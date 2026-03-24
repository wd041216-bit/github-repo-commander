# GitHub Repo Commander

把一个 GitHub 仓库从“勉强能看”提升到“更安全、更清楚、更可信、更适合公开传播”。

English README: [README.md](./README.md)

`github-repo-commander` 是一个通用社区技能，适合多种 agent 运行时。它不是单纯做 README 美化，而是把仓库公开前真正需要的一整套治理工作放到同一个流程里。

## 适合谁用

- 准备把仓库开源的维护者
- 想提升 README、metadata 和 discoverability 的 skill / tool 作者
- 想一次性清理隐私泄漏、包装层问题和文档欠账的人
- 准备投 awesome list、curated directory、社区导航页的项目作者

## 它会帮你做什么

- 发现开源前的隐私和安全阻塞项
- 优化 README 首屏和项目定位表达
- 对齐 `README`、`SKILL.md`、`skill.json` 等元数据
- 补齐 changelog、security、contributing 等信任信号
- 为社区提交或目录收录做准备

## 安装

把仓库 clone 到你的 skill 目录，或在支持文件式 skill 的运行时里直接使用 [SKILL.md](./SKILL.md)。

```bash
git clone https://github.com/wd041216-bit/openclaw-github-repo-commander.git \
  ~/.codex/skills/github-repo-commander
```

建议具备：

- `gh`
- `git`
- Python 3

## 快速示例

```bash
python3 ./scripts/repo_commander_audit.py /path/to/repo
```

典型输出会像这样：

```text
HIGH   README.md 中疑似暴露 github token
HIGH   docs/setup.md 中包含本地机器路径
MEDIUM README 首页缺少清晰的公开定位
LOW    公共仓库缺少 CHANGELOG.md
LOW    主打安全审计的仓库缺少 SECURITY.md
```

完整示例见 [examples/audit-example.md](./examples/audit-example.md)。

## 典型工作流

1. 先审计隐私、包装和 metadata 问题。
2. 先修高优先级阻塞项：
   - token
   - 本地路径
   - 个人信息
   - 误导性的公开文档
3. 再优化首屏表达：
   - 一句话定位
   - 面向谁
   - 快速示例
   - 关键结果
4. 再补公开信任信号：
   - changelog
   - contributing
   - security
   - release 说明
5. 最后准备社区提交：
   - awesome-list 条目
   - 分类 / 字母顺序
   - 元数据一致性

## 它和普通 README 工具有什么不同

很多工具只覆盖一个点，比如 secret scanning、README 生成、或者 discoverability。`github-repo-commander` 把 GitHub 仓库公开准备当成一个完整流程：

1. 让它安全
2. 让它清楚
3. 让它可信
4. 让它更容易被发现

## 进阶工作流资产

仓库里也保留了更重型的 GitHub 工作流参考：

- [references/workflow.md](./references/workflow.md)
- [references/gh-commands.md](./references/gh-commands.md)
- [scripts/repo-audit.sh](./scripts/repo-audit.sh)
- [scripts/privacy-check.sh](./scripts/privacy-check.sh)
- [scripts/competitor-search.sh](./scripts/competitor-search.sh)

## 作为社区技能如何使用

- 主要说明入口：[SKILL.md](./SKILL.md)
- 生态元数据：[skill.json](./skill.json)、[_meta.json](./_meta.json)
- skill 卡片元数据见仓库内 `agents/openai.yaml`
- 可执行审计脚本：[scripts/repo_commander_audit.py](./scripts/repo_commander_audit.py)

## 仓库内容

- [SKILL.md](./SKILL.md)
- [README.md](./README.md)
- [examples/audit-example.md](./examples/audit-example.md)
- [docs/compatibility.md](./docs/compatibility.md)
- [CONTRIBUTING.md](./CONTRIBUTING.md)
- [SECURITY.md](./SECURITY.md)
- [CHANGELOG.md](./CHANGELOG.md)
- [scripts/repo_commander_audit.py](./scripts/repo_commander_audit.py)
