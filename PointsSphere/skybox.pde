float p = 40000;   // half skybox size
float m = -p;

// create cube edges
PVector P000 = new PVector (m, m, m);
PVector P010 = new PVector (m, p, m);
PVector P110 = new PVector (p, p, m);
PVector P100 = new PVector (p, m, m);
PVector P001 = new PVector (m, m, p);
PVector P011 = new PVector (m, p, p);
PVector P111 = new PVector (p, p, p);
PVector P101 = new PVector (p, m, p);

PImage tex1, tex2, tex3, tex4, tex5, tex6; // texture images

// load six skybox images as cube texture
void loadSkybox(String skyboxName, String fExt) 
{ 
  //textureMode(NORMALIZED);  
  tex1 = loadImage(skyboxName + "_front" + fExt);
  tex2 = loadImage(skyboxName + "_back" + fExt);
  tex3 = loadImage(skyboxName + "_left" + fExt);
  tex4 = loadImage(skyboxName + "_right" + fExt);
  tex5 = loadImage(skyboxName + "_bottom" + fExt);
  tex6 = loadImage(skyboxName + "_top" + fExt); 
}

// Assign six texture to the six cube faces
PShape createTexturedCube() 
{
  PShape sky = createShape(GROUP); 
  sky.addChild(texturedCubeSide (P100, P000, P010, P110, tex1));   // -Z "front" face
  sky.addChild(texturedCubeSide (P001, P101, P111, P011, tex2));   // +Z "back" face
  sky.addChild(texturedCubeSide (P000, P001, P011, P010, tex3));   // -X "left" face
  sky.addChild(texturedCubeSide (P101, P100, P110, P111, tex4));   // +X "right" face
  sky.addChild(texturedCubeSide (P110, P010, P011, P111, tex5));   // +Y "base" face
  sky.addChild(texturedCubeSide (P101, P001, P000, P100, tex6));   // -Y "top" face
  return sky;
}

// create a cube side given by 4 edge vertices and a texture
//void TexturedCubeSide(PVector P1, PVector P2, PVector P3, PVector P4, Texture tex)
PShape texturedCubeSide(PVector P1, PVector P2, PVector P3, PVector P4, PImage tex)
{
  PShape sh = createShape();
  sh.beginShape(QUADS);
  sh.textureMode(NORMAL);
  sh.noStroke();
  sh.texture(tex);
  sh.vertex(P1.x, P1.y, P1.z, 1.0f, 0.0f);
  sh.vertex(P2.x, P2.y, P2.z, 0.0f, 0.0f);
  sh.vertex(P3.x, P3.y, P3.z, 0.0f, 1.0f);
  sh.vertex(P4.x, P4.y, P4.z, 1.0f, 1.0f);
  sh.endShape();
  return sh;
}

PShape createLines() {
  PShape lines = createShape();
  lines.beginShape(LINES);
  lines.strokeWeight(2);
  lines.stroke(255, 255, 255, 20);       
  for (int i = 0; i< rts.length; i++) {
    Vector3d ps = new Vector3d(rts[i]);
    lines.vertex(0.0, 0.0, 0.0);
    lines.vertex((float)ps.x, (float)ps.y, (float)ps.z);        
  }
  lines.endShape();
  return lines;  
}
