# Resume Writing Guidelines

## 核心原则：Bold Prefix Keywords（关键词前缀）

**EVERY bullet in work experience AND projects MUST start with a bold scan label.** For Chinese resumes, use `\textbf{简短总结：}` — a 3-8 character bold label followed by a Chinese colon. For English resumes, use `\textbf{Short Label:}` — a 2-4 word bold label followed by an English colon. This is the single most important formatting rule.

The bold prefix serves as a "scan line" — a reader should understand 80% of the resume just by reading the bold prefixes. Each prefix is a mini-title that telegraphs the bullet's content.

**Common prefixes for work experience:**
| Category | Prefix Examples |
|----------|----------------|
| Core execution work | 项目执行, 投前决策, 投前项目, 投资跟进, 项目承做 |
| Research & analysis | 行业研究, 赛道研究, 个股分析, 硬科技趋势研判 |
| Data & ops | 数据处理与维护, 数据与纪要, 周报产出, 底稿撰写 |
| Modeling & quantitative | 模型构建, 实证研究, 多目标优化, 因果推断 |
| Strategy & insight | 商业分析, 框架构建, 薪酬机制设计 |
| Communication | 报告与呈现, 成果输出, 独立访谈项目 |

**Common prefixes for projects:**
| Category | Prefix Examples |
|----------|----------------|
| Framework | 商业分析与实证设计, 四链智驱框架, 三层分析框架 |
| Modeling | 动态决策与阵容优化, 因果推断与机制检验 |
| Data | 数据采集与清洗, 问卷与数据分析 |
| Writing | 论文撰写与可视化, 报告与呈现 |
| Strategy | 文本挖掘与策略落地, 人群聚类与策略锚定 |

**Anti-pattern:** A bullet without a bold prefix is invisible on first scan. Never write:
```latex
\item 参与了某餐饮集团增长战略项目，搭建了分析体系...
```
Always write:
```latex
\item \textbf{增长战略：}搭建全球餐饮集团增长分析体系...
```

## Capability Over Brands（展示能力而非罗列品牌）

The worst resume mistake is "brand-dumping" — listing prestigious names without showing what YOU specifically did, how you did it, and what you concluded. The reader is hiring YOUR capability, not the brands you've touched.

### Anti-Pattern (brand-dumping)
> 参与BCG某头部餐饮集团项目、某电子制造集团AI采购战略项目、某高端零售品牌战略项目。

This tells the reader NOTHING about what you can actually do. Three BCG projects listed with zero substance.

### Correct Pattern (capability-demonstrating)
> **某头部餐饮集团增长战略：** 搭建全球餐饮集团增长分析体系，从增长来源出发，拆解经营形式、出海扩张、M&A等杠杆对P&L、ROIC和估值的传导机制。核心判断：资本市场为门店模型质量（unit economics）而非增长故事（growth narrative）定价。

This shows: framework-building capability, financial analysis depth, global benchmarking scope, AND independent analytical judgment.

**Rule:** Behind every brand name (BCG, 中金, 深创投), there must be a specific, quantified action YOU took and an insight YOU generated. If a bullet could have been written by anyone who worked at that company, it's too generic.

## The Independence Gradient（独立/主导梯度）

Signal ownership level precisely. Chinese verbs form a clear gradient:

| Level | Verbs | When to Use |
|-------|-------|-------------|
| **Full ownership** | 独立完成, 独立搭建, 独立撰写, 独立负责 | You did it entirely yourself with minimal supervision |
| **Strong leadership** | 主导, 主笔, 统筹 | You led the workstream, others contributed |
| **Deep involvement** | 深度参与, 深度分析, 重点拆解 | You were a key contributor with significant scope |
| **Supporting role** | 参与, 协助, 支持 | You contributed to something led by others |

**Rule:** Maximize the ownership level you can honestly claim. If you "independently built the financial model," say so. If you "supported the partner's analysis," say "参与." But never inflate — the interviewer will probe.

**Key insight from excellent resumes:** The strongest candidates use 独立完成/主导/深度参与 as their DEFAULT verbs and only use 参与 for genuinely peripheral work. If every bullet starts with 参与, you look like a bystander.

## Technical Depth → Business Translation（技术深潜→商业转译）

This is the gold standard for analytical/technical roles. The best bullets execute a two-layer move:

