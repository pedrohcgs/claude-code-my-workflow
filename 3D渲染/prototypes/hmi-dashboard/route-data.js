// Modeled route graph (hand-authored, no image tracing)
// Coordinates are in CAD percent space: [xPercent, yPercent]

export const ROUTE_NODES = [
  { id: 1, x: 8, y: 64, label: "给煤机系统" },
  { id: 2, x: 22, y: 74, label: "#1角二次风门、油枪" },
  { id: 3, x: 49, y: 49, label: "吹灰器" },
  { id: 4, x: 44, y: 56, label: "减温水系统" },
  { id: 5, x: 81, y: 66, label: "脱硝系统" },
  { id: 6, x: 33, y: 55, label: "主给水流量测点" },
];

export const ROUTE_LINKS = [
  {
    id: "R1",
    name: "给煤机上行线",
    from: 1,
    to: 4,
    points: [
      [8, 64],
      [18, 64],
      [18, 56],
      [44, 56],
    ],
  },
  {
    id: "R2",
    name: "炉膛主干线",
    from: 4,
    to: 5,
    points: [
      [44, 56],
      [58, 56],
      [66, 62],
      [81, 66],
    ],
  },
  {
    id: "R3",
    name: "吹灰器回流线",
    from: 3,
    to: 6,
    points: [
      [49, 49],
      [42, 49],
      [36, 52],
      [33, 55],
    ],
  },
  {
    id: "R4",
    name: "减温水旁路线",
    from: 2,
    to: 3,
    points: [
      [22, 74],
      [22, 64],
      [30, 58],
      [49, 49],
    ],
  },
  {
    id: "R5",
    name: "右侧脱硝支线",
    from: 6,
    to: 5,
    points: [
      [33, 55],
      [42, 60],
      [60, 64],
      [81, 66],
    ],
  },
];

export const MINI_ROUTE_LABELS = [
  "站点1：给煤机系统",
  "站点2：#1角二次风门、油枪",
  "站点3：吹灰器",
  "站点4：减温水系统",
];
