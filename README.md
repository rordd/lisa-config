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
4. `templates/*.append` → 해당 config 파일에 자동 append

> Google 계정, 캘린더 ID 등 개인 설정은 리사가 기능 사용 시 직접 안내합니다.

## 스킬/설정 추가 시

- 스킬 추가: `workspace/skills/`에 폴더 추가 (install.sh 수정 불필요)
- config 항목 추가: `templates/config.toml.append`에 추가

## 구조

```
workspace/          관리자 설정 (SOUL, IDENTITY, AGENTS, skills)
templates/          onboard 이후 추가 config 항목
install.sh          설치 스크립트
```

## 실행

```bash
GEMINI_API_KEY="your-key" zeroclaw daemon
```
