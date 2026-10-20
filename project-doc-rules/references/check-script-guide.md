# 阶段 4：校验闭环

> 产出：`tools/ledger_check.py` 跑通 + 台账首条决议。minimal 档（无台账）跳过本阶段，只保留 AGENTS.md 的命名条款。

## 一、脚本获取：复制，不要重写

从 `assets/scripts/ledger_check.py` 复制到项目 `tools/ledger_check.py`。脚本为通用实现，首次运行前只做两处项目化：

1. 头部 `PROJECT_NAME` 改为 `{project_name}`（仅影响输出标题）。
2. 若项目已有「编号区间随分支整体归档」的历史，在 `ledger/archives.json` 登记（文件不存在则无需创建）：
   ```json
   [{"lo": 10, "hi": 20, "branch": "archive/some-line"}]
   ```
   登记后的区间缺号只提示豁免、不判损坏。没有归档历史就什么都不用配。

## 二、检查项（脚本已内置）

1. 编号 `dN` 全局连续：d1 起无断号、无重号（归档区间豁免）。
2. 单本台账内部编号连续。
3. `INDEX.md` 每个版本的编号区间、条数与账本实际条目一致；指向文件存在。
4. 条目为管道表行（`| dN | … |`，固定 8 列），单元格内出现竖线或列数不符即判损坏；解析不到条目的账本报警。

退出码：0 = 通过；1 = 台账损坏。损坏必须先修复再提交——这是硬门槛。

## 三、接入 AGENTS.md

确认 AGENTS.md 台账条款包含两句（阶段 1 应已写入，缺则补）：

- 动手前：`python tools/ledger_check.py` 确认下一个可用编号，避免撞号。
- 收尾必做：同脚本，退出码非 0 必须先修复再提交。

## 四、dogfooding：为本次建档记台账 d1

在建档工作全部落盘后，往 `ledger/v{version}.md` 的表格末尾追加首行（一条决议一行，八列）：

| d1 | {{date}} | 制度 | 建立「规则-规格-决议」三层文档体系（skill 生成） | AGENTS.md 全文 | AGENTS.md、ledger/、tools/ledger_check.py | 校验脚本退出码 0 | — |

随后再跑一次校验，确认 d1 被正确解析、INDEX 区间与条数一致（INDEX 模板初始行为 `v{version} | v{version}.md | d1 – d1 | … | 1 | 进行中`，与实际不符就按实际填）。

## 五、收尾

按 SKILL.md「收尾」段执行（产出清单 + 档位理由 + 遗留 TODO + 使用约定），此处不再重复。
