import 'package:app/core/app/app_theme.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/noticias_provider.dart';
import 'package:app/provider/paises_provider.dart';
import 'package:app/provider/solicitudes_provider.dart';
import 'package:app/provider/testimonios_provider.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  ApiClient.instance.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaisesProvider()),
        ChangeNotifierProvider(create: (_) => NoticiasProvider()),
        ChangeNotifierProvider(create: (_) => TestimoniosProvider()),
        ChangeNotifierProvider(create: (_) => SolicitudesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latinoamérica Comparte',
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: '/',
      theme: AppTheme.theme,
    );
  }
}
