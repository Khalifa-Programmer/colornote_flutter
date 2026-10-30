import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/note_colors.dart';

enum NoteType { text, checklist, drawing }
enum NoteStatus { active, archived, trash }

class FolderModel {
  final String id;
  final String nameAr;
  final String nameEn;

  const FolderModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  Map<String, dynamic> toMap() => {'id': id, 'nameAr': nameAr, 'nameEn': nameEn};

  factory FolderModel.fromMap(Map<String, dynamic> map) => FolderModel(
        id: map['id'] as String,
        nameAr: map['nameAr'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
      );
}

class ChecklistItem {
  final String id;
  final String text;
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  ChecklistItem copyWith({String? id, String? text, bool? isChecked}) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isChecked': isChecked,
      };

  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
        id: map['id'] as String,
        text: map['text'] as String,
        isChecked: map['isChecked'] as bool? ?? false,
      );
}

class DrawingStroke {
  final List<Offset> points;
  final int colorValue;
  final double strokeWidth;
  final bool isEraser;

  const DrawingStroke({
    required this.points,
    required this.colorValue,
    required this.strokeWidth,
    this.isEraser = false,
  });

  Map<String, dynamic> toMap() => {
        'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
        'colorValue': colorValue,
        'strokeWidth': strokeWidth,
        'isEraser': isEraser,
      };

  factory DrawingStroke.fromMap(Map<String, dynamic> map) {
    final pts = (map['points'] as List<dynamic>? ?? [])
        .map((p) => Offset((p['dx'] as num).toDouble(), (p['dy'] as num).toDouble()))
        .toList();
    return DrawingStroke(
      points: pts,
      colorValue: map['colorValue'] as int? ?? 0xFF000000,
      strokeWidth: (map['strokeWidth'] as num? ?? 4.0).toDouble(),
      isEraser: map['isEraser'] as bool? ?? false,
    );
  }
}

class NoteModel {
  final int? id;
  final NoteType type;
  final String title;
  final String content;
  final List<ChecklistItem> checklistItems;
  final List<DrawingStroke> drawingStrokes;
  final List<String> imagePaths;
  final String folderId;
  final int colorIndex;
  final int? customColorValue; // Unrestricted custom color ARGB value
  final double paperTintRatio; // 0.45..0.95 paper lightness
  final bool isBold;
  final bool isItalic;
  final bool isUnderlined;
  final bool isStrikethrough;
  final int? highlightColorValue;
  final int? textColorValue;
  final String fontFamily;
  final DateTime createdDate;
  final DateTime modifiedDate;
  final DateTime? reminderDate;
  final bool isChecked;
  final bool isLocked;
  final NoteStatus status;
  final bool isWidgetPinned;

  const NoteModel({
    this.id,
    required this.type,
    required this.title,
    this.content = '',
    this.checklistItems = const [],
    this.drawingStrokes = const [],
    this.imagePaths = const [],
    this.folderId = 'important',
    this.colorIndex = 2,
    this.customColorValue,
    this.paperTintRatio = 0.84,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderlined = false,
    this.isStrikethrough = false,
    this.highlightColorValue,
    this.textColorValue,
    this.fontFamily = 'Cairo',
    required this.createdDate,
    required this.modifiedDate,
    this.reminderDate,
    this.isChecked = false,
    this.isLocked = false,
    this.status = NoteStatus.active,
    this.isWidgetPinned = false,
  });

  NoteColorPalette resolvePalette([List<NoteColorPalette> customPalettes = const []]) {
    if (customColorValue != null) {
      return NoteColorPalette.fromCustomColor(
        Color(customColorValue!),
        paperWhiteRatio: paperTintRatio,
      );
    }
    return NoteColors.byIndex(colorIndex, customPalettes);
  }

