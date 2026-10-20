# 通用 zip 发布流水线模板（project-doc-rules 提供）
#
# 用法：复制为项目 .github/workflows/release.yml，替换三处占位符后随库提交：
#   {{PKG_DIR}}  —— 要打包的目录（仓库根下相对路径，如 my-skill）
#   {{PKG_NAME}} —— 产物名前缀（完整前缀，如 my-skill-skill）
#   关键文件断言列表 —— 改成该项目包内必须存在的文件（至少一条）
# 触发约定：手动触发只出 artifact（验证用）；推 tag vX.Y.Z 挂 GitHub Release
# （zip + SHA256SUMS）。checkout 只含被跟踪文件，.gitignore 挡掉的东西天然不进包。
name: release-zip

on:
  workflow_dispatch:
  push:
    tags: ["v*"]

permissions:
  contents: write

concurrency:
  group: release-zip-${{ github.ref }}
  cancel-in-progress: true

jobs:
  package:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4

      - name: Package
        shell: bash
        run: |
          case "$GITHUB_REF_NAME" in
            v[0-9]*.[0-9]*.[0-9]*) ;;
            *) echo "::error::tag 必须是 vX.Y.Z 形态：$GITHUB_REF_NAME"; exit 1 ;;
          esac
          VERSION="${GITHUB_REF_NAME#v}"
          # 关键文件断言（按项目改这份列表，至少一条）
          for f in {{PKG_DIR}}/README.md; do
            [ -f "$f" ] || { echo "::error::缺 $f"; exit 1; }
          done
          ZIP="{{PKG_NAME}}-${VERSION}.zip"
          zip -qr "$ZIP" {{PKG_DIR}}
          # 结构断言：顶层目录名在包里，解压不散落
          unzip -l "$ZIP" | grep -q "{{PKG_DIR}}/" \
            || { echo "::error::zip 内缺少 {{PKG_DIR}}/ 顶层目录"; exit 1; }
          echo "ZIP=$ZIP" >> "$GITHUB_ENV"

      - name: SHA256
        run: |
          sha256sum "$ZIP" > SHA256SUMS.txt
          cat SHA256SUMS.txt

      - uses: actions/upload-artifact@v4
        with:
          name: release-zip
          path: |
            ${{ env.ZIP }}
            SHA256SUMS.txt
          if-no-files-found: error

      - name: Publish Release
        if: startsWith(github.ref, 'refs/tags/v')
        uses: softprops/action-gh-release@v2
        with:
          files: |
            ${{ env.ZIP }}
            SHA256SUMS.txt
