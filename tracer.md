# Codebook App — Codex Session Tracer

Last repository review: 2026-09-01 (Asia/Dhaka)  
Reviewed branch/commit: `main` at `053bc50` (`update`)  
Purpose: durable context for future Codex sessions. Read this before changing the project, then verify it against the current code because it is a point-in-time map.

## Review scope

- Reviewed all project-owned application source, models, screens, services, widgets, utilities, tests, manifests, dependency/configuration files, platform runner scaffolding, documentation, and asset metadata.
- Inspected representative screenshots and the primary app artwork. The screenshots show a dark, monospace-oriented Android UI with teal actions, a Lottie/illustrated home background, and reorderable section cards.
- Classified standard Flutter-generated Android, iOS, macOS, Linux, Windows, and web runner files as scaffolding after checking their entry points, identifiers, plugin registration, and build configuration.
- Did not read secret values from `.env`, `lib/env.dart`, or generated obfuscated environment arrays. Only the required variable shape (`GROQ_API_KEY`) and its code path were inspected.
- Excluded `.git`, dependency caches, build output, Pods, Gradle caches, Flutter ephemeral output, IDE metadata, and other regenerated artifacts from semantic review.
- No analyzer, test, build, package-resolution, or formatter command was run during this review, to honor the request not to change existing files or generated state.

## Product in one paragraph

Codebook is a Flutter application for developers to keep a personal cloud-backed library of code snippets. Firebase Authentication gates the app; Cloud Firestore stores each user's ordered sections, nested snippets, and persistent AI chat messages. Users can add/edit/delete/reorder/filter snippets, view syntax-highlighted code, copy/share it, export one or all snippets to PDF, and ask a Groq-hosted coding model questions with a small sample of their saved snippets included as context.

## Runtime architecture

```text
Flutter UI
  main.dart auth gate
    ├── signed out -> LoginScreen -> SignupScreen
    └── signed in  -> UID-scoped FirestoreService -> HomeScreen
                         ├── SectionsScreen -> SnippetsScreen -> SnippetEditScreen
                         ├── AIChatScreen -> AIService -> Groq HTTP API
                         └── PdfScreen -> PdfGenerator -> device file/open APIs

Firebase
  ├── Authentication: email/password identity and auth-state stream
  └── Cloud Firestore: sections, snippets, and AI chat messages per UID
```

This is a client-only architecture. There is no custom backend, Cloud Function, Firebase Rules file, deployment pipeline, or server-side AI proxy in the repository.

## Startup, dependency injection, and navigation

1. `main()` binds Flutter, initializes Firebase with `DefaultFirebaseOptions.currentPlatform`, then mounts `CodebookApp`.
2. `CodebookApp` owns the light/dark/system theme mode.
3. `StreamProvider<User?>` listens to Firebase Auth state.
4. Signed-out state creates a `MaterialApp` rooted at `LoginScreen` without a `FirestoreService` provider.
5. Signed-in state creates `Provider<FirestoreService>` with the authenticated UID and a `MaterialApp` rooted at `HomeScreen`.
6. Named authenticated routes are `/browse` -> `SectionsScreen`, `/ai` -> `AIChatScreen`, and `/pdf` -> `PdfScreen`.
7. `HomeScreen` offers Browse, AI Help, PDF export, theme toggle, sign out, and platform exit.

Provider is used mainly for auth state and supplying a UID-scoped Firestore service. Persistent data itself comes from Firestore streams; transient UI state uses local `StatefulWidget` fields and `setState()`.

## Firestore data model

```text
users/{uid}
├── sections/{sectionId}
│   ├── name: string
│   ├── orderIndex: number
│   └── snippets/{snippetId}
│       ├── title: string
│       ├── language: string
│       ├── section: string
│       ├── code: string
│       ├── markdown: string
│       ├── createdAt: timestamp
│       └── orderIndex: number
└── aiChats/{chatId}
    └── messages/{messageId}
        ├── text: string
        ├── isUser: boolean
        └── timestamp: timestamp
```

