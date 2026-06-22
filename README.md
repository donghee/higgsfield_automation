# Higgsfield Automation

Higgsfield AI로 영상을 자동 생성하는 워크플로우.

- **영상 모델:** Seedance 2.0 (`seedance_2_0`)
- **이미지 모델:** Nano Banana Pro (`nano_banana_2`, 대부분 이미지) · GPT Image 2 (`gpt_image_2`, 텍스트/디자인)
- **디렉터 모델:** Claude opus 4.8 또는 Deepseek v4 pro; 영상 모델과 이미지 모델에게 명령어 내림
- **AI 서비스:** higgsfield.ai, claude.ai, openrouter.ai (옵션)

## 주요 파일

- `ref-ids.md` — 업로드한 모든 에셋 UUID
- `models/description.md` — 모델 정체성 및 의상 사양
- `environments/description.md` — 환경 설명
- `handoff.md` — 핸드오프: 프로젝트의 맥락과 작업을 영상, 이미지 모델에게 전달하는 문서 (콘셉트·캐릭터 설명·레퍼런스 UUID·씬 브리프); 모든 생성 작업의 출발점
- `storyboard/storyboard-*-sheet-*.png` — 9프레임 3×3 스토리보드 시트, 없어도 됨. `handoff.md` 만으로도 영상 생성 가능
- `seedance-prompt-framework.md` — 프롬프트 구조, 모델 파라미터, 사운드 디자인 규칙
- `feedback-tracker.xlsx` - 생성 결과  피드백 파일
- `CLAUDE.md` — 에이전트 작업 지침

## 워크플로우

1. **모델 만들기** — `models/CLAUDE.md`를 따라 캐릭터 시트·클로즈업 생성, Higgsfield 업로드 후 `models/description.md` 작성
2. **환경 만들기** — `environments/CLAUDE.md`를 따라 환경 이미지 업로드·분석 후 `environments/description.md` 작성
3. **핸드오프 만들기** — `handoff.template.md`를 참고해 프로젝트 정보·레퍼런스 UUID·레퍼런스 스택을 채워 `handoff.md` 생성
4. **스토리보드 시트 만들기** — `storyboard/CLAUDE.md`를 따라 9프레임(3×3) 스토리보드 시트(`storyboard-*-sheet.png`)를 생성·Higgsfield 업로드, 생성 내역을 `storyboard/storyboard-log.md`에 누적 기록하고 승인된 시트 UUID를 `ref-ids.md`에 기록
5. **영상 생성** — 승인된 handoff와 스토리보드 시트를 기준으로 Seedance 영상 생성. 모든 잡에 **스토리보드 시트 UUID**(구도·연속성)와 **캐릭터 시트 UUID**(정체성)를 `--image`로 전달하고, 특정 프레임 샷은 해당 스틸을 시작 프레임으로 추가. 결과물은 `outputs/`에 저장
6. **프롬프트 로깅** — 모든 이미지/영상 프롬프트를 `prompt-log.md`에 기록, Seedance 실패는 `seedance-failure-log.md`에 별도 기록
7. **피드백 트래커** — `feedback-tracker.xlsx`(Guide·Images·Videos 3개 시트)에 생성 결과를 기록하고, 생성 전 검토해 승인/거절 방향을 학습

---

## Getting Started 튜토리얼

claude code를 이용해서 Higgsfield 자동화를 따라해보는 핸즈온 입니다. 
설치부터 영상 생성까지 실제 예제를 따라하면서 워크 플로우를 경험할 수 있습니다.

---

### 1단계 — 설치

**Claude Code** (AI 에이전트 CLI)와 **Higgsfield CLI** (영상·이미지 생성 API 클라이언트)를 설치.

```bash
# 1. Claude Code 설치
curl -fsSL https://claude.ai/install.sh | bash

# 2. Higgsfield CLI 설치 후 로그인 (계정 필요)
## https://github.com/higgsfield-ai/cli
curl -fsSL https://raw.githubusercontent.com/higgsfield-ai/cli/main/install.sh | sh
higgsfield auth login

# 3. 최신 NodeJS 설치 -- https://nodejs.org/ko/download/current 참고
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install node
nvm use node

# 4. Higgsfield 스킬 추가 — Claude Code가 Higgsfield API를 직접 호출할 수 있게 됨
## https://higgsfield.ai/skills
npx skills add higgsfield-ai/skills --agent claude-code -a opencode -g --copy -y
npx skills add OpenRouterTeam/skills openrouter-video -a claude-code -a opencode -g --copy -y
```

