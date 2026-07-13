# Remember

A HarmonyOS todo app built with ArkTS & ArkUI.

## Features

- Todo CRUD (add / edit / delete / complete)
- Priority levels: None / Low / Medium / High
- Category tags: Default / Work / Study / Life / Health / Other
- Due date with month+day dual-roller picker (click to expand/collapse)
- Search bar
- Status filter: All / Todo / Done
- Sort: Default / Priority / Due Date / Created At
- Batch mode: Select All / Deselect / Batch Delete / Batch Complete
- Dark mode toggle
- Local data persistence (Preferences)

## Tech Stack

- **Language:** ArkTS
- **UI Framework:** ArkUI (@Component, @State, @Prop, @Observed, @CustomDialog)
- **Storage:** @kit.ArkData (Preferences)
- **Platform:** HarmonyOS / OpenHarmony
- **SDK:** HarmonyOS NEXT

## Project Structure

```
entry/src/main/
├── ets/
│   ├── entryability/
│   │   └── EntryAbility.ets          # App entry ability
│   ├── model/
│   │   └── TodoItem.ets              # TodoItem model, Priority enum, TodoStore
│   ├── components/
│   │   └── TodoCard.ets              # Todo card component
│   └── pages/
│       └── Index.ets                  # Main page (search/filter/sort/batch/dialog)
├── resources/
│   ├── base/
│   │   ├── element/
│   │   │   ├── string.json           # All string resources
│   │   │   ├── color.json            # Light theme colors
│   │   │   └── float.json            # Dimension resources
│   │   ├── media/                    # App icons
│   │   └── profile/
│   │       └── main_pages.json       # Page routing config
│   └── dark/
│       └── element/
│           └── color.json            # Dark theme colors
└── module.json5                      # Module config
```

## Data Model

```typescript
class TodoItem {
  id: string           // Unique ID
  content: string      // Todo text
  isCompleted: boolean // Completion status
  createdAt: number    // Creation timestamp
  priority: Priority   // 0=None, 1=Low, 2=Medium, 3=High
  category: string     // Category label
  dueDate: number      // Due date timestamp (0 = no date)
}
```

## Key Design Decisions

- **Unified TodoDialog**: Single @CustomDialog for both add and edit, controlled by `isAddMode` flag
- **Display list pattern**: `@State displayList` cached separately from `todoList`, refreshed via `refreshDisplay()` after mutations
- **Sort**: Manual bubble sort (ArkTS lambda/prototype constraints)
- **Date picker**: TextPicker dual rollers (month + day), click to toggle visibility
- **Dark mode**: `WithTheme({ colorMode })` wrapping + dark resource qualifiers
- **Batch reactivity**: `@Prop isInBatchMode` / `@Prop isBatchChecked` on TodoCard

## Build & Run

1. Open project in DevEco Studio
2. Connect HarmonyOS device or start emulator
3. Build & run entry module

## License

MIT
