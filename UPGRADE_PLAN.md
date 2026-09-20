# Population Clock — iOS 27 Modernization & Data Refresh Plan

**Audience:** an implementing agent (Sonnet) running in one session, in this repo.
**Status of repo at time of writing:** branch `master`, clean, last commit `cf9e125` (v1.6.0).
**Verified against the real repo on 2026-09-19** — every claim below was checked, not assumed.

---

## 0. Read this first — ground truth about the project

| Thing | Current state |
|---|---|
| Language | Objective-C, 5,426 lines across `PopulationClock/*.{h,m}` |
| Deployment target | **iOS 8.0** (`IPHONEOS_DEPLOYMENT_TARGET = 8.0`, 4 places in `project.pbxproj`) |
| Xcode project format | `objectVersion = 46`, `compatibilityVersion = "Xcode 3.2"`, `LastUpgradeCheck = 0830` |
| Layout | **No Auto Layout at all** (0 constraints in either storyboard) — springs & struts + hardcoded `CGRectMake` |
| Storyboards | `PopulationClock/en.lproj/MainStoryboard.storyboard` (iPad), `PopulationClock/MainStoryboard_iPhone.storyboard` |
| Launch | **Launch images** (`LaunchImage.launchimage`), no `LaunchScreen.storyboard` |
| Dependencies | CocoaPods 1.2.1 lockfile; `Pods/` is **committed to the repo** |
| Web rendering | `UIWebView` (`CountryInfoWebView.h:9`, `CountryInfoViewController.m:20`) |
| Ads | Google-Mobile-Ads-SDK **7.21.0** (2017), fat `.framework`, archs `armv7 i386 x86_64 arm64` — **no arm64-simulator slice**, will not link on Apple Silicon |
| IAP | StoreKit 1 (`SKPaymentQueue`), product `REMOVE_ADS_POPCLOCK` |
| Data | `Resources/data.plist` — 209 countries, **all frozen at `populationYear = 2017`** |
| Descriptions | `Resources/Description.strings` — UTF-16BE, scraped from a CIA URL scheme dead since 2021 |
| Installed toolchain | **Xcode 16.4 (iOS 18.5 SDK)**, CocoaPods 1.8.3, Python 3.14.7 |

**Current build result** (`xcodebuild -workspace PopulationClock.xcworkspace -scheme PopulationClock -sdk iphonesimulator ...`):

```
Resources/Description.strings:1:1: error: could not decode input file using specified encoding:
Unicode (UTF-8), and the file contents appear to be encoded in Unicode (UTF-16)
** BUILD FAILED **
```

Note: **zero source files were compiled** before this failure (`CompileC` count = 0). Do not assume the
Objective-C sources are clean — you have not seen their errors yet. Expect a second wave after Phase 1.

### Decisions already made by the project owner — do not re-litigate

1. **Modernize the Objective-C in place.** No Swift rewrite, no SwiftUI. Keep the storyboards.
2. **Drop ads entirely.** Remove Google-Mobile-Ads-SDK and Appirater. Keep the "Remove Ads" IAP as a
   restore-only stub so existing purchasers are not broken.
3. **Full data refresh** — World Bank indicators *and* country descriptions.

### The iOS 27 caveat — read carefully

The machine has **Xcode 16.4 / iOS 18.5 SDK**. You cannot build against an iOS 27 SDK with it.
Details of iOS 27 postdate this plan's author's knowledge; **do not invent iOS 27 API names, symbols,
or behaviors.**

In Phase 0 you will detect the newest installed SDK and target that. Every instruction below is written
to be SDK-version-agnostic: nothing depends on an iOS-27-only API. If a newer Xcode is present, use it;
if not, build against 18.5 and leave the project correct and forward-compatible. **Record which SDK you
actually built against in your final report.**

### Rules of engagement

- Work on a branch: `git checkout -b ios27-modernization`.
- **Commit after each phase** with the phase name in the message. Small commits, not one giant one.
- After every phase, run the Phase Gate build command and **do not proceed while it fails**.
- If a step is blocked (needs an Apple Developer account, a signing identity, a decision only the owner
  can make), **skip it, finish everything else, and list it explicitly in your final report.** Do not
  silently narrow scope.
