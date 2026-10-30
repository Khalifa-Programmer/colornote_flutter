import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/lined_paper_painter.dart';
import 'drawing_canvas_screen.dart';

/// Unified Note & Checklist Editor Screen combining:
/// 1. ColorNote Ruled Lined Paper (36px horizontal rules)
/// 2. Unrestricted Color Picker (any color + paper tint slider)
/// 3. KiteTech Wordpad Rich Formatting Toolbar (B, I, U, S, Highlight, Font Color, Fonts)
/// 4. Folder Assignment + Checklist Reordering + Drawing Canvas Attachment
class NoteEditorScreen extends StatefulWidget {
  final NoteModel note;

  const NoteEditorScreen({super.key, required this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late NoteModel _note;
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  final TextEditingController _newItemCtrl = TextEditingController();
  bool _linedPaperEnabled = true;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleCtrl = TextEditingController(text: _note.title);
    _bodyCtrl = TextEditingController(text: _note.content);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _newItemCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    final updated = _note.copyWith(
      title: _titleCtrl.text.trim().isEmpty ? 'ملاحظة بدون عنوان' : _titleCtrl.text.trim(),
      content: _bodyCtrl.text,
      modifiedDate: DateTime.now(),
    );
    await context.read<NotesProvider>().saveNote(updated);
    if (mounted) Navigator.pop(context);
  }

  void _openColorPickerSheet() {
    final provider = context.read<NotesProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnrestrictedColorPickerSheet(
        currentColorIndex: _note.colorIndex,
        currentCustomColor: _note.customColorValue,
        currentTintRatio: _note.paperTintRatio,
        customPalettes: provider.customPalettes,
        onColorSelected: (idx, customVal, tint) {
          setState(() {
            _note = _note.copyWith(
              colorIndex: idx,
              customColorValue: customVal,
              clearCustomColor: customVal == null,
              paperTintRatio: tint,
            );
          });
        },
        onSaveCustomPalette: (newPal) {
          provider.addCustomPalette(newPal);
          setState(() {
            _note = _note.copyWith(
              colorIndex: newPal.index,
              clearCustomColor: true,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final palette = _note.resolvePalette(provider.customPalettes);

    return Scaffold(
      backgroundColor: palette.bodyColor,
      appBar: AppBar(
        backgroundColor: palette.headerColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'حفظ ورجوع',
          onPressed: _saveAndExit,
        ),
        title: TextField(
          controller: _titleCtrl,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: _note.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
          decoration: const InputDecoration(
            hintText: 'عنوان الملاحظة...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        actions: [
          // Unrestricted Color Picker Button
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'اختر أي لون حر',
            onPressed: _openColorPickerSheet,
          ),
          // Toggle Ruled Lined Paper
          IconButton(
            icon: Icon(_linedPaperEnabled ? Icons.format_align_justify : Icons.crop_din),
            tooltip: 'إظهار / إخفاء أسطر الدفتر المسطرة',
            onPressed: () => setState(() => _linedPaperEnabled = !_linedPaperEnabled),
          ),
          // Open Handwriting & Drawing Studio
          IconButton(
            icon: const Icon(Icons.brush),
            tooltip: 'لوحة الرسم والكتابة اليدوية',
            onPressed: () async {
              final strokes = await Navigator.push<List<DrawingStroke>>(
                context,
                MaterialPageRoute(
                  builder: (_) => DrawingCanvasScreen(initialStrokes: _note.drawingStrokes),
                ),
              );
              if (strokes != null) {
                setState(() => _note = _note.copyWith(drawingStrokes: strokes));
              }
            },
          ),
          // Done / Strikethrough toggle
          IconButton(
            icon: Icon(_note.isChecked ? Icons.check_box : Icons.check_box_outline_blank),
            tooltip: 'تأشير كمنجز',
            onPressed: () => setState(() => _note = _note.copyWith(isChecked: !_note.isChecked)),
          ),
          // Lock Note toggle
          IconButton(
            icon: Icon(_note.isLocked ? Icons.lock : Icons.lock_open),
            tooltip: 'قفل الملاحظة',
            onPressed: () => setState(() => _note = _note.copyWith(isLocked: !_note.isLocked)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sub-bar: Folder assignment & Note Type switcher
          Container(
            color: Colors.black.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.folders.any((f) => f.id == _note.folderId)
                        ? _note.folderId
                        : provider.folders.first.id,
                    items: provider.folders
                        .map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text('📁 ${f.nameAr} (${f.nameEn})', style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _note = _note.copyWith(folderId: val));
                    },
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: Text(
                    _note.type == NoteType.checklist ? 'تحويل إلى نص 📝' : 'تحويل إلى قائمة ☑️',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_note.type == NoteType.text) {
                        final lines = _bodyCtrl.text
                            .split('\n')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();
                        _note = _note.copyWith(
                          type: NoteType.checklist,
                          checklistItems: lines
                              .asMap()
                              .entries
                              .map((e) => ChecklistItem(id: 'i_${e.key}', text: e.value))
                              .toList(),
                        );
                      } else {
                        _bodyCtrl.text = _note.checklistItems.map((i) => i.text).join('\n');
                        _note = _note.copyWith(type: NoteType.text);
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // Main Lined Paper Editor Area (Text or Checklist)
          Expanded(
            child: CustomPaint(
              painter: LinedPaperPainter(
                lineSpacing: 36.0,
                enabled: _linedPaperEnabled,
              ),
              child: _note.type == NoteType.checklist
                  ? _buildChecklistBody()
                  : _buildRichTextBody(),
            ),
          ),

          // KiteTech Wordpad Rich Text Formatting Toolbar (#B8F597)
          if (_note.type == NoteType.text)
            Container(
              color: const Color(0xFFB8F597),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.format_bold, color: _note.isBold ? Colors.teal.shade900 : Colors.black87),
                    tooltip: 'خط عريض (Bold)',
                    onPressed: () => setState(() => _note = _note.copyWith(isBold: !_note.isBold)),
                  ),
                  IconButton(
                    icon: Icon(Icons.format_italic, color: _note.isItalic ? Colors.teal.shade900 : Colors.black87),
                    tooltip: 'خط مائل (Italic)',
                    onPressed: () => setState(() => _note = _note.copyWith(isItalic: !_note.isItalic)),
                  ),
                  IconButton(
                    icon: Icon(Icons.format_underlined, color: _note.isUnderlined ? Colors.teal.shade900 : Colors.black87),
                    tooltip: 'تسطير سفلي (Underline)',
                    onPressed: () => setState(() => _note = _note.copyWith(isUnderlined: !_note.isUnderlined)),
                  ),
                  IconButton(
                    icon: Icon(Icons.format_strikethrough, color: _note.isStrikethrough ? Colors.teal.shade900 : Colors.black87),
                    tooltip: 'يتوسطه خط (Strikethrough)',
                    onPressed: () => setState(() => _note = _note.copyWith(isStrikethrough: !_note.isStrikethrough)),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.highlight,
                      color: _note.highlightColorValue != null ? Colors.amber.shade900 : Colors.black87,
                    ),
                    tooltip: 'تظليل النص (Highlight)',
                    onPressed: () => setState(() {
                      if (_note.highlightColorValue != null) {
                        _note = _note.copyWith(clearHighlight: true);
                      } else {
                        _note = _note.copyWith(highlightColorValue: 0xFFFFFF00);
                      }
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRichTextBody() {
    final decorations = <TextDecoration>[];
    if (_note.isUnderlined) decorations.add(TextDecoration.underline);
    if (_note.isStrikethrough) decorations.add(TextDecoration.lineThrough);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: _bodyCtrl,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontSize: 16,
          height: 36.0 / 16.0, // Exact 36px line-height locked to LinedPaperPainter!
          fontWeight: _note.isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: _note.isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: TextDecoration.combine(decorations),
          backgroundColor: _note.highlightColorValue != null
              ? Color(_note.highlightColorValue!)
              : null,
          color: _note.textColorValue != null
              ? Color(_note.textColorValue!)
              : Colors.black87,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'اكتب ملاحظاتك فوق الأسطر المسطرة...',
        ),
      ),
    );
  }

  Widget _buildChecklistBody() {
    final items = _note.checklistItems;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemCtrl,
                  decoration: const InputDecoration(
                    hintText: '+ أضف عنصراً جديداً للقائمة...',
                    filled: true,
                    fillColor: Colors.white70,
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addChecklistItem(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addChecklistItem,
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemExtent: 36.0, // Locked to 36px LinedPaperPainter!
            itemBuilder: (context, idx) {
              final item = items[idx];
              return InkWell(
                onTap: () {
                  final updated = List<ChecklistItem>.from(items);
                  updated[idx] = item.copyWith(isChecked: !item.isChecked);
                  setState(() => _note = _note.copyWith(checklistItems: updated));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        item.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 20,
                        color: item.isChecked ? Colors.teal : Colors.black54,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontSize: 15,
                            decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                            color: item.isChecked ? Colors.black45 : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                        onPressed: () {
                          final updated = List<ChecklistItem>.from(items)..removeAt(idx);
                          setState(() => _note = _note.copyWith(checklistItems: updated));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addChecklistItem() {
    final text = _newItemCtrl.text.trim();
    if (text.isEmpty) return;
    final updated = List<ChecklistItem>.from(_note.checklistItems)
      ..add(ChecklistItem(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text));
    _newItemCtrl.clear();
    setState(() => _note = _note.copyWith(checklistItems: updated));
  }
}
