# K8S 部署策略

# 参考文档
[Kubernetes 部署策略详解-博客-阳明](https://www.qikqiak.com/post/k8s-deployment-strategies/)
[Kubernetes deployment strategies - github](https://github.com/ContainerSolutions/k8s-deployment-strategies)
# 部署策略
## 1. Recreate(重建)

![recreat.png](https://cdn.nlark.com/yuque/0/2020/png/207618/1584525784001-dd2206a1-0bc2-4637-a5ac-16a1bc44208c.png#align=left&display=inline&height=381&name=recreat.png&originHeight=381&originWidth=1192&size=52576&status=done&style=none&width=1192)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525132225-23365471-1286-43b0-b80a-084eeaeb5fb8.jpeg#align=left&display=inline&height=664&originHeight=664&originWidth=2860&size=0&status=done&style=none&width=2860)

## 2. RollingUpdate(滚动更新)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525291659-ba688576-bc7f-4588-9131-f9e285238e2e.jpeg#align=left&display=inline&height=434&originHeight=755&originWidth=1219&size=0&status=done&style=none&width=700)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525414274-37a49395-9a36-47ee-965c-90093a7d9d31.jpeg#align=left&display=inline&height=664&originHeight=664&originWidth=2856&size=0&status=done&style=none&width=2856)

## 3. Blue/Green(蓝/绿)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525535970-c591bfdb-db8b-4fee-8f49-c21a6a5ff7a7.jpeg#align=left&display=inline&height=429&originHeight=755&originWidth=1219&size=0&status=done&style=none&width=692)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525546207-e3e279ce-9bbb-45f5-ba3f-979ea94f3ecb.jpeg#align=left&display=inline&height=664&originHeight=664&originWidth=2856&size=0&status=done&style=none&width=2856)

## 4. Canary(金丝雀)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525585592-db962a03-08f9-4fd3-818e-4c4095955520.jpeg#align=left&display=inline&height=225&originHeight=385&originWidth=1219&size=0&status=done&style=none&width=712)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525592788-4453e475-0a37-4712-a0a6-88da4a0dc399.jpeg#align=left&display=inline&height=668&originHeight=668&originWidth=2862&size=0&status=done&style=none&width=2862)

## 5. A/B testing(A/B测试)
![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525679806-50289f71-5cd9-42af-bf52-556b5518cc1c.jpeg#align=left&display=inline&height=285&originHeight=397&originWidth=982&size=0&status=done&style=none&width=705)

![](https://cdn.nlark.com/yuque/0/2020/jpeg/207618/1584525689192-5e3f2810-32fc-4432-be1d-1410d85a5344.jpeg#align=left&display=inline&height=666&originHeight=666&originWidth=2856&size=0&status=done&style=none&width=2856)
