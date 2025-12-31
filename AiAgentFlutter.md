Act as a Senior Flutter Developer & System Architect. 

I need you to generate a full, production-ready Flutter project structure and core code for an Educational LMS App (Python & AI learning platform).

### Tech Stack & Architecture:
- **Framework:** Flutter (Latest Version).
- **Architecture:** MVVM with Clean Architecture principles.
- **State Management:** Provider pattern.
- **Networking:** Dio (with Interceptors for Bearer Token).
- **Local Storage:** Hive (for offline course data) + FlutterSecureStorage (for Auth Tokens).
- **Video Player:** Chewie + VideoPlayer.
- **Security:** flutter_windowmanager (to prevent screen recording).
- **Encryption:** 'encrypt' package (for offline file protection).
- **PDF:** flutter_pdfview.
- **UI Library:** Google Fonts (Cairo Font), flutter_svg.

### Project Context:
This app consumes a Laravel API. It allows students to login, view Python/AI courses, enroll via manual payment methods (uploading a receipt image), and watch courses. It has a strict "Secure Offline Mode" where downloaded files are encrypted and cannot be opened outside the app.

### Folder Structure (Please follow this strictly):
lib/
├── core/
│   ├── constants/ (api_urls.dart, app_colors.dart, app_strings.dart)
│   ├── services/ (api_service.dart, download_service.dart, encryption_service.dart)
│   └── utils/ (validators.dart, helpers.dart)
├── data/
│   ├── models/ (user_model.dart, course_model.dart, lesson_model.dart)
│   └── repositories/ (auth_repository.dart, course_repository.dart)
├── providers/ (auth_provider.dart, course_provider.dart, download_provider.dart)
├── ui/
│   ├── screens/
│   │   ├── auth/ (login_screen.dart, register_screen.dart)
│   │   ├── home/ (home_screen.dart, course_list_screen.dart)
│   │   ├── course/ (course_details_screen.dart, video_player_screen.dart, pdf_viewer_screen.dart)
│   │   ├── payment/ (payment_upload_screen.dart)
│   │   └── offline/ (downloaded_courses_screen.dart)
│   └── widgets/ (custom_button.dart, course_card.dart, loader.dart)
└── main.dart

### Specific Implementation Requirements (CRITICAL):

1.  **Security & Main Configuration:**
    - In `main.dart`, initialize `FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE)` to prevent screen recording/screenshots on Android.
    - Setup `Hive` initialization.

2.  **Auth Provider & Service:**
    - Implement `login`, `register`, and `googleLogin`.
    - Use `Dio` to send requests to Laravel endpoints (`/api/login`, etc.).
    - Store the received 'token' in `FlutterSecureStorage`.

3.  **Course Enrollment & Payment Logic:**
    - The `PaymentUploadScreen` must allow selecting a payment method (Dropdown: "Bank Transfer", "Sham Cash", "Syriatel Cash", "MTN Cash", "Hand Delivery").
    - Use `image_picker` to select a transaction receipt.
    - Send `MultipartFile` via Dio to `/api/enroll`.

4.  **Secure Offline System (The most important part):**
    - Create a `DownloadService` and `EncryptionService`.
    - **Logic:** When user downloads a video/PDF:
      a. Download the file bytes using Dio.
      b. Encrypt the bytes using AES (from `encrypt` package) with a hardcoded key.
      c. Save the `.enc` file in `ApplicationDocumentsDirectory`.
      d. Save metadata in Hive (isDownloaded = true).
    - **Playback Logic:**
      a. When playing an offline video, read the `.enc` file.
      b. Decrypt it to a temporary file (`.mp4`) in the cache directory.
      c. Pass the temp file to `VideoPlayerController`.
      d. *Crucial:* Delete the temp file when the screen is disposed.

5.  **UI Design:**
    - Use a Dark/Tech theme (Dark Blue & Neon Green accents for Python/AI vibe).
    - Use 'Cairo' font for Arabic support.
    - Create a reusable `CourseCard` widget showing progress and thumbnail.

### Task:
Please generate the code for the following files detailedly:
1.  `pubspec.yaml` (dependencies list).
2.  `lib/core/services/encryption_service.dart` (The secure logic).
3.  `lib/providers/download_provider.dart`.
4.  `lib/ui/screens/course/video_player_screen.dart` (Handling the secure playback).
5.  `lib/ui/screens/payment/payment_upload_screen.dart`.
6.  `lib/data/models/course_model.dart`.
7.  `main.dart` (with the security flags).

Write the code with comments explaining the logic.
