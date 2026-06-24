# Alibaba Cloud Video Generation — Prompt Framework

HappyHorse / WAN models via Alibaba Cloud Model Studio API.

All models are **async**: submit → poll → download. Requires `DASHSCOPE_API_KEY`.

**API endpoint:**
```
POST https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/video-generation/video-synthesis
```

> **Polling endpoint:** `GET https://dashscope-intl.aliyuncs.com/api/v1/tasks/{task_id}`

---

## Model Selection

| Model | Type | Best for |
|---|---|---|
| `happyhorse-1.1-i2v` | image-to-video | Locked composition shots driven from a single start frame. No end frame support. |
| `happyhorse-1.1-r2v` | reference-to-video | Multi-ref cinematic shots driven from 1–9 reference images. |
| `wan2.7-i2v-2026-04-25` | image-to-video | Most flexible i2v — `first_frame` + optional `last_frame`, `driving_audio`, or video continuation (`first_clip`). |
| `wan2.7-r2v` | reference-to-video | Complex multi-character shots with `reference_image`/`reference_video` and per-character voice (`reference_voice`). |

---

## Parameter Comparison

| Param | `happyhorse i2v` | `happyhorse r2v` | `wan2.7 i2v` | `wan2.7 r2v` |
|---|---|---|---|---|
| `model` | `happyhorse-1.1-i2v` (or `1.0`) | `happyhorse-1.1-r2v` (or `1.0`) | `wan2.7-i2v-2026-04-25` | `wan2.7-r2v` |
| `input.prompt` | Optional | Required. Use `[Image N]` | Optional | Required. Use `Image N`, `Video N` identifiers |
| `input.negative_prompt` | Not supported | Not supported | Optional. Max 500 chars | Optional. Max 500 chars |
| `input.media` | Exactly 1 `first_frame` | 1–9 `reference_image` | See valid combinations below | See asset limits below |
| `media[].reference_voice` | Not supported | Not supported | Not supported | Optional. Per-asset voice ref. WAV/MP3, 1–10s, max 15 MB |
| `parameters.resolution` | `1080P` (default) · `720P` | `1080P` (default) · `720P` | `1080P` (default) · `720P` | `1080P` (default) · `720P` |
| `parameters.ratio` | Not supported (follows input image) | `16:9` (default) · `9:16` · `4:3` · `3:4` · `1:1` · `4:5` · `5:4` · `21:9` · `9:21` | Not supported (follows input material) | `16:9` (default) · `9:16` · `1:1` · `4:3` · `3:4`. Ignored if `first_frame` is provided |
| `parameters.duration` | 3–15s. Default `5` | 3–15s. Default `5` | 2–15s. Default `5` | 2–15s (no ref video) · 2–10s (with ref video). Default `5` |
| `parameters.watermark` | `true` (default) · `false` | `true` (default) · `false` | `false` (default) · `true` | `false` (default) · `true` |
| `parameters.prompt_extend` | Not supported | Not supported | `true` (default) · `false` | `true` (default) · `false` |
| `parameters.seed` | 0–2147483647 | 0–2147483647 | 0–2147483647 | 0–2147483647 |

---

## Media Types by Model

| Model | `type` value | Count | Role |
|---|---|---|---|
| `happyhorse i2v` | `first_frame` | **exactly 1** (required) | Sets the opening frame. **Only `first_frame` is accepted — no other types allowed** |
| `happyhorse r2v` | `reference_image` | 1–9 (required) | Style/character/composition reference. Maps to `[Image N]` in prompt |
| `wan2.7 i2v` | `first_frame` | exactly 1 | Sets the opening frame |
| `wan2.7 i2v` | `last_frame` | 0–1 (optional) | Sets the closing frame (use with `first_frame`) |
| `wan2.7 i2v` | `driving_audio` | 0–1 (optional) | Drives lip-sync and action timing. WAV/MP3, 2–30s, max 15 MB |
| `wan2.7 i2v` | `first_clip` | 0–1 (optional) | Video continuation. MP4/MOV, 2–10s, max 100 MB |
| `wan2.7 r2v` | `reference_image` | 0–5 total (≥1 ref required) | Character/object/scene reference. Maps to `Image N` in prompt |
| `wan2.7 r2v` | `reference_video` | 0–5 total (≥1 ref required) | Character reference video with optional voice. Maps to `Video N` in prompt |
| `wan2.7 r2v` | `first_frame` | 0–1 (optional) | Sets the opening frame. `ratio` param is ignored when provided |

