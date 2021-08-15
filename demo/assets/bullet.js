// Requires: p5.js

function setup() {
  createCanvas(100, 100);

  const g = createGraphics(16, 16);
  g.fill("#4d089a20");
  g.stroke("#4d089a");
  g.strokeWeight(1);
  g.rect(1, 1, 14, 14);

  image(g, 0, 0);
  save(g, "bullet.png");
}
