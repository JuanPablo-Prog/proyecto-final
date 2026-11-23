# Viaja MX · App de agencia de turismo (Flutter + Firebase)

Paquete `flutter_application_1`. Estructura al estilo de tu práctica:
`components/` (tema, menú circular, widgets), `database/` (DAOs/modelos), `firebase/` (`EmailAuth`, `SocialAuth`),
`providers/`, `screens/`, `services/`. `lib/firebase_options.dart` NO viene incluido: lo genera `flutterfire configure` con TU propio proyecto de Firebase.

## 1. Definición del proyecto

**Problemática.** Las agencias de turismo pequeñas y medianas siguen vendiendo sus paquetes por WhatsApp,
redes sociales y llamadas: el cliente no ve un catálogo actualizado, no sabe dónde está la sucursal, no recibe
ofertas a tiempo y no puede reservar ni pagar en un solo lugar. Esto genera mensajes perdidos, precios
desactualizados, reservas sin confirmar y poca fidelización.

**Objetivo general.** Desarrollar una aplicación móvil multiplataforma (Flutter) que permita a los viajeros
explorar un catálogo en tiempo real, reservar y pagar paquetes turísticos, suscribirse a planes de beneficios y
recibir ofertas segmentadas por intereses mediante notificaciones push, con autenticación segura y respaldo
en Firebase.

**Alcance.**
- *Funcional:* registro/inicio de sesión (correo, Google, GitHub), catálogo con búsqueda y filtros, detalle con
  mapa, carrito, pago con tarjeta (simulado en modo prueba), 3 planes de suscripción con descuento,
  notificaciones por temas, perfil, tema claro/oscuro, onboarding.
- *Técnico:* Flutter + Provider; Firebase Auth, Realtime Database, Storage y Cloud Messaging; sensor
  acelerómetro; mapa nativo con `flutter_map`; caché de imágenes en disco.
- *Operativo / fuera de alcance:* panel administrativo (el catálogo se edita desde la consola de Firebase),
  cobro real con tarjetas (la pasarela está simulada; ver sección 5), facturación e inventario de cupos.

## 2. Puesta en marcha

```bash
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure      # elige/crea TU proyecto de Firebase; genera lib/firebase_options.dart
flutter run
```

**Consola de Firebase**
1. *Authentication → Sign-in method*: habilita **Correo/contraseña**, **Google** y **GitHub**
   (GitHub: crea una OAuth App y pega Client ID/Secret; copia la *callback URL* de Firebase en GitHub).
   Android: registra las huellas **SHA-1 y SHA-256** (`cd android && ./gradlew signingReport`).
2. *Realtime Database*: crea la base, pega `docs/database.rules.json` en *Rules* e importa
   `docs/seed_destinations.json` dentro del nodo `destinations` (⋮ → *Import JSON*).
3. *Storage*: pega `docs/storage.rules`. Sube tus fotos a `destinations/` y reemplaza `imageUrl` por las URL
   de descarga si quieres que el catálogo salga de Storage (las de ejemplo usan Unsplash).
4. *Cloud Messaging*: iOS requiere llave APNs y capacidad *Push Notifications*.
5. Android (`android/app/src/main/AndroidManifest.xml`), dentro de `<manifest>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
   `minSdk` 23 o superior en `android/app/build.gradle`.

## 3. Cobertura de requerimientos

| Requerimiento | Dónde está |
|---|---|
| Storage (multimedia) | `SessionProvider.updatePhoto` (avatar en `users/{uid}/avatar.jpg`) + imágenes del catálogo |
| Realtime Database | `DestinationProvider` (stream en vivo + persistencia offline), `orders/`, `subscriptions/`, `users/` |
| FCM desde la consola, sin backend | `NotificationProvider` |
| Listener global en todas las pantallas | provider con `lazy: false` en `main.dart` + `AppKeys.messenger` |
| Suscripción a Topics | `TopicsScreen` → `subscribeToTopic` |
| Foreground / background / terminated | `onMessage` / `onMessageOpenedApp` + handler top-level / `getInitialMessage` |
| Auth con ≥ 2 proveedores + correo | Google, GitHub y correo en `SessionProvider` / `LoginScreen` |
| Verificación, reenvío, recuperación | `VerifyEmailScreen` (con enfriamiento de 60 s), `ForgotPasswordScreen`, `RootGate` |
| Perfil y avatar sincronizado | `ProfileScreen`, `UserAvatar` (mismo provider en dashboard y perfil) |
| Foto editable solo con correo | `SessionProvider.canEditPhoto` |
| Estado sin `setState`/`ValueNotifier` | Provider en todo el proyecto (verificado con `grep`) |
| Fuentes y tema dinámico | Poppins en `resources/fonts`; 3 temas (Noche/Día/Cálido) en `ThemeApp`, cambio con `menuCircular` o desde el perfil vía `ThemeProvider` (persistente) |
| Onboarding | `OnboardingScreen` (4 pasos, se muestra una sola vez) |
| Responsivo móvil/escritorio | `NavigationBar` ↔ `NavigationRail`, rejillas con `MaxCrossAxisExtent`, ancho máximo |
| Widget avanzado (10 %) | `ParallaxDestinationCard` (`Flow` + `FlowDelegate` con parallax ligado al scroll) |
| Caché de imágenes offline | `cached_network_image` (`NetImage`, `UserAvatar`) + persistencia de Realtime Database |
| Sensor nativo | Acelerómetro (`ShakeProvider`): agitar = destino sorpresa, medidor en vivo |
| Mapa nativo | `MapScreen` y mini-mapa en el detalle (`flutter_map`, sin WebView) |
| Pagos (15 %) | `CheckoutScreen` + `CheckoutProvider` + `PaymentGateway`: pedido (carrito) y suscripción (3 planes) |

## 4. Cómo probar las notificaciones (sin backend)

Consola de Firebase → *Messaging → Nueva campaña → Mensajes de notificación*, destino **Tema** (`ofertas`, `playas`…).
- **Foreground:** con la app abierta aparece un aviso flotante y se guarda en la bandeja.
- **Background:** pon la app en segundo plano; llega a la bandeja del sistema; al tocarla abre la bandeja interna.
- **Terminated:** cierra la app por completo (deslizar); la notificación llega y al tocarla se abre en la bandeja.
Los temas FCM no existen en web/escritorio; allí se omite la suscripción.

## 5. Notas importantes

- **Pagos:** `SimulatedGateway` valida tarjeta (Luhn, vencimiento, CVV) y replica las tarjetas de prueba de Stripe
  (`4242…` aprobada, `4000 0000 0000 0002` rechazada, `4000 0000 0000 9995` sin fondos). Stripe y Mercado Pago
  necesitan crear el `PaymentIntent` / preferencia en un servidor; para integrarlos implementa `PaymentGateway`
  (por ejemplo con `flutter_stripe` y una Cloud Function) y pásalo a `CheckoutProvider(gateway: ...)`. La UI no cambia.
- **Mapa:** usa teselas de OpenStreetMap (sin API key, funciona también en escritorio). Si tu profesor exige Google Maps,
  cambia `FlutterMap` por `google_maps_flutter` en `map_screen.dart` y el mini-mapa del detalle.
- **Coordenadas de la agencia** en `map_screen.dart` son aproximadas: ajústalas a tu sucursal.
- Las versiones de `pubspec.yaml` pueden requerir `flutter pub upgrade --major-versions` según tu SDK.
- El código no se compiló en este entorno: ejecuta `flutter analyze` y corrige cualquier ajuste de versión.
