Act as a Senior Laravel Backend Developer.

I need a complete Laravel 11 Backend setup for an Educational LMS Platform (Python & AI). This backend will serve a Flutter Mobile App via REST APIs and include a Web Admin Panel.

### Tech Stack:
- **Framework:** Laravel 11.
- **Database:** MySQL.
- **Auth:** Laravel Sanctum (API), Laravel Socialite (Google Auth).
- **Permissions:** Spatie Laravel Permission.
- **PDF Generation:** Barryvdh/laravel-dompdf (for Certificates).

### Core Features & Logic Requirements:

1.  **Database Schema (Must match Flutter Models):**
    - `users`: (id, name, email, password, google_id, role, avatar, organization_id).
    - `roles`: [Admin, Developer, Organization, Teacher, Student].
    - `courses`: (id, title, description, price, thumbnail, teacher_id, category_id, is_published).
    - `modules`: (id, course_id, title, order).
    - `lessons`: (id, module_id, title, type['video', 'pdf', 'text'], file_path, duration, order).
    - `enrollments`: (id, user_id, course_id, status['pending', 'active'], payment_method, receipt_image).
    - `progress`: (id, user_id, lesson_id, is_completed).

2.  **Secure File Serving (Critical Anti-Piracy Logic):**
    - **Storage:** ALL course files (videos, PDFs) must be stored in `storage/app/private_courses` (NOT public).
    - **Streaming API:** Create a specific controller `MediaController`.
    - **Logic:**
        a. Endpoint: `GET /api/stream/{lesson_id}`.
        b. Middleware: Check valid Sanctum Token AND if User has 'active' enrollment for this course.
        c. If valid: Stream the file content using Laravel's `response()->file()` or stream for video ranges.
        d. If invalid: Return 403 Forbidden.

3.  **Payment Workflow (Manual Methods):**
    - Users submit an enrollment request via API with a `receipt_image`.
    - Admin/Manager views these requests in the Web Panel.
    - Admin clicks "Approve" -> Updates enrollment status to `active`.

4.  **API Endpoints Required:**
    - `POST /api/auth/register`, `login`, `google-callback`.
    - `GET /api/courses` (with filters), `GET /api/courses/{id}`.
    - `POST /api/enroll` (Multipart upload for receipt).
    - `GET /api/my-courses`.
    - `POST /api/lessons/{id}/complete` (Update progress).
    - `GET /api/certificate/{course_id}` (Generate PDF if progress is 100%).

### Task:
Please generate the following:
1.  **Migrations:** Code for the key tables defined above.
2.  **Models:** With relationships (`hasMany`, `belongsTo`).
3.  **MediaController:** The complete code for the secure streaming logic.
4.  **EnrollmentController:** Handling the payment upload and status check.
5.  **Routes:** `api.php` grouping protected routes.
