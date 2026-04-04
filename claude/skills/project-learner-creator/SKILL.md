---
name: project-learner-creator
description: "为任意项目自动生成专属的'面试式项目学习 Skill'。深度分析项目代码，自动划分 8-12 个知识域、每域 3-5 个知识点（共 30-50 点），生成动态出题的面试教练 Agent，支持 4 轮追问、多维评分、学习指南和进度持久化。Use when user says '生成learner', '生成学习skill', '创建learner skill', 'create project learner', 'generate learner skill', '学习这个项目', '面试准备', or wants to create a reusable interview-style learning skill for any codebase."
---

# Project Learner Creator — 面试式项目学习 Skill 生成器

分析目标项目，生成独立的 `project-learner` skill（面试式动态问答 + 多维评分 + 学习指南 + 进度持久化），可被 Claude Code 直接加载使用。

---

## 启动时确认

1. **目标项目路径**（默认当前工作目录）
2. **skill 输出路径**（默认 `{项目根目录}/project-learner/`）
3. **学习侧重**：特别想深入的模块？（可选，默认全覆盖）
4. **语言**（默认中文）

用户不指定则用默认值直接启动。

---

## 生成流程

### Phase 1：项目深度分析

用 Agent（subagent_type=Explore, thoroughness=very thorough）探索项目，收集：

| 维度 | 要收集的信息 |
|------|-------------|
| 项目定位 | 名称、解决什么问题、目标用户 |
| 技术栈 | 语言、框架、构建工具、关键依赖版本 |
| 架构分层 | 服务/模块划分、各自职责、协作关系 |
| 核心流程 | 请求链路、数据流、关键业务流程 |
| 设计决策 | 为什么选某技术、有哪些 trade-off |
| 存储 | 数据库/缓存/消息队列/文件存储 |
| 工程实践 | 测试、CI/CD、部署、配置管理 |
| 扩展点 | 如何添加新功能、插件/模块化机制 |

信息来源优先级：**代码 > 配置文件 > README > git 历史**

同时识别项目的**关键入口文件**（main、config、核心模块入口），记录在 skill 的 Key Paths 表中。

### Phase 2：设计知识域与知识点地图

将项目知识组织为 **8-12 个知识域（Domain）**，每域 **3-5 个知识点（Sub-topic）**，总计 **30-50 个知识点**。

**组织原则**：
- D1 固定为"项目整体架构"（端到端流程、分层设计、核心数据类型）
- 中间域按模块依赖顺序排列，每个核心模块/服务独立成域
- 横切关注点（可观测性、测试、工程化）放在末尾
- 最后一个域固定为与幂等性/生命周期管理相关的主题

**每个知识点必须包含**：
- ID：`D{域号}.{点号}`（如 D2.3）
- 名称：简洁的知识点名称
- Key Code Areas：对应的具体文件/目录路径（必须真实存在）

**知识域地图格式**（写入 SKILL.md）：

```markdown
| ID | 知识域 / 知识点 | Key Code Areas |
|----|----------------|----------------|
| **D1** | **{域名}** | |
| D1.1 | {知识点名} | `path/to/file` |
| D1.2 | {知识点名} | `path/to/file` |
```

完成后向用户展示知识域地图，等待确认或调整。

### Phase 3：生成 Skill 文件

生成以下目录结构：

```
project-learner/
├── SKILL.md                    # 面试教练 Agent 指令（含知识域地图）
└── references/
    └── LEARNING_PROGRESS.md    # 初始进度文件（全部 ⬜ 未学习）
```

#### SKILL.md 生成规则

参照 `references/skill_template.md` 模板，替换以下变量：

| 变量 | 替换为 |
|------|--------|
| `{{PROJECT_NAME}}` | 项目名称 |
| `{{DOMAIN_COUNT}}` | 知识域数量 |
| `{{SUBTOPIC_COUNT}}` | 知识点总数 |
| `{{DOMAIN_SUBTOPIC_MAP}}` | 完整的知识域×知识点地图表 |
| `{{DISCOVERY_STEPS}}` | Phase 1 的项目发现步骤（要读哪些文件） |
| `{{KEY_PATHS}}` | 关键文件路径表 |
| `{{TRIGGERS}}` | 触发词 |

#### LEARNING_PROGRESS.md 初始化

参照 `references/progress_template.md` 模板生成：
- Domain Summary 表：所有域 `⬜ 未学习`
- Sub-topic Progress 表：每域下所有知识点 `⬜ 未学习`，已学/最高分/最近分均为 `-`
- Detailed History 表：空
- 总进度：`0/{{SUBTOPIC_COUNT}}`

### Phase 4：交付

向用户展示：
1. 知识域 × 知识点地图概览
2. 生成文件路径
3. 触发使用方式（如"说'学习项目'即可启动"）

---

## 关键约束

- 知识点总数控制在 30-50 个，太多会导致学习周期过长
- 项目超过 10 个模块时，建议用户选择重点模块
- 每个知识点的 Key Code Areas 必须指向真实存在的文件/目录
- 生成前验证所有文件路径存在
- 生成的 SKILL.md 中**不包含题库**——题目由 Agent 在运行时根据知识点动态生成
