---
name: project-doc-rules
description: 为项目建立「规则-规格-决议」三层文档体系。触发词：初始化项目、项目初始化、项目规则、AGENTS.md、文档规范、项目文档制度、台账、决议记录、建立文档体系、ledger。生成 AGENTS.md（Agent 行为规则）、规格文档规范、版本台账（ledger/）与校验脚本。适用于新项目建档或既有项目补建/整顿文档体系。
---

# project-doc-rules — 项目文档规则体系建立

为任意项目建立经过生产实践验证的三层文档体系：**规则层（AGENTS.md）→ 规格层（\*_PLAN/\*_SPEC.md）→ 决议层（ledger/ 台账）**。

## 铁律（执行本 skill 期间始终生效）

1. **按需加载**：每个阶段只读「路由表」指定的那一份 reference，读完即用，不回读已完成阶段的文件。
2. **模板不进上下文**：台账三件套与校验脚本一律从 `assets/` 复制后做项目化替换（占位符 `{{PROJECT_NAME}}`），禁止凭记忆重写。
3. **产出即落盘**：每阶段产物写盘后再进入下一阶段；阶段间只传递交接变量（见下）。
4. **信息不足不中断**：访谈没答完的问题生成「TODO 标注」占位，最后统一汇总未决项告知用户；TODO 是兜底不是默认，能问尽问。
5. **骨架通用、血肉访谈**：台账制度照模板；目录职责表、依赖规则、铁律必须根据该项目实际情况生成，禁止硬编码套用其他项目内容。访谈按「设计树 + 待问边界轮询」纪律执行（`references/interview-guide.md`）。

## 交接变量（阶段间传递，保持在内存）

`{project_name}`、`{tier}`（档位：full / lean / minimal）、`{version}`（当前版本号）、`{carry_over}`（承接编号：首版 0；既有项目补建时取既有台账最大编号）。

## 阶段路由表

| 阶段 | 做什么 | 读哪份 reference | 适用档位 | 产出 |
|---|---|---|---|---|
| **0 档位判断** | 考察项目（见下方速判），确定 `{tier}` | `references/doc-system-overview.md` | 全档 | 档位决策 + 体系蓝图（对用户简述） |
| **1 规则层** | 访谈采集 → 生成 AGENTS.md（骨架按档位裁剪，见该文件） | `references/interview-guide.md` + `references/agents-md-guide.md` | 全档 | `AGENTS.md` |
| **2 规格层** | 生成项目方案 `docs/PROJECT_PLAN.md`（full/lean，方案轮访谈见 spec-guide §零）+ full：复制规格模板 + 命名条款进 AGENTS.md；minimal：只把下方简版条款写进 AGENTS.md | `references/spec-guide.md`（minimal 不读） | 全档 | `docs/PROJECT_PLAN.md`（full/lean）+ `docs/SPEC_TEMPLATE.md`（仅 full）+ 条款 |
| **3 台账层** | 复制模板 → 项目化替换 → 建当前版本账本 | `references/ledger-guide.md` | full / lean | `ledger/LEDGER_RULES.md` + `INDEX.md` + `v{version}.md` |
| **4 校验闭环** | 复制校验脚本 → 跑通 → 回写 AGENTS.md 使用条款 → 为本次建档记台账首条 | `references/check-script-guide.md` | full / lean | `tools/ledger_check.py` + 台账 d1 |

**阶段 2 简版条款（minimal 直接抄进 AGENTS.md，不读 spec-guide；lean 抄进后另按 spec-guide §零 生成项目方案）**：

```markdown
## 文档与规划
- 较大功能线动手前先写 <FEATURE>_PLAN.md（目标/非目标/约束/里程碑/验收），定稿后按此实施。
- 方案变更先改规格文档并记台账，再改代码。
```

**收尾**：跑一次校验脚本确认退出码 0；向用户汇报产出清单与遗留 TODO；提醒「每次实质改动后立即记账、收尾跑校验」的使用约定。

## 发布出口（可选，用户要求「推 GitHub / 触发 CI」时进入）

复制 `assets/scripts/github_publish.py` 到项目 `tools/` 后按指南操作（token 允许脚本加密或明文保存，政策见该文件；推送动作仅在用户明确提出时执行，见指南 §三）：读 `references/github-publish-guide.md` → token set → repo create → push --tags → ci trigger/status。

## 档位速判（进入阶段 0 前的粗筛，最终以 reference 为准）

- **full（全量三层）**：正式项目、多功能线并行、AI Agent 长期主导开发、需要可追溯决议。
- **lean（精简：AGENTS.md + 台账）**：单人/单 Agent 项目、功能线少、暂无独立规格需求。
- **minimal（仅 AGENTS.md）**：小工具、脚本库、生命周期短的仓库——台账编号体系是纯负担，不引入。

## 产出清单（full 档全量；lean/minimal 按档裁剪）

```
AGENTS.md                     # 规则层：Agent 行为唯一入口，<150 行
docs/PROJECT_PLAN.md          # 项目方案：项目级唯一开工依据（full/lean；minimal 并入引言不落盘）
docs/SPEC_TEMPLATE.md         # 规格模板（full 档）；*_PLAN/*_SPEC 由未来功能线按模板生成
ledger/LEDGER_RULES.md        # 台账制度（模板复制）
ledger/INDEX.md               # 版本索引：Agent 唯一入口（模板复制）
ledger/v{version}.md          # 当前版本账本（模板复制）
tools/ledger_check.py         # 校验脚本（assets 复制，退出码 0=通过）
tools/github_publish.py       # 发布出口工具（assets 复制；建仓/推送/CI，见发布出口节）
```
