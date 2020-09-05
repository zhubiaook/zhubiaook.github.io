# v-model 双向数据绑定

> `v-model` 指令监听用户输入控件的值，根据不同的控件读取相应的值来更新绑定的数据，绑定的数据也会更改控件的值。

## 参考文档
[http://www.imooc.com/wiki/vuelesson/vueforms.html](http://www.imooc.com/wiki/vuelesson/vueforms.html)
## 基本用法
### 输入框
```vue
<html lang="en">
<body>

<div id="app">
  <input v-model="name">
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: ""
      }
    }
  })
</script>
</body>
</html>
```


### 文本框
```vue
<html lang="en">
<body>

<div id="app">
  <textarea v-model="name"></textarea>
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: ""
      }
    }
  })
</script>
</body>
</html>
```


### 复选框
> 多个复选框，绑定的数据初始值设置为列表，控件输入值的变化会修改数据，绑定数据的变化也会修改控件的值

单个复选框
```vue
<html lang="en">
<body>

<div id="app">
  <input type="checkbox" v-model="name" value="one">
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: true
      }
    }
  })
</script>
</body>
</html>
```


多个复选框
```vue
<html lang="en">
<body>

<div id="app">
  <input type="checkbox" v-model="name" value="one">
  <input type="checkbox" v-model="name" value="two">
  <input type="checkbox" v-model="name" value="three">
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: []
      }
    }
  })
</script>
</body>
</html>
```


### 单选按钮
```vue
<html lang="en">
<body>

<div id="app">
  <input type="radio" v-model="name" value="one">
  <input type="radio" v-model="name" value="two">
  <input type="radio" v-model="name" value="three">
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: ""
      }
    }
  })
</script>
</body>
</html>
```


### 下拉框
```vue
<html lang="en">
<body>

<div id="app">
  <select v-model="name">
    <option>one</option>
    <option>two</option>
    <option>three</option>
  </select>
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: ""
      }
    }
  })
</script>
</body>
</html>
```




## 修饰符
> .lazy
> .number
> .trim

```vue
<html lang="en">
<body>

<div id="app">
  <!-- 去除字符串前后空格 -->
  <textarea v-model.trim="name"></textarea>
  <p>{{ name }}</p>
</div>

<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script>
  vm = new Vue({
    el : "#app",
    data() {
      return {
        name: ""
      }
    }
  })
</script>
</body>
</html>
```