1. **Layer 1 (Deep):** Show you understand the technical substance at a granular level — methods, parameters, mechanisms, data
2. **Layer 2 (Translate):** Explain WHY it matters in business/investment terms — what decision it informs, what risk it reveals, what value it creates

### Industry-Leading Example (陈皓)
> 针对该项目进行商业化可行性分析。指出当前 Over-built Infra 的 Timing Risk；针对团队缺乏 Native AI 背景问题，协助团队叙事规避早期非共识风险。

Layer 1 = technical understanding of AI Infra; Layer 2 = translated into investment risk and narrative strategy.

### Industry-Leading Example (辛亦迪)
> 深入分析传统侵入式脑机方案的现存行业风险。从pipeline和2b/3期临床实验结果入手，深入分析某AI制药公司现存风险，拆解现存结构性机会与风险。

Layer 1 = pipeline analysis, clinical trial data; Layer 2 = structural opportunity/risk assessment for investment decisions.

### Industry-Leading Example (王韧)
> 独立完成Staggered DID全流程，DID系数+0.2496（p<0.01）量化验证融资效率改善；配合500次随机安慰剂检验、平行趋势检验和SOE异质性分析；完成信用可得性（14.8%）与营运资金优化（20.1%）双渠道机制检验。

Layer 1 = Staggered DID, robustness checks, heterogeneity analysis; Layer 2 = quantified financing efficiency improvement, mechanism channels with specific magnitudes.

**Rule of thumb:** If your bullet only has Layer 1 (pure technical description), you look like a technician. If it only has Layer 2 (pure business commentary), you look like you don't understand the details. You need BOTH to look like an investor/consultant.

## Judgment & Conviction Language（判断力表达）

Excellent resumes don't just report facts — they take stances. Use judgment-language verbs to signal analytical maturity:

**Judgment verbs to use:**
- 核心判断 / 指出...风险 / 辩证评估 / 论证 / 提炼 / 识别 / 判断

**Anti-pattern (fact-reporting):**
> 完成了21家上市餐饮集团的财务数据对比分析。

**Correct pattern (judgment-embedding):**
> 完成21家上市餐饮集团10年财务数据底表与对比。核心判断：资本市场为门店模型质量（unit economics）而非增长故事（growth narrative）定价。

**Where to place judgment:**
- End of the strongest bullet as a standalone "核心判断：" sentence
- Embedded mid-bullet as "指出...Risk" or "论证..."
- In the bold prefix itself when the entire bullet is a judgment: "硬科技趋势研判："

**Important:** Judgment must be earned by the facts above it. Don't lead with a big claim and then provide no evidence. The fact-chain MUST support the conclusion.

## Bullet Ordering Strategy（Bullet排序策略）

Within each experience entry, order bullets by IMPACT and OWNERSHIP, not chronology:

1. **First bullet:** Your most self-directed, analytical, high-stakes work (投前项目, 项目执行, 投前决策)
2. **Second bullet:** Supporting work that still shows strong capability (行业研究, 赛道研究, 硬科技趋势研判)
3. **Third bullet (if needed):** Operational work or secondary projects (数据与纪要, 周报产出, 项目搜寻)

**Why this matters:** Recruiters read the first bullet of each experience most carefully. If the first bullet is "整理纪要" while the third bullet is "独立完成深度报告," you've buried your strongest signal.

## The Action-Result-Insight Arc

Every bullet should follow this progression: **Setup → Action → Result → Insight**

A single bullet can be 3-5 sentences long if it tells one complete story. Long bullets are OK — what matters is narrative coherence, not length.

**Example (Good):**
> Built a global restaurant group growth analysis framework, deconstructing the transmission mechanisms of format evolution, international expansion, and M&A on P&L, capital returns, and valuation. Compiled 10-year financial database and comparative analysis of 21 listed restaurant groups, covering Asia-Pacific benchmarks including Zensho, Jollibee, and DPC Dash. Core insight: capital markets price store-level unit economics quality, not growth narratives.

This bullet tells ONE story: "I built a framework → here's what went into it → here's the conclusion."

## Verb Conventions

### Strong Action Verbs (USE THESE)

| Category | Verbs |
|----------|-------|
| Analysis | 拆解, 分析, 诊断, 对标, 映射, 量化测算 |
| Building | 构建, 搭建, 设计, 建立, 开发 |
| Leading | 主导, 统筹, 推动, 驱动 |
| Delivering | 完成, 交付, 撰写, 输出 |
| Validating | 验证, 量化验证, 交叉验证, 稳健性检验 |
| Deep work | 深度参与, 深入分析, 重点拆解, 独立完成 |
| Judgment | 指出, 论证, 识别, 提炼, 判断 |

