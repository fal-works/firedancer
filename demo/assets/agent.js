function setup() {
  createCanvas(100, 100);

  const g = createGraphics(48, 48);
  g.fill("#4d089a20");
  g.stroke("#4d089a");
  g.strokeWeight(2);
  g.rect(4, 4, 40, 40);

  image(g, 0, 0);
  save(g, "agent.png");
}
