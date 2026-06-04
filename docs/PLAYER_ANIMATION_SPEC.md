# Player Animation Spec

Reference source:

- `art_src/concepts/player_cyber_fist_reference_v1.png`
- `art_src/generated/player_yuan_fist_pass/preview_sheet.png`
- `art_src/generated/player_yuan_fist_pass/runtime_frame_audit.csv`

Appearance rules for future frame generation:

1. Character reads as a fresh cyberpunk fist fighter, not any previous Yuan clone or placeholder variant.
2. Outfit stays intact: black coat or cropped cyber jacket, black inner layers, dark pants, heavy boots.
3. Right forearm has a compact cyber shell only. It must stay sleek and human-scale.
4. Left arm remains normal and both hands read as fists.
5. Face keeps one cyan cyber eye cue, with no external visor frame.
6. No exposed chest core, no ripped coat, no oversized arm armor, no weapon, and no proxy body.
7. Cyan and restrained magenta light cues support cyberpunk readability without becoming blade trails.
8. Final in-game frames target game-scale pixel art, not high-definition concept-pixel rendering.
9. Runtime frames must be generated as isolated 96x96 frames or clean strips. Do not crop from multi-pose boards.

Animation readability rules:

1. Keep the coat silhouette readable with large simple shapes.
2. Keep the right forearm shell visible in idle and punch wind-up.
3. Use fists as the opening combat language; the default attack chain must resolve to `punch_1`, `punch_2`, `punch_3`, and `punch_skill`.
4. Idle and `combat_idle` must be a normal standing idle animation, with arms relaxed and no raised fist guard.
5. Avoid micro-detail that will collapse in pixel frames.
6. Preserve three landmarks in every frame: hair silhouette, embedded blue left eye, right forearm shell.
7. Final runtime frames still obey the project frame spec: `96x96` canvas, body roughly `48x72`.
8. `runtime_frame_audit.csv` must report `Suspect frames: 0` before handoff.
