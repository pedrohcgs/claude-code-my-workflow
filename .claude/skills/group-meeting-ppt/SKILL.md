---
name: group-meeting-ppt
description: >
  从文献PDF一键生成组会汇报Beamer PPT + 讲稿。
  读取论文、厘清汇报要求、生成幻灯片（.tex）并编译、
  生成讲稿（.tex）并编译，全程自动完成。
argument-hint: "[论文PDF路径] [可选：附录路径]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Agent"]
---

# 组会汇报 PPT + 讲稿生成工作流

## 触发方式

```
/group-meeting-ppt path/to/paper.pdf
/group-meeting-ppt path/to/paper.pdf path/to/appendix.docx
```

---

## 约束（不可更改）

1. Beamer 主题：Madrid，SYSU 配色（见 `Preambles/header.tex`）
2. 不使用 `\pause`、`\onslide`、`\only` 等 overlay 命令
3. 幻灯片：约16—20张，覆盖论文全部核心内容
4. 每张幻灯片不得溢出（vbox/hbox 溢出 >10pt 必须修复）
5. 编译命令：`cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode <file>.tex`
6. 输出文件：`Slides/<AuthorYear>_LitReview.tex` 和 `Slides/<AuthorYear>_Script.tex`
7. 讲稿：Times New Roman + Songti SC（衬线），`article` 类，按幻灯片分段，含时间提示

---

## WORKFLOW

### Phase 0：用户需求确认

向用户提问（最多4个问题，可并行合并提问）：

| 问题 | 默认值 |
|------|--------|
| ① 汇报语言（中文/英文/中英混合） | 中文为主，保留必要英语术语 |
| ② 汇报时长（分钟） | 20分钟 |
| ③ 字体风格（衬线/无衬线） | 衬线（Songti SC） |
| ④ 机构显示 | 中山大学商学院 |

如果用户在命令中已经说明，跳过对应问题。

---

### Phase 1：深度阅读论文

按如下顺序读取材料：

1. **全文PDF**（分段读取，最多20页/次）
2. **附录**（如有）

提取并记录以下信息（内部笔记，不展示给用户）：

```
论文元信息
  - 标题（中文 + 英文）
  - 作者、期刊、年份、DOI
  - JEL分类（若有）

核心内容
  - 研究问题（1—2句）
  - 识别策略（DID / RD / IV / PSM / 其他）
  - 核心自变量、因变量
  - 数据来源、样本范围
  - 3—5个主要结果（含关键系数值）
  - 机制检验路径（含交叉项或中介变量）
  - 异质性分析维度
  - 稳健性检验方法

可嵌入幻灯片的数字
  - 关键回归系数 + 标准误 + 显著性
  - 样本量、均值等描述性统计
  - 政策背景数字（规模、时间节点等）
```

---

### Phase 2：规划幻灯片结构

提出幻灯片大纲（含 section 划分和每张标题），参考以下模板：

```
Section 1: 研究背景与动机        （2—3张）
  - 现实问题 / 政策背景
  - 研究缺口

Section 2: 文献回顾与理论框架    （2张）
  - 既有研究 + 本文贡献
  - 理论机制 / 假说

Section 3: 研究设计              （2张）
  - 模型设定（含公式）
  - 数据来源与变量构建

Section 4: 实证结果              （2—3张）
  - 基准回归
  - 稳健性 / 层次检验（如有）

Section 5: 机制分析              （2—3张）
  - 每条机制1张

Section 6: 异质性与调节效应      （1—2张）

Section 7: 评价与结论            （2—3张）
  - 批判性评价（贡献 + 局限）
  - 主要结论
  - 政策启示与展望（含致谢）
```

**GATE**：向用户展示大纲，确认后进入 Phase 3。
若用户无异议（回复"可以""好""继续"），直接进入。

---

### Phase 3：生成 Beamer PPT

#### 3.1 确定文件名

```
<第一作者姓氏><年份>_LitReview.tex
例：Sun2023_LitReview.tex
```

#### 3.2 文件头部（固定模板）

```latex
\documentclass[aspectratio=169, 11pt]{beamer}
\input{header}

% 衬线字体（如用户指定衬线）
\usefonttheme{serif}
\IfFontExistsTF{Songti SC}{%
  \setCJKmainfont{Songti SC}
  \setCJKsansfont{Songti SC}
}{%
  \IfFontExistsTF{STSong}{%
    \setCJKmainfont{STSong}
    \setCJKsansfont{STSong}
  }{%
    \setCJKmainfont{STHeiti}
  }
}

\title[短标题]{完整标题}
\subtitle{\textit{期刊名}，年份}
\author[机构缩写]{%
  \textbf{论文：}作者（年份）\\[4pt]
  \textbf{汇报：}王韧}
\institute[中山大学]{中山大学商学院}
\date{组会汇报，\today}
```

