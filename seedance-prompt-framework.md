# Generate Model Reference & Prompt Framework

---

## Image Models

### Nano Banana Pro (`nano_banana_2`) ← use this for all hero image generation

| Param | Options | Default | Notes |
|---|---|---|---|
| `prompt` | text | — | Required |
| `aspect_ratio` | `auto` `1:1` `3:2` `2:3` `4:3` `3:4` `4:5` `5:4` `9:16` `16:9` `21:9` | `1:1` | Includes `auto` |
| `resolution` | `1k` `2k` `4k` | `2k` | **Always use 2k. 4k looks plastic – loses film grain and texture.** |
| `input_images` | array | — | Passed via `--image` flags |

---

### Nano Banana 2 (`nano_banana_flash`) ← faster, use for quick iteration

| Param | Options | Default | Notes |
|---|---|---|---|
| `prompt` | text | — | Required |
| `aspect_ratio` | `1:1` `3:2` `2:3` `4:3` `3:4` `4:5` `5:4` `9:16` `16:9` `21:9` | `1:1` | No `auto` option |
| `resolution` | `1k` `2k` `4k` | `1k` | Default is 1k – lower quality than Pro |
| `medias` | array | — | Passed via `--image` flags |

**Notes:** Nano Banana 2 and Nano Banana Pro are different models. Use `nano_banana_flash` for fast cheap iteration when testing compositions and angles, then switch to `nano_banana_2` (Pro) for the final approved generation.

---

### GPT Image 2 (`gpt_image_2`)

| Param | Options | Default | Notes |
|---|---|---|---|
| `prompt` | text | — | Required |
| `aspect_ratio` | `1:1` `4:3` `3:4` `16:9` `9:16` `3:2` `2:3` | `1:1` | |
| `resolution` | `1k` `2k` `4k` | `2k` | 4k available |
| `quality` | `low` `medium` `high` | `high` | Use `low`/`medium` for fast iteration |
| `batch_size` | integer | `1` | **Generate multiple variations in one job** – pass `--batch_size 4` to get 4 outputs from a single prompt |
| `medias` | array | — | Supports image refs via `--image` |

**Key advantage:** `--batch_size` is powerful for the iterate phase – run 4 variations of the same prompt in one shot rather than 4 separate jobs.

---

## Video Models

### Seedance 2.0 (`seedance_2_0`)

| Param | Options | Default | Notes |
|---|---|---|---|
| `prompt` | text | — | Required |
| `aspect_ratio` | `auto` `16:9` `9:16` `4:3` `3:4` `1:1` `21:9` | `16:9` | |
| `duration` | integer | `5` | 4–15s supported |
| `resolution` | `480p` `720p` `1080p` | `720p` | |
| `genre` | `auto` `action` `horror` `comedy` `noir` `drama` `epic` | `auto` | Shapes cinematic feel – see Genre section below |
| `mode` | `std` `fast` | `std` | `fast` = quick preview; `std` = final quality |
| `medias` | array | — | `--start-image` sets first frame; `--end-image` sets last frame; `--image` for character/env refs; `--video` for reference video; `--audio` for lipsync/soundtrack |

**Generation modes:**
- **Multimodal reference-based (new):** images (0–9) + videos (0–3) + audio (0–3) + optional text prompt → 1 video. Audio alone is not allowed — at least 1 reference image or video is required. Supports generating, editing, and extending videos.
- **Image to video (first + last frame):** first frame image + last frame image + optional text → 1 video.
- **Image to video (first frame):** first frame image + optional text → 1 video.
- **Text to video:** text prompt only → 1 video.


### Seedance 2.0 in OpenRouter (`bytedance/seedance-2.0`)

OpenRouter video generation is **async**: submit → poll → download. A single request never returns the video (generation takes 30s–a few minutes). Requires `OPENROUTER_API_KEY`.

| Param | Type | Notes |
|---|---|---|
| `model` | string | Required — `bytedance/seedance-2.0` |
| `prompt` | string | Required |
| `duration` | int | Must be one of the model's `supported_durations` (discrete set, not a range) |
| `resolution` | string | `480p` `720p` `1080p` — validate against `supported_resolutions` |
| `aspect_ratio` | string | e.g. `16:9` `9:16` `4:3` `3:4` `1:1` `21:9` — validate against `supported_aspect_ratios` |
| `size` | string | `"WxH"`, interchangeable with `resolution` + `aspect_ratio` |
| `seed` | int | Honored only if the model's `seed` capability is true |
| `frame_images[]` | array | Image-to-video. Each: `{ type:"image_url", image_url:{url}, frame_type:"first_frame"\|"last_frame" }` |
| `input_references[]` | array | Reference-to-video (character/style/motion guidance). Each: `{ type:"image_url", image_url:{url} }` or `{ type:"video_url", video_url:{url} }` — same shape as `frame_images` but **no** `frame_type`. If both arrays are present, `frame_images` wins |
| `callback_url` | string | HTTPS webhook instead of polling |

