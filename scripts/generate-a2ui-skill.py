#!/usr/bin/env python3
"""Generate A2UI SKILL.md from Google A2UI official schema.

Usage:
    # Requires: pip install a2ui-agent (from google/A2UI repo)
    python3 scripts/generate-a2ui-skill.py

    # With custom components:
    python3 scripts/generate-a2ui-skill.py --components Text,Card,Column,Row,Icon,Button,Image,Divider

    # With examples:
    python3 scripts/generate-a2ui-skill.py --examples /path/to/examples/

Output: workspace/skills/a2ui/SKILL.md
"""

import argparse
import os
import sys

try:
    from a2ui.inference.schema.manager import A2uiSchemaManager
except ImportError:
    print("Error: a2ui-agent not installed.")
    print("Install from Google A2UI repo:")
    print("  cd /path/to/A2UI && pip install -e a2a_agents/python/a2ui_agent/")
    sys.exit(1)

DEFAULT_COMPONENTS = [
    "Text", "Card", "Column", "Row", "Icon",
    "Button", "Image", "Divider",
]

SKILL_HEADER = """---
name: a2ui
description: "Render rich UI cards on the web dashboard using the `canvas` tool. Use for weather, calendar, tasks, news, lists, settings — any response that benefits from visual layout."
always: true
---

# A2UI Skill — Canvas Tool

When a response benefits from **visual UI** (weather, calendar, tasks, lists, news, settings),
use the `canvas` tool to render A2UI cards on the connected web dashboard.

## How to Use

### Push UI Cards
Call the `canvas` tool with:
- `action`: `"a2ui_push"`
- `jsonl`: A2UI JSONL string (one JSON object per line, `\\n` separated)

### Clear UI
Call the `canvas` tool with:
- `action`: `"a2ui_reset"`

## Rules
1. **Always reply with text too** — canvas is supplementary; Telegram users only see text
2. Use `surfaceId: "default"` always
3. Every component needs a unique `id`
4. Use `path` references in components, actual values in `dataModelUpdate`
5. JSONL = one JSON object per line, separated by `\\n` in the jsonl string
6. For simple chat (greetings, jokes) — do NOT call canvas, text only

## Example: Weather Card (canvas tool call)
```json
{
  "action": "a2ui_push",
  "jsonl": "{\\"beginRendering\\":{\\"surfaceId\\":\\"default\\",\\"root\\":\\"root\\"}}\\n{\\"surfaceUpdate\\":{\\"surfaceId\\":\\"default\\",\\"components\\":[{\\"id\\":\\"root\\",\\"component\\":{\\"Card\\":{\\"child\\":\\"content\\"}}},{\\"id\\":\\"content\\",\\"component\\":{\\"Column\\":{\\"children\\":{\\"explicitList\\":[\\"title\\",\\"temp\\",\\"detail\\"]}}}},{\\"id\\":\\"title\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/title\\"},\\"usageHint\\":\\"h2\\"}}},{\\"id\\":\\"temp\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/temp\\"},\\"usageHint\\":\\"h1\\"}}},{\\"id\\":\\"detail\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/detail\\"},\\"usageHint\\":\\"body\\"}}}]}}\\n{\\"dataModelUpdate\\":{\\"surfaceId\\":\\"default\\",\\"path\\":\\"/\\",\\"contents\\":[{\\"key\\":\\"title\\",\\"valueString\\":\\"🌤️ Seoul Weather\\"},{\\"key\\":\\"temp\\",\\"valueString\\":\\"12°C\\"},{\\"key\\":\\"detail\\",\\"valueString\\":\\"Clear | Wind 3m/s | Humidity 45%\\"}]}}"
}
```

"""

