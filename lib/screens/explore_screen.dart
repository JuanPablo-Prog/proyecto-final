import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/components/responsive.dart';
import 'package:flutter_application_1/providers/destination_provider.dart';
import 'package:flutter_application_1/components/destination_card.dart';
import 'package:flutter_application_1/screens/destination_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DestinationProvider>();
    final list = p.filtered;

    return SafeArea(
      child: Responsive.constrained(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: p.setQuery,
                decoration: const InputDecoration(
                  hintText: 'Buscar destino o estado',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: DestinationProvider.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = DestinationProvider.categories[i];
                  return ChoiceChip(
                    label: Text(c),
                    selected: p.category == c,
                    onSelected: (_) => p.setCategory(c),
                  );
                },
              ),
            ),
            Expanded(
              child: p.loading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? const Center(child: Text('No hay destinos que coincidan'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisExtent: 270,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                          ),
                          itemCount: list.length,
                          itemBuilder: (_, i) => DestinationCard(
                            destination: list[i],
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => DestinationDetailScreen(destination: list[i]))),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
