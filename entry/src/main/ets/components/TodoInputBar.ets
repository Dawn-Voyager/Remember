import { Priority, CATEGORY_LIST } from '../model/TodoItem';

@Component
export struct TodoInputBar {
  @State inputText: string = '';
  @State selectedPriority: Priority = Priority.None;
  @State selectedCategory: string = '默认';
  @State selectedDueDate: string = '';
  @State showPriorityPicker: boolean = false;
  @State showCategoryPicker: boolean = false;
  @State showDatePicker: boolean = false;
  onAdd: (content: string, priority: Priority, category: string, dueDate: number) => void = () => {};

  private priorityOptions: string[] = ['无', '低', '中', '高'];
  private priorityValues: Priority[] = [Priority.None, Priority.Low, Priority.Medium, Priority.High];

  private dateToTimestamp(dateStr: string): number {
    if (dateStr === '') {
      return 0;
    }
    const parts: string[] = dateStr.split('-');
    if (parts.length === 3) {
      const d: Date = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
      return d.getTime();
    }
    return 0;
  }

  private getPriorityLabel(): string {
    const idx: number = this.priorityValues.indexOf(this.selectedPriority);
    if (idx >= 0) {
      return this.priorityOptions[idx];
    }
    return '无';
  }

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        TextInput({ placeholder: $r('app.string.hint_input'), text: this.inputText })
          .type(InputType.Normal)
          .layoutWeight(1)
          .height(44)
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.inputText = value;
          })
        Button($r('app.string.btn_add'))
          .type(ButtonType.Capsule)
          .height(44)
          .fontSize($r('app.float.body_font_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.accent_color'))
          .borderRadius(8)
          .enabled(this.inputText.trim().length > 0)
          .onClick(() => {
            const trimmed: string = this.inputText.trim();
            if (trimmed.length > 0) {
              this.onAdd(trimmed, this.selectedPriority, this.selectedCategory, this.dateToTimestamp(this.selectedDueDate));
              this.inputText = '';
              this.selectedPriority = Priority.None;
              this.selectedCategory = '默认';
              this.selectedDueDate = '';
            }
          })
      }
      Row({ space: 8 }) {
        Row({ space: 2 }) {
          Text($r('app.string.label_priority'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.chip_text_color'))
          Text(': ' + this.getPriorityLabel())
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.chip_text_color'))
        }
          .backgroundColor($r('app.color.chip_background'))
          .borderRadius($r('app.float.chip_border_radius'))
          .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          .onClick(() => {
            this.showPriorityPicker = !this.showPriorityPicker;
            this.showCategoryPicker = false;
            this.showDatePicker = false;
          })
        Row({ space: 2 }) {
          Text($r('app.string.label_category'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.chip_text_color'))
          Text(': ' + this.selectedCategory)
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.chip_text_color'))
        }
          .backgroundColor($r('app.color.chip_background'))
          .borderRadius($r('app.float.chip_border_radius'))
          .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          .onClick(() => {
            this.showCategoryPicker = !this.showCategoryPicker;
            this.showPriorityPicker = false;
            this.showDatePicker = false;
          })
        if (this.selectedDueDate !== '') {
          Row({ space: 2 }) {
            Text($r('app.string.label_due_date'))
              .fontSize($r('app.float.chip_font_size'))
              .fontColor($r('app.color.accent_color'))
            Text(': ' + this.selectedDueDate)
              .fontSize($r('app.float.chip_font_size'))
              .fontColor($r('app.color.accent_color'))
          }
            .backgroundColor($r('app.color.chip_background'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.showDatePicker = !this.showDatePicker;
              this.showPriorityPicker = false;
              this.showCategoryPicker = false;
            })
          Text('\u2715')
            .fontSize(14)
            .fontColor($r('app.color.delete_color'))
            .onClick(() => {
              this.selectedDueDate = '';
            })
        } else {
          Text($r('app.string.hint_select_date'))
            .fontSize($r('app.float.chip_font_size'))
            .fontColor($r('app.color.chip_text_color'))
            .backgroundColor($r('app.color.chip_background'))
            .borderRadius($r('app.float.chip_border_radius'))
            .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
            .onClick(() => {
              this.showDatePicker = !this.showDatePicker;
              this.showPriorityPicker = false;
              this.showCategoryPicker = false;
            })
        }
      }
      if (this.showPriorityPicker) {
        Row({ space: 8 }) {
          ForEach(this.priorityOptions, (option: string, index: number) => {
            Text(option)
              .fontSize($r('app.float.chip_font_size'))
              .fontColor(this.selectedPriority === this.priorityValues[index] ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
              .backgroundColor(this.selectedPriority === this.priorityValues[index] ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
              .borderRadius($r('app.float.chip_border_radius'))
              .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
              .onClick(() => {
                this.selectedPriority = this.priorityValues[index];
                this.showPriorityPicker = false;
              })
          }, (option: string, index: number) => `${index}`)
        }
      }
      if (this.showCategoryPicker) {
        Row({ space: 8 }) {
          ForEach(CATEGORY_LIST, (cat: string) => {
            Text(cat)
              .fontSize($r('app.float.chip_font_size'))
              .fontColor(this.selectedCategory === cat ? $r('app.color.filter_active_text') : $r('app.color.filter_inactive_text'))
              .backgroundColor(this.selectedCategory === cat ? $r('app.color.filter_active_bg') : $r('app.color.filter_inactive_bg'))
              .borderRadius($r('app.float.chip_border_radius'))
              .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
              .onClick(() => {
                this.selectedCategory = cat;
                this.showCategoryPicker = false;
              })
          }, (cat: string) => cat)
        }
      }
      if (this.showDatePicker) {
        DatePicker({
          start: new Date('2024-1-1'),
          end: new Date('2100-12-31'),
          selected: this.selectedDueDate !== '' ? new Date(this.selectedDueDate) : new Date()
        })
          .onDateChange((value: Date) => {
            const y: number = value.getFullYear();
            const m: number = value.getMonth() + 1;
            const d: number = value.getDate();
            this.selectedDueDate = `${y}-${m < 10 ? '0' + m : m}-${d < 10 ? '0' + d : d}`;
            this.showDatePicker = false;
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }
}
