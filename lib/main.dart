import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/note_colors.dart';
import 'data/models/note_model.dart';
import 'providers/notes_provider.dart';
import 'presentation/screens/note_editor_screen.dart';
import 'presentation/widgets/note_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider()..loadNotes(),
      child: const ColorNoteSimpleMergedApp(),
    ),
  );
}

class ColorNoteSimpleMergedApp extends StatelessWidget {
  const ColorNoteSimpleMergedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorNote × Simple Notepad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF55B535)),
        useMaterial3: true,
      ),
      home: const MergedHomeScreen(),
    );
  }
}

class MergedHomeScreen extends StatefulWidget {
  const MergedHomeScreen({super.key});

  @override
  State<MergedHomeScreen> createState() => _MergedHomeScreenState();
}

class _MergedHomeScreenState extends State<MergedHomeScreen> {
  int _currentTab = 0;
  bool _showFoldersDirectory = false;

  Color _resolveAppBarColor(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.kiteTechGreen:
      case AppThemeStyle.amoledBlack:
        return const Color(0xFF55B535);
      case AppThemeStyle.kiteTechBlue:
        return const Color(0xFF29B6F6);
      case AppThemeStyle.colorNoteWhite:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.notes;
    final appBarColor = _resolveAppBarColor(provider.appThemeStyle);
    final isWhiteBar = provider.appThemeStyle == AppThemeStyle.colorNoteWhite;
    final isAmoled = provider.appThemeStyle == AppThemeStyle.amoledBlack;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isAmoled ? Colors.black : const Color(0xFFF3F3F3),
        appBar: AppBar(
          backgroundColor: appBarColor,
          foregroundColor: isWhiteBar ? Colors.black87 : Colors.white,
          elevation: 1,
          title: const Text(
            'ColorNote × Simple Notepad',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              tooltip: 'عرض المجلدات (Folders)',
              onPressed: () => setState(() => _showFoldersDirectory = !_showFoldersDirectory),
            ),
            IconButton(
              icon: const Icon(Icons.color_lens_outlined),
              tooltip: 'تغيير مظهر التطبيق (Green / Blue / AMOLED / White)',
              onPressed: provider.cycleAppThemeStyle,
            ),
            PopupMenuButton<SortOrder>(
              icon: const Icon(Icons.sort),
              onSelected: provider.setSortOrder,
              itemBuilder: (_) => const [
                PopupMenuItem(value: SortOrder.byColor, child: Text('فرز حسب اللون')),
                PopupMenuItem(value: SortOrder.byModifiedTime, child: Text('فرز حسب تاريخ التعديل')),
                PopupMenuItem(value: SortOrder.byAlphabet, child: Text('فرز أبجدي')),
                PopupMenuItem(value: SortOrder.byReminder, child: Text('فرز حسب التذكير')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // KiteTech Folders Strip
            Container(
              height: 44,
              color: isAmoled ? const Color(0xFF121212) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: provider.selectedFolderId == 'all',
                    onSelected: (_) => provider.setFolderFilter('all'),
                  ),
                  const SizedBox(width: 6),
                  ...provider.folders.map((f) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text('📁 ${f.nameAr}'),
                          selected: provider.selectedFolderId == f.id,
                          onSelected: (_) => provider.setFolderFilter(f.id),
                        ),
                      )),
                ],
              ),
            ),

            // Main Notes List or Folders Directory
            Expanded(
              child: _showFoldersDirectory
                  ? ListView.separated(
                      itemCount: provider.folders.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final folder = provider.folders[index];
                        return ListTile(
                          leading: const Icon(Icons.folder, color: Color(0xFF55B535), size: 28),
                          title: Text('${folder.nameAr} (${folder.nameEn})', style: TextStyle(color: isAmoled ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                          onTap: () {
                            provider.setFolderFilter(folder.id);
                            setState(() => _showFoldersDirectory = false);
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return NoteCard(
                          note: note,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF009688),
          onPressed: () => _showCreateNoteDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (idx) => setState(() => _currentTab = idx),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'الملاحظات'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'التقويم'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'المزيد'),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.article, color: Colors.amber),
              title: const Text('ملاحظة نصية مسطرة (Text Note)'),
              onTap: () {
                Navigator.pop(context);
                _openNewNote(NoteType.text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box, color: Colors.teal),
              title: const Text('قائمة مهام / تسوق (Checklist)'),
              onTap: () {
                Navigator.pop(context);
                _openNewNote(NoteType.checklist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brush, color: Colors.green),
              title: const Text('رسم وكتابة يدوية (Handwriting & Drawing)'),
              onTap: () {
                Navigator.pop(context);
                _openNewNote(NoteType.drawing);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openNewNote(NoteType type) {
    final now = DateTime.now();
    final newNote = NoteModel(
      type: type,
      title: '',
      createdDate: now,
      modifiedDate: now,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: newNote)),
    );
  }
}
