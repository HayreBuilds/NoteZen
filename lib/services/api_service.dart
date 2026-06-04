import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post.dart';

/// Handles all HTTP communication with the JSONPlaceholder REST API.
///
/// Notes are stored as /posts on JSONPlaceholder (same data structure).
/// Equivalent to a Repository using the `http` package (Assignment 2)
/// or the `dio` package (Assignment 1).
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ─── READ ALL ────────────────────────────────────────────────────────────────

  /// Fetches all notes.  GET /posts
  Future<List<Note>> fetchNotes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts'),
      headers: _headers,
    );

    _checkStatus(response, 'fetch notes');

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ─── READ ONE ────────────────────────────────────────────────────────────────

  /// Fetches a single note by ID.  GET /posts/:id
  Future<Note> fetchNote(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: _headers,
    );

    _checkStatus(response, 'fetch note $id');

    return Note.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─── CREATE ──────────────────────────────────────────────────────────────────

  /// Creates a new note.  POST /posts
  Future<Note> createNote({required String title, required String body}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: _headers,
      body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
    );

    _checkStatus(response, 'create note');

    return Note.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─── UPDATE ──────────────────────────────────────────────────────────────────

  /// Updates an existing note.  PUT /posts/:id
  Future<Note> updateNote(Note note) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/${note.id}'),
      headers: _headers,
      body: jsonEncode(note.toJson()),
    );

    _checkStatus(response, 'update note ${note.id}');

    return Note.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─── DELETE ──────────────────────────────────────────────────────────────────

  /// Deletes a note by ID.  DELETE /posts/:id
  Future<void> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: _headers,
    );

    _checkStatus(response, 'delete note $id');
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  void _checkStatus(http.Response response, String operation) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to $operation — HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }
}