**Validate params first** — fetch the model's capabilities and only send values from the returned sets (an out-of-set value returns 400):

```bash
curl -sS https://openrouter.ai/api/v1/videos/models \
  | jq '.data[] | select(.id == "bytedance/seedance-2.0")'
```

**1. Submit** → returns `{ id, polling_url, status: "pending" }`:

```bash
curl -X POST "https://openrouter.ai/api/v1/videos" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "bytedance/seedance-2.0",
    "prompt": "PROMPT",
    "duration": 5,
    "resolution": "720p",
    "aspect_ratio": "16:9",
    "frame_images": [
      { "type": "image_url", "image_url": { "url": "first frame image url" }, "frame_type": "first_frame" },
      { "type": "image_url", "image_url": { "url": "last frame image url (optional)" }, "frame_type": "last_frame" }
    ],
    "input_references": [
      { "type": "image_url", "image_url": { "url": "character sheet image url" } },
      { "type": "image_url", "image_url": { "url": "environment/character reference image url" } },
      { "type": "video_url", "video_url": { "url": "reference input video url" } }
    ]
  }'
```

**2. Poll** `GET <polling_url>` every ~30s until `status` is `completed` (terminal failures: `failed`, `cancelled`, `expired` — surface the `error` field):

```bash
curl -sS "$POLLING_URL" -H "Authorization: Bearer $OPENROUTER_API_KEY" | jq '.status, .error'
```

**3. Download** the finished MP4 (auth header required):

```bash
curl -sS -L "$(curl -sS "$POLLING_URL" -H "Authorization: Bearer $OPENROUTER_API_KEY" | jq -r '.unsigned_urls[0]')" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" --output seedance.mp4
```

**Usage tips for Seedance via OpenRouter:**
- Image/video `url` can be a public `https://` URL or a local-file data URL (`data:image/png;base64,<...>`). Upload assets to Higgsfield first and pass their image/video URLs as input.
- Use `frame_images` (first/last frame) for image-to-video; use `input_references` for character/environment style guidance.
- Keep the same prompt structure and sound-design rules as the Higgsfield path; OpenRouter only changes the transport, not the prompt craft.

**Recommended ref stack (OpenRouter equivalent of the Higgsfield CLI stack):**
1. `frame_images` with `frame_type:"first_frame"` -- approved still from the image batch (Higgsfield `--start-image`)
2. `input_references` image -- character sheet, mandatory minimum for identity (Higgsfield `--image <char-sheet-uuid>`); add more `input_references` images for environment/character references as needed, no hard limit
3. `input_references` video -- reference video if exists (Higgsfield `--video <reference-video-uuid>`)
4. *(optional)* `frame_images` with `frame_type:"last_frame"` -- closing frame for a transition (Higgsfield `--end-image`)

### HappyHorse / WAN in Alibaba Cloud (`happyhorse-1.1-i2v` / `happyhorse-1.1-r2v` / `wan2.7-i2v` / `wan2.7-r2v`)

> **See [`alibaba-cloud-prompt-framework.md`](alibaba-cloud-prompt-framework.md) for full parameters, examples, and notes.**

**Model summary:**
- `happyhorse-1.1-i2v` — generate video from a single start frame (only `first_frame` type allowed)
- `happyhorse-1.1-r2v` — generate video from 1–9 reference images (see `[Image N]` in prompt)
- `wan2.7-i2v-2026-04-25` — most flexible i2v, supporting first/last frame + audio + video continuation
- `wan2.7-r2v` — multi-character reference (image+video) + per-character voice support

**Recommended ref stack:**

| Mode | Ref stack |
|---|---|
| `happyhorse i2v` | `first_frame` = approved start still (no other types allowed — char/storyboard refs go in prompt text) |
| `happyhorse r2v` | `media[0]` char sheet → `[Image 1]` · `media[1]` storyboard sheet → `[Image 2]` |
| `wan2.7 i2v` | `first_frame` + optional `last_frame` + optional `driving_audio` |
| `wan2.7 r2v` | `reference_image`/`reference_video` per character (max 5) + optional `first_frame` |