All chat currently uses the fixed ID `default_chat`, so each user has one conversation. Section/snippet lists are ordered by `orderIndex`. Reorders use Firestore batches. New indexes are calculated by reading the current highest index. Deleting a section manually deletes its immediate snippet documents before deleting the section document.

## Main feature flows

### Authentication

- `AuthService` wraps Firebase email/password sign-in, sign-up, and sign-out.
- Root auth-state listening is intended to switch automatically between login and home.
- Login and sign-up screens also perform imperative navigation, which overlaps with the root auth gate.

### Sections and snippets

- `SectionsScreen` subscribes to ordered sections, supports add/delete, and drag reordering.
- Selecting a section opens `SnippetsScreen` with its Firestore document ID and display name.
- `SnippetsScreen` subscribes to ordered nested snippets and supports add/edit/delete, drag reorder, language filter, highlighted viewing, clipboard/share, and single-snippet PDF output.
- `SnippetEditScreen` validates title, language, and code, then calls add or update.
- `BrowseScreen` is an older/alternate section list and is not used by current routing.
- `SnippetDetailScreen` and `SnippetCard` exist but are not reached by the current main flow.

### AI assistant

1. User prompt is persisted to Firestore.
2. `AIService.getAllSnippets()` reads every section and its snippets.
3. The first five snippets are selected; each code value is truncated to 800 characters.
4. Context and prompt are sent directly from the client to Groq's OpenAI-compatible chat-completions endpoint.
5. The configured model in code is `openai/gpt-oss-120b` (the README's LLaMA 3 wording is stale).
6. The request uses temperature `0.7`, `max_tokens: 1024`, and a 15-second timeout.
7. Assistant output or an error string is stored in Firestore and rendered as Markdown; code blocks have a copy action.

The key comes from Envied-generated client code. Obfuscation prevents casual plaintext reading but is not a secure secret boundary in a distributed mobile/desktop/web client.

### PDF and sharing

- `PdfGenerator` lazily loads bundled Open Sans and Roboto Mono fonts.
- It groups snippets by section, sorts by `orderIndex` or `createdAt`, creates A4 multipage output, and adds optional team header and page numbering.
- `generateSimplePdf()` is used for single-column export; `generateCombinedPdf()` implements two-column output but is unused.
- Single-snippet export writes to Android Downloads or an application documents directory and uses the hard-coded team name `MyTeam`.
- All-snippet export writes to external app storage, then attempts to open the PDF.
- `SharingService` supports text/file sharing but is unused; current snippet UI calls `share_plus` directly.

## Handwritten Dart file map

| File | Responsibility / status |
|---|---|
| `lib/main.dart` | Firebase startup, root auth gate, theme, providers, named routes |
| `lib/constants/app_colors.dart` | Empty placeholder |
| `lib/env.dart` | Ignored Envied declaration for `GROQ_API_KEY`; secret value not recorded here |
| `lib/env.g.dart` | Generated obfuscated key data; tracked; still extractable from a client binary/source |
| `lib/firebase_options.dart` | Generated Firebase options for web, Android, iOS, macOS, Windows; Linux throws unsupported |
| `lib/models/chat_message.dart` | Chat message entity |
| `lib/models/section.dart` | Section entity and Firestore document mapper |
| `lib/models/snippet.dart` | Snippet entity and Firestore serialization |
| `lib/services/auth_service.dart` | Firebase email/password operations |
| `lib/services/firestore_service.dart` | All section/snippet/chat queries and writes |
| `lib/services/ai_service.dart` | Snippet-context selection and direct Groq HTTP call |
| `lib/services/sharing_service.dart` | Unused text/temp-file sharing abstraction |
| `lib/screens/home_screen.dart` | Authenticated feature menu, theme action, sign out/quit |
| `lib/screens/login_screen.dart` | Login form and sign-up navigation |
| `lib/screens/signup_screen.dart` | Account creation form |
| `lib/screens/sections_screen.dart` | Current ordered section list |
| `lib/screens/browse_screen.dart` | Unused older section list |
| `lib/screens/snippets_screen.dart` | Ordered/filterable snippet list and actions |
| `lib/screens/snippet_edit_screen.dart` | Add/edit/delete form |
| `lib/screens/snippet_detail_screen.dart` | Unused rich snippet detail view |
| `lib/screens/ai_chat_screen.dart` | Persistent Markdown chat UI |
| `lib/screens/pdf_screen.dart` | Full-library PDF export/open UI |
| `lib/widgets/code_viewer.dart` | Dark syntax-highlight dialog with copy/share hooks |
| `lib/widgets/snippet_card.dart` | Unused expansion-card representation |
| `lib/utils/pdf_generator.dart` | Reusable PDF construction |
| `test/widget_test.dart` | One default-style widget test; does not mock Firebase/auth |

## Dependencies and assets

- Core: Flutter/Dart, Material 3, Provider.
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`.
- Presentation: `google_fonts`, `lottie`, `flutter_markdown`, `flutter_highlight`, `markdown`.
- I/O: `http`, `path_provider`, `permission_handler`, `open_file`, `share_plus`.
- Documents: `pdf`. The unused `printing` plugin was removed on 2026-09-03 because version 5.13.1 compiled its Android module against SDK 30 and failed on `android:attr/lStar`.
- Environment generation: `envied`, `build_runner`, `envied_generator`; `flutter_dotenv` is declared but not used by app code.
- `intl` and `reorderables` are declared but current handwritten code does not import them. Flutter's built-in reorderable list is used.
- Main assets: 11 Android screenshots in `Pics/`, app/icon artwork, a 1080x1080 30fps/480-frame Lottie animation, and bundled Open Sans/Roboto Mono fonts.

`pubspec.lock` exists locally but is ignored because `.gitignore` ignores every `*.lock`; dependency resolution is therefore not reproducible from Git alone.

## Platform state

- Android is the clearest primary target. It uses application ID `com.example.codebook_app`, compile/target SDK 35, NDK 28.2.13676358, Java/Kotlin JVM 11, Gradle 8.12, Android Gradle Plugin 8.7.3, and Kotlin 2.1.0.
- Android release currently uses the debug signing configuration.
- Android main manifest requests legacy read/write storage plus broad `MANAGE_EXTERNAL_STORAGE`; modern scoped-storage/Play policy compatibility needs review.
- Android `INTERNET` permission is present in the main manifest for release networking as of 2026-09-03.
- iOS/macOS use standard Flutter CocoaPods runners. iOS has no explicit minimum platform in the Podfile. macOS minimum is 10.15.
- Windows, Linux, macOS, iOS, web, and Android runner scaffolding exists. Firebase options explicitly reject Linux.
- Several app files import/use `dart:io`, `Platform`, exit, and mobile storage APIs without platform abstraction, so scaffolding presence does not mean every feature builds or works on web/desktop.
- Web metadata still uses Flutter template name/description rather than product copy.

## Code-inferred risks and current limitations

These are static-review findings, not runtime-verified failures:

1. **Client AI secret:** the Groq key is compiled into generated client code. Move AI calls behind an authenticated backend/Cloud Function, keep the key server-side, rate-limit, and enforce request limits.
2. **No repository security rules:** UI routing is not authorization. Firestore Rules must require authenticated ownership under `users/{uid}`; the repository does not include rules to verify this.
3. **Snippet edit loses fields:** `SnippetEditScreen` reconstructs an edited snippet without preserving `section` or `markdown`, so `updateSnippet()` writes empty defaults over existing values.
4. **Filtered reorder mismatch:** `SnippetsScreen` renders `filteredSnippets` but `_reorderSnippets()` mutates `_snippets` using filtered indexes. Reordering while a language filter is active can reorder the wrong records.
5. **Uncancelled streams:** `SectionsScreen` and `SnippetsScreen` call `.listen()` without retaining/canceling subscriptions; the snippet listener also calls `setState` without checking `mounted`.
6. **Empty-state bug:** `SectionsScreen` treats an empty loaded list as perpetual loading. The unused `BrowseScreen` has a proper empty message.
7. **Overlapping auth navigation:** login/sign-up/sign-out push screens manually while the root auth stream also swaps the whole app. This can race, bypass the UID service scope temporarily, make the login-pushed home theme toggle a no-op, or produce confusing sign-up behavior.
8. **Signed-out routes expose provider-dependent screens:** the signed-out `MaterialApp` registers `/browse` and `/pdf` even though it does not provide `FirestoreService`. They are not linked from login, but programmatic/deep navigation would fail.
9. **Chat avatar edge case:** `shortEmail[0]` throws when the email string is empty.
10. **AI privacy/logging:** selected private snippets are sent to a third party without a consent/selection step. Full AI response data and provider error bodies are debug-logged; provider details can also be stored in chat error messages.
11. **Broad Firestore reads:** each AI request and full export reads all sections plus each nested snippet collection (N+1 query pattern), with no pagination or semantic retrieval.
12. **Ordering races:** add operations calculate `max(orderIndex) + 1` without a transaction; concurrent additions can duplicate order values. Optimistic reorders have no rollback/error UI.
13. **Deletion scaling:** section deletion performs sequential client-side child deletes and does not use trusted recursive backend deletion.
14. **Storage handling:** the single-PDF path requests storage permission but ignores the returned result; hard-coded Downloads access and broad Android permissions are not aligned with current scoped-storage patterns.
15. **Platform exit:** calling `exit(0)` on iOS is not standard platform UX and may be unacceptable for App Store distribution.
16. **Testing gap:** the deterministic widget test covers `CodeViewer`, but Firebase/auth, data services, navigation, and end-to-end feature flows still lack automated coverage and test doubles.
17. **Stale/unused surface:** README AI model text is stale; `BrowseScreen`, `SnippetDetailScreen`, `SnippetCard`, `SharingService`, combined PDF generation, and several declared packages are unused.
18. **Release/deployment:** no CI, secure release signing, Firebase Emulator setup, Crashlytics/monitoring, flavors, localization, or formal accessibility coverage is present.

## Sensible future verification order

If a future task authorizes changes, begin by re-reading this file and checking `git status`, then:

1. Run `flutter pub get`, `flutter analyze`, and `flutter test` in an environment where generated changes are acceptable.
2. Verify Firebase Auth and Rules with Emulator Suite or a dedicated test project.
3. Reproduce filtered reorder and edit-field-loss issues with focused tests.
4. Decide the actual supported platform set; align Firebase, manifests, file APIs, and CI accordingly.
5. Move AI access behind a server-side boundary before distributing a build.
6. Add dependency injection/fakes, model/service tests, widget tests, integration tests, and Firestore Rules tests.

## Session handoff notes

- Preserve user work and inspect the current diff before editing.
- Never print or copy `.env`, `lib/env.dart` values, or obfuscated arrays from `lib/env.g.dart` into chat, logs, patches, or this tracer.
- Treat `interview.md` as a comprehensive project/interview explanation; it already documents architecture, trade-offs, security, testing strategy, demo flow, limitations, and model answers.
- The most important source files for nearly any feature are `lib/main.dart`, `lib/services/firestore_service.dart`, the relevant screen, and its model.
- This tracer records understanding only. It does not certify that the current application builds, passes tests, or is production-secure.

## Latest build verification

- 2026-09-03: removed the unused `printing` dependency, aligned Android NDK to 28.2.13676358, and added release `INTERNET` permission.
- `flutter pub get`: passed.
- `flutter test`: passed (1 widget test).
- `flutter build apk --release`: passed; artifact generated at `build/app/outputs/flutter-apk/app-release.apk` (64.4 MB).
- `flutter analyze`: no compile errors, but 32 existing warning/info findings remain.
