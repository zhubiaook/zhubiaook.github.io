# v-on 事件处理

> 可以用 `v-on` 指令监听DOM事件，当事件触发时，执行JavaScript代码



## 参考文档
[http://www.imooc.com/wiki/vuelesson/vueevents.html](http://www.imooc.com/wiki/vuelesson/vueevents.html)
## 基本使用
### JS直接写在模板中
```vue
<html>
<body>
  <div id="app">
    <div>
      <!-- JS代码直接写在模板中 -->
      <button v-on:click="count += 1">click</button>
      数量: {{ count }}
    </div>
  </div>

  <script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
  <script>
    vm = new Vue({
      el: "#app",
      data() {
        return {
          count: 0
        }
      }
    })
  </script>
</body>
</html>
```


### 不带参数方法
```vue
<html>
<body>
  <div id="app">
    <div>
      <!-- 使用方法 -->
      <button v-on:click="add">click</button>
      数量: {{ count }}
    </div>
  </div>

  <script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
  <script>
    vm = new Vue({
      el: "#app",
      data() {
        return {
          count: 0
        }
      },
      
      methods: {
        add() {
          this.count += 1;
        }
      },
    })
  </script>
</body>
</html>
```


### 带参数方法
```vue
<html>
<body>
  <div id="app">
    <div>
      <!-- 使用方法 -->
      <button v-on:click="add(10)">click</button>
      数量: {{ count }}
    </div>
  </div>

  <script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
  <script>
    vm = new Vue({
      el: "#app",
      data() {
        return {
          count: 0
        }
      },
      
      methods: {
        add(num) {
          this.count += num;
        }
      },
    })
  </script>
</body>
</html>
```


### 传送event事件
```vue
<html>
<body>
  <div id="app">
    <div>
      <!-- 使用方法 -->
      <button v-on:click="add(10, $event)">click</button>
      数量: {{ count }}
    </div>
  </div>

  <script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
  <script>
    vm = new Vue({
      el: "#app",
      data() {
        return {
          count: 0
        }
      },
      
      methods: {
        add(num, event) {
          this.count += num;
          console.log(event)
        }
      },
    })
  </script>
</body>
</html>
```


## 事件修饰符
> 1. .stop: 阻止单击事件继续传播；
> 1. .prevent: 只有修饰符，提交事件不再重载页面。
> 1. .capture: 添加事件监听器时使用事件捕获模式，即元素自身触发的事件先在自身处理，然后交由内部元素进行处理；
> 1. .self: 只有在event.target是当前元素自身时触发处理函数，即事件不是从内部元素触发的；
> 1. .once: 点击事件将只触发一次
> 1. .passive: 滚动事件会立即触发，不会等待其他串联事件。即prevent会失效。

```vue
<!DOCTYPE html>
  <html lang="en">
  <head>
  </head>

  <body>
    <div id="app">
      <!-- stop 案例 -->
      <div @click="clickTargetContainer">
        <button @click.stop="clickTargetA">点我 stop 案例</button>
        <button @click="clickTargetA">点我 无 stop 修饰</button>
      </div>

      <!-- submit.prevent 案例 -->
      <form method="get" action="/" @submit.prevent="submit">
        <button type="submit">点我提交表单</button>
      </form>

      <form method="get" action="https://www.baidu.com" @submit="submit">
        <button type="submit">点我提交表单</button>
      </form>

      <!-- capture 案例 -->
      <div v-on:click.capture="capture">
        <button @click.stop="clickTargetA">点我 capture 案例</button>
      </div>

      <!-- self 案例 -->
      <div @click.self="clickTargetContainer" style="padding: 20px;border: 1px solid #cccccc;">
        <button @click="clickTargetA">点我 self 案例</button>
      </div>

      <!-- once 案例 -->
      <div>
        <button @click.once="clickTargetA">点我 once 案例</button>
      </div>

    </div>
  </body>
  <script src="https://unpkg.com/vue/dist/vue.js"></script>
  <script>
    var vm = new Vue({
      el: '#app',
      methods: {
        clickTargetContainer() {
          alert('父级容器点击事件触发')
        },
        clickTargetA() {
          alert('按钮标签点击事件触发')
        },
        submit() {
          alert('提交表单了')
        },
        capture() {
          alert('虽然你点击的是内部元素，但是我先触发！')
        }
      }
    })
  </script>
</html>
```
## 按键修饰符
> 1. .enter: 回车键；
> 1. .tab: TAB键；
> 1. .delete: 删除和退格键；
> 1. .esc: 只有在event.终止键；
> 1. .space: 删除键；
> 1. .up: 上方向键：
> 1. .down: 下方向键：
> 1. .left: 左方向键：
> 1. .right: 右方向键：



```vue
<html>
<body>
  <div id="app">
    <div>
      <button @keyup.enter="clickA">enter</button>
    </div>
  </div>

  <script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
  <script>
    vm = new Vue({
      el: "#app",
      methods: {
        clickA() {
          alert("hello")
        }
      },
    })
  </script>
</body>
</html>
```


## 系统按键修饰符
> 1. .ctrl:
> 1. .alt:
> 1. .shift:
> 1. .meta: 在 Mac 系统键盘上，meta 对应 command 键 (⌘)。在 Windows 系统键盘 meta 对应 Windows 徽标键 (⊞)



```vue
<html>
<body>
  <div id="app">
    <div>
      <button @click.ctrl="clickA">enter</button>
    </div>
  </div>

  <script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
  <script>
    vm = new Vue({
      el: "#app",
      methods: {
        clickA() {
          alert("hello")
        }
      },
    })
  </script>
</body>
</html>
```


