# Final Cyber Fist Sprite Generation Prompt

Use this file as the authoritative prompt lock for the final player character frames. The goal is to generate polished pixel-art animation frames based on the two reference images, not simple geometric placeholder sprites.

## Reference Images

Reference A:
`art_src/concepts/player_cyber_fist_reference_v1.png`

- Full-body young male cyber fighter.
- Black long trench coat below the knees.
- Black tactical inner clothes and boots.
- Black messy hair.
- Cyan glowing cyber eye, cyan collar accents, cyan mechanical forearm details.
- Relaxed standing attitude, not a boxing guard.

Reference B:
`art_src/concepts/469e005c3f117ad7b04665cc008639cb.png`

- Cyberpunk portrait/menu mood reference.
- Dark black-blue palette, dense pixel-art rendering, glowing cyan cyber eye/core details.
- Use the mood and rendering richness only; do not copy UI text, logo, menu elements, or magenta glitch accents into the character frames.

## Hard Requirements

- The character must look like a finished hand-painted pixel-art game character, not a simple geometric construction.
- Use a consistent young male anime cyberpunk fighter in every frame.
- Black long coat is the main silhouette. The coat must reach below the knees and remain readable in motion.
- No weapons. Opening loadout is fists only.
- The attack animations use punches and cyber fist energy only.
- Idle animations must not use a fist guard, boxing pose, raised fists, or aggressive combat stance.
- Idle should show normal standing and subtle breathing/body bob only.
- Idle may use more frames for smoothness: generate 12 frames for `idle` and 12 frames for `combat_idle`.
- Use cyan/electric-blue accents only: cyber eye, collar edge, mechanical forearm, and fist energy.
- No pink, magenta, purple, rose, red neon, or warm glitch accents anywhere on the character or effects.
- No labels, text, frame numbers, UI, grid lines, borders, shadows, floor plane, watermark, or background art.
- Use a perfectly flat solid `#00ff00` chroma-key background for local transparency removal.
- The background must be one uniform green color with no gradients, no lighting variation, no shadows, and no texture.
- Every frame must contain exactly one complete character pose unless the animation explicitly includes a cyan fist energy effect.
- Do not crop heads, feet, coat tails, fists, or energy bursts.
- The face must stay complete and readable in every frame. Do not let hair, glow, mask shapes, motion blur, green background, or low-resolution distortion erase half of the face.
- At 96x96 crop size, the head must still show a clear face plane, visible skin area, black hair silhouette, and one small cyan cyber eye. The cyan eye glow must not cover or replace the whole face.
- Keep generous padding around each frame so later 96x96 crops are safe.
- Keep the same character scale, camera angle, and 3/4 side-facing direction across all strips.

## Face Readability Lock

This requirement is especially important for punch and skill frames, where the previous generated sheet distorted the face.

- The face must be a complete anime pixel-art face, not a broken mask, skull shape, blank dark patch, or smeared glow.
- Keep enough visible skin-tone pixels for the cheek, nose/mouth area, and jaw line.
- Hair may partly cover the forehead, but it must not hide the whole face.
- The cyan cyber eye should be a small readable accent, not a large blob that consumes the face.
- Do not use heavy black shadows over the face.
- Do not let the green chroma-key background cut through the hairline, cheek, jaw, or neck.
- If a dynamic punch pose turns the head, keep a consistent 3/4 face angle rather than a collapsed profile.
- Prefer a slightly calmer pose over an extreme pose if the extreme pose damages face readability.
- During local review, reject any frame where the face appears incomplete, melted, overly masked, or unrecognizable at game size.

## Production Method

Do not generate one giant multi-row animation sheet. The previous multi-row sheet caused mixed/misaligned action rows. Generate one animation strip at a time.

For every strip:

- One horizontal row only.
- Transparent-ready flat `#00ff00` background.
- Evenly spaced frames from left to right.
- No grid lines or labels.
- Same character scale in every frame.
- Each frame should fit a 96x96 game cell after cropping.
- Leave at least 8-12 pixels of visual padding around the character in each mental cell.
- If an animation has many frames, keep the image as a single clean horizontal strip and avoid wrapping into a second row.

## Master Style Prompt

Use this text at the beginning of every generation request:

```text
Create a production-quality hand-painted pixel-art animation strip for a 2D action game character, using the attached/reference full-body black long-coat cyber fighter and cyberpunk portrait mood image as the visual source.

Character design: young male anime cyberpunk fighter, black messy hair, black long trench coat reaching below the knees, black tactical shirt and pants, black boots, cyan glowing cyber eye, subtle cyan collar edge lights, metallic cyber right forearm with cyan edge lights. Fist-based combat only, no weapons. The black long coat must be the dominant silhouette in every frame.

Rendering style: detailed pixel art, rich clothing folds, readable coat panels, boots, hair, face, mechanical forearm, and cyan glow details. Not vector art, not a flat silhouette, not simple geometry, not a blocky construction placeholder.

Face lock: every frame must preserve a complete readable anime face at 96x96 game size, with visible skin-tone cheek/jaw/nose area, black hair silhouette, and one small cyan cyber eye. Do not let hair, black shadows, eye glow, mask shapes, motion blur, or chroma-key green remove or distort the face.

Palette: mostly black, charcoal, dark cool gray, steel gray, and cyan/electric blue. Absolutely no pink, magenta, purple, rose, red neon, orange glitch, or warm neon accents.

Output format: one clean horizontal animation strip on a perfectly flat solid #00ff00 chroma-key background. No text, no labels, no frame numbers, no frame borders, no grid, no UI, no watermark, no shadows, no floor plane, no background art. Keep each frame fully separated with generous padding. Every frame must fit a 96x96 game sprite cell after cropping.
```

