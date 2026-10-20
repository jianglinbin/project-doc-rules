# project-doc-rules

**为任意项目建立「规则-规格-决议」三层文档体系的 AI Agent 技能。** 适用于新项目建档，或既有项目补建/整顿文档体系。

## 项目简介

AI Agent 长期主导项目开发时，文档体系缺失会带来四个典型失控场景：

1. **行为规则散落**——代码放哪、按什么流程写，每个会话重新发明一次；
2. **方案翻案无据**——改了什么、为什么改、依据什么拍板，事后无人能答；
3. **跨会话丢上下文**——Agent 换个会话就忘掉已拍板的约束，重新发明已否决的方案；
4. **文档膨胀失控**——所有信息堆进一个文件，上下文窗口装不下，Agent 要么加载不全要么干脆不读。

本技能以一套**经过真实项目数百条决议生产验证**的制度回应：把文档按回答的问题拆成三层——

- **规则层**（`AGENTS.md`，<150 行）：Agent 行为唯一入口，只管「代码放哪里、怎么写、按什么流程」，内置 11 条通用过程纪律；
- **规格层**（`*_PLAN.md` / `*_SPEC.md`）：每条功能线一份，是「做什么、为什么、怎么验收」的唯一开工依据；
- **决议层**（`ledger/` 台账）：一版本一本账，决议编号 `dN` 全局连续、只追加、机器校验，任何决定都能沿「依据」链回溯。

三层之间**渐进引用**：Agent 从最小的 AGENTS.md 进入，按需下钻，永远不必一次加载全套文档；编号与索引一致性交给校验脚本（退出码判定），不靠人眼自觉——这是制度能长期存活的唯一保障。

技能本身即按这套制度开发：驱动 Agent 走**访谈式四阶段建档**（档位判断 → 规则层 → 规格层 → 台账层 → 校验闭环），产出全套骨架文件与校验脚本；另附可选发布出口（GitHub 建仓 / 推送 / CI 挂 Release 一键完成，token 加密保存）。

## 三层体系

| 层 | 载体 | 回答的问题 | 关键纪律 |
|---|---|---|---|
| **规则层** | `AGENTS.md`（<150 行） | 「代码放哪里、怎么写、按什么流程」 | 单一入口；不重复规格内容，只引用 |
| **规格层** | `*_PLAN.md` / `*_SPEC.md` | 「做什么、为什么、验收标准」 | 头部元数据三件套；冲突时规格 > 规则，先改规格再改代码 |
| **决议层** | `ledger/` 台账 | 「每个决定是什么时候、依据什么做的」 | 编号 `dN` 全局连续、只追加；脚本机器校验 |

设计要点：

- **机器可校验**——编号连续性、索引一致性交给 `ledger_check.py`（退出码判定），不靠人眼。
- **决议可追溯**——每条决议带「依据」字段，可沿链回溯，Agent 换会话不丢上下文。

## 安装

```bash
# 方式一：Release zip（推荐）
# 从 GitHub Releases 下载 project-doc-rules-<ver>-skill.zip，解压到所用 Agent 的技能目录，
#   例如 ~/.claude/skills/project-doc-rules/（各 Agent 的技能目录以其文档为准）

# 方式二：从源码安装
git clone https://github.com/jianglinbin/project-doc-rules
cp -r project-doc-rules <你的 Agent 技能目录>/
```

## 使用

在与 AI Agent 的对话中说任意触发词即可：**初始化项目**、项目初始化、项目规则、AGENTS.md、文档规范、台账、决议记录、建立文档体系。

技能按四个阶段执行（每阶段只加载一份 reference，模板一律复制不重写）：

```
阶段 0 档位判断 → 阶段 1 规则层(AGENTS.md) → 阶段 2 规格层 → 阶段 3 台账层 → 阶段 4 校验闭环
```

### 档位

| 档位 | 产出 | 适用 |
|---|---|---|
| **full** | AGENTS.md + 规格模板 + ledger 三件套 + 校验脚本 | 正式产品、多功能线、Agent 长期主导 |
| **lean** | AGENTS.md + ledger 三件套 + 校验脚本 | 单人/单 Agent 项目、决议量中等 |
| **minimal** | 仅 AGENTS.md | 小工具、短生命周期仓库 |

### 内置通用基础规则

生成的每个 AGENTS.md 默认携带 11 条与技术栈无关的过程纪律（访谈可裁剪）：未确认不动工、规格先行、单一真值、先提交再推送、机器护航、产物与源分离、零警告门槛、实改动即记账、无明确指令不执行、推送由用户主动要求、标签策略即问即清。

## 发布出口（可选）

用户要求「推 GitHub / 触发 CI」时，技能提供 `tools/github_publish.py`（纯 Python 标准库，跨平台）：

```bash
python tools/github_publish.py token set        # token 加密保存（keyring），明文 0600 为明确允许的兜底
python tools/github_publish.py repo create NAME --private
python tools/github_publish.py push --tags      # 脏工作区拒绝推送；tag v* 触发 CI 挂 Release
python tools/github_publish.py publish --private --tags --watch   # 全流程一键
```

token 政策：加密保存优先，明文兜底明确允许；永不入库、不打日志、不进 git config。详见技能内 `references/github-publish-guide.md`（含「什么进公开仓、什么留本地」的四问判定标准）。

## CI

`.github/workflows/release.yml`：手动触发只构建 artifact（验证）；推 tag `vX.Y.Z` 自动打包技能 zip + SHA256SUMS 并挂 GitHub Release（自动生成 release notes）。

## 目录结构

```
project-doc-rules/
├── SKILL.md                       # 技能入口：路由表 + 铁律 + 档位速判
├── references/                    # 按需加载的阶段指南（6 份）
├── assets/
│   ├── templates/                 # 台账三件套/规格/CI 模板（复制后替换占位符）
│   └── scripts/                   # ledger_check.py（校验）+ github_publish.py（发布）
└── .github/workflows/release.yml  # zip 打包 + Release 流水线
```
