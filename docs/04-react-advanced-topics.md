# 模块四：React 进阶主题

> 面向 Java/Spring 后端工程师的 React 进阶指南

## 目录

- [课时 4.1: Context 深入](#课时-41-context-深入)
- [课时 4.2: 错误边界](#课时-42-错误边界)
- [课时 4.3: Suspense 与懒加载](#课时-43-suspense-与懒加载)
- [课时 4.4: 性能优化策略](#课时-44-性能优化策略)
- [课时 4.5: 测试基础](#课时-45-测试基础)

---

## 课时 4.1: Context 深入

> Spring 类比：@Autowired 依赖注入 + ApplicationContext

### 4.1.1 Context 是什么？

Context 提供了一种在组件树中**跨层级传递数据**的方式，避免了 "props 逐层传递" 的问题。

```
Props 逐层传递（Prop Drilling）问题：

App (theme='dark')
 └─ Layout (theme='dark')      ← 只是传递，不使用
     └─ Sidebar (theme='dark') ← 只是传递，不使用
         └─ Menu (theme='dark') ← 只是传递，不使用
             └─ MenuItem (使用 theme)  ← 真正使用的地方

使用 Context 后：

App (提供 theme)
 └─ Layout
     └─ Sidebar
         └─ Menu
             └─ MenuItem (直接获取 theme)  ← 跳过中间层
```

**后端类比**：

```java
// Spring 依赖注入 —— 不需要手动逐层传递
@Service
public class OrderService {
    @Autowired  // 直接注入，不管 Bean 在哪里定义
    private UserService userService;
}

// React Context 类似于 ApplicationContext
// 在任意深度的组件中都能获取到"注入"的值
```

---

### 4.1.2 创建和使用 Context

```tsx
// ============================================
// 1. 创建 Context
// ============================================

// 定义 Context 的类型
interface ThemeContextType {
    theme: 'light' | 'dark';
    toggleTheme: () => void;
}

// 创建 Context，提供默认值（可选）
// 默认值在没有 Provider 包裹时使用
const ThemeContext = createContext<ThemeContextType | null>(null);

console.log('[ThemeContext] Context 创建完成');

// ============================================
// 2. 创建 Provider 组件
// ============================================

function ThemeProvider({ children }: { children: React.ReactNode }) {
    console.log('[ThemeProvider] 组件渲染');

    const [theme, setTheme] = useState<'light' | 'dark'>('light');

    // 切换主题的函数
    const toggleTheme = useCallback(() => {
        console.log('[ThemeProvider] 切换主题');
        setTheme(prev => prev === 'light' ? 'dark' : 'light');
    }, []);

    // 使用 useMemo 缓存 value 对象，避免不必要的重渲染
    const value = useMemo(() => ({
        theme,
        toggleTheme
    }), [theme, toggleTheme]);

    console.log('[ThemeProvider] 当前主题:', theme);

    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
}

// ============================================
// 3. 创建自定义 Hook（推荐）
// ============================================

function useTheme() {
    const context = useContext(ThemeContext);

    // 安全检查：确保在 Provider 内使用
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }

    return context;
}

// ============================================
// 4. 使用 Context
// ============================================

// 根组件：包裹 Provider
function App() {
    return (
        <ThemeProvider>
            <div className="app">
                <Header />
                <MainContent />
            </div>
        </ThemeProvider>
    );
}

// 深层组件：直接使用 Context
function Header() {
    console.log('[Header] 组件渲染');

    // 使用自定义 Hook 获取 Context
    const { theme, toggleTheme } = useTheme();

    return (
        <header className={`header-${theme}`}>
            <h1>我的应用</h1>
            <button onClick={toggleTheme}>
                当前: {theme} | 点击切换
            </button>
        </header>
    );
}

function MainContent() {
    console.log('[MainContent] 组件渲染');

    const { theme } = useTheme();

    return (
        <main className={`main-${theme}`}>
            <p>当前主题：{theme}</p>
        </main>
    );
}
```

**执行流程日志**：

```
// 1. 应用初始化
[ThemeContext] Context 创建完成
[ThemeProvider] 组件渲染
[ThemeProvider] 当前主题: light
[Header] 组件渲染
[MainContent] 组件渲染

// 2. 用户点击切换主题
[ThemeProvider] 切换主题
[ThemeProvider] 组件渲染
[ThemeProvider] 当前主题: dark
[Header] 组件渲染      ← Context 变化，消费者重渲染
[MainContent] 组件渲染 ← Context 变化，消费者重渲染
```

---

### 4.1.3 Context 性能优化

#### 问题：Context 变化导致所有消费者重渲染

```tsx
// ❌ 问题示例：将所有状态放在一个 Context 中
interface AppContextType {
    user: User | null;
    theme: 'light' | 'dark';
    notifications: Notification[];
    // ... 更多状态
}

const AppContext = createContext<AppContextType | null>(null);

// 问题：任何一个值变化，所有消费者都会重渲染
// 比如添加通知，只使用 theme 的组件也会重渲染
```

#### 解决方案 1：拆分 Context

```tsx
// ✅ 将不同关注点拆分到不同 Context
const UserContext = createContext<UserContextType | null>(null);
const ThemeContext = createContext<ThemeContextType | null>(null);
const NotificationContext = createContext<NotificationContextType | null>(null);

// 组件只订阅需要的 Context
function ThemeToggle() {
    // 只订阅 ThemeContext，User 变化不会触发重渲染
    const { theme, toggleTheme } = useTheme();
    return <button onClick={toggleTheme}>{theme}</button>;
}
```

#### 解决方案 2：分离状态和 Dispatch

```tsx
// ✅ 将 state 和 dispatch 分开
const StateContext = createContext<AppState | null>(null);
const DispatchContext = createContext<Dispatch<AppAction> | null>(null);

function AppProvider({ children }: { children: React.ReactNode }) {
    const [state, dispatch] = useReducer(appReducer, initialState);

    return (
        // state 和 dispatch 分开提供
        <StateContext.Provider value={state}>
            <DispatchContext.Provider value={dispatch}>
                {children}
            </DispatchContext.Provider>
        </StateContext.Provider>
    );
}

// 只需要 dispatch 的组件不会因为 state 变化而重渲染
function AddButton() {
    const dispatch = useContext(DispatchContext);
    // 只使用 dispatch，state 变化不会触发重渲染

    return (
        <button onClick={() => dispatch({ type: 'ADD' })}>
            添加
        </button>
    );
}
```

#### 解决方案 3：使用 useMemo 包装 value

```tsx
// ✅ 缓存 Context value
function ThemeProvider({ children }: { children: React.ReactNode }) {
    const [theme, setTheme] = useState<'light' | 'dark'>('light');

    const toggleTheme = useCallback(() => {
        setTheme(prev => prev === 'light' ? 'dark' : 'light');
    }, []);

    // 使用 useMemo 缓存 value 对象
    // 只有 theme 或 toggleTheme 变化时才创建新对象
    const value = useMemo(() => ({
        theme,
        toggleTheme
    }), [theme, toggleTheme]);

    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
}
```

---

### 4.1.4 Context 使用场景

| 场景 | 说明 | Spring 类比 |
|-----|------|------------|
| 主题 (Theme) | 全局 UI 风格 | 全局配置 |
| 用户信息 (Auth) | 登录状态、权限 | SecurityContext |
| 国际化 (i18n) | 多语言支持 | LocaleContextHolder |
| 路由信息 | 当前路径、导航方法 | RequestContext |
| 表单状态 | 跨组件的表单数据 | 请求域数据 |

---

### 4.1.5 Context vs Props vs 状态管理库

| 方案 | 适用场景 | 复杂度 |
|-----|---------|-------|
| **Props** | 父子组件间传递（1-2 层） | 低 |
| **Context** | 跨多层组件共享（主题、用户、配置） | 中 |
| **Zustand/Redux** | 复杂全局状态、需要中间件、需要持久化 | 高 |

**选择原则**：

```
能用 Props 解决 → 用 Props
Props 传递超过 2-3 层 → 考虑 Context
状态逻辑复杂、需要中间件 → 考虑状态管理库
```

---

### 课时 4.1 小结

```tsx
// Context 三步走：
// 1. 创建 Context
const MyContext = createContext<Type | null>(null);

// 2. 提供 Provider
<MyContext.Provider value={value}>
    {children}
</MyContext.Provider>

// 3. 消费 Context（推荐用自定义 Hook）
function useMyContext() {
    const ctx = useContext(MyContext);
    if (!ctx) throw new Error('...');
    return ctx;
}
```

---

## 课时 4.2: 错误边界

> Spring 类比：@ControllerAdvice 全局异常处理

### 4.2.1 什么是错误边界？

错误边界是 React 组件，可以**捕获子组件树中的 JavaScript 错误**，记录错误并展示备用 UI，而不是让整个应用崩溃。

```
没有错误边界时：
一个组件报错 → 整个应用白屏

有错误边界时：
一个组件报错 → 只有该区域显示错误 UI，其他部分正常
```

**后端类比**：

```java
// Spring 全局异常处理
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e) {
        // 捕获异常，返回友好的错误信息
        return ResponseEntity.status(500).body(new ErrorResponse(e.getMessage()));
    }
}

// React 错误边界类似于：
// 捕获渲染过程中的异常，显示备用 UI
```

---

### 4.2.2 创建错误边界（类组件）

错误边界**必须使用类组件**，因为需要用到 `componentDidCatch` 和 `getDerivedStateFromError` 生命周期方法。

```tsx
// ============================================
// 错误边界组件
// ============================================

interface ErrorBoundaryProps {
    children: React.ReactNode;
    fallback?: React.ReactNode;  // 自定义错误 UI
    onError?: (error: Error, errorInfo: React.ErrorInfo) => void;  // 错误回调
}

interface ErrorBoundaryState {
    hasError: boolean;
    error: Error | null;
}

class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
    constructor(props: ErrorBoundaryProps) {
        super(props);
        this.state = { hasError: false, error: null };
        console.log('[ErrorBoundary] 初始化');
    }

    // ----------------------------------------
    // 静态方法：从错误中派生状态
    // ----------------------------------------
    // 当子组件抛出错误时调用
    // 返回值会更新 state
    static getDerivedStateFromError(error: Error): ErrorBoundaryState {
        console.log('[ErrorBoundary] getDerivedStateFromError:', error.message);
        // 更新状态，下次渲染时显示错误 UI
        return { hasError: true, error };
    }

    // ----------------------------------------
    // 生命周期方法：捕获错误信息
    // ----------------------------------------
    // 可以用于错误上报
    componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
        console.log('[ErrorBoundary] componentDidCatch');
        console.log('  Error:', error.message);
        console.log('  Component Stack:', errorInfo.componentStack);

        // 调用错误回调（如上报到监控系统）
        this.props.onError?.(error, errorInfo);

        // 实际项目中可以上报到 Sentry 等监控平台
        // Sentry.captureException(error, { extra: errorInfo });
    }

    // ----------------------------------------
    // 重置错误状态
    // ----------------------------------------
    handleRetry = () => {
        console.log('[ErrorBoundary] 重试');
        this.setState({ hasError: false, error: null });
    };

    render() {
        console.log('[ErrorBoundary] render, hasError:', this.state.hasError);

        if (this.state.hasError) {
            // 显示自定义 fallback 或默认错误 UI
            if (this.props.fallback) {
                return this.props.fallback;
            }

            return (
                <div className="error-boundary">
                    <h2>出错了</h2>
                    <p>{this.state.error?.message}</p>
                    <button onClick={this.handleRetry}>重试</button>
                </div>
            );
        }

        // 正常渲染子组件
        return this.props.children;
    }
}
```

---

### 4.2.3 使用错误边界

```tsx
// ============================================
// 使用示例
// ============================================

// 可能出错的组件
function UserProfile({ userId }: { userId: string }) {
    const [user, setUser] = useState<User | null>(null);

    useEffect(() => {
        fetchUser(userId).then(setUser);
    }, [userId]);

    if (!user) return <div>加载中...</div>;

    // 假设这里可能因为数据问题抛出错误
    return (
        <div>
            <h1>{user.name}</h1>
            <p>{user.email}</p>
        </div>
    );
}

// 故意抛出错误的组件（用于测试）
function BuggyComponent() {
    throw new Error('这是一个故意抛出的错误！');
    return <div>这行不会执行</div>;
}

// ============================================
// 在应用中使用
// ============================================

function App() {
    return (
        <div className="app">
            <Header />

            {/* 用错误边界包裹可能出错的区域 */}
            <ErrorBoundary
                fallback={<div className="error">用户信息加载失败</div>}
                onError={(error) => {
                    console.log('[App] 捕获到错误:', error.message);
                    // 上报错误
                }}
            >
                <UserProfile userId="123" />
            </ErrorBoundary>

            {/* 另一个独立的错误边界区域 */}
            <ErrorBoundary
                fallback={<div className="error">侧边栏加载失败</div>}
            >
                <Sidebar />
            </ErrorBoundary>

            <Footer />
        </div>
    );
}
```

**执行流程日志（正常情况）**：

```
[ErrorBoundary] 初始化
[ErrorBoundary] render, hasError: false
[UserProfile] 渲染
```

**执行流程日志（发生错误）**：

```
[ErrorBoundary] 初始化
[ErrorBoundary] render, hasError: false
[UserProfile] 渲染
// UserProfile 抛出错误...
[ErrorBoundary] getDerivedStateFromError: Cannot read property 'name' of null
[ErrorBoundary] componentDidCatch
  Error: Cannot read property 'name' of null
  Component Stack:
    at UserProfile
    at ErrorBoundary
    at App
[App] 捕获到错误: Cannot read property 'name' of null
[ErrorBoundary] render, hasError: true
// 显示错误 UI
```

---

### 4.2.4 错误边界的限制

错误边界**无法捕获**以下情况的错误：

| 无法捕获的场景 | 原因 | 解决方案 |
|--------------|------|---------|
| 事件处理函数中的错误 | 不在渲染流程中 | try-catch |
| 异步代码 (setTimeout, Promise) | 不在渲染流程中 | try-catch + 状态更新 |
| 服务端渲染 | 服务端没有错误边界机制 | 服务端 try-catch |
| 错误边界自身的错误 | 无法自己捕获自己 | 外层错误边界 |

```tsx
function MyComponent() {
    // ❌ 错误边界无法捕获
    const handleClick = () => {
        throw new Error('事件处理中的错误');
    };

    // ✅ 手动处理事件中的错误
    const handleClickSafe = () => {
        try {
            riskyOperation();
        } catch (error) {
            // 设置错误状态，触发错误 UI
            setError(error);
            // 或上报错误
            console.error('操作失败:', error);
        }
    };

    // ❌ 错误边界无法捕获
    useEffect(() => {
        setTimeout(() => {
            throw new Error('异步错误');
        }, 1000);
    }, []);

    // ✅ 手动处理异步错误
    useEffect(() => {
        const fetchData = async () => {
            try {
                const data = await api.getData();
                setData(data);
            } catch (error) {
                setError(error);
            }
        };
        fetchData();
    }, []);

    return <button onClick={handleClickSafe}>点击</button>;
}
```

---

### 4.2.5 使用 react-error-boundary 库

社区提供了更强大的错误边界实现：

```tsx
import { ErrorBoundary, useErrorBoundary } from 'react-error-boundary';

// 错误回退组件
function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
    return (
        <div role="alert">
            <p>出错了：</p>
            <pre>{error.message}</pre>
            <button onClick={resetErrorBoundary}>重试</button>
        </div>
    );
}

// 使用
function App() {
    return (
        <ErrorBoundary
            FallbackComponent={ErrorFallback}
            onError={(error, info) => {
                // 上报错误
                logErrorToService(error, info);
            }}
            onReset={() => {
                // 重置时清理状态
                queryClient.clear();
            }}
        >
            <MyApp />
        </ErrorBoundary>
    );
}

// 在函数组件中手动触发错误边界
function UserProfile() {
    const { showBoundary } = useErrorBoundary();

    const handleClick = async () => {
        try {
            await riskyOperation();
        } catch (error) {
            // 将错误传递给错误边界
            showBoundary(error);
        }
    };

    return <button onClick={handleClick}>执行操作</button>;
}
```

---

### 课时 4.2 小结

```tsx
// 错误边界核心要点：

// 1. 必须是类组件
class ErrorBoundary extends React.Component {
    static getDerivedStateFromError(error) {
        return { hasError: true };  // 更新状态
    }

    componentDidCatch(error, errorInfo) {
        logError(error, errorInfo);  // 上报错误
    }

    render() {
        if (this.state.hasError) {
            return <ErrorUI />;  // 显示备用 UI
        }
        return this.props.children;
    }
}

// 2. 使用方式
<ErrorBoundary fallback={<ErrorUI />}>
    <PossiblyBuggyComponent />
</ErrorBoundary>

// 3. 推荐使用 react-error-boundary 库
```

---

## 课时 4.3: Suspense 与懒加载

> Spring 类比：异步 Servlet + 懒加载 Bean

### 4.3.1 什么是 Suspense？

Suspense 让组件可以"等待"某些异步操作完成，在等待期间显示 fallback 内容。

```
传统方式：
组件内部处理 loading 状态 → 每个组件都要写 loading 逻辑

Suspense 方式：
组件声明式地"挂起" → Suspense 统一处理 loading 显示
```

**后端类比**：

```java
// Spring 异步处理
@GetMapping("/data")
public DeferredResult<ResponseEntity<Data>> getData() {
    DeferredResult<ResponseEntity<Data>> result = new DeferredResult<>();

    // 异步获取数据
    asyncService.fetchData().thenAccept(data -> {
        result.setResult(ResponseEntity.ok(data));
    });

    return result;  // 立即返回，数据准备好后再响应
}

// React Suspense 类似：
// 组件挂起，等待数据准备好后再渲染
```

---

### 4.3.2 代码分割与懒加载

```tsx
// ============================================
// 使用 React.lazy 进行代码分割
// ============================================

// 传统导入：所有组件打包在一起
// import HeavyComponent from './HeavyComponent';

// 懒加载导入：单独打包，按需加载
const HeavyComponent = lazy(() => {
    console.log('[lazy] 开始加载 HeavyComponent');
    return import('./HeavyComponent');
});

const AdminDashboard = lazy(() => {
    console.log('[lazy] 开始加载 AdminDashboard');
    return import('./AdminDashboard');
});

// ============================================
// 使用 Suspense 包裹懒加载组件
// ============================================

function App() {
    console.log('[App] 渲染');

    const [showHeavy, setShowHeavy] = useState(false);

    return (
        <div>
            <h1>我的应用</h1>

            <button onClick={() => setShowHeavy(true)}>
                加载大组件
            </button>

            {showHeavy && (
                // Suspense 提供 fallback，在组件加载期间显示
                <Suspense fallback={<div>加载中...</div>}>
                    <HeavyComponent />
                </Suspense>
            )}
        </div>
    );
}
```

**执行流程日志**：

```
// 1. 应用初始加载
[App] 渲染
// HeavyComponent 尚未加载

// 2. 用户点击"加载大组件"
[App] 渲染
[lazy] 开始加载 HeavyComponent
// 显示 "加载中..."

// 3. 组件加载完成
[HeavyComponent] 渲染
// 显示 HeavyComponent 内容
```

---

### 4.3.3 路由级别的代码分割

```tsx
// ============================================
// 基于路由的代码分割（推荐）
// ============================================

import { BrowserRouter, Routes, Route } from 'react-router-dom';

// 懒加载各页面组件
const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const UserProfile = lazy(() => import('./pages/UserProfile'));

// 加载指示器组件
function PageLoader() {
    return (
        <div className="page-loader">
            <div className="spinner" />
            <p>页面加载中...</p>
        </div>
    );
}

function App() {
    return (
        <BrowserRouter>
            {/* 全局 Suspense 包裹所有路由 */}
            <Suspense fallback={<PageLoader />}>
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/about" element={<About />} />
                    <Route path="/dashboard" element={<Dashboard />} />
                    <Route path="/user/:id" element={<UserProfile />} />
                </Routes>
            </Suspense>
        </BrowserRouter>
    );
}
```

**打包结果**：

```
dist/
├── index.js          # 主包（React + 路由 + 公共代码）
├── Home.js           # Home 页面单独打包
├── About.js          # About 页面单独打包
├── Dashboard.js      # Dashboard 页面单独打包
└── UserProfile.js    # UserProfile 页面单独打包
```

---

### 4.3.4 数据获取与 Suspense

React 18+ 支持使用 Suspense 处理数据获取（需要配合支持的库）。

```tsx
// ============================================
// 使用 TanStack Query (React Query) 配合 Suspense
// ============================================

import { useSuspenseQuery } from '@tanstack/react-query';

// 数据获取组件
function UserProfile({ userId }: { userId: string }) {
    console.log('[UserProfile] 渲染');

    // useSuspenseQuery 会在数据加载期间"挂起"组件
    const { data: user } = useSuspenseQuery({
        queryKey: ['user', userId],
        queryFn: () => fetchUser(userId),
    });

    // 这里 user 一定有值（非 undefined）
    // 因为 Suspense 会等待数据准备好才渲染
    console.log('[UserProfile] 数据已就绪:', user);

    return (
        <div>
            <h1>{user.name}</h1>
            <p>{user.email}</p>
        </div>
    );
}

// 使用
function App() {
    return (
        <Suspense fallback={<div>加载用户信息...</div>}>
            <UserProfile userId="123" />
        </Suspense>
    );
}
```

**对比传统方式**：

```tsx
// ❌ 传统方式：组件内部处理 loading
function UserProfile({ userId }: { userId: string }) {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        setLoading(true);
        fetchUser(userId)
            .then(setUser)
            .finally(() => setLoading(false));
    }, [userId]);

    if (loading) return <div>加载中...</div>;
    if (!user) return <div>用户不存在</div>;

    return (
        <div>
            <h1>{user.name}</h1>
            <p>{user.email}</p>
        </div>
    );
}

// ✅ Suspense 方式：loading 状态外部处理
function UserProfile({ userId }: { userId: string }) {
    const { data: user } = useSuspenseQuery({
        queryKey: ['user', userId],
        queryFn: () => fetchUser(userId),
    });

    // 组件更简洁，只关注渲染逻辑
    return (
        <div>
            <h1>{user.name}</h1>
            <p>{user.email}</p>
        </div>
    );
}
```

---

### 4.3.5 嵌套 Suspense

```tsx
// ============================================
// 多层 Suspense：细粒度控制加载状态
// ============================================

function Dashboard() {
    return (
        <div className="dashboard">
            {/* 外层 Suspense：整体 loading */}
            <Suspense fallback={<DashboardSkeleton />}>
                <DashboardHeader />

                <div className="dashboard-content">
                    {/* 内层 Suspense：独立 loading */}
                    <Suspense fallback={<ChartSkeleton />}>
                        <SalesChart />
                    </Suspense>

                    <Suspense fallback={<TableSkeleton />}>
                        <RecentOrders />
                    </Suspense>

                    <Suspense fallback={<ListSkeleton />}>
                        <TopProducts />
                    </Suspense>
                </div>
            </Suspense>
        </div>
    );
}
```

**加载行为**：

```
1. 初始：显示 DashboardSkeleton

2. DashboardHeader 准备好后：
   - 显示 DashboardHeader
   - 其他区域仍显示各自的 Skeleton

3. 各区域独立加载完成后替换 Skeleton

效果：页面逐步呈现，用户体验更好
```

---

### 4.3.6 Suspense 与错误边界组合

```tsx
// ============================================
// Suspense + ErrorBoundary 完整模式
// ============================================

function DataSection({ children }: { children: React.ReactNode }) {
    return (
        <ErrorBoundary
            fallback={<div className="error">加载失败，请刷新重试</div>}
        >
            <Suspense fallback={<div className="loading">加载中...</div>}>
                {children}
            </Suspense>
        </ErrorBoundary>
    );
}

// 使用
function Dashboard() {
    return (
        <div>
            <DataSection>
                <UserProfile />
            </DataSection>

            <DataSection>
                <OrderList />
            </DataSection>
        </div>
    );
}
```

---

### 课时 4.3 小结

```tsx
// Suspense 核心要点：

// 1. 代码分割 - React.lazy
const LazyComponent = lazy(() => import('./Component'));

// 2. 包裹懒加载组件
<Suspense fallback={<Loading />}>
    <LazyComponent />
</Suspense>

// 3. 路由级别分割（最常用）
const Home = lazy(() => import('./pages/Home'));

// 4. 数据获取（需要配合 React Query 等库）
const { data } = useSuspenseQuery({ queryKey, queryFn });

// 5. 配合错误边界
<ErrorBoundary fallback={<Error />}>
    <Suspense fallback={<Loading />}>
        <DataComponent />
    </Suspense>
</ErrorBoundary>
```

---

## 课时 4.4: 性能优化策略

> Spring 类比：缓存策略 + 连接池 + 延迟加载

### 4.4.1 React 性能优化原则

```
核心原则：减少不必要的渲染

渲染成本公式：
总成本 = 渲染次数 × 单次渲染成本

优化方向：
1. 减少渲染次数（避免不必要的重渲染）
2. 降低单次渲染成本（优化组件内部逻辑）
```

**后端类比**：

```java
// Spring 性能优化思路类似

// 1. 减少数据库查询次数（≈ 减少渲染次数）
@Cacheable("users")
public User getUser(String id) { ... }

// 2. 优化单次查询（≈ 优化单次渲染）
// 使用索引、减少返回字段等
```

---

### 4.4.2 React.memo：组件级别缓存

```tsx
// ============================================
// React.memo 基础用法
// ============================================

interface UserCardProps {
    user: User;
    onEdit: (id: string) => void;
}

// 未优化：父组件每次渲染都会导致 UserCard 重渲染
function UserCard({ user, onEdit }: UserCardProps) {
    console.log('[UserCard] 渲染:', user.name);
    return (
        <div className="user-card">
            <h3>{user.name}</h3>
            <button onClick={() => onEdit(user.id)}>编辑</button>
        </div>
    );
}

// 使用 React.memo 包裹：只有 props 变化时才重渲染
const MemoizedUserCard = React.memo(UserCard);

// ============================================
// 配合 useCallback 使用
// ============================================

function UserList({ users }: { users: User[] }) {
    console.log('[UserList] 渲染');

    // ❌ 每次渲染都创建新函数，memo 失效
    // const handleEdit = (id: string) => { ... };

    // ✅ 使用 useCallback 缓存函数引用
    const handleEdit = useCallback((id: string) => {
        console.log('编辑用户:', id);
    }, []);

    return (
        <div>
            {users.map(user => (
                <MemoizedUserCard
                    key={user.id}
                    user={user}
                    onEdit={handleEdit}
                />
            ))}
        </div>
    );
}
```

---

### 4.4.3 useMemo：计算结果缓存

```tsx
// ============================================
// 缓存昂贵的计算
// ============================================

function ProductList({ products, filters }: Props) {
    console.log('[ProductList] 渲染');

    // ❌ 每次渲染都重新过滤和排序
    // const filteredProducts = products
    //     .filter(p => p.category === filters.category)
    //     .sort((a, b) => a.price - b.price);

    // ✅ 只在 products 或 filters 变化时重新计算
    const filteredProducts = useMemo(() => {
        console.log('[ProductList] 执行过滤和排序');
        return products
            .filter(p => p.category === filters.category)
            .sort((a, b) => a.price - b.price);
    }, [products, filters]);

    // ✅ 缓存统计信息
    const stats = useMemo(() => {
        console.log('[ProductList] 计算统计信息');
        return {
            count: filteredProducts.length,
            avgPrice: filteredProducts.reduce((sum, p) => sum + p.price, 0) /
                      filteredProducts.length || 0,
        };
    }, [filteredProducts]);

    return (
        <div>
            <div>共 {stats.count} 个商品，均价 ¥{stats.avgPrice.toFixed(2)}</div>
            {filteredProducts.map(product => (
                <ProductCard key={product.id} product={product} />
            ))}
        </div>
    );
}
```

---

### 4.4.4 列表虚拟化

当渲染大量列表项时，使用虚拟化只渲染可见区域。

```tsx
// ============================================
// 使用 react-window 进行列表虚拟化
// ============================================

import { FixedSizeList as List } from 'react-window';

interface VirtualListProps {
    items: Item[];
}

function VirtualList({ items }: VirtualListProps) {
    console.log('[VirtualList] 渲染，总项数:', items.length);

    // 渲染单个列表项
    const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => {
        const item = items[index];
        return (
            <div style={style} className="list-item">
                {item.name}
            </div>
        );
    };

    return (
        <List
            height={400}        // 可视区域高度
            itemCount={items.length}  // 总项数
            itemSize={50}       // 每项高度
            width="100%"
        >
            {Row}
        </List>
    );
}

// 效果：即使有 10000 项，也只渲染可见的 8-10 项
```

**后端类比**：

```java
// 分页查询 ≈ 列表虚拟化
@GetMapping("/users")
public Page<User> getUsers(
    @RequestParam int page,
    @RequestParam int size
) {
    return userRepository.findAll(PageRequest.of(page, size));
}

// 只返回当前页的数据，而不是全部数据
```

---

### 4.4.5 防抖与节流

```tsx
// ============================================
// useDebounce Hook
// ============================================

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

// 使用：搜索输入防抖
function SearchBox() {
    const [query, setQuery] = useState('');
    const debouncedQuery = useDebounce(query, 300);

    // 只在防抖后的值变化时发起请求
    useEffect(() => {
        if (debouncedQuery) {
            console.log('[SearchBox] 发起搜索:', debouncedQuery);
            searchAPI(debouncedQuery);
        }
    }, [debouncedQuery]);

    return (
        <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="搜索..."
        />
    );
}

// ============================================
// useThrottle Hook
// ============================================

function useThrottle<T>(value: T, interval: number): T {
    const [throttledValue, setThrottledValue] = useState(value);
    const lastUpdated = useRef(Date.now());

    useEffect(() => {
        const now = Date.now();
        if (now - lastUpdated.current >= interval) {
            lastUpdated.current = now;
            setThrottledValue(value);
        } else {
            const timer = setTimeout(() => {
                lastUpdated.current = Date.now();
                setThrottledValue(value);
            }, interval - (now - lastUpdated.current));

            return () => clearTimeout(timer);
        }
    }, [value, interval]);

    return throttledValue;
}
```

---

### 4.4.6 状态下沉

将状态放在最需要它的组件中，避免不必要的父组件重渲染。

```tsx
// ❌ 状态放在父组件：整个列表都会重渲染
function UserList({ users }: { users: User[] }) {
    const [expandedId, setExpandedId] = useState<string | null>(null);

    return (
        <div>
            {users.map(user => (
                <UserCard
                    key={user.id}
                    user={user}
                    isExpanded={expandedId === user.id}
                    onToggle={() => setExpandedId(
                        expandedId === user.id ? null : user.id
                    )}
                />
            ))}
        </div>
    );
}

// ✅ 状态下沉到子组件：只有被点击的卡片重渲染
function UserList({ users }: { users: User[] }) {
    return (
        <div>
            {users.map(user => (
                <UserCard key={user.id} user={user} />
            ))}
        </div>
    );
}

function UserCard({ user }: { user: User }) {
    // 状态在子组件内部管理
    const [isExpanded, setIsExpanded] = useState(false);

    return (
        <div>
            <h3 onClick={() => setIsExpanded(!isExpanded)}>{user.name}</h3>
            {isExpanded && <UserDetails user={user} />}
        </div>
    );
}
```

---

### 4.4.7 性能分析工具

```tsx
// ============================================
// 1. React DevTools Profiler
// ============================================
// 浏览器扩展 → Profiler 面板 → 录制渲染过程

// ============================================
// 2. 使用 console.log 追踪渲染
// ============================================
function MyComponent() {
    console.log('[MyComponent] 渲染', Date.now());
    // ...
}

// ============================================
// 3. 使用 Profiler 组件
// ============================================
import { Profiler } from 'react';

function onRenderCallback(
    id: string,              // Profiler 的 id
    phase: 'mount' | 'update', // mount 或 update
    actualDuration: number,  // 本次渲染耗时
    baseDuration: number,    // 不使用 memo 的预估耗时
    startTime: number,       // 开始时间
    commitTime: number       // 提交时间
) {
    console.log(`[Profiler ${id}] ${phase} 耗时: ${actualDuration.toFixed(2)}ms`);
}

function App() {
    return (
        <Profiler id="App" onRender={onRenderCallback}>
            <MyExpensiveComponent />
        </Profiler>
    );
}

// ============================================
// 4. why-did-you-render 库
// ============================================
// 自动检测不必要的重渲染
// npm install @welldone-software/why-did-you-render

// wdyr.ts
import React from 'react';

if (process.env.NODE_ENV === 'development') {
    const whyDidYouRender = require('@welldone-software/why-did-you-render');
    whyDidYouRender(React, {
        trackAllPureComponents: true,
    });
}

// 在组件上启用
MyComponent.whyDidYouRender = true;
```

---

### 4.4.8 优化检查清单

| 问题 | 检查点 | 解决方案 |
|-----|-------|---------|
| 组件频繁重渲染 | 是否有不必要的 props 变化？ | React.memo + useCallback |
| 昂贵的计算重复执行 | 是否每次渲染都重新计算？ | useMemo |
| 大列表渲染卡顿 | 是否渲染了所有项目？ | 虚拟化 (react-window) |
| 输入框响应慢 | 是否每次输入都触发渲染？ | 防抖/节流 |
| 首屏加载慢 | 是否加载了不必要的代码？ | 代码分割 + 懒加载 |
| 状态变化影响范围大 | 状态是否放在了合适的层级？ | 状态下沉 |

---

### 课时 4.4 小结

```tsx
// 性能优化工具箱：

// 1. 组件缓存
const MemoComponent = React.memo(Component);

// 2. 计算缓存
const result = useMemo(() => compute(x), [x]);

// 3. 函数缓存
const handler = useCallback(() => {}, [deps]);

// 4. 列表虚拟化
<List itemCount={10000} height={400} itemSize={50}>
    {Row}
</List>

// 5. 代码分割
const LazyComponent = lazy(() => import('./Component'));

// 6. 防抖
const debouncedValue = useDebounce(value, 300);

// 优化原则：
// - 先测量，再优化（不要过早优化）
// - 优化热点路径（频繁渲染的组件）
// - 保持代码可读性
```

---

## 课时 4.5: 测试基础

> Spring 类比：JUnit + Mockito

### 4.5.1 React 测试金字塔

```
                    ┌───────┐
                    │  E2E  │  端到端测试（Cypress/Playwright）
                   ┌┴───────┴┐
                   │集成测试  │  组件交互测试
                  ┌┴─────────┴┐
                  │  单元测试   │  组件/Hook/工具函数
                 └─────────────┘

                 越往下：数量越多、速度越快、成本越低
```

**后端类比**：

```java
// 单元测试 ≈ Service 单元测试
@Test
void testUserService() { ... }

// 集成测试 ≈ Controller 集成测试
@SpringBootTest
void testUserController() { ... }

// E2E 测试 ≈ API 接口测试
// Postman / REST Assured
```

---

### 4.5.2 测试工具链

| 后端工具 | 前端对应 | 用途 |
|---------|---------|------|
| JUnit | Jest / Vitest | 测试运行器 |
| Mockito | Jest Mock / MSW | Mock 工具 |
| Hamcrest | Jest Matchers | 断言库 |
| Spring Test | React Testing Library | 组件测试 |
| Selenium | Cypress / Playwright | E2E 测试 |

---

### 4.5.3 设置测试环境

```bash
# 使用 Vitest（推荐，与 Vite 配合）
npm install -D vitest @testing-library/react @testing-library/jest-dom jsdom

# 或使用 Jest
npm install -D jest @testing-library/react @testing-library/jest-dom
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        environment: 'jsdom',
        globals: true,
        setupFiles: ['./src/test/setup.ts'],
    },
});

// src/test/setup.ts
import '@testing-library/jest-dom';
```

---

### 4.5.4 组件单元测试

```tsx
// ============================================
// 被测组件：Counter
// ============================================

interface CounterProps {
    initialValue?: number;
    onCountChange?: (count: number) => void;
}

function Counter({ initialValue = 0, onCountChange }: CounterProps) {
    const [count, setCount] = useState(initialValue);

    const increment = () => {
        const newCount = count + 1;
        setCount(newCount);
        onCountChange?.(newCount);
    };

    const decrement = () => {
        const newCount = count - 1;
        setCount(newCount);
        onCountChange?.(newCount);
    };

    return (
        <div>
            <span data-testid="count">{count}</span>
            <button onClick={decrement}>-</button>
            <button onClick={increment}>+</button>
        </div>
    );
}

// ============================================
// 测试文件：Counter.test.tsx
// ============================================

import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Counter from './Counter';

describe('Counter 组件', () => {
    // 测试初始渲染
    it('应该渲染初始值', () => {
        render(<Counter initialValue={10} />);

        // 查找元素并断言
        expect(screen.getByTestId('count')).toHaveTextContent('10');
    });

    // 测试用户交互
    it('点击 + 按钮应该增加计数', () => {
        render(<Counter />);

        // 查找按钮并点击
        fireEvent.click(screen.getByText('+'));

        // 断言结果
        expect(screen.getByTestId('count')).toHaveTextContent('1');
    });

    it('点击 - 按钮应该减少计数', () => {
        render(<Counter initialValue={5} />);

        fireEvent.click(screen.getByText('-'));

        expect(screen.getByTestId('count')).toHaveTextContent('4');
    });

    // 测试回调函数
    it('计数变化时应该调用 onCountChange', () => {
        // 创建 mock 函数
        const handleChange = vi.fn();

        render(<Counter onCountChange={handleChange} />);

        fireEvent.click(screen.getByText('+'));

        // 断言 mock 函数被调用
        expect(handleChange).toHaveBeenCalledWith(1);
        expect(handleChange).toHaveBeenCalledTimes(1);
    });
});
```

---

### 4.5.5 异步组件测试

```tsx
// ============================================
// 被测组件：UserProfile
// ============================================

function UserProfile({ userId }: { userId: string }) {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        setLoading(true);
        fetchUser(userId)
            .then(setUser)
            .catch(e => setError(e.message))
            .finally(() => setLoading(false));
    }, [userId]);

    if (loading) return <div>加载中...</div>;
    if (error) return <div>错误: {error}</div>;
    if (!user) return <div>用户不存在</div>;

    return (
        <div>
            <h1>{user.name}</h1>
            <p>{user.email}</p>
        </div>
    );
}

// ============================================
// 测试文件：UserProfile.test.tsx
// ============================================

import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import UserProfile from './UserProfile';
import * as api from './api';

// Mock API 模块
vi.mock('./api');

describe('UserProfile 组件', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('应该显示加载状态', () => {
        // Mock 返回一个永不 resolve 的 Promise
        vi.mocked(api.fetchUser).mockReturnValue(new Promise(() => {}));

        render(<UserProfile userId="1" />);

        expect(screen.getByText('加载中...')).toBeInTheDocument();
    });

    it('加载成功后应该显示用户信息', async () => {
        // Mock 返回用户数据
        vi.mocked(api.fetchUser).mockResolvedValue({
            id: '1',
            name: 'Tom',
            email: 'tom@example.com'
        });

        render(<UserProfile userId="1" />);

        // 等待异步操作完成
        await waitFor(() => {
            expect(screen.getByText('Tom')).toBeInTheDocument();
        });

        expect(screen.getByText('tom@example.com')).toBeInTheDocument();
    });

    it('加载失败应该显示错误信息', async () => {
        // Mock 返回错误
        vi.mocked(api.fetchUser).mockRejectedValue(new Error('网络错误'));

        render(<UserProfile userId="1" />);

        await waitFor(() => {
            expect(screen.getByText('错误: 网络错误')).toBeInTheDocument();
        });
    });
});
```

---

### 4.5.6 自定义 Hook 测试

```tsx
// ============================================
// 被测 Hook：useCounter
// ============================================

function useCounter(initialValue = 0) {
    const [count, setCount] = useState(initialValue);

    const increment = useCallback(() => setCount(c => c + 1), []);
    const decrement = useCallback(() => setCount(c => c - 1), []);
    const reset = useCallback(() => setCount(initialValue), [initialValue]);

    return { count, increment, decrement, reset };
}

// ============================================
// 测试文件：useCounter.test.ts
// ============================================

import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import useCounter from './useCounter';

describe('useCounter Hook', () => {
    it('应该返回初始值', () => {
        const { result } = renderHook(() => useCounter(10));

        expect(result.current.count).toBe(10);
    });

    it('increment 应该增加计数', () => {
        const { result } = renderHook(() => useCounter());

        // act 包裹状态更新操作
        act(() => {
            result.current.increment();
        });

        expect(result.current.count).toBe(1);
    });

    it('decrement 应该减少计数', () => {
        const { result } = renderHook(() => useCounter(5));

        act(() => {
            result.current.decrement();
        });

        expect(result.current.count).toBe(4);
    });

    it('reset 应该重置到初始值', () => {
        const { result } = renderHook(() => useCounter(10));

        act(() => {
            result.current.increment();
            result.current.increment();
        });

        expect(result.current.count).toBe(12);

        act(() => {
            result.current.reset();
        });

        expect(result.current.count).toBe(10);
    });
});
```

---

### 4.5.7 Mock 网络请求 (MSW)

```tsx
// ============================================
// 使用 MSW (Mock Service Worker) Mock API
// ============================================

// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
    // Mock GET /api/users/:id
    http.get('/api/users/:id', ({ params }) => {
        const { id } = params;

        if (id === '404') {
            return new HttpResponse(null, { status: 404 });
        }

        return HttpResponse.json({
            id,
            name: 'Mock User',
            email: 'mock@example.com'
        });
    }),

    // Mock POST /api/users
    http.post('/api/users', async ({ request }) => {
        const body = await request.json();

        return HttpResponse.json({
            id: 'new-id',
            ...body
        }, { status: 201 });
    }),
];

// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// src/test/setup.ts
import { server } from '../mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// ============================================
// 测试中使用
// ============================================

import { http, HttpResponse } from 'msw';
import { server } from '../mocks/server';

describe('UserProfile', () => {
    it('处理 404 错误', async () => {
        // 覆盖默认 handler
        server.use(
            http.get('/api/users/:id', () => {
                return new HttpResponse(null, { status: 404 });
            })
        );

        render(<UserProfile userId="123" />);

        await waitFor(() => {
            expect(screen.getByText('用户不存在')).toBeInTheDocument();
        });
    });
});
```

---

### 4.5.8 测试最佳实践

#### 1. 测试用户行为，而非实现细节

```tsx
// ❌ 测试实现细节
it('应该调用 setState', () => {
    const setStateSpy = vi.spyOn(React, 'useState');
    // ...
});

// ✅ 测试用户可见的行为
it('点击按钮后应该显示提交成功', async () => {
    render(<Form />);

    fireEvent.click(screen.getByText('提交'));

    await waitFor(() => {
        expect(screen.getByText('提交成功')).toBeInTheDocument();
    });
});
```

#### 2. 使用合适的查询方法

```tsx
// 查询优先级（推荐顺序）：
// 1. getByRole - 基于可访问性角色
screen.getByRole('button', { name: '提交' });

// 2. getByLabelText - 表单元素
screen.getByLabelText('邮箱');

// 3. getByPlaceholderText - placeholder
screen.getByPlaceholderText('请输入邮箱');

// 4. getByText - 文本内容
screen.getByText('提交');

// 5. getByTestId - 最后手段
screen.getByTestId('submit-button');
```

#### 3. 测试覆盖要点

| 测试类型 | 覆盖内容 |
|---------|---------|
| 正常路径 | 主要功能正常工作 |
| 边界情况 | 空数据、极端值 |
| 错误处理 | 网络错误、验证错误 |
| 用户交互 | 点击、输入、提交 |
| 异步行为 | 加载状态、成功/失败 |

---

### 课时 4.5 小结

```tsx
// 测试核心要点：

// 1. 组件测试
render(<Component />);
expect(screen.getByText('...')).toBeInTheDocument();

// 2. 用户交互
fireEvent.click(screen.getByRole('button'));

// 3. 异步等待
await waitFor(() => {
    expect(screen.getByText('...')).toBeInTheDocument();
});

// 4. Hook 测试
const { result } = renderHook(() => useMyHook());
act(() => { result.current.action(); });

// 5. Mock 函数
const mockFn = vi.fn();
expect(mockFn).toHaveBeenCalledWith(arg);

// 6. Mock API (MSW)
server.use(
    http.get('/api/...', () => HttpResponse.json(data))
);
```

---

## 模块四总结

### 完成的课时

| 课时 | 主题 | 核心内容 |
|-----|------|---------|
| 4.1 | Context 深入 | 跨层级数据传递、性能优化 |
| 4.2 | 错误边界 | 捕获渲染错误、备用 UI |
| 4.3 | Suspense 与懒加载 | 代码分割、异步组件 |
| 4.4 | 性能优化 | memo、useMemo、虚拟化 |
| 4.5 | 测试基础 | 组件测试、Hook 测试、Mock |

### 后端视角核心映射

| React 概念 | Java/Spring 类比 |
|-----------|-----------------|
| Context | @Autowired + ApplicationContext |
| 错误边界 | @ControllerAdvice 全局异常处理 |
| Suspense | 异步 Servlet + DeferredResult |
| React.memo | @Cacheable 缓存 |
| 代码分割 | 模块化 + 按需加载 |
| Vitest/Jest | JUnit |
| React Testing Library | Spring Test |
| MSW | WireMock |

### 下一步

模块五将开始讲解实战项目开发：
- 5.1 项目初始化与结构
- 5.2 路由配置
- 5.3 状态管理方案选型
- 5.4 API 层封装
- 5.5 完整 CRUD 实战

---