### Weak Verbs (AVOID THESE)

Never start a bullet with:
- "帮助..." (Helped with)
- "参与了..." (Participated in)
- "负责..." (Was responsible for — too vague, say what you specifically DID)
- "协助..." (Assisted with — unless genuinely just supporting)
- "了解了..." (Got exposure to)
- "做了..." (Did...)

If you "帮助" someone do something, you either **did** it or **supported** it — pick the honest verb.

### English Verb Equivalents

| Chinese | English |
|---------|---------|
| 主导 | Led / Drove |
| 构建 / 搭建 | Built / Constructed / Designed |
| 拆解 / 分析 | Analyzed / Deconstructed / Dissected |
| 独立完成 | Independently completed / Single-handedly delivered |
| 统筹 | Coordinated / Orchestrated |
| 验证 / 量化验证 | Validated / Quantitatively verified |
| 深度参与 | Deeply engaged in / Served as key contributor to |

## Quantification Rules

### Everything Gets a Number

Numbers are the anchor of credibility. Quantify:
- **Scope**: "500+ SKUs," "21 listed groups," "18 vendors," "9 equipment categories"
- **Scale**: "10-year financial data," "6,754 reviews," "345 samples across 111 variables"
- **Performance**: "60.8% win rate," "93.7% salary cap utilization," "+115% WAR improvement"
- **Output**: "3 in-depth reports," "20+ data tables," "6 earnings call memos," "50+页立项报告"
- **Rankings**: "Rank 3/150," "National Top 10," "Provincial 2nd Prize"
- **Time investment**: "完成6h+的独立访谈" (shows depth of engagement)

### When Exact Numbers Aren't Available

Use approximations marked with ~ or range indicators:
- "30+项目," "100余篇," "逾20篇," "20+份"

Never say "很多," "若干," "大量," or "各种."

## Specificity Over Generality

### Name Names

Excellent resumes name specific companies, products, and technologies:
- "覆盖 Zensho、Jollibee、达势集团" not "覆盖多家餐饮集团"
- "完成 HDD 金属件（T-ring/Damper/Bobbin）材料构成与工艺壁垒拆解" not "完成零部件分析"
- "对比分析不同算力架构对分子模拟的影响" not "研究技术影响"

### Name Methods

- "应用 Staggered DID 配合 500 次随机安慰剂检验" not "做了计量分析"
- "构建 DL-ADDM 双循环动态决策模型与 SAC 强化学习代理" not "建了数学模型"
- "运用 Black-Scholes 期权定价重构为看涨期权" not "做了金融分析"

### Name Frameworks

- "运用 PEST 与波特五力拆解竞争格局" not "分析了行业"
- "按工业品平台/流程型SRM/招采交易平台三层分类" not "做了分类"

## Taste & Personality Signals（个人特质信号）

The Skills section should NOT be a dry checklist. It's an opportunity to show genuine intellectual interests and personality.

### Anti-Pattern (checklist)
> 技能：Python, Stata, SQL, Wind, Office, AI工具

### Correct Pattern (personality-signaling)
> AI工具使用：重度使用 Cursor、Claude Code、Codex 等 IDE/agent 工具；曾用 AI agent 独立完成工厂设备管理平台前端原型与个人portfolio

OR (陈皓 style):
> AI 工具使用: Gemini, Perplexity, Claude Code 等产品的长期付费订阅用户。长期追踪 The Information, AI Times, ProductHunt，与多家 AI 初创团队保持联系并受邀为被访谈对象；保持对 AI 应用趋势的敏感度

**Key difference:** The good version shows HOW you use tools and WHY you care. "长期付费订阅用户" signals genuine commitment, not just resume padding. "长期追踪...保持联系" shows this is a real interest, not a bullet point.

**For campus activities:** Be selective. Include things that signal something:
- Consulting/finance clubs → professional network and ambition
- Sports teams → teamwork and discipline
- Music/arts → well-rounded personality
- Skip generic memberships that signal nothing

## Section-Specific Guidelines

### Education

- GPA format: "4.28/5" (not "4.28 out of 5")
- Ranking format: "Rank 3/150" (not "top 2%")
- List 3-4 highest-score courses with scores: "财务管理（98）、Python 程序设计（97）、投资学（96）"
- Scholarships in order of prestige (National before University-level)