SKILL_FOOTER = """
## Additional Examples

### Calendar List
```json
{
  "action": "a2ui_push",
  "jsonl": "{\\"beginRendering\\":{\\"surfaceId\\":\\"default\\",\\"root\\":\\"root\\"}}\\n{\\"surfaceUpdate\\":{\\"surfaceId\\":\\"default\\",\\"components\\":[{\\"id\\":\\"root\\",\\"component\\":{\\"Card\\":{\\"child\\":\\"col\\"}}},{\\"id\\":\\"col\\",\\"component\\":{\\"Column\\":{\\"children\\":{\\"explicitList\\":[\\"title\\",\\"e1\\",\\"e2\\"]}}}},{\\"id\\":\\"title\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/title\\"},\\"usageHint\\":\\"h2\\"}}},{\\"id\\":\\"e1\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/ev1\\"},\\"usageHint\\":\\"body\\"}}},{\\"id\\":\\"e2\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/ev2\\"},\\"usageHint\\":\\"body\\"}}}]}}\\n{\\"dataModelUpdate\\":{\\"surfaceId\\":\\"default\\",\\"path\\":\\"/\\",\\"contents\\":[{\\"key\\":\\"title\\",\\"valueString\\":\\"📅 Today's Schedule\\"},{\\"key\\":\\"ev1\\",\\"valueString\\":\\"09:00 Team Standup\\"},{\\"key\\":\\"ev2\\",\\"valueString\\":\\"14:00 1:1 Meeting\\"}]}}"
}
```

### Button Selection
```json
{
  "action": "a2ui_push",
  "jsonl": "{\\"beginRendering\\":{\\"surfaceId\\":\\"default\\",\\"root\\":\\"root\\"}}\\n{\\"surfaceUpdate\\":{\\"surfaceId\\":\\"default\\",\\"components\\":[{\\"id\\":\\"root\\",\\"component\\":{\\"Card\\":{\\"child\\":\\"col\\"}}},{\\"id\\":\\"col\\",\\"component\\":{\\"Column\\":{\\"children\\":{\\"explicitList\\":[\\"title\\",\\"btn1\\",\\"btn2\\"]}}}},{\\"id\\":\\"title\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/title\\"},\\"usageHint\\":\\"h2\\"}}},{\\"id\\":\\"btn1\\",\\"component\\":{\\"Button\\":{\\"child\\":\\"btn1-t\\",\\"primary\\":true,\\"action\\":{\\"name\\":\\"select\\",\\"context\\":[{\\"key\\":\\"choice\\",\\"value\\":{\\"path\\":\\"/o1\\"}}]}}}},{\\"id\\":\\"btn1-t\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/o1\\"}}}},{\\"id\\":\\"btn2\\",\\"component\\":{\\"Button\\":{\\"child\\":\\"btn2-t\\",\\"action\\":{\\"name\\":\\"select\\",\\"context\\":[{\\"key\\":\\"choice\\",\\"value\\":{\\"path\\":\\"/o2\\"}}]}}}},{\\"id\\":\\"btn2-t\\",\\"component\\":{\\"Text\\":{\\"text\\":{\\"path\\":\\"/o2\\"}}}}]}}\\n{\\"dataModelUpdate\\":{\\"surfaceId\\":\\"default\\",\\"path\\":\\"/\\",\\"contents\\":[{\\"key\\":\\"title\\",\\"valueString\\":\\"🍽️ What to eat?\\"},{\\"key\\":\\"o1\\",\\"valueString\\":\\"🍗 Chicken\\"},{\\"key\\":\\"o2\\",\\"valueString\\":\\"🍕 Pizza\\"}]}}"
}
```
"""


def main():
    parser = argparse.ArgumentParser(description="Generate A2UI SKILL.md from official schema")
    parser.add_argument("--version", default="0.8", help="A2UI spec version (default: 0.8)")
    parser.add_argument("--components", default=",".join(DEFAULT_COMPONENTS),
                        help="Comma-separated list of allowed components")
    parser.add_argument("--examples", default=None, help="Path to examples directory")
    parser.add_argument("--output", default=None, help="Output path (default: workspace/skills/a2ui/SKILL.md)")
    args = parser.parse_args()

    components = [c.strip() for c in args.components.split(",") if c.strip()]

    # Determine output path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    output_path = args.output or os.path.join(repo_root, "workspace", "skills", "a2ui", "SKILL.md")

    print(f"A2UI version: {args.version}")
    print(f"Components: {components}")
    print(f"Output: {output_path}")

    # Generate schema prompt
    mgr = A2uiSchemaManager(
        version=args.version,
        basic_examples_path=args.examples,
    )

    schema_prompt = mgr.generate_system_prompt(
        role_description="",
        include_schema=True,
        include_examples=bool(args.examples),
        allowed_components=components,
    )

    # Strip the empty role description line
    schema_prompt = schema_prompt.strip()

    # Assemble SKILL.md
    skill_content = SKILL_HEADER
    skill_content += "## A2UI JSON Schema (Official)\n\n"
    skill_content += "The following is the official A2UI component schema. "
    skill_content += "Use these component types in `surfaceUpdate.components`.\n\n"
    skill_content += schema_prompt + "\n"
    skill_content += SKILL_FOOTER

    # Write
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        f.write(skill_content)

    print(f"\n✅ Generated {output_path}")
    print(f"   Total size: {len(skill_content):,} chars")


if __name__ == "__main__":
    main()
