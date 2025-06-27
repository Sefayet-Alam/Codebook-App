# Codebook App

## About the Project

Codebook App is a Flutter-based mobile application designed to help programmers create, manage, and share their own coding snippets and notes efficiently.  
It integrates Firebase for backend services such as authentication and Firestore database management. The app also leverages AI-powered code suggestions via the Groq API.

---

## Technology Stack & Libraries Used

- **Flutter & Dart**: Frontend mobile application development  
- **Firebase**: Authentication, Firestore database, cloud backend  
- **Provider**: State management  
- **Flutter Dotenv**: Environment variable management  
- **Google Fonts**: Custom font integration  
- **HTTP**: API requests  
- **Flutter Markdown**: Render markdown formatted code snippets  
- **Lottie**: Animations  
- **Permission Handler**: Permissions management  
- **Open File**: Open files on device  
- **PDF & Printing**: Generate and print PDF documents  
- **Share Plus**: Sharing content functionality  
- **Reorderables**: Drag & drop reorderable lists  
- **Flutter Highlight**: Syntax highlighting for code snippets  

---

## Setup & Initialization

### 1. Clone the repository

```bash
git clone https://github.com/Sefayet-Alam/Codebook-App.git
cd Codebook-App

2. Install dependencies

flutter pub get
3. Create .env file in the root directory
Add your environment variables here, for example:
env

GROQ_API_KEY=your_groq_api_key_here

4. Run build runner (if using code generation)

flutter pub run build_runner build --delete-conflicting-outputs
5. Run the app

flutter run
Or run on a specific device/emulator:


flutter run -d <device_id>
Firebase Setup
Make sure to configure your Firebase project and add the google-services.json (Android) and GoogleService-Info.plist (iOS) files appropriately.
Your firebase_options.dart is generated from your Firebase project setup and included in the project.

Environment Variables
This project uses the flutter_dotenv package to load environment variables from .env.
Make sure to run await dotenv.load(fileName: '.env'); in your main.dart before app initialization.

Contribution
Feel free to fork the repo, make improvements, and open pull requests!
If you find any issues or have feature requests, open an issue on GitHub.

License
This project is licensed under the MIT License.

Happy coding! 🚀


---

### How to use the bash script:

- Save the above script into a file, for example `create_readme.sh` in your project root.
- Run:
bash create_readme.sh
This will generate a complete README.md in your current directory.