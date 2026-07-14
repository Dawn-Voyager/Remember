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
    Column({ space: 20 }) {
      Row() {
        Text(this.isAddMode ? '添加待办' : $r('app.string.dialog_edit_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
        Text('\u2715')
          .fontSize(20)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            this.controller?.close();
          })
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('内容')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        TextInput({ placeholder: $r('app.string.hint_input'), text: this.editContent })
          .height(48)
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.chip_background'))
          .borderRadius(12)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.editContent = value;
          })
      }

      Column({ space: 8 }) {
        Text('优先级')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
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
      }

      Column({ space: 8 }) {
        Text('分类')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          ForEach(CATEGORY_LIST, (cat: string) => {
            Text(cat)
              .fontSize($r('app.float.chip_font_size'))
              .fontColor(this.editCategory === cat ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
              .backgroundColor(this.editCategory === cat ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
              .borderRadius($r('app.float.chip_border_radius'))
              .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.editCategory = cat;
              })
          }, (cat: string) => cat)
        }
      }

      Column({ space: 8 }) {
        Text('到期日期')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        Row({ space: 8 }) {
          Text('\uD83D\uDCC5')
            .fontSize(16)
          if (this.editDueMonth !== 0 && this.editDueDay !== 0) {
            Text(this.getDueDateLabel())
              .fontSize($r('app.float.body_font_size'))
              .fontColor($r('app.color.accent_color'))
              .fontWeight(FontWeight.Medium)
          } else {
            Text($r('app.string.hint_select_date'))
              .fontSize($r('app.float.body_font_size'))
              .fontColor($r('app.color.chip_text_color'))
          }
          Blank()
          Text(this.showDatePicker ? '收起' : '选择')
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.accent_color'))
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.chip_background'))
        .borderRadius(12)
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
          .backgroundColor($r('app.color.chip_background'))
          .borderRadius(12)
        }
      }

      Row({ space: 12 }) {
        Button($r('app.string.dialog_cancel'))
          .type(ButtonType.Capsule)
          .height(48)
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.chip_background'))
          .layoutWeight(1)
          .onClick(() => {
            this.controller?.close();
          })
        Button($r('app.string.dialog_confirm'))
          .type(ButtonType.Capsule)
          .height(48)
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
      .margin({ top: 4 })
    }
    .padding(24)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(24)
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
    const list: TodoItem[] = [];
    for (let i = 0; i < this.todoList.length; i++) {
      const item: TodoItem = this.todoList[i];
      if (item.id === id) {
        item.isCompleted = !item.isCompleted;
      }
      list.push(item);
    }
    this.todoList = list;
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
    const list: TodoItem[] = [];
    for (let i = 0; i < this.todoList.length; i++) {
      const item: TodoItem = this.todoList[i];
      if (item.id === id) {
        item.content = content;
        item.priority = priority;
        item.category = category;
        item.dueDate = dueDate;
      }
      list.push(item);
    }
    this.todoList = list;
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

  private getTotalCount(): number {
    return this.todoList.length;
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
    const list: TodoItem[] = [];
    for (let i = 0; i < this.todoList.length; i++) {
      const item: TodoItem = this.todoList[i];
      for (let j = 0; j < this.batchCheckedIds.length; j++) {
        if (item.id === this.batchCheckedIds[j]) {
          item.isCompleted = true;
          break;
        }
      }
      list.push(item);
    }
    this.todoList = list;
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
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Column() {
          Row() {
            Column() {
              Text($r('app.string.app_title'))
                .fontSize($r('app.float.title_font_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.header_text_color'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Row({ space: 16 }) {
              Text('\u263E')
                .fontSize(22)
                .fontColor($r('app.color.header_text_color'))
                .opacity(0.9)
                .onClick(() => {
                  this.isDarkMode = !this.isDarkMode;
                })
              Text('\u2261')
                .fontSize(22)
                .fontColor($r('app.color.header_text_color'))
                .opacity(0.9)
                .onClick(() => {
                  this.isBatchMode = !this.isBatchMode;
                  this.batchCheckedIds = [];
                })
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: $r('app.float.header_padding_top'), bottom: 8 })

          Row() {
            Text('\uD83D\uDD0D')
              .fontSize($r('app.float.search_icon_size'))
              .margin({ left: 12, right: 8 })
            TextInput({ placeholder: $r('app.string.hint_search'), text: this.searchText })
              .height($r('app.float.search_bar_height'))
              .fontSize($r('app.float.body_font_size'))
              .fontColor($r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .padding({ left: 0, right: 12 })
              .onChange((value: string) => {
                this.searchText = value;
                this.refreshDisplay();
              })
          }
          .width('100%')
          .height($r('app.float.search_bar_height'))
          .backgroundColor($r('app.color.search_background'))
          .borderRadius(22)
          .margin({ left: 20, right: 20, top: 12 })

          Row({ space: 8 }) {
            Column() {
              Text(this.getTodoCount().toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.header_text_color'))
              Text('待办')
                .fontSize(10)
                .fontColor($r('app.color.header_text_color'))
                .opacity(0.7)
            }
            .layoutWeight(1)
            .padding({ top: 4, bottom: 4 })
            .backgroundColor($r('app.color.stat_card_bg'))
            .borderRadius(8)
            Column() {
              Text(this.getDoneCount().toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.header_text_color'))
              Text('已完成')
                .fontSize(10)
                .fontColor($r('app.color.header_text_color'))
                .opacity(0.7)
            }
            .layoutWeight(1)
            .padding({ top: 4, bottom: 4 })
            .backgroundColor($r('app.color.stat_card_bg'))
            .borderRadius(8)
            Column() {
              Text(this.getTotalCount().toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.header_text_color'))
              Text('全部')
                .fontSize(10)
                .fontColor($r('app.color.header_text_color'))
                .opacity(0.7)
            }
            .layoutWeight(1)
            .padding({ top: 4, bottom: 4 })
            .backgroundColor($r('app.color.stat_card_bg'))
            .borderRadius(8)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8, bottom: 14 })
        }
        .width('100%')
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [[$r('app.color.header_gradient_start'), 0], [$r('app.color.header_gradient_end'), 1]]
        })

        Column() {
          Row({ space: 8 }) {
            Text($r('app.string.filter_all'))
              .fontSize($r('app.float.chip_font_size'))
              .fontWeight(this.filterMode === FilterMode.All ? FontWeight.Medium : FontWeight.Normal)
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
              .fontWeight(this.filterMode === FilterMode.Todo ? FontWeight.Medium : FontWeight.Normal)
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
              .fontWeight(this.filterMode === FilterMode.Done ? FontWeight.Medium : FontWeight.Normal)
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
          .padding({ left: 20, right: 20, top: 16, bottom: 4 })
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
            .padding({ left: 20, right: 20, top: 4, bottom: 4 })
          }
          if (this.isBatchMode) {
            Row({ space: 16 }) {
              Text($r('app.string.btn_select_all'))
                .fontSize($r('app.float.chip_font_size'))
                .fontColor($r('app.color.accent_color'))
                .fontWeight(FontWeight.Medium)
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
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.batchDelete();
                })
              Text($r('app.string.btn_batch_complete'))
                .fontSize($r('app.float.chip_font_size'))
                .fontColor($r('app.color.accent_color'))
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.batchComplete();
                })
            }
            .width('100%')
            .height($r('app.float.toolbar_height'))
            .padding({ left: 20, right: 20 })
            .backgroundColor($r('app.color.toolbar_background'))
            .borderRadius({ topLeft: 16, topRight: 16 })
            .alignItems(VerticalAlign.Center)
          }
          if (this.displayList.length === 0) {
            Column() {
              Text('\uD83D\uDCCB')
                .fontSize(48)
                .margin({ bottom: 16 })
              Text($r('app.string.empty_tip'))
                .fontSize($r('app.float.body_font_size'))
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            List({ space: 10 }) {
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
            .padding({ left: 16, right: 16, top: 8, bottom: 80 })
            .edgeEffect(EdgeEffect.Spring)
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))

      Button() {
        Text('+')
          .fontSize(28)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Normal)
      }
      .type(ButtonType.Circle)
      .width($r('app.float.fab_size'))
      .height($r('app.float.fab_size'))
      .backgroundColor($r('app.color.accent_color'))
      .shadow({ radius: 16, color: $r('app.color.fab_shadow_color'), offsetY: 4 })
      .margin({ right: 24, bottom: 32 })
      .onClick(() => {
        this.requestAdd();
      })
    }
    .width('100%')
    .height('100%')
    }
  }
}