- Do not delete `Resources/data.plist` or `Resources/Description.strings` until their replacements are
  generated and verified — regenerate to a temp path first, diff, then swap.

**Phase Gate command** (used throughout; substitute the SDK you selected in Phase 0):

```bash
cd /Users/ppaulojr/git/iPhone/PopulationClock
xcodebuild -workspace PopulationClock.xcworkspace -scheme PopulationClock \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | tail -40
```

---

## Phase 0 — Toolchain and baseline

1. Detect the toolchain:
   ```bash
   xcodebuild -version
   xcodebuild -showsdks | grep -i iphoneos
   ls /Applications | grep -i "^Xcode"
   ```
   Pick the **highest installed iOS SDK**. Call it `$MAXSDK`. If `$MAXSDK` ≥ 27, target iOS 27 as the
   owner asked. If not, proceed with `$MAXSDK` and flag the gap in your report — do not stall.

2. Record a baseline: `git log -1`, current build failure, `xcrun simctl list devices available | head -20`.

3. Create the branch. Commit nothing yet.

**Gate:** you can state the exact SDK version you will build against.

---

## Phase 1 — Make it build at all

This phase is mechanical. Goal: a successful simulator build, nothing more.

1. **Fix `Resources/Description.strings` encoding.** It is UTF-16BE. Either convert it to UTF-8 or tell
   Xcode its encoding. Prefer conversion (Phase 5 regenerates this file as UTF-8 anyway):
   ```bash
   iconv -f UTF-16 -t UTF-8 Resources/Description.strings > /tmp/desc.utf8 && \
     mv /tmp/desc.utf8 Resources/Description.strings
   file Resources/Description.strings   # expect: UTF-8 Unicode text
   ```
   Then verify the `PBXFileReference` for it in `project.pbxproj` has no stale
   `fileEncoding` attribute pointing at UTF-16 (encoding 10); set it to 4 (UTF-8) or remove it.

2. **Raise the deployment target.** Set `IPHONEOS_DEPLOYMENT_TARGET = 15.0` in all 4 occurrences in
   `PopulationClock.xcodeproj/project.pbxproj`. (15.0, not higher: it is the floor that current
   tooling accepts without forcing further API churn, and it drops all the 32-bit-era baggage.)

3. **Remove 32-bit / legacy device requirements** from `PopulationClock/PopulationClock-Info.plist`:
   - Delete the `UIRequiredDeviceCapabilities` array containing `armv7` (this alone causes App Store
     rejection today — arm64 only).
   - Delete `UIPrerenderedIcon` (no-op since iOS 7).
   - Delete `CFBundleSignature` and the empty `CFBundleIcons` / `CFBundleIcons~ipad` dicts.

4. **Raise `LastUpgradeCheck`** to match the Xcode you are using, and let Xcode's project format stay at
   `objectVersion = 46` unless a build error demands otherwise (gratuitous format churn makes review hard).