설치가 끝나면 프로젝트 디렉터리에서 `claude` 명령어로 대화하면서 모든 생성 작업을 진행할 수 있습니다.

### 2단계 — 서비스 가입 및 API 키 발급

아래 세 가지 서비스에 각각 가입하고 API 키를 발급받습니다.

| 서비스 | 가입 주소 | 필요한 것 | 비고 |
|--------|-----------|-----------|------|
| **Higgsfield** | [higgsfield.ai](https://higgsfield.ai) | 구독  | seedance 2.0 사용을 위해서는 PLUS 이상 필요. |
| **Claude** | [claude.ai](https://claude.ai) | 구독 또는 API 키 | Claude Code 사용 시 Pro 구독 권장 |
| **OpenRouter** | [openrouter.ai](https://openrouter.ai) | API 키 | 대시보드 → Keys에서 발급 (옵션) |

발급받은 키는 각 서비스의 인증 절차에 따라 설정합니다.
- **Higgsfield:** `higgsfield auth login` 실행 시 브라우저 로그인
- **Claude Code:** 최초 실행 시 자동으로 로그인 절차 안내
- **OpenRouter:** `OPENROUTER_API_KEY` 환경 변수로 설정

---

### 3단계 — 개념 이해

워크플로우를 따라하기 전에 알면 좋은 개념.

#### higgsfield cli

higgsfield API를 명령어로 실행할 수 있도록 만든 도구

모델의 입력 도움말 
```
higgsfield model get nano_banana_2
higgsfield model get seedance_2_0
```

영상 생성 예시
```
higgsfield generate create seeddance_2_0 --prompt "cinematic product photo" --image <UUID>
```

#### UUID

Higgsfield에 이미지나 영상을 업로드하면 **UUID**(고유 식별자)가 발급됩니다.

```
522d8454-047b-4acc-8002-d93eb7407a12   ← 이 형식
```

이 UUID가 모든 생성 명령의 레퍼런스로 쓰입니다. 업로드한 모든 에셋의 UUID는 `ref-ids.md`에 기록합니다. UUID를 잃어버리면 동일 레퍼런스를 다시 쓸 수 없으므로 반드시 기록해 두어야 합니다.

#### 스킬 (Skill)

Claude Code에 추가된 **도구 모음**입니다. `higgsfield-generate` 스킬이 설치되면 Claude에게 말로 지시하는 것만으로 이미지 생성·업로드·UUID 조회가 가능해집니다.

```
"두둥이 캐릭터 시트 생성해줘" → Claude가 스킬을 호출 → Nano Banana Pro API 실행 → 결과 이미지 저장 + UUID 기록
```

#### 사용하는 모델

| 용도 | 모델 ID | 특징 |
|------|---------|------|
| 캐릭터·환경 이미지 (최종) | `nano_banana_2` (Nano Banana Pro) | 2k, 영화 느낌, 텍스처 풍부 |
| 이미지 빠른 반복 | `nano_banana_flash` (Nano Banana 2) | 저렴·빠름, 구도 탐색용 |
| 텍스트·디자인 이미지 | `gpt_image_2` (GPT Image 2) | 문자 렌더링에 강함 |
| 영상 생성 | `seedance_2_0` (Seedance 2.0) | 시작/끝 프레임 제어, 장르 지원 |


#### Seedance 2.0 주요 입력

Seedance 2.0 영상 생성에 쓰이는 주요 플래그입니다.

| 플래그 | 역할 |
|--------|------|
| `--start-image <uuid>` | 영상의 **첫 프레임**을 고정 |
| `--end-image <uuid>` | 영상의 **마지막 프레임**을 고정 |
| `--image <uuid>` | 캐릭터·환경 레퍼런스 (0–9개) |
| `--video <uuid>` | 동작·스타일 레퍼런스 영상 (0–3개) |

컷과 컷을 이어 붙일 때는 **앞 컷의 `--end-image`와 뒤 컷의 `--start-image`에 같은 프레임을 공유**하면 장면 전환이 자연스럽게 이어집니다.

#### 캐릭터 시트 (Character Sheet)

캐릭터의 **일관성 유지** 를 위한 이미지입니다. 여러 각도와 표정을 담은 레퍼런스 시트로, 모든 Seedance 잡에 `--image <char-sheet-uuid>`로 반드시 포함해야 합니다. 이것을 빠뜨리면 컷마다 캐릭터의 얼굴·체형·색상이 달라집니다.

> 클로즈업이나 편집용 사진(detail/editorial)은 레퍼런스로 쓰지 않습니다. Seedance가 그것을 프레임 그대로 복사해버림!

#### 핸드오프 (handoff.md)

이미지,영상 모델 에이전트에 전달하는 **핸드오프**입니다. 영상의 콘셉트·캐릭터 설명·레퍼런스 UUID·씬 요약이 한 파일에 담겨 있으며, Claude가 모든 생성 작업을 시작할 때 이 파일을 가장 먼저 읽습니다.

```
handoff.md 구조
├── Project Overview  — 콘셉트 및 포맷
├── Models            — 각 캐릭터 외형·성격·역할 설명
├── Reference UUIDs   — 업로드된 에셋 UUID 표
├── Ref Stacks        — 각 컷에 쓸 --image 플래그 복붙용 블록
└── Scene Briefs      — 컷별 카메라 움직임·감정 흐름 요약
```

#### 스토리보드 (Storyboard)

영상을 만들기 전에 생성하는 **9프레임 3×3 그리드 이미지**입니다. 컷의 구도·조명·감정 흐름을 한눈에 확인하고, Seedance 영상 생성 때 구도 앵커(`--image <storyboard-sheet-uuid>`)로 반드시 사용합니다.

```
[1 장면 설정]  [2 인물 등장]  [3 행동 시작]
[4 위기/전환]  [5 핵심 장면]  [6 대조/반응]
[7 회복]       [8 클라이맥스] [9 해소/마무리]
```

탐색 단계는 `nano_banana_flash`(저렴), 승인 후 최종본은 `nano_banana_2`(Pro)로 다시 랜더링 합니다.

---

### 4단계 — 알아두어야 할 문제점

#### 일관성 문제 (Consistency)

컷마다 같은 캐릭터라도 털 색상, 체형, 얼굴이 미묘하게 달라질 수 있습니다.

**이 파이프라인의 해법:**

1. **캐릭터 시트 UUID**를 seedance 모델에 요청시 `--image`로 전달 — 캐릭터 일관성 유지
2. **스토리보드 시트 UUID**를 seedance 모델에 요청시 `--image`로 전달 — 구도·조명·연속성 일관성 유지
3. **경계 키프레임 공유** — 앞 컷의 `--end-image`와 뒤 컷의 `--start-image`를 동일 이미지로 고정

```
CUT N:    --start-image A  --end-image B
CUT N+1:  --start-image B  --end-image C   ← B를 공유
```

#### 토큰 비용 (Token Cost)

영상 생성은 비용이 많이 든다. 일관성 문제 때문에 영상 생성을 더 여러번 하게 됨

| 작업 | 비용 수준 | 절약 팁 |
|------|-----------|---------|
| Nano Banana Flash (탐색) | 저렴 | 구도 확인은 항상 Flash로 |
| Nano Banana Pro (최종) | 중간 | 승인된 시트만 Pro 재렌더 |
| Seedance `fast` (미리보기) | 중간 | 방향 확인은 fast 모드 |
| Seedance `std` (최종 720p) | 높음 | 확정된 컷에만 사용 |
| Seedance `std` (1080p) | 매우 높음 | fast 모드로 만들고 최종 생성에 사용 |

**절약 팁:** handoff 문서와 스토리 보드에 생성할 영상 내용을 미리 계획. 요청 프롬프트와 그 결과물을 기록으로 남겨서, 다음 영상 생성시 기록보고 개선하도록 함.

---

### 5단계 — 핸즈온: 두둥·둥실 동네 산책

실제 프로젝트 파일을 참고해서 처음부터 끝까지 따라합니다.  
예제: **"동네 한 바퀴 (Neighborhood Rovers)"** — 두둥(회색 고양이)과 둥실(노란색 고양이)이 동네를 모험하는 2D 애니메이션 단편.

> **참고 파일 :**
> - [두둥 캐릭터 시트](docs/model-1-char-sheet-for-animation.png)
> - [둥실 캐릭터 시트](docs/model-4-char-sheet-for-animation.png)
> - [스토리보드 시트](docs/storyboard-nr-rovers-sheet.png)
> - [최종 합성 영상](docs/nr-or-composite.mp4)

#### 1. 디렉터리 구조

```
higgsfield_automation/
│
├── models/                          # 캐릭터 관련 파일
│   ├── CLAUDE.md                    # 캐릭터 생성 에이전트 지침
│   ├── descriptions.template.md     # descriptions.md 작성 양식
│   ├── descriptions.md              # 캐릭터별 외형·레퍼런스 UUID 기록
│   ├── model-1-char-sheet.png       # 캐릭터 시트 (정체성 앵커)
│   ├── model-1-detail-*.png         # 캐릭터 클로즈업 (레퍼런스 금지)
│   └── ...                          # 기타 캐릭터 사진·영상
│
├── environments/                    # 배경 환경 관련 파일
│   ├── CLAUDE.md                    # 환경 생성 에이전트 지침
│   ├── descriptions.template.md     # descriptions.md 작성 양식
│   ├── descriptions.md              # 환경별 조명·분위기·UUID 기록
│   └── *.jpg                        # 기타 환경 사진
│
├── storyboard/                      # 스토리보드 관련 파일
│   ├── CLAUDE.md                    # 스토리보드 생성 에이전트 지침
│   ├── storyboard-log.md            # 누적 스토리보드 기록 (덮어쓰기 금지)
│   ├── storyboard-*-sheet.png       # 생성된 스토리 보드 
│   └── keyframes/                   # 확정된 시작·끝 프레임 스틸
│
├── outputs/                         # 생성된 영상 저장소
│   └── *.mp4                        # 생성된 영상
│
├── CLAUDE.md                        # 전체 워크플로우 에이전트 지침
├── handoff.template.md              # handoff.md 작성 양식
├── handoff.md                       # 현재 활성 프로젝트 브리핑
├── ref-ids.md                       # 모든 업로드 에셋 UUID 목록
├── seedance-prompt-framework.md     # 프롬프트 구조·모델 파라미터 가이드
├── prompt-log.md                    # 생성 프롬프트 누적 기록
└── feedback-tracker.xlsx            # 이미지·영상 승인/거절 트래커
```

#### 2. 주요 파일 설명

**`CLAUDE.md`** — 에이전트의 작업 지침서입니다. Claude가 프로젝트 디렉터리에서 실행될 때 가장 먼저 읽는 파일로, 전체 7단계 워크플로우와 핵심 규칙이 담겨 있습니다. 프로젝트를 새로 만들 때 이 파일부터 작성합니다. `models/CLAUDE.md`, `environments/CLAUDE.md`, `storyboard/CLAUDE.md`도 각 단계의 세부 지침을 담고 있습니다.

**`handoff.template.md`** — handoff 문서의 **템플릿 양식**입니다. 새 에피소드를 시작할 때 이 파일을 복사해서 handoff.<이름>.md`로 저장하고, 프로젝트 개요·캐릭터 설명·레퍼런스 UUID·씬 브리프를 채워 넣습니다. 클로드가 알아서 채움.

```markdown
# Title                     ← 에피소드 제목

## Project Overview         ← 콘셉트·포맷·분위기

## Models
### Model 1 (M1)
**Model Description**: ...  ← 외형·성격·역할

## Reference Image UUIDs
| File | UUID |            ← 캐릭터 시트·환경 UUID 표
...

## Ref Stacks               ← 컷별 --image 플래그 복붙 블록
### CUT 1 — ...
--image <char-sheet-uuid>
--image <env-uuid>

## Scene Briefs             ← 컷별 카메라·감정 한줄 요약
```

**`models/descriptions.template.md`** (및 `environments/descriptions.template.md`) — 캐릭터·환경 설명 문서의 **템플릿 양식**입니다. Higgsfield에 이미지를 업로드한 뒤, 이 양식을 따라 외형 묘사와 UUID를 기록하면 Claude가 나중에 프롬프트를 쓸 때 참조합니다.

```markdown
## Model N

**Subject:** 두둥, 회색 영국 숏헤어 고양이

**Model description:** 뚱뚱하고 무뚝뚝한 고양이 ...

**Image References:**
- model-1-char-sheet.png -> 522d8454-047b-4acc-...
- model-1-detail-1.png   -> (레퍼런스로 쓰지 않음)
```

---

#### 3. handoff 읽기

`handoff.md`는 핸드오프 파일입니다.

```bash
# Claude에게 지시
"handoff.md 읽고 동네 한 바퀴 에피소드 캐릭터와 씬 구조를 요약해줘"
```

Claude가 읽어오는 핵심 정보:

- **두둥 (M1):** 뚱뚱한 회색 영국 숏헤어, 점잖고 무뚝뚝, UUID `95366446`
- **둥실 (M4):** 노란 고양이, 활달하고 탄력적, UUID `3c64a938`
- **씬:** 골목 → 벽 도약 → 두둥 배 걸림 개그 → 회복 → 옥상 행진 → 해소

#### 4. 스토리보드 생성

화면을 명시적으로 만들때는 스토리 보드를 이용, 자유롭게 탐험할때는 핸드오프(`handoff.md`) 만으로 생성하는게
좋음(토큰 절약)

```bash
# Claude에게 지시
"handoff.md 기반으로 동네 한 바퀴 스토리보드 시트 만들어줘.
storyboard/CLAUDE.md 따라서 9프레임 3×3 그리드로."
```

Claude가 자동으로 수행하는 것:
1. `handoff.md`에서 Scene 브리프 읽기
2. `ref-ids.md`에서 캐릭터 시트·환경 UUID 조회
3. Nano Banana Flash로 탐색 버전 생성
4. `storyboard/storyboard-log.md`에 기록

생성된 스토리보드 예시

![생성된 스토리 보드](docs/storyboard-nr-rovers-sheet.png)

스토리 보드 수정이 필요하면

```bash
"3번 프레임 두둥이 배가 벽 위에 걸려 있어야 해. 더 코믹하게 다시 생성해줘"
```

승인 후 Nano Banana Pro로 최종 시트 재렌더:

```bash
"승인. Nano Banana Pro로 최종 시트 렌더해줘"
# → storyboard-nr-rovers-sheet-final.png 생성
# → Higgsfield 업로드 → UUID c3e30b4a-... 발급
# → ref-ids.md에 자동 기록
```

#### 5. 키프레임 확정

영상 한 컷마다 시작·끝 프레임을 확정합니다.

```bash
"NR 3컷 구성으로 키프레임 생성해줘.
CUT1: 프레임 1→3 (접근+도약)
CUT2: 프레임 4→6 (개그)
CUT3: 프레임 7→9 (회복+해소)"
```

Claude가 생성하는 파일:

```
storyboard/keyframes/
├── cut1-start-frame.png        (CUT1 시작, UUID: 034f7be4)
├── cut1-end-frame.png           (CUT1 끝 / CUT4 시작, UUID: 0ea80a45)
├── cut2-start-frame.png       (CUT2 시작, UUID: f59a6a91)
├── cut2-end-frame.png           (CUT2 끝, UUID: 5105fb5d)
├── cut3-start-frame.png           (CUT3 시작, UUID: 83d4ab5c)
└── cut3-end-frame.png          (CUT3 끝, UUID: 566dd444)
```

#### 6. 영상 생성

```bash
"CUT1 영상 생성해줘.
2D 애니메이션 스타일, 6초, 720p, 코미디 장르.
두둥·둥실이 햇살 드는 골목을 트롯으로 내려와 벽으로 향한다."
```

Claude가 구성하는 higgsfield cli로 Seedance 2.0에 내리는 명령:

```bash
higgsfield generate seedance_2_0 \
  --prompt "Two cartoon cats trot side by side down a sunny brick lane toward a low garden wall...No music." \
  --duration 6 \
  --resolution 720p \
  --genre comedy \
  --start-image 034f7be4 \       # CUT1 시작 프레임
  --end-image 0ea80a45 \         # CUT1 끝 프레임
  --image c3e30b4a \             # 스토리보드 시트 (필수)
  --image 95366446 \             # 두둥 캐릭터 시트 (필수)
  --image 3c64a938               # 둥실 캐릭터 시트 (필수)
```

같은 방식으로 CUT2, CUT3, CUT4(도약→개그 이어붙이기)를 생성한 뒤 ffmpeg으로 합칩니다.

실제 생성된 결과물 (이 프로젝트에서 확인 가능):

```
outputs/
├── cut1-approach.mp4    (6s, 접근+도약)
├── cut2-comedy.mp4      (7s, 개그)
├── cut3-resolution.mp4  (7s, 회복+해소)
├── cut4-leap-gag.mp4    (15s, 도약→배걸림 연결)
└── full.mp4             (35s, 최종 합본)
```

총 비용: 약 $5.29 (4개 컷, 35초 분량)

---

### FAQ

**Q. UUID를 잃어버렸어요.**  
`ref-ids.md`를 확인하세요. 모든 업로드 UUID가 여기 기록됩니다. 없다면 Higgsfield 대시보드에서 해당 에셋을 찾아 UUID를 복사합니다.

**Q. 영상마다 캐릭터 얼굴이 달라요.**  
캐릭터 시트 UUID를 `--image`로 빠뜨렸거나, 클로즈업·편집 이미지를 레퍼런스로 쓴 경우입니다. 반드시 캐릭터 쉬트 이미지만 사용 해야 합니다.
Higgsfield의 Soul ID를 기능으로 캐릭터 ID를 만들어 캐릭터 일관성 유지 가능. 자주 사용하는 캐릭터의 경우에 유용.
higgsfield cli를 사용할 경우 seedance 모델의 입력으로 soul-id 지원하지 않음.

**Q. 스토리보드가 마음에 들지 않아요.**  
`"다시 생성해줘"`라고 말하면 Claude가 동일 레퍼런스로 재생성. 구체적으로 설명 해야함.  `"3번 프레임 카메라를 더 낮게, 개그가 더 강조되게"`.

**Q. 컷 연결이 갑자기 바뀌어요.** 
prompt 로그 파일 보고 경계 프레임이 같은 키프레임을 제대로 쓰는지 확인. 앞 컷의 `--end-image`와 뒤 컷의 `--start-image`가 동일한 UUID를 가리켜야 합니다.

**Q. Seedance job 이 실패했어요.**  
`seedance-failure-log.md`에 기록하고, 에러 메시지를 확인합니다. 흔한 원인은 UUID가 유효하지 않거나, duration이 지원 범위(4–15초)를 벗어난 경우입니다.

**Q. 비용이 너무 많이 나와요.**  
- 디렉터 모델로 클로드 말고 deepseek v4 pro를 사용해 보세요.
- 이미지 모델은 탐색은 Flash + `fast` 모드, 최종만 Pro + `std` 모드를 사용하세요. 
- 스토리 보드 없이 handoff 만으로 제작. 이미지 모델 비용 최소화.
- higgsfield에서 Seedance 2.0 가격이 오르고 있음. MCP/skills 에서 unlimited 모델 사용 안됨.
- 실제 사용 크레딧이나 비용을 로그로 남겨 보고 판단.

**2026년 6월 현재 Seedance 2.0 가격 비교**

| 서비스 | 영상 모델 | 해상도 | 생성 시간 | 비용 | 비고 |
|--------|-----------|--------|-----------|------|------|
| OpenRouter | Seedance 2.0 | 1080p | 15초 | $2.27 | 달러 직접 청구 |
| Higgsfield | Seedance 2.0 | 1080p | 15초 | 65.5 Credits ≈ $3.28 | $1 = 20 Credits |

**Q. Seedance 2.0 외에 다른 video generation모델은?**
- Kling 3.0, 가격: https://kling.ai/dev/pricing
- alibaba에서 제공하는 video generation 모델로 HappyHorse 1과 WAN 2.7이 있음, 가격: https://www.alibabacloud.com/help/en/model-studio/model-pricing  Happy Horse 1.0 t2v 1080p $0.24/s
    - API https://www.alibabacloud.com/help/en/model-studio/video-generation-api/
- Google Veo 3.1, 가격: Veo 3 Fast: $0.15/초, Veo 3: $0.40/초 (2026년 6월 현재) 
    - API https://ai.google.dev/gemini-api/docs/video
