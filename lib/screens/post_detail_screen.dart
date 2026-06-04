import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/posts_provider.dart';
import 'edit_post_screen.dart';

/// Note Detail Screen — shows full note content.
///
/// Operations demonstrated:
///   READ   — displays full title + body
///   UPDATE — navigates to EditNoteScreen
///   DELETE — shows confirmation dialog then fires DELETE /posts/:id
class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  Widget build(BuildContext context) {
    // Resolve the latest version of this note from the provider, in case it
    // was updated while the detail screen was open.
    final liveNote = context.select<NotesProvider, Note?>(
          (p) => p.notes.where((x) => x.id == note.id).firstOrNull,
        ) ??
        note;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Note #${liveNote.id}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditNoteScreen(note: liveNote),
              ),
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, liveNote),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User ID badge ─────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'User #${liveNote.userId}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              liveNote.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 28, color: Color(0xFFE5E7EB)),

            // ── Body ─────────────────────────────────────────────────────
            Text(
              liveNote.body,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF374151),
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),

            // ── Action buttons ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNoteScreen(note: liveNote),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Note'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, liveNote),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Note liveNote) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Note'),
        content: Text(
          '"${liveNote.title.length > 60 ? '${liveNote.title.substring(0, 60)}…' : liveNote.title}" will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await context.read<NotesProvider>().deleteNote(liveNote.id);
              if (context.mounted) {
                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete note.')),
                  );
                }
              }
            },
            child: const Text('Delete Note'),
          ),
        ],
      ),
    );
  }
}
