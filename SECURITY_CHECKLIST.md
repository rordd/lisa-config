# Security Checklist — Production Hardening

제품화 배포 전 반드시 확인할 보안 항목들.
개발/테스트 중에는 느슨하게 두되, 배포 직전에 이 리스트를 하나씩 점검할 것.

---

## 1. web_fetch — allowed_domains

**파일:** `config.toml` → `[web_fetch]`

| 환경 | 설정 |
|---|---|
| 개발/테스트 | `allowed_domains = ["*"]` |
| 프로덕션 | 필요한 도메인만 화이트리스트 |

```toml
# ❌ 테스트용 (전체 허용)
[web_fetch]
allowed_domains = ["*"]

# ✅ 프로덕션 예시 (필요한 것만)
[web_fetch]
allowed_domains = [
    "api.open-meteo.com",    # weather skill
    "wttr.in",               # weather skill
]
blocked_domains = []
```

**위험:** `["*"]`이면 LLM이 임의 외부 서버에 접근 가능 → 데이터 유출 가능성.

---

## 2. web_search — provider & 결과 수

**파일:** `config.toml` → `[web_search]`

```toml
# 테스트
[web_search]
enabled = true
max_results = 5

# 프로덕션 — 필요 없으면 비활성화
[web_search]
enabled = false
```

**위험:** LLM이 웹 검색으로 외부 정보 수집 → 프롬프트 인젝션 벡터.

---

## 3. autonomy — block_high_risk_commands

**파일:** `config.toml` → `[autonomy]`

```toml
# ✅ 반드시 true 유지
block_high_risk_commands = true
require_approval_for_medium_risk = true
```

**위험:** `false`로 바꾸면 `rm`, `sudo`, `ssh` 등 전부 실행 가능.

---

## 4. autonomy — allowed_commands

**파일:** `config.toml` → `[autonomy]`

```toml
# ❌ 테스트용 (넓게)
allowed_commands = ["git", "npm", "cargo", "ls", "cat", "grep", "find", "echo", "pwd", "wc", "head", "tail", "date", "gog", "curl", "jq", "python3", "bash"]

# ✅ 프로덕션 (최소 권한)
allowed_commands = ["ls", "cat", "echo", "date", "gog"]
```

**위험:** `bash`, `python3` 허용 시 사실상 모든 명령 실행 가능.

---

## 5. gateway — require_pairing

**파일:** `config.toml` → `[gateway]`

```toml
# ❌ 테스트용
require_pairing = false

# ✅ 프로덕션
require_pairing = true
```

**위험:** `false`면 누구나 gateway API에 접근 가능.

---

## 6. channels — allowed_users

**파일:** `config.toml` → `[channels_config.telegram]`

```toml
# ✅ 반드시 허용된 사용자만
allowed_users = ["8394492274"]
```

**위험:** 비어있으면 모든 사용자 거부 (deny-by-default). 실수로 `["*"]` 같은 건 없는지 확인.

---

## 7. security — OTP & E-Stop

**파일:** `config.toml` → `[security.otp]`, `[security.estop]`

```toml
# 프로덕션 권장
[security.otp]
enabled = true

[security.estop]
enabled = true
```

**위험:** 비활성화 시 긴급 정지 및 민감 작업 2차 인증 불가.

---

## 8. memory — auto_save & retention

**파일:** `config.toml` → `[memory]`

```toml
# 프로덕션 — 보존 기간 최소화
conversation_retention_days = 7
archive_after_days = 3
purge_after_days = 14
```

**위험:** 대화 기록에 개인정보 포함 가능. 장기 보관 시 유출 위험 증가.

---

## 점검 방법

배포 전 터미널에서:

```bash
grep -E "allowed_domains|block_high_risk|require_pairing|allowed_users|enabled" ~/.zeroclaw/config.toml
```

한눈에 주요 설정값 확인 가능.
