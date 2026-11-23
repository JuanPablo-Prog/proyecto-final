import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/database/destination_dao.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/destination_provider.dart';
import 'package:flutter_application_1/providers/navigation_provider.dart';
import 'package:flutter_application_1/providers/shake_provider.dart';
import 'package:flutter_application_1/components/menu_circular.dart';
import 'package:flutter_application_1/components/user_avatar.dart';
import 'package:flutter_application_1/providers/session_provider.dart';
import 'package:flutter_application_1/screens/cart_screen.dart';
import 'package:flutter_application_1/screens/destination_detail_screen.dart';
import 'package:flutter_application_1/screens/explore_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/components/net_image.dart';
import 'package:flutter_application_1/components/destination_card.dart';

/// Contenedor principal RESPONSIVO:
///  - móvil  : NavigationBar inferior
///  - tablet / escritorio: NavigationRail lateral
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ShakeProvider _shake;

  @override
  void initState() {
    super.initState();
    _shake = context.read<ShakeProvider>();
    // Sensor activo mientras el usuario está dentro de la app.
    _shake.start(
      source: () => context.read<DestinationProvider>().all,
      onShake: _showSurprise,
    );
  }

  @override
  void dispose() {
    _shake.stop();
    super.dispose();
  }

  void _showSurprise(DestinationDAO d) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¡Destino sorpresa!',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(height: 170, width: double.infinity, child: NetImage(d.imageUrl)),
            ),
            const SizedBox(height: 12),
            Text(d.name, style: Theme.of(ctx).textTheme.titleMedium),
            Text('${d.state} · desde ${money.format(d.price)}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DestinationDetailScreen(destination: d)));
              },
              child: const Text('Ver destino'),
            ),
          ],
        ),
      ),
    );
  }

  static const _pages = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    CartScreen(embedded: true),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final cartCount = context.select<CartProvider, int>((c) => c.count);
    final wide = MediaQuery.sizeOf(context).width >= 760;

    final cartIcon = Badge(
      isLabelVisible: cartCount > 0,
      label: Text('$cartCount'),
      child: const Icon(Icons.shopping_bag_outlined),
    );

    final body = IndexedStack(index: nav.index, children: _pages);
    final drawer = _buildDrawer(context);
    // Menú circular de temas (solo en el dashboard), como en tu práctica.
    final fab = nav.index == 0 ? const menuCircular() : null;

    if (wide) {
      return Scaffold(
        endDrawer: drawer,
        floatingActionButton: fab,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: nav.index,
              onDestinationSelected: nav.go,
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Inicio')),
                const NavigationRailDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: Text('Explorar')),
                NavigationRailDestination(icon: cartIcon, label: const Text('Carrito')),
                const NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Perfil')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      endDrawer: drawer,
      floatingActionButton: fab,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        onDestinationSelected: nav.go,
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explorar'),
          NavigationDestination(icon: cartIcon, label: 'Carrito'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  /// Drawer lateral (endDrawer) con los datos del usuario, igual que tu dashboard.
  Widget _buildDrawer(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final url = session.photoUrl;

    void go(String route) {
      Navigator.of(context).pop(); // cierra el drawer
      Navigator.of(context).pushNamed(route);
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(session.displayName),
            accountEmail: Text(session.email),
            currentAccountPicture: const UserAvatar(radius: 36),
            key: ValueKey(url),
          ),
          ListTile(
            title: const Text('Planes de suscripción'),
            subtitle: const Text('Ahorra en tus viajes'),
            leading: const Icon(Icons.workspace_premium_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => go('/plans'),
          ),
          ListTile(
            title: const Text('Ubicación de la agencia'),
            subtitle: const Text('Mapa'),
            leading: const Icon(Icons.map_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => go('/map'),
          ),
          ListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Ofertas y avisos'),
            leading: const Icon(Icons.notifications_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => go('/notifications'),
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            subtitle: const Text('Salir'),
            leading: const Icon(Icons.logout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pop();
              session.signOut();
            },
          ),
        ],
      ),
    );
  }
}