**Usage tips for Alibaba Cloud video generation:**
- Image/video `url` can be a public `https://` URL or base64. Upload assets to Higgsfield first and pass their image/video URLs as input.
- **Strip the number in storyboard frame** — remove the burned‑in 1–9 digit and any grid lines before using a storyboard still as `first_frame`; the still must be clean or the number bleeds into the video frame.

---
## Prompt workflow


### What Claude does

Claude is prompt writer, It takes directional short and turns it into structured prompts optimised for
Seedance, The director directes and ideates, Claude writes, Seedance shoots

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
- `seedance-prompt-framework.md` -- this file

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

```
[WHO] – subject description, outfit, defining physical detail (hair colour, silhouette)
[ACTION] – what are they doing, how does it feel physically
[CAMERA] – start position, movement over time, end position
[ENVIRONMENT] – setting, time of day, atmospheric detail
[LIGHT] – light sources, quality, colour, how it interacts with the subject
[SOUND] – specific physical sounds, escalation, no music
```

---

## Use Claude for variations
When a beat could go three ways, ask Claude for three versions of the same prompt with different tonal or staging choices, then run all three in Seedance and compare the outputs.

**Variation axes to explore:**
- Camera distance (tight / mid / wide)
- Camera movement (static / tracking / pull-back / crane up)
- Time of action (start of movement / mid-action / aftermath)
- Sound emphasis (intimate and close / building to wide)

---

## Media flags for Seedance 2

| Flag | Count | Use |
|-----|-----|-----|
| `--image` | 0–9 | Storyboard / environment / character reference images |
| `--start-image` | 0–1 | First frame – the approved still from the image batch |
| `--end-image` | 0–1 | Last frame – sets the closing frame for a transition |
| `--video` | 0–3 | Reference video for motion / style guidance |
| `--audio` | 0–3 | Reference audio (lipsync / soundtrack match). Use this, NOT `--generate-audio` |

Each flag accepts either a local file path (auto-uploaded) or a UUID (upload id or a previous job id).

**Important:** Use generated environment shots of the model as `--image` refs, not clean studio shots. Studio backgrounds bleed into the environment mid-clip.

**Storyboard sheet rule:** ALWAYS pass the storyboard sheet UUID as a minimum `--image` ref on every Seedance generation. This is non-negotiable for identity consistency

**Character sheet rule:** ALWAYS pass the model's character sheet UUID as a minimum `--image` ref on every Seedance generation. This is non-negotiable for identity consistency

| Model | Character Sheet UUID |
|-------|----------------------|
| Model 1 |  |
| Model 2 |  |


Recommended ref stack per generation:
1. `--start-image` -- approved still from the image batch (sets first frame) optional
2. `--end-image` -- approved still from the image batch (sets end frame) optional
2. `--image <storyboard-sheet-uuid>` -- storyboard sheet (mandatory minimum)
2. `--image <char-sheet-uuid>` -- character sheet (mandatory minimum)
3. `--video <reference-video-uuid>` -- reference video if exist

---

## Consistency rules

Rules for keeping character, environment, and tone from drifting across consecutive shots.

### 1. Default to a single shot

- Treat each beat as **one Seedance shot** by default. The more you split a beat into cuts, the higher the risk of consistency breaking.
- For environment consistency, pass **as many environment images as possible** of the same location as `--image` refs — use generated shots of the model inside that environment, not clean studio shots.
- Always pass the **storyboard sheet UUID + character sheet UUID** as minimum refs on every shot (identity / composition anchors).

### 2. For multishot sequences

The core principle for holding environment and character consistency when stitching multiple cuts together:

- Make **"the last frame of cut N = the first frame of cut N+1"** a **single shared still**.
- Pass that still as `--end-image` on cut N and as `--start-image` on cut N+1 (one image shared by two shots).
- In other words, put **both** `--start-image` and `--end-image` on each Seedance shot so adjacent cuts hold the same boundary frame.
- This keeps lighting, background, outfit, and pose from breaking at the cut transition and carries them through seamlessly.

### 3. Shared principles

- Use the **finalized standalone still** from storyboard STEP 5 as the boundary-frame still.
- Always use a **model shot generated in that environment** as the environment ref — clean studio backgrounds bleed into the environment mid-clip.
- Identity details (outfit, hair, silhouette) are locked to the character sheet, so never drop the char sheet UUID on any shot.
