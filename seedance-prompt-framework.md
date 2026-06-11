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
- `models/Description.md` -- model identity and outfit specs
- `environment/Description.md` -- environment descriptions
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

## Prompt structure for Seedance 2

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

| Flag | Use |
|-----|-----|
| `--image` | Environment/character references – pass as many as needed, no hard limit |
| `--start-image` | First frame = use the approved still from the image batch |
| `--end-image` | Last frame for a transition – sets the closing frame of the clip |
| `--video` | Reference video for motion/style guidance – pass as many as needed, no hard limit |
| `--audio` | Reference audio (lipsync / soundtrack match). Use this, NOT `--generate-audio` |

Each flag accepts either a local file path (auto-uploaded) or a UUID (upload id or a previous job id).

**Important:** Use generated environment shots of the model as `--image` refs, not clean studio shots. Studio backgrounds bleed into the environment mid-clip.

**Character sheet rule:** ALWAYS pass the model's character sheet UUID as a minimum `--image` ref on every Seedance generation. This is non-negotiable for identity consistency

| Model | Character Sheet UUID |
|-------|----------------------|
| Model 1 |  |
| Model 2 |  |


Recommended ref stack per generation:
1. `--start-image` -- approved still from the image batch (sets first frame)
2. `--image <char-sheet-uuid>` -- character sheet (mandatory minimum)
3. `--video <reference-video-uuid>` -- reference video if exist
