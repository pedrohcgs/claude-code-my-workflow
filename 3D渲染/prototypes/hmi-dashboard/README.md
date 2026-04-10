# HMI Dashboard（Three.js）

这个原型已覆盖三件事：
- 路线图和文字说明：左侧加入路线图缩略图 + 站点文字列表，3D 场景中叠加路线纹理层与线路管道。
- Container 接入：提供 `mountHMIDashboard(container)`，可直接挂到任意容器。
- 更强交互：点击对象（如“中心结构区”）会弹出数据抽屉，展示多字段指标与说明，且支持实时更新。

## 1) 本地直接打开

在当前目录下启动静态服务后访问：
`http://127.0.0.1:8787/prototypes/hmi-dashboard/index.html`

## 2) 装进 container

在你的页面放一个容器：

```html
<div id="myHmiContainer" style="width: 1200px; height: 760px;"></div>
<script type="module">
  import { mountHMIDashboard } from "./main.js";
  const app = mountHMIDashboard(document.getElementById("myHmiContainer"));
  // app.resize(); app.destroy(); app.selectCenter();
</script>
```

说明：
- `mountHMIDashboard` 支持传入空容器，会自动注入 dashboard 结构并初始化 Three.js。
- `ResizeObserver` 已内置，容器尺寸变化会自动重绘。

## 3) 点击后弹出多数据（实现建议）

当前实现：
- 每个可点击对象携带 `panelKey`。
- 点击后更新侧栏摘要 + 右侧数据抽屉。
- 抽屉内容由 `makePanelFromLive(panelKey, liveState)` 生成，支持指标卡和说明列表。
- 定时器模拟实时数据，后续可替换成 WebSocket / SSE。

建议下一步：
1. 把 `liveState` 替换为后端实时流（WebSocket）。
2. 在 `panelKey` 上做配置化映射（例如从 API 返回字段定义）。
3. 抽屉里增加趋势小图（近 30 分钟 / 24 小时）。

## 4) Git 版本管理建议（按你这次任务）

```bash
git status
git add 3D渲染/prototypes/hmi-dashboard
git commit -m "feat(hmi-dashboard): add route layer, container mount API, and interactive data drawer"
```

推荐节奏：
1. 每完成一个子目标就 commit（UI、交互、容器化分开）。
2. commit message 用 `feat/fix/refactor/docs` 前缀。
3. 关键 demo 截图与验证结论写进 PR 描述。
