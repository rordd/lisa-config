---
name: google-tasks
description: "Manage todos and reminders using Google Tasks via the gog CLI. Refer to USER.md for account and list ID."
---

# Google Tasks Skill

## Environment

- CLI: `gog` (v0.11.0+)
- Account and list ID: see `USER.md`
- Required env: `GOG_KEYRING_PASSWORD` (see USER.md)

## Commands

### List tasks
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog tasks list $TASKS_LIST_ID
```

### Create task
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog tasks create $TASKS_LIST_ID --title "Buy milk"
```

### Create task with due date
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog tasks create $TASKS_LIST_ID --title "Submit report" --due "2026-03-01"
```

### Complete task
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog tasks complete $TASKS_LIST_ID TASK_ID
```