  NoteModel copyWith({
    int? id,
    NoteType? type,
    String? title,
    String? content,
    List<ChecklistItem>? checklistItems,
    List<DrawingStroke>? drawingStrokes,
    List<String>? imagePaths,
    String? folderId,
    int? colorIndex,
    int? customColorValue,
    bool clearCustomColor = false,
    double? paperTintRatio,
    bool? isBold,
    bool? isItalic,
    bool? isUnderlined,
    bool? isStrikethrough,
    int? highlightColorValue,
    bool clearHighlight = false,
    int? textColorValue,
    String? fontFamily,
    DateTime? createdDate,
    DateTime? modifiedDate,
    DateTime? reminderDate,
    bool clearReminder = false,
    bool? isChecked,
    bool? isLocked,
    NoteStatus? status,
    bool? isWidgetPinned,
  }) {
    return NoteModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      checklistItems: checklistItems ?? this.checklistItems,
      drawingStrokes: drawingStrokes ?? this.drawingStrokes,
      imagePaths: imagePaths ?? this.imagePaths,
      folderId: folderId ?? this.folderId,
      colorIndex: colorIndex ?? this.colorIndex,
      customColorValue: clearCustomColor ? null : (customColorValue ?? this.customColorValue),
      paperTintRatio: paperTintRatio ?? this.paperTintRatio,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderlined: isUnderlined ?? this.isUnderlined,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      highlightColorValue: clearHighlight ? null : (highlightColorValue ?? this.highlightColorValue),
      textColorValue: textColorValue ?? this.textColorValue,
      fontFamily: fontFamily ?? this.fontFamily,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      reminderDate: clearReminder ? null : (reminderDate ?? this.reminderDate),
      isChecked: isChecked ?? this.isChecked,
      isLocked: isLocked ?? this.isLocked,
      status: status ?? this.status,
      isWidgetPinned: isWidgetPinned ?? this.isWidgetPinned,
    );
  }

  Map<String, dynamic> toSqlMap() {
    return {
      if (id != null) '_id': id,
      'type': type.index,
      'title': title,
      'note': content,
      'checklist_json': jsonEncode(checklistItems.map((e) => e.toMap()).toList()),
      'drawing_json': jsonEncode(drawingStrokes.map((e) => e.toMap()).toList()),
      'images_json': jsonEncode(imagePaths),
      'folder_id': folderId,
      'color_index': colorIndex,
      'custom_color': customColorValue,
      'paper_tint': paperTintRatio,
      'style_json': jsonEncode({
        'bold': isBold,
        'italic': isItalic,
        'underline': isUnderlined,
        'strike': isStrikethrough,
        'highlight': highlightColorValue,
        'textColor': textColorValue,
        'fontFamily': fontFamily,
      }),
      'created_date': createdDate.millisecondsSinceEpoch,
      'modified_date': modifiedDate.millisecondsSinceEpoch,
      'reminder_date': reminderDate?.millisecondsSinceEpoch ?? 0,
      'checked': isChecked ? 1 : 0,
      'locked': isLocked ? 1 : 0,
      'status': status.index,
      'widget_pinned': isWidgetPinned ? 1 : 0,
    };
  }

  factory NoteModel.fromSqlMap(Map<String, dynamic> map) {
    final typeIdx = (map['type'] as int? ?? 0).clamp(0, 2);
    List<ChecklistItem> parsedItems = [];
    List<DrawingStroke> parsedStrokes = [];
    List<String> parsedImages = [];
    Map<String, dynamic> styleMap = {};

    try {
      if (map['checklist_json'] != null) {
        parsedItems = (jsonDecode(map['checklist_json'] as String) as List<dynamic>)
            .map((e) => ChecklistItem.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      if (map['drawing_json'] != null) {
        parsedStrokes = (jsonDecode(map['drawing_json'] as String) as List<dynamic>)
            .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      if (map['images_json'] != null) {
        parsedImages = (jsonDecode(map['images_json'] as String) as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
      if (map['style_json'] != null) {
        styleMap = jsonDecode(map['style_json'] as String) as Map<String, dynamic>;
      }
    } catch (_) {}

    final remMs = map['reminder_date'] as int? ?? 0;
    return NoteModel(
      id: map['_id'] as int?,
      type: NoteType.values[typeIdx],
      title: map['title'] as String? ?? '',
      content: map['note'] as String? ?? '',
      checklistItems: parsedItems,
      drawingStrokes: parsedStrokes,
      imagePaths: parsedImages,
      folderId: map['folder_id'] as String? ?? 'important',
      colorIndex: map['color_index'] as int? ?? 2,
      customColorValue: map['custom_color'] as int?,
      paperTintRatio: (map['paper_tint'] as num? ?? 0.84).toDouble(),
      isBold: styleMap['bold'] as bool? ?? false,
      isItalic: styleMap['italic'] as bool? ?? false,
      isUnderlined: styleMap['underline'] as bool? ?? false,
      isStrikethrough: styleMap['strike'] as bool? ?? false,
      highlightColorValue: styleMap['highlight'] as int?,
      textColorValue: styleMap['textColor'] as int?,
      fontFamily: styleMap['fontFamily'] as String? ?? 'Cairo',
      createdDate: DateTime.fromMillisecondsSinceEpoch(
          map['created_date'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      modifiedDate: DateTime.fromMillisecondsSinceEpoch(
          map['modified_date'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      reminderDate:
          remMs > 0 ? DateTime.fromMillisecondsSinceEpoch(remMs) : null,
      isChecked: (map['checked'] as int? ?? 0) == 1,
      isLocked: (map['locked'] as int? ?? 0) == 1,
      status: NoteStatus.values[(map['status'] as int? ?? 0).clamp(0, 2)],
      isWidgetPinned: (map['widget_pinned'] as int? ?? 0) == 1,
    );
  }
}
