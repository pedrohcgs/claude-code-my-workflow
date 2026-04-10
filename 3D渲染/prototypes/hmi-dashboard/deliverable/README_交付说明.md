# HMI Dashboard 交付包

## 目录内容

- `index_standalone.html`：单文件可交付版本（可直接发给别人）

## 使用方式

1. 直接双击 `index_standalone.html` 打开；或拖进浏览器打开。  
2. 需要联网（页面会从 CDN 拉取 Three.js）。  
3. 鼠标操作：左键旋转、滚轮缩放、右键平移。  
4. 点击模型里的高亮对象（例如中心结构区）可弹出数据信息。

## 这版已包含

1. 路线图和文字（左侧缩略图 + 右侧 3D 场景中的路线高亮与标签）  
2. 可容器化挂载的同源代码能力（`mountHMIDashboard`）  
3. 基础交互链路（点击对象 -> 数据抽屉显示指标与说明）

## 备注

- 如果你后续更新了源代码，请在项目根目录执行：

```bash
node 3D渲染/prototypes/hmi-dashboard/build-standalone.mjs
```

重新生成最新 `index_standalone.html` 后，再覆盖本目录中的文件即可。
