هذه خطة عمل شاملة وتفصيلية لبناء المنصة التعليمية التي طلبتها، مع مراعاة الخصوصية الجغرافية لطرق الدفع (سوريا) والمتطلبات الأمنية العالية (منع تسجيل الشاشة وحماية المحتوى).

المشروع سيقسم إلى قسمين رئيسيين: **Backend (Laravel)** و **Mobile App (Flutter)**.

---

### القسم الأول: هيكلية قاعدة البيانات (Laravel Database Schema)

بناءً على الأدوار والميزات، سنحتاج الجداول التالية:

1.  **users**: (id, name, email, password, google_id, role_id, organization_id, avatar, is_active).
2.  **roles**: (id, name) -> [Admin, Developer, Organization_Manager, Teacher, Student].
3.  **organizations**: (id, name, logo, status, owner_id).
4.  **categories**: (id, name, slug, icon, parent_id).
5.  **courses**: (id, title, description, thumbnail, price, teacher_id, category_id, level, is_published).
6.  **modules**: (id, course_id, title, order). -> لتقسيم الكورس إلى محاور.
7.  **lessons**: (id, module_id, title, type [video, text, pdf], content_url, duration, is_free_preview, order).
8.  **enrollments**: (id, user_id, course_id, status [active, pending, expired], payment_method, transaction_image).
9.  **progress**: (id, enrollment_id, lesson_id, is_completed, last_position).
10. **certificates**: (id, user_id, course_id, certificate_code, file_url, issued_at).
11. **payments**: (id, user_id, course_id, amount, method, proof_image, status, admin_note).

---

### القسم الثاني: تفاصيل Backend (Laravel)

سنستخدم **Laravel 11** مع **Laravel Sanctum** للـ API Auth.

#### 1. أهم الحزم (Packages) المطلوبة:
*   `spatie/laravel-permission`: لإدارة الأدوار والصلاحيات.
*   `laravel/sanctum`: للمصادقة مع فلاتر.
*   `barryvdh/laravel-dompdf` أو `browsershot`: لتوليد الشهادات.
*   `laravel/socialite`: لتسجيل الدخول عبر Google.

#### 2. Models & Relationships:
*   **User**: `belongsTo(Organization)`, `hasMany(Enrollment)`.
*   **Course**: `belongsTo(Category)`, `belongsTo(Teacher)`, `hasMany(Module)`.
*   **Lesson**: `belongsTo(Module)`.

#### 3. Controllers & API Endpoints:

**A. AuthController:**
*   `register(Request $request)`: إنشاء حساب جديد.
*   `login(Request $request)`: تسجيل دخول وإرجاع Token.
*   `googleLogin(Request $request)`: استقبال التوكن من فلاتر والتحقق منه.

**B. CourseController:**
*   `index()`: عرض الكورسات مع الفلاتر (بحث، تصنيف).
*   `show($id)`: عرض تفاصيل الكورس (مع الدروس إذا كان المشترك مسجلاً).
*   `store()`: (للمعلم/المطور) إضافة كورس.

**C. EnrollmentController:**
*   `subscribe(Request $request)`: طلب اشتراك ورفع صورة الإشعار (للحوالات وشام كاش).
*   `myCourses()`: عرض كورسات الطالب.

**D. ProgressController:**
*   `updateProgress()`: تحديث التقدم عند إنهاء درس.
*   `generateCertificate()`: التحقق من اكتمال 100% وتوليد PDF.

**E. AdminController:**
*   `approvePayment()`: الموافقة على الدفع وتفعيل الكورس.

#### 4. نظام إدارة الملفات (File System):
*   يجب تخزين الفيديوهات وملفات PDF في مسار `storage/app/private_courses` بحيث لا يمكن الوصول إليها عبر رابط مباشر (Public URL).
*   يتم الوصول للملفات عبر API `StreamController` الذي يتحقق من `Header` التوكن وصلاحية المستخدم قبل إرسال البيانات (Stream).

---

### القسم الثالث: تفاصيل التطبيق (Flutter)

سنستخدم نمط **MVVM** مع **Provider** لإدارة الحالة، وهيكلية Clean Architecture مبسطة.

