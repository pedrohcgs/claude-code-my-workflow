import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { TRACE_HEIGHT, TRACE_SEGMENTS, TRACE_WIDTH } from "./map-trace-data.js";
import { ROUTE_IMG_WIDTH, ROUTE_IMG_HEIGHT, ROUTE_PATHS, ROUTE_NODES } from "./route-data.js";

const DASHBOARD_TEMPLATE = `
  <div class="hmi-dashboard">
    <aside class="sidebar" id="sidebar">
      <header class="sidebar-brand">
        <svg class="sidebar-logo" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
        </svg>
        <div>
          <h1 class="sidebar-title">组态监控</h1>
          <p class="sidebar-subtitle">HMI Dashboard</p>
        </div>
      </header>
      <nav class="sidebar-stats">
        <div class="stat-card"><span class="stat-label">设备在线</span><span class="stat-value">124</span></div>
        <div class="stat-card"><span class="stat-label">待办告警</span><span class="stat-value stat-warn">3</span></div>
        <div class="stat-card"><span class="stat-label">今日吞吐</span><span class="stat-value">8,942</span></div>
        <div class="stat-card"><span class="stat-label">管线路段</span><span class="stat-value stat-ok" id="routeCount">—</span></div>
      </nav>
      <section class="sidebar-detail" id="detailPanel">
        <p class="detail-eyebrow">当前选中</p>
        <h2 class="detail-title" id="objectTitle">全景视图</h2>
        <p class="detail-copy" id="objectCopy">点击右侧 3D 模型中的高亮区块或管线节点，此处将显示对应说明信息。</p>
        <button class="detail-action" id="openDrawerBtn" type="button">展开对象数据</button>
      </section>
      <section class="route-map-card">
        <p class="detail-eyebrow">路线图与文字</p>
        <img class="route-map-image" src="./layer_routes.png" alt="提取后的路线图层" />
        <ul class="route-map-list" id="routeLegend"></ul>
      </section>
      <footer class="sidebar-footer"><p>Container-ready · On-Demand Rendering · ResizeObserver</p></footer>
    </aside>
    <main class="main-viewer" id="mainViewer">
      <section class="viewer-container" id="viewer">
        <canvas id="sceneCanvas"></canvas>
        <header class="viewer-hud">
          <div>
            <p class="hud-eyebrow">三维空间组态 · Route-A 管线数据叠加</p>
            <h2 class="hud-title" id="viewer-title">车间全景模型</h2>
          </div>
          <button class="hud-reset" type="button" id="resetView">恢复默认机位</button>
        </header>
        <aside class="data-drawer" id="dataDrawer" aria-live="polite" aria-label="对象详细数据">
          <header class="drawer-header">
            <div>
              <p class="detail-eyebrow">对象数据</p>
              <h3 class="drawer-title" id="drawerTitle">未选中对象</h3>
            </div>
            <button class="drawer-close" id="drawerCloseBtn" type="button">关闭</button>
          </header>
          <div class="drawer-body" id="drawerBody">
            <p class="drawer-empty">点击对象后会在这里显示更多数据。</p>
          </div>
        </aside>
        <p class="viewer-loading" id="loadingState">装载 3D 物理资产与管线数据中…</p>
      </section>
    </main>
  </div>
`;

const MAP_W = 16.16;
const MAP_D = MAP_W * (TRACE_HEIGHT / TRACE_WIDTH);

function cadPx(x, y, elev = 0.08) {
  return new THREE.Vector3(
    (x / TRACE_WIDTH - 0.5) * MAP_W,
    elev,
    (0.5 - y / TRACE_HEIGHT) * MAP_D
  );
}

function routePx(x, y, elev = 0.38) {
  return new THREE.Vector3(
    (x / ROUTE_IMG_WIDTH - 0.5) * MAP_W,
    elev,
    (0.5 - y / ROUTE_IMG_HEIGHT) * MAP_D
  );
}

function pctToWorld(px, py, elev = 0.22) {
  return cadPx((px / 100) * TRACE_WIDTH, (py / 100) * TRACE_HEIGHT, elev);
}

