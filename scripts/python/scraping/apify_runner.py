"""
File:     apify_runner.py
Purpose:  Thin, cached wrapper around the Apify API to run an actor and return
          its dataset items, with retries/backoff and on-disk caching so re-runs
          do not re-hit the platforms.
Inputs:   APIFY_TOKEN (via config); actor id + run input.
Outputs:  list[dict] dataset items; raw JSON cached under data/scraped/cache/.

Requires: pip install apify-client
"""
from __future__ import annotations
import json, time, hashlib
from pathlib import Path
from typing import Any

import config


def _cache_key(actor_id: str, run_input: dict[str, Any]) -> Path:
    blob = json.dumps({"actor": actor_id, "input": run_input}, sort_keys=True)
    h = hashlib.sha1(blob.encode("utf-8")).hexdigest()[:16]
    safe = actor_id.replace("/", "__")
    return config.CACHE / f"{safe}__{h}.json"


def run_actor(actor_id: str, run_input: dict[str, Any],
              retries: int = 2, timeout_s: int | None = None) -> list[dict]:
    """Run an Apify actor synchronously and return its dataset items.

    Results are cached by (actor_id, run_input). Delete the cache file to refresh.
    Raises RuntimeError if the token is missing or all retries fail.
    """
    cache_path = _cache_key(actor_id, run_input)
    if cache_path.exists():
        return json.loads(cache_path.read_text(encoding="utf-8"))

    if not config.APIFY_TOKEN:
        raise RuntimeError(
            "APIFY_TOKEN is not set. Export it before running: "
            "`export APIFY_TOKEN=...` (do not hardcode it)."
        )

    # Imported here so the module imports even before apify-client is installed.
    from apify_client import ApifyClient
    client = ApifyClient(config.APIFY_TOKEN)

    last_err: Exception | None = None
    for attempt in range(retries + 1):
        try:
            run = client.actor(actor_id).call(
                run_input=run_input,
                timeout_secs=timeout_s or config.ACTOR_TIMEOUT_S,
            )
            items = list(client.dataset(run["defaultDatasetId"]).iterate_items())
            cache_path.write_text(json.dumps(items, ensure_ascii=False), encoding="utf-8")
            return items
        except Exception as e:                                    # noqa: BLE001 — surface after retries
            last_err = e
            if attempt < retries:
                time.sleep(config.BACKOFF_BASE_S * (2 ** attempt))  # exponential backoff
            else:
                raise RuntimeError(f"Actor {actor_id} failed after {retries + 1} attempts: {e}") from e
    raise RuntimeError(f"Actor {actor_id} failed: {last_err}")     # unreachable, keeps type-checkers happy
