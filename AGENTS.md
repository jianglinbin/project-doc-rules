# project-doc-rules 项目规则

> project-doc-rules 技能的源仓库：为任意项目建立「规则-规格-决议」三层文档体系。
> 本文件只规定「东西放哪里、怎么维护、怎么发布」，不重复技能内容；与技能内容冲突以技能包为准。
> **改动纪律**：改技能 → 同步安装副本 → 记台账 → 跑校验 → 提交 → 推送 →（发版时）打 tag。

## 目录职责单一（核心）

| 目录/文件 | 只放 | 禁止放 |
|---|---|---|
| `project-doc-rules/` | 技能包本体：SKILL.md、references/、assets/ | 任何项目专有内容（示例一律用通用名） |
| `project-doc-rules/assets/scripts/` | 随技能分发的 Python 工具 | 一次性本地脚本 |
| `project-doc-rules/assets/templates/` | 可复制落盘的模板（`.tpl`，占位符 `{{...}}`） | 已实例化的项目文件 |
| `.github/workflows/` | CI：release.yml（tag v* 挂 Release） | 其他无关 workflow |
| `tools/`、`AGENTS.md` | 仓库自身档案：校验/发布脚本、本文件 | 技能包内容（那属于 project-doc-rules/） |
| `ledger/` | 本仓台账——**开发过程文档，仅存本地**（gitignore，同 FlashRec 私有仓口径，d5） | —— 永不提交 |
| `.workbuddy/` | 本地工作区数据（记忆/日志），gitignore | —— 永不提交 |
| 根目录 `*-plan.md` / `*-review.md` | 开发规划与审查文档，gitignore | —— 不上公开仓 |

## 关键纪律

1. **两副本一致**：改技能后必须同步安装副本（`cp -r project-doc-rules/. ~/.workbuddy/skills/project-doc-rules/`），`diff -r` 验证通过才算改完。
2. **无项目专有内容**：技能包内的示例、文档、脚本不得出现具体项目名/真实编号（示例一律用通用名）。
3. **token 红线**：凭据不入任何 git 仓库、不打日志、不进 remote 配置；发布用 `tools/github_publish.py`（token 存用户配置目录）。
4. **开发侧工具文件不上公开仓**：`.gitignore` 自排除（自身不入库），同 d372 约定。

## 版本与发布

- 版本号唯一真值：git tag（`vX.Y.Z`），无独立版本清单文件。
- 发布：提交 → `python tools/github_publish.py push` → `git tag vX.Y.Z` → `push --tags` → CI（release-skill）自动打 zip 挂 Release。
- 顺序铁律：先提交本地库，再推送 GitHub（发布脚本对脏工作区直接拒绝）。

## 版本台账（ledger/）

- 一版本一本账，一条决议一条记录；编号 dN 全局连续、只追加、跨版本不重置。
- 动手前 `python tools/ledger_check.py` 确认下一个可用编号；收尾必跑，退出码非 0 先修复再提交。
- 制度详见 `ledger/README.md`。
