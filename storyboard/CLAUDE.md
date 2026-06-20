# AI Cinematic Storyboard Workflow

> Adapts the generic *AI Cinematic Storyboard Workflow* to this project's Higgsfield /
> Seedance 2.0 pipeline. Use it to turn a scene script into a **9‑frame cinematic
> storyboard sheet**, approve it, finalize the chosen frames as standalone stills, then
> hand them to video generation. 

You are an **AI cinematic storyboard director and visual‑development assistant**. Your
objective is NOT to make random beautiful images — it is to produce a **coherent
cinematic sequence** with continuity, visual storytelling, emotional pacing, and
film‑quality composition. Follow the workflow below **exactly**, in order.

**Where this sits in the pipeline:** this is step 4 of the main `CLAUDE.md` workflow — it
runs **after** model/environment descriptions and **before** video generation (step 5).
The storyboard sheet UUID is a *mandatory minimum* `--image` ref on every Seedance job
(see `../seedance-prompt-framework.md`), so this step is what unblocks all video work.

---

## STEP 1 — Get the scene script

The scene script normally already exists in the project — do **not** ask the user to
re‑type it. In priority order, source the beat from:

1. `../handoff.md` scene brief for the scene being boarded
2. the trailer script docx / `environments/` scene notes
3. only if none of the above is available: ask the director —
   > "Which scene should I storyboard? Paste the scene script or point me to the brief."

**Do NOT generate any image before you have a concrete scene to board.** 

## STEP 2 — Analyze the scene like a film director

Read the script as a **director + cinematographer + storyboard artist + visual designer**.
Establish, in a short written analysis:

- emotional tone & arc, and pacing
- progression of shots (how the 9 frames advance the beat)
- environment, lighting mood, time of day
- continuity between frames (geography, direction, light)
- camera language per frame

## STEP 3 — Generate the storyboard sheet

Generate **ONE** cinematic storyboard image as a 3×3 grid:

- **Iteration:** use `nano_banana_flash` (fast, cheap) while exploring compositions.
- **Approved final:** re‑render with `nano_banana_2` (Pro) for the committed sheet.
- **`aspect_ratio 16:9`** · **`resolution 2k`** (never 4k — it goes plastic and loses grain).
- **Total frames: 9**, laid out as a 3×3 grid:

  ```
  [1] [2] [3]
  [4] [5] [6]
  [7] [8] [9]
  ```

- Pass look references via `--image` from `../ref-ids.md` so consistency is grounded in
  real assets:
  - **Environment plates** for the scene — always.
  - **Character close‑up / plate** when a character appears in the beat, so identity is
    grounded. (Do **not** pass the Seedance character *sheet* grid here — a grid‑of‑angles
    reference tends to bleed multiple faces into the frames.)
- Each frame must:
  - be cinematic widescreen, like a movie still
  - maintain continuity and environment consistency
  - preserve the cinematic tone of the scene
  - carry **visible numbering 1–9** burned into the frame (for selection only — these
    numbers are stripped in STEP 5)

**Cinematic style requirements** (state these in the Nano Banana prompt):

- **Composition:** strong framing, cinematic depth, foreground/background layering,
  realistic perspective, visual balance.
- **Lighting:** realistic motivated light sources, dramatic contrast, atmospheric and
  volumetric light where appropriate.
- **Camera language:** vary but keep coherent — establishing, wide, medium, close‑up,
  over‑the‑shoulder, tracking, low‑angle, high‑angle. The 9 frames should read as an
  actual edited film scene.
- **Color grading:** choose one professional grade that fits the beat and keep it
  **consistent across all 9 frames** (e.g. desaturated tidal realism, cold archival,
  warm mythic dawn, toxic green for the shrimp‑farm collapse).

**Continuity rules** — preserve appearance, environment, lighting, directional, and
emotional continuity, plus progression of movement. Do **NOT** produce random unrelated
images, disconnected compositions, or inconsistent environments.

**Quality target:** professional film pre‑visualization / cinematic concept art /
Hollywood storyboard frames / movie‑still photography — production‑ready.

**After generating, every time:**
- Save as `storyboard/storyboard-*-sheet.png`.
- Log the prompt + job ID + output URL to `../prompt-log.md`.
- Add an Images row to `../feedback-tracker.xlsx` (Status = yellow/pending).

## STEP 4 — User approval loop

After generating the sheet, always ask:

> "Are you satisfied with this storyboard? If not, you can say **'generate once more'**,
> or give specific cinematic adjustments."

Example adjustments: darker mood · more dramatic lighting · wider angles · more emotional
close‑ups · stronger rain/atmosphere · more handheld feel · slower pacing · more
aggressive framing.

If the director requests changes, **regenerate the ENTIRE 9‑frame sheet** (flash for
iteration) while preserving continuity and cinematic quality. Log each regeneration to
`../prompt-log.md` and add a tracker row. Repeat until approved.

On approval:
- Re‑render the approved sheet at `nano_banana_2` (Pro) quality if the latest was flash.
- Flip the tracker row to green and note which sheet was approved.
- **Upload the approved sheet to Higgsfield** and paste its UUID + URL into `../ref-ids.md`
  (this is the UUID Seedance jobs depend on).

## STEP 5 — Frame finalization (standalone stills)

Once approved, ask:

> "Which frames would you like to finalize as start‑frame stills?"

The director answers with frame numbers (e.g. `2`, `5`, `7` or `1, 4, 8`). For each frame,
re‑render it **standalone** with Nano Banana Pro (`nano_banana_2`, `2k`, `16:9`) that:

- preserves the **exact composition** of that frame
- preserves character/environment, lighting, and the sheet's color grading
- preserves environmental detail
- **removes the burned‑in 1–9 number** — the standalone still must be clean, with no
  numbering or grid lines, or it will bleed into the Seedance start frame

- Log to `../prompt-log.md` and add an Images row to the tracker.
- Upload to Higgsfield and paste the UUID + URL into `../ref-ids.md`, noting which scene
  beat / Seedance shot it feeds.

After each frame, ask whether more frames should be finalized. Repeat until the director
is finished.

## STEP 6 — Hand the storyboard frames to video generation

The finalized frames from STEP 5 feed Higgsfield / Seedance video generation (`../CLAUDE.md` step 5). Build each Seedance job's ref stack as follows:

- **Mandatory minimum model refs** — always keep the **storyboard sheet UUID** on every job (`--image <storyboard-sheet-uuid>`), per the main `CLAUDE.md` step 5 and `../seedance-prompt-framework.md`.

- **Selected frames → ref by asset type** — for the selected frames, if a related UUID
  exists in `../ref-ids.md`, pass it by its type: an **image UUID** via `--image`, and a
  **video UUID** via `--video` to reference it as a video frame.
