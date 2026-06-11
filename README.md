# Higgsfield Automation

Higgsfield AI로 영상을 자동 생성하는 워크플로우.

- **영상 모델:** Seedance 2.0 (`seedance_2_0`)
- **이미지 모델:** Nano Banana Pro (`nano_banana_2`, 히어로 이미지) · GPT Image 2 (`gpt_image_2`, 텍스트/디자인)

## 설치

```bash
# Claude Code 설치
curl -fsSL https://claude.ai/install.sh | bash

# Higgsfield CLI 설치 후 로그인
curl -fsSL https://raw.githubusercontent.com/higgsfield-ai/cli/main/install.sh | sh
higgsfield auth login

# Higgsfield Skill 추가
npx skills add higgsfield-ai/skills --agent claude-code -a opencode -g --copy -y
```

## 참고 파일

- `ref-ids.md` — 업로드한 모든 에셋 UUID
- `models/description.md` — 모델 정체성 및 의상 사양
- `environments/description.md` — 환경 설명
- `seedance-prompt-framework.md` — 프롬프트 구조, 모델 파라미터, 사운드 디자인 규칙
- `CLAUDE.md` — 에이전트 작업 지침

## 워크플로우

1. **모델 만들기** — `models/CLAUDE.md`를 따라 캐릭터 시트·클로즈업 생성, Higgsfield 업로드 후 `models/description.md` 작성
2. **환경 만들기** — `environments/CLAUDE.md`를 따라 환경 이미지 업로드·분석 후 `environments/description.md` 작성
3. **handoff 만들기** — `handoff.template.md`를 참고해 프로젝트 정보·레퍼런스 UUID·레퍼런스 스택을 채워 `handoff.md` 생성
4. **영상 생성** — `handoff.md`와 `seedance-prompt-framework.md`를 따라 Seedance로 영상 생성 (모든 잡에 캐릭터 시트 UUID를 `--image`로 전달)
5. **프롬프트 로깅** — 모든 이미지/영상 프롬프트를 `prompt-log.md`에 기록, Seedance 실패는 `seedance-failure-log.md`에 별도 기록
6. **피드백 트래커** — `feedback-tracker.xlsx`(Guide·Images·Videos 3개 시트)에 생성 결과를 기록하고, 생성 전 검토해 승인/거절 방향을 학습

## 주요 규칙

- 모델 레퍼런스는 캐릭터 시트 UUID 사용 — detail/editorial 이미지는 프레임에 번지므로 금지
- 사운드 디자인은 물리적이고 구체적으로, 음악 금지. 모든 프롬프트는 **No music.** 으로 종료
- 해상도: Nano Banana Pro는 항상 `2k`, Seedance는 기본 `720p`
- 모드: 최종 출력은 `std`, 미리보기/반복은 `fast`
