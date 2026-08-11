#!/usr/bin/env python3
"""Validate the text model provider registry used by the model-version gate."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


PRICE_FIELDS = ("input", "output", "cache_read", "cache_write")
ENDPOINT_FIELDS = (
    "region",
    "openai_base_url",
    "anthropic_base_url",
    "docs_root",
)


class RegistryDrift(ValueError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RegistryDrift(message)


def unique_strings(value: object) -> bool:
    return (
        isinstance(value, list)
        and bool(value)
        and all(isinstance(item, str) and item for item in value)
        and len(value) == len(set(value))
    )


def nonnegative_number(value: object) -> bool:
    return (
        isinstance(value, (int, float))
        and not isinstance(value, bool)
        and value >= 0
    )


def validate_provider(provider: object) -> str:
    try:
        require(isinstance(provider, dict), "provider entry must be an object")
        name = provider["name"]
        text = provider["text"]
        require(isinstance(name, str) and name, "provider name is invalid")
        require(isinstance(text, dict), f"{name}: text mapping is invalid")

        reason_codes = text["reason_codes"]
        require(
            isinstance(reason_codes, dict)
            and bool(reason_codes)
            and all(
                isinstance(key, str)
                and key
                and isinstance(value, str)
                and value
                for key, value in reason_codes.items()
            ),
            f"{name}: reason codes are invalid",
        )

        model_ids = text["model_ids"]
        models = text["models"]
        require(unique_strings(model_ids), f"{name}: model IDs are invalid")
        require(isinstance(models, list) and models, f"{name}: models are invalid")
        model_map = {model["model_id"]: model for model in models}
        require(
            len(model_map) == len(models) and set(model_ids) == set(model_map),
            f"{name}: model IDs do not match model details",
        )

        for model_id, model in model_map.items():
            context_window = model["context_window"]
            require(
                isinstance(context_window, int)
                and not isinstance(context_window, bool)
                and context_window > 0,
                f"{name}: {model_id} context window is invalid",
            )
            pricing = model["pricing_usd_per_million_tokens"]
            require(isinstance(pricing, dict), f"{name}: {model_id} pricing is invalid")
            for field in PRICE_FIELDS:
                price = pricing[field]
                require(
                    (field == "cache_write" and price is None)
                    or nonnegative_number(price),
                    f"{name}: {model_id} {field} pricing is invalid",
                )
            require(
                unique_strings(model["input_modalities"]),
                f"{name}: {model_id} input modalities are invalid",
            )
            require(
                unique_strings(model["thinking"]),
                f"{name}: {model_id} thinking modes are invalid",
            )

        default_model = model_map[text["model_id"]]
        for field in ("context_window", "pricing_usd_per_million_tokens", "thinking"):
            require(
                text[field] == default_model[field],
                f"{name}: default {field} does not match model details",
            )

        required_regions = provider["required_regions"]
        endpoints = provider["regional_endpoints"]
        require(unique_strings(required_regions), f"{name}: regions are invalid")
        require(isinstance(endpoints, list) and endpoints, f"{name}: endpoints are invalid")
        endpoint_map = {endpoint["region"]: endpoint for endpoint in endpoints}
        require(
            len(endpoint_map) == len(endpoints)
            and set(required_regions) == set(endpoint_map),
            f"{name}: regions do not match endpoints",
        )
        for endpoint in endpoints:
            require(
                all(
                    isinstance(endpoint[field], str)
                    and endpoint[field]
                    and (field == "region" or endpoint[field].startswith("https://"))
                    for field in ENDPOINT_FIELDS
                ),
                f"{name}: endpoint fields are invalid",
            )
        for field in ("openai_base_url", "anthropic_base_url"):
            require(
                text[field] in {endpoint[field] for endpoint in endpoints},
                f"{name}: default {field} does not match an endpoint",
            )
        return name
    except (KeyError, TypeError) as error:
        raise RegistryDrift(f"missing or malformed field: {error}") from error


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "registry",
        nargs="?",
        type=Path,
        default=(
            Path(__file__).resolve().parent.parent
            / ".claude"
            / "references"
            / "model-providers.json"
        ),
    )
    args = parser.parse_args()

    if not args.registry.is_file():
        print(f"check-model-providers: missing registry: {args.registry}", file=sys.stderr)
        return 2
    try:
        data = json.loads(args.registry.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"check-model-providers: cannot read registry: {error}", file=sys.stderr)
        return 2

    try:
        require(isinstance(data, dict), "registry root must be an object")
        require(data.get("schema_version") == 1, "schema_version must be 1")
        providers = data.get("providers")
        require(
            isinstance(providers, list) and bool(providers),
            "providers must be a non-empty list",
        )
        names = [validate_provider(provider) for provider in providers]
        require(len(names) == len(set(names)), "provider names must be unique")
    except RegistryDrift as error:
        print(f"MODEL-PROVIDER REGISTRY DRIFT: {error}", file=sys.stderr)
        return 1

    print(f"check-model-providers: {len(providers)} provider mapping(s) valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
