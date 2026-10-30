import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/note_model.dart';
import '../../providers/notes_provider.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final palette = note.resolvePalette(provider.customPalettes);
    final isAmoled = provider.appThemeStyle == AppThemeStyle.amoledBlack;
    final dateStr = DateFormat('MMM d').format(note.modifiedDate);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: isAmoled ? 66 : 54,
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        decoration: BoxDecoration(
          color: isAmoled ? Colors.black : palette.bodyColor,
          border: Border(
            left: BorderSide(color: palette.stripeColor, width: 8),
            bottom: BorderSide(
              color: isAmoled ? const Color(0xFF55B535) : Colors.black.withOpacity(0.08),
              width: isAmoled ? 1.5 : 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                note.title.isEmpty ? '(بدون عنوان)' : note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isAmoled
                      ? Colors.white
                      : (note.isChecked ? Colors.black45 : palette.textColor),
                  decoration: note.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (note.drawingStrokes.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.brush, size: 16, color: Colors.teal),
              ),
            if (note.isLocked)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.lock, size: 16, color: isAmoled ? Colors.white70 : Colors.black54),
              ),
            if (note.isChecked)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 16, color: isAmoled ? Colors.greenAccent : Colors.black54),
              ),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12,
                color: isAmoled ? const Color(0xFF55B535) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
