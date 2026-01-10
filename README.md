# 📘 Codebook App

Codebook is a sleek, mobile-friendly Flutter app designed for developers to **store, manage, share**, and even **chat with AI** about their code snippets. It's your personal snippet assistant – all in one place.

![Flutter](https://img.shields.io/badge/Built%20with-Flutter-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)
![AI](https://img.shields.io/badge/AI-Groq%2kf0LLaMA3-purple?logo=openai)
![License](https://img.shields.io/github/license/Sefayet-Alam/Codebook-App)


Find the APK file at: [Google Drive Link](https://drive.google.com/drive/folders/18X3otuSETXvkJVm3XdHVvjHdXAymRjOk?dmr=1&ec=wgc-drive-globalnav-goto) <br/>

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

📂 Project Structure <br/>
lib/ <br/>
├── models/             # Data models (Snippet, Section, etc.) <br/>
├── screens/            # All the UI screens <br/>
├── services/           # Firebase, Auth, and AI API logic <br/>
├── widgets/            # Reusable UI components <br/>
├── utils/              # Utility files (e.g., PDF generator) <br/>
├── env.dart            # Your private API key file (ignored in git) <br/>
main.dart               # App entry point <br/>


🤖 Powered By
💙 Flutter

🔥 Firebase

🧠 Groq API (LLaMA 3)

🖨️ pdf and printing packages

🧠 flutter_markdown


🙋‍♂️ Author
Sefayet Alam
📧 Contact | 🌐 GitHub


flutter clean
flutter pub get
flutter run