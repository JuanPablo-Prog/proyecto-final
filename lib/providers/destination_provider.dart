import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/database/destination_dao.dart';

/// Catálogo en tiempo real desde Firebase Realtime Database.
/// Con la persistencia activada (main.dart) también funciona sin internet.
class DestinationProvider extends ChangeNotifier {
  static const categories = ['Todos', 'Playa', 'Pueblo Mágico', 'Aventura', 'Cultura'];

  StreamSubscription<DatabaseEvent>? _sub;
  List<DestinationDAO> _all = [];
  bool loading = true;
  String? error;
  String _query = '';
  String _category = 'Todos';

  DestinationProvider() {
    final ref = FirebaseDatabase.instance.ref('destinations');
    if (!kIsWeb) ref.keepSynced(true);
    _sub = ref.onValue.listen(_onData, onError: (Object e) {
      error = 'No se pudo cargar el catálogo';
      loading = false;
      notifyListeners();
    });
  }

  void _onData(DatabaseEvent event) {
    final value = event.snapshot.value;
    final list = <DestinationDAO>[];
    if (value is Map) {
      value.forEach((k, v) {
        if (v is Map) list.add(DestinationDAO.fromMap(k.toString(), v));
      });
    }
    list.sort((a, b) => b.rating.compareTo(a.rating));
    _all = list;
    loading = false;
    error = null;
    notifyListeners();
  }

  List<DestinationDAO> get all => _all;
  List<DestinationDAO> get featured => _all.take(6).toList();
  String get category => _category;
  String get query => _query;

  List<DestinationDAO> get filtered {
    return _all.where((d) {
      final okCat = _category == 'Todos' || d.category == _category;
      final q = _query.trim().toLowerCase();
      final okQ = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.state.toLowerCase().contains(q);
      return okCat && okQ;
    }).toList();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategory(String c) {
    _category = c;
    notifyListeners();
  }

  DestinationDAO? byId(String id) {
    for (final d in _all) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
