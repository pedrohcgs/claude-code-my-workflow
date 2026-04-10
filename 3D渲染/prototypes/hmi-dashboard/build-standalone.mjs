import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const indexPath = path.join(__dirname, "index.html");
const stylePath = path.join(__dirname, "styles.css");
const mapPath = path.join(__dirname, "map-trace-data.js");
const routePath = path.join(__dirname, "route-data.js");
const mainPath = path.join(__dirname, "main.js");
const deliverableDir = path.join(__dirname, "deliverable");
const outputPath = path.join(deliverableDir, "index_standalone.html");

const indexHtml = fs.readFileSync(indexPath, "utf8");
const stylesCss = fs.readFileSync(stylePath, "utf8");
const mapData = fs.readFileSync(mapPath, "utf8").replace(/^export\s+const\s+/gm, "const ");
const routeData = fs.readFileSync(routePath, "utf8").replace(/^export\s+const\s+/gm, "const ");

const mainCode = fs
  .readFileSync(mainPath, "utf8")
  .replace(/^import\s+.*$/gm, "")
  .replace(/^export\s+function\s+mountHMIDashboard/gm, "function mountHMIDashboard")
  .trim();

const moduleScript = `
  <script type="module">
import * as THREE from "https://cdn.jsdelivr.net/npm/three@0.161.0/build/three.module.js";
import { OrbitControls } from "https://cdn.jsdelivr.net/npm/three@0.161.0/examples/jsm/controls/OrbitControls.js";

${mapData}

${routeData}

${mainCode}
  </script>
`;

let standalone = indexHtml.replace(
  /<link rel="stylesheet" href="\.\/styles\.css" \/>/,
  `<style>\n${stylesCss}\n</style>`
);

standalone = standalone.replace(
  /<script type="module" src="\.\/main\.js"><\/script>/,
  moduleScript.trim()
);

fs.mkdirSync(deliverableDir, { recursive: true });
fs.writeFileSync(outputPath, standalone, "utf8");
console.log(`Generated: ${outputPath}`);
