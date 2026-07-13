import { TodoItem, TodoStore, Priority, CATEGORY_LIST } from '../model/TodoItem';
import { TodoCard } from '../components/TodoCard';
import { common } from '@kit.AbilityKit';

export enum SortMode {
  Default = 0,
  Priority = 1,
  DueDate = 2,
  CreatedAt = 3
}

export enum FilterMode {
  All = 0,
  Todo = 1,
  Done = 2
}

@CustomDialog
struct TodoDialog {
  controller?: CustomDialogController;
  @State editContent: string = '';
  @State editPriority: Priority = Priority.None;
  @State editCategory: string = '默认';
  @State editDueMonth: number = 0;
  @State editDueDay: number = 0;
  @State selectedMonthIndex: number = 0;
  @State selectedDayIndex: number = 0;
  @State showDatePicker: boolean = false;
  editId: string = '';
  isAddMode: boolean = true;
  onConfirm: (id: string, content: string, priority: Priority, category: string, dueDate: number) => void = () => {};

  private priorityOptions: string[] = ['无', '低', '中', '高'];
  private priorityValues: Priority[] = [Priority.None, Priority.Low, Priority.Medium, Priority.High];
  private monthOptions: string[] = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
  private dayOptions: string[] = [];

  private initDayOptions(): void {
    this.dayOptions = [];
    for (let i = 1; i <= 31; i++) {
      this.dayOptions.push(`${i}日`);
    }
  }

  private dateToTimestamp(): number {
    if (this.editDueMonth === 0 || this.editDueDay === 0) {
      return 0;
    }
    const now: Date = new Date();
    const year: number = now.getFullYear();
    let targetYear: number = year;
    const currentMonth: number = now.getMonth() + 1;
    if (this.editDueMonth < currentMonth) {
      targetYear = year + 1;
    }
    const d: Date = new Date(targetYear, this.editDueMonth - 1, this.editDueDay);
    return d.getTime();
  }

  private getPriorityLabel(): string {
    const idx: number = this.priorityValues.indexOf(this.editPriority);
    if (idx >= 0) {
      return this.priorityOptions[idx];
    }
    return '无';
  }

  private getDueDateLabel(): string {
    if (this.editDueMonth === 0 || this.editDueDay === 0) {
      return '';
    }
    return `${this.editDueMonth}月${this.editDueDay}日`;
  }

  aboutToAppear(): void {
    this.initDayOptions();
    const now: Date = new Date();
    this.editDueMonth = now.getMonth() + 1;
    this.editDueDay = now.getDate();
    this.selectedMonthIndex = this.editDueMonth - 1;
    this.selectedDayIndex = this.editDueDay - 1;
  }

