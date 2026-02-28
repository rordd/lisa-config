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

## lisa-onboard.sh 동작

1. `zeroclaw onboard` (config.toml, USER.md 등 기본 생성)
2. SOUL.md, IDENTITY.md, AGENTS.md → 리사 버전으로 덮어쓰기
3. skills/ 복사
4. config.toml에 추가 설정 append (a2ui, web_fetch 등)
5. 위치, Google 계정, 캘린더, Tasks → USER.md에 append

## 구조

```
workspace/          관리자 설정 (SOUL, IDENTITY, AGENTS, skills)
templates/          onboard 이후 추가 config 항목
lisa-onboard.sh     설치 + 개인 설정
```

## 실행

```bash
GEMINI_API_KEY="your-key" zeroclaw daemon
```
