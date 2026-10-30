import 'package:flutter/material.dart';
import '../core/constants/note_colors.dart';
import '../data/database/database_helper.dart';
import '../data/models/note_model.dart';

enum SortOrder { byColor, byModifiedTime, byCreatedTime, byAlphabet, byReminder }
enum ViewLayout { list, grid, details, largeGrid }
enum AppThemeStyle { kiteTechGreen, kiteTechBlue, amoledBlack, colorNoteWhite }

class NotesProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  List<FolderModel> _folders = [];
  final List<NoteColorPalette> _customPalettes = [];

  SortOrder _sortOrder = SortOrder.byColor;
  ViewLayout _viewLayout = ViewLayout.list;
  AppThemeStyle _appThemeStyle = AppThemeStyle.kiteTechGreen;
  int? _selectedColorFilter;
  String _selectedFolderId = 'all';
  String _searchQuery = '';
  String _masterPin = '1234';

  List<NoteModel> get notes => _filteredAndSortedNotes(NoteStatus.active);
  List<NoteModel> get archivedNotes => _filteredAndSortedNotes(NoteStatus.archived);
  List<NoteModel> get trashNotes => _filteredAndSortedNotes(NoteStatus.trash);
  List<FolderModel> get folders => _folders;
  List<NoteColorPalette> get customPalettes => _customPalettes;

  SortOrder get sortOrder => _sortOrder;
  ViewLayout get viewLayout => _viewLayout;
  AppThemeStyle get appThemeStyle => _appThemeStyle;
  int? get selectedColorFilter => _selectedColorFilter;
  String get selectedFolderId => _selectedFolderId;

  Future<void> loadNotes() async {
    _folders = await DatabaseHelper.instance.fetchFolders();
    _notes = await DatabaseHelper.instance.fetchAllNotes();
    notifyListeners();
  }

  void cycleAppThemeStyle() {
    final nextIdx = (_appThemeStyle.index + 1) % AppThemeStyle.values.length;
    _appThemeStyle = AppThemeStyle.values[nextIdx];
    notifyListeners();
  }

  void addCustomPalette(NoteColorPalette palette) {
    _customPalettes.add(palette);
    notifyListeners();
  }

  Future<void> createFolder(String nameAr, String nameEn) async {
    final folder = FolderModel(
      id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
      nameAr: nameAr,
      nameEn: nameEn,
    );
    await DatabaseHelper.instance.insertFolder(folder);
    _folders = await DatabaseHelper.instance.fetchFolders();
    notifyListeners();
  }

  void setFolderFilter(String folderId) {
    _selectedFolderId = folderId;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setViewLayout(ViewLayout layout) {
    _viewLayout = layout;
    notifyListeners();
  }

  void setColorFilter(int? colorIndex) {
    _selectedColorFilter = colorIndex;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool verifyPin(String input) => input == _masterPin;

  List<NoteModel> _filteredAndSortedNotes(NoteStatus status) {
    final list = _notes.where((n) {
      if (n.status != status) return false;
      if (_selectedColorFilter != null && n.colorIndex != _selectedColorFilter) {
        return false;
      }
      if (status == NoteStatus.active && _selectedFolderId != 'all' && n.folderId != _selectedFolderId) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final inTitle = n.title.toLowerCase().contains(q);
        final inBody = !n.isLocked && n.content.toLowerCase().contains(q);
        return inTitle || inBody;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      switch (_sortOrder) {
        case SortOrder.byColor:
          final cmp = a.colorIndex.compareTo(b.colorIndex);
          return cmp != 0 ? cmp : b.modifiedDate.compareTo(a.modifiedDate);
        case SortOrder.byModifiedTime:
          return b.modifiedDate.compareTo(a.modifiedDate);
        case SortOrder.byCreatedTime:
          return b.createdDate.compareTo(a.createdDate);
        case SortOrder.byAlphabet:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOrder.byReminder:
          final remA = a.reminderDate?.millisecondsSinceEpoch ?? 0;
          final remB = b.reminderDate?.millisecondsSinceEpoch ?? 0;
          return remB.compareTo(remA);
      }
    });
    return list;
  }

  Future<void> saveNote(NoteModel note) async {
    if (note.id == null) {
      await DatabaseHelper.instance.insertNote(note);
    } else {
      await DatabaseHelper.instance.updateNote(note);
    }
    await loadNotes();
  }
}
