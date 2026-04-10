// Modeled route graph (hand-authored, no image tracing)
// Coordinates are in CAD percent space: [xPercent, yPercent]

export const ROUTE_NODES = [
  { id: 1, x: 2, y: 52, label: "给煤机系统" },
  { id: 2, x: 30, y: 78, label: "#1角二次风门、油枪" },
  { id: 3, x: 42, y: 52, label: "吹灰器" },
  { id: 4, x: 34, y: 45, label: "减温水系统" },
  { id: 5, x: 78, y: 52, label: "脱硝系统" },
  { id: 6, x: 26, y: 52, label: "主给水流量测点" },
];

export const ROUTE_LINKS = [
  {
    id: "R1",
    name: "给煤机系统",
    from: 1,
    to: 2,
    points: [
      [2, 52],
      [2, 80],
      [30, 80],
    ],
  },
  {
    id: "R2",
    name: "#1角二次风门、油枪",
    from: 2,
    to: 3,
    points: [
      [30, 80],
      [42, 78],
      [42, 66],
      [42, 52],
    ],
  },
  {
    id: "R3",
    name: "主给水流量测点",
    to: 6,
    from: 6,
    points: [
      [26, 36],
      [26, 78],
    ],
  },
  {
    id: "R4",
    name: "减温水系统",
    from: 4,
    to: 3,
    points: [
      [34, 45],
      [34, 52],
      [42, 52],
    ],
  },
  {
    id: "R5",
    name: "#4角二次风门、油枪",
    from: 4,
    to: 3,
    points: [
      [54, 36],
      [34, 36],
      [34, 45],
    ],
  },
  {
    id: "R6",
    name: "#3角二次风门、油枪",
    to: 5,
    from: 5,
    points: [
      [78, 52],
      [78, 36],
      [54, 36],
    ],
  },
  {
    id: "R7",
    name: "吹灰器",
    from: 3,
    to: 5,
    points: [
      [42, 52],
      [42, 45],
      [66, 45],
      [66, 52],
    ],
  },
  {
    id: "R8",
    name: "吹灰器",
    from: 3,
    to: 5,
    points: [
      [42, 52],
      [42, 68],
      [66, 68],
      [66, 52],
    ],
  },
  {
    id: "R9",
    name: "#2角二次风门、油枪",
    from: 2,
    to: 5,
    points: [
      [42, 78],
      [78, 78],
    ],
  },
  {
    id: "R10",
    name: "脱硝系统",
    from: 5,
    to: 5,
    points: [
      [78, 78],
      [78, 36],
    ],
  },
];

export const ROUTE_SCENE_LABELS = [
  { text: "给煤机系统", x: 5.4, y: 60, width: 0.35, height: 1.42, vertical: true },
  { text: "主给水流量测点", x: 27.8, y: 57, width: 0.38, height: 1.88, vertical: true },
  { text: "减温水系统", x: 34.6, y: 57, width: 0.35, height: 1.48, vertical: true },
  { text: "吹灰器", x: 54, y: 42, width: 0.85, height: 0.24 },
  { text: "吹灰器", x: 54, y: 68, width: 0.85, height: 0.24 },
  { text: "炉膛", x: 55.3, y: 55, width: 0.74, height: 0.24, fontSize: 84 },
  { text: "脱硝系统", x: 79.6, y: 57, width: 0.35, height: 1.38, vertical: true },
  { text: "#1角二次风门、油枪", x: 43.4, y: 74.8, width: 1.72, height: 0.26 },
  { text: "#2角二次风门、油枪", x: 72.4, y: 74.8, width: 1.72, height: 0.26 },
  { text: "#3角二次风门、油枪", x: 72.4, y: 33.8, width: 1.72, height: 0.26 },
  { text: "#4角二次风门、油枪", x: 42.2, y: 33.8, width: 1.72, height: 0.26 },
];

export const MINI_ROUTE_LABELS = [
  "站点1：给煤机系统",
  "站点2：#1角二次风门、油枪",
  "站点3：吹灰器",
  "站点4：减温水系统",
];
