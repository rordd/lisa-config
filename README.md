# lisa-config

Lisa (ZeroClaw) 배포 설정 패키지.

## 설치

```bash
git clone https://github.com/rordd/lisa-config.git
cd lisa-config
./install.sh
```

### 소스 빌드에서 설치

```bash
git clone https://github.com/rordd/lisa.git
cd lisa && cargo build --release
cd ../lisa-config
./install.sh --source ../lisa
```

## install.sh 동작

1. `zeroclaw onboard` 실행 (config.toml, USER.md 등 기본 생성)
2. SOUL.md, IDENTITY.md, AGENTS.md → 리사 버전으로 덮어쓰기
3. skills/ 복사
4. `templates/USER.md.append` 파싱 → `{{변수}}` 입력받아 USER.md에 append
5. `templates/config.toml.append` → config.toml에 append

> 이미 적용된 항목은 건드리지 않습니다.

## 스킬/설정 추가 시

- 스킬 추가: `workspace/skills/`에 폴더 추가
- 새 개인정보 필요 시: `templates/USER.md.append`에 `{{변수}}` 추가
- 새 config 항목 필요 시: `templates/config.toml.append`에 추가
- **install.sh 수정 불필요** (템플릿에서 변수를 자동 감지)

## 구조

```
workspace/          관리자 설정 (SOUL, IDENTITY, AGENTS, skills)
templates/          onboard 이후 추가 항목 (변수 자동 파싱)
install.sh          설치 스크립트
```

## 실행

```bash
GEMINI_API_KEY="your-key" zeroclaw daemon
```
