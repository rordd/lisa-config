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
2. SOUL.md, IDENTITY.md, AGENTS.md 리사 버전으로 덮어쓰기
3. skills/ 복사
4. USER.md에 Google 계정/위치 등 추가 항목 append
5. config.toml에 a2ui, web_fetch 등 추가 설정 append

> 이미 설정된 항목은 건드리지 않습니다.

## 업데이트

```bash
git pull
./install.sh
```

## 구조

```
workspace/          관리자 설정 (SOUL, IDENTITY, AGENTS, skills)
install.sh          설치 스크립트
```

## 실행

```bash
GEMINI_API_KEY="your-key" zeroclaw daemon
```
