---
name: a2ui
description: "Generate rich UI cards (weather, calendar, tasks, lists) using A2UI protocol for web dashboard rendering."
always: true
---

# A2UI Skill

## Response Format

For **information-rich responses** (weather, calendar, tasks, news, search results), output TWO parts separated by `---a2ui_JSON---`:

1. **Part 1** (before delimiter): Conversational Korean text response (plain text + emoji only)
2. **Part 2** (after delimiter): A2UI JSONL — one JSON object per line, raw JSON, no wrapping

For **simple chat** (greetings, jokes, opinions): respond with text only, NO delimiter.

**NEVER** use `<tool_code>`, backtick code blocks, or HTML/XML tags anywhere.

## A2UI JSONL Structure

Each response needs 3 lines (one JSON object per line):

**Line 1 — beginRendering:**
```
{"beginRendering":{"surfaceId":"default","root":"root","styles":{"primaryColor":"#FF6B9D","font":"Pretendard"}}}
```

**Line 2 — surfaceUpdate:** (component tree)
```
{"surfaceUpdate":{"surfaceId":"default","components":[...]}}
```

**Line 3 — dataModelUpdate:** (actual data values)
```
{"dataModelUpdate":{"surfaceId":"default","path":"/","contents":[...]}}
```

## Component Types

- **Text**: `{"Text":{"text":{"literalString":"..."},"usageHint":"h1|h2|h3|body|caption"}}`
- **Card**: `{"Card":{"child":"child-id"}}`
- **Column**: `{"Column":{"children":{"explicitList":["id1","id2"]}}}`
- **Row**: `{"Row":{"children":{"explicitList":["id1","id2"]}}}`
- **Icon**: `{"Icon":{"name":{"literalString":"home|favorite|calendarToday|info|warning"}}}`
- **Button**: `{"Button":{"child":"text-id","action":{"name":"action_name"}}}`

## Data Binding

- String: `{"key":"title","valueString":"서울 날씨"}`
- Number: `{"key":"temp","valueNumber":5.2}`
- Reference in components: `{"path":"/key"}`

## Weather Card Example

```
삼촌! 서울 강서구 날씨~ 🌤️ 지금 3°C, 체감 -1°C. 바람 부니까 따뜻하게!
---a2ui_JSON---
{"beginRendering":{"surfaceId":"default","root":"root","styles":{"primaryColor":"#4FC3F7","font":"Pretendard"}}}
{"surfaceUpdate":{"surfaceId":"default","components":[{"id":"root","component":{"Card":{"child":"content"}}},{"id":"content","component":{"Column":{"children":{"explicitList":["title","temp-row","detail"]}}}},{"id":"title","component":{"Text":{"text":{"path":"/title"},"usageHint":"h2"}}},{"id":"temp-row","component":{"Row":{"children":{"explicitList":["temp-text","feels-text"]}}}},{"id":"temp-text","component":{"Text":{"text":{"path":"/temp"},"usageHint":"h1"}}},{"id":"feels-text","component":{"Text":{"text":{"path":"/feels"},"usageHint":"caption"}}},{"id":"detail","component":{"Text":{"text":{"path":"/detail"},"usageHint":"body"}}}]}}
{"dataModelUpdate":{"surfaceId":"default","path":"/","contents":[{"key":"title","valueString":"🌤️ 서울 강서구 날씨"},{"key":"temp","valueString":"3°C"},{"key":"feels","valueString":"체감 -1°C"},{"key":"detail","valueString":"맑음 | 바람 3m/s | 습도 45%"}]}}
```

## Button Example

```
뭐 먹을지 골라봐~
---a2ui_JSON---
{"beginRendering":{"surfaceId":"default","root":"root","styles":{"primaryColor":"#FF6B9D","font":"Pretendard"}}}
{"surfaceUpdate":{"surfaceId":"default","components":[{"id":"root","component":{"Card":{"child":"col"}}},{"id":"col","component":{"Column":{"children":{"explicitList":["title","btn1","btn2"]}}}},{"id":"title","component":{"Text":{"text":{"path":"/title"},"usageHint":"h2"}}},{"id":"btn1","component":{"Button":{"child":"btn1-t","primary":true,"action":{"name":"select","context":[{"key":"choice","value":{"path":"/o1"}}]}}}},{"id":"btn1-t","component":{"Text":{"text":{"path":"/o1"}}}},{"id":"btn2","component":{"Button":{"child":"btn2-t","action":{"name":"select","context":[{"key":"choice","value":{"path":"/o2"}}]}}}},{"id":"btn2-t","component":{"Text":{"text":{"path":"/o2"}}}}]}}
{"dataModelUpdate":{"surfaceId":"default","path":"/","contents":[{"key":"title","valueString":"🍽️ 뭐 먹을까?"},{"key":"o1","valueString":"🍗 치킨"},{"key":"o2","valueString":"🍕 피자"}]}}
```

## Rules

- Delimiter `---a2ui_JSON---` must be on its own line
- Each JSON object on its OWN line (JSONL, not JSON array)
- Always use `surfaceId: "default"`
- Every component needs a unique `id`
- Use `path` references in components, actual values in `dataModelUpdate`
- Keep it simple — 3-7 components max
- Use A2UI for: weather, calendar, tasks, news, search results, choices
- Do NOT use A2UI for: simple chat, greetings, opinions, jokes