function solidMat(color, opacity = 0.72) {
  return new THREE.MeshStandardMaterial({
    color,
    roughness: 0.34,
    metalness: 0.12,
    transparent: true,
    opacity,
    emissive: color,
    emissiveIntensity: 0.24,
  });
}

function numberLabel(text, position, scene, options = {}) {
  const element = document.createElement("canvas");
  element.width = 128;
  element.height = 128;
  const context = element.getContext("2d");

  context.clearRect(0, 0, 128, 128);
  context.fillStyle = "rgba(0,180,216,0.84)";
  context.beginPath();
  context.arc(64, 64, 48, 0, Math.PI * 2);
  context.fill();
  context.fillStyle = "#ffffff";
  context.font = "700 52px Segoe UI, sans-serif";
  context.textAlign = "center";
  context.textBaseline = "middle";
  context.fillText(text, 64, 66);

  const texture = new THREE.CanvasTexture(element);
  texture.colorSpace = THREE.SRGBColorSpace;
  const sprite = new THREE.Sprite(
    new THREE.SpriteMaterial({
      map: texture,
      transparent: true,
      depthTest: false,
    })
  );
  sprite.position.copy(position);
  sprite.scale.set(options.width || 0.5, options.height || 0.5, 1);
  scene.add(sprite);
}

function formatNumber(value, digits = 1) {
  return Number(value).toFixed(digits);
}

function buildMetricMarkup(panelData) {
  if (!panelData) {
    return `<p class="drawer-empty">点击对象后会在这里显示更多数据。</p>`;
  }

  const metrics = panelData.metrics
    .map(
      (item) => `
      <article class="metric-card">
        <p class="metric-key">${item.label}</p>
        <p class="metric-value">${item.value}</p>
      </article>`
    )
    .join("");

  const notes = panelData.notes
    .map((text) => `<li>${text}</li>`)
    .join("");

  return `
    <section class="metric-grid">${metrics}</section>
    <ul class="drawer-list">${notes}</ul>
  `;
}

function buildLiveDataStore() {
  return {
    center: {
      temperature: 842,
      pressure: 12.4,
      flow: 100.0,
      level: 5.0,
      vibration: 0.32,
    },
    route: {
      velocity: 1.8,
      load: 72.0,
    },
  };
}

function makePanelFromLive(name, liveState) {
  if (name === "center") {
    return {
      metrics: [
        { label: "炉膛温度", value: `${formatNumber(liveState.center.temperature)} °C` },
        { label: "腔体压力", value: `${formatNumber(liveState.center.pressure, 2)} kPa` },
        { label: "瞬时流量", value: `${formatNumber(liveState.center.flow, 2)} m³/h` },
        { label: "液位高度", value: `${formatNumber(liveState.center.level, 2)} m` },
        { label: "振动值", value: `${formatNumber(liveState.center.vibration, 3)} g` },
        { label: "工况", value: "运行中" },
      ],
      notes: [
        "趋势建议：保留 30 分钟与 24 小时双窗口。",
        "异常策略：温度超 900°C 时推送告警与联锁建议。",
        "接入方式：可直接绑定 Kafka / MQTT 实时数据流。",
      ],
    };
  }

  if (name === "route") {
    return {
      metrics: [
        { label: "线路速度", value: `${formatNumber(liveState.route.velocity, 2)} m/s` },
        { label: "当前负载", value: `${formatNumber(liveState.route.load, 1)} %` },
        { label: "状态", value: "稳定" },
        { label: "数据源", value: "Route-A" },
      ],
      notes: [
        "可按路段维度聚合报警和巡检记录。",
        "可挂接维护工单与人员定位信息。",
      ],
    };
  }

  return {
    metrics: [
      { label: "状态", value: "在线" },
      { label: "最后更新", value: "刚刚" },
    ],
    notes: ["该对象暂未配置更多业务数据字段。"],
  };
}

