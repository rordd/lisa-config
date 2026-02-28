# lisa-config

Lisa (ZeroClaw) 배포 설정 패키지.

## 설치

```bash
git clone https://github.com/rordd/lisa-config.git
cd lisa-config
./lisa-onboard.sh
```

### 소스 빌드에서 설치

```bash
git clone https://github.com/rordd/lisa.git
cd lisa && cargo build --release
cd ../lisa-config
./lisa-onboard.sh --source ../lisa
```

### 테스트 (기존 환경 안 건드림)

```bash
ZEROCLAW_DIR=/tmp/lisa-test ./lisa-onboard.sh
```

## lisa-onboard.sh 동작

1. `zeroclaw onboard` (기본 설정)
2. SOUL.md, IDENTITY.md, AGENTS.md → 리사 버전으로 덮어쓰기
3. 스킬 선택 UI → 선택한 스킬만 설치
4. 스킬별 `onboard.conf` 파싱:
   - `[requires]` → CLI 의존성 설치 (OS별 분기)
   - `[user]` → 개인 설정 → USER.md에 append
   - `[config]` → config.toml에 append

## 스킬 추가 시

```
workspace/skills/새스킬/
├── SKILL.md         ← OpenClaw 기반 (원본 유지)
└── onboard.conf     ← [requires] [user] [config]
```

lisa-onboard.sh 수정 불필요.

## 실행

```bash
GEMINI_API_KEY="your-key" zeroclaw daemon
```