  build() {
    Column({ space: 12 }) {
      Text(this.isAddMode ? '添加待办' : $r('app.string.dialog_edit_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Center)
      TextInput({ placeholder: $r('app.string.hint_input'), text: this.editContent })
        .height(48)
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_primary'))
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.editContent = value;
        })
      Row({ space: 8 }) {
        ForEach(this.priorityOptions, (option: string, index: number) => {
          Text(option)
            .fontSize($r('app.float.chip_font_size'))
            .fontColor(this.editPriority === this.priorityValues[index] ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
            .backgroundColor(this.editPriority === this.priorityValues[index] ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.editPriority = this.priorityValues[index];
            })
        }, (option: string, index: number) => `${index}`)
      }
      Row({ space: 8 }) {
        ForEach(CATEGORY_LIST, (cat: string) => {
          Text(cat)
            .fontSize($r('app.float.chip_font_size'))
            .fontColor(this.editCategory === cat ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
            .backgroundColor(this.editCategory === cat ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.editCategory = cat;
            })
        }, (cat: string) => cat)
      }
      Row({ space: 8 }) {
        Text($r('app.string.label_due_date'))
          .fontSize($r('app.float.chip_font_size'))
          .fontColor($r('app.color.text_secondary'))
        if (this.editDueMonth !== 0 && this.editDueDay !== 0) {
          Text(this.getDueDateLabel())
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.accent_color'))
        } else {
          Text($r('app.string.hint_select_date'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.chip_text_color'))
        }
      }
        .backgroundColor($r('app.color.chip_background'))
        .borderRadius($r('app.float.chip_border_radius'))
        .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
        .onClick(() => {
          this.showDatePicker = !this.showDatePicker;
        })
      if (this.showDatePicker) {
        Row() {
          TextPicker({ range: this.monthOptions, selected: this.selectedMonthIndex })
            .onChange((value: string | string[], index: number | number[]) => {
              const idx: number = index as number;
              this.selectedMonthIndex = idx;
              this.editDueMonth = idx + 1;
            })
            .width('50%')
          TextPicker({ range: this.dayOptions, selected: this.selectedDayIndex })
            .onChange((value: string | string[], index: number | number[]) => {
              const idx: number = index as number;
              this.selectedDayIndex = idx;
              this.editDueDay = idx + 1;
            })
            .width('50%')
        }
        .height(120)
      }
      Row({ space: 12 }) {
        Button($r('app.string.dialog_cancel'))
          .type(ButtonType.Capsule)
          .height(44)
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor('#F0F0F0')
          .layoutWeight(1)
          .onClick(() => {
            this.controller?.close();
          })
        Button($r('app.string.dialog_confirm'))
          .type(ButtonType.Capsule)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.accent_color'))
          .layoutWeight(1)
          .onClick(() => {
            const trimmed: string = this.editContent.trim();
            if (trimmed.length > 0) {
              this.onConfirm(this.editId, trimmed, this.editPriority, this.editCategory, this.dateToTimestamp());
            }
            this.controller?.close();
          })
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }
}

@Entry
@Component
struct Index {
  @State todoList: TodoItem[] = [];
  @State searchText: string = '';
  @State filterMode: FilterMode = FilterMode.All;
  @State sortMode: SortMode = SortMode.Default;
  @State isDarkMode: boolean = false;
  @State isBatchMode: boolean = false;
  @State batchCheckedIds: string[] = [];
  @State showSortMenu: boolean = false;
  @State displayList: TodoItem[] = [];
  private abilityContext: common.UIAbilityContext | undefined = undefined;
  private editDialogController: CustomDialogController = new CustomDialogController({
    builder: TodoDialog({
      editContent: '',
      editId: '',
      editPriority: Priority.None,
      editCategory: '默认',
      editDueMonth: 0,
      editDueDay: 0,
      isAddMode: false,
      onConfirm: (id: string, content: string, priority: Priority, category: string, dueDate: number) => {
        this.editTodo(id, content, priority, category, dueDate);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true,
    autoCancel: true
  });
  private addDialogController: CustomDialogController = new CustomDialogController({
    builder: TodoDialog({
      editContent: '',
      editId: '',
      editPriority: Priority.None,
      editCategory: '默认',
      editDueMonth: 0,
      editDueDay: 0,
      isAddMode: true,
      onConfirm: (id: string, content: string, priority: Priority, category: string, dueDate: number) => {
        this.addTodo(content, priority, category, dueDate);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true,
    autoCancel: true
  });

  private getContext(): common.UIAbilityContext {
    if (this.abilityContext !== undefined) {
      return this.abilityContext;
    }
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    this.abilityContext = hostContext as common.UIAbilityContext;
    return this.abilityContext;
  }

  aboutToAppear(): void {
    this.todoList = TodoStore.loadTodos(this.getContext());
    this.refreshDisplay();
  }

  private generateId(): string {
    return Date.now().toString() + Math.floor(Math.random() * 1000).toString();
  }

  private refreshDisplay(): void {
    this.displayList = this.getFilteredAndSortedList();
  }

  private addTodo(content: string, priority: Priority, category: string, dueDate: number): void {
    const newItem: TodoItem = TodoItem.of(this.generateId(), content, Date.now());
    newItem.priority = priority;
    newItem.category = category;
    newItem.dueDate = dueDate;
    this.todoList = [newItem, ...this.todoList];
    TodoStore.saveTodos(this.getContext(), this.todoList);
    this.refreshDisplay();
  }

  private toggleTodo(id: string): void {
    for (let i = 0; i < this.todoList.length; i++) {
      if (this.todoList[i].id === id) {
        this.todoList[i].isCompleted = !this.todoList[i].isCompleted;
        break;
      }
    }
    TodoStore.saveTodos(this.getContext(), this.todoList);
    this.refreshDisplay();
  }

  private deleteTodo(id: string): void {
    const list: TodoItem[] = [];
    for (let i = 0; i < this.todoList.length; i++) {
      if (this.todoList[i].id !== id) {
        list.push(this.todoList[i]);
      }
    }
    this.todoList = list;
    TodoStore.saveTodos(this.getContext(), this.todoList);
    this.refreshDisplay();
  }

  private editTodo(id: string, content: string, priority: Priority, category: string, dueDate: number): void {
    for (let i = 0; i < this.todoList.length; i++) {
      if (this.todoList[i].id === id) {
        this.todoList[i].content = content;
        this.todoList[i].priority = priority;
        this.todoList[i].category = category;
        this.todoList[i].dueDate = dueDate;
        break;
      }
    }
    TodoStore.saveTodos(this.getContext(), this.todoList);
    this.refreshDisplay();
  }

  private requestEdit(id: string, content: string, priority: Priority, category: string, dueDate: number): void {
    let dueMonth: number = 0;
    let dueDay: number = 0;
    if (dueDate !== 0) {
      const d: Date = new Date(dueDate);
      dueMonth = d.getMonth() + 1;
      dueDay = d.getDate();
    } else {
      const now: Date = new Date();
      dueMonth = now.getMonth() + 1;
      dueDay = now.getDate();
    }
    this.editDialogController = new CustomDialogController({
      builder: TodoDialog({
        editContent: content,
        editId: id,
        editPriority: priority,
        editCategory: category,
        editDueMonth: dueMonth,
        editDueDay: dueDay,
        selectedMonthIndex: dueMonth - 1,
        selectedDayIndex: dueDay - 1,
        isAddMode: false,
        onConfirm: (editId: string, newContent: string, newPriority: Priority, newCategory: string, newDueDate: number) => {
          this.editTodo(editId, newContent, newPriority, newCategory, newDueDate);
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      autoCancel: true
    });
    this.editDialogController.open();
  }

  private requestAdd(): void {
    this.addDialogController = new CustomDialogController({
      builder: TodoDialog({
        editContent: '',
        editId: '',
        editPriority: Priority.None,
        editCategory: '默认',
        editDueMonth: 0,
        editDueDay: 0,
        isAddMode: true,
        onConfirm: (id: string, content: string, priority: Priority, category: string, dueDate: number) => {
          this.addTodo(content, priority, category, dueDate);
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      autoCancel: true
    });
    this.addDialogController.open();
  }

  private getFilteredAndSortedList(): TodoItem[] {
    const list: TodoItem[] = [];
    for (let i = 0; i < this.todoList.length; i++) {
      const item: TodoItem = this.todoList[i];
      if (this.filterMode === FilterMode.Todo && item.isCompleted) {
        continue;
      }
      if (this.filterMode === FilterMode.Done && !item.isCompleted) {
        continue;
      }
      if (this.searchText.length > 0) {
        if (item.content.indexOf(this.searchText) < 0) {
          continue;
        }
      }
      list.push(item);
    }
    if (this.sortMode === SortMode.Priority) {
      for (let i = 0; i < list.length - 1; i++) {
        for (let j = i + 1; j < list.length; j++) {
          if (list[j].priority > list[i].priority) {
            const temp: TodoItem = list[i];
            list[i] = list[j];
            list[j] = temp;
          }
        }
      }
    } else if (this.sortMode === SortMode.DueDate) {
      for (let i = 0; i < list.length - 1; i++) {
        for (let j = i + 1; j < list.length; j++) {
          const aDate: number = list[i].dueDate === 0 ? 9999999999999 : list[i].dueDate;
          const bDate: number = list[j].dueDate === 0 ? 9999999999999 : list[j].dueDate;
          if (bDate < aDate) {
            const temp: TodoItem = list[i];
            list[i] = list[j];
            list[j] = temp;
          }
        }
      }
    } else if (this.sortMode === SortMode.CreatedAt) {
      for (let i = 0; i < list.length - 1; i++) {
        for (let j = i + 1; j < list.length; j++) {
          if (list[j].createdAt > list[i].createdAt) {
            const temp: TodoItem = list[i];
            list[i] = list[j];
            list[j] = temp;
          }
        }
      }
    }
    return list;
  }

  private getTodoCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.todoList.length; i++) {
      if (!this.todoList[i].isCompleted) {
        count++;
      }
    }
    return count;
  }

  private getDoneCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.todoList.length; i++) {
      if (this.todoList[i].isCompleted) {
        count++;
      }
    }
    return count;
  }

  private toggleBatchCheck(id: string, checked: boolean): void {
    if (checked) {
      const newList: string[] = [];
      for (let i = 0; i < this.batchCheckedIds.length; i++) {
        newList.push(this.batchCheckedIds[i]);
      }
      newList.push(id);
      this.batchCheckedIds = newList;
    } else {
      const newList: string[] = [];
      for (let i = 0; i < this.batchCheckedIds.length; i++) {
        if (this.batchCheckedIds[i] !== id) {
          newList.push(this.batchCheckedIds[i]);
        }
      }
      this.batchCheckedIds = newList;
    }
    this.refreshDisplay();
  }

  private selectAll(): void {
    const filtered: TodoItem[] = this.getFilteredAndSortedList();
    const ids: string[] = [];
    for (let i = 0; i < filtered.length; i++) {
      ids.push(filtered[i].id);
    }
    this.batchCheckedIds = ids;
    this.refreshDisplay();
  }

  private deselectAll(): void {
    this.batchCheckedIds = [];
    this.refreshDisplay();
  }

  private batchDelete(): void {
    const list: TodoItem[] = [];
    for (let i = 0; i < this.todoList.length; i++) {
      let found: boolean = false;
      for (let j = 0; j < this.batchCheckedIds.length; j++) {
        if (this.todoList[i].id === this.batchCheckedIds[j]) {
          found = true;
          break;
        }
      }
      if (!found) {
        list.push(this.todoList[i]);
      }
    }
    this.todoList = list;
    this.batchCheckedIds = [];
    this.isBatchMode = false;
    TodoStore.saveTodos(this.getContext(), this.todoList);
    this.refreshDisplay();
  }

  private batchComplete(): void {
    for (let i = 0; i < this.todoList.length; i++) {
      for (let j = 0; j < this.batchCheckedIds.length; j++) {
        if (this.todoList[i].id === this.batchCheckedIds[j]) {
          this.todoList[i].isCompleted = true;
          break;
        }
      }
    }
    this.batchCheckedIds = [];
    this.isBatchMode = false;
    TodoStore.saveTodos(this.getContext(), this.todoList);
    this.refreshDisplay();
  }

  private isBatchItemChecked(id: string): boolean {
    for (let i = 0; i < this.batchCheckedIds.length; i++) {
      if (this.batchCheckedIds[i] === id) {
        return true;
      }
    }
    return false;
  }

  private getSortLabel(): string {
    if (this.sortMode === SortMode.Priority) {
      return '按优先级';
    }
    if (this.sortMode === SortMode.DueDate) {
      return '按到期日期';
    }
    if (this.sortMode === SortMode.CreatedAt) {
      return '按创建时间';
    }
    return '默认排序';
  }

  build() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
    Column() {
      Row() {
        Text($r('app.string.app_title'))
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
        Row({ space: 12 }) {
          Text('\u263E')
            .fontSize(22)
            .fontColor($r('app.color.dark_mode_icon_color'))
            .onClick(() => {
              this.isDarkMode = !this.isDarkMode;
            })
          Text('\u2261')
            .fontSize(22)
            .fontColor($r('app.color.dark_mode_icon_color'))
            .onClick(() => {
              this.isBatchMode = !this.isBatchMode;
              this.batchCheckedIds = [];
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 4 })
      Text($r('app.string.stat_info', this.getTodoCount().toString(), this.getDoneCount().toString()))
        .fontSize($r('app.float.secondary_font_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 16, right: 16, bottom: 8 })
      TextInput({ placeholder: $r('app.string.hint_search'), text: this.searchText })
        .height($r('app.float.search_bar_height'))
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.search_background'))
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .width('100%')
        .margin({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchText = value;
          this.refreshDisplay();
        })
      Row({ space: 8 }) {
        Text($r('app.string.filter_all'))
          .fontSize($r('app.float.chip_font_size'))
          .fontColor(this.filterMode === FilterMode.All ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
          .backgroundColor(this.filterMode === FilterMode.All ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
          .borderRadius($r('app.float.chip_border_radius'))
          .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          .onClick(() => {
            this.filterMode = FilterMode.All;
            this.refreshDisplay();
          })
        Text($r('app.string.filter_todo'))
          .fontSize($r('app.float.chip_font_size'))
          .fontColor(this.filterMode === FilterMode.Todo ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
          .backgroundColor(this.filterMode === FilterMode.Todo ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
          .borderRadius($r('app.float.chip_border_radius'))
          .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          .onClick(() => {
            this.filterMode = FilterMode.Todo;
            this.refreshDisplay();
          })
        Text($r('app.string.filter_done'))
          .fontSize($r('app.float.chip_font_size'))
          .fontColor(this.filterMode === FilterMode.Done ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
          .backgroundColor(this.filterMode === FilterMode.Done ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
          .borderRadius($r('app.float.chip_border_radius'))
          .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          .onClick(() => {
            this.filterMode = FilterMode.Done;
            this.refreshDisplay();
          })
        Blank()
        Text(this.getSortLabel())
          .fontSize($r('app.float.chip_font_size'))
          .fontColor($r('app.color.chip_text_color'))
          .backgroundColor($r('app.color.chip_background'))
          .borderRadius($r('app.float.chip_border_radius'))
          .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          .onClick(() => {
            this.showSortMenu = !this.showSortMenu;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 4 })
      if (this.showSortMenu) {
        Row({ space: 8 }) {
          Text($r('app.string.sort_default'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor(this.sortMode === SortMode.Default ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
            .backgroundColor(this.sortMode === SortMode.Default ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.sortMode = SortMode.Default;
              this.showSortMenu = false;
              this.refreshDisplay();
            })
          Text($r('app.string.sort_priority'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor(this.sortMode === SortMode.Priority ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
            .backgroundColor(this.sortMode === SortMode.Priority ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.sortMode = SortMode.Priority;
              this.showSortMenu = false;
              this.refreshDisplay();
            })
          Text($r('app.string.sort_due_date'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor(this.sortMode === SortMode.DueDate ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
            .backgroundColor(this.sortMode === SortMode.DueDate ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.sortMode = SortMode.DueDate;
              this.showSortMenu = false;
              this.refreshDisplay();
            })
          Text($r('app.string.sort_created'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor(this.sortMode === SortMode.CreatedAt ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
            .backgroundColor(this.sortMode === SortMode.CreatedAt ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.sortMode = SortMode.CreatedAt;
              this.showSortMenu = false;
              this.refreshDisplay();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      }
      if (this.isBatchMode) {
        Row({ space: 12 }) {
          Text($r('app.string.btn_select_all'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.accent_color'))
            .onClick(() => {
              this.selectAll();
            })
          Text($r('app.string.btn_deselect_all'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.text_secondary'))
            .onClick(() => {
              this.deselectAll();
            })
          Blank()
          Text($r('app.string.btn_batch_delete'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.delete_color'))
            .onClick(() => {
              this.batchDelete();
            })
          Text($r('app.string.btn_batch_complete'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.accent_color'))
            .onClick(() => {
              this.batchComplete();
            })
        }
        .width('100%')
        .height($r('app.float.toolbar_height'))
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.toolbar_background'))
        .alignItems(VerticalAlign.Center)
      }
      if (this.displayList.length === 0) {
        Column() {
          Text($r('app.string.empty_tip'))
            .fontSize($r('app.float.body_font_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.displayList, (item: TodoItem) => {
            ListItem() {
              TodoCard({
                todoItem: item,
                onToggle: (id: string) => { this.toggleTodo(id); },
                onDelete: (id: string) => { this.deleteTodo(id); },
                onEditRequest: (id: string, content: string) => {
                  this.requestEdit(id, content, item.priority, item.category, item.dueDate);
                },
                isInBatchMode: this.isBatchMode,
                isBatchChecked: this.isBatchItemChecked(item.id),
                onBatchCheck: (id: string, checked: boolean) => { this.toggleBatchCheck(id, checked); }
              })
            }
          }, (item: TodoItem) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .edgeEffect(EdgeEffect.Spring)
      }
      Button($r('app.string.btn_add'))
        .type(ButtonType.Capsule)
        .height(48)
        .fontSize($r('app.float.body_font_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.accent_color'))
        .borderRadius(24)
        .width(120)
        .margin({ top: 8, bottom: 16 })
        .onClick(() => {
          this.requestAdd();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    }
  }
}
