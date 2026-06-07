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
| Model 1 | `522d8454-047b-4acc-8002-d93eb7407a12` |
| Model 2 | `` |


Recommended ref stack per generation:
1. `--start-image` -- approved still from the image batch (sets first frame)
2. `--image <char-sheet-uuid>` -- character sheet (mandatory minimum)
3. `--video <reference-video-uuid>` -- reference video if exist
