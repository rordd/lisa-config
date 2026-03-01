---
name: a2ui
description: "Render rich UI cards on the web dashboard using the `canvas` tool. Use for weather, calendar, tasks, news, lists, settings — any response that benefits from visual layout."
always: true
---

# A2UI Skill — Canvas Tool

When a response benefits from **visual UI** (weather, calendar, tasks, lists, news, settings), use the `canvas` tool to render A2UI cards on the connected web dashboard.

## How to Use

### Push UI Cards

Call the `canvas` tool with:
- `action`: `"a2ui_push"`
- `jsonl`: A2UI JSONL string (one JSON object per line)

### Clear UI

Call the `canvas` tool with:
- `action`: `"a2ui_reset"`

## JSONL Structure

Each `jsonl` payload needs **3 lines** (one JSON per line):

**Line 1 — beginRendering** (initialize surface):
```
{"beginRendering":{"surfaceId":"default","root":"root"}}
```

**Line 2 — surfaceUpdate** (component tree):
```
{"surfaceUpdate":{"surfaceId":"default","components":[...]}}
```

**Line 3 — dataModelUpdate** (bind data values):
```
{"dataModelUpdate":{"surfaceId":"default","path":"/","contents":[...]}}
```

## Component Types

| Type | Usage | Structure |
|------|-------|-----------|
| Text | Labels, headings | `{"Text":{"text":{"literalString":"..."}\|{"path":"/key"},"usageHint":"h1\|h2\|body\|caption"}}` |
| Card | Container with shadow | `{"Card":{"child":"child-id"}}` |
| Column | Vertical stack | `{"Column":{"children":{"explicitList":["id1","id2"]}}}` |
| Row | Horizontal stack | `{"Row":{"children":{"explicitList":["id1","id2"]}}}` |
| Icon | Material icon | `{"Icon":{"name":{"literalString":"home\|favorite\|calendarToday"}}}` |
| Button | Clickable action | `{"Button":{"child":"text-id","action":{"name":"action_name"}}}` |

## Data Binding

In `dataModelUpdate.contents`:
- String: `{"key":"title","valueString":"서울 날씨"}`
- Number: `{"key":"temp","valueNumber":5.2}`

In components, reference with `{"path":"/key"}` instead of `{"literalString":"..."}`.

## Example: Weather Card

**Text response** (always include conversational text in your reply):
> 서울 강서구 지금 3°C, 체감 -1°C. 바람 부니까 따뜻하게!

**Canvas tool call**:
```json
{
  "action": "a2ui_push",
  "jsonl": "{\"beginRendering\":{\"surfaceId\":\"default\",\"root\":\"root\"}}\n{\"surfaceUpdate\":{\"surfaceId\":\"default\",\"components\":[{\"id\":\"root\",\"component\":{\"Card\":{\"child\":\"content\"}}},{\"id\":\"content\",\"component\":{\"Column\":{\"children\":{\"explicitList\":[\"title\",\"temp-row\",\"detail\"]}}}},{\"id\":\"title\",\"component\":{\"Text\":{\"text\":{\"path\":\"/title\"},\"usageHint\":\"h2\"}}},{\"id\":\"temp-row\",\"component\":{\"Row\":{\"children\":{\"explicitList\":[\"temp-text\",\"feels-text\"]}}}},{\"id\":\"temp-text\",\"component\":{\"Text\":{\"text\":{\"path\":\"/temp\"},\"usageHint\":\"h1\"}}},{\"id\":\"feels-text\",\"component\":{\"Text\":{\"text\":{\"path\":\"/feels\"},\"usageHint\":\"caption\"}}},{\"id\":\"detail\",\"component\":{\"Text\":{\"text\":{\"path\":\"/detail\"},\"usageHint\":\"body\"}}}]}}\n{\"dataModelUpdate\":{\"surfaceId\":\"default\",\"path\":\"/\",\"contents\":[{\"key\":\"title\",\"valueString\":\"🌤️ 서울 강서구 날씨\"},{\"key\":\"temp\",\"valueString\":\"3°C\"},{\"key\":\"feels\",\"valueString\":\"체감 -1°C\"},{\"key\":\"detail\",\"valueString\":\"맑음 | 바람 3m/s | 습도 45%\"}]}}"
}
```

