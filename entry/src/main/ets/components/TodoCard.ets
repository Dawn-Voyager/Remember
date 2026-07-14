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
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    return `${month}月${day}日`;
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

  private hasPriority(): boolean {
    return this.todoItem.priority !== Priority.None;
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

  private getTagSuffix(): string {
    const parts: string[] = [];
    if (this.todoItem.category !== '默认') {
      parts.push(this.todoItem.category);
    }
    if (this.todoItem.dueDate !== 0) {
      parts.push(this.formatDate(this.todoItem.dueDate));
    }
    if (this.todoItem.priority !== Priority.None) {
      parts.push(PRIORITY_LABELS[this.todoItem.priority.toString()]);
    }
    if (parts.length === 0) {
      return '';
    }
    return '  ' + parts.join('·');
  }

  build() {
    Row({ space: 10 }) {
      if (this.isInBatchMode) {
        Toggle({ type: ToggleType.Checkbox, isOn: this.isBatchChecked })
          .width(20)
          .height(20)
          .selectedColor($r('app.color.accent_color'))
          .onChange((isOn: boolean) => {
            this.onBatchCheck(this.todoItem.id, isOn);
          })
      }
      Toggle({ type: ToggleType.Checkbox, isOn: this.todoItem.isCompleted })
        .width(20)
        .height(20)
        .selectedColor($r('app.color.accent_color'))
        .onChange((isOn: boolean) => {
          this.onToggle(this.todoItem.id);
        })
      Row() {
        if (this.hasPriority()) {
          Circle()
            .width(6)
            .height(6)
            .fill(this.getPriorityColor())
            .margin({ right: 6 })
        }
        Text(this.todoItem.content)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.todoItem.isCompleted ? $r('app.color.completed_text_color') : $r('app.color.text_primary'))
          .decoration(this.todoItem.isCompleted ? { type: TextDecorationType.LineThrough, color: $r('app.color.completed_text_color') } : { type: TextDecorationType.None, color: Color.Transparent })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width(0)
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.onEditRequest(this.todoItem.id, this.todoItem.content);
      })
      Text(this.getTagSuffix().length > 0 ? this.getTagSuffix().trim() : '')
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(100)
        .textAlign(TextAlign.Start)
        .onClick(() => {
          this.onEditRequest(this.todoItem.id, this.todoItem.content);
        })
      Button({ type: ButtonType.Circle }) {
        Text('\u2715')
          .fontSize(12)
          .fontColor($r('app.color.delete_color'))
      }
      .width(28)
      .height(28)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onDelete(this.todoItem.id);
      })
    }
    .width('100%')
    .padding({ left: 14, right: 10, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(14)
    .shadow({ radius: 8, color: $r('app.color.card_shadow_color'), offsetY: 2 })
    .alignItems(VerticalAlign.Center)
  }
}
