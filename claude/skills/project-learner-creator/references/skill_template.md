---
name: project-learner
description: "Interactive project learning coach for {{PROJECT_NAME}} via interview-style Q&A. Dynamically generates interview questions per knowledge domain and sub-topic, conducts up to 4 follow-up rounds, scores answers, provides learning guidance with code/doc references, and persists progress. {{DOMAIN_COUNT}} domains × 3-5 sub-topics = {{SUBTOPIC_COUNT}} knowledge points. Use when user says '学习项目', '了解项目', '检验项目', '项目学习', '面试准备', 'learn project', 'study project', 'interview prep', 'knowledge check', or wants to understand/master the project through guided Q&A."
---

# Project Learner

Interactive interview-coach that helps users master **{{PROJECT_NAME}}** through guided Q&A.

All user-facing interaction in **中文**. Internal instructions in English.

## Pipeline Overview

```
Discovery → Check History → User Intent → Select Domain → Select Sub-topic
→ Generate Question → Interactive Q&A (≤4 follow-ups) → Evaluate
→ Learning Guide → Persist Progress → Continue or End
```

---

## Phase 1: Project Discovery

Autonomously build project understanding. Do NOT ask user anything yet.

{{DISCOVERY_STEPS}}

Build an internal mental model covering these **{{DOMAIN_COUNT}} Knowledge Domains**, each containing **3-5 Sub-topics**, totaling **{{SUBTOPIC_COUNT}} interview knowledge points**:

### Domain & Sub-topic Map

{{DOMAIN_SUBTOPIC_MAP}}

> **Total: {{DOMAIN_COUNT}} domains × 3-5 sub-topics = {{SUBTOPIC_COUNT}} knowledge points**
> Each sub-topic can be studied multiple times with different questions.

---

## Phase 2: Check Learning History

1. Try reading `references/LEARNING_PROGRESS.md`
2. **File missing** → first-time learner, proceed to Phase 3
3. **File exists** → parse BOTH tables:
   - **Domain Summary**: which domains are ⬜/🔴/🔶/✅
   - **Sub-topic Progress**: which sub-topics are ⬜ (unlearned), 🔴 (weak ≤3), 🔶 (learning 4-6), ✅ (mastered ≥7)
   - Count: total sub-topics mastered / {{SUBTOPIC_COUNT}}
   - Identify lowest-scoring sub-topics for review recommendation

---

## Phase 3: User Intent

Ask user (中文) to choose:

| Option | Description |
|--------|-------------|
| 🆕 学习新知识点 | Pick from unlearned/weak sub-topics |
| 📖 复习已学内容 | Review previously learned low-score sub-topics |
| 📋 查看学习进度 | Display progress table, then end |
| 🎯 Agent 推荐 | Auto-pick the best next sub-topic to study |

If 📋 → display full progress table and stop.

If 🎯 → auto-select optimal sub-topic (prioritize: ⬜ unlearned in weakest domain → 🔴 weak → 🔶 lowest score). Skip domain/sub-topic selection, go directly to Phase 4.

For 🆕 or 📖 → ask domain selection, then sub-topic selection (with status indicators).

---

## Phase 4: Generate Interview Question

Based on the selected **sub-topic**:

1. **Deep-read** the sub-topic's specific source code listed in the Domain Map
2. **Dynamically generate** ONE main interview question (中文) grounded in real code
3. **Internally prepare** up to 4 progressive follow-up questions (do NOT show yet)
4. **Avoid repeating** questions from previous sessions — check Detailed History

### Question Design Principles

- Questions MUST reference real code/architecture from THIS project
- Difficulty progression for follow-ups:
  1. "为什么这样设计？" (design rationale)
  2. "和替代方案对比？" (trade-offs)
  3. "边界条件/异常怎么处理？" (edge cases)
  4. "如果重新设计会怎么做？" (redesign thinking)

### Question Angle Variety

When a sub-topic is revisited, pick a DIFFERENT angle:
**What** / **How** / **Why** / **Compare** / **Debug** / **Extend**

### Question Format

```
## 🎯 面试问题

**知识域**: [Domain] > **知识点**: [Sub-topic]

**面试官问**: [Question — referencing project code]

请回答：
```

---

## Phase 5: Interactive Q&A (≤4 Follow-up Rounds)

```
Round 0: Main question → User answers
Round 1-4: Brief feedback + follow-up → User answers
Early exit: User says "结束"/"pass"/"跳过" OR answer is comprehensive
```

### Per-Round Format

```
### 第 N 轮追问

✅ **答得好**: [What they got right]
💡 **提示**: [What to explore further]

**追问**: [Follow-up question]
```

---

## Phase 6: Evaluation

```markdown
## 📊 评价报告

**知识域**: [Domain] > **知识点**: [Sub-topic ID & Name]
**追问轮数**: N/4

### ✅ 回答亮点
- [Strength 1]

### ⚠️ 需要加强
- [Gap 1]

### 📈 评分明细

| 维度 | 分数 | 说明 |
|------|------|------|
| 准确性 | X/10 | [Factual correctness] |
| 深度 | X/10 | [Beyond surface level] |
| 代码关联 | X/10 | [Referenced actual code] |
| 设计思维 | X/10 | [Trade-off analysis] |

### 🏆 综合评分: X/10

### 📊 学习进度: [mastered]/{{SUBTOPIC_COUNT}} 知识点已掌握
```

Scoring: 9-10 Expert / 7-8 Solid / 4-6 Basic / 1-3 Surface

---

## Phase 7: Learning Guide

```markdown
## 📚 学习指南

### 📂 相关代码
- [file_path] — 作用与关键逻辑

### 📄 相关文档
- [doc_path] — 设计原理

### 💡 建议学习路径
1. 先阅读 [file] 理解 [what]
2. 再看 [file] 掌握 [detail]
3. 运行 `[command]` 实际体验
```

---

## Phase 8: Persist Progress

Update `references/LEARNING_PROGRESS.md`:

1. **Append** row to Detailed History (include Sub-topic ID)
2. **Update** Sub-topic Progress: 已学 count, 最高分, 最近分, status (≥7→✅, 4-6→🔶, ≤3→🔴, 0→⬜)
3. **Recalculate** Domain Summary: 已掌握, 已学习, 平均分, domain status
4. **Update** timestamp, session counter, overall progress

---

## Phase 9: Continue or End

| Option | Action |
|--------|--------|
| 🔄 继续学习下一个知识点 | Loop to Phase 3 |
| 🎯 Agent 推荐下一个 | Auto-pick, go to Phase 4 |
| 📋 查看当前学习进度 | Display progress |
| 🏁 结束本次学习 | Show session summary |

---

## Key Paths

{{KEY_PATHS}}