## Example: Calendar List

```json
{
  "action": "a2ui_push",
  "jsonl": "{\"beginRendering\":{\"surfaceId\":\"default\",\"root\":\"root\"}}\n{\"surfaceUpdate\":{\"surfaceId\":\"default\",\"components\":[{\"id\":\"root\",\"component\":{\"Card\":{\"child\":\"col\"}}},{\"id\":\"col\",\"component\":{\"Column\":{\"children\":{\"explicitList\":[\"title\",\"e1\",\"e2\",\"e3\"]}}}},{\"id\":\"title\",\"component\":{\"Text\":{\"text\":{\"path\":\"/title\"},\"usageHint\":\"h2\"}}},{\"id\":\"e1\",\"component\":{\"Text\":{\"text\":{\"path\":\"/ev1\"},\"usageHint\":\"body\"}}},{\"id\":\"e2\",\"component\":{\"Text\":{\"text\":{\"path\":\"/ev2\"},\"usageHint\":\"body\"}}},{\"id\":\"e3\",\"component\":{\"Text\":{\"text\":{\"path\":\"/ev3\"},\"usageHint\":\"body\"}}}]}}\n{\"dataModelUpdate\":{\"surfaceId\":\"default\",\"path\":\"/\",\"contents\":[{\"key\":\"title\",\"valueString\":\"📅 오늘 일정\"},{\"key\":\"ev1\",\"valueString\":\"09:00 팀 스탠드업\"},{\"key\":\"ev2\",\"valueString\":\"12:00 점심\"},{\"key\":\"ev3\",\"valueString\":\"14:00 1:1 미팅\"}]}}"
}
```

## Example: Button Selection

```json
{
  "action": "a2ui_push",
  "jsonl": "{\"beginRendering\":{\"surfaceId\":\"default\",\"root\":\"root\"}}\n{\"surfaceUpdate\":{\"surfaceId\":\"default\",\"components\":[{\"id\":\"root\",\"component\":{\"Card\":{\"child\":\"col\"}}},{\"id\":\"col\",\"component\":{\"Column\":{\"children\":{\"explicitList\":[\"title\",\"btn1\",\"btn2\"]}}}},{\"id\":\"title\",\"component\":{\"Text\":{\"text\":{\"path\":\"/title\"},\"usageHint\":\"h2\"}}},{\"id\":\"btn1\",\"component\":{\"Button\":{\"child\":\"btn1-t\",\"primary\":true,\"action\":{\"name\":\"select\",\"context\":[{\"key\":\"choice\",\"value\":{\"path\":\"/o1\"}}]}}}},{\"id\":\"btn1-t\",\"component\":{\"Text\":{\"text\":{\"path\":\"/o1\"}}}},{\"id\":\"btn2\",\"component\":{\"Button\":{\"child\":\"btn2-t\",\"action\":{\"name\":\"select\",\"context\":[{\"key\":\"choice\",\"value\":{\"path\":\"/o2\"}}]}}}},{\"id\":\"btn2-t\",\"component\":{\"Text\":{\"text\":{\"path\":\"/o2\"}}}}]}}\n{\"dataModelUpdate\":{\"surfaceId\":\"default\",\"path\":\"/\",\"contents\":[{\"key\":\"title\",\"valueString\":\"🍽️ 뭐 먹을까?\"},{\"key\":\"o1\",\"valueString\":\"🍗 치킨\"},{\"key\":\"o2\",\"valueString\":\"🍕 피자\"}]}}"
}
```

## Rules

1. **Always reply with text too** — canvas is supplementary; users on Telegram only see text
2. Use `surfaceId: "default"` always
3. Every component needs a unique `id`
4. Use `path` references in components, actual values in `dataModelUpdate`
5. JSONL = one JSON object per line, separated by `\n` in the jsonl string
6. For simple chat (greetings, jokes) — do NOT call canvas, text only