## Animation Strip Prompts

### idle

```text
Animation: idle, 12 frames in one horizontal row.

The character stands normally and calmly, arms relaxed down at the sides, shoulders relaxed, coat hanging naturally. No fist guard, no boxing stance, no raised fists, no attack anticipation. Only subtle breathing: small chest rise/fall, tiny head/shoulder bob, slight coat hem movement. Keep feet planted and body mostly still.
```

### combat_idle

```text
Animation: combat_idle, 12 frames in one horizontal row.

Use the same relaxed standing/breathing idle as the normal idle. It may feel alert through eye glow and posture, but hands stay low and relaxed. No fist guard, no raised fists, no crouched fighting stance, no attack windup. Subtle breathing and slight coat movement only.
```

### run

```text
Animation: run, 8 frames in one horizontal row.

Side-facing 3/4 run toward the right. Natural action-game running cycle, fists empty, black long coat trailing behind with readable coat tails. Keep cyan accents subtle and consistent. Do not let coat tails or feet crop out.
```

### combat_run

```text
Animation: combat_run, 10 frames in one horizontal row.

Faster combat run toward the right, empty fists, black long coat trailing, cyber right forearm visible. Dynamic but readable. No weapons. Cyan accents only on eye, collar, mechanical arm, and tiny motion sparks if needed.
```

### jump

```text
Animation: jump, 3 frames in one horizontal row.

Takeoff, airborne rise, peak. Empty fists. Long coat lifts naturally. Character remains fully visible inside each frame.
```

### fall

```text
Animation: fall, 3 frames in one horizontal row.

Airborne falling poses. Coat and hair move upward from falling motion. Empty fists. No ground contact, no floor shadow.
```

### dash

```text
Animation: dash, 5 frames in one horizontal row.

Fast rightward dash with body leaning forward and coat streaming back. Use cyan speed streaks only if needed, and keep them inside the frame with padding. No pink/magenta afterimages.
```

### hit

```text
Animation: hit, 3 frames in one horizontal row.

The character recoils from damage while staying upright. Black long coat and mechanical forearm remain readable. No blood, no red flashes, no magenta effects.
```

### death

```text
Animation: death, 8 frames in one horizontal row.

Clear single sequence from stagger to collapse to lying still. Do not mix unrelated poses in the same cell. Each frame contains one complete character pose only. The character gradually falls and ends lying down. No cropped body parts, no duplicated characters, no extra fragments, no floor shadow.
```

### punch_1

```text
Animation: punch_1, 12 frames in one horizontal row.

Basic rightward punch combo starter: relaxed/ready transition, windup, punch extension, small cyan fist spark, recovery. Fists only, no weapons. The character should not become a simple stick/geometric form; keep coat folds, hair, boots, face, and mechanical arm detailed.

Face must stay complete and readable through every punch frame. Avoid extreme head tilt or shadow that hides the face.
```

### punch_2

```text
Animation: punch_2, 12 frames in one horizontal row.

Alternate punch combo continuation with a different arm/body rhythm. Fists only. Cyan impact energy is allowed only at the fist and must stay blue/cyan, never pink or magenta. Keep the long black coat silhouette.

Face must stay complete and readable through every punch frame. Do not let the cyan eye glow become a mask or erase the cheek/jaw.
```

### punch_3

```text
Animation: punch_3, 14 frames in one horizontal row.

Heavier finishing punch. More body twist and coat swing, but the character remains readable and consistent. Fists only, cyan impact effect only, no weapons, no pink/magenta.

Even during the strongest pose, the head must show a complete readable face. Prefer a less extreme body twist if it keeps the face intact.
```

### punch_skill

```text
Animation: punch_skill, 14 frames in one horizontal row.

Cyber fist burst skill. The mechanical right forearm charges and releases a cyan/electric-blue fist energy burst. No weapon shapes, no blade, no gun, no beam weapon; it should read as fist energy. No pink, magenta, purple, or red. Keep character and energy fully inside frame padding.

Face must remain visible and complete while the fist energy is active. Energy effects must not cover the head or face.
```

## Negative Prompt

```text
Do not create simple geometric placeholder sprites. Do not create stick figures, block mannequins, flat vector shapes, chibi toy proportions, tiny unreadable silhouettes, inconsistent costumes, different characters, weapons, swords, guns, beams as weapons, UI, labels, text, frame numbers, frame borders, grid lines, shadows, floor plane, scenery, cropped limbs, cropped coat tails, multiple characters per cell, mixed action rows, duplicate body fragments, pink, magenta, purple, rose neon, red neon, orange glitch, warm neon accents, or gray-background concept poses.
Do not create incomplete faces, melted faces, mask-like blank faces, skull-like faces, faces hidden by hair, faces swallowed by cyan eye glow, green background holes in the face/hair, or punch poses where the head becomes unreadable.
```

## Acceptance Checklist

- The output is generated strip-by-strip, not as one giant multi-row sheet.
- `idle` and `combat_idle` each have 12 relaxed standing/breathing frames.
- Idle frames do not show raised fists or a boxing guard.
- Every animation strip has exactly the requested number of frames.
- Every frame contains one complete character pose with no accidental extra cropped figure parts.
- Character design matches Reference A: black long coat, black clothes, cyan cyber eye/collar/forearm.
- Face is complete and readable in every frame, especially punch and skill frames.
- Rendering is detailed pixel art, not simple geometry.
- No pink/magenta/purple pixels are visible in character or effects.
- Chroma-key background is flat `#00ff00` and can be removed cleanly.
- Cropped 96x96 runtime frames keep head, feet, coat tails, fists, and cyan effects inside the cell.
