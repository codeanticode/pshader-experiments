// Use of custom vertex attributes.
// Inspired by 
// http://pyopengl.sourceforge.net/context/tutorials/shader_4.html

PShader sh;
PShape grid;

void setup() {
  size(640, 360, P3D);
  sh = loadShader("frag.glsl", "vert.glsl");
  shader(sh);
  grid = createShape();
  grid.beginShape(QUADS);
  grid.noStroke();  
  grid.fill(150);  
  float d = 10;
  for (int x = -width; x < width; x += d) {
    for (int y = -width; y < width; y += d) {
      for (int i = 0; i <= 1; i++) {
        for (int j = 0; j <= 1; j++) {
          int ij = j * (1-i) + 1 - i*j; // invert j when i is 1
          float n = noise(x + d * ij, y + d * i);
          grid.fill(255 * n);
          grid.attribPosition("tweened", x + d * ij, y + d * i, 100 * n);
          grid.vertex(x + d * ij, y + d * i, 0);
        }
      }
    }
  }
  grid.endShape();  
}

void draw() {
  background(255);  
  sh.set("tween", map(mouseX, 0, width, 0, 1));  
  translate(width/2, height/2, 0);
  rotateX(frameCount * 0.01);
  rotateY(frameCount * 0.01);  
  shape(grid);
}