### Work Experience

- **CRITICAL: Every bullet MUST start with `\textbf{关键词：}`** — the bold prefix is non-negotiable
- Each module/workstream gets one bullet that tells the complete story
- Order modules by impact/impressiveness, not chronologically
- For each work entry, aim for 2-3 modules with 1 bullet each
- Include **核心判断：** for consulting/strategy modules where you generated an original insight
- Client anonymization: "某头部餐饮集团" is fine, but the analytical detail must be hyper-specific to compensate

### Projects

- Use `\workentry` format
- **CRITICAL: Projects MUST have 2-3 bullets, each starting with `\textbf{简短总结：}`**
- Bullet label: 4-8 character noun phrase summarizing that bullet's focus
- **How to split**: Divide the project work into 2-3 logically distinct dimensions:
  - Modeling competition: "动态决策与阵容优化" + "期权定价重构球员补偿"
  - Case competition: "商业分析" + "实证研究" (or "因果推断与机制检验")
  - Marketing competition: "问卷与数据分析" + "文本挖掘与策略落地"
  - AI/business case: "四链智驱框架" + "报告与呈现" (or "ROI验证")
- Emphasize: analytical framework, methodology rigor, quantitative results, and business judgment

### Skills & Interests

- Four standard categories: 语言, 研究与数据, AI工具使用, 校园经历
- Languages: include scores (CET-4: 656, CET-6: 631, IELTS 7.5)
- Research & Data: list specific tools (MS Office, Python, Stata, SQL, Wind, iFind, Bloomberg)
- AI Tools: **make this personal** — show HOW you use them, not just that you know they exist
- Campus: selective, only memberships that signal something real

## Wording Tips

### Chinese (中文)

- Use precise quantifiers: `抓取 500+ SKU` not `抓取大量SKU`
- Use industry-standard abbreviations after first mention: `锅圈食汇（02517.HK）`
- Document/report titles in `《书名号》`
- Use `、` (enumeration comma) for lists within sentences
- Use `；` (semicolon) to separate sub-clauses within a long bullet
- Prefer `完成 / 构建 / 拆解 / 主导` over weak verbs
- Contact info labels: `电话：`, `邮箱：`, `作品集：`
- "某+行业+公司类型" for anonymized clients: "某头部餐饮集团", "某AI4S公司"

### English (EN)

- Report titles in backtick quotes: `` ``Restaurant Industry Entering Recovery Phase`` ``
- Stock tickers in parentheses: `Guoquan Shihui (02517.HK)`
- Use en-dash `--` for ranges: `2024.09 -- 2028.06`
- Use `\&` for ampersands in LaTeX
- Percent signs need backslash: `60.8\%`
- Dollar signs need backslash: `\$450K`

## What Makes a Bullet Strong vs. Weak

### Weak Bullet (vague, no numbers, no insight, no bold prefix)
> 参与了餐饮行业研究项目，写了一些报告。

### OK Bullet (specific but no insight, no bold prefix)
> 协助撰写3篇餐饮行业深度报告，维护5个品牌数据库。

### Strong Bullet (bold prefix, specific, quantified, insight-driven)
> **行业与公司研究：** 参与锅圈食汇（02517.HK）首次覆盖，独立搭建运营数据底稿和财务预测模型，拆解门店指标与估值假设；参与深度报告《餐饮行业步入复苏阶段》，拆解行业复苏逻辑与同店表现分化；核心判断：同店表现的分化——而非总量复苏——才是板块重定价的核心驱动力。

### What Changed
1. Added bold prefix for scan-ability
2. Named the specific stock (锅圈食汇, 02517.HK)
3. Showed independence (独立搭建 vs 参与)
4. Named specific outputs (运营数据底稿, 财务预测模型, 深度报告书名)
5. Showed analytical framework (拆解门店指标与估值假设)
6. Added a core insight that synthesizes the analytical takeaway

## Two-Language Consistency

When maintaining both Chinese and English versions:
- Content must be 1:1 aligned (same facts, same numbers, same structure)
- Wording should feel natural in each language — do NOT translate word-for-word
- Chinese can use slightly more compact phrasing (characters are information-dense)
- English can use slightly longer, more flowing sentences
- Both versions must fit on exactly 1 page
- English bold prefixes should also be short labels: `\textbf{Growth Strategy:}`, `\textbf{Industry Research:}`, `\textbf{Deal Execution:}`
