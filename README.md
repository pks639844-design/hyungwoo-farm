# 형우농원 자료 저장소

강원도 인제 형우농원의 마케팅 자료와 Threads 글을 한곳에 모아 GitHub로 백업·관리합니다.

## 폴더 구성

| 경로 | 설명 |
|------|------|
| `카드뉴스.html` / `카드뉴스.png` | 인스타그램 카드뉴스 (1080×1080) |
| `*.jpg`, `*.png` | 원본 사진 |
| `형우농원 웹사이트.txt` | 웹사이트 HTML 초안 |
| `posts/` | Threads 글 초안 모음 |
| `skills/hyungwoo-threads/` | Claude Code 스킬 백업 (자동 동기화) |
| `upload.bat` | **더블클릭하면 GitHub에 업로드** |
| `upload.ps1` | 실제 동작 스크립트 |

## 첫 1회 설정

### 1) git 사용자 정보 (한 번만)

PowerShell을 열고 아래 두 줄을 본인 정보로 실행.

```powershell
git config --global user.name  "본인 이름"
git config --global user.email "you@example.com"
```

### 2) GitHub에 빈 저장소 만들기

1. https://github.com/new 접속
2. **Repository name** 입력 — 예: `hyungwoo-farm`
3. **Private** 선택 (외부 공개를 원하면 Public)
4. **README / .gitignore / license 체크는 모두 해제** (반드시 비어 있어야 함)
5. **Create repository**
6. 생성된 페이지에서 HTTPS URL 복사 — 예: `https://github.com/your-id/hyungwoo-farm.git`

### 3) `upload.bat` 더블클릭

스크립트가 자동으로 진행합니다.
- git 저장소 초기화
- 위에서 복사한 URL을 한 번 물어봄 → 붙여넣기
- 첫 푸시 시 GitHub 로그인 창이 한 번 뜸
  - **Username**: GitHub 아이디
  - **Password 자리**: GitHub 비밀번호가 아니라 **Personal Access Token**
  - 토큰 발급: GitHub → Settings → Developer settings → Personal access tokens (classic) → Generate new token → `repo` 권한 체크
  - 한 번 입력하면 Windows Credential Manager가 기억해서 다음부터 자동

## 이후 사용 (일상)

파일을 추가하거나 수정한 뒤 **`upload.bat` 더블클릭**.

스크립트가 자동으로:
1. `~/.claude/skills/hyungwoo-threads/` → `skills/hyungwoo-threads/` 동기화
2. 모든 변경사항 스테이징·커밋 (메시지 예: `Update: 2026-05-16 14:30`)
3. GitHub에 푸시

변경된 파일이 없으면 푸시를 건너뜁니다.

## 자주 묻는 질문

**Q. OneDrive 폴더에서 git을 써도 되나요?**
대체로 괜찮지만, 드물게 `.git/` 내부 파일이 OneDrive 충돌로 막힐 수 있습니다.
- 증상: `error: cannot lock ref` 같은 메시지
- 해결: 작업 폴더에서 우클릭 → **항상 이 장치에 유지** 체크

**Q. 푸시할 때 다른 컴퓨터에서 작업하고 싶어요.**
다른 PC에서 임의 폴더에 들어가 `git clone https://github.com/your-id/hyungwoo-farm.git` 한 번 실행.
이후 그 폴더에서도 `upload.bat`로 같은 방식 사용 가능.

**Q. 스킬 폴더를 GitHub에 안 올리고 싶어요.**
`.gitignore` 파일에 `skills/` 한 줄 추가.

**Q. 커밋 메시지를 자세히 쓰고 싶어요.**
스크립트의 자동 커밋 메시지는 시간 기반입니다.
의미 있는 메시지로 남기려면 `upload.bat` 대신 직접:
```powershell
git add -A
git commit -m "두릅 글 3편 추가"
git push
```
