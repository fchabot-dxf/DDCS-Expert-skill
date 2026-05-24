# Post-Processors

Two Fusion 360 post-processors for the DDCS M350.

| File | Status | Approach |
|---|---|---|
| `fanuc_DDCS_m350.cps` | **CURRENT** / preferred | Minimalist, operator-driven. G53 retracts to K6/K7-taught presets (`#601-#604`). No `#1153/#880/#1505/#2070` runtime use. No priming-bug exposure. Default-OFF M6, 3D-arc guard, no G10. |
| `Fusion360_DDCS_post-processor.cps` | **LEGACY** / reference | Maximalist with dynamic WCS-aware parking math (`#[802 + #578 * 5]`), victory dance, manual tool change. More features, more runtime dependencies. |

**Default to `fanuc_DDCS_m350.cps` for new work.** Use the legacy variant only if you specifically need its dynamic-parking or end-of-job behaviors.

### Patched in workspace copy (2026-05-12) — pending port to GitHub

1. **`M09` now emitted in `onClose()`** — fixed at L794–803 by replacing the no-op `COMMAND_COOLANT_OFF` with an explicit `writeBlock(mFormat.format(9))` gated on `useCoolant`. Mirrors the explicit-M8 pattern already in `COMMAND_START_SPINDLE`.
2. **Orphan `H01` suppressed when `useG43=false`** — fixed at L3068 by gating the `hOffset` variable on `getProperty("useG43")` so it tracks `getOffsetCode()`'s output.

Both edits are marked with `// --- CUSTOM EDIT (2026-05-12)` comments in the .cps file. Test on a single-tool job before promoting to GitHub. See [`../fusion-post-processor.md`](../fusion-post-processor.md) for full breakdown and other known concerns.
