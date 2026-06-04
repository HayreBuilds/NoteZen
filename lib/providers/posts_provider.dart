import 'package:flutter/foundation.dart';

import '../models/post.dart';
import '../services/api_service.dart';

/// Possible states for any async operation.
enum LoadingStatus { idle, loading, success, error }

/// Global state manager for Notes using the Provider / ChangeNotifier pattern.
///
/// This is the equivalent of:
///  - Flutter Provider's ChangeNotifier (Assignment 2)
///  - Flutter Bloc's Bloc + State classes  (Assignment 1)
///
/// Responsibilities:
///  1. Hold the canonical list of notes in memory.
///  2. Track loading / error status for list operations and mutations.
///  3. Delegate all network I/O to [ApiService].
///  4. Call [notifyListeners] so the UI rebuilds automatically.
class NotesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ─── State ───────────────────────────────────────────────────────────────────

  List<Note> _notes = [];
  LoadingStatus _listStatus = LoadingStatus.idle;
  LoadingStatus _mutationStatus = LoadingStatus.idle;
  String? _errorMessage;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  List<Note> get notes => List.unmodifiable(_notes);
  LoadingStatus get listStatus => _listStatus;
  LoadingStatus get mutationStatus => _mutationStatus;
  String? get errorMessage => _errorMessage;

  bool get isListLoading => _listStatus == LoadingStatus.loading;
  bool get isListError => _listStatus == LoadingStatus.error;
  bool get isMutating => _mutationStatus == LoadingStatus.loading;

  // ─── READ ALL ────────────────────────────────────────────────────────────────

  Future<void> fetchNotes() async {
    _listStatus = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await _api.fetchNotes();
      _listStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _listStatus = LoadingStatus.error;
    }

    notifyListeners();
  }

  // ─── CREATE ──────────────────────────────────────────────────────────────────

  Future<bool> createNote({required String title, required String body}) async {
    _mutationStatus = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _api.createNote(title: title, body: body);
      // Prepend so the new note appears at the top of the list.
      _notes = [created, ..._notes];
      _mutationStatus = LoadingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _mutationStatus = LoadingStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── UPDATE ──────────────────────────────────────────────────────────────────

  Future<bool> updateNote(Note updated) async {
    _mutationStatus = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final saved = await _api.updateNote(updated);
      _notes = _notes.map((n) => n.id == saved.id ? saved : n).toList();
      _mutationStatus = LoadingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _mutationStatus = LoadingStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── DELETE ──────────────────────────────────────────────────────────────────

  Future<bool> deleteNote(int id) async {
    _mutationStatus = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.deleteNote(id);
      _notes = _notes.where((n) => n.id != id).toList();
      _mutationStatus = LoadingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _mutationStatus = LoadingStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  void resetMutationStatus() {
    _mutationStatus = LoadingStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