#### 3.3 内容规范

- 每张幻灯片优先使用 `\begin{columns}[T]` 双栏布局
- 数据表格使用 `booktabs`（`\toprule`/`\midrule`/`\bottomrule`）
- 关键数字 / 结论用 `\alerttext{...}` 高亮
- 正面结论用 `\positivetext{...}`（如 header.tex 中定义）
- 公式幻灯片用 `\begin{alertblock}{模型}` 包裹
- 内容密集时加 `\small` 或 `\footnotesize`
- 表格列头避免长中文字符串，改用 (1)(2)(3) + 脚注说明

#### 3.4 溢出修复循环

每次编译后检查 log：

```bash
grep "Overfull" <file>.log
```

修复规则：
- vbox > 10pt：裁剪文字、降字号（`\small` → `\footnotesize`）、删次要要点
- hbox > 5pt：拆行、缩短句子、简化表头
- 循环至无 >10pt 溢出为止（最多5轮）

---

### Phase 4：生成讲稿

#### 4.1 文件名

```
<AuthorYear>_Script.tex
```

#### 4.2 文件结构（固定模板）

```latex
\documentclass[12pt, a4paper]{article}
\usepackage{fontspec}
\usepackage{xeCJK}
\usepackage{geometry}
\usepackage{titlesec}
\usepackage{xcolor}
\usepackage{fancyhdr}
\usepackage{parskip}

\setmainfont[Ligatures=TeX]{Times New Roman}
\IfFontExistsTF{Songti SC}{%
  \setCJKmainfont{Songti SC}
}{%
  \setCJKmainfont{STSong}
}

\geometry{top=2.5cm, bottom=2.5cm, left=3cm, right=3cm}
```

#### 4.3 讲稿内容规范

- 按幻灯片顺序分段，每段开头标注 `【第N张】幻灯片标题`
- 语言：口语化、流畅，不是幻灯片内容的简单复读
- 每段末尾标注预计用时（如 `约1.5分钟`）
- 衔接词自然（"接下来"、"但现实中"、"这说明"……）
- 关键数字口语化（`5.70` 读作"5点7"而非"5.70"）
- 末尾附时间节奏总表

#### 4.4 时间分配参考

| 论文时长 | 幻灯片数 | 背景 | 设计 | 结果+机制 | 异质性 | 结论 |
|----------|----------|------|------|-----------|--------|------|
| 15分钟   | 14—15张  | 2m   | 2m   | 5m        | 2m     | 2m   |
| 20分钟   | 16—18张  | 4m   | 3m   | 8m        | 2m     | 2m   |
| 25分钟   | 18—22张  | 5m   | 4m   | 10m       | 3m     | 2m   |

---

### Phase 5：最终验证

1. 编译 PPT（两遍，生成正确 TOC）：
   ```bash
   TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode <ppt>.tex
   TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode <ppt>.tex
   ```
2. 编译讲稿：
   ```bash
   TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode <script>.tex
   ```
3. 向用户汇报：生成的文件路径、页数、剩余溢出（如有）

---

## 完成检查清单

```
[ ] PPT .tex 编译无 Error
[ ] PPT 无 vbox/hbox 溢出 > 10pt
[ ] 所有主要结论都有数字支撑（系数 + 显著性）
[ ] 机制分析每条假说对应独立幻灯片
[ ] 包含批判性评价幻灯片
[ ] 讲稿 .tex 编译无 Error
[ ] 讲稿每段有时间提示
[ ] 讲稿总时长与用户要求匹配
[ ] 会话日志已更新
```

---

## 常见问题速查

| 问题 | 解决方案 |
|------|----------|
| `Songti SC` 找不到 | fallback → `STSong` → `STHeiti` |
| `Latin Modern Roman` 找不到 | 改用 `Times New Roman` |
| 表格太宽（hbox > 30pt） | 列头改 `(1)(2)(3)` + 脚注 |
| 三栏 block 溢出 | 每 block 最多3个 item，去掉 `\vspace` |
| `header.tex` 找不到 | 检查 `TEXINPUTS=../Preambles:$TEXINPUTS` 是否设置 |
| `\positivetext` 未定义 | 用 `\textcolor{green!60!black}{\textbf{...}}` 替代 |
