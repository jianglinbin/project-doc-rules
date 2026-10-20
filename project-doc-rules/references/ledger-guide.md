# 阶段 3：台账层（ledger/）初始化指南

> 产出：`ledger/LEDGER_RULES.md`、`ledger/INDEX.md`、`ledger/v{version}.md`。
> 前两份从 `assets/templates/` **复制后替换占位符**，不要重写；本文件只讲制度要点与替换清单。

## 一、复制与替换

| 模板 | 落盘为 | 替换项 |
|---|---|---|
| `assets/templates/LEDGER_RULES.md.tpl` | `ledger/LEDGER_RULES.md` | `{{PROJECT_NAME}}` |
| `assets/templates/ledger-INDEX.md.tpl` | `ledger/INDEX.md` | `{{VERSION}}`、`{{DATE}}`、主题说明占位 |
| `assets/templates/ledger-entry.md.tpl` | `ledger/v{version}.md` | `{{VERSION}}`、`{{DATE}}`、`{{CARRY_OVER}}`（承接编号，首版为 0，即从 d1 起） |

注意：INDEX/条目模板中 `{{VERSION}}` 前已有字面 `v`，**替换值不带 v 前缀**（填 `0.1.2` 而非 `v0.1.2`，否则出 `vv`）。替换后 `grep -r "{{" ledger/` 必须为 0。

若已有历史版本需要追溯，可按 INDEX 表格式为每个历史版本补一行（文件可缺，区间写实际已知范围并注明「追溯」）。

## 二、制度要点（LEDGER_RULES 模板即制度全文，不在此复述、不落盘）

只强调 LEDGER_RULES 之外的两点：
- **条目行 `| dN | … |`（九列管道表：编号/日期/类型/议题/决议/依据/改动/验证/关联）是机器解析契约**：单元格内出现竖线或列数不为 9 会判损坏；字段写法照模板，不自创。
- **防口径漂移**：编号铁律、记账时机、状态机等制度以 LEDGER_RULES 为唯一文本源，禁止在 AGENTS.md 或其他文件复述（AGENTS.md 只放两三行引用条款）。

## 三、当前版本账本头部

`v{version}.md` 按模板生成后，头部字段：

```
版本：{{version}}
开账日期：{{date}}
承接编号：{{carry_over}}（首版写 0，下一条从 d1 起）
状态：进行中
```

正文按 `ledger-entry.md.tpl` 的条目格式追加。

## 四、与 AGENTS.md 的接口

阶段 1 生成的 AGENTS.md 已含「版本台账」条款（动手前查号 / 收尾跑校验 / 制度见 LEDGER_RULES）。若当时该条款是 TODO 占位，现在回填为正式条款（引用 `ledger/LEDGER_RULES.md`，两三行即可，不复述制度）。

> 注：本阶段落盘后账本尚无条目，此时跑校验报「未解析到条目」属预期，d1 于阶段 4 记入后自然消除。

写盘后进入阶段 4（`check-script-guide.md`）。
