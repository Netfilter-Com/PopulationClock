# Population Clock — Roadmap

**Status:** approved by the project owner, 2026-10-11.
**Current release:** 2.1.0 (live on the App Store). Adds Antarctica, refreshed flags, larger-text fixes.

Items are marked **verified** when checked against the repo or the app, and
**to verify** when they are a hypothesis that must be confirmed first.

## Decisions

| # | Question | Decision |
|---|---|---|
| 1 | Antarctica population | Keep **1,000** (approximate number wintering at research stations) |
| 2 | Languages | **pt-BR** first. Other languages later, if at all |
| 3 | 3.0 scope | Remove the leftover "Remove Ads" purchase, widget, share card, historical series |
| 4 | Cadence | Everything before 3.0 ships as a single **2.2** |

## 2.2 — quality, accessibility and content

Consolidates the previously proposed 2.1.1, 2.2 and 2.3.

### Corrections
- [ ] **Texts unreadable in dark mode.** *(About text and search field fixed; rest to verify)* *(cause verified in code; extent to verify with screenshots)*
  The app forces dark (`UIUserInterfaceStyle = Dark` in `PopulationClock-Info.plist`), but most of the artwork is light (`debut_light`, `aboutBox`, `patternBgInfo`). Any text that uses a system color therefore renders light on light.
  - **About:** the `UITextView` in the storyboard never sets a text color, so it takes the dark-mode default (white) over the light `aboutBox` background. *(verified in code)*
  - **Country list:** gray titles on black cells were nearly unreadable, and the search field placeholder was white on white. *(fixed: transparent cells over the light pattern, explicit search colors; iPad screenshot checked)*
  - **Alerts, HUD and any other system UI** shown over the light panels. *(to verify)*
  - **Decision to make:** keep forcing dark and set explicit colors where the artwork is light (small, safe), or move to a real light/dark theme (needs dark artwork; belongs in 3.0). Recommendation: explicit colors in 2.2.
- [x] **Country description (CIA Factbook text) has no margins on iPad.** *(fixed in `info_template_landscape.html`; iPad portrait still to check)* *(reported by the owner on iPad; cause verified in code)*
  The text is the expanded description in the info panel (`info_template_*.html`, "[Read more]" expands it in place).
  - `info_template_landscape.html` (iPad landscape): `body` has no margin and `p` has no padding, so the text touches the panel edges. This matches the report. *(verified in code)* Check iPad portrait too, which uses the 280 px column.
  - `info_template_landscape~iphone.html` has `margin: 8px 12px`, and the portrait template uses a fixed 280 px centered column, so both should be fine. Confirm on device, including a small iPhone and Display Zoom.
  - Fix: same margin/padding as the iPhone template, plus `env(safe-area-inset-*)` already present; use a `max-width` column instead of the fixed 280 px.
- [x] **About text is stale.** It says the statistics cover 2007–2015, but `Resources/data.plist` has all 210 entries at 2025. *(verified)*
- [x] **Antarctica note.** The country description now says the population is an estimate of people wintering at research stations.
- [ ] **Screens not checked with large text:** Country list, About, country info. *(to verify in the simulator; do it in the same screenshot pass as the dark-mode and margin items)*
- [ ] **Stats panel in landscape** appeared cut off under the notch in a simulator screenshot. *(to verify)*
- [ ] **Any flag still off in tone** after the 2.1.0 refresh. Flags were re-rendered from flagcdn.com. Left as is on purpose: Antarctica (drawn for the app), Afghanistan (owner's decision), Martinique (official French tricolor).

### Accessibility and layout
- [ ] **Dynamic Type** where the layout allows it (country list, About, country description). 2.1.0 only stops clipping by fixing sizes.
- [ ] **VoiceOver:** labels for flags, the clock, the Info/List buttons and the map. The map is a tappable image with no accessible equivalent today.
- [ ] **Auto Layout** in place of hard-coded frames on the screens most affected (iPad, landscape, Display Zoom).
- [ ] **Automated tests.** The repo has none. Start with data integrity (every country has a flag, name and colormap entry) and a large-text capture test.

### Localization (pt-BR)
- [x] UI strings, country names and About text in Brazilian Portuguese (`PopulationClock/pt-BR.lproj`). *(checked on iPad and on the iPhone main screen in pt-BR; iPhone Info/List panes not seen. App Store text drafted in `AppStore/pt-BR.md`)*
- [x] Country descriptions: **keep the English CIA World Factbook text** (owner's decision). The pt-BR About text says so.

### Content and data
- [ ] **Country descriptions** came from a scraper whose source URL has been dead since 2021. Decide whether to move to a live source or accept the current text. *(to verify what is current)*
- [ ] **Single yearly data update script** (World Bank) with a report of what changed. Antarctica and other manual entries live in `MANUAL_COUNTRIES` in `Scripts/data/data.py`.
- [ ] **Small territories without a map polygon.** Only Antarctica is handled (`Scripts/colormap/add_antarctica.sh`). Audit the rest. *(to verify)*

## 3.0 — new features

- [ ] **Remove the leftover "Remove Ads" purchase.** Ads are already gone. Check what the user still sees and whether the in-app purchase can be dropped. Existing purchasers must not be broken. *(to verify)*
- [ ] **Widget / Lock Screen** with the real-time world population.
- [ ] **Share card:** image with the flag and the population of a country.
- [ ] **Historical series:** population-over-time chart per country, using the data the update script already downloads.

## Notes

- Releases go through Xcode Cloud on push to `master`. The marketing version is set in `PopulationClock/PopulationClock-Info.plist`; Xcode Cloud assigns the build number.
- A new App Store version cannot be created while the previous one is waiting for review or in review. Swap the build instead (cancel the review submission, attach the new build, resubmit).