export function mountHMIDashboard(rootOrSelector = "#hmiDashboard") {
  let root =
    typeof rootOrSelector === "string"
      ? document.querySelector(rootOrSelector)
      : rootOrSelector;

  if (!root) {
    throw new Error("mountHMIDashboard: root container not found.");
  }

  if (!root.classList.contains("hmi-dashboard")) {
    if (!root.querySelector(".hmi-dashboard")) {
      root.innerHTML = DASHBOARD_TEMPLATE;
    }
    root = root.querySelector(".hmi-dashboard");
  }

  const viewer = root.querySelector("#viewer");
  const canvas = root.querySelector("#sceneCanvas");
  const loadingEl = root.querySelector("#loadingState");
  const titleEl = root.querySelector("#objectTitle");
  const copyEl = root.querySelector("#objectCopy");
  const resetBtn = root.querySelector("#resetView");
  const routeCountEl = root.querySelector("#routeCount");
  const routeLegendEl = root.querySelector("#routeLegend");
  const openDrawerBtn = root.querySelector("#openDrawerBtn");
  const dataDrawer = root.querySelector("#dataDrawer");
  const drawerTitleEl = root.querySelector("#drawerTitle");
  const drawerBodyEl = root.querySelector("#drawerBody");
  const drawerCloseBtn = root.querySelector("#drawerCloseBtn");

  if (!viewer || !canvas || !loadingEl || !titleEl || !copyEl || !resetBtn) {
    throw new Error("mountHMIDashboard: required dashboard elements are missing.");
  }

  const renderer = new THREE.WebGLRenderer({
    canvas,
    antialias: true,
    alpha: true,
    preserveDrawingBuffer: true,
  });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.shadowMap.enabled = false;
  renderer.setClearColor(0x181f2a, 1);

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x181f2a);
  scene.fog = new THREE.Fog(0x181f2a, 22, 42);

  const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 90);
  const defaultPos = new THREE.Vector3(6.5, 8.7, 8.4);
  const defaultTarget = new THREE.Vector3(0, 0.08, -0.2);
  camera.position.copy(defaultPos);
  camera.lookAt(defaultTarget);

  const controls = new OrbitControls(camera, renderer.domElement);
  controls.target.copy(defaultTarget);
  controls.enableDamping = false;
  controls.enablePan = true;
  controls.enableRotate = true;
  controls.enableZoom = true;
  controls.screenSpacePanning = true;
  controls.minDistance = 4.6;
  controls.maxDistance = 30;
  controls.minPolarAngle = 0.18;
  controls.maxPolarAngle = Math.PI * 0.49;
  controls.update();

  let renderRequested = false;
  function render() {
    renderRequested = false;
    renderer.render(scene, camera);
  }
  function invalidate() {
    if (!renderRequested) {
      renderRequested = true;
      requestAnimationFrame(render);
    }
  }

  scene.add(new THREE.HemisphereLight(0xc8d8e8, 0x1a1e24, 1.8));
  const keyLight = new THREE.DirectionalLight(0xffffff, 2.4);
  keyLight.position.set(4.8, 9.5, 5.8);
  scene.add(keyLight);
  const fillLight = new THREE.DirectionalLight(0xdff8ff, 0.8);
  fillLight.position.set(-6, 4, -3);
  scene.add(fillLight);

  const clickables = [];
  const liveState = buildLiveDataStore();

  function registerClickable(mesh, title, copy, panelKey = "default") {
    mesh.userData.title = title;
    mesh.userData.copy = copy;
    mesh.userData.panelKey = panelKey;
    clickables.push(mesh);
    scene.add(mesh);
    return mesh;
  }

  function buildLinework(elev, color, opacity) {
    const vertices = new Float32Array(TRACE_SEGMENTS.length * 6);
    TRACE_SEGMENTS.forEach(([x1, y1, x2, y2], index) => {
      const a = cadPx(x1, y1, elev);
      const b = cadPx(x2, y2, elev);
      const offset = index * 6;
      vertices[offset] = a.x;
      vertices[offset + 1] = a.y;
      vertices[offset + 2] = a.z;
      vertices[offset + 3] = b.x;
      vertices[offset + 4] = b.y;
      vertices[offset + 5] = b.z;
    });

    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute("position", new THREE.BufferAttribute(vertices, 3));
    scene.add(
      new THREE.LineSegments(
        geometry,
        new THREE.LineBasicMaterial({
          color,
          transparent: true,
          opacity,
        })
      )
    );
  }

  const routeLineMat = new THREE.MeshStandardMaterial({
    color: 0x0077b6,
    roughness: 0.28,
    metalness: 0.35,
    transparent: true,
    opacity: 0.82,
    emissive: 0x0077b6,
    emissiveIntensity: 0.55,
  });

  const routeNodeMat = new THREE.MeshStandardMaterial({
    color: 0x00b4d8,
    roughness: 0.2,
    metalness: 0.4,
    transparent: true,
    opacity: 0.88,
    emissive: 0x00b4d8,
    emissiveIntensity: 0.6,
  });

  function buildRouteTextureLayer() {
    const loader = new THREE.TextureLoader();
    loader.load("./layer_routes.png", (texture) => {
      texture.colorSpace = THREE.SRGBColorSpace;
      const routeLayer = new THREE.Mesh(
        new THREE.PlaneGeometry(MAP_W, MAP_D),
        new THREE.MeshBasicMaterial({
          map: texture,
          transparent: true,
          opacity: 0.25,
          depthWrite: false,
        })
      );
      routeLayer.rotation.x = -Math.PI / 2;
      routeLayer.position.y = 0.096;
      scene.add(routeLayer);
      invalidate();
    });
  }

  function buildRouteTubes() {
    let count = 0;
    ROUTE_PATHS.filter((path) => path.length >= 3).forEach((path) => {
      const worldPoints = path.map(([x, y]) => routePx(x, y, 0.38));
      const xs = worldPoints.map((point) => point.x);
      const zs = worldPoints.map((point) => point.z);
      const span = Math.max(
        Math.max(...xs) - Math.min(...xs),
        Math.max(...zs) - Math.min(...zs)
      );
      if (span < 0.3) {
        return;
      }

      try {
        const curve = new THREE.CatmullRomCurve3(worldPoints, false, "catmullrom", 0.3);
        const geometry = new THREE.TubeGeometry(
          curve,
          Math.max(24, path.length * 4),
          0.032,
          8,
          false
        );
        const tube = new THREE.Mesh(geometry, routeLineMat.clone());
        tube.userData.haloSize = 0.8;
        registerClickable(
          tube,
          `管线路段 #${count + 1}`,
          `该路段由 ${path.length} 个控制点生成，覆盖跨度 ${span.toFixed(1)}m。`,
          "route"
        );
        count += 1;
      } catch {
        // Skip degenerate curves.
      }
    });
    return count;
  }

  function buildRouteNodes() {
    ROUTE_NODES.forEach(([id, px, py, label]) => {
      const node = new THREE.Mesh(
        new THREE.CylinderGeometry(0.18, 0.18, 0.5, 32),
        routeNodeMat.clone()
      );
      const position = routePx(px, py, 0);
      node.position.set(position.x, 0.33, position.z);
      node.userData.haloSize = 0.45;
      registerClickable(
        node,
        `站点 ${id} · ${label}`,
        `编号 ${id}，归属区域：${label}。`,
        "route"
      );
      numberLabel(String(id), routePx(px, py, 0.75), scene, {
        width: 0.4,
        height: 0.4,
      });
    });
  }

  function addZone({ x, y, w, d, h, color, title, copy, rot = 0, panelKey = "default" }) {
    const mesh = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), solidMat(color));
    const point = pctToWorld(x, y, 0);
    mesh.position.set(point.x, h / 2 + 0.12, point.z);
    mesh.rotation.y = rot;
    mesh.userData.haloSize = Math.max(w, d) * 0.64;
    registerClickable(mesh, title, copy, panelKey);
  }

  function addNode({ x, y, r, color, title, copy, panelKey = "default" }) {
    const mesh = new THREE.Mesh(
      new THREE.CylinderGeometry(r, r, 0.46, 36),
      solidMat(color, 0.84)
    );
    const point = pctToWorld(x, y, 0);
    mesh.position.set(point.x, 0.34, point.z);
    mesh.userData.haloSize = r * 1.8;
    registerClickable(mesh, title, copy, panelKey);
  }

  const floor = new THREE.Mesh(
    new THREE.BoxGeometry(MAP_W, 0.1, MAP_D),
    new THREE.MeshStandardMaterial({
      color: 0x0d1117,
      roughness: 0.76,
      metalness: 0.02,
    })
  );
  floor.position.y = -0.03;
  scene.add(floor);

  const edge = new THREE.Mesh(
    new THREE.BoxGeometry(MAP_W + 0.08, 0.16, MAP_D + 0.08),
    new THREE.MeshStandardMaterial({
      color: 0x00b4d8,
      roughness: 0.62,
      transparent: true,
      opacity: 0.06,
    })
  );
  edge.position.y = -0.13;
  scene.add(edge);

  buildLinework(0.08, 0x3a4248, 0.25);
  buildLinework(0.145, 0x8b9298, 0.65);
  buildRouteTextureLayer();
  const routeCount = buildRouteTubes();
  buildRouteNodes();

  addZone({
    x: 55,
    y: 49,
    w: 3.1,
    d: 1.05,
    h: 0.38,
    color: 0x00a7c8,
    title: "中心结构区 (炉膛)",
    copy: "此高亮块对齐原图中央炉膛结构。点击后可查看多维运行指标。",
    panelKey: "center",
  });

  addZone({
    x: 21,
    y: 72,
    w: 1.55,
    d: 0.55,
    h: 0.32,
    color: 0x2c9b68,
    title: "左侧构件区",
    copy: "对应原图左侧重复构件位置，可继续补充热点。",
  });

  addNode({
    x: 89,
    y: 66,
    r: 0.24,
    color: 0xd94a22,
    title: "右侧标注点",
    copy: "设备点位位于原图右侧标注和尺寸线附近。",
  });

  if (routeCountEl) {
    routeCountEl.textContent = String(routeCount);
  }
  if (routeLegendEl) {
    routeLegendEl.innerHTML = ROUTE_NODES.slice(0, 4)
      .map((node) => `<li>站点 ${node[0]}：${node[3]}</li>`)
      .join("");
  }
  loadingEl.classList.add("is-hidden");

  const halo = new THREE.Mesh(
    new THREE.TorusGeometry(1, 0.015, 12, 96),
    new THREE.MeshBasicMaterial({
      color: 0x00b4d8,
      transparent: true,
      opacity: 0.9,
    })
  );
  halo.rotation.x = Math.PI / 2;
  halo.position.y = 0.16;
  halo.visible = false;
  scene.add(halo);

  let activeObj = clickables[0] || null;
  let drawerOpen = false;

  function openDrawer() {
    if (!dataDrawer) {
      return;
    }
    dataDrawer.classList.add("is-open");
    drawerOpen = true;
  }

  function closeDrawer() {
    if (!dataDrawer) {
      return;
    }
    dataDrawer.classList.remove("is-open");
    drawerOpen = false;
  }

  function renderDrawer(obj) {
    if (!drawerBodyEl || !drawerTitleEl || !obj) {
      return;
    }
    const panelKey = obj.userData.panelKey || "default";
    const panelData = makePanelFromLive(panelKey, liveState);
    drawerTitleEl.textContent = obj.userData.title;
    drawerBodyEl.innerHTML = buildMetricMarkup(panelData);
  }

  function selectObj(obj, openPanel = true) {
    activeObj = obj;
    titleEl.textContent = obj.userData.title;
    copyEl.textContent = obj.userData.copy;

    clickables.forEach((mesh) => {
      mesh.material.opacity = mesh === obj ? 0.92 : 0.54;
      mesh.material.emissiveIntensity = mesh === obj ? 0.65 : 0.2;
    });

    const box = new THREE.Box3().setFromObject(obj);
    const center = box.getCenter(new THREE.Vector3());
    halo.position.set(center.x, 0.18, center.z);
    halo.scale.setScalar(obj.userData.haloSize || 1);
    halo.visible = true;
    renderDrawer(obj);
    if (openPanel) {
      openDrawer();
    }
    invalidate();
  }

  if (activeObj) {
    selectObj(activeObj, false);
  }

  const raycaster = new THREE.Raycaster();
  const pointer = new THREE.Vector2();
  let pressState = null;

  function updatePointer(event) {
    const bounds = canvas.getBoundingClientRect();
    pointer.x = ((event.clientX - bounds.left) / bounds.width) * 2 - 1;
    pointer.y = -((event.clientY - bounds.top) / bounds.height) * 2 + 1;
  }

  canvas.addEventListener("pointermove", (event) => {
    updatePointer(event);
    raycaster.setFromCamera(pointer, camera);
    const hit = raycaster.intersectObjects(clickables, false)[0];
    canvas.style.cursor = hit ? "pointer" : "default";
  });

  canvas.addEventListener("pointerdown", (event) => {
    updatePointer(event);
    raycaster.setFromCamera(pointer, camera);
    const hit = raycaster.intersectObjects(clickables, false)[0];
    pressState = {
      x: event.clientX,
      y: event.clientY,
      obj: hit?.object || null,
    };
  });

  canvas.addEventListener("pointerup", (event) => {
    if (!pressState?.obj) {
      pressState = null;
      return;
    }
    const moved = Math.hypot(event.clientX - pressState.x, event.clientY - pressState.y) > 6;
    if (!moved) {
      selectObj(pressState.obj, true);
    }
    pressState = null;
  });

  canvas.addEventListener("pointercancel", () => {
    pressState = null;
  });

  resetBtn.addEventListener("click", () => {
    camera.position.copy(defaultPos);
    controls.target.copy(defaultTarget);
    controls.update();
    invalidate();
  });

  if (openDrawerBtn) {
    openDrawerBtn.addEventListener("click", () => {
      if (!activeObj) {
        return;
      }
      renderDrawer(activeObj);
      openDrawer();
    });
  }
  if (drawerCloseBtn) {
    drawerCloseBtn.addEventListener("click", closeDrawer);
  }

  function resize() {
    const rect = viewer.getBoundingClientRect();
    const width = Math.floor(rect.width || viewer.clientWidth || canvas.clientWidth);
    const height = Math.floor(rect.height || viewer.clientHeight || canvas.clientHeight);
    if (width < 10 || height < 10) {
      return false;
    }
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setSize(width, height);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    return true;
  }

  controls.addEventListener("change", invalidate);

  const observer = new ResizeObserver(() => {
    resize();
    invalidate();
  });
  observer.observe(viewer);

  const liveTimer = window.setInterval(() => {
    liveState.center.temperature += Math.random() * 5 - 2.5;
    liveState.center.pressure += Math.random() * 0.12 - 0.06;
    liveState.center.flow += Math.random() * 1.6 - 0.8;
    liveState.center.level += Math.random() * 0.05 - 0.025;
    liveState.center.vibration += Math.random() * 0.02 - 0.01;
    liveState.route.velocity += Math.random() * 0.08 - 0.04;
    liveState.route.load += Math.random() * 1.1 - 0.55;

    if (drawerOpen && activeObj) {
      renderDrawer(activeObj);
    }
  }, 1800);

  function ensureInitialSize(attempt = 0) {
    const sized = resize();
    renderer.render(scene, camera);
    if ((!sized || canvas.width <= 300) && attempt < 16) {
      window.requestAnimationFrame(() => ensureInitialSize(attempt + 1));
    }
  }

  ensureInitialSize(0);
  window.setTimeout(() => ensureInitialSize(0), 260);
  window.addEventListener("load", () => ensureInitialSize(0), { once: true });

  return {
    resize: () => {
      resize();
      invalidate();
    },
    destroy: () => {
      observer.disconnect();
      window.clearInterval(liveTimer);
      controls.dispose();
      renderer.dispose();
    },
    openDrawer,
    closeDrawer,
    selectCenter: () => {
      const centerObject = clickables.find((item) => item.userData.panelKey === "center");
      if (centerObject) {
        selectObj(centerObject, true);
      }
    },
  };
}

if (document.querySelector("#hmiDashboard")) {
  window.hmiDashboard = mountHMIDashboard("#hmiDashboard");
}
