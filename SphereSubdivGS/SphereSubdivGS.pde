// Sphere subdivision using the geometry shader.
// However, the GS shouldn't be used to perform 
// tessellation because it process the output primitives
// sequentially w/out parallelization.
//
// Useful applications of the GS
// * recalculate normals after vertex displacement
// * primitive distortion (e.g.: explode geometry along the normals)
// * normal and edge rendering
// * geometry culling
// http://renderingwonders.wordpress.com/2011/02/07/chapter-11-%E2%80%93-advanced-shader-usage-geometry-shaders/

import javax.media.opengl.GL3;
{ PJOGL.PROFILE = 3; }

PShape octa;
PShader simple;
PShader subdiv;
PShader showNormals;
float angle;
boolean useSubdiv = true;

void setup() {
  size(400, 400, P3D);

  octa = createOctahedron();

  simple = new GeometryShader(this, "PassthrouVert.glsl", "SimpleGeom.glsl", "SimpleFrag.glsl");
  subdiv = new GeometryShader(this, "PassthrouVert.glsl", "SubdivGeom.glsl", "SimpleFrag.glsl");
  showNormals = new GeometryShader(this, "PassthrouVert.glsl", "ShowNormalsGeom.glsl", "SimpleFrag.glsl");
  shader(subdiv);
}

void draw() {
  background(0);  

  pointLight(204, 204, 204, 0, 0, 200);

  translate(width/2, height/2, 0);
  
  scale(100);
  angle += 0.01;
  rotateY(angle);  
  shape(octa);
  if (useSubdiv) {
    shader(showNormals);
    shape(octa);
    shader(subdiv);
  }
}

void keyPressed() {
  useSubdiv = !useSubdiv;
  if (useSubdiv) shader(subdiv);
  else shader(simple);
}

void mouseMoved() {
  subdiv.set("level", int(map(mouseX, 0, width, 0, 4)));
  showNormals.set("level", int(map(mouseX, 0, width, 0, 4)));
}  

