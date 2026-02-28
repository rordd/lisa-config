---
name: calendar
description: "Query and create Google Calendar events using the gog CLI. Supports multiple calendars. Refer to USER.md for account and calendar IDs."
---

# Calendar Skill

## Environment

- CLI: `gog` (v0.11.0+)
- Account and calendar IDs: see `USER.md`
- Required env: `GOG_KEYRING_PASSWORD` (see USER.md)

## Commands

### List today's events
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog calendar list --from today --to tomorrow
```

### List specific calendar
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog calendar list --from today --to tomorrow --calendar-id "CALENDAR_ID"
```

### Create event
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog calendar create --title "Meeting" --start "2026-03-01T10:00:00" --end "2026-03-01T11:00:00"
```

## Briefing

For daily briefings, check all calendars listed in USER.md and group by category.
