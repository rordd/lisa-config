---
name: calendar
description: "Manage Google Calendar events using the gog CLI. List, create, update events. Refer to USER.md for account and calendar IDs."
---

# Calendar Skill

## Environment

- CLI: `gog` (v0.11.0+)
- Account and calendar IDs: see `USER.md`
- If not in USER.md, ask the user for their Google account and calendar IDs
- Set env: `GOG_KEYRING_PASSWORD` (ask user if unknown)

## Setup (first time)

If `gog auth list` shows no accounts:
```bash
gog auth credentials /path/to/client_secret.json
gog auth add USER_EMAIL --services gmail,calendar,drive,contacts,docs,sheets
```

## Commands

### List events
```bash
GOG_KEYRING_PASSWORD=$PASSWORD gog calendar events CALENDAR_ID --from 2026-03-01T00:00:00 --to 2026-03-02T00:00:00
```

### List today's events
```bash
GOG_KEYRING_PASSWORD=$PASSWORD gog calendar events CALENDAR_ID --from $(date +%Y-%m-%dT00:00:00) --to $(date -v+1d +%Y-%m-%dT00:00:00)
```

### Create event
```bash
GOG_KEYRING_PASSWORD=$PASSWORD gog calendar create CALENDAR_ID --summary "Meeting" --from 2026-03-01T10:00:00 --to 2026-03-01T11:00:00
```

### Create event with color
```bash
GOG_KEYRING_PASSWORD=$PASSWORD gog calendar create CALENDAR_ID --summary "Important" --from ISO --to ISO --event-color 4
```

### Update event
```bash
GOG_KEYRING_PASSWORD=$PASSWORD gog calendar update CALENDAR_ID EVENT_ID --summary "New Title" --event-color 7
```

### Show available colors
```bash
gog calendar colors
```

## Event Colors

| ID | Color |
|----|-------|
| 1 | #a4bdfc (Lavender) |
| 2 | #7ae7bf (Sage) |
| 3 | #dbadff (Grape) |
| 4 | #ff887c (Flamingo) |
| 5 | #fbd75b (Banana) |
| 6 | #ffb878 (Tangerine) |
| 7 | #46d6db (Peacock) |
| 8 | #e1e1e1 (Graphite) |
| 9 | #5484ed (Blueberry) |
| 10 | #51b749 (Basil) |
| 11 | #dc2127 (Tomato) |

## Briefing

For daily briefings, check all calendars listed in USER.md.
Group events by calendar and sort by time.

## Notes

- Set `GOG_ACCOUNT=email` env to avoid repeating `--account`
- Use `--json` for scripting/parsing
- Confirm before creating or modifying events
- Respond in Korean