#### 1. هيكلية المجلدات (Folder Structure):
```
lib/
├── core/
│   ├── constants/ (Colors, Strings, API Endpoints)
│   ├── services/ (ApiService, DatabaseService, DownloadService)
│   └── utils/ (Helpers, Validators)
├── data/
│   ├── models/ (User, Course, Lesson, Certificate)
│   └── providers/ (AuthProvider, CourseProvider, DownloadProvider)
├── ui/
│   ├── screens/
│   │   ├── auth/ (Login, Register)
│   │   ├── home/ (Dashboard, CourseList)
│   │   ├── course/ (CourseDetails, VideoPlayer, PDFReader)
│   │   ├── offline/ (MyDownloads)
│   │   └── profile/
│   └── widgets/ (CustomButton, CourseCard, Loader)
└── main.dart
```

#### 2. أهم المكتبات (Dependencies):
*   `provider`: لإدارة الحالة.
*   `dio`: للاتصالات الشبكية والتحميل.
*   `hive` & `hive_flutter`: قاعدة بيانات محلية لتخزين بيانات الكورسات (NoSQL) للعمل أوفلاين.
*   `flutter_windowmanager`: لمنع تسجيل الشاشة (Android).
*   `video_player` + `chewie`: مشغل الفيديو.
*   `google_sign_in`: تسجيل دخول جوجل.
*   `flutter_pdfview`: عرض الـ PDF.
*   `encrypt`: لتشفير الملفات المحملة.
*   `path_provider`: للوصول لمسارات التخزين.

#### 3. إدارة الملفات والأمن (Security Logic) - أهم جزء:

**أ. منع تسجيل الشاشة:**
في ملف `main.dart` أو في `init` لكل شاشة حساسة:
```dart
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

// داخل دالة initState
await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
```
*ملاحظة: هذا يعمل بكفاءة على أندرويد. في iOS يتم تعتيم الشاشة عند فتح تعدد المهام، ولكن منع التسجيل كلياً يتطلب كود Native معقد، لكن الأغلب يكتفي بـ DRM إذا توفر أو الاكتفاء بحماية أندرويد.*

**ب. التحميل الآمن (Secure Offline Mode):**
عندما يضغط الطالب على "تحميل":
1.  **Download**: يقوم `Dio` بتحميل الملف كـ `Bytes`.
2.  **Encryption**: يقوم `DownloadService` بتشفير هذه الـ Bytes باستخدام مفتاح AES وتخزين الملف بصيغة غير معروفة (مثلاً `.enc`) في `ApplicationDocumentsDirectory`.
3.  **Storage**: حفظ مسار الملف واسمه في `Hive` ليعرف التطبيق أنه موجود أوفلاين.

**ج. التشغيل (Playback):**
1.  **Video**: لا يمكن تشغيل ملف مشفر مباشرة. الحل هو إنشاء `Local Server` صغير داخل التطبيق أو فك التشفير الجزئي (Decryption on the fly) وتمريره للمشغل. أو الأسهل: عند التشغيل، يتم فك تشفير الملف لملف مؤقت (Temp) وتشغيله، وعند إغلاق الصفحة يتم حذف الملف المؤقت فوراً.
2.  **PDF**: نفس المبدأ، فك تشفير إلى Temp وعرضه ثم حذفه.

#### 4. إدارة عمليات الدفع (Payment Flow):
بما أن الطرق يدوية (شام كاش، سيرياتيل، إلخ):
1.  يختار الطالب "شراء الكورس".
2.  تظهر شاشة فيها تعليمات: "حول المبلغ X إلى الرقم 09xxxxxxxx".
3.  حقل إدخال: "رقم العملية" + "زر رفع صورة الإشعار".
4.  يتم إرسال الطلب للـ Laravel API.
5.  تكون حالة الاشتراك `pending`.
6.  يوافق الأدمن من لوحة التحكم -> يصبح الاشتراك `active`.

---

### القسم الرابع: السيناريوهات التفصيلية (CRUD & Permissions)

#### 1. نظام الأدوار (Spatie Roles):
*   **Developer (Super Admin)**: صلاحيات كاملة، يضيف المنظمات، يضيف المعلمين، يحدد القوالب.
*   **Organization**: إضافة معلمين تابعين لها، إضافة كورسات (تنتظر موافقة أو لا حسب الإعدادات)، مشاهدة تقارير مبيعاتها.
*   **Teacher**: إنشاء محتوى الكورس، متابعة أسئلة الطلاب (إن وجد نظام تعليقات).
*   **Student**: تصفح، شراء، حضور، تحميل، الحصول على شهادة.

