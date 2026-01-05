# Ingrys - Your Personalized health Assistant

A Flutter-based mobile application focused on **AI-powered health scanning and personalization**. The app allows users to scan product ingredients, medicines, or labels, analyze results, maintain scan history, and personalize insights — with full **multi-language support** using Flutter's `gen-l10n` pipeline.

---

## 🚀 Features

* 📷 **Ingredient & Product Scanning** (Camera + Gallery + Text)
* 🕘 **Better UI/UX (Automatic Picture Click for fast and acccurate Results)**
* 🧠 **AI-powered Analysis with ~90-95% Accuracy** (backend-driven)
* 🕘 **Scan History Tracking**
* 👤 **User Authentication** (Email/Password + Google Sign-In(In progress*))
* 🎨 **Light / Dark Theme Support**
* 🌍 **Multi-language Support (i18n)** (In Progress)
* ⚙️ **Profile Management**
* 🔐 **Secure Token Storage**

---
##  App Download -> 
- **Direct APK:** [APP LINK ](https://github.com/shreyomer10/healthAIApp/releases/)

## 🧱 Tech Stack

### Frontend

* **Flutter (Dart)**
* Provider (State Management)
* Camera, Image Picker
* Sensors Plus
* SharedPreferences

### Localization

* Flutter `gen-l10n`
* ARB-based translations
* Supported languages include:

  * English (en)
  * Hindi (hi)
  * Tamil (ta)
  * Telugu (te)
  * Spanish (es)
  * French (fr)



---

## 📂 Project Structure

```
lib/
 ├── Screens/        # UI screens (Auth, Scanner, History, Profile)
 ├── Provider/       # State management (Auth, Locale, Theme)
 ├── Model/          # Data models
 ├── core/           # Secure storage, API helpers
 ├── widgets/        # Reusable UI components
 ├── l10n/           # Localization (ARB files)
 ├── theme.dart      # App themes
 └── main.dart       # App entry point
```

---

## 🌍 Localization Setup

### ARB Files

Located in:

```
lib/l10n/
```

Example:

* `app_en.arb` (base)
* `app_hi.arb`
* `app_ta.arb`
* `app_te.arb`
* `app_es.arb`
* `app_fr.arb`

All ARB files **must contain identical keys**.

### Generate Localization

Run:

```bash
flutter gen-l10n
```

This generates `AppLocalizations` automatically.

### Usage in UI

```dart
final t = AppLocalizations.of(context)!;
Text(t.login);
```

---

## 🌐 Language Switching

* Language selection is handled via a `LocaleProvider`
* Selected language is persisted using `SharedPreferences`
* App updates language **at runtime** (no restart required)

---

## 🎨 Theme Support

* System
* Light
* Dark

Theme changes propagate instantly across the app.

---

## 🔐 Authentication

* Email & Password login
* Google Sign-In
* Secure token storage
* Auto-login on app relaunch

---

## 🧪 Development Setup

### Prerequisites

* Flutter SDK (stable)
* Android Studio / VS Code
* Android Emulator or Physical Device

### Run Locally

```bash
flutter pub get
flutter run
```

---

## ⚠️ Common Pitfalls

* ❌ Hardcoded strings (breaks localization)
* ❌ Missing `locale:` in `MaterialApp`
* ❌ Duplicate keys in ARB files
* ❌ Relying on hot-reload after ARB changes

Restart the app after modifying localization files.

---

## 📈 Future Enhancements

* Alternative Products recommendation ( same composition )
* More language support
* Offline scan caching
* Advanced AI explanations
* Accessibility improvements

---

## 📄 License

This project is currently private / internal. Licensing to be defined.

---

## 👨‍💻 Author

Built with focus on **performance, clean architecture, and scalability** using Flutter.
**Shrey Omer**
