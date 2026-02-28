---
name: gmail
description: "Read, search, and manage Gmail messages using the gog CLI. Refer to USER.md for account info."
---

# Gmail Skill

## Environment

- CLI: `gog` (v0.11.0+)
- Account: see `USER.md`
- Required env: `GOG_KEYRING_PASSWORD` (see USER.md)

## Commands

### List recent emails
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog gmail list --max 10
```

### Unread emails
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog gmail list --query "is:unread" --max 10
```

### Read specific email
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog gmail read MESSAGE_ID
```

### Search
```bash
GOG_KEYRING_PASSWORD=$GOG_KEYRING_PASSWORD gog gmail list --query "from:someone@example.com" --max 5
```