#### 2. Providers في Flutter:

**A. `AuthProvider`**:
*   `login(email, password)`
*   `register(...)`
*   `googleSignIn()`
*   يخزن التوكن في `FlutterSecureStorage`.

**B. `CourseProvider`**:
*   `fetchCourses()`: يجلب القائمة من API.
*   `enrollInCourse(id, paymentProof)`: يرسل طلب الاشتراك.
*   `checkCourseStatus(id)`: هل هو مفعل أم لا.

**C. `DownloadProvider`**:
*   `downloadLesson(url, filename)`: يدير التشفير والحفظ.
*   `getLocalFile(filename)`: يدير فك التشفير.

---

### القسم الخامس: مقترح بيانات الكورسات والتصنيفات (Data Seeding)

بما أن المنصة لتعليم بايثون والذكاء الصنعي، أقترح عليك هذه الهيكلية للتصنيفات:

**1. أساسيات البرمجة (Programming Basics)**
*   Python Level 1: Syntax & Structures
*   Python Level 2: OOP & Advanced Concepts
*   Database Management with SQL

**2. علم البيانات (Data Science)**
*   Data Analysis with Pandas & NumPy
*   Data Visualization (Matplotlib & Seaborn)
*   Data Preprocessing Techniques

**3. الذكاء الصنعي (Artificial Intelligence)**
*   Machine Learning Basics (Scikit-Learn)
*   Deep Learning (TensorFlow & Keras)
*   Computer Vision (OpenCV)
*   Natural Language Processing (NLP)

**4. مشاريع عملية (Real-world Projects)**
*   بناء Chatbot ذكي.
*   نظام التعرف على الوجوه.
*   التنبؤ بأسعار العقارات.

---

### القسم السادس: خطة العمل خطوة بخطوة

#### الأسبوع 1: إعداد الأساس (Backend)
1.  تثبيت Laravel وإعداد قاعدة البيانات (Migrations).
2.  تثبيت Spatie Permission وإعداد الأدوار (Roles & Seeders).
3.  بناء Auth APIs (Login, Register, Socialite).
4.  بناء لوحة تحكم بسيطة (FilamentPHP ممتاز جداً وسريع للوحة الإدارة أو استخدام Blade عادي).

#### الأسبوع 2: إدارة المحتوى (Backend)
1.  بناء CRUD للكورسات، الأقسام، والدروس.
2.  إعداد رفع الملفات (Video, PDF) وحمايتها.
3.  بناء API إرجاع الكورسات وتفاصيلها (JSON Resources).

#### الأسبوع 3: تطبيق فلاتر (UI & Auth)
1.  بناء واجهات تسجيل الدخول وإنشاء الحساب.
2.  ربط `AuthProvider` مع الـ API.
3.  تصميم واجهة الصفحة الرئيسية وعرض الكورسات.

#### الأسبوع 4: ميزات الكورس والدفع (Flutter & Laravel)
1.  بناء صفحة تفاصيل الكورس.
2.  تنفيذ آلية الاشتراك (رفع صورة الحوالة) في التطبيق والـ API.
3.  لوحة الأدمن للموافقة على الدفعات.

#### الأسبوع 5: المشغلات والأوفلاين (The Core)
1.  دمج `video_player` و `pdf_view`.
2.  تنفيذ منطق التحميل والتشفير (`encrypt` package).
3.  تنفيذ منطق `FlutterWindowManager` لمنع التسجيل.

#### الأسبوع 6: الشهادات واللمسات الأخيرة
1.  تصميم قالب الشهادة HTML/CSS في لارافيل.
2.  كود توليد الشهادة عند اكتمال التقدم.
3.  اختبار التطبيق (Testing) وإصلاح الأخطاء.

### نصيحة إضافية للمطور:
بما أنك تستخدم طرق دفع محلية (شام كاش..)، اجعل جدول `payment_methods` في قاعدة البيانات ديناميكياً (يمكن إضافة طرق دفع جديدة من لوحة التحكم مع رقم الهاتف والتعليمات)، بحيث يعرض التطبيق هذه الطرق ديناميكياً (API Request) بدلاً من برمجتها بشكل ثابت (Hardcoded) داخل التطبيق.