> **wan2.7 r2v asset limits:** At least 1 `reference_image` or `reference_video` required. `reference_images` + `reference_videos` ≤ 5. Max 1 `first_frame`. Each reference asset with a subject must contain only **one character**.

---

## wan2.7-i2v Valid Media Combinations

Only the following combinations are accepted — any other combination returns an error:

| Combination | Media array contents |
|---|---|
| First frame only | `first_frame` |
| First frame + audio | `first_frame` + `driving_audio` |
| First + last frame | `first_frame` + `last_frame` |
| First + last frame + audio | `first_frame` + `last_frame` + `driving_audio` |
| Video continuation | `first_clip` |
| Video continuation + last frame | `first_clip` + `last_frame` |

> Each `type` can appear **at most once** in the media array.

---

## Image / Video Requirements

| | `happyhorse i2v` `first_frame` | `happyhorse r2v` `reference_image` | `wan2.7` images |
|---|---|---|---|
| Formats | JPEG/PNG/WEBP | JPEG/PNG/WEBP | JPEG/PNG/BMP/WEBP (no alpha) |
| Min size | Width and height both ≥ 300px | Shortest side ≥ 400px | Width and height 240–8000px |
| Aspect ratio | 1:2.5 to 2.5:1 | — | 1:8 to 8:1 |
| Max file size | 20 MB | 20 MB | 20 MB |

`wan2.7 r2v` reference_video: MP4/MOV, 1–30s, 240–4096px, max 100 MB.

---

## Warnings

> **happyhorse i2v:** `media` 배열에 `reference_image`, `last_frame` 등 `first_frame` 이외의 타입을 넣으면 `"Input should be 'first_frame'"` 오류가 반환됩니다. character sheet나 storyboard sheet를 `media`로 전달할 수 없습니다 — 프롬프트 텍스트로만 가이드해야 합니다.

> **wan2.7 i2v:** Each `type` can appear **at most once** in the media array. Any combination not listed in the valid combinations table returns an error.

---

## Submit Examples

**1. Submit** → returns `task_id`:

```bash
API_URL="https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/video-generation/video-synthesis"

# happyhorse i2v — first frame only (ratio follows input image, no other media types allowed)
curl -X POST "$API_URL" \
  -H "X-DashScope-Async: enable" \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "happyhorse-1.1-i2v",
    "input": {
      "prompt": "PROMPT describing action and scene. No music.",
      "media": [
        { "type": "first_frame", "url": "https://example.com/start-frame.png" }
      ]
    },
    "parameters": { "resolution": "720P", "duration": 5, "watermark_switch": false }
  }'

# happyhorse r2v — multi-ref driven (input.media with type=reference_image)
curl -X POST "$API_URL" \
  -H "X-DashScope-Async: enable" \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "happyhorse-1.1-r2v",
    "input": {
      "prompt": "[Image 1] is the character reference for CHARACTER_NAME. [Image 2] is a 9-panel storyboard sheet showing the full sequence — use it as the visual blueprint for composition and timing. Ignore all frame numbers burned into [Image 2]; do not render any digits or text overlays in the output. PROMPT ... No music.",
      "media": [
        { "type": "reference_image", "url": "https://example.com/char-sheet.png" },
        { "type": "reference_image", "url": "https://example.com/storyboard-sheet.png" }
      ]
    },
    "parameters": { "resolution": "720P", "duration": 5, "ratio": "16:9", "watermark_switch": false }
  }'

# wan2.7 i2v — first frame + last frame (supports transitions)
curl -X POST "$API_URL" \
  -H "X-DashScope-Async: enable" \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "wan2.7-i2v-2026-04-25",
    "input": {
      "prompt": "PROMPT describing action and scene. No music.",
      "negative_prompt": "low resolution, worst quality, deformed",
      "media": [
        { "type": "first_frame", "url": "https://example.com/start-frame.png" },
        { "type": "last_frame",  "url": "https://example.com/end-frame.png" }
      ]
    },
    "parameters": { "resolution": "720P", "duration": 5, "prompt_extend": false, "watermark": false }
  }'

# wan2.7 r2v — multi-subject reference with voice
curl -X POST "$API_URL" \
  -H "X-DashScope-Async: enable" \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "wan2.7-r2v",
    "input": {
      "prompt": "Image 1 walks into the room from Image 3 and greets Video 1. No music.",
      "negative_prompt": "low resolution, worst quality, deformed",
      "media": [
        { "type": "reference_image", "url": "https://example.com/char1-sheet.png",
          "reference_voice": "https://example.com/char1-voice.mp3" },
        { "type": "reference_video", "url": "https://example.com/char2-ref.mp4",
          "reference_voice": "https://example.com/char2-voice.mp3" },
        { "type": "reference_image", "url": "https://example.com/background.png" }
      ]
    },
    "parameters": { "resolution": "720P", "duration": 5, "ratio": "16:9", "prompt_extend": false, "watermark": false }
  }'
```

Response: `{ "output": { "task_id": "...", "task_status": "PENDING" }, "request_id": "..." }`

---

## Poll & Download

**2. Poll** `GET /tasks/{task_id}` every ~15s until `task_status` is `SUCCEEDED` (terminal: `FAILED`, `CANCELED`, `UNKNOWN`):

```bash
curl -X GET "https://dashscope-intl.aliyuncs.com/api/v1/tasks/{task_id}" \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" | jq '.output.task_status, .output.video_url'
```

Status flow: `PENDING` → `RUNNING` → `SUCCEEDED` or `FAILED`.

**3. Download** the finished MP4 (video URL valid for 24 hours only — save promptly):

```bash
curl -L "$(curl -sS "https://dashscope-intl.aliyuncs.com/api/v1/tasks/{task_id}" \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" | jq -r '.output.video_url')" \
  --output output.mp4
```

---

## Recommended Ref Stack

| Mode | Ref stack |
|---|---|
| `happyhorse i2v` | `first_frame` = approved start still (only accepted type — char/storyboard refs go in prompt text only) |
| `happyhorse r2v` | `media[0]` char sheet → `[Image 1]` · `media[1]` storyboard sheet → `[Image 2]` · add env refs up to 9 total |
| `wan2.7 i2v` | `first_frame` = approved start still · `last_frame` = approved end still (optional) · `driving_audio` = audio file (optional) |
| `wan2.7 r2v` | `reference_image`/`reference_video` per character (max 5 total) + optional `first_frame` for locked start · `reference_voice` per asset for voice |

---

## Usage Tips

- **happyhorse i2v**: Pass only 1 `first_frame`. No other media types accepted. Describe character/storyboard in prompt text.
- **wan2.7 i2v**: Use when you need `first_frame` + `last_frame` (transition control) or `driving_audio` (lip-sync). Set `prompt_extend: false` for precise prompt control.
- **happyhorse r2v**: use `[Image N]` in the prompt to reference the Nth image in `media[]` — e.g. `"the cat in [Image 1]"`.
- **wan2.7 r2v**: use `Image N` / `Video N` identifiers (images and videos counted separately). Each subject reference must contain only one character. Duration capped at 10s when `reference_video` is included.
- Keep the same prompt structure and sound-design rules as the Higgsfield/OpenRouter path; only the transport changes.
- Task IDs and video URLs are valid for 24 hours only.

