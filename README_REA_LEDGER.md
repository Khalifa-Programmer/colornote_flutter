# ColorNote Notepad Notes — Reverse Engineering (REA) Ledger & Clean-Room Clone

## 1. Target Classification & Surface Inventory (REA Step 1)
- **Target Application**: ColorNote Notepad Notes
- **Package Identifier**: `com.socialnmobile.dictapps.notepad.color.note`
- **Developer**: Notes (Social & Mobile, Inc.)
- **Platform**: Android (Native Java/Kotlin + SQLite + AppWidgetProvider)
- **Core Capabilities**:
  1. **Dual Note Types**: Plain Text Note (`type = 0`, lined paper canvas) and Checklist / To-Do List (`type = 1`, checkable/reorderable rows).
  2. **9-Color Categorization System**: Red, Orange, Yellow, Green, Blue, Purple, Black, Grey, White — each with customizable category labels and header/body tinting.
  3. **Multi-Mode Sorting & Filtering**: Sort by Color, Modified Time, Created Time, Alphabetical (A-Z), and Reminder Time; Filter by 3x3 Color Grid.
  4. **Calendar Integration**: Monthly calendar view plotting notes/reminders by target date (`reminder_date`).
  5. **Security & Master Password**: Per-note locking (`locked = 1`) guarded by a Master Password / 4-digit PIN and PBKDF2/AES-128 encryption for local `.doc`/`.bak` backups.
  6. **Lifecycle States**: Active (`status = 0`), Archived (`status = 1`), and Trash Bin (`status = 2`), plus Done/Completed state (`checked = 1`) which renders strikethrough titles.
  7. **Home Screen Sticky Note Widgets**: `2x2` Sticky Note widget and `1x1` Direct Note shortcut widget.

## 2. Reconstruction Obligation Ledger (REA Step 2)

### SQLite Database Schema (`colornote.db`)
```sql
CREATE TABLE notes (
    _id INTEGER PRIMARY KEY AUTOINCREMENT,
    type INTEGER NOT NULL DEFAULT 0,          -- 0 = Text Note, 1 = Checklist
    title TEXT NOT NULL,
    note TEXT NOT NULL,                       -- Raw text or JSON-serialized checklist items
    color_index INTEGER NOT NULL DEFAULT 2,   -- 0:Red, 1:Orange, 2:Yellow, 3:Green, 4:Blue, 5:Purple, 6:Black, 7:Grey, 8:White
    created_date INTEGER NOT NULL,            -- Epoch ms
    modified_date INTEGER NOT NULL,           -- Epoch ms
    reminder_date INTEGER DEFAULT 0,          -- Epoch ms (0 = none)
    reminder_type INTEGER DEFAULT 0,          -- 0:None, 1:Time Alarm, 2:All-Day, 3:Pin to Status Bar
    checked INTEGER NOT NULL DEFAULT 0,       -- 0 = Active, 1 = Done (strikethrough title)
    locked INTEGER NOT NULL DEFAULT 0,        -- 0 = Unlocked, 1 = Protected by Master Password
    status INTEGER NOT NULL DEFAULT 0,        -- 0 = Normal, 1 = Archived, 2 = Trash
    widget_pinned INTEGER NOT NULL DEFAULT 0  -- 0 = Not on home widget, 1 = Pinned to widget
);

CREATE TABLE color_labels (
    color_index INTEGER PRIMARY KEY,
    label TEXT NOT NULL
);
```

## 3. Project Structure (Flutter Clean Architecture)
- `lib/main.dart`: Application entry point, theme setup, and root navigation.
- `lib/core/constants/note_colors.dart`: Exact 9-color palette definitions (Header, Body, Stripe, Dark variants).
- `lib/data/models/note_model.dart`: Immutable `NoteModel` and `ChecklistItem` classes with SQLite & JSON serialization.
- `lib/data/database/database_helper.dart`: `sqflite` database helper implementing CRUD, color filtering, calendar queries, archive, and trash.
- `lib/providers/notes_provider.dart`: `ChangeNotifier` state management handling sorting, search, PIN verification, and backup/restore.
- `lib/presentation/screens/`: Modular screens (`home_screen.dart`, `note_editor_screen.dart`, `calendar_screen.dart`).
- `lib/presentation/widgets/`: Reusable UI components (`note_card.dart`, `color_picker_dialog.dart`).

## 4. Merged Target #2: Simple Notepad Notes by KiteTech (`org.whiteglow.keepmynotes`)
All differential features from **Simple notepad notes (KiteTech)** have been reverse-engineered and merged into the unified application:
- **Folders Hierarchy (`folders` table & `folder_id` foreign key)**: Pre-configured with `Book list`, `Important`, `Quotes`, `To do lists`, and `Travel`, plus custom user folders and a dedicated Folders Directory view.
- **Wordpad Rich Text Formatting Toolbar (`B`, `I`, `U`, `S`, Highlight `A`, Font Color `🎨`, Multiple Font Styles `⚙️`, Undo/Redo `↶`/`↷`)**: Inline HTML/Rich-Text formatting directly on the 36px ruled notebook paper.
- **Handwriting & Finger Drawing Studio (`type = 2`, HTML5/Flutter Canvas)**: Interactive pen, eraser, stroke width slider, Undo/Redo history stack, and BFS pixel **Flood Fill Bucket (`🪣`)** with the KiteTech demo landscape preset.
- **Multimedia & Voice Dictation**: Inline picture attachments (`🖼️` Base64/File storage) and Speech-to-Text voice dictation (`🎙️` Arabic & English).
- **KiteTech App Bar Themes & AMOLED Mode**: Switchable header styles (`#55b535` KiteTech Green, `#29b6f6` KiteTech Sky Blue, `#000000` AMOLED Pure Black with green dividers, and Classic ColorNote White).
