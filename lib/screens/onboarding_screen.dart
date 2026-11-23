import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/onboarding_provider.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String text;
  const _Slide(this.icon, this.title, this.text);
}

const _slides = [
  _Slide(Icons.travel_explore, 'Descubre México',
      'Explora playas, Pueblos Mágicos y rutas de aventura curadas por nuestra agencia.'),
  _Slide(Icons.vibration, 'Agita y sorpréndete',
      'Sacude tu teléfono y el acelerómetro te sugerirá un destino sorpresa.'),
  _Slide(Icons.workspace_premium_outlined, 'Reserva y ahorra',
      'Paga tus paquetes en la app y suscríbete para obtener hasta 20% de descuento.'),
  _Slide(Icons.notifications_active_outlined, 'Entérate primero',
      'Suscríbete a temas de interés y recibe ofertas en tiempo real.'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isLast = ob.page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Responsive.constrained(
          max: 640,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: ob.finish,
                  child: const Text('Omitir'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: ob.setPage,
                  itemBuilder: (_, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(s.icon, size: 88, color: scheme.onPrimaryContainer),
                          ),
                          const SizedBox(height: 40),
                          Text(s.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Text(s.text,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: i == ob.page ? 26 : 8,
                    decoration: BoxDecoration(
                      color: i == ob.page ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  onPressed: () {
                    if (isLast) {
                      ob.finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(isLast ? 'Comenzar' : 'Siguiente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
