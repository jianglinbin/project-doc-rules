# 发布出口：推送 GitHub（github_publish.py）

> 时机：建档/开发收尾后，用户要求「推 GitHub / 发布到 GitHub / 触发 CI」时使用本工具。
> 脚本获取：从 `assets/scripts/github_publish.py` 复制到项目 `tools/`，**不重写**。

## 一、token 政策（本技能明确授权，向用户说明时引用本节）

**允许脚本保存 GitHub token**，两种方式皆可，按优先级自动选择：

1. **加密保存（默认首选）**：`pip install keyring` 后自动落系统凭据库
   （Windows 凭据管理器 / macOS 钥匙串 / Linux Secret Service）。
2. **明文保存（明确允许的兜底）**：无 keyring 时写入配置目录，POSIX 上权限 0600，
   Windows 依赖用户 Profile 的 ACL 保护。用户点名允许此方式，不必回避。

环境变量 `GITHUB_TOKEN` / `GH_TOKEN` 优先于以上两者（CI 场景用）。

**红线（无论哪种存储方式都不可违背）**：
- token 永不提交进任何 git 仓库（本技能自身的本地工作数据目录隔离约定同样适用）；
- token 永不出现在日志、输出、remote URL 的持久化配置里（脚本内已打码/一次性 URL）；
- 粘贴过 token 的会话记录视为敏感，提醒用户泄露后立即在
  GitHub → Settings → Developer settings 轮换。

## 二、命令速查

```bash
python tools/github_publish.py token set          # 交互粘贴；--stdin 管道喂入；--plain 跳过加密
python tools/github_publish.py token check        # 校验，返回账号名
python tools/github_publish.py repo create NAME --private
python tools/github_publish.py push --tags        # 当前分支 + 全部 tag；脏工作区会拒绝
python tools/github_publish.py ci trigger --workflow release.yml
python tools/github_publish.py ci status --watch  # 等待 CI 结论（默认最长 30 分钟）
python tools/github_publish.py publish --private --tags --watch   # 全流程一键
```

## 三、行为约定（与仓库制度衔接）

1. **先提交再推送，推送由用户主动要求**：脚本遇脏工作区直接拒绝——这是把 AGENTS.md「先提交本地库，再推送」
   的顺序铁律做成了机器门槛，不要用 `--allow-dirty` 绕过。**推送由用户主动发起**（基础规则 10）：
   Agent 不推送、也不主动询问是否推送；push 远程、远程 tag、Release 只在用户明确说「推 / 发布」时执行。
2. **开发侧文件不上公开仓**：`.gitignore` / `.clang-format` /
   `.gitattributes`，以及**规则层与台账（`AGENTS.md`、`ledger/`）**——它们是开发过程
   产物，公开仓只放对外交付物。`.gitignore` 的自排除做法：把 `.gitignore` 一行写进
   `.gitignore` 本身（忽略规则对未跟踪文件依然生效），再 `git rm --cached` 移出索引
   （ledger 加 `-r`）并提交。脚本 push 时发现这些文件被跟踪会给出提示。
3. **token 不进 git config**：脚本用一次性 URL 推送；若项目原本没有 origin，
   推完会补一个无凭据的 origin 供日常 fetch/pull。
4. **CI 触发两型**：`workflow_dispatch` 型用 `ci trigger`；`push tags` 型用 `push --tags`。
   本地只有一个 workflow 文件时 `publish` 子命令会自动识别并等待结论。
5. **目标仓库记忆**：`repo create` / 成功推送后把 `owner/name` 记在配置目录
   （repo.json），后续命令不必重复指定；优先级为 `--repo` > origin remote > repo.json。

## 四、上传判定标准（什么进公开仓，什么留本地）

对每个准备提交的文件/目录，**按顺序问四个问题**：

1. **是对外交付物吗？**——删掉它，仓库的使用者/协作者会受影响吗？
   受影响（源码、技能包、构建/打包脚本、CI 配置、README/LICENSE）→ **上传**；不受影响 → 进入第 2 问。
2. **是开发过程产物吗？**——只为「开发/维护本仓」服务的 → **留本地**（gitignore + `git rm --cached`）：
   规则层与台账（`AGENTS.md`、`ledger/`）、维护工具实例（`tools/` 里技能 assets 已有原件的脚本）、
   规划/审查/会议文档、工作记忆与日志。
3. **含凭据或私有信息吗？**——token、内网 IP、本机用户路径、密钥。无论第 1 问答案如何，
   必须先脱敏或不上传；拿不准就跑残留扫描（正则扫内网段 / 用户名 / `token` 字样）。
4. **仍拿不准？**——**默认不上传**（保守侧），向用户确认；确认结果记台账。

默认清单（多数项目直接套用）：

| 上传 | 留本地 |
|---|---|
| 对外交付物目录（如技能包、`src/`） | `AGENTS.md`、`ledger/`、`tools/` 维护脚本实例 |
| `.github/workflows/`（CI 是交付物的一部分） | 规划/审查文档、Agent 工作区数据目录、凭据文件 |
| `README.md` / `LICENSE`（若项目设有） | `.gitignore` 自身（自排除） |

**反例信号**（公开仓出现即违反本标准）：台账、规则层文档、规划稿、日志、任何凭据。

## 五、失败速查

| 症状 | 处置 |
|---|---|
| `token 校验失败 HTTP 401` | token 失效/过期 → 用户重新生成 → `token set` 覆盖 |
| `建仓失败 HTTP 422` 且 GET 也 404 | 同名仓库属于其他账号 → 换名或 `--repo OWNER/NAME` |
| 推送被拒 non-fast-forward | 远端有本地没有的提交 → 先 `git pull --rebase`，**禁 --force** |
| `触发失败 HTTP 422` | workflow 缺 `on: workflow_dispatch`，或该文件只在非默认分支 → 改走 tag 触发 |
| `ci status` 长时间 queued | runner 排队，属 GitHub 侧状态，非脚本问题；超时后重查即可 |

## 六、CI 模板：tag 挂 Release（可选出口）

仓库有可打包产物（技能目录/文档集）时，从 `assets/templates/release-zip.yml.tpl`
复制为项目 `.github/workflows/release.yml`，替换三处占位符：`{{PKG_DIR}}` 打包目录、
`{{PKG_NAME}}` 产物名前缀、关键文件断言列表按项目实际改（至少一条）。

触发约定：**手动触发只出 artifact（验证）；tag `vX.Y.Z` 挂 Release**
（zip + SHA256SUMS.txt）。发布全流程：commit → `push` → `git tag vX.Y.Z` →
`push --tags` → `ci status --watch` 盯结论。
