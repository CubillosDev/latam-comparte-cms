import 'package:flutter/material.dart';
import '../screens/screens.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => const LoadingPage(),
  '/login': (context) => const LoginPage(),
  '/dashboard': (context) => const DashboardSuperAdminPage(),
  '/dashboard/pais': (context) => const DashboardAdminPaisPage(),
  '/portales': (context) => const AllPortalsPage(),
  '/solicitudes': (context) => const RequestPage(),
  '/solicitudes/detalle': (context) => const RequestDetailsPage(),
  '/contenido': (context) => const TestimoniosPage(),
  '/testimonios/nuevo': (context) => const FormularioTestimoniosPage(),
  '/noticias': (context) => const NoticiasPage(),
  '/noticias/nuevo': (context) => const FormularioNoticiasPage(),
  '/contacto': (context) => const ContactPage(),
};