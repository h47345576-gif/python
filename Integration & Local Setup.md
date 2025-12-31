Act as a DevOps & Mobile Integration Specialist.

I have the Laravel Backend running locally (localhost:8000) and the Flutter App running on an Android Emulator (and sometimes a physical device). I need a step-by-step guide and specific configuration code to connect them successfully.

### Please provide solutions for the following:

1.  **Android Emulator Networking:**
    - Explain how to configure the `base_url` in Flutter (e.g., using `10.0.2.2` vs `localhost`).
    - Provide the `dio_client.dart` configuration snippet to switch URLs based on environment (Debug/Release).

2.  **Laravel CORS & Network Config:**
    - Provide the `config/cors.php` settings to allow requests from the mobile app.
    - Command to serve Laravel on a specific IP network (e.g., `php artisan serve --host 0.0.0.0`) so physical devices can connect via WiFi.

3.  **Android Manifest Config:**
    - Provide the necessary permissions for `AndroidManifest.xml` (Internet, Read/Write Storage).
    - Fix for "Cleartext Traffic" error (since local dev uses HTTP, not HTTPS).

4.  **Image Loading:**
    - How to handle image URLs coming from the DB? (e.g., if DB saves `public/images/x.png`, how to convert it to `http://10.0.2.2:8000/storage/images/x.png` in Flutter).

### Task:
Generate a troubleshooting guide and the specific code snippets for `cors.php`, `AndroidManifest.xml`, and the Flutter `ApiConstants` class.
