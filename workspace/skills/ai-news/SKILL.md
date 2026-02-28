---
name: ai-news
description: "Fetch and summarize the latest AI news from major tech publications."
---

# AI News Skill

## Sources (try in order, fall back if one fails)

1. **TechCrunch AI**: `web_fetch("https://techcrunch.com/category/artificial-intelligence/")`
2. **The Verge AI**: `web_fetch("https://www.theverge.com/ai-artificial-intelligence")`

## Output Format

- Summarize top 5 headlines in Korean
- Include source name and brief description per item
- Use emoji for visual clarity
- Keep each item to 2-3 sentences max
