# Higgsfield Automation — Agent Instructions

## Project Context

**Subject:** 
**Environments:** 
**Video model:** Seedance 2.0 (`seedance_2_0`).
**Image model:** Nano Banana Pro (`nano_banana_2`) for hero images; GPT Image 2 (`gpt_image_2`) for text/design.

Reference data lives in:
- `ref-ids.md` — all uploaded asset UUIDs
- `models/description.md` — model identity and outfit specs
- `environments/description.md` — environment descriptions
- `seedance-prompt-framework.md` — prompt structure, model params, sound design rules

---

## Workflow

### 1. Create Model Descriptions
- Follow `models/CLAUDE.md`
- Generate character sheets (`model-*-char-sheet.png`) and close-up shots (`model-*-detail-*.png`) with Nano Banana Pro
- Upload all model images to Higgsfield, then write `models/description.md` (one `## Model N` section each)
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 2. Create Environment Descriptions
- Follow `environments/CLAUDE.md`
- Upload every environment image to Higgsfield and analyze each in detail
- Write `environments/description.md` (one `## FILENAME -- TITLE` section each, covering texture, lighting, atmosphere, scale, best-for scenes)
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 3. Create handoff.md
- Read `handoff.template.md`
- Fill in project title, model descriptions, reference UUIDs, and ref stacks
- Save as `handoff.md`

### 4. Create Storyboard sheet
- Read `handoff.md` for scene briefs and ref stacks
- Follow `storyboard/CLAUDE.md`
- Generate storyboard sheet (`storyboard-*-sheet.png`) and Upload storyboard sheet images to Higgsfield
- **Append** all generation details (prompt, job ID, URL, UUID, version notes, storyboard sheet) to `storyboard/storyboard-log.md` — this file is the cumulative archive; every new storyboard version gets appended, never overwritten
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 5. Generate video
- Drive every Seedance job from the **approved storyboard sheet** built in step 4 — it is the shot's visual blueprint, not an optional reference.
- Name the **storyboard sheet UUID** in the prompt text to generate the video *from that storyboard sheet* — never attach it silently.
- Read `handoff.md` for the scene brief and `seedance-prompt-framework.md` for prompt structure and ref-stack rules
- **Mandatory minimum refs on every Seedance job:** the approved **storyboard sheet UUID** and the **character sheet UUID** (`--image <storyboard-sheet-uuid> --image <char-sheet-uuid>`) — the storyboard sheet anchors composition/continuity, the char sheet anchors
- **Single shot:** always pass `--start-image`.
- **Multishot sequence:** always pass `--start-image` and `--end-image` to keep continuity across cuts.
- **Boarded-frame shot:** when a shot matches a specific storyboard frame, use that frame's **finalized standalone still** (storyboard STEP 5) as `--start-image` / `--end-image`. Pull additional references from `ref-ids.md` with `--image` and `--video`.
- Save every generated video to the `outputs/` directory.

### 6. Log prompts
- Append every image/video prompt (with job ID and output URL) to `prompt-log.md`
- Log Seedance failures separately in `seedance-failure-log.md`

### 7. Feedback Tracker

Maintain a single Excel file (`feedback-tracker.xlsx`) with three sheets.

**Rules:**
- Read the tracker before each generation to learn approved vs. rejected direction.
- After every generation, append a new row to the matching sheet (Images or Videos) with the generated asset's information.

**Sheets:**
- **Sheet 1 — Guide:** usage instructions for the tracker — what each sheet/column means, how `Status` colors work, and the rule to review it before every generation.
- **Sheet 2 — Images:** one row per generated image. Columns: File Name, Model, Prompt, UUID, Local Path, Source URL, Status, Notes
- **Sheet 3 — Videos:** one row per generated video. Columns: File Name, Model, Prompt, References, UUID, Local Path, Source URL, Status, Notes

**Column definitions:**
- `File Name`: asset file name
- `Model`: generation model used (e.g. `nano_banana_2`, `gpt_image_2`, `seedance_2_0`)
- `Prompt`: full prompt used to generate the asset
- `References` (video only): UUIDs of reference images or videos passed to the job
- `UUID`: Asset ID uploaded into higgsfield
- `Local Path`: full asset path on local disk
- `Source URL`: full asset URL — always the complete URL, never abbreviated or truncated
- `Status`: red = rejected · green = approved · yellow = pending (toggleable cell)
- `Notes`: freeform feedback per image/video

---

## Key Rules

- Use char sheet UUID as model ref — never detail/editorial images (they bleed into frames)
- Sound design: physical and specific, never musical. End every prompt with **No music.**
- Resolution: always `2k` for Nano Banana Pro; `720p` default for Seedance
- Mode: `std` for final output, `fast` for preview/iteration
