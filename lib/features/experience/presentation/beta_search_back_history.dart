import 'package:flutter/widgets.dart';

/// Embedded search is not a GoRoute. Real local history makes the enclosing
/// Navigator advertise a back target to Android, including predictive Back.
/// Dispatcher callbacks alone can be bypassed when Android sees a root page.
class BetaSearchBackHistory {
  ModalRoute<dynamic>? _route;
  LocalHistoryEntry? _search;
  LocalHistoryEntry? _results;
  bool _suppress = false;

  void synchronize({
    required ModalRoute<dynamic>? route,
    required bool visible,
    required bool hasResults,
    required VoidCallback onClose,
    required VoidCallback onClear,
  }) {
    if (route != _route) {
      clear();
      _route = route;
    }
    if (!visible || route == null) {
      clear();
      return;
    }
    if (_search == null) {
      _search = LocalHistoryEntry(
        impliesAppBarDismissal: false,
        onRemove: () {
          _search = null;
          if (!_suppress) onClose();
        },
      );
      route.addLocalHistoryEntry(_search!);
    }
    if (hasResults) {
      if (_results == null) {
        _results = LocalHistoryEntry(
          impliesAppBarDismissal: false,
          onRemove: () {
            _results = null;
            if (!_suppress) onClear();
          },
        );
        route.addLocalHistoryEntry(_results!);
      }
    } else {
      _removeResults();
    }
  }

  void _removeResults() {
    _suppress = true;
    _results?.remove();
    _results = null;
    _suppress = false;
  }

  void clear() {
    _removeResults();
    _suppress = true;
    _search?.remove();
    _search = null;
    _suppress = false;
  }
}
