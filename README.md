# Paisa Flow

An offline money app for Android and iOS, built with Flutter. Track cash in, cash out and transfers across your accounts (cash, bank, wallet, card, loan), import bank and wallet statements, set budgets, split expenses with friends, and see where your money goes. Everything stays on the device: no sign-in, no server, no analytics.

Available in English and नेपाली.

- **Package:** `com.paisaflow.app`
- **Privacy policy:** https://sites.google.com/view/paisaflow-privacypolicy/home

## Features

- **Accounts:** Cash, Bank, Wallet, Card, Loan, Savings or Other, each with its own currency, opening balance and a running balance on every entry.
  - The Accounts tab shows assets, liabilities and total per currency (never converted), grouped by type.
  - Card and Loan accounts show what is owed.
  - Home shows net worth.
- **Entries:**
  - Cash in, cash out and **transfers** between accounts, with an optional fee and both amounts when the currencies differ.
  - Each entry has a category and optional subcategory (Food › Lunch), payment mode, date, notes, **tags** (#japan-trip) and an edit history.
  - Faster entry: title suggestions from past entries, templates (★), and "Save & add another".
  - **Repeating entries** and a loan **EMI calculator**. Due entries are listed for you to confirm when the app opens; nothing is added on its own.
- **All entries and search:** one feed across accounts with month totals and filters, and search over titles, notes, amounts, references, tags and subcategories.
- **Statement import:**
  - Text-based PDF bank statements (NIC Asia, Nabil, Standard Chartered and similar), including password-protected PDFs.
  - Legacy `.xls` / `.xlsx` / `.csv` wallet exports (eSewa).
  - Several files at once, with one combined preview. Overlapping days are imported once, and a gap between two statements of the same account is flagged.
  - Duplicates are detected on re-import.
  - Each entry's payment mode is set to the bank or wallet it came from.
  - Simple keyword rules (`lib/data/category_rules.dart`) suggest a category.
  - Bank codes in descriptions become readable titles, such as `QR · Mega Mart Nagaun` or `IPS · Name · Loan Paid` (`lib/data/description_cleaner.dart`). The bank's original text is kept in the entry's notes.
  - Importing into an empty book adds the statement's opening balance, so the book ends at the bank's closing balance.
- **Split:** groups, shared expenses and one-off bills, with balances per friend and settle-up.
- **Insights:**
  - A money **Flow** chart (income → month → categories → saved), a spending calendar, and a **Pace** chart against last month and your budget.
  - Category boxes with drill-down into 6 months of history, top places, trends and tags.
  - Cards can be reordered and hidden.
- **Budgets:** monthly limits overall and per category, for all accounts in a currency or for one account.
- **Reports:** PDF / Excel reports for any date range.
- **Backup & restore:** an encrypted `.pfbak` file (AES-256-GCM, with an optional password), restored by merging or replacing.
- **App lock:** a 4-digit PIN with fingerprint or face unlock, and the app hidden in the app switcher.
- **Goals:** savings targets with progress.
- **Personalisation:** light and dark themes, English and Nepali.

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter 3.41, Dart 3.11 |
| State | `ChangeNotifier` store exposed through an `InheritedNotifier` (`AppScope`) |
| Storage | JSON in `shared_preferences` |
| PDF | `syncfusion_flutter_pdf` (reading), `pdf` + `printing` (export) |
| Security | `cryptography` (AES-GCM backups, PBKDF2, PIN hash), `local_auth` (biometrics) |
| Charts | Hand-drawn with `CustomPainter` (Sankey flow, pace line, treemap, bars) |
| Spreadsheets | `spreadsheet_decoder`, a built-in BIFF8 reader for legacy `.xls`, and a hand-written `.xlsx` writer (`archive`) |
| Localisation | `flutter_localizations` + gen-l10n (ARB files) |
| UI | Bundled Nunito and Mukta fonts, Lucide icons |

## Project structure

```
lib/
├── app/          App root, shell (bottom tabs), navigation helpers
├── core/         Formatting (money, dates)
├── data/         AppStore, models, statement parsers, reports, export
├── features/     One folder per feature
│   ├── backup/  books/  budgets/  calendar/  emi/  entries/  goals/
│   ├── home/  import/  insights/  lock/  onboarding/  repeating/
│   └── reports/  search/  settings/  split/  tags/
├── l10n/         app_en.arb, app_ne.arb and generated localisations
├── theme/        Design tokens (PfColors) and ThemeData
└── widgets/      Shared UI (buttons, cards, sheets, entry rows)
test/             Unit and widget tests
integration_test/ End-to-end flows run on a simulator or emulator
store_listing/    Play Store and App Store assets, listing copy, privacy policy
```

## Getting started

Requires the Flutter SDK (3.41 or newer), plus Xcode for iOS or Android Studio for Android.

```bash
flutter pub get
flutter run
```

Localisations are generated from the ARB files on build. After editing `lib/l10n/*.arb`, run `flutter gen-l10n`.

## Tests

```bash
flutter analyze
flutter test
```

Integration tests run on a booted simulator or emulator:

```bash
flutter test integration_test/onboarding_tour_test.dart -d <device-id>
flutter test integration_test/statement_import_flow_test.dart -d <device-id> \
  --dart-define=STATEMENTS_DIR=<folder with statements on the device>
```

## Release build (Android)

Release signing reads `android/key.properties`. That file is git-ignored; create it locally:

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Without it, release builds fall back to the debug key, which Google Play will not accept.

Before every Play upload, bump the build number after `+` in `pubspec.yaml`, for example `1.0.0+3` → `1.0.0+4`. Then build:

```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

Never commit `key.properties` or the `.jks` keystore.

## Release artifacts (CI)

Pushing a version tag runs [`.github/workflows/release.yml`](.github/workflows/release.yml). It analyzes and tests the code, then builds:

- a **signed APK** (with the upload key, for sideloading), and
- an **unsigned IPA**, since there's no Apple developer account. Sideloading tools such as AltStore or Sideloadly sign it with the user's own Apple ID.

Both are attached to a GitHub release for that tag, as `PaisaFlow-1.0.0-build4.apk` and `PaisaFlow-1.0.0-build4.ipa`. The Play Store bundle is still built locally (see above).

**Tag after each release.** The tag must match `version:` in `pubspec.yaml`, with a `v` in front, or the run stops:

```bash
git tag v1.0.0+4          # pubspec version 1.0.0+4
git push origin v1.0.0+4
```

A suffix such as `v1.0.0+5-beta` marks a pre-release and names the files; the app keeps the pubspec version.

**Repository secrets** (Settings → Secrets and variables → Actions):

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | the upload keystore, base64-encoded: `base64 -i upload-keystore.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` from `key.properties` |
| `ANDROID_KEY_ALIAS` | `keyAlias` from `key.properties` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` from `key.properties` |

If any secret is missing, the Android job fails instead of signing with the debug key.

## Privacy

Paisa Flow stores all data locally on the device. The Android release build does not request internet access. See the [privacy policy](https://sites.google.com/view/paisaflow-privacypolicy/home).

## Author

Raymond Maharjan