---
## Prompt workflow


### What Claude does

Claude is prompt writer, It takes directional short and turns it into structured prompts optimised for
Seedance, The director directes and ideates, Claude writes, happyhorse or wan shoots

---

## Custom project context

Set up claude with the film's setting, charater roster, tone and relevant context, without it Claude writes
generic prompts, With it, the prompt is tuned to the specific project

For this project that context lives in:
- `models/description.md` -- model identity and outfit specs
- `environment/description.md` -- environment descriptions
- `output/shotlist.html` -- shotlist
- `storyboard/storyboard-log.md` -- storyboard descriptions
- `ref-ids.md` --  all uploaded image UUIDs
- `alibaba-cloud-prompt-framework.md` -- this file

---

## You stay the director

Describe the scene the way you would brief a DP. A paragraph of shorthand naming characters, beats, geography,
sometimes a film comparison. Claude knows what you're talking about turns that into the full structured prompt.

---

## The clarification pass

Before drafting, Claude asks questions about anything it has doubts about to make sure the instructions are as clear as possible. Standard questions:

- **Duration** – how long? (Seedance 2 supports 4–15s)
- **Camera** – locked off, tracking, crane, handheld?
- **Sound design** – what physical sounds define this scene?
- **Start/end frame** – what does it open on, what does it end on?
- **Aspect ratio** – 16:9 editorial or 9:16 social?
- **Film reference** – any visual reference for the energy or tone?

---

## Voice and sound design
Every character has a voice descriptor that holds across scenes. Sound design is always **physical and specific, never musical**, escalating with the action. This gets footage with excellent sound design while avoiding footage with music.

**Sound design principles:**
- Name the specific material making the sound (volcanic gravel, nylon anorak, lattice-heel sneaker)
- Describe how it escalates through the clip
- Always end the prompt with: **No music.**

---

## Prompt structure

Use this order for every HappyHorse/WAN prompt:

1. `[Image N]` character declarations, one line per character sheet.
2. `[Image N]` storyboard sheet declaration, if a storyboard sheet is included.
3. Frame-number suppression line, if a storyboard sheet is included.
4. Main prompt body.

[WHO] – subject description, outfit, defining physical detail (hair colour, silhouette)
[ACTION] – what are they doing, how does it feel physically
[CAMERA] – start position, movement over time, end position
[ENVIRONMENT] – setting, time of day, atmospheric detail
[LIGHT] – light sources, quality, colour, how it interacts with the subject
[SOUND] – specific physical sounds, escalation, no music

---

## Use Claude for variations
When a beat could go three ways, ask Claude for three versions of the same prompt with different tonal or staging choices, then run all three in HappyHorse/WAN and compare the outputs.

**Variation axes to explore:**
- Camera distance (tight / mid / wide)
- Camera movement (static / tracking / pull-back / crane up)
- Time of action (start of movement / mid-action / aftermath)
- Sound emphasis (intimate and close / building to wide)

---

## Media flags for HappyHorse and WAN

These rules apply whenever a storyboard sheet or character sheet is passed as a `reference_image`.

**Important:** Always name each reference image explicitly in the prompt using its index (`[Image N]`). Do not rely on silent media attachment.

**Storyboard sheet rule:** Always identify the storyboard sheet at the top of the prompt and state how it should be used.

> `[Image N] is a 9-panel storyboard sheet showing the full sequence — use it as the visual blueprint for composition and timing.`

Then add the frame-number suppression line:

> `Ignore all frame numbers burned into [Image N]; do not render any digits or text overlays in the output.`

**Character sheet rule:** Always identify each character sheet at the top of the prompt.

> `[Image N] is the character reference for CHARACTER_NAME.`
