# Population Clock — Roadmap

**Updated:** 2026-10-13.
**Live on the App Store:** 2.1.0 (Antarctica, refreshed flags, larger-text fixes).
**Approved by App Review:** 2.2.0 (build 20, commit `78ea911`, submitted 2026-10-12, approved 2026-10-13). Release it from App Store Connect if it is set to manual release; it becomes the live version once released.

Items are marked **verified** when checked against the repo or the app, and
**to verify** when they are a hypothesis that must be confirmed first.

## Decisions

| # | Question | Decision |
|---|---|---|
| 1 | Antarctica population | Keep **1,000** (approximate number wintering at research stations) |
| 2 | Languages | **pt-BR** first. Other languages later, if at all |
| 3 | 3.0 scope | Remove the leftover "Remove Ads" purchase, widget, share card, historical series |
| 4 | Cadence | Everything before 3.0 ships as a single **2.2** |
| 5 | CIA descriptions | Keep the English text, frozen (the Factbook was discontinued in Feb 2026). A living source is a 3.0 question |
| 6 | iPad multitasking | Opt out with `UIRequiresFullScreen`; no Auto Layout rewrite for now |
| 7 | Share/About in iPad landscape | Buttons in the top bar |
| 8 | Taiwan, Holy See, small territories | Manual entries (rounded estimates), flagged as estimates in About |
| 9 | Electricity consumption | World Bank (kWh per capita x population), frozen Factbook figure as fallback |
| 10 | App Store listing language | en-US only for 2.2.0 (a pt-BR listing needs its own screenshots) |

## 2.2.0 — approved

### What is in it
- **pt-BR localization:** interface, statistics, 249 country names, About text (`PopulationClock/pt-BR.lproj`). The iPad storyboard texts are translated at runtime (`UIView+NFLocalization`) because the storyboard strings were not applied at build time.
- **Accessibility:** VoiceOver labels for the clock (one element, value = the number), map, flags, arrows, carousel buttons and logo links; the selected country is announced. Dynamic Type in the country list, search, About, clock label and description/statistics panel, with caps where the layout is artwork.
- **Dark mode:** explicit colors where the artwork is light (About, search field, country list) and a light text color on the dark iPad landscape panel.
- **Layout fixes:** About dialog was cut off on iPhone and too small for the text; iPad description margins; Share/About in the iPad landscape top bar (with the title making room for longer languages); `UIRequiresFullScreen`.
- **Crash fixes:** sharing crashed on iPad (popover without a source) and on every device (`Icon-72.png` no longer exists, so a nil item raised an exception). Both were already in 2.1.0.
- **Data:** Taiwan, the Holy See and 15 small territories now have entries; coordinates added for South Sudan, Saint Martin and Saint Barthélemy (births and deaths never flashed there); electricity from the World Bank; CIA description HTML cleaned.
- **Tooling:** UI walkthrough tests, data consistency check, single yearly update command (see Notes).

