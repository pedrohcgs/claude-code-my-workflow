# Knowledge Mgmt Templates

Use these as structural guides. Match the repo's current formatting before copying any template literally.

## Deliverables folder naming

Preferred pattern:

`knowledge_mgmt/deliverables/YYYY-MM-DD_<project-name>/`

Examples:
- `2026-04-03_美的集团与上市平台对标/`
- `2026-04-02_GB200_NVL72_capex/`

Use a concise project name that is:
- specific enough to be searchable
- short enough to stay readable in links

## Chinese log section template

```md
## YYYY-MM-DD | 项目名

### Request

[任务原文或根据交付物反推的请求]

### What I Did

- [动作 1]
- [动作 2]
- [动作 3]

### Conclusion

[2-4 段高信号结论，必要时用 flat bullets]

### Deliverables

- [交付物 1](./deliverables/YYYY-MM-DD_xxx/file.ext)

### Sources

直接 source：
- [来源 1](url-or-path)

本地可复用 source：
- [脚本或底稿](../explorations/...)

### Reusable Knowledge

- [以后怎么复用]

### Open Gaps / Follow-Up

- [还缺什么]
```

## English log section template

```md
## YYYY-MM-DD | Project Name

### Request

[What the user asked for]

### What I Did

- [action 1]
- [action 2]
- [action 3]

### Conclusion

[High-signal conclusion paragraphs or flat bullets]

### Deliverables

- [artifact](./deliverables/YYYY-MM-DD_xxx/file.ext)

### Sources

Official or direct sources:
- [source](url-or-path)

Reusable local source:
- [script or notes](../explorations/...)

### Reusable Knowledge

- [what to reuse later]

### Open Gaps / Follow-Up

- [what remains incomplete]
```

## Quick index row template

Chinese table row:

```md
| YYYY-MM-DD | 项目名 | 核心结论 | [打开目录](./deliverables/YYYY-MM-DD_xxx/) |
```

English table row:

```md
| YYYY-MM-DD | Project Name | Core conclusion | [artifact](./deliverables/YYYY-MM-DD_xxx/file.ext) |
```

## Minimal checklist

Before finishing, check:
- the quick index was updated
- the full project section was added
- `deliverables/README.md` includes the new folder
- links point to real files
- the summary distinguishes facts from judgments
