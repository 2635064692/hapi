# 模块一：前置基础 (JavaScript/TypeScript)

> 面向 Java/Spring 后端工程师的前端基础知识
>
> 学习形式：每个概念配代码示例和 Spring 类比

---

## 目录

- [课时 1.1: ES6+ 核心语法](#课时-11-es6-核心语法)
- [课时 1.2: 模块化系统](#课时-12-模块化系统)
- [课时 1.3: 异步编程](#课时-13-异步编程)
- [课时 1.4: TypeScript 基础](#课时-14-typescript-基础)
- [课时 1.5: TypeScript 进阶](#课时-15-typescript-进阶)

---

## 课时 1.1: ES6+ 核心语法

> Spring 类比：Java 8 Lambda 表达式、Stream API

### 1. 箭头函数 ≈ Java Lambda

#### Java Lambda 回顾

```java
// Java 传统匿名类
Runnable r1 = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};

// Java 8 Lambda
Runnable r2 = () -> System.out.println("Hello");

// 带参数
Function<String, Integer> len = s -> s.length();
```

#### JavaScript 箭头函数

```javascript
// 传统函数
function add(a, b) {
    return a + b;
}

// 箭头函数（等价写法）
const add = (a, b) => {
    return a + b;
};

// 单行可省略 return 和大括号
const add = (a, b) => a + b;

// 单参数可省略括号
const double = x => x * 2;

// 无参数
const sayHello = () => console.log('Hello');
```

#### 关键区别：`this` 绑定

```javascript
// 传统函数：this 取决于调用方式
const obj = {
    name: 'Spring',
    greet: function() {
        console.log(this.name);  // 'Spring'
    }
};

// 箭头函数：this 继承自外层作用域（词法作用域）
const obj2 = {
    name: 'React',
    greet: () => {
        console.log(this.name);  // undefined（this 是外层的 this）
    }
};
```

**后端类比**：箭头函数的 `this` 类似 Java Lambda 中捕获外部变量——它"捕获"的是定义时的 `this`，而不是调用时的。

---

### 2. 解构赋值 ≈ 模式匹配

#### Java 没有解构，但 Record 有类似感觉

```java
// Java Record（Java 16+）
record User(String name, int age) {}
User user = new User("Tom", 25);
String name = user.name();  // 必须逐个获取
```

#### JavaScript 解构

```javascript
// 对象解构 — 按属性名匹配
const user = { name: 'Tom', age: 25, email: 'tom@test.com' };
const { name, age } = user;  // name='Tom', age=25

// 重命名
const { name: userName } = user;  // userName='Tom'

// 默认值
const { role = 'guest' } = user;  // role='guest'（user 中没有 role）

// 数组解构 — 按位置匹配
const [first, second] = [1, 2, 3];  // first=1, second=2

// 跳过元素
const [, , third] = [1, 2, 3];  // third=3

// 函数参数解构（React 中极常用！）
function UserCard({ name, age }) {  // 直接解构 props
    return <div>{name}, {age}</div>;
}
```

**后端类比**：解构就像 MyBatis 的结果映射，把数据源的字段"映射"到局部变量。

---

### 3. 展开运算符 `...` ≈ 集合操作

#### Java 集合操作

```java
List<Integer> list1 = Arrays.asList(1, 2, 3);
List<Integer> list2 = Arrays.asList(4, 5);
List<Integer> combined = new ArrayList<>(list1);
combined.addAll(list2);  // [1, 2, 3, 4, 5]
```

#### JavaScript 展开运算符

```javascript
// 数组展开
const arr1 = [1, 2, 3];
const arr2 = [4, 5];
const combined = [...arr1, ...arr2];  // [1, 2, 3, 4, 5]

// 复制数组（浅拷贝）
const copy = [...arr1];

// 对象展开（React 中极常用！）
const user = { name: 'Tom', age: 25 };
const updated = { ...user, age: 26 };  // { name: 'Tom', age: 26 }

// 合并对象
const defaults = { theme: 'light', lang: 'en' };
const settings = { ...defaults, theme: 'dark' };  // 后面的覆盖前面的
```

**React 中的典型用法**：

```jsx
// 更新 State（不可变更新）
const [user, setUser] = useState({ name: 'Tom', age: 25 });
setUser({ ...user, age: 26 });  // 创建新对象，而不是修改原对象

// Props 透传
<ChildComponent {...props} />
```

**后端类比**：展开运算符类似 BeanUtils.copyProperties()，用于对象属性的复制和合并。

---

### 4. 模板字符串 ≈ String.format()

#### Java 字符串拼接

```java
String name = "Tom";
int age = 25;
String msg = String.format("Hello, %s. You are %d years old.", name, age);
// 或
String msg2 = "Hello, " + name + ". You are " + age + " years old.";
```

#### JavaScript 模板字符串

```javascript
const name = 'Tom';
const age = 25;
const msg = `Hello, ${name}. You are ${age} years old.`;

// 可以嵌入任意表达式
const greeting = `${age >= 18 ? 'Adult' : 'Minor'}: ${name}`;

// 多行字符串（无需 \n）
const html = `
    <div>
        <h1>${name}</h1>
        <p>Age: ${age}</p>
    </div>
`;
```

**后端类比**：模板字符串就是 JavaScript 版的 `String.format()`，但更灵活——可以直接嵌入表达式。

---

### 5. 可选链 `?.` 和空值合并 `??`

#### Java 的空指针处理

```java
// Java 传统方式
String city = null;
if (user != null && user.getAddress() != null) {
    city = user.getAddress().getCity();
}

// Java Optional（Java 8+）
String city = Optional.ofNullable(user)
    .map(User::getAddress)
    .map(Address::getCity)
    .orElse("Unknown");
```

#### JavaScript 可选链

```javascript
// 可选链 ?.（安全访问）
const city = user?.address?.city;  // 任意一环为 null/undefined 就返回 undefined

// 空值合并 ??（默认值）
const city = user?.address?.city ?? 'Unknown';

// 注意：?? 只对 null/undefined 生效
0 ?? 'default'    // 0（0 不是 null/undefined）
'' ?? 'default'   // ''（空字符串不是 null/undefined）

// 对比 ||（会把 0、''、false 也视为"假"）
0 || 'default'    // 'default'（0 是 falsy）
```

**后端类比**：`?.` 就是 JavaScript 版的 `Optional.map()`，`??` 就是 `Optional.orElse()`。

---

### 课时 1.1 小结

| ES6+ 语法 | Java 类比 | React 使用场景 |
|----------|---------|---------------|
| 箭头函数 `=>` | Lambda 表达式 | 事件处理、回调函数 |
| 解构赋值 `{}` | 模式匹配 | Props 解构、State 解构 |
| 展开运算符 `...` | BeanUtils.copyProperties | 不可变状态更新 |
| 模板字符串 `` ` ` `` | String.format() | 动态拼接类名、URL |
| 可选链 `?.` | Optional.map() | 安全访问嵌套数据 |
| 空值合并 `??` | Optional.orElse() | 设置默认值 |

---

## 课时 1.2: 模块化系统

> Spring 类比：Maven 依赖管理、Spring Bean 的依赖注入

### 1. 为什么需要模块化

#### Java 的模块化

```java
// Java 通过 package 组织代码
package com.example.service;

// 通过 import 引入依赖
import com.example.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository userRepository;
    // ...
}
```

#### JavaScript 历史问题

早期 JavaScript 没有模块系统，所有代码共享全局作用域：

```html
<!-- 传统方式：顺序加载，全局污染 -->
<script src="jquery.js"></script>
<script src="utils.js"></script>
<script src="app.js"></script>
<!-- 如果顺序错误或变量名冲突，就会出问题 -->
```

---

### 2. ES Modules (ESM) — 现代标准

#### 导出 (export)

```javascript
// utils.js

// 命名导出（可以有多个）
export const PI = 3.14159;

export function add(a, b) {
    return a + b;
}

export class Calculator {
    // ...
}

// 也可以集中导出
const multiply = (a, b) => a * b;
const divide = (a, b) => a / b;
export { multiply, divide };
```

```javascript
// userService.js

// 默认导出（每个模块只能有一个）
export default class UserService {
    getUser(id) {
        // ...
    }
}
```

#### 导入 (import)

```javascript
// app.js

// 导入命名导出（使用大括号，名称必须匹配）
import { PI, add, Calculator } from './utils.js';

// 导入默认导出（不用大括号，名称可以任意）
import UserService from './userService.js';

// 混合导入
import UserService, { helper } from './userService.js';

// 重命名导入
import { add as sum } from './utils.js';

// 导入全部为一个对象
import * as Utils from './utils.js';
console.log(Utils.PI);  // 3.14159

// 仅执行模块（不导入任何内容）
import './polyfill.js';
```

**后端类比**：

| JavaScript | Java |
|-----------|------|
| `export` | `public` 修饰符 |
| `export default` | 类的主要公开接口 |
| `import { x }` | `import com.example.x` |
| `import * as X` | `import com.example.*` |

---

### 3. 动态导入 — 代码分割

#### Java 的类加载

```java
// Java 反射动态加载
Class<?> clazz = Class.forName("com.example.Plugin");
Object instance = clazz.getDeclaredConstructor().newInstance();
```

#### JavaScript 动态导入

```javascript
// 静态导入：打包时就包含
import { Chart } from 'chart.js';

// 动态导入：运行时按需加载（返回 Promise）
const loadChart = async () => {
    const { Chart } = await import('chart.js');
    new Chart(canvas, config);
};

// React 中的懒加载（代码分割）
const LazyComponent = React.lazy(() => import('./HeavyComponent'));

function App() {
    return (
        <Suspense fallback={<Loading />}>
            <LazyComponent />
        </Suspense>
    );
}
```

**后端类比**：动态导入类似于 Spring 的懒加载 (`@Lazy`) 或插件系统的按需加载。

---

### 4. 路径解析

```javascript
// 相对路径（相对于当前文件）
import { utils } from './utils.js';
import { config } from '../config/index.js';

// 包名（从 node_modules 解析）
import React from 'react';
import { useState } from 'react';

// 别名路径（需要构建工具配置）
import { Button } from '@/components/Button';  // @ 通常指向 src 目录
```

**后端类比**：

| JavaScript | Java/Maven |
|-----------|------------|
| `./utils.js` | 同包内的类 |
| `react` | pom.xml 中的依赖 |
| `@/components` | 项目内模块的引用 |

---

### 5. 模块的组织模式

#### 桶文件 (Barrel) 模式

```javascript
// components/index.js — 集中导出
export { Button } from './Button';
export { Input } from './Input';
export { Modal } from './Modal';

// 使用时可以简化导入路径
import { Button, Input, Modal } from '@/components';
// 而不是
import { Button } from '@/components/Button';
import { Input } from '@/components/Input';
```

**后端类比**：类似 Java 的 Facade 模式，提供统一的入口点。

---

### 课时 1.2 小结

| 概念 | JavaScript | Java 类比 |
|-----|-----------|----------|
| 命名导出 | `export { x }` | public 成员 |
| 默认导出 | `export default` | 类的主接口 |
| 静态导入 | `import x from 'y'` | import 语句 |
| 动态导入 | `import('x')` | Class.forName() |
| 包管理 | npm / pnpm | Maven / Gradle |
| 依赖声明 | package.json | pom.xml |

---

## 课时 1.3: 异步编程

> Spring 类比：CompletableFuture、@Async、WebFlux

### 1. 为什么需要异步

#### Java 中的阻塞 vs 非阻塞

```java
// 同步阻塞（传统方式）
User user = userRepository.findById(id);  // 线程等待数据库返回
System.out.println(user.getName());

// 异步非阻塞（CompletableFuture）
CompletableFuture<User> future = CompletableFuture.supplyAsync(() ->
    userRepository.findById(id)
);
future.thenAccept(user -> System.out.println(user.getName()));
```

#### JavaScript 的单线程模型

JavaScript 是**单线程**的，如果同步等待网络请求，整个页面会卡死：

```javascript
// ❌ 假设这是同步的（实际 JS 不会这样）
const data = fetch('/api/user');  // 页面卡住 3 秒...
console.log(data);

// ✅ 实际是异步的
fetch('/api/user').then(response => {
    console.log(response);  // 请求完成后执行
});
console.log('继续执行其他代码');  // 立即执行，不等待
```

**后端类比**：JavaScript 的事件循环类似 Netty 的 EventLoop 或 Node.js（本来就是 JS）的非阻塞 I/O 模型。

---

### 2. 回调函数 — 最原始的方式

```javascript
// 回调地狱（Callback Hell）
getUser(userId, (user) => {
    getOrders(user.id, (orders) => {
        getOrderDetails(orders[0].id, (details) => {
            console.log(details);
            // 嵌套越来越深...
        });
    });
});
```

**问题**：代码难以阅读、错误处理困难、难以组合。

---

### 3. Promise — 链式调用

#### 基本用法

```javascript
// 创建 Promise
const fetchUser = (id) => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            if (id > 0) {
                resolve({ id, name: 'Tom' });
            } else {
                reject(new Error('Invalid ID'));
            }
        }, 1000);
    });
};

// 使用 Promise
fetchUser(1)
    .then(user => {
        console.log(user.name);
        return fetchOrders(user.id);  // 返回新的 Promise
    })
    .then(orders => {
        console.log(orders);
    })
    .catch(error => {
        console.error('出错了:', error);
    })
    .finally(() => {
        console.log('无论成功失败都执行');
    });
```

#### Promise 静态方法

```javascript
// 并行执行，全部完成后返回
const [user, orders] = await Promise.all([
    fetchUser(1),
    fetchOrders(1)
]);

// 并行执行，返回最快的那个
const fastest = await Promise.race([
    fetchFromServer1(),
    fetchFromServer2()
]);

// 并行执行，等待全部结束（不管成功失败）
const results = await Promise.allSettled([
    fetchUser(1),
    fetchUser(-1)  // 会失败
]);
// results: [{ status: 'fulfilled', value: {...} }, { status: 'rejected', reason: Error }]
```

**后端类比**：

| JavaScript Promise | Java CompletableFuture |
|-------------------|------------------------|
| `new Promise()` | `CompletableFuture.supplyAsync()` |
| `.then()` | `.thenApply()` / `.thenAccept()` |
| `.catch()` | `.exceptionally()` |
| `.finally()` | `.whenComplete()` |
| `Promise.all()` | `CompletableFuture.allOf()` |
| `Promise.race()` | `CompletableFuture.anyOf()` |

---

### 4. async/await — 同步写法的异步

```javascript
// async 函数自动返回 Promise
async function getUserWithOrders(userId) {
    try {
        // await 等待 Promise 完成，像同步代码一样
        const user = await fetchUser(userId);
        const orders = await fetchOrders(user.id);
        return { user, orders };
    } catch (error) {
        console.error('获取失败:', error);
        throw error;
    }
}

// 调用
getUserWithOrders(1).then(result => console.log(result));

// 或在另一个 async 函数中
async function main() {
    const result = await getUserWithOrders(1);
    console.log(result);
}
```

#### 并行执行优化

```javascript
// ❌ 串行执行（慢）
async function slow() {
    const user = await fetchUser(1);     // 等待 1 秒
    const orders = await fetchOrders(1);  // 再等待 1 秒
    // 总共 2 秒
}

// ✅ 并行执行（快）
async function fast() {
    const [user, orders] = await Promise.all([
        fetchUser(1),
        fetchOrders(1)
    ]);
    // 总共 1 秒
}
```

**后端类比**：async/await 就像 Kotlin 的协程或 Project Loom 的虚拟线程，用同步的写法实现异步。

---

### 5. 错误处理模式

```javascript
// 方式一：try/catch（推荐）
async function fetchData() {
    try {
        const data = await fetch('/api/data');
        return await data.json();
    } catch (error) {
        console.error('请求失败:', error);
        return null;  // 返回默认值
    }
}

// 方式二：.catch() 链式
const data = await fetch('/api/data')
    .then(res => res.json())
    .catch(error => {
        console.error(error);
        return null;
    });

// 方式三：错误包装模式（类似 Go 的 error 返回）
async function safeAwait(promise) {
    try {
        const data = await promise;
        return [data, null];
    } catch (error) {
        return [null, error];
    }
}

const [user, error] = await safeAwait(fetchUser(1));
if (error) {
    console.error('获取用户失败:', error);
}
```

---

### 6. React 中的异步处理

```jsx
function UserProfile({ userId }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        // 定义异步函数
        async function loadUser() {
            try {
                setLoading(true);
                const response = await fetch(`/api/users/${userId}`);
                if (!response.ok) throw new Error('请求失败');
                const data = await response.json();
                setUser(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        }

        loadUser();
    }, [userId]);

    if (loading) return <div>加载中...</div>;
    if (error) return <div>错误: {error}</div>;
    return <div>{user.name}</div>;
}
```

**后端类比**：这个模式类似于 Controller 调用 Service 时的异常处理：

```java
@GetMapping("/users/{id}")
public ResponseEntity<?> getUser(@PathVariable Long id) {
    try {
        User user = userService.findById(id);
        return ResponseEntity.ok(user);
    } catch (UserNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body(e.getMessage());
    }
}
```

---

### 课时 1.3 小结

| JavaScript | Java | 说明 |
|-----------|------|------|
| `Promise` | `CompletableFuture` | 异步操作的容器 |
| `async/await` | Kotlin 协程 / Loom | 同步写法的异步 |
| `.then()` | `.thenApply()` | 链式处理结果 |
| `.catch()` | `.exceptionally()` | 异常处理 |
| `Promise.all()` | `allOf()` | 并行等待全部 |
| 事件循环 | Netty EventLoop | 非阻塞调度模型 |

---

## 课时 1.4: TypeScript 基础

> Spring 类比：Java 强类型系统

### 1. 为什么需要 TypeScript

#### JavaScript 的问题

```javascript
// JavaScript 是动态类型，运行时才发现错误
function add(a, b) {
    return a + b;
}

add(1, 2);        // 3 ✓
add('1', 2);      // '12' — 字符串拼接，可能不是预期
add(null, 2);     // 2 — null 被转为 0
add({}, []);      // '[object Object]' — 更奇怪的结果
```

#### TypeScript 的解决

```typescript
// TypeScript 在编译时就能发现错误
function add(a: number, b: number): number {
    return a + b;
}

add(1, 2);        // 3 ✓
add('1', 2);      // ❌ 编译错误：类型 'string' 不能赋值给类型 'number'
```

**后端类比**：TypeScript 之于 JavaScript，就像 Java 之于弱类型语言。类型系统提供编译时检查。

---

### 2. 基本类型

```typescript
// 原始类型
const name: string = 'Tom';
const age: number = 25;
const isActive: boolean = true;
const nothing: null = null;
const notDefined: undefined = undefined;

// 数组
const numbers: number[] = [1, 2, 3];
const names: Array<string> = ['Tom', 'Jerry'];  // 泛型写法

// 元组（固定长度和类型的数组）
const tuple: [string, number] = ['Tom', 25];

// 枚举
enum Status {
    Pending = 'PENDING',
    Active = 'ACTIVE',
    Inactive = 'INACTIVE'
}
const status: Status = Status.Active;

// any（逃生舱，尽量避免）
const data: any = fetchFromSomewhere();

// unknown（比 any 更安全）
const input: unknown = JSON.parse(userInput);
if (typeof input === 'string') {
    console.log(input.toUpperCase());  // 类型收窄后才能使用
}

// void（函数无返回值）
function log(msg: string): void {
    console.log(msg);
}

// never（永不返回）
function throwError(msg: string): never {
    throw new Error(msg);
}
```

**后端类比**：

| TypeScript | Java |
|-----------|------|
| `string` | `String` |
| `number` | `int` / `double` |
| `boolean` | `boolean` |
| `number[]` | `List<Integer>` |
| `[string, number]` | 自定义类或 Record |
| `enum` | `enum` |
| `any` | `Object` |
| `unknown` | 需要类型检查的 `Object` |
| `void` | `void` |
| `never` | 抛异常的方法 |

---

### 3. 接口 (Interface) ≈ Java Interface / DTO

```typescript
// 定义接口
interface User {
    id: number;
    name: string;
    email?: string;        // 可选属性
    readonly createdAt: Date;  // 只读属性
}

// 使用接口
const user: User = {
    id: 1,
    name: 'Tom',
    createdAt: new Date()
};

// 接口继承
interface Admin extends User {
    role: 'admin';
    permissions: string[];
}

// 函数类型接口
interface SearchFunction {
    (query: string, limit?: number): Promise<User[]>;
}

const search: SearchFunction = async (query, limit = 10) => {
    // 实现
    return [];
};
```

**后端类比**：

```java
// Java DTO
public class User {
    private Long id;
    private String name;
    private String email;  // @Nullable
    private final Date createdAt;  // final = readonly

    // getters, setters...
}

// Java 接口
public interface SearchFunction {
    CompletableFuture<List<User>> apply(String query, Integer limit);
}
```

---

### 4. 类型别名 (Type Alias)

```typescript
// 基本类型别名
type ID = string | number;
type Status = 'pending' | 'active' | 'inactive';

// 对象类型别名（与 interface 类似）
type Point = {
    x: number;
    y: number;
};

// 联合类型
type Result = Success | Failure;

interface Success {
    status: 'success';
    data: any;
}

interface Failure {
    status: 'failure';
    error: string;
}

// 使用
function handleResult(result: Result) {
    if (result.status === 'success') {
        console.log(result.data);  // TypeScript 知道这里有 data
    } else {
        console.log(result.error); // TypeScript 知道这里有 error
    }
}
```

**interface vs type**：

| 特性 | interface | type |
|-----|-----------|------|
| 对象类型 | ✓ | ✓ |
| 联合类型 | ✗ | ✓ |
| 交叉类型 | ✗ | ✓ |
| 声明合并 | ✓ | ✗ |
| extends | ✓ | 用 `&` 代替 |

**一般建议**：对象结构用 `interface`，其他用 `type`。

---

### 5. 泛型 ≈ Java 泛型

```typescript
// 泛型函数
function identity<T>(value: T): T {
    return value;
}

const num = identity<number>(42);    // 显式指定类型
const str = identity('hello');       // 类型推断

// 泛型接口
interface ApiResponse<T> {
    code: number;
    message: string;
    data: T;
}

const userResponse: ApiResponse<User> = {
    code: 200,
    message: 'success',
    data: { id: 1, name: 'Tom', createdAt: new Date() }
};

// 泛型约束
interface HasId {
    id: number;
}

function findById<T extends HasId>(items: T[], id: number): T | undefined {
    return items.find(item => item.id === id);
}

// 多个泛型参数
function pair<K, V>(key: K, value: V): [K, V] {
    return [key, value];
}
```

**后端类比**：

```java
// Java 泛型方法
public <T> T identity(T value) {
    return value;
}

// Java 泛型接口
public interface ApiResponse<T> {
    int getCode();
    String getMessage();
    T getData();
}

// Java 泛型约束
public <T extends HasId> T findById(List<T> items, Long id) {
    return items.stream()
        .filter(item -> item.getId().equals(id))
        .findFirst()
        .orElse(null);
}
```

---

### 6. 函数类型

```typescript
// 函数声明
function add(a: number, b: number): number {
    return a + b;
}

// 箭头函数
const multiply = (a: number, b: number): number => a * b;

// 可选参数
function greet(name: string, greeting?: string): string {
    return `${greeting ?? 'Hello'}, ${name}!`;
}

// 默认参数
function greet2(name: string, greeting: string = 'Hello'): string {
    return `${greeting}, ${name}!`;
}

// 剩余参数
function sum(...numbers: number[]): number {
    return numbers.reduce((a, b) => a + b, 0);
}

// 函数重载
function format(value: string): string;
function format(value: number): string;
function format(value: string | number): string {
    if (typeof value === 'string') {
        return value.toUpperCase();
    }
    return value.toFixed(2);
}
```

---

### 课时 1.4 小结

| TypeScript 概念 | Java 类比 | 说明 |
|----------------|----------|------|
| 基本类型 | 基本类型 | string, number, boolean |
| interface | interface / DTO | 定义对象结构 |
| type | — | 类型别名、联合类型 |
| 泛型 `<T>` | 泛型 `<T>` | 类型参数化 |
| `?` 可选属性 | `@Nullable` | 属性可以不存在 |
| `readonly` | `final` | 只读属性 |
| `unknown` | 需要检查的 Object | 安全的 any |

---

## 课时 1.5: TypeScript 进阶

> Spring 类比：Java 泛型高级用法、反射

### 1. 工具类型 (Utility Types)

TypeScript 内置了很多实用的类型工具：

```typescript
interface User {
    id: number;
    name: string;
    email: string;
    age: number;
}

// Partial<T> — 所有属性变为可选
type PartialUser = Partial<User>;
// 等价于 { id?: number; name?: string; email?: string; age?: number; }

// Required<T> — 所有属性变为必选
type RequiredUser = Required<PartialUser>;

// Readonly<T> — 所有属性变为只读
type ReadonlyUser = Readonly<User>;

// Pick<T, K> — 选取部分属性
type UserBasic = Pick<User, 'id' | 'name'>;
// 等价于 { id: number; name: string; }

// Omit<T, K> — 排除部分属性
type UserWithoutEmail = Omit<User, 'email'>;
// 等价于 { id: number; name: string; age: number; }

// Record<K, V> — 构造对象类型
type UserMap = Record<string, User>;
// 等价于 { [key: string]: User }

// ReturnType<T> — 获取函数返回类型
function getUser() {
    return { id: 1, name: 'Tom' };
}
type UserFromFunc = ReturnType<typeof getUser>;
// 等价于 { id: number; name: string; }

// Parameters<T> — 获取函数参数类型
type GetUserParams = Parameters<typeof getUser>;
// 等价于 []
```

**后端类比**：工具类型类似 Java 泛型的一些模式，但 TypeScript 更灵活：

```java
// Java 中要实现类似 Partial 需要创建新类或使用 Optional 字段
public class PartialUser {
    private Optional<Long> id;
    private Optional<String> name;
    // ...
}
```

---

### 2. 类型守卫 (Type Guards)

```typescript
// typeof 守卫
function process(value: string | number) {
    if (typeof value === 'string') {
        return value.toUpperCase();  // TypeScript 知道是 string
    }
    return value.toFixed(2);         // TypeScript 知道是 number
}

// instanceof 守卫
class Dog {
    bark() { console.log('汪'); }
}
class Cat {
    meow() { console.log('喵'); }
}

function speak(animal: Dog | Cat) {
    if (animal instanceof Dog) {
        animal.bark();   // TypeScript 知道是 Dog
    } else {
        animal.meow();   // TypeScript 知道是 Cat
    }
}

// in 守卫（检查属性是否存在）
interface Bird {
    fly: () => void;
}
interface Fish {
    swim: () => void;
}

function move(animal: Bird | Fish) {
    if ('fly' in animal) {
        animal.fly();    // TypeScript 知道是 Bird
    } else {
        animal.swim();   // TypeScript 知道是 Fish
    }
}

// 自定义类型守卫
interface User {
    type: 'user';
    name: string;
}
interface Admin {
    type: 'admin';
    name: string;
    permissions: string[];
}

// 返回类型 `is` 告诉 TypeScript 这是类型守卫
function isAdmin(person: User | Admin): person is Admin {
    return person.type === 'admin';
}

function greet(person: User | Admin) {
    if (isAdmin(person)) {
        console.log(`Admin ${person.name} has ${person.permissions.length} permissions`);
    } else {
        console.log(`User ${person.name}`);
    }
}
```

**后端类比**：

```java
// Java instanceof
if (animal instanceof Dog) {
    ((Dog) animal).bark();
}

// Java 17 模式匹配
if (animal instanceof Dog dog) {
    dog.bark();  // 自动类型收窄
}
```

---

### 3. 映射类型 (Mapped Types)

映射类型是 TypeScript 的"反射 + 批量字段转换"能力。

#### 基础类型定义

```typescript
// 原始类型（类比 Java 实体类）
interface User {
    id: number;
    name: string;
    email: string;
    age: number;
}
```

#### 3.1 `keyof` — 获取所有属性名

```typescript
type UserKeys = keyof User;
// 等价于: 'id' | 'name' | 'email' | 'age'

// 使用示例
function getProperty(user: User, key: UserKeys) {
    return user[key];  // 类型安全，key 只能是 User 的属性名
}

const user: User = { id: 1, name: 'Tom', email: 'tom@test.com', age: 25 };
getProperty(user, 'name');   // ✓ 正确
getProperty(user, 'phone');  // ✗ 错误：'phone' 不是 User 的属性
```

**后端类比**：类似 Java 反射获取字段名

```java
// Java 反射
Field[] fields = User.class.getDeclaredFields();
// ["id", "name", "email", "age"]
```

#### 3.2 `[K in keyof T]` — 遍历所有属性

```typescript
// 原理：遍历 T 的每个属性 K，生成新类型
type Readonly<T> = {
    readonly [K in keyof T]: T[K];
};

// 展开过程（手动模拟）：
// K = 'id'    → readonly id: User['id']    → readonly id: number
// K = 'name'  → readonly name: User['name'] → readonly name: string
// K = 'email' → readonly email: User['email'] → readonly email: string
// K = 'age'   → readonly age: User['age']   → readonly age: number

// 最终结果
type ReadonlyUser = Readonly<User>;
// 等价于：
// {
//     readonly id: number;
//     readonly name: string;
//     readonly email: string;
//     readonly age: number;
// }

// 使用
const user: ReadonlyUser = { id: 1, name: 'Tom', email: 'tom@test.com', age: 25 };
user.name = 'Jerry';  // ✗ 错误：无法分配到 "name" ，因为它是只读属性
```

#### 3.3 `Nullable<T>` — 所有属性可为 null

```typescript
type Nullable<T> = {
    [K in keyof T]: T[K] | null;
};

// 展开过程：
// K = 'id'    → id: number | null
// K = 'name'  → name: string | null
// K = 'email' → email: string | null
// K = 'age'   → age: number | null

type NullableUser = Nullable<User>;
// 等价于：
// {
//     id: number | null;
//     name: string | null;
//     email: string | null;
//     age: number | null;
// }

// 使用场景：表单初始状态
const formData: NullableUser = {
    id: null,      // 新建时 id 为空
    name: null,
    email: null,
    age: null
};

// 填写表单
formData.name = 'Tom';
formData.email = 'tom@test.com';
```

#### 3.4 修饰符操作：`+` 和 `-`

```typescript
// 移除 readonly（-readonly）
type Mutable<T> = {
    -readonly [K in keyof T]: T[K];
};

// 原始只读类型
interface ReadonlyConfig {
    readonly apiUrl: string;
    readonly timeout: number;
}

// 移除只读
type MutableConfig = Mutable<ReadonlyConfig>;
// 等价于：
// {
//     apiUrl: string;    // 不再是 readonly
//     timeout: number;   // 不再是 readonly
// }

const config: MutableConfig = { apiUrl: 'http://api.com', timeout: 3000 };
config.timeout = 5000;  // ✓ 现在可以修改了
```

```typescript
// 添加可选（+?）
type Optional<T> = {
    [K in keyof T]+?: T[K];
};

// 等价于 Partial<T>
type OptionalUser = Optional<User>;
// 等价于：
// {
//     id?: number;
//     name?: string;
//     email?: string;
//     age?: number;
// }

// 使用场景：更新时只传需要修改的字段
function updateUser(id: number, updates: OptionalUser) {
    // 只更新传入的字段
}

updateUser(1, { name: 'Jerry' });  // ✓ 只更新 name
updateUser(1, { age: 26 });        // ✓ 只更新 age
```

```typescript
// 移除可选（-?）— 让所有属性变为必选
type Required<T> = {
    [K in keyof T]-?: T[K];
};

interface PartialConfig {
    apiUrl?: string;
    timeout?: number;
}

type FullConfig = Required<PartialConfig>;
// 等价于：
// {
//     apiUrl: string;   // 必选
//     timeout: number;  // 必选
// }

const config: FullConfig = { apiUrl: 'http://api.com' };  // ✗ 错误：缺少 timeout
```

#### 3.5 实战示例：API 请求类型转换

```typescript
// 后端返回的原始数据（所有字段都是必选）
interface UserDTO {
    id: number;
    name: string;
    email: string;
    createdAt: string;
    updatedAt: string;
}

// 创建用户时的请求体（不需要 id 和时间戳）
type CreateUserRequest = Omit<UserDTO, 'id' | 'createdAt' | 'updatedAt'>;
// { name: string; email: string; }

// 更新用户时的请求体（所有字段可选）
type UpdateUserRequest = Partial<Omit<UserDTO, 'id' | 'createdAt' | 'updatedAt'>>;
// { name?: string; email?: string; }

// 表单状态（所有字段可能为 null）
type UserFormState = {
    [K in keyof CreateUserRequest]: CreateUserRequest[K] | null;
};
// { name: string | null; email: string | null; }
```

#### 映射类型总结

| 映射类型 | 效果 | Java 类比 |
|---------|------|----------|
| `keyof T` | 获取所有属性名 | 反射获取字段名 |
| `[K in keyof T]` | 遍历所有属性 | 遍历 Field[] |
| `T[K]` | 获取属性类型 | field.getType() |
| `readonly` | 添加只读 | final 修饰符 |
| `-readonly` | 移除只读 | 去掉 final |
| `?` | 添加可选 | @Nullable |
| `-?` | 移除可选 | @NotNull |

---

### 4. 条件类型 (Conditional Types)

```typescript
// 基本语法：T extends U ? X : Y
type IsString<T> = T extends string ? true : false;

type A = IsString<string>;   // true
type B = IsString<number>;   // false

// 提取类型
type ExtractArrayType<T> = T extends (infer U)[] ? U : never;

type C = ExtractArrayType<string[]>;    // string
type D = ExtractArrayType<number[]>;    // number
type E = ExtractArrayType<string>;      // never

// 内置条件类型
type Exclude<T, U> = T extends U ? never : T;
type Extract<T, U> = T extends U ? T : never;

type F = Exclude<'a' | 'b' | 'c', 'a'>;     // 'b' | 'c'
type G = Extract<'a' | 'b' | 'c', 'a' | 'd'>; // 'a'

// NonNullable
type NonNullable<T> = T extends null | undefined ? never : T;
type H = NonNullable<string | null | undefined>;  // string
```

---

### 5. 模板字面量类型

```typescript
// 字符串模板类型
type Greeting = `Hello, ${string}!`;
const g1: Greeting = 'Hello, World!';    // ✓
const g2: Greeting = 'Hi, World!';       // ✗ 错误

// 结合联合类型
type Color = 'red' | 'green' | 'blue';
type Size = 'small' | 'medium' | 'large';
type ColorSize = `${Color}-${Size}`;
// 'red-small' | 'red-medium' | 'red-large' | 'green-small' | ...

// 实用例子：CSS 属性
type CSSProperty = `${string}px` | `${string}%` | `${string}em`;
const width: CSSProperty = '100px';

// 事件处理器类型
type EventName<T extends string> = `on${Capitalize<T>}`;
type ClickEvent = EventName<'click'>;  // 'onClick'
```

---

### 6. 实战类型模式

#### API 响应类型

```typescript
// 通用 API 响应
interface ApiResponse<T> {
    code: number;
    message: string;
    data: T;
}

// 分页响应
interface PaginatedResponse<T> extends ApiResponse<T[]> {
    pagination: {
        page: number;
        pageSize: number;
        total: number;
    };
}

// 使用
async function fetchUsers(): Promise<PaginatedResponse<User>> {
    const response = await fetch('/api/users');
    return response.json();
}
```

#### 表单状态类型

```typescript
// 表单字段状态
interface FieldState<T> {
    value: T;
    error: string | null;
    touched: boolean;
}

// 整个表单的状态
type FormState<T> = {
    [K in keyof T]: FieldState<T[K]>;
};

// 使用
interface LoginForm {
    username: string;
    password: string;
}

type LoginFormState = FormState<LoginForm>;
// {
//     username: FieldState<string>;
//     password: FieldState<string>;
// }
```

#### React 组件 Props 类型

```typescript
// 基础组件 Props
interface ButtonProps {
    children: React.ReactNode;
    onClick?: () => void;
    variant?: 'primary' | 'secondary' | 'danger';
    disabled?: boolean;
}

// 继承 HTML 属性
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label: string;
    error?: string;
}

// 泛型组件 Props
interface SelectProps<T> {
    options: T[];
    value: T;
    onChange: (value: T) => void;
    getLabel: (item: T) => string;
    getValue: (item: T) => string | number;
}

function Select<T>(props: SelectProps<T>) {
    // 实现
}
```

---

### 课时 1.5 小结

| TypeScript 进阶概念 | 说明 | 常见用途 |
|-------------------|------|---------|
| 工具类型 | Partial, Pick, Omit 等 | 类型转换 |
| 类型守卫 | typeof, instanceof, is | 类型收窄 |
| 映射类型 | `[K in keyof T]` | 批量转换属性 |
| 条件类型 | `T extends U ? X : Y` | 类型逻辑判断 |
| 模板字面量 | `` `${T}` `` | 字符串类型约束 |

---

## 模块一总结

### 完成的课时

| 课时 | 主题 | 核心内容 |
|-----|------|---------|
| 1.1 | ES6+ 核心语法 | 箭头函数、解构、展开运算符、模板字符串、可选链 |
| 1.2 | 模块化系统 | import/export、动态导入、包管理 |
| 1.3 | 异步编程 | Promise、async/await、错误处理 |
| 1.4 | TypeScript 基础 | 类型注解、接口、泛型 |
| 1.5 | TypeScript 进阶 | 工具类型、类型守卫、映射类型 |

### 后端视角核心映射

| JavaScript/TypeScript | Java/Spring |
|----------------------|-------------|
| 箭头函数 | Lambda 表达式 |
| 解构赋值 | 模式匹配 |
| Promise / async-await | CompletableFuture |
| interface | DTO / 接口 |
| 泛型 | Java 泛型 |
| 模块系统 | Maven 依赖 |

### 下一步

模块二将开始讲解 React 核心概念：
- 2.1 JSX 语法
- 2.2 组件基础
- 2.3 State 状态管理
- 2.4 事件处理
- 2.5 条件与列表渲染

---

## 扩展内容：核心概念深入

以下是对话中深入讨论的内容补充。

---

### 扩展 A：组件与页面渲染

#### A.1 什么是组件

**后端类比**：组件 ≈ 可复用的模板片段 + 数据 + 逻辑

```java
// 后端 Thymeleaf 模板片段
// fragments/userCard.html
<div th:fragment="userCard(user)">
    <h3 th:text="${user.name}"></h3>
    <p th:text="${user.email}"></p>
</div>

// 在页面中复用
<div th:replace="fragments/userCard :: userCard(${user1})"></div>
<div th:replace="fragments/userCard :: userCard(${user2})"></div>
```

```tsx
// React 组件 — 同样的概念，但更强大
function UserCard({ user }: { user: User }) {
    return (
        <div>
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

#### A.2 页面渲染流程对比

**后端 SSR 流程（传统方式）**：

```
浏览器请求 → 服务器 Controller → 查询数据库 → 模板引擎渲染 → 返回完整 HTML
                                                                    ↓
                                                            浏览器显示页面
```

**前端 CSR 流程（React 默认）**：

```
浏览器请求 → 服务器返回空壳 HTML + JS 文件
                        ↓
            浏览器下载并执行 JS
                        ↓
            React 创建 Virtual DOM
                        ↓
            React 生成真实 DOM 插入页面
                        ↓
            用户看到内容（首屏完成）
                        ↓
            用户交互 → 更新 State → 重新渲染局部
```

#### A.3 组件渲染的三个阶段

用后端事务来类比：

```
后端事务:
BEGIN → 业务逻辑 → COMMIT → 数据库变更生效

React 渲染:
触发 → Render 阶段 → Commit 阶段 → DOM 变更生效
```

```tsx
function UserProfile({ userId }: { userId: string }) {
    // ========== 触发渲染的原因 ==========
    // 1. 首次挂载
    // 2. Props 变化 (userId 改变)
    // 3. State 变化 (setUser 调用)
    // 4. 父组件重渲染

    const [user, setUser] = useState<User | null>(null);

    // ========== Render 阶段 ==========
    // - 执行组件函数
    // - 生成新的 Virtual DOM
    // - 纯计算，无副作用（类似事务中的业务逻辑）

    const displayName = user?.name.toUpperCase();  // 纯计算

    // ========== Commit 阶段 ==========
    // - 在 Render 完成后执行
    // - 将变更应用到真实 DOM
    // - useEffect 在此阶段后执行

    useEffect(() => {
        // 副作用：API 调用、DOM 操作等
        fetchUser(userId).then(setUser);
    }, [userId]);

    // 返回 UI 描述（Virtual DOM）
    return (
        <div>
            <h1>{displayName}</h1>
        </div>
    );
}
```

| 阶段 | React | 后端类比 | 说明 |
|-----|-------|---------|------|
| **触发** | setState / Props 变化 | 收到请求 | 开始处理 |
| **Render** | 执行组件函数，生成 VDOM | 执行业务逻辑 | 纯计算，可中断 |
| **Commit** | 更新真实 DOM | 事务提交 | 不可中断，同步执行 |
| **Effects** | useEffect 执行 | @Async 异步任务 | DOM 更新后执行 |

#### A.4 按需渲染（Diff 算法）

**按需渲染 = 只更新真实 DOM 中发生变化的部分**

**后端类比：Hibernate 脏检查**

```java
// Hibernate 不会这样：
UPDATE users SET name=?, email=?, age=?, address=?, phone=?, ... WHERE id=?
// 全字段更新，浪费性能

// Hibernate 实际这样（脏检查后只更新变化字段）：
UPDATE users SET age=? WHERE id=?  // 只有 age 变了
```

**React 同样的思路**：

```tsx
// 状态变化前
<div className="card">
    <h1>Tom</h1>
    <p>Age: 25</p>   {/* 旧值 */}
</div>

// 状态变化后
<div className="card">
    <h1>Tom</h1>      {/* 未变 → 不操作 DOM */}
    <p>Age: 26</p>    {/* 变了 → 只更新这个文本节点 */}
</div>
```

React 只执行：
```javascript
// 实际的 DOM 操作（伪代码）
pElement.textContent = 'Age: 26';  // 只这一行
```

**Diff 过程可视化**：

```
旧 Virtual DOM                    新 Virtual DOM
     │                                 │
     ▼                                 ▼
┌─────────────┐                 ┌─────────────┐
│ div.card    │ ═══ 类型相同 ═══ │ div.card    │  ✓ 不变
├─────────────┤                 ├─────────────┤
│ h1: "Tom"   │ ═══ 内容相同 ═══ │ h1: "Tom"   │  ✓ 不变
├─────────────┤                 ├─────────────┤
│ p: "Age: 25"│ ═══ 内容不同 ═══ │ p: "Age: 26"│  ✗ 需更新
└─────────────┘                 └─────────────┘
                                      │
                                      ▼
                              只更新 p 元素的文本
```

---

### 扩展 B：useState 观察者模式原理

#### B.1 观察者模式回顾

```java
// Java 观察者模式
public interface Observer {
    void update(Object newState);
}

public class Subject {
    private List<Observer> observers = new ArrayList<>();
    private Object state;

    public void addObserver(Observer o) {
        observers.add(o);
    }

    public void setState(Object newState) {
        this.state = newState;
        notifyObservers();  // 状态变化时通知所有观察者
    }

    private void notifyObservers() {
        for (Observer o : observers) {
            o.update(state);
        }
    }
}
```

**核心机制**：状态变化 → 通知观察者 → 观察者执行更新

#### B.2 useState 的观察者模式类比

```
传统观察者:
Subject.setState() → notifyObservers() → Observer.update()

React useState:
setState() → 标记组件需要更新 → React 调度器重新渲染组件
```

| 观察者模式角色 | React 对应 |
|--------------|-----------|
| Subject (被观察者) | State |
| Observer (观察者) | 组件函数本身 |
| notify() | 触发重新渲染 |
| update() | 组件函数重新执行 |

#### B.3 简化版 useState 实现

```typescript
// ============================================
// 简化版 React 运行时 —— 理解核心原理
// ============================================

// 全局状态存储（类似 Subject 维护的状态）
let currentComponent: Component | null = null;
let hookIndex = 0;

interface Component {
    hooks: any[];           // 存储该组件的所有 hook 状态
    render: () => any;      // 组件渲染函数
    rerender: () => void;   // 触发重渲染的方法
}

// useState 的简化实现
function useState<T>(initialValue: T): [T, (newValue: T) => void] {
    const component = currentComponent!;
    const index = hookIndex++;

    // 首次渲染：初始化状态
    if (component.hooks[index] === undefined) {
        component.hooks[index] = initialValue;
    }

    // 获取当前状态
    const state = component.hooks[index] as T;

    // setState 函数 —— 这里体现观察者模式的 notify
    const setState = (newValue: T) => {
        // 1. 更新状态
        component.hooks[index] = newValue;

        // 2. 通知"观察者"（触发重渲染）—— 关键！
        component.rerender();
    };

    return [state, setState];
}

// 模拟组件挂载和渲染
function mountComponent(renderFn: () => any) {
    const component: Component = {
        hooks: [],
        render: renderFn,
        rerender: () => {
            // 重渲染逻辑
            hookIndex = 0;
            currentComponent = component;
            const output = component.render();  // 重新执行组件函数
            console.log('Rendered:', output);
            currentComponent = null;
        }
    };

    // 首次渲染
    component.rerender();
    return component;
}
```

**使用示例**：

```typescript
// 模拟一个计数器组件
function Counter() {
    const [count, setCount] = useState(0);
    const [name, setName] = useState('React');

    return {
        count,
        name,
        increment: () => setCount(count + 1),
        setName
    };
}

// 挂载组件
const counter = mountComponent(Counter);
// 输出: Rendered: { count: 0, name: 'React', ... }

// 调用 increment（触发 setState）
counter.render().increment();
// 内部: hooks[0] = 1, 然后调用 rerender()
// 输出: Rendered: { count: 1, name: 'React', ... }
```

#### B.4 完整的观察者模式流程

```
用户调用 setState(newValue)
         │
         ▼
┌─────────────────────────────────┐
│  1. 创建 Update 对象            │
│     { action: newValue }        │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  2. 将 Update 加入队列          │
│     hook.queue.push(update)     │
│     (类似事务日志)               │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  3. 标记 Fiber 需要更新         │
│     fiber.lanes |= UpdateLane   │
│     (类似脏检查标记)             │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  4. 调度更新                    │
│     scheduleUpdateOnFiber()     │
│     (进入 React 调度器)          │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  5. 调度器在合适时机执行渲染     │
│     - 同步更新：立即执行         │
│     - 并发更新：可中断、分片执行  │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  6. 处理 Update 队列            │
│     计算新状态值                 │
│     (类似事务提交)               │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  7. 重新执行组件函数            │
│     (观察者的 update 方法)       │
│     生成新的 Virtual DOM        │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  8. Diff 算法比较新旧 VDOM      │
│     (类似 Hibernate 脏检查)      │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  9. 提交变更到真实 DOM          │
│     (类似数据库写入)             │
└─────────────────────────────────┘
```

#### B.5 与后端观察者模式的对比

| 方面 | 后端观察者模式 | React useState |
|-----|--------------|----------------|
| **观察者注册** | 显式 `addObserver()` | 隐式，组件渲染时自动"订阅" |
| **通知机制** | 同步遍历观察者列表 | 异步调度，批量更新 |
| **更新粒度** | 精确通知变化的字段 | 整个组件函数重新执行 |
| **状态存储** | Subject 内部 | Fiber 节点的 Hook 链表 |
| **多观察者** | 一个 Subject 多个 Observer | 一个 State 只属于一个组件 |

**一句话总结**：`useState` 是一个隐式的观察者模式——你调用 `setState`，React 调度器负责通知组件重新渲染，你不需要手动管理订阅关系。

---

### 扩展 C：Vue vs React 深度对比

#### C.1 核心设计理念差异

| 维度 | React | Vue |
|-----|-------|-----|
| **哲学** | UI = f(state)，纯函数式 | 渐进式框架，响应式数据 |
| **数据流** | 单向数据流，不可变 | 双向绑定，可变数据 |
| **更新机制** | 手动触发 setState | 自动依赖追踪 |
| **模板** | JSX（JS 中写 HTML） | Template（HTML 中写指令） |

**后端类比**：
- **React** ≈ 函数式编程（Scala、Kotlin 风格）
- **Vue** ≈ 面向对象 + 响应式（Spring Data JPA 的实体自动追踪）

#### C.2 响应式原理对比

**React：手动触发更新**

```tsx
// React: 你必须显式调用 setState
function Counter() {
    const [count, setCount] = useState(0);

    const increment = () => {
        // ❌ 直接修改不会触发更新
        // count = count + 1;

        // ✓ 必须调用 setState
        setCount(count + 1);
    };

    return <button onClick={increment}>{count}</button>;
}
```

**后端类比**：像 JDBC 手动提交事务

```java
connection.setAutoCommit(false);
// ... 执行操作
connection.commit();  // 必须手动提交
```

**Vue：自动依赖追踪**

```vue
<script setup>
import { ref } from 'vue';

const count = ref(0);

const increment = () => {
    // ✓ 直接修改，自动触发更新
    count.value++;
};
</script>

<template>
    <button @click="increment">{{ count }}</button>
</template>
```

**后端类比**：像 Hibernate 的脏检查自动提交

```java
@Transactional
public void updateUser(Long id) {
    User user = repository.findById(id);
    user.setAge(26);  // 直接修改
    // 事务结束时自动检测变化并提交
}
```

#### C.3 更新粒度对比（性能差异核心）

```
React 更新流程:
State 变化 → 组件函数重新执行 → 生成新 VDOM → Diff → 更新 DOM
            ↑
      整个组件重新计算

Vue 更新流程:
数据变化 → 精确知道哪些组件依赖此数据 → 只更新那些组件
            ↑
      编译时建立依赖关系
```

**具体示例**：

```tsx
// React: 父组件 state 变化，所有子组件默认都重渲染
function Parent() {
    const [count, setCount] = useState(0);
    const [name, setName] = useState('Tom');

    return (
        <div>
            <Counter count={count} />     {/* count 变化时需要更新 */}
            <UserName name={name} />       {/* count 变化时也会重渲染！ */}
        </div>
    );
}

// 需要手动优化
const UserName = React.memo(({ name }) => {
    return <span>{name}</span>;
});
```

```vue
<!-- Vue: 自动精确追踪，只更新依赖的组件 -->
<template>
    <div>
        <Counter :count="count" />    <!-- count 变化时更新 -->
        <UserName :name="name" />      <!-- count 变化时不会更新 -->
    </div>
</template>

<script setup>
import { ref } from 'vue';
const count = ref(0);
const name = ref('Tom');
</script>
```

#### C.4 性能对比

| 场景 | React | Vue | 原因 |
|-----|-------|-----|------|
| **小型应用** | 相当 | 相当 | 差异不明显 |
| **大型列表** | 需优化 | 更好 | Vue 精确追踪，React 需 memo |
| **频繁更新** | 需优化 | 更好 | Vue 自动批量，React 需手动 |
| **首次渲染** | 相当 | 稍快 | Vue 模板编译优化 |
| **复杂计算** | 更好 | 相当 | React 并发模式更成熟 |

#### C.5 场景选择建议

**选择 Vue**：

| 场景 | 原因 |
|-----|------|
| 快速原型开发 | 上手简单，开箱即用 |
| 中小型项目 | 配置少，约定多 |
| 团队 HTML/CSS 背景强 | 模板语法更接近传统 |
| 需要双向绑定 | 表单密集型应用 |
| 国内项目 | 中文文档完善，社区活跃 |

**选择 React**：

| 场景 | 原因 |
|-----|------|
| 大型复杂应用 | 生态最丰富，TypeScript 支持最好 |
| 需要高度定制 | 更灵活，不受模板语法限制 |
| 跨平台 | React Native 成熟度最高 |
| 团队 JS 功底强 | JSX 就是 JS，更符合程序员思维 |
| 并发/实时场景 | 并发模式、Suspense 更成熟 |
| 海外项目/大厂 | Meta/Vercel 等大厂主推 |

#### C.6 后端工程师视角选择

| 你的背景 | 推荐 | 原因 |
|---------|-----|------|
| Java/Spring | Vue | 响应式类似 JPA，模板类似 Thymeleaf |
| Kotlin/函数式 | React | 函数式思维匹配 |
| 想学 React Native | React | 一套技术栈解决 Web + App |
| 项目已用 Vue | Vue | 保持一致 |
| 纯新项目 | 看团队 | 团队熟悉哪个用哪个 |

#### C.7 核心差异总结

| 维度 | React | Vue |
|-----|-------|-----|
| **设计模式** | 显式、大量使用 | 隐式、被框架封装 |
| **领域模型** | 贫血模型为主 | 响应式数据 |
| **状态更新** | 不可变 + setState | 可变 + 自动追踪 |
| **性能优化** | 手动（memo/useMemo） | 自动（编译优化） |
| **学习曲线** | 较陡（需理解函数式） | 较平缓 |

**一句话结论**：两者都是优秀框架，选择取决于**团队技术栈和项目需求**，而非绝对的"谁更好"。

---

### 扩展 D：前端设计模式与模型使用

#### D.1 前端设计模式用得少的原因

| 后端 Java | 前端 TypeScript | 原因 |
|----------|----------------|------|
| 大量 OOP 模式 | 函数式为主 | React 推崇函数式编程 |
| 类继承体系 | 组合优于继承 | Hooks 实现逻辑复用 |
| 显式 new 实例 | 框架管理生命周期 | React 控制组件实例化 |
| 接口 + 实现分离 | 类型 + 函数 | 无需运行时多态 |

#### D.2 前端常见的设计模式

```typescript
// 1. 工厂模式 — 创建组件或配置
function createApiClient(config: ApiConfig): ApiClient {
    return {
        get: (url) => fetch(config.baseUrl + url),
        post: (url, data) => fetch(config.baseUrl + url, {
            method: 'POST',
            body: JSON.stringify(data)
        })
    };
}

// 2. 单例模式 — 全局实例（用模块作用域代替）
// api.ts
const apiClient = createApiClient({ baseUrl: '/api' });
export default apiClient;  // 模块级单例

// 3. 策略模式 — 函数作为参数
interface SortStrategy<T> {
    (a: T, b: T): number;
}

function sortUsers(users: User[], strategy: SortStrategy<User>) {
    return [...users].sort(strategy);
}

// 使用
sortUsers(users, (a, b) => a.name.localeCompare(b.name));
sortUsers(users, (a, b) => a.age - b.age);
```

#### D.3 充血模型 vs 贫血模型

**Java 后端的充血模型**：

```java
// 充血模型：实体包含业务逻辑
public class Order {
    private List<OrderItem> items;
    private OrderStatus status;

    public void addItem(Product product, int quantity) {
        if (this.status != OrderStatus.DRAFT) {
            throw new IllegalStateException("Cannot modify confirmed order");
        }
        this.items.add(new OrderItem(product, quantity));
    }

    public Money calculateTotal() {
        return items.stream()
            .map(OrderItem::getSubtotal)
            .reduce(Money.ZERO, Money::add);
    }
}
```

**前端的贫血模型 + 函数式处理**：

```typescript
// 前端通常：纯数据类型 + 独立函数
// types.ts — 贫血模型（纯数据）
interface Order {
    id: string;
    items: OrderItem[];
    status: 'draft' | 'confirmed' | 'shipped';
}

// orderUtils.ts — 独立的纯函数
function calculateTotal(order: Order): number {
    return order.items.reduce(
        (sum, item) => sum + item.price * item.quantity,
        0
    );
}

function addItem(order: Order, item: OrderItem): Order {
    if (order.status !== 'draft') {
        throw new Error('Cannot modify confirmed order');
    }
    return {
        ...order,
        items: [...order.items, item]
    };
}
```

**为什么前端偏好贫血模型**：

| 原因 | 说明 |
|-----|------|
| 不可变性 | React 要求 state 不可变，充血模型的 mutate 方法不兼容 |
| 序列化 | 前端数据经常来自 JSON API，class 实例化有额外成本 |
| Tree Shaking | 纯函数可以被打包工具按需剔除，class 方法不行 |
| 测试简单 | 纯函数测试不需要 mock，输入输出确定 |
| 函数式范式 | React Hooks 推崇函数式，与贫血模型契合 |

**一句话总结**：前端用的是"函数式设计模式"——用函数组合代替类继承，用不可变数据代替可变状态。
