# 模块三：React Hooks 进阶

> 面向 Java/Spring 后端工程师的 React Hooks 深入讲解
>
> 学习形式：每个 Hook 配代码示例和 Spring 类比

---

## 目录

- [课时 3.1: useEffect 副作用](#课时-31-useeffect-副作用)
- [课时 3.2: useRef 引用](#课时-32-useref-引用)
- [课时 3.3: useMemo 与 useCallback 优化](#课时-33-usememo-与-usecallback-优化)
- [课时 3.4: 自定义 Hook](#课时-34-自定义-hook)
- [课时 3.5: 常用 Hook 模式](#课时-35-常用-hook-模式)

---

## 课时 3.1: useEffect 副作用

> Spring 类比：@PostConstruct、@PreDestroy、@Async、AOP 切面

### 3.1.1 什么是副作用

**纯函数 vs 副作用**：

```tsx
// 纯函数：相同输入 → 相同输出，无外部影响
function add(a: number, b: number): number {
    return a + b;
}

// 副作用：影响外部世界或依赖外部状态
function fetchUser(id: string) {
    fetch(`/api/users/${id}`);  // 网络请求 = 副作用
}

function logMessage(msg: string) {
    console.log(msg);  // 控制台输出 = 副作用
}

function saveToStorage(data: object) {
    localStorage.setItem('data', JSON.stringify(data));  // 存储 = 副作用
}
```

**React 组件中的副作用**：
- API 请求
- 订阅/取消订阅（WebSocket、事件监听）
- 手动 DOM 操作
- 定时器
- 日志记录

**后端类比**：

```java
@Service
public class UserService {

    @PostConstruct  // 初始化时执行（类似 useEffect 首次渲染）
    public void init() {
        loadCache();
    }

    @PreDestroy  // 销毁时执行（类似 useEffect 清理函数）
    public void cleanup() {
        clearCache();
    }
}
```

---

### 3.1.2 useEffect 基本用法

```tsx
import { useEffect, useState } from 'react';

function UserProfile({ userId }: { userId: string }) {
    const [user, setUser] = useState<User | null>(null);

    useEffect(() => {
        // 副作用：API 请求
        async function fetchUser() {
            const response = await fetch(`/api/users/${userId}`);
            const data = await response.json();
            setUser(data);
        }

        fetchUser();
    }, [userId]);  // 依赖数组：userId 变化时重新执行

    return <div>{user?.name}</div>;
}
```

**执行时机**：

```
组件挂载（首次渲染）
         │
         ▼
    渲染完成，DOM 更新
         │
         ▼
    useEffect 回调执行  ← 在 DOM 更新后异步执行
         │
         ▼
    userId 变化
         │
         ▼
    重新渲染，DOM 更新
         │
         ▼
    清理函数执行（如果有）
         │
         ▼
    useEffect 回调再次执行
```

---

### 3.1.3 依赖数组详解

#### 情况一：空数组 `[]` — 仅首次渲染执行

```tsx
useEffect(() => {
    console.log('只在组件挂载时执行一次');

    return () => {
        console.log('只在组件卸载时执行一次');
    };
}, []);  // 空数组 = 无依赖
```

**后端类比**：`@PostConstruct` + `@PreDestroy`

#### 情况二：有依赖 `[a, b]` — 依赖变化时执行

```tsx
useEffect(() => {
    console.log(`userId 或 token 变化了: ${userId}, ${token}`);
    fetchUserData(userId, token);
}, [userId, token]);  // userId 或 token 变化时执行
```

**后端类比**：监听配置变化的 `@RefreshScope`

#### 情况三：无依赖数组 — 每次渲染都执行

```tsx
useEffect(() => {
    console.log('每次渲染后都执行');
});  // 没有依赖数组
```

**注意**：这种用法很少见，通常是错误的。

#### 依赖数组对比

| 依赖数组 | 执行时机 | 类似 |
|---------|---------|-----|
| `[]` | 仅挂载时 | @PostConstruct |
| `[a, b]` | a 或 b 变化时 | @EventListener |
| 无 | 每次渲染后 | 极少使用 |

---

### 3.1.4 清理函数（Cleanup）

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
    useEffect(() => {
        // 建立连接
        const connection = createConnection(roomId);
        connection.connect();

        // 清理函数：在组件卸载或 roomId 变化前执行
        return () => {
            connection.disconnect();  // 断开连接
        };
    }, [roomId]);

    return <div>Chat Room: {roomId}</div>;
}
```

**执行顺序**：

```
1. 首次渲染，roomId = "room1"
   └─→ 执行 effect：连接 room1

2. roomId 变化为 "room2"
   ├─→ 先执行清理：断开 room1
   └─→ 再执行 effect：连接 room2

3. 组件卸载
   └─→ 执行清理：断开 room2
```

**后端类比**：

```java
// Spring 资源管理
@Component
public class WebSocketHandler {
    private WebSocketSession session;

    @PostConstruct
    public void connect() {
        this.session = createConnection();
    }

    @PreDestroy
    public void cleanup() {
        if (session != null) {
            session.close();  // 类似 useEffect 的清理函数
        }
    }
}
```

---

### 3.1.5 常见副作用场景

#### 场景一：数据获取

```tsx
function UserList() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        let cancelled = false;  // 防止组件卸载后设置状态

        async function fetchUsers() {
            try {
                setLoading(true);
                const response = await fetch('/api/users');
                const data = await response.json();

                if (!cancelled) {
                    setUsers(data);
                }
            } catch (err) {
                if (!cancelled) {
                    setError(err.message);
                }
            } finally {
                if (!cancelled) {
                    setLoading(false);
                }
            }
        }

        fetchUsers();

        return () => {
            cancelled = true;  // 标记取消
        };
    }, []);

    if (loading) return <div>加载中...</div>;
    if (error) return <div>错误: {error}</div>;
    return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

#### 场景二：事件订阅

```tsx
function WindowSize() {
    const [size, setSize] = useState({ width: 0, height: 0 });

    useEffect(() => {
        function handleResize() {
            setSize({
                width: window.innerWidth,
                height: window.innerHeight
            });
        }

        // 初始化
        handleResize();

        // 订阅
        window.addEventListener('resize', handleResize);

        // 清理：取消订阅
        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);

    return <div>{size.width} x {size.height}</div>;
}
```

#### 场景三：定时器

```tsx
function Timer() {
    const [seconds, setSeconds] = useState(0);

    useEffect(() => {
        const intervalId = setInterval(() => {
            setSeconds(s => s + 1);  // 使用函数式更新
        }, 1000);

        return () => {
            clearInterval(intervalId);  // 清理定时器
        };
    }, []);

    return <div>已运行: {seconds} 秒</div>;
}
```

#### 场景四：文档标题

```tsx
function PageTitle({ title }: { title: string }) {
    useEffect(() => {
        const previousTitle = document.title;
        document.title = title;

        return () => {
            document.title = previousTitle;  // 恢复原标题
        };
    }, [title]);

    return null;
}
```

---

### 3.1.6 useEffect 常见错误

#### 错误一：无限循环

```tsx
// ❌ 错误：每次渲染都创建新对象，触发无限循环
useEffect(() => {
    fetchData(options);
}, [{ page: 1, size: 10 }]);  // 对象每次都是新引用！

// ✅ 正确：使用基本类型或 useMemo
const [page, setPage] = useState(1);
const [size, setSize] = useState(10);

useEffect(() => {
    fetchData({ page, size });
}, [page, size]);
```

#### 错误二：缺少依赖

```tsx
// ❌ 错误：使用了 userId 但没有加入依赖
useEffect(() => {
    fetchUser(userId);  // userId 变化时不会重新获取
}, []);

// ✅ 正确：添加依赖
useEffect(() => {
    fetchUser(userId);
}, [userId]);
```

#### 错误三：在 useEffect 中直接使用 async

```tsx
// ❌ 错误：useEffect 回调不能是 async 函数
useEffect(async () => {
    const data = await fetchData();
}, []);

// ✅ 正确：在内部定义 async 函数
useEffect(() => {
    async function loadData() {
        const data = await fetchData();
    }
    loadData();
}, []);
```

---

### 3.1.7 useEffect vs useLayoutEffect

| Hook | 执行时机 | 使用场景 |
|------|---------|---------|
| `useEffect` | DOM 更新后异步执行 | 大多数场景（数据获取、订阅） |
| `useLayoutEffect` | DOM 更新后同步执行 | 需要测量/修改 DOM |

```tsx
function Tooltip({ position }: { position: Position }) {
    const ref = useRef<HTMLDivElement>(null);

    // 需要同步测量 DOM，避免闪烁
    useLayoutEffect(() => {
        const rect = ref.current?.getBoundingClientRect();
        // 根据测量结果调整位置
    }, [position]);

    return <div ref={ref}>Tooltip</div>;
}
```

---

### 课时 3.1 小结

| 概念 | useEffect | Spring 类比 |
|-----|-----------|------------|
| 首次执行 | `useEffect(..., [])` | @PostConstruct |
| 清理函数 | `return () => {...}` | @PreDestroy |
| 依赖变化执行 | `useEffect(..., [dep])` | @EventListener |
| 异步执行 | 默认行为 | @Async |

---

## 课时 3.2: useRef 引用

> Spring 类比：成员变量、@Autowired 注入的引用

### 3.2.1 useRef 的两个用途

1. **访问 DOM 元素**
2. **保存不触发重渲染的可变值**

---

### 3.2.2 用途一：访问 DOM 元素

```tsx
function TextInput() {
    const inputRef = useRef<HTMLInputElement>(null);

    const focusInput = () => {
        inputRef.current?.focus();  // 直接操作 DOM
    };

    return (
        <div>
            <input ref={inputRef} type="text" />
            <button onClick={focusInput}>聚焦输入框</button>
        </div>
    );
}
```

**后端类比**：

```java
// 类似直接持有对象引用
@Component
public class FormController {
    @Autowired
    private InputComponent inputComponent;  // 直接引用

    public void focusInput() {
        inputComponent.focus();  // 直接调用方法
    }
}
```

#### 常见 DOM 操作

```tsx
function MediaPlayer() {
    const videoRef = useRef<HTMLVideoElement>(null);

    const play = () => videoRef.current?.play();
    const pause = () => videoRef.current?.pause();
    const seekTo = (time: number) => {
        if (videoRef.current) {
            videoRef.current.currentTime = time;
        }
    };

    return (
        <div>
            <video ref={videoRef} src="/video.mp4" />
            <button onClick={play}>播放</button>
            <button onClick={pause}>暂停</button>
            <button onClick={() => seekTo(30)}>跳转到 30s</button>
        </div>
    );
}
```

---

### 3.2.3 用途二：保存可变值（不触发重渲染）

```tsx
function StopWatch() {
    const [time, setTime] = useState(0);
    const [isRunning, setIsRunning] = useState(false);

    // 用 ref 保存 interval ID，变化时不需要重渲染
    const intervalRef = useRef<number | null>(null);

    const start = () => {
        setIsRunning(true);
        intervalRef.current = setInterval(() => {
            setTime(t => t + 1);
        }, 1000);
    };

    const stop = () => {
        setIsRunning(false);
        if (intervalRef.current) {
            clearInterval(intervalRef.current);
        }
    };

    return (
        <div>
            <p>时间: {time}秒</p>
            <button onClick={isRunning ? stop : start}>
                {isRunning ? '停止' : '开始'}
            </button>
        </div>
    );
}
```

**为什么不用 useState？**

```tsx
// ❌ 使用 useState
const [intervalId, setIntervalId] = useState<number | null>(null);
// 每次设置 intervalId 都会触发重渲染，没有必要

// ✅ 使用 useRef
const intervalRef = useRef<number | null>(null);
// 修改 intervalRef.current 不会触发重渲染
```

---

### 3.2.4 useRef vs useState 对比

| 特性 | useState | useRef |
|-----|----------|--------|
| 更新时重渲染 | ✅ 是 | ❌ 否 |
| 值在渲染间保持 | ✅ 是 | ✅ 是 |
| 同步更新 | ❌ 异步批量 | ✅ 同步立即 |
| 适用场景 | UI 相关数据 | DOM 引用、定时器 ID、前一个值 |

---

### 3.2.5 保存前一个值

```tsx
function usePrevious<T>(value: T): T | undefined {
    const ref = useRef<T>();

    useEffect(() => {
        ref.current = value;
    }, [value]);

    return ref.current;  // 返回上一次的值
}

// 使用
function Counter() {
    const [count, setCount] = useState(0);
    const prevCount = usePrevious(count);

    return (
        <div>
            <p>当前: {count}, 之前: {prevCount}</p>
            <button onClick={() => setCount(c => c + 1)}>+1</button>
        </div>
    );
}
```

---

### 3.2.6 forwardRef：向父组件暴露子组件的 ref

```tsx
// 子组件：使用 forwardRef 接收 ref
const CustomInput = forwardRef<HTMLInputElement, { label: string }>(
    function CustomInput({ label }, ref) {
        return (
            <div>
                <label>{label}</label>
                <input ref={ref} />
            </div>
        );
    }
);

// 父组件：可以获取子组件内部的 DOM
function Form() {
    const inputRef = useRef<HTMLInputElement>(null);

    const handleSubmit = () => {
        console.log('输入值:', inputRef.current?.value);
    };

    return (
        <form>
            <CustomInput ref={inputRef} label="用户名" />
            <button type="button" onClick={handleSubmit}>提交</button>
        </form>
    );
}
```

---

### 3.2.7 useImperativeHandle：自定义暴露的方法

```tsx
interface InputHandle {
    focus: () => void;
    clear: () => void;
    getValue: () => string;
}

const CustomInput = forwardRef<InputHandle, { label: string }>(
    function CustomInput({ label }, ref) {
        const inputRef = useRef<HTMLInputElement>(null);

        // 自定义暴露给父组件的方法
        useImperativeHandle(ref, () => ({
            focus: () => inputRef.current?.focus(),
            clear: () => {
                if (inputRef.current) inputRef.current.value = '';
            },
            getValue: () => inputRef.current?.value ?? ''
        }));

        return (
            <div>
                <label>{label}</label>
                <input ref={inputRef} />
            </div>
        );
    }
);

// 父组件使用
function Form() {
    const inputRef = useRef<InputHandle>(null);

    return (
        <div>
            <CustomInput ref={inputRef} label="用户名" />
            <button onClick={() => inputRef.current?.focus()}>聚焦</button>
            <button onClick={() => inputRef.current?.clear()}>清空</button>
            <button onClick={() => alert(inputRef.current?.getValue())}>
                获取值
            </button>
        </div>
    );
}
```

**后端类比**：

```java
// 类似接口定义 —— 只暴露必要的方法
public interface InputHandle {
    void focus();
    void clear();
    String getValue();
}

// 实现类可能有更多内部方法，但只暴露接口定义的
```

---

### 课时 3.2 小结

| 用途 | 示例 | 说明 |
|-----|------|------|
| 访问 DOM | `ref={inputRef}` | 直接操作 DOM 元素 |
| 保存可变值 | `intervalRef.current = id` | 不触发重渲染 |
| 保存前一个值 | `usePrevious(value)` | 常见自定义 Hook |
| 暴露方法给父组件 | `forwardRef` + `useImperativeHandle` | 组件间通信 |

---

## 课时 3.3: useMemo 与 useCallback 优化

> Spring 类比：@Cacheable 缓存、享元模式

### 3.3.1 为什么需要优化

```tsx
function ExpensiveComponent({ items, filter }: Props) {
    // 每次渲染都会重新计算！
    const filteredItems = items
        .filter(item => item.name.includes(filter))
        .sort((a, b) => a.price - b.price);

    // 每次渲染都会创建新函数！
    const handleClick = (id: string) => {
        console.log('clicked', id);
    };

    return (
        <ul>
            {filteredItems.map(item => (
                <li key={item.id} onClick={() => handleClick(item.id)}>
                    {item.name}
                </li>
            ))}
        </ul>
    );
}
```

**问题**：
1. 即使 `items` 和 `filter` 没变，每次渲染都重新过滤排序
2. `handleClick` 每次都是新函数，导致子组件无法用 `React.memo` 优化

---

### 3.3.2 useMemo：缓存计算结果

```tsx
import { useMemo } from 'react';

function ExpensiveComponent({ items, filter }: Props) {
    // 只有 items 或 filter 变化时才重新计算
    const filteredItems = useMemo(() => {
        console.log('重新计算 filteredItems');
        return items
            .filter(item => item.name.includes(filter))
            .sort((a, b) => a.price - b.price);
    }, [items, filter]);  // 依赖数组

    return (
        <ul>
            {filteredItems.map(item => (
                <li key={item.id}>{item.name}</li>
            ))}
        </ul>
    );
}
```

**后端类比**：

```java
// Spring @Cacheable
@Cacheable(key = "#items.hashCode() + #filter")
public List<Item> getFilteredItems(List<Item> items, String filter) {
    return items.stream()
        .filter(item -> item.getName().contains(filter))
        .sorted(Comparator.comparing(Item::getPrice))
        .collect(Collectors.toList());
}
```

---

### 3.3.3 useCallback：缓存函数引用

```tsx
import { useCallback } from 'react';

function ParentComponent({ id }: { id: string }) {
    // 只有 id 变化时才创建新函数
    const handleClick = useCallback(() => {
        console.log('clicked', id);
    }, [id]);

    return <ChildComponent onClick={handleClick} />;
}

// 子组件使用 React.memo 优化
const ChildComponent = React.memo(({ onClick }: { onClick: () => void }) => {
    console.log('ChildComponent 渲染');
    return <button onClick={onClick}>点击</button>;
});
```

**useCallback 等价于**：

```tsx
// useCallback 是 useMemo 的语法糖
const handleClick = useCallback(() => {
    console.log('clicked', id);
}, [id]);

// 等价于
const handleClick = useMemo(() => {
    return () => {
        console.log('clicked', id);
    };
}, [id]);
```

---

### 3.3.4 React.memo：组件级别缓存

```tsx
interface UserCardProps {
    user: User;
    onEdit: (id: string) => void;
}

// 使用 React.memo 包裹，props 不变时跳过渲染
const UserCard = React.memo(function UserCard({ user, onEdit }: UserCardProps) {
    console.log('UserCard 渲染:', user.name);

    return (
        <div>
            <h3>{user.name}</h3>
            <button onClick={() => onEdit(user.id)}>编辑</button>
        </div>
    );
});

// 父组件
function UserList({ users }: { users: User[] }) {
    // ❌ 如果不用 useCallback，每次渲染 onEdit 都是新函数
    // UserCard 的 React.memo 就失效了
    const handleEdit = useCallback((id: string) => {
        console.log('编辑用户:', id);
    }, []);

    return (
        <div>
            {users.map(user => (
                <UserCard key={user.id} user={user} onEdit={handleEdit} />
            ))}
        </div>
    );
}
```

---

### 3.3.5 何时使用优化

#### 应该使用的场景

| 场景 | 使用 |
|-----|------|
| 昂贵的计算（过滤、排序大数组） | `useMemo` |
| 传给 memo 子组件的回调 | `useCallback` |
| 作为其他 Hook 的依赖 | `useMemo` / `useCallback` |
| 创建复杂对象作为 props | `useMemo` |

#### 不需要使用的场景

| 场景 | 原因 |
|-----|------|
| 简单计算（加减乘除） | 优化开销 > 计算开销 |
| 子组件没有 memo | useCallback 没有意义 |
| 基础类型 props | 不需要引用稳定 |

---

### 3.3.6 完整优化示例

```tsx
interface Product {
    id: string;
    name: string;
    price: number;
    category: string;
}

interface ProductListProps {
    products: Product[];
    category: string;
    onSelect: (product: Product) => void;
}

function ProductList({ products, category, onSelect }: ProductListProps) {
    // 1. 缓存过滤和排序结果
    const filteredProducts = useMemo(() => {
        console.log('过滤产品列表');
        return products
            .filter(p => p.category === category)
            .sort((a, b) => a.price - b.price);
    }, [products, category]);

    // 2. 缓存统计计算
    const stats = useMemo(() => ({
        count: filteredProducts.length,
        avgPrice: filteredProducts.reduce((sum, p) => sum + p.price, 0) /
                  filteredProducts.length || 0,
        minPrice: Math.min(...filteredProducts.map(p => p.price)),
        maxPrice: Math.max(...filteredProducts.map(p => p.price))
    }), [filteredProducts]);

    // 3. 缓存回调函数
    const handleSelect = useCallback((product: Product) => {
        onSelect(product);
    }, [onSelect]);

    return (
        <div>
            <div className="stats">
                <span>数量: {stats.count}</span>
                <span>均价: ¥{stats.avgPrice.toFixed(2)}</span>
            </div>
            <ul>
                {filteredProducts.map(product => (
                    <ProductItem
                        key={product.id}
                        product={product}
                        onSelect={handleSelect}
                    />
                ))}
            </ul>
        </div>
    );
}

// 4. 子组件使用 memo
const ProductItem = React.memo(function ProductItem({
    product,
    onSelect
}: {
    product: Product;
    onSelect: (product: Product) => void;
}) {
    console.log('ProductItem 渲染:', product.name);

    return (
        <li onClick={() => onSelect(product)}>
            {product.name} - ¥{product.price}
        </li>
    );
});
```

---

### 3.3.7 优化对比总结

| Hook/API | 缓存对象 | 依赖变化时 | 使用场景 |
|----------|---------|-----------|---------|
| `useMemo` | 计算结果 | 重新计算 | 昂贵计算 |
| `useCallback` | 函数引用 | 创建新函数 | memo 子组件的回调 |
| `React.memo` | 组件渲染 | 重新渲染 | 防止不必要的子组件渲染 |

**后端类比总结**：

| React | Spring | 说明 |
|-------|--------|------|
| `useMemo` | `@Cacheable` | 缓存计算结果 |
| `useCallback` | 单例 Bean | 保持引用稳定 |
| `React.memo` | HTTP 缓存 304 | 无变化时复用 |

---

### 课时 3.3 小结

```tsx
// 记忆口诀：
// useMemo    = 缓存值
// useCallback = 缓存函数
// React.memo  = 缓存组件

// 优化三件套组合使用：
const Parent = () => {
    const data = useMemo(() => compute(x), [x]);       // 值
    const handler = useCallback(() => handle(y), [y]); // 函数
    return <MemoChild data={data} onAction={handler} />;
};
const MemoChild = React.memo(Child);                   // 组件
```

---

## 课时 3.4: 自定义 Hook

> Spring 类比：抽取公共 Service、工具类封装

### 3.4.1 什么是自定义 Hook

自定义 Hook 是**复用状态逻辑**的方式，本质是一个以 `use` 开头的函数。

```tsx
// 自定义 Hook：封装通用逻辑
function useCounter(initialValue = 0) {
    const [count, setCount] = useState(initialValue);

    const increment = useCallback(() => setCount(c => c + 1), []);
    const decrement = useCallback(() => setCount(c => c - 1), []);
    const reset = useCallback(() => setCount(initialValue), [initialValue]);

    return { count, increment, decrement, reset };
}

// 使用
function Counter() {
    const { count, increment, decrement, reset } = useCounter(10);

    return (
        <div>
            <p>{count}</p>
            <button onClick={increment}>+</button>
            <button onClick={decrement}>-</button>
            <button onClick={reset}>重置</button>
        </div>
    );
}
```

**后端类比**：

```java
// 抽取公共 Service
@Service
public class CounterService {
    private int count;

    public int getCount() { return count; }
    public void increment() { count++; }
    public void decrement() { count--; }
    public void reset(int initial) { count = initial; }
}
```

---

### 3.4.2 常用自定义 Hook

#### useLocalStorage：本地存储状态

```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
    // 初始化：从 localStorage 读取或使用默认值
    const [storedValue, setStoredValue] = useState<T>(() => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch {
            return initialValue;
        }
    });

    // 包装 setter，同时更新 localStorage
    const setValue = useCallback((value: T | ((val: T) => T)) => {
        try {
            const valueToStore = value instanceof Function
                ? value(storedValue)
                : value;
            setStoredValue(valueToStore);
            localStorage.setItem(key, JSON.stringify(valueToStore));
        } catch (error) {
            console.error('localStorage error:', error);
        }
    }, [key, storedValue]);

    return [storedValue, setValue] as const;
}

// 使用
function Settings() {
    const [theme, setTheme] = useLocalStorage('theme', 'light');

    return (
        <select value={theme} onChange={e => setTheme(e.target.value)}>
            <option value="light">浅色</option>
            <option value="dark">深色</option>
        </select>
    );
}
```

#### useFetch：数据获取

```tsx
interface UseFetchResult<T> {
    data: T | null;
    loading: boolean;
    error: Error | null;
    refetch: () => void;
}

function useFetch<T>(url: string): UseFetchResult<T> {
    const [data, setData] = useState<T | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<Error | null>(null);

    const fetchData = useCallback(async () => {
        try {
            setLoading(true);
            setError(null);
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const json = await response.json();
            setData(json);
        } catch (e) {
            setError(e as Error);
        } finally {
            setLoading(false);
        }
    }, [url]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    return { data, loading, error, refetch: fetchData };
}

// 使用
function UserProfile({ userId }: { userId: string }) {
    const { data: user, loading, error, refetch } = useFetch<User>(
        `/api/users/${userId}`
    );

    if (loading) return <div>加载中...</div>;
    if (error) return <div>错误: {error.message}</div>;

    return (
        <div>
            <h1>{user?.name}</h1>
            <button onClick={refetch}>刷新</button>
        </div>
    );
}
```

#### useDebounce：防抖

```tsx
function useDebounce<T>(value: T, delay: number): T {
    const [debouncedValue, setDebouncedValue] = useState(value);

    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedValue(value);
        }, delay);

        return () => clearTimeout(timer);
    }, [value, delay]);

    return debouncedValue;
}

// 使用：搜索框防抖
function SearchInput() {
    const [search, setSearch] = useState('');
    const debouncedSearch = useDebounce(search, 500);

    useEffect(() => {
        if (debouncedSearch) {
            // 500ms 内没有新输入才执行搜索
            fetchSearchResults(debouncedSearch);
        }
    }, [debouncedSearch]);

    return (
        <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="搜索..."
        />
    );
}
```

#### useToggle：开关状态

```tsx
function Modal() {
    // 解构赋值 + 重命名
    const { value: isOpen, toggle, setFalse: close } = useToggle();
    //      ↑              ↑       ↑
    //      重命名为 isOpen |       重命名为 close
    //                    保持原名

    return (
        <div>
            {/* 点击按钮：isOpen 在 true/false 之间切换 */}
            <button onClick={toggle}>打开模态框</button>

            {/* 条件渲染：isOpen 为 true 时显示模态框 */}
            {isOpen && (
                <div className="modal">
                    <p>模态框内容</p>
                    {/* 点击关闭：isOpen 设为 false */}
                    <button onClick={close}>关闭</button>
                </div>
            )}
        </div>
    );
}
```

#### useClickOutside：点击外部检测
> 第一次挂载，通过useEffect构建listener，后续触发由点击和触摸事件触发。

```tsx
function useClickOutside(
    ref: RefObject<HTMLElement>,  // 要监测的元素引用
    handler: () => void           // 点击外部时执行的回调
) {
    useEffect(() => {
        // 事件监听器
        const listener = (event: MouseEvent | TouchEvent) => {
            // 情况1: ref 还没绑定到 DOM（组件未挂载）
            if (!ref.current) {
                return;
            }

            // 情况2: 点击的是元素内部（包括元素本身）
            if (ref.current.contains(event.target as Node)) {
                return;  // 不触发 handler
            }

            // 情况3: 点击的是元素外部
            handler();  // 触发回调
        };

        // 监听鼠标和触摸事件
        document.addEventListener('mousedown', listener);   // PC 端
        document.addEventListener('touchstart', listener);  // 移动端

        // 清理函数：组件卸载时移除监听
        return () => {
            document.removeEventListener('mousedown', listener);
            document.removeEventListener('touchstart', listener);
        };
    }, [ref, handler]);  // 依赖项
}

// 使用：点击下拉框外部关闭
function Dropdown() {
    const [isOpen, setIsOpen] = useState(false);
    const dropdownRef = useRef<HTMLDivElement>(null);

    useClickOutside(dropdownRef, () => setIsOpen(false));

    return (
        <div ref={dropdownRef}>
            <button onClick={() => setIsOpen(!isOpen)}>菜单</button>
            {isOpen && (
                <ul className="dropdown-menu">
                    <li>选项 1</li>
                    <li>选项 2</li>
                </ul>
            )}
        </div>
    );
}
```

---

### 3.4.3 自定义 Hook 设计原则

| 原则 | 说明 | 示例 |
|-----|------|------|
| 以 `use` 开头 | React 约定，必须遵守 | `useCounter`, `useFetch` |
| 单一职责 | 一个 Hook 只做一件事 | 不要把获取和提交混在一起 |
| 返回必要的值 | 不要返回过多内部状态 | `{ data, loading, error }` |
| 参数简洁 | 复杂配置用对象参数 | `useFetch(url, options)` |
| 考虑类型安全 | 使用 TypeScript 泛型 | `useFetch<User>(url)` |

---

### 3.4.4 Hook 规则

1. **只在顶层调用 Hook**

```tsx
// ❌ 错误：条件语句中调用
if (condition) {
    const [value, setValue] = useState(0);
}

// ❌ 错误：循环中调用
for (let i = 0; i < 5; i++) {
    useEffect(() => {});
}

// ✅ 正确：始终在顶层
const [value, setValue] = useState(0);
const [other, setOther] = useState('');
```

2. **只在 React 函数中调用 Hook**

```tsx
// ❌ 错误：普通函数中调用
function regularFunction() {
    const [value, setValue] = useState(0);
}

// ✅ 正确：React 组件中
function MyComponent() {
    const [value, setValue] = useState(0);
}

// ✅ 正确：自定义 Hook 中
function useMyHook() {
    const [value, setValue] = useState(0);
}
```

---

### 课时 3.4 小结

| 自定义 Hook | 用途 | 封装内容 |
|------------|------|---------|
| `useLocalStorage` | 本地存储 | useState + localStorage |
| `useFetch` | 数据获取 | useState + useEffect + fetch |
| `useDebounce` | 防抖 | useState + useEffect + setTimeout |
| `useToggle` | 开关 | useState + useCallback |
| `useClickOutside` | 点击外部 | useEffect + 事件监听 |

---

## 课时 3.5: 常用 Hook 模式

> Spring 类比：最佳实践、设计模式应用

### 3.5.1 useReducer：复杂状态管理

当状态逻辑复杂时，使用 `useReducer` 替代多个 `useState`。

```tsx
// 定义状态类型
interface FormState {
    values: { username: string; email: string; password: string };
    errors: { username?: string; email?: string; password?: string };
    isSubmitting: boolean;
    isValid: boolean;
}

// 定义 Action 类型
type FormAction =
    | { type: 'SET_FIELD'; field: string; value: string }
    | { type: 'SET_ERROR'; field: string; error: string }
    | { type: 'CLEAR_ERRORS' }
    | { type: 'SUBMIT_START' }
    | { type: 'SUBMIT_SUCCESS' }
    | { type: 'SUBMIT_ERROR'; errors: Record<string, string> };

// Reducer 函数
function formReducer(state: FormState, action: FormAction): FormState {
    switch (action.type) {
        case 'SET_FIELD':
            return {
                ...state,
                values: { ...state.values, [action.field]: action.value },
                errors: { ...state.errors, [action.field]: undefined }
            };
        case 'SET_ERROR':
            return {
                ...state,
                errors: { ...state.errors, [action.field]: action.error }
            };
        case 'CLEAR_ERRORS':
            return { ...state, errors: {} };
        case 'SUBMIT_START':
            return { ...state, isSubmitting: true };
        case 'SUBMIT_SUCCESS':
            return { ...state, isSubmitting: false };
        case 'SUBMIT_ERROR':
            return { ...state, isSubmitting: false, errors: action.errors };
        default:
            return state;
    }
}

// 使用
function RegistrationForm() {
    // useReducer 接收 reducer 函数和初始状态
    const [state, dispatch] = useReducer(formReducer, {
        values: { username: '', email: '', password: '' },
        errors: {},
        isSubmitting: false,
        isValid: false
    });

    // dispatch 发送 action，触发 reducer 执行
    const handleChange = (field: string, value: string) => {
        dispatch({ type: 'SET_FIELD', field, value });
        //        ↑ 这个对象就是 action，类型是 FormAction
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        dispatch({ type: 'SUBMIT_START' });

        try {
            await submitForm(state.values);
            dispatch({ type: 'SUBMIT_SUCCESS' });
        } catch (error) {
            dispatch({ type: 'SUBMIT_ERROR', errors: error.errors });
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <input
                value={state.values.username}
                onChange={handleChange('username')}
            />
            {state.errors.username && <span>{state.errors.username}</span>}
            {/* ... 其他字段 ... */}
            <button disabled={state.isSubmitting}>
                {state.isSubmitting ? '提交中...' : '提交'}
            </button>
        </form>
    );
}
```

**后端类比**：

```java
// 类似状态机模式
public class FormStateMachine {
    private FormState state;

    public void dispatch(FormAction action) {
        this.state = reduce(this.state, action);
        notifyListeners();
    }

    private FormState reduce(FormState state, FormAction action) {
        return switch (action.type()) {
            case SET_FIELD -> state.withField(action.field(), action.value());
            case SUBMIT_START -> state.withSubmitting(true);
            // ...
        };
    }
}
```

---

### 3.5.2 Context + useReducer：全局状态

```tsx
// ============================================
// 1. 定义类型
// ============================================

// 用户类型
interface User {
    id: string;
    name: string;
    email: string;
    avatar?: string;
}

// 通知类型
interface Notification {
    id: string;
    type: 'success' | 'error' | 'warning' | 'info';
    message: string;
    createdAt: Date;
}

// 全局状态类型
interface AppState {
    user: User | null;
    theme: 'light' | 'dark';
    notifications: Notification[];
}

// 动作类型
type AppAction =
    | { type: 'SET_USER'; user: User | null }
    | { type: 'SET_THEME'; theme: 'light' | 'dark' }
    | { type: 'ADD_NOTIFICATION'; notification: Notification }
    | { type: 'REMOVE_NOTIFICATION'; id: string };

// ============================================
// 2. 创建 Context
// ============================================

const AppStateContext = createContext<AppState | null>(null);
const AppDispatchContext = createContext<Dispatch<AppAction> | null>(null);

// ============================================
// 3. Reducer
// ============================================

function appReducer(state: AppState, action: AppAction): AppState {
    switch (action.type) {
        case 'SET_USER':
            return { ...state, user: action.user };
        case 'SET_THEME':
            return { ...state, theme: action.theme };
        case 'ADD_NOTIFICATION':
            return {
                ...state,
                notifications: [...state.notifications, action.notification]
            };
        case 'REMOVE_NOTIFICATION':
            return {
                ...state,
                notifications: state.notifications.filter(n => n.id !== action.id)
            };
        default:
            return state;
    }
}

// ============================================
// 4. Provider 组件
// ============================================

// 初始状态
const initialState: AppState = {
    user: null,
    theme: 'light',
    notifications: []
};

function AppProvider({ children }: { children: React.ReactNode }) {
    const [state, dispatch] = useReducer(appReducer, initialState);

    return (
        <AppStateContext.Provider value={state}>
            <AppDispatchContext.Provider value={dispatch}>
                {children}
            </AppDispatchContext.Provider>
        </AppStateContext.Provider>
    );
}

// ============================================
// 5. 自定义 Hook（简化使用）
// ============================================

function useAppState() {
    const context = useContext(AppStateContext);
    if (!context) {
        throw new Error('useAppState must be used within AppProvider');
    }
    return context;
}

function useAppDispatch() {
    const context = useContext(AppDispatchContext);
    if (!context) {
        throw new Error('useAppDispatch must be used within AppProvider');
    }
    return context;
}

// 便捷 Hook：添加通知
function useNotification() {
    const dispatch = useAppDispatch();

    const addNotification = useCallback((
        type: Notification['type'],
        message: string
    ) => {
        const notification: Notification = {
            id: Date.now().toString(),
            type,
            message,
            createdAt: new Date()
        };
        dispatch({ type: 'ADD_NOTIFICATION', notification });

        // 3秒后自动移除
        setTimeout(() => {
            dispatch({ type: 'REMOVE_NOTIFICATION', id: notification.id });
        }, 3000);
    }, [dispatch]);

    return { addNotification };
}

// ============================================
// 6. 使用示例
// ============================================

// 根组件：包裹 Provider
function App() {
    return (
        <AppProvider>
            <div className="app">
                <Header />
                <MainContent />
                <NotificationList />
            </div>
        </AppProvider>
    );
}

// 头部组件
function Header() {
    const { user, theme } = useAppState();
    const dispatch = useAppDispatch();

    const toggleTheme = () => {
        dispatch({
            type: 'SET_THEME',
            theme: theme === 'light' ? 'dark' : 'light'
        });
    };

    const logout = () => {
        dispatch({ type: 'SET_USER', user: null });
    };

    return (
        <header className={`header ${theme}`}>
            {user ? (
                <>
                    <span>欢迎, {user.name}</span>
                    <button onClick={logout}>退出</button>
                </>
            ) : (
                <span>请登录</span>
            )}
            <button onClick={toggleTheme}>
                切换到{theme === 'light' ? '深色' : '浅色'}模式
            </button>
        </header>
    );
}

// 主内容组件
function MainContent() {
    const { user } = useAppState();
    const dispatch = useAppDispatch();
    const { addNotification } = useNotification();

    const login = () => {
        // 模拟登录
        const mockUser: User = {
            id: '1',
            name: 'Tom',
            email: 'tom@example.com'
        };
        dispatch({ type: 'SET_USER', user: mockUser });
        addNotification('success', '登录成功！');
    };

    return (
        <main>
            {user ? (
                <div>
                    <h1>用户信息</h1>
                    <p>ID: {user.id}</p>
                    <p>姓名: {user.name}</p>
                    <p>邮箱: {user.email}</p>
                </div>
            ) : (
                <div>
                    <p>您还未登录</p>
                    <button onClick={login}>模拟登录</button>
                </div>
            )}
        </main>
    );
}

// 通知列表组件
function NotificationList() {
    const { notifications } = useAppState();
    const dispatch = useAppDispatch();

    if (notifications.length === 0) return null;

    return (
        <div className="notification-list">
            {notifications.map(notification => (
                <div
                    key={notification.id}
                    className={`notification notification-${notification.type}`}
                >
                    <span>{notification.message}</span>
                    <button
                        onClick={() => dispatch({
                            type: 'REMOVE_NOTIFICATION',
                            id: notification.id
                        })}
                    >
                        ✕
                    </button>
                </div>
            ))}
        </div>
    );
}
```

---

### 3.5.3 异步数据获取模式

```tsx
// 通用的异步数据 Hook
interface AsyncState<T> {
    status: 'idle' | 'loading' | 'success' | 'error';
    data: T | null;
    error: Error | null;
}

function useAsync<T>(asyncFn: () => Promise<T>, deps: any[] = []) {
    const [state, setState] = useState<AsyncState<T>>({
        status: 'idle',
        data: null,
        error: null
    });

    const execute = useCallback(async () => {
        setState({ status: 'loading', data: null, error: null });
        try {
            const data = await asyncFn();
            setState({ status: 'success', data, error: null });
        } catch (error) {
            setState({ status: 'error', data: null, error: error as Error });
        }
    }, deps);

    useEffect(() => {
        execute();
    }, [execute]);

    return { ...state, refetch: execute };
}

// 使用
function UserProfile({ userId }: { userId: string }) {
    const { status, data: user, error, refetch } = useAsync(
        () => fetchUser(userId),
        [userId]
    );

    switch (status) {
        case 'idle':
        case 'loading':
            return <Skeleton />;
        case 'error':
            return <ErrorMessage error={error} onRetry={refetch} />;
        case 'success':
            return <UserCard user={user!} />;
    }
}
```

---

### 3.5.4 表单处理模式

```tsx
// ============================================
// 通用表单 Hook - 类型定义
// ============================================
interface UseFormOptions<T> {
    initialValues: T;                                          // 表单初始值
    validate?: (values: T) => Partial<Record<keyof T, string>>; // 验证函数（可选）
    onSubmit: (values: T) => Promise<void>;                    // 提交处理函数
}

// ============================================
// useForm Hook 实现
// ============================================
function useForm<T extends Record<string, any>>({
    initialValues,
    validate,
    onSubmit
}: UseFormOptions<T>) {
    console.log('[useForm] Hook 初始化，初始值:', initialValues);

    // ---------- 状态定义 ----------
    const [values, setValues] = useState<T>(initialValues);           // 表单值
    const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({}); // 错误信息
    const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({}); // 已触碰的字段
    const [isSubmitting, setIsSubmitting] = useState(false);          // 提交中状态

    // ---------- 字段变更处理 ----------
    // 返回一个函数，用于处理特定字段的 onChange 事件
    const handleChange = (field: keyof T) => (
        e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
    ) => {
        // 处理 checkbox 和普通 input 的区别
        const value = e.target.type === 'checkbox'
            ? (e.target as HTMLInputElement).checked
            : e.target.value;

        console.log(`[useForm] 字段变更: ${String(field)} =`, value);
        setValues(prev => ({ ...prev, [field]: value }));
    };

    // ---------- 字段失焦处理 ----------
    // 返回一个函数，用于处理特定字段的 onBlur 事件
    const handleBlur = (field: keyof T) => () => {
        console.log(`[useForm] 字段失焦: ${String(field)}`);

        // 标记该字段已被触碰
        setTouched(prev => ({ ...prev, [field]: true }));

        // 执行验证
        if (validate) {
            const validationErrors = validate(values);
            console.log('[useForm] 验证结果:', validationErrors);
            setErrors(validationErrors);
        }
    };

    // ---------- 表单提交处理 ----------
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();  // 阻止默认的表单提交行为
        console.log('[useForm] 表单提交开始，当前值:', values);

        // 提交前验证
        if (validate) {
            const validationErrors = validate(values);
            setErrors(validationErrors);

            if (Object.keys(validationErrors).length > 0) {
                console.log('[useForm] 验证失败，错误:', validationErrors);
                return;  // 有错误，终止提交
            }
        }

        // 开始提交
        console.log('[useForm] 验证通过，开始提交...');
        setIsSubmitting(true);

        try {
            await onSubmit(values);
            console.log('[useForm] 提交成功');
        } catch (error) {
            console.error('[useForm] 提交失败:', error);
        } finally {
            setIsSubmitting(false);
            console.log('[useForm] 提交流程结束');
        }
    };

    // ---------- 便捷方法：获取字段 props ----------
    // 返回可以直接展开到 input 上的属性
    const getFieldProps = (field: keyof T) => ({
        value: values[field],
        onChange: handleChange(field),
        onBlur: handleBlur(field)
    });

    // ---------- 便捷方法：获取字段错误 ----------
    // 只有字段被触碰后才显示错误
    const getFieldError = (field: keyof T) =>
        touched[field] ? errors[field] : undefined;

    // ---------- 返回表单控制对象 ----------
    return {
        values,          // 当前表单值
        errors,          // 当前错误
        touched,         // 已触碰字段
        isSubmitting,    // 是否提交中
        handleSubmit,    // 提交处理器
        getFieldProps,   // 获取字段 props
        getFieldError,   // 获取字段错误
        setFieldValue: (field: keyof T, value: any) => {
            console.log(`[useForm] 手动设置字段: ${String(field)} =`, value);
            setValues(prev => ({ ...prev, [field]: value }));
        },
        resetForm: () => {
            console.log('[useForm] 重置表单');
            setValues(initialValues);
            setErrors({});
            setTouched({});
        }
    };
}

// ============================================
// 使用示例：登录表单
// ============================================
function LoginForm() {
    console.log('[LoginForm] 组件渲染');

    const form = useForm({
        // 初始值
        initialValues: { email: '', password: '' },

        // 验证函数
        validate: (values) => {
            console.log('[LoginForm] 执行验证，values:', values);
            const errors: Record<string, string> = {};
            if (!values.email) errors.email = '邮箱必填';
            if (!values.password) errors.password = '密码必填';
            return errors;
        },

        // 提交处理
        onSubmit: async (values) => {
            console.log('[LoginForm] 调用登录 API，参数:', values);
            await login(values);
            console.log('[LoginForm] 登录成功');
        }
    });

    return (
        <form onSubmit={form.handleSubmit}>
            <div>
                {/* getFieldProps('email') 返回 { value, onChange, onBlur } */}
                <input {...form.getFieldProps('email')} placeholder="邮箱" />
                {form.getFieldError('email') && (
                    <span className="error">{form.getFieldError('email')}</span>
                )}
            </div>
            <div>
                <input
                    {...form.getFieldProps('password')}
                    type="password"
                    placeholder="密码"
                />
                {form.getFieldError('password') && (
                    <span className="error">{form.getFieldError('password')}</span>
                )}
            </div>
            <button disabled={form.isSubmitting}>
                {form.isSubmitting ? '登录中...' : '登录'}
            </button>
        </form>
    );
}
```

**执行流程日志示例**：

```
[LoginForm] 组件渲染
[useForm] Hook 初始化，初始值: { email: '', password: '' }

// 用户输入邮箱
[useForm] 字段变更: email = "tom@example.com"
[LoginForm] 组件渲染

// 用户离开邮箱输入框
[useForm] 字段失焦: email
[useForm] 验证结果: { password: '密码必填' }

// 用户输入密码
[useForm] 字段变更: password = "123456"
[LoginForm] 组件渲染

// 用户点击提交
[useForm] 表单提交开始，当前值: { email: 'tom@example.com', password: '123456' }
[LoginForm] 执行验证，values: { email: 'tom@example.com', password: '123456' }
[useForm] 验证通过，开始提交...
[LoginForm] 调用登录 API，参数: { email: 'tom@example.com', password: '123456' }
[LoginForm] 登录成功
[useForm] 提交成功
[useForm] 提交流程结束
```

---

### 3.5.5 模态框/对话框模式

```tsx
// ========================================
// useModal Hook：模态框状态管理
// ========================================
// 封装模态框的开/关状态和关联数据
// 支持泛型，可传入任意类型的数据

interface UseModalResult<T> {
    isOpen: boolean;       // 模态框是否打开
    data: T | null;        // 模态框关联的数据（如要删除的用户）
    open: (data?: T) => void;  // 打开模态框，可传入数据
    close: () => void;     // 关闭模态框
}

function useModal<T = undefined>(): UseModalResult<T> {
    console.log('[useModal] Hook 初始化/重新执行');

    // ----------------------------------------
    // 状态定义
    // ----------------------------------------
    const [isOpen, setIsOpen] = useState(false);
    const [data, setData] = useState<T | null>(null);

    console.log('[useModal] 当前状态 - isOpen:', isOpen, ', data:', data);

    // ----------------------------------------
    // open：打开模态框
    // ----------------------------------------
    // 使用 useCallback 缓存函数引用
    // 依赖数组为空，因为不依赖任何外部变量
    const open = useCallback((data?: T) => {
        console.log('[useModal.open] 打开模态框，传入数据:', data);

        // 先设置数据，再打开模态框
        // ?? null 处理 undefined 的情况
        setData(data ?? null);
        setIsOpen(true);

        console.log('[useModal.open] 状态更新已触发');
    }, []);

    // ----------------------------------------
    // close：关闭模态框
    // ----------------------------------------
    const close = useCallback(() => {
        console.log('[useModal.close] 关闭模态框');

        // 关闭模态框并清空数据
        setIsOpen(false);
        setData(null);

        console.log('[useModal.close] 状态更新已触发');
    }, []);

    console.log('[useModal] 返回 Hook 结果');
    return { isOpen, data, open, close };
}

// ========================================
// 使用示例：用户管理页面
// ========================================
// 同时管理多个模态框（删除确认、编辑表单）

function UserManagement() {
    console.log('[UserManagement] 组件渲染');

    // ----------------------------------------
    // 初始化两个独立的模态框
    // ----------------------------------------
    // 每个 useModal 调用创建独立的状态
    // 泛型 <User> 指定模态框关联的数据类型
    const deleteModal = useModal<User>();
    const editModal = useModal<User>();

    console.log('[UserManagement] deleteModal 状态:', {
        isOpen: deleteModal.isOpen,
        data: deleteModal.data
    });
    console.log('[UserManagement] editModal 状态:', {
        isOpen: editModal.isOpen,
        data: editModal.data
    });

    // ----------------------------------------
    // handleDelete：处理删除确认
    // ----------------------------------------
    const handleDelete = async () => {
        console.log('[handleDelete] 执行删除操作');

        if (deleteModal.data) {
            console.log('[handleDelete] 删除用户:', deleteModal.data.id);

            // 调用 API 删除用户
            await deleteUser(deleteModal.data.id);

            console.log('[handleDelete] 删除成功，关闭模态框');
            deleteModal.close();
        } else {
            console.log('[handleDelete] 无数据，跳过删除');
        }
    };

    // ----------------------------------------
    // 渲染 UI
    // ----------------------------------------
    return (
        <div>
            {/* 用户列表 */}
            <UserList
                onEdit={(user) => {
                    console.log('[UserList.onEdit] 点击编辑按钮:', user);
                    editModal.open(user);  // 打开编辑模态框，传入用户数据
                }}
                onDelete={(user) => {
                    console.log('[UserList.onDelete] 点击删除按钮:', user);
                    deleteModal.open(user);  // 打开删除确认框，传入用户数据
                }}
            />

            {/*
              删除确认框
              条件渲染：仅当 isOpen 为 true 时渲染
            */}
            {deleteModal.isOpen && (
                <ConfirmModal
                    title="确认删除"
                    message={`确定删除用户 ${deleteModal.data?.name}？`}
                    onConfirm={handleDelete}    // 确认 → 执行删除
                    onCancel={deleteModal.close} // 取消 → 关闭模态框
                />
            )}

            {/*
              编辑表单模态框
              user={editModal.data!} 中的 ! 是 TypeScript 非空断言
              因为在 isOpen 为 true 时，data 一定不为 null
            */}
            {editModal.isOpen && (
                <EditUserModal
                    user={editModal.data!}
                    onClose={editModal.close}
                />
            )}
        </div>
    );
}
```

**执行流程日志示例**（点击删除按钮 → 确认删除）：

```
// 1. 页面初始加载
[useModal] Hook 初始化/重新执行
[useModal] 当前状态 - isOpen: false , data: null
[useModal] 返回 Hook 结果
[useModal] Hook 初始化/重新执行
[useModal] 当前状态 - isOpen: false , data: null
[useModal] 返回 Hook 结果
[UserManagement] 组件渲染
[UserManagement] deleteModal 状态: { isOpen: false, data: null }
[UserManagement] editModal 状态: { isOpen: false, data: null }

// 2. 用户点击删除按钮
[UserList.onDelete] 点击删除按钮: { id: '1', name: '张三' }
[useModal.open] 打开模态框，传入数据: { id: '1', name: '张三' }
[useModal.open] 状态更新已触发

// 3. 组件因 state 变化重新渲染
[useModal] Hook 初始化/重新执行
[useModal] 当前状态 - isOpen: true , data: { id: '1', name: '张三' }
[useModal] 返回 Hook 结果
[UserManagement] 组件渲染
[UserManagement] deleteModal 状态: { isOpen: true, data: { id: '1', name: '张三' } }

// 4. 用户点击确认删除
[handleDelete] 执行删除操作
[handleDelete] 删除用户: 1
[handleDelete] 删除成功，关闭模态框
[useModal.close] 关闭模态框
[useModal.close] 状态更新已触发

// 5. 模态框关闭，组件重新渲染
[useModal] Hook 初始化/重新执行
[useModal] 当前状态 - isOpen: false , data: null
[UserManagement] deleteModal 状态: { isOpen: false, data: null }
```

**后端类比**：

```java
// Spring 中的模态框状态管理类似于 Session 范围的临时状态

@Component
@Scope("session")
public class ModalStateManager<T> {
    private boolean isOpen = false;
    private T data = null;

    public void open(T data) {
        log.debug("[ModalStateManager.open] 打开模态框，数据: {}", data);
        this.data = data;
        this.isOpen = true;
    }

    public void close() {
        log.debug("[ModalStateManager.close] 关闭模态框");
        this.isOpen = false;
        this.data = null;
    }

    // getters...
}
```

---

### 3.5.6 Hook 模式总结

| 模式 | 适用场景 | 核心 Hook |
|-----|---------|----------|
| useReducer | 复杂状态逻辑 | useReducer |
| Context + Reducer | 全局状态 | createContext + useReducer |
| 异步数据 | API 请求 | useState + useEffect |
| 表单处理 | 表单验证提交 | useState + useCallback |
| 模态框 | 对话框管理 | useState + useCallback |

---

## 模块三总结

### 完成的课时

| 课时 | 主题 | 核心内容 |
|-----|------|---------|
| 3.1 | useEffect 副作用 | 执行时机、依赖数组、清理函数 |
| 3.2 | useRef 引用 | DOM 访问、可变值、forwardRef |
| 3.3 | useMemo/useCallback | 性能优化、React.memo |
| 3.4 | 自定义 Hook | 逻辑复用、常用 Hook 封装 |
| 3.5 | 常用 Hook 模式 | useReducer、表单、模态框 |

### 后端视角核心映射

| React Hook | Java/Spring 类比 |
|------------|-----------------|
| useEffect | @PostConstruct + @PreDestroy + @Async |
| useRef | 成员变量引用 |
| useMemo | @Cacheable |
| useCallback | 单例 Bean |
| useReducer | 状态机模式 |
| 自定义 Hook | 抽取公共 Service |

### 下一步

模块四将开始讲解 React 进阶主题：
- 4.1 Context 深入
- 4.2 错误边界
- 4.3 Suspense 与懒加载
- 4.4 性能优化策略
- 4.5 测试基础

---
