# 📘 Codebook App

Codebook is a sleek, mobile-friendly Flutter app designed for developers to **store, manage, share**, and even **chat with AI** about their code snippets. It's your personal snippet assistant – all in one place.

![Flutter](https://img.shields.io/badge/Built%20with-Flutter-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)
![AI](https://img.shields.io/badge/AI-Groq%2kf0LLaMA3-purple?logo=openai) 
![License](https://img.shields.io/github/license/Sefayet-Alam/Codebook-App)

---

## ✨ Features

### 👤 Authentication & Profiles
- Sign up, log in, and manage your profile securely.
- Session persistence with sign out support.

### 🗂️ Organize Snippets by Sections
- Create multiple **sections** to group your code logically.
- Each section can have multiple **code snippets**.

### 🧠 AI-Powered Code Assistant
- Ask AI to **explain**, **review**, or **improve** your code snippets.
- Ask general coding questions using a **Groq-powered LLaMA 3 AI**.
- AI considers your saved snippets as context for more personalized answers.

### 📄 Snippet Actions
- View code in a beautiful syntax-highlighted format.
- **Edit** or **delete** code snippets anytime.
- **Copy**, **share** via Messenger, Telegram, etc.
- **Export as PDF** and download directly to your device’s **Downloads** folder.

### 🖨️ Full Code PDF Export
- Generate a **complete PDF document** of all your snippets organized by section.

---

## 📲 Download the Android App

You can download the latest Android APK from the [Codebook GitHub Releases page](https://github.com/Sefayet-Alam/Codebook-App/releases/latest).

### How to download and install

1. Open the [latest release](https://github.com/Sefayet-Alam/Codebook-App/releases/latest) on your Android phone.
2. Scroll to the **Assets** section.
3. Tap the file ending in `.apk`, such as `app-release.apk`. Do not download the automatically generated **Source code** ZIP or TAR.GZ files.
4. When the download finishes, open the APK from your browser or **Downloads** folder.
5. If Android asks for permission, allow **Install unknown apps** for the browser or file manager you are using.
6. Tap **Install**, then open Codebook.

> The APK is for Android devices. iPhones and iPads cannot install APK files. This GitHub build is currently provided as a portfolio/demo release rather than an app-store production release. Only download it from this repository's official Releases page, and disable **Install unknown apps** again afterward if you do not need it.

---

## 📸 Screenshots

<table>
  <tr>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/pic1.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/pic2.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss3.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss4.jpg?raw=true" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss5.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss6.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss7.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss8.jpg?raw=true" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss9.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss10.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss11.jpg?raw=true" width="200"/></td>
    <td><img src="https://github.com/Sefayet-Alam/Codebook-App/blob/main/Pics/ss12.jpg?raw=true" width="200"/></td>
  </tr>
</table>


---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x
- Dart SDK
- Firebase project (Firestore + Auth)
- A Groq API key for LLaMA3 AI (stored in `lib/env.dart`)

### Clone the Repo

```bash
git clone https://github.com/Sefayet-Alam/Codebook-App.git
cd Codebook-App
flutter pub get
```

📂 Project Structure  </br>
lib/
├── models/             # Data models (Snippet, Section, etc.) </br>
├── screens/            # All the UI screens  </br>
├── services/           # Firebase, Auth, and AI API logic  </br>
├── widgets/            # Reusable UI components  </br>
├── utils/              # Utility files (e.g., PDF generator)  </br>
├── env.dart            # Your private API key file (ignored in git)  </br>
main.dart               # App entry point  </br>


🤖 Powered By  </br>
💙 Flutter  </br>

🔥 Firebase  </br>

🧠 Groq API (LLaMA 3)  </br>

🖨️ pdf and printing packages  </br>

🧠 flutter_markdown  </br>


🙋‍♂️ Author  </br>
Sefayet Alam  </br>
📧 Contact | 🌐 GitHub


flutter clean  </br>
flutter pub get  </br>
flutter run  </br>