5. **Rip out the ad SDK and Appirater** (owner decision #2):
   - `Podfile`: bump `platform :ios, '15.0'`; remove `pod 'Google-Mobile-Ads-SDK'` and `pod 'Appirater'`.
     Keep `MBProgressHUD` (bump to `~> 1.2`) and `SBTickerView`. **Note:** `SBTickerView` is an abandoned
     2011 pod with a deployment target of 4.3 — if it fails to build, vendor its two source files directly
     into `PopulationClock/` rather than fighting the podspec, and say so in your report.
   - Delete `PopulationClock/AdManager.{h,m}` and remove them from `project.pbxproj`.
   - `PopulationClock/CountryListViewController.{h,m}`: remove `GADBannerViewDelegate` from the protocol
     list (`.h:15`), the `GADBannerView *_adView` ivar (`.m:59`), and `adViewDidReceiveAd:` (`.m:434`) plus
     every call site and the layout space reserved for the banner.
   - `PopulationClock/MainViewController.m:25`: remove `GADBannerView *_adView` and its call sites.
   - `PopulationClock/AppDelegate.m`: remove `#import "Appirater.h"` and the five `Appirater` setup lines.
     Replace with a StoreKit review request — see Phase 3.
   - `pod install` (or `pod deintegrate && pod install` if the workspace is stale). Commit the updated
     `Podfile.lock` and the changed `Pods/` tree (this repo commits `Pods/`; keep that convention).

6. **Remove the Twitter framework.** `PopulationClock/UIViewController+NFSharing.m:9` imports
   `<Twitter/Twitter.h>` — the framework is a dead stub. Delete the import; the method already uses
   `UIActivityViewController`. Also delete the `NSClassFromString(@"UIActivityViewController")` guard
   and its `assert(NO)` fallback (it has been unconditionally true since iOS 6), and remove
   `Twitter.framework` from the link phase in `project.pbxproj`.

7. Build. Fix whatever falls out. **Expect a wave of errors here** — this is the first time the sources
   have actually been compiled. Common ones in code of this vintage: implicit `id` conversions, missing
   `__bridge` casts, `NSInteger`/`int` format-specifier warnings escalated to errors.

**Gate:** `** BUILD SUCCEEDED **` on the simulator.
**Commit:** `Phase 1: build against modern SDK, drop ads and legacy device requirements`

---

## Phase 2 — Replace removed/rejected APIs

1. **`UIWebView` → `WKWebView`.** This is non-negotiable: App Store Connect has rejected binaries
   containing `UIWebView` symbols since December 2020. (It still exists in the 18.5 SDK, marked
   `API_DEPRECATED(...ios(2.0, 12.0))`, so the compiler will *not* stop you — the App Store will.)
   - `PopulationClock/CountryInfoWebView.h:9` — `@interface CountryInfoWebView : UIWebView` → `: WKWebView`.
   - `PopulationClock/CountryInfoWebView.m` (244 lines) — port delegate methods:
     `UIWebViewDelegate` → `WKNavigationDelegate`;
     `webView:shouldStartLoadWithRequest:navigationType:` → `webView:decidePolicyForNavigationAction:decisionHandler:`;
     `stringByEvaluatingJavaScriptFromString:` → `evaluateJavaScript:completionHandler:` (**now async** —
     any code reading its return value needs restructuring into the completion handler);
     `loadHTMLString:baseURL:` keeps the same name.
   - `PopulationClock/CountryInfoViewController.m:20` — the `IBOutlet __weak UIWebView *_webView`.
     **`WKWebView` cannot be instantiated from a storyboard on old-format storyboards reliably** — if the
     outlet misbehaves, create it in code and pin it with constraints instead.
   - Update both storyboards' web view scenes accordingly.
   - Verify: `grep -rn "UIWebView" PopulationClock/` must return nothing.

2. **`[[UIApplication sharedApplication] openURL:]` → `openURL:options:completionHandler:`**
   at `PopulationClock/AboutViewController.m:84` and `:89`.

3. **`[UIApplication sharedApplication].statusBarOrientation`** is deprecated and unreliable on modern
   devices. It appears in 7 places:
   `CountryInfoWebView.m:92,175,203`, `CountryInfoViewController.m:109`, `ClockViewController.m:66`,
   `MainView.m:102`, `CountryListViewController.m:187,221`, `TopBarView.m:73`.
   Replace each with the owning view's window scene:
   `self.window.windowScene.interfaceOrientation`, or — better where the code is really asking
   "am I wide or tall?" — switch to `UITraitCollection` size classes / comparing `bounds.size`.
   Read each call site; several are doing layout math that size classes express more simply.

4. **`[UIApplication sharedApplication].keyWindow`** at `CountryListViewController.m:402` — deprecated.
   Use the view's own `self.view.window`, or resolve the active scene's key window.

5. **`globals.h`** defines `SYSTEM_VERSION_LESS_THAN`, used in `AppDelegate.m` to guard an iOS-6 bar-button
   appearance hack. Delete the macro and the dead branch.

**Gate:** builds clean; `grep -rn "UIWebView\|statusBarOrientation\|keyWindow" PopulationClock/` is empty.
**Commit:** `Phase 2: WKWebView migration and removal of deprecated UIKit APIs`

---

## Phase 3 — Monetization stub and StoreKit

Per owner decision #2 — ads gone, purchase path preserved.

1. **`PopulationClock/InAppPurchaseManager.{h,m}`** (205 lines, StoreKit 1). `SKPaymentQueue` is
   deprecated but still functional, and StoreKit 2 is Swift-only — which conflicts with decision #1
   (no Swift). **Keep StoreKit 1**, but:
   - Keep `REMOVE_ADS_POPCLOCK` product loading and the `removeAds` `NSUserDefaults` flag so existing
     purchasers keep their entitlement.
   - Keep the restore-purchases path.
   - Since there are no ads to remove, the purchase no longer has a user-visible effect. **Hide the
     "Remove Ads" purchase UI** (do not offer a new sale) but leave restore working. Find the UI entry
     point in `AboutViewController` / `ModalDialogViewController` and gate it.
   - Fix the typo'd constant `InAppPurchaseManagerFaieldToRetrieveProducts` → `...FailedToRetrieve...`
     while you are in there (it is referenced in `.m:12` and its call sites).
   - Add a clear `TODO` noting StoreKit 2 migration requires introducing Swift, deferred by decision.

2. **Replace Appirater** (removed in Phase 1) with StoreKit's native review prompt in `AppDelegate.m`:
   `#import <StoreKit/StoreKit.h>` and request a review via `SKStoreReviewController` on the active
   window scene, rate-limited by a launch counter in `NSUserDefaults` (mirror the old policy:
   5 days / 7 uses). App ID for reference: `590689957`.

3. **Privacy manifest.** Even with ads gone, the app still touches `NSUserDefaults`, which is a
   "required reason API." Add `PopulationClock/PrivacyInfo.xcprivacy` declaring
   `NSPrivacyAccessedAPICategoryUserDefaults` with reason code `CA92.1`, `NSPrivacyTracking` = false,
   and empty collected-data / tracking-domain arrays. Add it to the Copy Bundle Resources phase.
   Verify no `AdSupport` / `AppTrackingTransparency` linkage remains:
   `grep -n "AdSupport" PopulationClock.xcodeproj/project.pbxproj` — remove the framework reference.

**Gate:** builds clean; app launches in the simulator without a StoreKit crash.
**Commit:** `Phase 3: StoreKit review prompt, IAP restore-only stub, privacy manifest`

---

## Phase 4 — Modern device layout

This is the largest UI phase. The app was built for a 1024×768 non-Retina iPad and a 3.5" iPhone.

1. **Launch screen.** Delete `LaunchImage.launchimage` from `PopulationClock/Images.xcassets` and the
   `ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME` build setting (2 occurrences, `project.pbxproj:2886,2909`).
   Add `LaunchScreen.storyboard` (solid app-background color plus the app logo, constrained to center)
   and set `UILaunchStoryboardName` in `PopulationClock-Info.plist`.
   **Without this the app is letterboxed on every modern device** and your layout work will be invisible.
   Also delete the now-unused root-level `Default*.png` files (7 files, ~4.5 MB).

2. **App icon.** `AppIcon.appiconset` predates the single 1024×1024 icon format and is missing modern
   sizes. Regenerate `Contents.json` for a single-size 1024 icon (plus dark/tinted variants if the
   selected SDK supports them — check the SDK, do not assume). Source art: `iTunesArtwork.png` (1024×1024).

3. **Orientation policy.** `PopulationClock-Info.plist` currently declares iPhone as **landscape-only**
   and `UIRequiresFullScreen = YES`.
   - Keep the landscape-only iPhone policy (the whole iPhone UI is built around it) — but verify it is
     still accepted by the selected SDK.
   - `UIRequiresFullScreen = YES` blocks iPad multitasking and is increasingly penalized. **Attempt to
     remove it.** If the iPad layout breaks irreparably in Split View within this session, put it back
     and report that as deferred work rather than shipping a broken iPad layout.

4. **Safe areas.** Every hardcoded frame needs auditing — there are 27 `CGRectMake` / magic-number sites
   across `PopulationClock/*.m`. Priority order (biggest files first, these are where the layout lives):
   - `CountryListViewController.m` (446 lines)
   - `MapImageView.m` (342) — **careful**: this does pixel-level hit testing against `colormap.png` via
     `CountryDetector`. Its coordinate math must stay exact or country selection silently breaks.
   - `NFCarouselViewController.m` (332) — custom paging container, drives the whole iPhone navigation.
   - `MainView.m` (271), `CountryCarouselView.m` (243), `PopulationClockView.m` (193)

   Convert to Auto Layout with `safeAreaLayoutGuide` where practical. Where a view is genuinely
   image-driven and must stay pixel-exact (the map), keep manual layout but derive it from
   `view.safeAreaInsets` instead of constants.

5. **Dark Mode.** `PopulationClock/UIColor+NFAppColors.{h,m}` returns fixed colors. The app's visual
   identity is a dark textured skin, so a full Dark Mode adaptation is not required — but the app must
   not look broken. Either declare `UIUserInterfaceStyle = Dark` in `PopulationClock-Info.plist`
   (simplest, honest for this design) or migrate the color category to dynamic colors. **Recommend the
   former**; note the choice in your report.

6. Also update the HTML templates in `Resources/` (`info_template_portrait.html`,
   `info_template_landscape~iphone.html`) — they carry the country-info styling and will need
   `viewport-fit=cover` plus `env(safe-area-inset-*)` padding under WKWebView.

**Gate:** builds and runs. Take screenshots on an iPhone simulator (landscape) and an iPad simulator,
portrait and landscape, and confirm: no letterboxing, no content under the notch/Dynamic Island or home
indicator, country selection by tapping the map still selects the right country.

**Commit:** `Phase 4: launch screen, safe-area layout, modern icon and orientation policy`

---

## Phase 5 — Data refresh

Data is frozen at 2017. Everything in this phase was **verified live on 2026-09-19** — the API
responses quoted are real.

### 5a. Fix the World Bank pipeline — `Scripts/data/get_data.py`

Three separate defects:

1. **Dead API endpoint.** Line ~40: `url = 'http://api.worldbank.org/countries/all/indicators/{indicator}?'`
   is the v1 API over plain HTTP. Change to:
   ```
   https://api.worldbank.org/v2/country/all/indicator/{indicator}?
   ```
   (v2, HTTPS, `country`/`indicator` singular). Confirmed working; WDI `lastupdated` is `2026-07-13`.

2. **Pagination is broken.** In `Report.request()` there is:
   ```python
   params.page += 1
   break  # TODO REMOVE THIS --- FOR TESTING ONLY
   ```
   This `break` exits the loop after page 1, silently truncating every dataset. **Delete it.**
   Then raise `page_limit` (20000 is accepted) so most indicators fit in one page anyway.

3. **`date` range.** `date = (2000, datetime.datetime.now().year)` still works — leave it.

### 5b. Fix the indicator list — four of them are deleted from WDI

Verified results against `https://api.worldbank.org/v2/country/BRA/indicator/<ID>`:

| Current ID in `get_data.py` | Status | Action |
|---|---|---|
| `SP.POP.TOTL` | OK, data to **2025** | keep |
| `SP.DYN.CBRT.IN` | OK, to 2024 | keep |
| `SP.DYN.CDRT.IN` | OK, to 2024 | keep |
| `SP.POP.GROW` | OK, to 2025 | keep |
| `SP.DYN.TFRT.IN` | OK, to 2024 | keep |
| `SP.DYN.LE00.IN` | OK | keep |
| `EG.ELC.ACCS.ZS` | OK, to 2024 | keep |
| `AG.LND.FRST.ZS` | OK, to 2023 | keep |
| `NY.GDP.MKTP.PP.CD` | OK, to 2025 | keep |
| `NY.GDP.MKTP.KD.ZG` | OK, to 2025 | keep |
| `NY.GDP.PCAP.KN` | OK, to 2025 | keep |
| **`EN.ATM.CO2E.KT`** | **DELETED** — *"The indicator was not found. It may have been deleted or archived."* | → **`EN.GHG.CO2.MT.CE.AR5`** ("CO2 emissions (total) excluding LULUCF, Mt CO2e") |
| **`SH.XPD.TOTL.ZS`** | **DELETED** | → **`SH.XPD.CHEX.GD.ZS`** ("Current health expenditure (% of GDP)") |

Two more indicators have CSVs in `Scripts/data/csv/` but are **missing from the `reports` list** in
`get_data.py` — they were being carried over stale from 2017. Add them:

| Metric | ID | Status |
|---|---|---|
| Internet users | `IT.NET.USER.ZS` | OK to 2024 (**old `IT.NET.USER.P2` is DELETED**) |
| Mobile subscriptions | `IT.CEL.SETS.P2` | OK to 2024 |

**Two metrics have no viable source — decisions required:**

- **Passenger cars per 1,000** (`IS.VEH.PCAR.P3`): the indicator still resolves but returns
  `"total": 0` — no data at all. **Recommended: drop the metric.** Remove `passengerCarPer1000` from
  `Scripts/data/data.py` `DATA[]`, from `StatsBuilder.m:136`, from `Scripts/data/csv/`, and from the
  README metric list.
- **Energy production**: was never a World Bank metric — it came from the CIA scraper, and the Factbook
  **no longer publishes electricity production**. Current Factbook `Energy.Electricity` fields are:
  `installed generating capacity`, `consumption`, `exports`, `imports`, `transmission/distribution losses`.
  Also note `StatsBuilder.m:133` labels it *"Energy prod. (kg of oil equiv.)"* while the README says kWh —
  they already disagree. **Recommended: replace with electricity *consumption* (kWh)**, which is directly
  published; rename the key to `electricityConsumption`, update the label, and update the README.

Apply the recommended option for both, and **flag both clearly in your final report** as changes to what
the app displays — the owner explicitly scoped this refresh as "indicators + descriptions," so these are
forced substitutions, not elective additions.

**Unit change to handle:** `EN.GHG.CO2.MT.CE.AR5` is in **Mt CO2e**, the old indicator was **kt**.
Either multiply by 1000 in `get_data.py` to preserve the existing `formatCO2Emissions` behavior, or
change the formatter. Prefer multiplying — fewer moving parts. Note also that `StatsBuilder.m:131` labels
CO₂ as *"(kg/yr)"* while the README says *"(kt)"*; fix the label to match the real unit.

### 5c. Fix the country table — `Scripts/shared/constants.py`

`DATA[]` carries pre-2018 names that will no longer match World Bank / Factbook output:

- `['SZ', 'SWZ', '748', 1, "Swaziland"]` → **"Eswatini"**
- `['MK', 'MKD', '807', 1, "Macedonia, FYRO"]` → **"North Macedonia"**
- `['TR', 'TUR', '792', 1, "Turkey"]` → **"Türkiye"**
- `['CZ', 'CZE', '203', 1, "Czech Republic"]` → **"Czechia"**
- `['PS', 'PSE', '275', 1, "Palestine "]` — trailing space, clean it up

Matching is by ISO code, not name, so these are display-only — but they are user-visible in the app's
country list. Also re-check `NL`-adjacent entries (`CW`, `SX`, `BQ` are `used = 0`) and confirm nothing
the World Bank now reports is being silently dropped by the `used` filter.

### 5d. Port the Python 2 scripts to Python 3

These still contain Python 2 idioms (`from __future__ import print_function`, and in `scrapeCIA.py`,
`urllib.urlopen` which does not exist in Py3):
`Scripts/coords/coords.py`, `Scripts/description/scrapeCIA.py`, `Scripts/growth/growth.py`,
`Scripts/data/data.py`.
`Scripts/colormap/colormap.py` uses `from constants import *` which only works via the `PYTHONPATH`
hack in the `.sh` wrappers — normalize it to the `sys.path` + `from shared.constants import *` pattern
the other scripts use.
Environment: **Python 3.14.7**. Note `xml.dom.minidom` is still fine; `BeautifulSoup` (`bs4`) is needed
only if you keep HTML scraping — see 5e, where you will not.
Delete the stale `Scripts/shared/*.pyc` and `__pycache__/` artifacts and add them to `.gitignore`.

### 5e. Replace the dead CIA scraper — `Scripts/description/scrapeCIA.py`

The script targets `https://www.cia.gov/library/publications/the-world-factbook/geos/<cc>.html`,
which has been dead since the 2021 Factbook redesign. The current site
(`https://www.cia.gov/the-world-factbook/countries/brazil/`) returns a 302 and is JavaScript-rendered —
**do not try to scrape it.**

**Use the maintained JSON mirror instead** — verified working, HTTP 200:
```
https://raw.githubusercontent.com/factbook/factbook.json/master/<region>/<cc2>.json
```
Regions: `africa`, `antarctica`, `australia-oceania`, `central-america-n-caribbean`, `central-asia`,
`east-n-southeast-asia`, `europe`, `middle-east`, `north-america`, `oceans`, `south-asia`,
`south-america`, `world`.

Field mapping (verified on `south-america/br.json`):
- Country description → `Introduction → Background → text` (2,686 chars for Brazil — comparable to
  what the old `div.category_data` scrape produced).
- Electricity consumption → `Energy → Electricity → consumption → text`, e.g.
  `"608.451 billion kWh (2023 est.)"` — **needs parsing**: strip the `(YYYY est.)` suffix and expand
  `million`/`billion`/`trillion` to a number.

Rewrite `scrapeCIA.py` to:
1. Build a `cc2 → region` index by listing the repo tree once (GitHub contents API), rather than
   hardcoding it — regions do shift.
2. Emit the same `"<cc>" = "<escaped text>";` `.strings` format the current script produces
   (the existing `quot()` / `escape()` helpers are correct — keep them).
3. Write **UTF-8** output (the current file is UTF-16BE; Phase 1 already converted it).
4. Be polite: the raw.githubusercontent endpoint is fine for ~250 sequential requests, but add a small
   delay and handle 404s for the `used = 0` countries that have no Factbook page.

`Scripts/description/ciaCountryCode.txt` (the old CIA two-letter code table) becomes obsolete —
delete it once the new script works, since factbook.json is keyed by ISO 3166-1 alpha-2.

### 5f. Regenerate everything

```bash
cd Scripts/data        && python3 get_data.py          # refreshes Scripts/data/csv/*.csv
cd ../data             && bash data.sh                 # csv -> Scripts/data/data.plist
cd ../description      && python3 scrapeCIA.py > Description.strings
cd ../growth           && bash growth.sh               # growth colormap SVG from new growth rates
cd ../colormap         && bash colormap.sh             # country-ID greyscale map
```

**Careful with the growth/colormap outputs.** `Scripts/growth/growth.py` produces the colored population-
growth map and `Scripts/colormap/colormap.py` produces the 8-bit greyscale country-ID map that
`CountryDetector` reads pixel-by-pixel for tap hit-testing. Commit `cf9e125` is literally
*"Version 1.6.0 - Bugfix colormap"* — this has been broken before.
**The colormap is the app's hit-testing index: if a country's grey value shifts, taps select the wrong
country.** Regenerate it only if the country set actually changed; otherwise leave
`Resources/colormap*.png` and `Resources/colormap.plist` untouched. If you do regenerate, diff
`Resources/colormap.plist` against `Scripts/colormap/colormap.plist` and verify a handful of
countries by tapping in the simulator.

Then copy the outputs into `Resources/`:
`data.plist`, `Description.strings`, the growth-map PNGs (`map.png`, `map@2x.png`, `map~iphone.png`,
`map@2x~iphone.png` — note the SVG must be rasterized at all four sizes).

**Verify the refresh landed:**
```bash
python3 -c "
import plistlib
d = plistlib.load(open('Resources/data.plist','rb'))
print('countries:', len(d))
ys = [v['populationYear'] for v in d.values() if 'populationYear' in v]
print('year range:', min(ys), max(ys))
print('world pop:', d['world']['population'])
"
```
Expect: ~209 countries (or fewer if any dropped out — investigate if the count moves much), year range
at **2024–2025**, and world population around **8.1–8.2 billion**. The current values are 2017 and
7,442,135,578 — if you still see those, the pipeline did not actually run.

### 5g. Update the labels and docs

- `PopulationClock/StatsBuilder.m:118–137` — the metric labels. Fix the CO₂ unit label, the health
  expenditure label ("Current health expenditure (% GDP)"), the energy/electricity label, and remove
  the `passengerCarPer1000` row.
- While there: lines 127, 128, 129, 137 register `literacyRate`, `govtEducationExpensePercentGDP`,
  `unemploymentRate`, `roadsPaved` — **none of these keys are ever produced by the data pipeline**.
  They are dead rows. Remove them or wire them up; removing is simpler and honest.
- Also `StatsBuilder.m:130` has a typo in a user-visible string: `"Unenmployment rate"`.
- `README.md` — update the metric list and the World Factbook link (the `library/publications` URL
  in the README is also dead).

**Gate:** app runs, country info pages show 2024–2025 figures, descriptions are current, tapping the map
still selects the correct country.
**Commit:** `Phase 5: refresh World Bank and Factbook data through 2025, fix data pipeline`

---

## Phase 6 — Release hygiene

1. **Bump the version.** `PopulationClock-Info.plist`: `CFBundleShortVersionString` `1.6.0` → `2.0.0`,
   `CFBundleVersion` `45` → `46`.
2. **Bundle ID / signing.** Currently `br.com.netfilter.${PRODUCT_NAME:rfc1034identifier}` with no
   `DEVELOPMENT_TEAM` set. Leave the bundle ID alone (changing it orphans existing users). Do **not**
   invent a team ID — if signing is needed and no identity is configured, stop and report it.
3. **`.gitignore`** — add `*.pyc`, `__pycache__/`, `.DS_Store` (there are committed `.DS_Store` files at
   the repo root and in `Scripts/`; remove them).
4. **Archive check** (only if a signing identity exists):
   ```bash
   xcodebuild -workspace PopulationClock.xcworkspace -scheme PopulationClock \
     -sdk iphoneos -destination 'generic/platform=iOS' archive \
     -archivePath /tmp/PopulationClock.xcarchive
   ```
5. Final symbol sweep — all of these must return nothing:
   ```bash
   grep -rn "UIWebView\|GADBannerView\|Appirater\|Twitter/Twitter.h\|statusBarOrientation\|keyWindow\|armv7" \
     PopulationClock/ Podfile
   ```

**Commit:** `Phase 6: version bump and release hygiene`

---

## Final report — what to tell the owner

State plainly, with no hedging:

1. **Which SDK you actually built against**, and whether iOS 27 was available on this machine.
2. Whether the simulator build and (if attempted) the device archive succeeded.
3. The data vintage you landed on — the actual min/max `populationYear` in the new `data.plist` and the
   new world population figure.
4. **The two forced metric substitutions** (CO₂ indicator change with its unit conversion; passenger cars
   dropped; energy production → electricity consumption) — these change what users see.
5. Anything you skipped and why. Specifically call out if any of these were deferred:
   `UIRequiresFullScreen` removal, `SBTickerView` vendoring, colormap regeneration, StoreKit 2,
   code signing.
6. Anything you found that this plan got wrong. The plan was written from a read of the repo on
   2026-09-19; if reality differs, trust reality and say so.

**Do not report a phase as complete unless its gate actually passed.** If tests or builds fail, quote
the output.
