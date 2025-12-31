import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import providers (to be created)
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/download_provider.dart';

// Import screens (to be created)
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Open Hive boxes (add as needed)
  // await Hive.openBox('courses');

  // Set security flag to prevent screenshots/recordings
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: MaterialApp(
        title: 'Educational LMS App',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF00FF88), // Neon Green
          scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Dark Blue
          fontFamily: GoogleFonts.cairo().fontFamily,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00FF88),
            secondary: Color(0xFF00FF88),
            surface: Color(0xFF16213E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F3460),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF88),
              foregroundColor: Colors.black,
            ),
          ),
        ),
        home: const HomeScreen(), // Placeholder, will be auth check later
      ),
    );
  }
}
