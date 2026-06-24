# Higgsfield Environment Image Upload & Analysis

Process all environment images in the current directory; Upload All Images into Higgsfield and then Write Descriptions.

## Workflow

1. **Upload Images** → Upload every environment image in the current directory to Higgsfield
2. **Analyze Images** → Analyze the content of each image in detail
3. **Write Descriptions** → Follow `descriptions.template.md` to create `descriptions.md`. Add an `## Environment N -- @NAME` section per image. All in English.
4. **Write ref-ids.md** → If you do upload environment refs, paste the UUID and URL into `../ref-ids.md` and write a matching text description in `descriptions.md'.

## Per-Environment Section Content

- **NAME** → Environment tag name. Keep name to letters, numbers, hyphens (-), and underscores (_). Avoid spaces, commas, or periods within tag name
- **FILENAME** → Image file name
- **TITLE** → Image title
- **UUID** → Higgsfield asset ID of the uploaded image
- **Text description** → Detailed analysis: texture, lighting colour, atmospheric density, scale
- **Best for** → Recommended scenes this environment suits

