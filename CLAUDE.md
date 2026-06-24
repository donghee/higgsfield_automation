# Higgsfield Automation — Agent Instructions

## Project Context

**Subject:** 
**Environments:** 
**Video model:** Seedance 2.0 (`seedance_2_0`).
**Image model:** Nano Banana Pro (`nano_banana_2`) for hero images; GPT Image 2 (`gpt_image_2`) for text/design.

Reference data lives in:
- `ref-ids.md` — all uploaded asset UUIDs and URLs
- `models/description.md` — model identity and outfit specs
- `environments/description.md` — environment descriptions
- `handoff.md` — project brief, story overview, model/environment descriptions, reference UUID tables
- `outputs/shotlist.html` — shotlist and prompt structure
- `seedance-prompt-framework.md` — model params and sound design rules for Seedance
- `alibaba-cloud-prompt-framework.md` — model params and sound design rules for Alibaba HappyHorse and WAN

---

## Workflow

### 1. Create Model Descriptions
- Follow `models/CLAUDE.md`
- Generate character sheets (`model-*-char-sheet.png`) and close-up shots (`model-*-detail-*.png`) with Nano Banana Pro
- Upload all model images to Higgsfield, then write `models/description.md` (one `## Model N -- @NAME` section each)
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 2. Create Environment Descriptions
- Follow `environments/CLAUDE.md`
- Upload every environment image to Higgsfield and analyze each in detail
- Write `environments/description.md` (one `## Environment N -- @NAME` section each, covering texture, lighting, atmosphere, scale, best-for scenes)
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 3. Create Handoff document
- Read `handoff.template.md`
- Fill in project title, descriptions, reference UUIDs and ref stacks
- Save as `handoff.md`

### 4. Create Director's Shotlist
- Follow `shotlist-director.md`
- Generate `outputs/shotlist.html`

### 4b. Create Storyboard Sheet (Optional)
- Read `outputs/shotlist.html` for the shotlist
- Follow `storyboard/CLAUDE.md`
- Generate the storyboard sheet (`storyboard-*-sheet.png`) and upload it to Higgsfield
- **Append** all generation details (prompt, job ID, URL, UUID, version notes, storyboard sheet) to `storyboard/storyboard-log.md` — this is the cumulative archive; every new version is appended, never overwritten
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 5. Generate Video
- Read `outputs/shotlist.html` for the prompt and scene. Use `seedance-prompt-framework.md` (Seedance) or `alibaba-cloud-prompt-framework.md` (HappyHorse, WAN) for model reference and ref stacks.
- **If a storyboard sheet exists:** drive every video job from the **approved storyboard sheet** — it is the shot's visual blueprint, not an optional reference. Pass it via `--image <storyboard-sheet-uuid>` and name the UUID explicitly in the prompt text (never attach it silently). State in the prompt that it is a 9-panel storyboard sheet, e.g. `[Image N] is a 9-panel storyboard sheet showing the full sequence — use it as the visual blueprint for composition and timing.` Mandatory minimum refs: storyboard sheet UUID + character sheet UUID.
- **Single shot:** always pass `--start-image`.
- **Multishot sequence:** always pass `--start-image` and `--end-image` to keep continuity across cuts.
- **Boarded-frame shot:** when a shot matches a specific storyboard frame, use that frame's **finalized standalone still** (storyboard STEP 5) as `--start-image` / `--end-image`. Pull additional references from `ref-ids.md` with `--image` and `--video`.
- Save every generated video to the `outputs/` directory.

### 6. Log Prompts
- Append every image/video prompt (with job ID and output URL) to `prompt-log.md`
- Log Seedance failures separately in `seedance-failure-log.md`

### 7. Feedback Tracker

Maintain a single Excel file (`feedback-tracker.xlsx`) with four sheets.

**Rules:**
- Read the tracker before each generation to learn approved vs. rejected direction.
- After every generation, append a new row to the matching sheet (Images, Storyboard, or Videos) with the generated asset's information.

**Sheets:**
- **Sheet 1 — Guide:** how to use the tracker — explains each sheet/column, the `Status` colors, and the review-before-generation rule.
- **Sheet 2 — Images:** one row per generated or reference image. Columns: File Name, Model, Prompt, UUID, Local Path, Source URL, Status, Notes
- **Sheet 3 — Storyboard:** one row per generated storyboard image. Same columns as Images.
- **Sheet 4 — Videos:** one row per generated video. Columns: File Name, Model, Prompt, References, UUID, Local Path, Source URL, Status, Notes

**Column definitions:**
- `File Name`: asset file name
- `Model`: generation model used (e.g. `nano_banana_2`, `gpt_image_2`, `seedance_2_0`)
- `Prompt`: full prompt used to generate the asset
- `References`: UUIDs of input reference images, videos, or audio passed to the job
- `UUID`: generated asset ID uploaded into Higgsfield
- `Local Path`: full asset path on local disk
- `Source URL`: full asset URL — always complete, never abbreviated or truncated
- `Status`: red = rejected · green = approved · yellow = pending (toggleable cell)
- `Notes`: freeform reviewer feedback per asset

---

## Key Rules

- Use the char sheet UUID as the model ref — never detail/editorial images (they bleed into frames)
- Sound design: physical and specific, never musical. End every prompt with **No music.**
- Resolution: always `2k` for Nano Banana Pro; `720p` default for Seedance
- Mode: `std` for final output, `fast` for preview/iteration
