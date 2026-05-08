# Post-Processors

Two Fusion 360 post-processors for the DDCS M350.

| File | Status | Approach |
|---|---|---|
| `fanuc_DDCS_m350.cps` | **CURRENT** / preferred | Minimalist, operator-driven. G53 retracts to K6/K7-taught presets (`#601-#604`). No `#1153/#880/#1505/#2070` runtime use. No priming-bug exposure. Default-OFF M6, 3D-arc guard, no G10. |
| `Fusion360_DDCS_post-processor.cps` | **LEGACY** / reference | Maximalist with dynamic WCS-aware parking math (`#[802 + #578 * 5]`), victory dance, manual tool change. More features, more runtime dependencies. |

**Default to `fanuc_DDCS_m350.cps` for new work.** Use the legacy variant only if you specifically need its dynamic-parking or end-of-job behaviors.

See [`../fusion-post-processor.md`](../fusion-post-processor.md) for the full breakdown, including line references and known concerns.
