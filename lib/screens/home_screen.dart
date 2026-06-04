import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'create_post_screen.dart';

/// Home Screen — displays the full list of notes fetched from the API.
///
/// Operations demonstrated: READ (list all notes), DELETE (from card).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Fetch notes after the first frame so the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().fetchNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search notes…',
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<NotesProvider>().fetchNotes(),
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          // ── Loading ───────────────────────────────────────────────────────
          if (provider.isListLoading && provider.notes.isEmpty) {
            return const LoadingWidget(label: 'Fetching notes…');
          }

          // ── Error ─────────────────────────────────────────────────────────
          if (provider.isListError && provider.notes.isEmpty) {
            return AppErrorWidget(
              message: provider.errorMessage ?? 'Unknown error',
              onRetry: provider.fetchNotes,
            );
          }

          // ── Filter ────────────────────────────────────────────────────────
          final notes = _query.isEmpty
              ? provider.notes
              : provider.notes.where((n) {
                  return n.title.toLowerCase().contains(_query) ||
                      n.body.toLowerCase().contains(_query);
                }).toList();

          // ── Empty state ───────────────────────────────────────────────────
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notes_outlined,
                      size: 52, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 12),
                  Text(
                    _query.isEmpty
                        ? 'No notes yet — tap + to create one'
                        : 'No results for "$_query"',
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 15),
                  ),
                ],
              ),
            );
          }

          // ── List ──────────────────────────────────────────────────────────
          return RefreshIndicator(
            color: const Color(0xFF4F46E5),
            onRefresh: provider.fetchNotes,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        '${notes.length} note${notes.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 100),
                    itemCount: notes.length,
                    itemBuilder: (_, i) => NoteCard(note: notes[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
        ),
        tooltip: 'New Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
