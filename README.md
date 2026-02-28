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

### 업데이트

```bash
git pull
./install.sh --update
```

> `USER.md`와 `config.toml`은 이미 존재하면 덮어쓰지 않습니다.

## 구조

```
workspace/          관리자 설정 (SOUL, IDENTITY, skills)
templates/          최초 설치 시 사용되는 템플릿
install.sh          설치 스크립트
```

## 실행

```bash
GEMINI_API_KEY="your-key" zeroclaw daemon
```
