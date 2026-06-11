# Higgsfield Character Image Upload & Analysis

Process all model images in the current directory; Generate Character Sheet and Close-up Shot and Upload All
Images into Higgsfield and then Write Descriptions.
Use Higgsfield's **Nano Banana Pro** model for generating Character Sheets and Close-up Shots.

## Workflow

1. **Generate Character Sheet** → Create a character sheet based on model images. Ensure all angles/directions of the character are visible in the sheet. Save as `model-*-char-sheet.png` 
2. **Generate Close-up Shots** → Create detail close-up shots. Save as `model-*-detail-*.png`
3. **Upload Images** → Upload character sheets, close-up shots, and model images to Higgsfield
4. **Write Descriptions** → Follow `descriptions.template.md` to create `description.md`. Add `## Model *` sections per model. All in English.
5. **Write ref-ids.md** → If you do upload Charactor refs, paste the UUID and URL into `../ref-ids.md` and write a matching text description in `description.md'.

## Per-Model Section Content

- **Subject** → Brief model description
- **Model description** → Detailed analysis: mood, appearance, outfit
- **Image References** → Character sheet filename, close-up shot filename, model image filenames + UUIDs
- **Video References** → Any reference video filenames + UUIDs for the model (omit this section if none exist)

## Template Reference

From `descriptions.template.md`:

| Item | Format |
|------|--------|
| Character Sheet | `model-*-char-sheet.png` |
| Close-up Shot | `model-*-detail-*.png` |
| UUID | Asset ID uploaded to Higgsfield |

```
## Model N

**Subject:**

**Model description:**

**Image References:**
- model-N-char-sheet.png -> UUID
- model-N-detail-1.png -> UUID
- FILENAME -> UUID

**Video References:**
- FILENAME -> UUID
```

