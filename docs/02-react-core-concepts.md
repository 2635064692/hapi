# 模块二：React 核心概念

> 面向 Java/Spring 后端工程师的 React 基础知识
>
> 学习形式：每个概念配代码示例和 Spring 类比

---

## 目录

- [课时 2.1: JSX 语法](#课时-21-jsx-语法)
- [课时 2.2: 组件基础](#课时-22-组件基础)
- [课时 2.3: State 状态管理](#课时-23-state-状态管理)
- [课时 2.4: 事件处理](#课时-24-事件处理)
- [课时 2.5: 条件与列表渲染](#课时-25-条件与列表渲染)
l
---

## 课时 2.1: JSX 语法

> Spring 类比：Thymeleaf/FreeMarker 模板引擎

### 核心概念：JSX 是什么？

**Spring 类比**：JSX ≈ **Thymeleaf/FreeMarker 模板引擎**，但直接写在 Java 代码里

```java
// 假设 Java 能这样写（实际不行，但帮助理解）
public String renderUser(User user) {
    return (
        <div class="user-card">
            <h1>{user.getName()}</h1>
            <p>{user.getEmail()}</p>
        </div>
    );
}
```

这就是 JSX 的本质——**在 JavaScript 代码中直接编写 HTML 结构**。

---

### 2.1.1 JSX 的本质：语法糖

JSX 不是真正的 HTML，而是 `React.createElement()` 的语法糖：

```tsx
// 你写的 JSX
const element = <h1 className="title">Hello, World!</h1>;

// 编译后的 JavaScript（Babel 转换）
const element = React.createElement(
  'h1',                        // 标签类型
  { className: 'title' },      // 属性对象
  'Hello, World!'              // 子元素
);
```

**Spring 类比**：

```html
<!-- Thymeleaf 模板 -->
<h1 th:text="${title}" th:class="${titleClass}">默认标题</h1>

<!-- 最终渲染成 -->
<h1 class="main-title">Hello, World!</h1>
```

JSX 和 Thymeleaf 都是**描述 UI 结构的 DSL**，最终都会转换成实际的 HTML。

---

### 2.1.2 JSX 基本语法规则

#### 规则 1：必须有单一根元素

```tsx
// ❌ 错误：多个根元素
return (
  <h1>标题</h1>
  <p>段落</p>
);

// ✅ 正确：用 div 包裹
return (
  <div>
    <h1>标题</h1>
    <p>段落</p>
  </div>
);

// ✅ 更好：用 Fragment 避免多余 DOM
return (
  <>
    <h1>标题</h1>
    <p>段落</p>
  </>
);
```

**类比理解**：就像 Java 方法只能返回一个对象，JSX 也只能返回一个根节点。

---

#### 规则 2：用 `{}` 插入 JavaScript 表达式

```tsx
function UserGreeting({ user }: { user: User }) {
  const currentTime = new Date().toLocaleTimeString();

  return (
    <div>
      {/* 变量插值 */}
      <h1>欢迎, {user.name}!</h1>

      {/* 表达式计算 */}
      <p>当前时间: {currentTime}</p>

      {/* 函数调用 */}
      <p>用户名长度: {user.name.length}</p>

      {/* 三元表达式 */}
      <p>状态: {user.isVip ? 'VIP用户' : '普通用户'}</p>
    </div>
  );
}
```

**Spring 类比**：

```html
<!-- Thymeleaf -->
<h1 th:text="'欢迎, ' + ${user.name} + '!'">欢迎!</h1>
<p th:text="${user.vip} ? 'VIP用户' : '普通用户'">状态</p>
```

| Thymeleaf | JSX | 说明 |
|-----------|-----|------|
| `${变量}` | `{变量}` | 变量插值 |
| `th:text` | `{表达式}` | 文本内容 |
| `th:if` | `{条件 && 内容}` | 条件渲染 |

---

#### 规则 3：属性使用驼峰命名

```tsx
// HTML 属性 → JSX 属性
<div
  className="container"      // class → className
  htmlFor="inputId"          // for → htmlFor
  tabIndex={0}               // tabindex → tabIndex
  onClick={handleClick}      // onclick → onClick
  style={{ color: 'red' }}   // style 接收对象
>
```

**原因**：`class` 和 `for` 是 JavaScript 保留字。

---

### 2.1.3 条件渲染

#### 方式 1：三元表达式（简单条件）

```tsx
function UserStatus({ isOnline }: { isOnline: boolean }) {
  return (
    <span className={isOnline ? 'status-online' : 'status-offline'}>
      {isOnline ? '在线' : '离线'}
    </span>
  );
}
```

#### 方式 2：逻辑与 `&&`（只显示或不显示）

```tsx
function Notification({ count }: { count: number }) {
  return (
    <div>
      {count > 0 && <span className="badge">{count}</span>}
    </div>
  );
}
```

**注意陷阱**：

```tsx
// ❌ 危险：count 为 0 时会渲染 "0"
{count && <span>{count}</span>}

// ✅ 安全：明确转换为布尔值
{count > 0 && <span>{count}</span>}
{Boolean(count) && <span>{count}</span>}
```

#### 方式 3：提前 return（复杂条件）

```tsx
function UserProfile({ user, isLoading, error }: Props) {
  // 加载状态
  if (isLoading) {
    return <div>加载中...</div>;
  }

  // 错误状态
  if (error) {
    return <div className="error">错误: {error.message}</div>;
  }

  // 空数据
  if (!user) {
    return <div>用户不存在</div>;
  }

  // 正常渲染
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

**Spring 类比**：

```java
// Controller 中的条件处理
@GetMapping("/user/{id}")
public ResponseEntity<?> getUser(@PathVariable Long id) {
    if (isLoading) {
        return ResponseEntity.status(202).body("处理中...");
    }
    if (error != null) {
        return ResponseEntity.badRequest().body(error);
    }
    if (user == null) {
        return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(user);
}
```

---

### 2.1.4 列表渲染

使用 `map()` 方法将数组转换为 JSX 元素列表：

```tsx
interface User {
  id: string;
  name: string;
  email: string;
}

function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>
          <span>{user.name}</span>
          <span>{user.email}</span>
        </li>
      ))}
    </ul>
  );
}
```

**Spring 类比**：

```html
<!-- Thymeleaf -->
<ul>
  <li th:each="user : ${users}">
    <span th:text="${user.name}">名称</span>
    <span th:text="${user.email}">邮箱</span>
  </li>
</ul>
```

#### key 的作用（重要！）

```tsx
// ❌ 错误：使用索引作为 key
{users.map((user, index) => (
  <li key={index}>{user.name}</li>
))}

// ✅ 正确：使用唯一标识作为 key
{users.map(user => (
  <li key={user.id}>{user.name}</li>
))}
```

**为什么需要 key？**

类比数据库主键：

```
React 的 key ≈ 数据库主键（Primary Key）

没有主键时：
- 数据库无法高效定位和更新特定行
- React 无法高效定位和更新特定元素

有主键时：
- UPDATE users SET name='新名字' WHERE id=123  ← 精确定位
- React 通过 key 精确定位哪个元素需要更新
```

**Virtual DOM Diff 算法**：
- key 帮助 React 识别哪些元素是新增、删除、移动还是更新
- 没有 key 时，React 只能按顺序比较，可能导致不必要的重渲染

---

### 2.1.5 JSX 中的注释

```tsx
function Example() {
  return (
    <div>
      {/* 这是 JSX 中的注释 */}
      <p>内容</p>

      {/*
        多行注释
        也是这样写
      */}
    </div>
  );
}
```

---

### 2.1.6 JSX 与模板引擎对比总结

| 特性 | Thymeleaf | JSX |
|------|-----------|-----|
| 语法位置 | 独立模板文件 | 直接在 JS/TS 代码中 |
| 变量插值 | `${变量}` | `{变量}` |
| 条件渲染 | `th:if` / `th:unless` | `{条件 && 内容}` / 三元 |
| 循环渲染 | `th:each` | `.map()` |
| 属性绑定 | `th:属性` | `属性={值}` |
| 类型检查 | 无 | TypeScript 完整支持 |
| IDE 支持 | 有限 | 完整（重构、跳转等） |

**JSX 的优势**：
1. **类型安全**：TypeScript 可以检查 props 和表达式
2. **IDE 支持**：完整的自动补全、重构、跳转到定义
3. **JavaScript 完整能力**：任意 JS 表达式和逻辑

---

### 实践练习

将以下 Thymeleaf 模板转换为 JSX：

```html
<!-- Thymeleaf -->
<div class="user-list">
  <h1 th:text="${title}">用户列表</h1>
  <p th:if="${users.isEmpty()}">暂无用户</p>
  <ul th:unless="${users.isEmpty()}">
    <li th:each="user : ${users}" th:class="${user.vip} ? 'vip' : 'normal'">
      <span th:text="${user.name}">用户名</span>
      <span th:if="${user.vip}">[VIP]</span>
    </li>
  </ul>
</div>
```

**参考答案**：

```tsx
interface User {
  id: string;
  name: string;
  isVip: boolean;
}

function UserList({ title, users }: { title: string; users: User[] }) {
  return (
    <div className="user-list">
      <h1>{title}</h1>

      {users.length === 0 ? (
        <p>暂无用户</p>
      ) : (
        <ul>
          {users.map(user => (
            <li key={user.id} className={user.isVip ? 'vip' : 'normal'}>
              <span>{user.name}</span>
              {user.isVip && <span>[VIP]</span>}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

---

### 课时 2.1 小结

| JSX 语法 | Thymeleaf 类比 | 说明 |
|---------|---------------|------|
| `{变量}` | `${变量}` | 变量插值 |
| `{条件 && 内容}` | `th:if` | 条件渲染 |
| `条件 ? A : B` | `th:if / th:unless` | 二选一渲染 |
| `.map()` | `th:each` | 列表渲染 |
| `key={id}` | — | 列表项唯一标识 |
| `className` | `class` | CSS 类名 |
| `<>...</>` | — | Fragment（无额外 DOM） |

---

## 课时 2.2: 组件基础

> Spring 类比：Controller + Service 分层、Bean 组件

### 2.2.1 什么是组件

**后端类比**：组件 ≈ 可复用的模板片段 + 数据 + 逻辑

```java
// 后端 Spring Bean
@Component
public class UserCardRenderer {
    public String render(User user) {
        return "<div class='user-card'>" +
               "<h3>" + user.getName() + "</h3>" +
               "<p>" + user.getEmail() + "</p>" +
               "</div>";
    }
}
```

```tsx
// React 组件 — 同样的概念，但更声明式
function UserCard({ user }: { user: User }) {
    return (
        <div className="user-card">
            <h3>{user.name}</h3>
            <p>{user.email}</p>
        </div>
    );
}

// 复用
<UserCard user={user1} />
<UserCard user={user2} />
```

**组件的本质**：

```
组件 = 函数(Props) => UI

输入：Props（外部传入的数据）
输出：UI 描述（JSX → Virtual DOM）
```

---

### 2.2.2 函数组件 vs 类组件

#### 现代方式：函数组件（推荐）

```tsx
// 函数组件 — 就是一个返回 JSX 的函数
function Greeting({ name }: { name: string }) {
    return <h1>Hello, {name}!</h1>;
}

// 箭头函数写法
const Greeting = ({ name }: { name: string }) => {
    return <h1>Hello, {name}!</h1>;
};

// 使用
<Greeting name="Tom" />
```

#### 传统方式：类组件（了解即可）

```tsx
// 类组件 — React 16.8 之前的主流写法
class Greeting extends React.Component<{ name: string }> {
    render() {
        return <h1>Hello, {this.props.name}!</h1>;
    }
}
```

**后端类比**：

| React | Java | 说明 |
|-------|------|------|
| 函数组件 | 静态方法 | 无状态，输入输出明确 |
| 类组件 | 有状态的 Bean | 需要管理生命周期 |

**为什么推荐函数组件**：
1. 代码更简洁
2. Hooks 只能在函数组件中使用
3. 更容易理解和测试
4. 性能稍优（无 class 实例化开销）

---

### 2.2.3 Props（属性）

Props 是组件的输入参数，类似 Java 方法的参数。

#### 基本用法

```tsx
// 定义组件，接收 Props
interface UserCardProps {
    name: string;
    email: string;
    age?: number;           // 可选属性
    isVip?: boolean;        // 可选属性
}

function UserCard({ name, email, age, isVip = false }: UserCardProps) {
    return (
        <div className={isVip ? 'vip-card' : 'card'}>
            <h3>{name}</h3>
            <p>{email}</p>
            {age && <p>年龄: {age}</p>}
        </div>
    );
}

// 使用组件，传递 Props
<UserCard name="Tom" email="tom@test.com" />
<UserCard name="Jerry" email="jerry@test.com" age={25} isVip={true} />
```

**后端类比**：

```java
// Java DTO + 方法调用
public record UserCardProps(
    String name,
    String email,
    @Nullable Integer age,
    boolean isVip  // 默认值在使用处处理
) {}

public String renderUserCard(UserCardProps props) {
    // 渲染逻辑
}

// 调用
renderUserCard(new UserCardProps("Tom", "tom@test.com", null, false));
```

#### Props 是只读的

```tsx
function UserCard({ name }: { name: string }) {
    // ❌ 错误：不能修改 Props
    name = "New Name";  // TypeScript 会报错

    // ✓ 正确：只读使用
    return <h1>{name}</h1>;
}
```

**后端类比**：Props 类似 `final` 参数或不可变对象。

---

### 2.2.4 children Props

`children` 是特殊的 Props，表示组件标签之间的内容。

```tsx
// 定义容器组件
interface CardProps {
    title: string;
    children: React.ReactNode;  // 任意 JSX 内容
}

function Card({ title, children }: CardProps) {
    return (
        <div className="card">
            <div className="card-header">{title}</div>
            <div className="card-body">{children}</div>
        </div>
    );
}

// 使用 — children 是标签之间的内容
<Card title="用户信息">
    <p>姓名：Tom</p>
    <p>邮箱：tom@test.com</p>
</Card>
```

**后端类比**：

```html
<!-- Thymeleaf Layout -->
<div layout:fragment="content">
    <!-- 这里的内容会被插入到布局中 -->
</div>
```

---

### 2.2.5 组件组合

React 推崇**组合优于继承**。

```tsx
// 基础组件
function Button({ children, onClick }: { children: React.ReactNode; onClick?: () => void }) {
    return <button onClick={onClick}>{children}</button>;
}

function Icon({ name }: { name: string }) {
    return <span className={`icon-${name}`} />;
}

// 组合使用
function IconButton({ icon, children, onClick }: {
    icon: string;
    children: React.ReactNode;
    onClick?: () => void;
}) {
    return (
        <Button onClick={onClick}>
            <Icon name={icon} />
            {children}
        </Button>
    );
}

// 使用
<IconButton icon="save" onClick={handleSave}>保存</IconButton>
```

**后端类比**：

```java
// Java 组合模式
public class IconButton {
    private final Button button;
    private final Icon icon;

    public IconButton(Icon icon, Button button) {
        this.icon = icon;
        this.button = button;
    }
}
```

---

### 2.2.6 组件的文件组织

```
src/
├── components/           # 可复用组件
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.css
│   │   └── index.ts      # 导出
│   ├── Card/
│   │   ├── Card.tsx
│   │   └── index.ts
│   └── index.ts          # 桶文件，统一导出
├── pages/                # 页面组件
│   ├── HomePage.tsx
│   └── UserPage.tsx
└── App.tsx               # 根组件
```

**桶文件模式**：

```typescript
// components/index.ts
export { Button } from './Button';
export { Card } from './Card';

// 使用时
import { Button, Card } from '@/components';
```

---

### 2.2.7 组件命名规范

| 规范 | 示例 | 说明 |
|-----|------|------|
| 组件名 PascalCase | `UserCard` | 首字母大写 |
| 文件名与组件名一致 | `UserCard.tsx` | 便于查找 |
| Props 类型加后缀 | `UserCardProps` | 明确类型用途 |
| 事件处理函数前缀 | `handleClick` | 表明是事件处理器 |

---

### 课时 2.2 小结

| 概念 | React | Java/Spring 类比 |
|-----|-------|-----------------|
| 组件 | 函数返回 JSX | Bean/Service |
| Props | 组件参数 | 方法参数/DTO |
| children | 嵌套内容 | 模板插槽 |
| 组合 | 组件嵌套 | 组合模式 |
| 命名 | PascalCase | 类名规范 |

---

## 课时 2.3: State 状态管理

> Spring 类比：Session 状态、实体对象状态

### 2.3.1 Props vs State

| 特性 | Props | State |
|-----|-------|-------|
| 来源 | 父组件传入 | 组件内部创建 |
| 可变性 | 只读（immutable） | 可变（通过 setState） |
| 作用 | 配置组件 | 管理组件内部数据 |
| 类比 | 方法参数 | 成员变量 |

```tsx
function Counter({ initialValue }: { initialValue: number }) {
    // initialValue 是 Props —— 外部传入，不可变
    // count 是 State —— 内部管理，可变
    const [count, setCount] = useState(initialValue);

    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={() => setCount(count + 1)}>+1</button>
        </div>
    );
}
```

---

### 2.3.2 useState Hook

#### 基本用法

```tsx
import { useState } from 'react';

function Counter() {
    // useState 返回 [当前值, 更新函数]
    const [count, setCount] = useState(0);

    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={() => setCount(count + 1)}>增加</button>
            <button onClick={() => setCount(count - 1)}>减少</button>
            <button onClick={() => setCount(0)}>重置</button>
        </div>
    );
}
```

**后端类比**：

```java
// Java 有状态对象
public class Counter {
    private int count = 0;  // 成员变量

    public int getCount() { return count; }
    public void setCount(int value) {
        this.count = value;
        this.notifyObservers();  // 通知视图更新
    }
}
```

#### 多个 State

```tsx
function UserForm() {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [age, setAge] = useState(0);

    return (
        <form>
            <input value={name} onChange={e => setName(e.target.value)} />
            <input value={email} onChange={e => setEmail(e.target.value)} />
            <input
                type="number"
                value={age}
                onChange={e => setAge(Number(e.target.value))}
            />
        </form>
    );
}
```

#### 对象作为 State

```tsx
interface User {
    name: string;
    email: string;
    age: number;
}

function UserForm() {
    const [user, setUser] = useState<User>({
        name: '',
        email: '',
        age: 0
    });

    // ❌ 错误：直接修改对象
    const handleNameChange = (name: string) => {
        user.name = name;  // React 不会检测到变化！
    };

    // ✅ 正确：创建新对象
    const handleNameChange = (name: string) => {
        setUser({ ...user, name });  // 展开运算符创建新对象
    };

    // ✅ 更好：使用函数式更新
    const handleAgeChange = (age: number) => {
        setUser(prev => ({ ...prev, age }));
    };

    return (
        <form>
            <input
                value={user.name}
                onChange={e => handleNameChange(e.target.value)}
            />
        </form>
    );
}
```

**为什么不能直接修改？**

```
React 通过引用比较检测变化：

user.name = 'new';     // 对象引用不变，React 认为没变化
setUser({...user});    // 新对象引用，React 知道要重渲染
```

**后端类比**：

```java
// Hibernate 脏检查需要新对象
// ❌ 直接修改原对象，JPA 可能检测到（但 React 不会）
user.setName("new");

// ✅ React 需要的方式
User newUser = new User(user);  // 复制
newUser.setName("new");
setUser(newUser);
```

---

### 2.3.3 数组作为 State

```tsx
function TodoList() {
    const [todos, setTodos] = useState<string[]>([]);
    const [input, setInput] = useState('');

    // 添加
    const addTodo = () => {
        setTodos([...todos, input]);  // 创建新数组
        setInput('');
    };

    // 删除
    const removeTodo = (index: number) => {
        setTodos(todos.filter((_, i) => i !== index));
    };

    // 更新
    const updateTodo = (index: number, newValue: string) => {
        setTodos(todos.map((todo, i) =>
            i === index ? newValue : todo
        ));
    };

    return (
        <div>
            <input value={input} onChange={e => setInput(e.target.value)} />
            <button onClick={addTodo}>添加</button>
            <ul>
                {todos.map((todo, index) => (
                    <li key={index}>
                        {todo}
                        <button onClick={() => removeTodo(index)}>删除</button>
                    </li>
                ))}
            </ul>
        </div>
    );
}
```

**数组不可变操作对照表**：

| 操作 | 可变方法（❌ 避免） | 不可变方法（✅ 使用） |
|-----|------------------|-------------------|
| 添加 | `push()` | `[...arr, item]` |
| 删除 | `splice()` | `filter()` |
| 更新 | `arr[i] = x` | `map()` |
| 排序 | `sort()` | `[...arr].sort()` |
| 反转 | `reverse()` | `[...arr].reverse()` |

---

### 2.3.4 State 更新是异步的

```tsx
function Counter() {
    const [count, setCount] = useState(0);

    const handleClick = () => {
        setCount(count + 1);
        console.log(count);  // 还是旧值！不是 count + 1

        // 如果需要基于最新值
        setCount(prev => prev + 1);  // 函数式更新
    };

    // 多次更新的陷阱
    const addThree = () => {
        // ❌ 这样只会 +1，因为 count 在这次渲染中是固定的
        setCount(count + 1);
        setCount(count + 1);
        setCount(count + 1);

        // ✅ 正确：使用函数式更新
        setCount(prev => prev + 1);
        setCount(prev => prev + 1);
        setCount(prev => prev + 1);
    };
}
```

**后端类比**：

```java
// 类似数据库的 Read Committed 隔离级别
// 在同一个"事务"（渲染）中，读取的是快照值

@Transactional
public void updateCount() {
    int count = getCount();      // 读取快照
    setCount(count + 1);         // 更新
    System.out.println(count);   // 打印的是旧值
}
```

---

### 2.3.5 State 提升

当多个组件需要共享状态时，将状态提升到共同的父组件。

```tsx
// 子组件 A：显示温度
function TemperatureDisplay({ celsius }: { celsius: number }) {
    return <p>温度: {celsius}°C / {celsius * 9/5 + 32}°F</p>;
}

// 子组件 B：调整温度
function TemperatureInput({
    celsius,
    onChange
}: {
    celsius: number;
    onChange: (value: number) => void;
}) {
    return (
        <input
            type="number"
            value={celsius}
            onChange={e => onChange(Number(e.target.value))}
        />
    );
}

// 父组件：管理共享状态
function TemperatureApp() {
    const [celsius, setCelsius] = useState(0);  // 状态提升到这里

    return (
        <div>
            <TemperatureInput celsius={celsius} onChange={setCelsius} />
            <TemperatureDisplay celsius={celsius} />
        </div>
    );
}
```

**后端类比**：

```java
// Service 层管理共享状态
@Service
public class TemperatureService {
    private double celsius;

    public double getCelsius() { return celsius; }
    public void setCelsius(double value) { this.celsius = value; }
}

// Controller A 和 Controller B 都注入同一个 Service
```

---

### 2.3.6 State 设计原则

| 原则 | 说明 | 示例 |
|-----|------|------|
| 最小化 | 只存储必要数据 | 不存储可计算的值 |
| 单一数据源 | 避免重复数据 | 用 userId 而不是整个 user |
| 扁平化 | 避免深层嵌套 | 拆分成多个 state |
| 就近原则 | 状态放在需要它的最近组件 | 不要全部放根组件 |

```tsx
// ❌ 冗余状态
const [items, setItems] = useState<Item[]>([]);
const [total, setTotal] = useState(0);  // 可以从 items 计算

// ✅ 派生计算
const [items, setItems] = useState<Item[]>([]);
const total = items.reduce((sum, item) => sum + item.price, 0);
```

---

### 课时 2.3 小结

| 概念 | React | Java 类比 |
|-----|-------|----------|
| State | `useState(initial)` | 成员变量 |
| 更新 State | `setState(newValue)` | setter + 通知更新 |
| 不可变更新 | `{...obj, prop: value}` | 创建新对象 |
| 函数式更新 | `setState(prev => ...)` | 基于当前值计算 |
| State 提升 | 移到父组件 | Service 层共享 |

---

## 课时 2.4: 事件处理

> Spring 类比：Controller 接收请求、事件监听器

### 2.4.1 基本事件处理

```tsx
function Button() {
    // 事件处理函数
    const handleClick = () => {
        console.log('按钮被点击');
    };

    // 绑定事件
    return <button onClick={handleClick}>点击我</button>;
}
```

**后端类比**：

```java
// Spring MVC Controller
@PostMapping("/click")
public void handleClick() {
    System.out.println("按钮被点击");
}
```

---

### 2.4.2 事件命名规范

| HTML | React | 说明 |
|------|-------|------|
| `onclick` | `onClick` | 驼峰命名 |
| `onchange` | `onChange` | 驼峰命名 |
| `onsubmit` | `onSubmit` | 驼峰命名 |
| `"handleClick()"` | `{handleClick}` | 传函数引用 |

```tsx
// ❌ 错误：立即执行
<button onClick={handleClick()}>  // 渲染时就执行了！

// ✅ 正确：传递函数引用
<button onClick={handleClick}>

// ✅ 需要传参时，用箭头函数包裹
<button onClick={() => handleClick(id)}>
```

---

### 2.4.3 事件对象

```tsx
function Form() {
    const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();  // 阻止默认提交行为
        console.log('表单提交');
    };

    const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const value = event.target.value;  // 获取输入值
        console.log('输入:', value);
    };

    const handleButtonClick = (event: React.MouseEvent<HTMLButtonElement>) => {
        console.log('点击位置:', event.clientX, event.clientY);
    };

    return (
        <form onSubmit={handleSubmit}>
            <input onChange={handleInputChange} />
            <button type="button" onClick={handleButtonClick}>点击</button>
            <button type="submit">提交</button>
        </form>
    );
}
```

**常用事件类型**：

| 事件 | 类型 | 触发时机 |
|-----|------|---------|
| `onClick` | `MouseEvent` | 点击 |
| `onChange` | `ChangeEvent` | 输入值变化 |
| `onSubmit` | `FormEvent` | 表单提交 |
| `onKeyDown` | `KeyboardEvent` | 按下键盘 |
| `onFocus` | `FocusEvent` | 获得焦点 |
| `onBlur` | `FocusEvent` | 失去焦点 |

---

### 2.4.4 传递参数给事件处理器

```tsx
function ItemList({ items }: { items: Item[] }) {
    // 方式 1：箭头函数包裹
    const handleDelete = (id: string) => {
        console.log('删除:', id);
    };

    // 方式 2：柯里化（函数返回函数）
    const handleEdit = (id: string) => (event: React.MouseEvent) => {
        console.log('编辑:', id, event);
    };

    return (
        <ul>
            {items.map(item => (
                <li key={item.id}>
                    {item.name}
                    {/* 方式 1 */}
                    <button onClick={() => handleDelete(item.id)}>删除</button>
                    {/* 方式 2 */}
                    <button onClick={handleEdit(item.id)}>编辑</button>
                </li>
            ))}
        </ul>
    );
}
```

---

### 2.4.5 受控组件 vs 非受控组件

#### 受控组件（推荐）

组件的值由 React State 控制：

```tsx
function ControlledInput() {
    const [value, setValue] = useState('');

    return (
        <input
            value={value}                              // React 控制值
            onChange={e => setValue(e.target.value)}   // 每次变化更新 State
        />
    );
}
```

**后端类比**：

```java
// 类似双向绑定的表单
@ModelAttribute
public UserForm userForm() {
    return new UserForm();  // Spring 管理表单状态
}
```

#### 非受控组件

使用 ref 直接访问 DOM：

```tsx
function UncontrolledInput() {
    const inputRef = useRef<HTMLInputElement>(null);

    const handleSubmit = () => {
        console.log('值:', inputRef.current?.value);  // 直接读取 DOM
    };

    return (
        <div>
            <input ref={inputRef} defaultValue="默认值" />
            <button onClick={handleSubmit}>提交</button>
        </div>
    );
}
```

**对比**：

| 特性 | 受控组件 | 非受控组件 |
|-----|---------|-----------|
| 值来源 | React State | DOM |
| 即时验证 | ✅ 容易 | ❌ 困难 |
| 动态禁用 | ✅ 容易 | ❌ 困难 |
| 表单提交 | 从 State 获取 | 从 ref 获取 |
| 代码量 | 较多 | 较少 |
| 推荐场景 | 大多数情况 | 简单场景/第三方库 |

---

### 2.4.6 表单处理完整示例

```tsx
interface FormData {
    username: string;
    email: string;
    role: string;
    agree: boolean;
}

function RegistrationForm() {
    const [formData, setFormData] = useState<FormData>({
        username: '',
        email: '',
        role: 'user',
        agree: false
    });
    const [errors, setErrors] = useState<Partial<FormData>>({});

    // 通用输入处理
    const handleChange = (
        e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
    ) => {
        const { name, value, type } = e.target;
        const checked = (e.target as HTMLInputElement).checked;

        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    // 验证
    const validate = (): boolean => {
        const newErrors: Partial<FormData> = {};

        if (!formData.username) {
            newErrors.username = '用户名不能为空';
        }
        if (!formData.email.includes('@')) {
            newErrors.email = '邮箱格式不正确';
        }
        if (!formData.agree) {
            newErrors.agree = '必须同意条款';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    // 提交
    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validate()) {
            console.log('提交:', formData);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <div>
                <input
                    name="username"
                    value={formData.username}
                    onChange={handleChange}
                    placeholder="用户名"
                />
                {errors.username && <span className="error">{errors.username}</span>}
            </div>

            <div>
                <input
                    name="email"
                    type="email"
                    value={formData.email}
                    onChange={handleChange}
                    placeholder="邮箱"
                />
                {errors.email && <span className="error">{errors.email}</span>}
            </div>

            <div>
                <select name="role" value={formData.role} onChange={handleChange}>
                    <option value="user">普通用户</option>
                    <option value="admin">管理员</option>
                </select>
            </div>

            <div>
                <label>
                    <input
                        name="agree"
                        type="checkbox"
                        checked={formData.agree}
                        onChange={handleChange}
                    />
                    同意用户条款
                </label>
            </div>

            <button type="submit">注册</button>
        </form>
    );
}
```

---

### 2.4.7 事件冒泡与阻止

```tsx
function NestedButtons() {
    const handleOuterClick = () => console.log('外层点击');
    const handleInnerClick = (e: React.MouseEvent) => {
        e.stopPropagation();  // 阻止冒泡
        console.log('内层点击');
    };

    return (
        <div onClick={handleOuterClick}>
            <button onClick={handleInnerClick}>内层按钮</button>
        </div>
    );
}
```

| 方法 | 作用 |
|-----|------|
| `e.preventDefault()` | 阻止默认行为（如表单提交、链接跳转） |
| `e.stopPropagation()` | 阻止事件冒泡到父元素 |

---

### 课时 2.4 小结

| 概念 | React | 说明 |
|-----|-------|------|
| 事件绑定 | `onClick={handler}` | 传递函数引用 |
| 事件对象 | `React.MouseEvent` 等 | 类型化的事件 |
| 传参 | `onClick={() => fn(id)}` | 箭头函数包裹 |
| 受控组件 | `value` + `onChange` | React 管理值 |
| 阻止默认 | `e.preventDefault()` | 阻止浏览器行为 |

---

## 课时 2.5: 条件与列表渲染

> Spring 类比：Thymeleaf th:if / th:each

### 2.5.1 条件渲染详解

#### 方式一：if-else 提前返回

```tsx
function UserGreeting({ user, isLoading, error }: {
    user: User | null;
    isLoading: boolean;
    error: Error | null;
}) {
    if (isLoading) {
        return <LoadingSpinner />;
    }

    if (error) {
        return <ErrorMessage message={error.message} />;
    }

    if (!user) {
        return <EmptyState message="用户不存在" />;
    }

    return <UserProfile user={user} />;
}
```

**适用场景**：互斥的多个状态，整个组件只显示一种。

#### 方式二：三元表达式

```tsx
function UserStatus({ isOnline }: { isOnline: boolean }) {
    return (
        <div>
            <span className={isOnline ? 'online' : 'offline'}>
                {isOnline ? '在线' : '离线'}
            </span>
        </div>
    );
}
```

**适用场景**：二选一的简单条件。

#### 方式三：逻辑与 &&

```tsx
function NotificationBadge({ count }: { count: number }) {
    return (
        <div className="notification">
            <span>通知</span>
            {count > 0 && <span className="badge">{count}</span>}
        </div>
    );
}
```

**适用场景**：显示或不显示。

**注意陷阱**：

```tsx
// ❌ 问题：0 会被渲染出来
{count && <span>{count}</span>}  // count=0 时显示 "0"

// ✅ 解决方案
{count > 0 && <span>{count}</span>}
{!!count && <span>{count}</span>}
{Boolean(count) && <span>{count}</span>}
```

#### 方式四：变量存储 JSX

```tsx
function UserPanel({ user, isAdmin }: { user: User; isAdmin: boolean }) {
    let adminSection: React.ReactNode = null;

    if (isAdmin) {
        adminSection = (
            <div className="admin-panel">
                <h3>管理员功能</h3>
                <AdminTools />
            </div>
        );
    }

    return (
        <div>
            <UserInfo user={user} />
            {adminSection}
        </div>
    );
}
```

**适用场景**：复杂的条件逻辑，提高可读性。

---

### 2.5.2 条件渲染对比总结

| 方式 | 适用场景 | 示例 |
|-----|---------|------|
| if-else return | 互斥状态，整体替换 | loading/error/empty/data |
| 三元 `? :` | 二选一 | 在线/离线 |
| 逻辑与 `&&` | 显示/不显示 | 红点徽章 |
| 变量存储 | 复杂条件 | 多层嵌套判断 |

---

### 2.5.3 列表渲染详解

#### 基本用法

```tsx
function UserList({ users }: { users: User[] }) {
    return (
        <ul>
            {users.map(user => (
                <li key={user.id}>
                    {user.name} - {user.email}
                </li>
            ))}
        </ul>
    );
}
```

#### key 的最佳实践

```tsx
// ✅ 使用唯一且稳定的 ID
{users.map(user => <UserCard key={user.id} user={user} />)}

// ✅ 复合 key（当单个字段不唯一时）
{items.map(item => <Item key={`${item.type}-${item.id}`} item={item} />)}

// ❌ 避免使用索引作为 key（除非列表静态不变）
{users.map((user, index) => <UserCard key={index} user={user} />)}

// ❌ 避免使用随机数作为 key
{users.map(user => <UserCard key={Math.random()} user={user} />)}
```

**为什么索引作为 key 有问题？**

```tsx
// 假设列表 [A, B, C]，使用索引 key
<li key={0}>A</li>
<li key={1}>B</li>
<li key={2}>C</li>

// 删除 A 后，列表变成 [B, C]
<li key={0}>B</li>  // React 认为这是原来的 key=0，只是内容从 A 变成 B
<li key={1}>C</li>  // React 认为这是原来的 key=1，只是内容从 B 变成 C
// React 认为 key=2 被删除了

// 结果：React 错误地复用了 DOM 节点，可能导致状态混乱
```

#### 列表项组件抽取

```tsx
// 抽取列表项为独立组件
interface UserCardProps {
    user: User;
    onEdit: (id: string) => void;
    onDelete: (id: string) => void;
}

function UserCard({ user, onEdit, onDelete }: UserCardProps) {
    return (
        <div className="user-card">
            <h3>{user.name}</h3>
            <p>{user.email}</p>
            <button onClick={() => onEdit(user.id)}>编辑</button>
            <button onClick={() => onDelete(user.id)}>删除</button>
        </div>
    );
}

// 列表组件
function UserList({ users }: { users: User[] }) {
    const handleEdit = (id: string) => console.log('编辑', id);
    const handleDelete = (id: string) => console.log('删除', id);

    return (
        <div className="user-list">
            {users.map(user => (
                <UserCard
                    key={user.id}
                    user={user}
                    onEdit={handleEdit}
                    onDelete={handleDelete}
                />
            ))}
        </div>
    );
}
```

---

### 2.5.4 空列表处理

```tsx
function UserList({ users }: { users: User[] }) {
    if (users.length === 0) {
        return (
            <div className="empty-state">
                <p>暂无用户</p>
                <button>添加用户</button>
            </div>
        );
    }

    return (
        <ul>
            {users.map(user => (
                <li key={user.id}>{user.name}</li>
            ))}
        </ul>
    );
}
```

---

### 2.5.5 嵌套列表

```tsx
interface Category {
    id: string;
    name: string;
    products: Product[];
}

function CategoryList({ categories }: { categories: Category[] }) {
    return (
        <div>
            {categories.map(category => (
                <div key={category.id} className="category">
                    <h2>{category.name}</h2>
                    <ul>
                        {category.products.map(product => (
                            <li key={product.id}>{product.name}</li>
                        ))}
                    </ul>
                </div>
            ))}
        </div>
    );
}
```

---

### 2.5.6 列表过滤和排序

```tsx
function FilterableList({ users }: { users: User[] }) {
    const [search, setSearch] = useState('');
    const [sortBy, setSortBy] = useState<'name' | 'age'>('name');

    // 过滤
    const filteredUsers = users.filter(user =>
        user.name.toLowerCase().includes(search.toLowerCase())
    );

    // 排序
    const sortedUsers = [...filteredUsers].sort((a, b) => {
        if (sortBy === 'name') {
            return a.name.localeCompare(b.name);
        }
        return a.age - b.age;
    });

    return (
        <div>
            <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="搜索用户..."
            />
            <select value={sortBy} onChange={e => setSortBy(e.target.value as any)}>
                <option value="name">按名称</option>
                <option value="age">按年龄</option>
            </select>

            <ul>
                {sortedUsers.map(user => (
                    <li key={user.id}>
                        {user.name} - {user.age}岁
                    </li>
                ))}
            </ul>
        </div>
    );
}
```

**注意**：过滤和排序应该基于原始数据计算，而不是存储为独立的 State。

---

### 2.5.7 与 Thymeleaf 对比

| 操作 | Thymeleaf | React JSX |
|-----|-----------|-----------|
| 条件显示 | `th:if="${cond}"` | `{cond && <.../>}` |
| 条件隐藏 | `th:unless="${cond}"` | `{!cond && <.../>}` |
| 二选一 | `th:if` + `th:unless` | `{cond ? <A/> : <B/>}` |
| 循环 | `th:each="item : ${list}"` | `{list.map(item => ...)}` |
| 循环索引 | `${iterStat.index}` | `{list.map((item, i) => ...)}` |
| 空判断 | `th:if="${#lists.isEmpty(list)}"` | `{list.length === 0 && ...}` |

---

### 课时 2.5 小结

| 模式 | 语法 | 适用场景 |
|-----|------|---------|
| 三元渲染 | `{cond ? A : B}` | 二选一 |
| 逻辑与 | `{cond && A}` | 显示/隐藏 |
| 提前返回 | `if (...) return` | 互斥状态 |
| 列表渲染 | `.map(x => <X key/>)` | 数组转 JSX |
| key | `key={uniqueId}` | 唯一稳定标识 |
| 空状态 | `length === 0` | 空列表提示 |

---

## 模块二总结

### 完成的课时

| 课时 | 主题 | 核心内容 |
|-----|------|---------|
| 2.1 | JSX 语法 | 语法规则、表达式、条件渲染、列表渲染 |
| 2.2 | 组件基础 | 函数组件、Props、children、组件组合 |
| 2.3 | State 状态管理 | useState、不可变更新、状态提升 |
| 2.4 | 事件处理 | 事件绑定、受控组件、表单处理 |
| 2.5 | 条件与列表渲染 | 条件渲染模式、key 的作用、列表处理 |

### 后端视角核心映射

| React 概念 | Java/Spring 类比 |
|-----------|-----------------|
| JSX | Thymeleaf 模板 |
| 组件 | Service/Bean |
| Props | 方法参数/DTO |
| State | 成员变量 |
| 事件处理 | Controller 方法 |
| 受控组件 | 双向绑定表单 |
| key | 数据库主键 |

### 下一步

模块三将开始讲解 React Hooks 进阶：
- 3.1 useEffect 副作用
- 3.2 useRef 引用
- 3.3 useMemo 与 useCallback 优化
- 3.4 自定义 Hook
- 3.5 常用 Hook 模式

---
