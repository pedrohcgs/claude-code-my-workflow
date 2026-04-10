# HMI Dashboard（Three.js）

## 快速说明：给别人电脑直接打开

你现在有两种形式：

1. 多文件开发版：`index.html + styles.css + main.js + map-trace-data.js + route-data.js`
2. 单文件交付版：`deliverable/index_standalone.html`

已经整理好的交付目录：
`3D渲染/prototypes/hmi-dashboard/deliverable/`

它是由下面命令生成的：

```bash
node 3D渲染/prototypes/hmi-dashboard/build-standalone.mjs
```

注意：`index_standalone.html` 仍会从 CDN 加载 Three.js，所以目标电脑需要联网。

## 1）把路线图和文字也加上去

当前实现里有两层：

1. 左侧路线缩略图（HTML/SVG）
2. 右侧 3D 场景中的路线管道和文字标签（Three.js）

对应文件：
- 路线点位和线路：`route-data.js`
- 3D 构建逻辑：`main.js`（`buildRouteTubes` / `buildRouteNodes` / `routeTag`）

你后续如果要改路线，只改 `route-data.js` 的节点和 points 即可，不需要改渲染框架。

## 2）怎么把这个东西装进 container

项目已经暴露了挂载函数 `mountHMIDashboard(container)`，直接塞进任意容器：

```html
<div id="myHmiContainer" style="width: 1200px; height: 760px;"></div>
<script type="module">
  import { mountHMIDashboard } from "./main.js";
  const app = mountHMIDashboard(document.getElementById("myHmiContainer"));
  // 可选：app.resize(); app.destroy(); app.selectCenter();
</script>
```

实现细节：
- `mountHMIDashboard` 会在容器内注入 dashboard DOM；
- 内置 `ResizeObserver`，容器尺寸变化会自动重绘；
- 返回实例可用于后续销毁、重置、聚焦中心对象。

## 3）未来更 interactive：点【中心结构区】弹出更多数据怎么做

当前已经有基础链路：

1. 每个可点击对象有 `panelKey`（如 `center`）
2. 点击后触发选中逻辑
3. 抽屉通过 `makePanelFromLive(panelKey, liveState)` 渲染指标和说明

建议按下面落地成生产方案：

1. 数据源改为后端接口/流
   - HTTP 拉基础信息
   - WebSocket/SSE 推实时指标

2. 面板字段配置化
   - 建一个 `panelSchema`（字段名、单位、阈值、格式）
   - UI 按 schema 渲染，不把字段写死在函数里

3. 交互升级
   - 对象 hover 高亮 + tooltip
   - 点击后抽屉分 tab（实时/历史/告警/维护）
   - 增加趋势图（30 分钟、24 小时）

4. 稳定性
   - 对每个 panelKey 做兜底空态
   - 数据异常时提示“最后更新时间”和数据质量状态

## 文件清单

- `index.html`：开发入口（多文件）
- `index_standalone.html`：单文件交付入口
- `build-standalone.mjs`：生成单文件脚本
- `main.js`：Three.js 主逻辑和 container 挂载
- `route-data.js`：路线拓扑数据
- `map-trace-data.js`：底图线稿数据
- `styles.css`：界面样式
