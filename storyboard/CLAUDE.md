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
  - **Environment plates** for the scene — always, and pass **as many as possible**
    (every relevant environment plate in `../ref-ids.md`) to maximally ground consistency.
  - **Character sheet** when a character appears in the beat — this anchors identity.
    - **Mandatory minimum:** the **character sheet UUID** (`--image <char-sheet-uuid>`).
      Whenever a character is in the scene, this ref is required.
    - You may also add a **close‑up / detail** of that character to reinforce identity.
    - **Never** pass the Seedance character *sheet* grid (the grid‑of‑angles reference) —
      it bleeds multiple faces into the frames.
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

**Key rule: always generate fresh keyframes for every new storyboard sheet.** Never reuse
keyframes from a previous storyboard version — old keyframes are archived when a new sheet
is approved. `storyboard/keyframes/` must only contain frames that correspond to the
current approved sheet.

Once approved, ask:

> "Which frames would you like to finalize? For each Seedance shot, name the **start frame**
> and the **end frame** (e.g. start `2` → end `3`)."

Each Seedance shot is driven by **two** stills — a **start frame** and an **end frame** —
so the director answers in start→end pairs. For **each** frame in a pair, re‑render it
**standalone** with Nano Banana Pro (`nano_banana_2`, `2k`, `16:9`):

1. **Match the sheet** — keep the frame's exact composition, character, environment,
   lighting, and color grading.
2. **Strip the number** — remove the burned‑in 1–9 digit and any grid lines; the still must
   be clean or the number bleeds into the Seedance frame.
3. **Anchor identity & environment** — to hold continuity across frames, **always** pass the
   **character sheet** (UUID or file) as a `--image` ref, plus the relevant **environment
   plate(s)** for the scene.
4. **Keep the pair continuous** — the start and end frame of one shot must share the same
   character, wardrobe, environment, lighting, and color grading; only the boarded action,
   pose, or camera position should advance from start to end.
5. **Save & log** — save start as `storyboard/keyframes/<scene>-cut-*-start-frame.png` and
   end as `storyboard/keyframes/<scene>-cut-*-end-frame.png`, log to `../prompt-log.md`,
   add an Images row to the tracker for each.
6. **Upload** to Higgsfield, paste each UUID + URL into `../ref-ids.md`, and note which
   Seedance shot (and whether start or end) it feeds.

Then ask whether to finalize more shots. Repeat until the director is done.

## STEP 6 — Hand the frames to video generation

The finalized stills feed Seedance video generation (`../CLAUDE.md` step 5). Build each
Seedance job's ref stack like this:

1. **Storyboard sheet UUID — always** (`--image <storyboard-sheet-uuid>`). Mandatory on
   every job, and also named in the prompt text: tell the model to generate the video *from
   that storyboard sheet* — don't attach it silently.
2. **Selected frame** — if `../ref-ids.md` has a UUID for the boarded frame, pass it as the
   start frame by its type: image UUID via `--image`, video UUID via `--video`.
