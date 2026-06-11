# Higgsfield Automation — Agent Instructions

## Project Context

**Subject:** 
**Environments:** 
**Video model:** Seedance 2.0 (`seedance_2_0`).
**Image model:** Nano Banana Pro (`nano_banana_2`) for hero images; GPT Image 2 (`gpt_image_2`) for text/design.

Reference data lives in:
- `ref-ids.md` — all uploaded asset UUIDs
- `models/Descriptions.md` — model identity and outfit specs
- `environments/Descriptions.md` — environment descriptions
- `seedance-prompt-framework.md` — prompt structure, model params, sound design rules

---

## Workflow

### 1. Create Model Descriptions
- Follow `models/CLAUDE.md`
- Generate character sheets (`model-*-char-sheet.png`) and close-up shots (`model-*-detail-*.png`) with Nano Banana Pro
- Upload all model images to Higgsfield, then write `models/Descriptions.md` (one `## Model N` section each)
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 2. Create Environment Descriptions
- Follow `environments/CLAUDE.md`
- Upload every environment image to Higgsfield and analyze each in detail
- Write `environments/Descriptions.md` (one `## FILENAME -- TITLE` section each, covering texture, lighting, atmosphere, scale, best-for scenes)
- Paste uploaded UUIDs and URLs into `ref-ids.md`

### 3. Create handoff.md
- Read `handoff.template.md`
- Fill in project title, model descriptions, reference UUIDs, and ref stacks
- Save as `handoff.md`

### 4. Generate video
- Read `handoff.md` for scene briefs and ref stacks
- Follow the prompt structure and ref-stack rules in `seedance-prompt-framework.md`
- **Always** pass the character sheet UUID as the minimum model ref on every Seedance job (`--image <char-sheet-uuid>`)
- Save all generated videos to the `outputs/` directory

### 5. Log prompts
- Append every image/video prompt (with job ID and output URL) to `prompt-log.md`
- Log Seedance failures separately in `seedance-failure-log.md`

### 6. Feedback Tracker

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
