import { TodoItem, Priority, PRIORITY_LABELS } from '../model/TodoItem';

@Component
export struct TodoCard {
  @ObjectLink todoItem: TodoItem;
  onToggle: (id: string) => void = () => {};
  onDelete: (id: string) => void = () => {};
  onEditRequest: (id: string, content: string) => void = () => {};
  @Prop isInBatchMode: boolean = false;
  @Prop isBatchChecked: boolean = false;
  onBatchCheck: (id: string, checked: boolean) => void = () => {};

  private formatDate(timestamp: number): string {
    if (timestamp === 0) {
      return '';
    }
    const date: Date = new Date(timestamp);
    const year: number = date.getFullYear();
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    return `${year}-${month < 10 ? '0' + month : month}-${day < 10 ? '0' + day : day}`;
  }

  private getPriorityColor(): ResourceStr {
    if (this.todoItem.priority === Priority.High) {
      return $r('app.color.priority_high_color');
    }
    if (this.todoItem.priority === Priority.Medium) {
      return $r('app.color.priority_medium_color');
    }
    if (this.todoItem.priority === Priority.Low) {
      return $r('app.color.priority_low_color');
    }
    return '';
  }

  private getDueDateStatus(): string {
    if (this.todoItem.dueDate === 0) {
      return '';
    }
    const now: number = Date.now();
    const todayStart: number = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate()).getTime();
    const dueDayStart: number = new Date(this.todoItem.dueDate).getTime();
    if (dueDayStart < todayStart) {
      return 'expired';
    }
    if (dueDayStart === todayStart) {
      return 'today';
    }
    return 'future';
  }

  private getDueDateColor(): ResourceColor {
    const status: string = this.getDueDateStatus();
    if (status === 'expired') {
      return $r('app.color.due_expired_color');
    }
    if (status === 'today') {
      return $r('app.color.due_soon_color');
    }
    return $r('app.color.text_secondary');
  }

  build() {
    Row({ space: 12 }) {
      if (this.isInBatchMode) {
        Toggle({ type: ToggleType.Checkbox, isOn: this.isBatchChecked })
          .width(24)
          .height(24)
          .selectedColor($r('app.color.accent_color'))
          .onChange((isOn: boolean) => {
            this.onBatchCheck(this.todoItem.id, isOn);
          })
      }
      Toggle({ type: ToggleType.Checkbox, isOn: this.todoItem.isCompleted })
        .width(24)
        .height(24)
        .selectedColor($r('app.color.accent_color'))
        .onChange((isOn: boolean) => {
          this.onToggle(this.todoItem.id);
        })
      Column({ space: 4 }) {
        Row({ space: 6 }) {
          if (this.todoItem.priority !== Priority.None) {
            Circle()
              .width($r('app.float.priority_indicator_size'))
              .height($r('app.float.priority_indicator_size'))
              .fill(this.getPriorityColor())
          }
          Text(this.todoItem.content)
            .fontSize($r('app.float.body_font_size'))
            .fontColor(this.todoItem.isCompleted ? $r('app.color.text_secondary') : $r('app.color.text_primary'))
            .decoration(this.todoItem.isCompleted ? { type: TextDecorationType.LineThrough, color: $r('app.color.text_secondary') } : { type: TextDecorationType.None, color: Color.Transparent })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        Row({ space: 8 }) {
          if (this.todoItem.category !== '默认') {
            Text(this.todoItem.category)
              .fontSize($r('app.float.chip_font_size'))
              .fontColor($r('app.color.chip_text_color'))
              .backgroundColor($r('app.color.chip_background'))
              .borderRadius($r('app.float.chip_border_radius'))
              .padding({ left: $r('app.float.chip_padding_h'), right: $r('app.float.chip_padding_h'), top: $r('app.float.chip_padding_v'), bottom: $r('app.float.chip_padding_v') })
          }
          if (this.todoItem.dueDate !== 0) {
            Row({ space: 4 }) {
              Text(this.formatDate(this.todoItem.dueDate))
                .fontSize($r('app.float.chip_font_size'))
                .fontColor(this.getDueDateColor())
            }
          }
          if (this.todoItem.priority !== Priority.None) {
            Text(PRIORITY_LABELS[this.todoItem.priority.toString()])
              .fontSize($r('app.float.chip_font_size'))
              .fontColor(this.getPriorityColor())
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.onEditRequest(this.todoItem.id, this.todoItem.content);
      })
      Blank()
      Button({ type: ButtonType.Circle }) {
        Text('\u2715')
          .fontSize(16)
          .fontColor($r('app.color.delete_color'))
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onDelete(this.todoItem.id);
      })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor($r('app.color.card_background'))
    .borderRadius($r('app.float.card_border_radius'))
    .alignItems(VerticalAlign.Center)
  }
}
