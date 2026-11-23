import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/components/app_keys.dart';
import 'package:flutter_application_1/firebase_options.dart'; // generado con: flutterfire configure
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/checkout_provider.dart';
import 'package:flutter_application_1/providers/destination_provider.dart';
import 'package:flutter_application_1/providers/navigation_provider.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';
import 'package:flutter_application_1/providers/onboarding_provider.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/providers/shake_provider.dart';
import 'package:flutter_application_1/providers/subscription_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/screens/app_shell.dart';
import 'package:flutter_application_1/screens/cart_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/map_screen.dart';
import 'package:flutter_application_1/screens/notifications_screen.dart';
import 'package:flutter_application_1/screens/onboarding_screen.dart';
import 'package:flutter_application_1/screens/plans_screen.dart';
import 'package:flutter_application_1/screens/verify_email_screen.dart';

/// Handler de mensajes con la app en SEGUNDO PLANO / CERRADA.
/// Debe ser una función de nivel superior. Los mensajes con bloque
/// `notification` los muestra el sistema; aquí solo se inicializa Firebase.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseDatabase.instance.setPersistenceEnabled(true); // datos sin conexión
  }

  await initializeDateFormatting('es_MX'); // fechas en español
  final prefs = await SharedPreferences.getInstance();
  runApp(AgenciaApp(prefs: prefs));
}

class AgenciaApp extends StatelessWidget {
  final SharedPreferences prefs;
  const AgenciaApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => OnboardingProvider(prefs)),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => ShakeProvider()),
        // lazy:false => escuchador global de FCM activo desde el arranque.
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => NotificationProvider(prefs)..init(),
        ),
        ChangeNotifierProxyProvider<SessionProvider, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
          update: (_, session, sub) => (sub ?? SubscriptionProvider())..bind(session.user?.uid),
        ),
      ],
      // Misma lógica de tu práctica (0 Noche, 1 Día, 2 Cálido) pero con Provider.
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Viaja MX',
          debugShowCheckedModeBanner: false,
          navigatorKey: AppKeys.navigator,
          scaffoldMessengerKey: AppKeys.messenger,
          theme: theme.theme,
          home: const RootGate(),
          routes: {
            '/notifications': (_) => const NotificationsScreen(),
            '/map': (_) => const MapScreen(),
            '/plans': (_) => const PlansScreen(),
            '/cart': (_) => const CartScreen(),
          },
        ),
      ),
    );
  }
}

/// Decide qué pantalla mostrar: onboarding -> login -> verificación -> app.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final session = context.watch<SessionProvider>();

    if (!onboarding.seen) return const OnboardingScreen();
    if (!session.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!session.isLoggedIn) return const loginScreen();
    if (session.needsVerification) return const VerifyEmailScreen();
    return const AppShell();
  }
}
