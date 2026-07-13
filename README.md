# Remember

一个基于 HarmonyOS ArkTS & ArkUI 开发的待办事项应用。

## 功能特性

- 待办事项增删改查
- 优先级标记：无 / 低 / 中 / 高
- 分类标签：默认 / 工作 / 学习 / 生活 / 健康 / 其他
- 截止日期：月份+日期双滚轮选择器（点击展开/收起）
- 搜索栏
- 状态筛选：全部 / 待办 / 已完成
- 排序：默认 / 按优先级 / 按到期日期 / 按创建时间
- 批量操作：全选 / 取消全选 / 批量删除 / 批量完成
- 深色模式切换
- 本地数据持久化（Preferences）

## 技术栈

- **语言：** ArkTS
- **UI 框架：** ArkUI (@Component, @State, @Prop, @Observed, @CustomDialog)
- **存储：** @kit.ArkData (Preferences)
- **平台：** HarmonyOS / OpenHarmony
- **SDK：** HarmonyOS NEXT

## 项目结构

```
entry/src/main/
├── ets/
│   ├── entryability/
│   │   └── EntryAbility.ets          # 应用入口 Ability
│   ├── model/
│   │   └── TodoItem.ets              # TodoItem 模型、Priority 枚举、TodoStore
│   ├── components/
│   │   └── TodoCard.ets              # 待办卡片组件
│   └── pages/
│       └── Index.ets                  # 主页面（搜索/筛选/排序/批量/对话框）
├── resources/
│   ├── base/
│   │   ├── element/
│   │   │   ├── string.json           # 字符串资源
│   │   │   ├── color.json            # 浅色主题颜色
│   │   │   └── float.json            # 尺寸资源
│   │   ├── media/                    # 应用图标
│   │   └── profile/
│   │       └── main_pages.json       # 页面路由配置
│   └── dark/
│       └── element/
│           └── color.json            # 深色主题颜色
└── module.json5                      # 模块配置
```

## 数据模型

```typescript
class TodoItem {
  id: string           // 唯一标识
  content: string      // 待办内容
  isCompleted: boolean // 是否完成
  createdAt: number    // 创建时间戳
  priority: Priority   // 0=无, 1=低, 2=中, 3=高
  category: string     // 分类标签
  dueDate: number      // 截止日期时间戳（0=无日期）
}
```

## 关键设计决策

- **统一 TodoDialog**：添加和编辑共用一个 @CustomDialog，通过 `isAddMode` 标志区分
- **显示列表模式**：`@State displayList` 与 `todoList` 分离缓存，数据变更后调用 `refreshDisplay()` 刷新 UI
- **排序**：手动冒泡排序（规避 ArkTS lambda/原型链限制）
- **日期选择器**：TextPicker 双滚轮（月+日），点击切换显示/隐藏
- **深色模式**：使用 `WithTheme({ colorMode })` 包裹 + dark 资源限定符
- **批量操作响应式**：TodoCard 使用 `@Prop isInBatchMode` / `@Prop isBatchChecked`

## 构建与运行

1. 在 DevEco Studio 中打开项目
2. 连接 HarmonyOS 设备或启动模拟器
3. 构建并运行 entry 模块

## 许可证

MIT
