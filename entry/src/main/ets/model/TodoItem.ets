import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export enum Priority {
  None = 0,
  Low = 1,
  Medium = 2,
  High = 3
}

export const PRIORITY_LABELS: Record<string, string> = {
  '0': '',
  '1': '低',
  '2': '中',
  '3': '高'
};

export const CATEGORY_LIST: string[] = ['默认', '工作', '学习', '生活', '健康', '其他'];

@Observed
export class TodoItem {
  id: string = '';
  content: string = '';
  isCompleted: boolean = false;
  createdAt: number = 0;
  priority: Priority = Priority.None;
  category: string = '默认';
  dueDate: number = 0;

  static of(id: string, content: string, createdAt: number): TodoItem {
    const item = new TodoItem();
    item.id = id;
    item.content = content;
    item.isCompleted = false;
    item.createdAt = createdAt;
    item.priority = Priority.None;
    item.category = '默认';
    item.dueDate = 0;
    return item;
  }
}

const PREFS_NAME: string = 'remember_todos';
const KEY_TODO_LIST: string = 'todo_list';

export class TodoStore {
  static loadTodos(context: common.UIAbilityContext): TodoItem[] {
    try {
      const store: preferences.Preferences = preferences.getPreferencesSync(context, { name: PREFS_NAME });
      const jsonStr: string = store.getSync(KEY_TODO_LIST, '[]') as string;
      if (jsonStr === '' || jsonStr === '[]') {
        return [];
      }
      const parsed: Object = JSON.parse(jsonStr);
      const arr: Object[] = parsed as Object[];
      const result: TodoItem[] = [];
      for (let i = 0; i < arr.length; i++) {
        const obj: Object = arr[i];
        const item: TodoItem = new TodoItem();
        const record: Record<string, Object> = obj as Record<string, Object>;
        item.id = (record['id'] ?? '') as string;
        item.content = (record['content'] ?? '') as string;
        item.isCompleted = (record['isCompleted'] ?? false) as boolean;
        item.createdAt = (record['createdAt'] ?? 0) as number;
        item.priority = (record['priority'] ?? 0) as Priority;
        item.category = (record['category'] ?? '默认') as string;
        item.dueDate = (record['dueDate'] ?? 0) as number;
        result.push(item);
      }
      return result;
    } catch (e) {
      const err = e as BusinessError;
      console.error(`TodoStore.loadTodos failed: code=${err.code}, message=${err.message}`);
      return [];
    }
  }

  static saveTodos(context: common.UIAbilityContext, todos: TodoItem[]): void {
    try {
      const store: preferences.Preferences = preferences.getPreferencesSync(context, { name: PREFS_NAME });
      const jsonStr: string = JSON.stringify(todos);
      store.putSync(KEY_TODO_LIST, jsonStr);
      store.flush();
    } catch (e) {
      const err = e as BusinessError;
      console.error(`TodoStore.saveTodos failed: code=${err.code}, message=${err.message}`);
    }
  }
}