### Open follow-ups (candidates for a 2.2.x or 2.3)
- [ ] **Validate the figures of the 17 manual entries** (`MANUAL_COUNTRIES` in `Scripts/data/data.py`). They are rounded estimates for 2021-2024 written without a cited source; the most uncertain are the birth/death rates of the small islands and the population of Saint Helena. *(owner)*
- [ ] **Forest area revision.** On 2026-10-12 the dry run showed the World Bank forest-area series changed in 199 countries (Vanuatu 36% -> 75%, Central African Republic 36% -> 72%). Read the indicator notes before running `update_data.py --apply`.
- [ ] **VoiceOver by ear on a real device.** The tests prove the labels exist; the reading order and how often the clock value is announced have to be heard.
- [ ] **pt-BR App Store listing.** Text is ready in `AppStore/pt-BR.md`; it needs pt-BR screenshots (and an app-info name) before it can be added.
- [ ] **Mayotte** has a map polygon and no data because the app has no description text for it (the CIA text is gone with the Factbook). Write one or leave it. It is the only polygon without data left (`check_data.py` lists them); territories with data but no polygon are reachable from the list only.
- [ ] **Stats panel under the notch in iPhone landscape** was a hypothesis from one screenshot; the iPhone walkthrough shows the panel whole. Close it unless it shows up on a device.
- [ ] **Remaining flag tones.** Flags were re-rendered from flagcdn.com in 2.1.0. Left on purpose: Antarctica (drawn for the app), Afghanistan (owner's decision), Martinique (official French tricolor).
- [ ] **Dangling `Icon-72.png` / `Icon-72@2x.png` references** in `project.pbxproj` (files do not exist). Harmless now that nothing loads them; clean up when touching the project.
- [ ] **Data check in CI.** `Scripts/check_data.py` is not wired into Xcode Cloud (`ci_pre_xcodebuild.sh` would do it, at the cost of failing builds on data errors).
- [ ] **Alerts, HUD and other system UI** over the light panels in dark mode were not reviewed.
- [ ] **Dynamic Type limits.** At the largest accessibility size the description panel is capped at 30 px and the list at 30 pt; toolbar buttons, segmented control, legend and flip-clock stay fixed. Revisit if users report it.

## 3.0 — new features

- [ ] **Remove the leftover "Remove Ads" purchase.** Ads are already gone. Check what the user still sees and whether the in-app purchase can be dropped. Existing purchasers must not be broken. *(to verify)*
- [ ] **Widget / Lock Screen** with the real-time world population.
- [ ] **Share card:** image with the flag and the population of a country (sharing is text only now).
- [ ] **Historical series:** population-over-time chart per country, using the data the update script already downloads.
- [ ] **Living source for country descriptions.** The Factbook text is frozen at January 2026 and is English only. Options considered: an Open Factbook community fork, or Wikipedia (CC BY-SA, needs attribution). Decide with the rest of 3.0.
- [ ] **Auto Layout / multitasking.** Only if Split View and Stage Manager on iPad are wanted: migrate `MainView` and the info panels, then drop `UIRequiresFullScreen`.
- [ ] **More languages** (see decision 2).

## Notes

- **Releases:** Xcode Cloud builds on push to `master` using the shared `PopulationClock` scheme. The marketing version is in `PopulationClock/PopulationClock-Info.plist`; Xcode Cloud assigns the build number. Keep `PopulationClock.xcscheme` in `xcshareddata/xcschemes`: when that folder held only the UI tests scheme, build 17 failed with "A scheme called PopulationClock does not exist".
- **App Store Connect:** versions and review submissions can be driven through the API (create version, set the localization's `whatsNew`, attach the build, create a `reviewSubmission` with an item for the version, then `submitted: true`). A new version cannot be created while the previous one is waiting for review; swap the build instead (cancel the submission, attach the new build, resubmit).
- **UI tests:** scheme `PopulationClockUITests`. Run `TEST_RUNNER_SCREENSHOT_DIR=<dir> xcodebuild test -workspace PopulationClock.xcworkspace -scheme PopulationClockUITests -destination 'id=<simulator>'`. Scenarios: en/pt-BR x default/largest accessibility size, VoiceOver labels, Share (iPhone, iPad portrait and landscape), iPad landscape in en and pt-BR (checks that the title does not cover Share). The simulator's own text size is not reset by the tests: check it with `xcrun simctl ui <id> content_size` before trusting a "default" run.
- **Data:** `python3 Scripts/check_data.py` (consistency, exits 1 on errors) and `python3 Scripts/update_data.py [--apply]` (World Bank refresh with a change report). `Resources/Description.strings` is the source of truth for descriptions; `Scripts/description/scrapeCIA.py` is legacy and refuses to run without `--force`.
- **Colormap:** run `Scripts/colormap/add_antarctica.sh` after `colormap.sh`, or Antarctica stops being tappable.
