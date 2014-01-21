// Issue 11: https://github.com/processing/processing/issues/11
import processing.glw.*;
 
import processing.opengl.PGraphicsOpenGL;
import javax.media.opengl.GL2;
import javax.vecmath.Point3d;
import javax.vecmath.Vector3d;
import java.lang.Math;
import java.nio.*;

import com.jogamp.opengl.util.texture.Texture;
import com.jogamp.opengl.util.texture.TextureIO;
import com.jogamp.opengl.util.texture.awt.AWTTextureIO;

String skyboxName = "besiege";   

public final int[] nodes_vbo = new int[1];
public int vnodelength;

GLSLshader shader;
PGraphicsOpenGL pgl;
GL2 gl;
Texture particleImg, ringImg;
Geodesic rt;
Point3d[] rts;
boolean growcomplete = false;
//int radius = 30;
int radius = 15;
//int nodecount = 30252;
int nodecount = 30252 * 2;
//float pointSize = 200;
float pointSize = 400;
PShape skybox;
PShape lines;

boolean showskybox = true;
boolean showpoints = true;
boolean showlines = false;
boolean showfps = false;

PGraphics pg;

void setup() {
  size(100, 100, GLW.RENDERER);
  pg = createGraphics(2560, 1440, GLW.P3D);
  pg.beginDraw();
  pg.hint(DISABLE_DEPTH_TEST);
  pg.endDraw();
  GLW.createWindow(pg);
  
  
  
  pg.beginDraw();
  float fov = PI/3.0;
  float cameraZ = (pg.height/2.0) / tan(fov/2.0);
  pg.perspective(fov, (float(pg.width)/float(pg.height)), cameraZ/10.0, cameraZ*500);
  //float distance = nodecount/11;
  float distance = nodecount/15;
  pg.camera(distance, distance, distance / tan(PI*30.0 / 180.0), pg.width/2.0, pg.height/2.0, 0, 0, 1, 0);
  
  rt = new Geodesic(nodecount);
  rts = rt.getPointList();
  
  loadSkybox(skyboxName, ".png");  
  skybox = createTexturedCube();  

  PJOGL pgl = (PJOGL)pg.beginPGL();
  gl = pgl.gl.getGL2();
  initShaders(gl);
  initNodes(gl);
  try {
    particleImg = AWTTextureIO.newTexture(new File(dataPath("particle.png")), true);
    ringImg = AWTTextureIO.newTexture(new File(dataPath("select.png")), true);
    particleImg.setTexParameteri( gl, GL2.GL_TEXTURE_MIN_FILTER, GL2.GL_LINEAR_MIPMAP_LINEAR );
    particleImg.setTexParameteri( gl, GL2.GL_TEXTURE_MAG_FILTER, GL2.GL_LINEAR );
    ringImg.setTexParameteri( gl, GL2.GL_TEXTURE_MIN_FILTER, GL2.GL_LINEAR_MIPMAP_LINEAR );
    ringImg.setTexParameteri( gl, GL2.GL_TEXTURE_MAG_FILTER, GL2.GL_LINEAR ); 
  }
  catch (IOException e) {    
    println("Texture file (particle.png) is missing");
    exit();  // or handle it some other way
  }

  gl.glPointParameterf(GL2.GL_POINT_SIZE_MAX, 1000.0f);
  gl.glPointParameterf(GL2.GL_POINT_SIZE_MIN, 0.0f );
  gl.glPointParameterf( GL2.GL_POINT_FADE_THRESHOLD_SIZE, 60.0f );
  gl.glTexEnvi(GL2.GL_POINT_SPRITE, GL2.GL_COORD_REPLACE, GL2.GL_TRUE);
  gl.glEnable(GL2.GL_BLEND);
  pg.endPGL();
  pg.endDraw();
}

float rtx = 0;
void draw() {
  pg.beginDraw();  
  pg.background(0);
  if (frameCount % 30 == 0 && showfps) {
    println(frameRate);
  }

  pg.translate(pg.width/2, pg.height/2, 50);
  rtx += .003;
  pg.rotateY(rtx);
  
  if (showskybox) {
    pg.shape(skybox);
  }
  
  if (showpoints) {
    PJOGL pgl = (PJOGL)pg.beginPGL();
    gl = pgl.gl.getGL2();
  
    gl.glBlendFunc(GL2.GL_SRC_ALPHA, GL2.GL_ONE);
  
    gl.glDisable(GL2.GL_POINT_SMOOTH);
    gl.glEnable(GL2.GL_POINT_SPRITE);
    gl.glEnableClientState(GL2.GL_VERTEX_ARRAY);
    gl.glEnable(GL2.GL_VERTEX_PROGRAM_POINT_SIZE_ARB);

    gl.glColor3f(1, 1, 1);
    shader.startShader(gl);

    particleImg.bind(gl);
    particleImg.enable(gl);

    gl.glUniform1f(shader.getUniformLocation("gui"), 0.0);
    gl.glUniform1f(shader.getUniformLocation("fogval"), 3000.0);
    gl.glUniform1f(shader.getUniformLocation("pointSize"), pointSize);

    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, nodes_vbo[0]);
    gl.glVertexPointer(3, GL2.GL_FLOAT, 0, 0);
    gl.glDrawArrays(GL2.GL_POINTS, 0, nodecount);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, 0);

    particleImg.disable(gl);

    ringImg.bind(gl);
    ringImg.enable(gl);
    gl.glUniform1f(shader.getUniformLocation("pointSize"), pointSize);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, nodes_vbo[0]);
    gl.glVertexPointer(3, GL2.GL_FLOAT, 0, 0);
    gl.glDrawArrays(GL2.GL_POINTS, 0, nodecount);
    gl.glBindBuffer(GL2.GL_ARRAY_BUFFER, 0);

    ringImg.disable(gl);

    shader.endShader();

    gl.glDisable(GL2.GL_POINT_SPRITE);
    gl.glDisable(GL2.GL_VERTEX_PROGRAM_POINT_SIZE);  
    gl.glColor3f(1, 1, 1);

    gl.glBlendFunc(GL2.GL_SRC_ALPHA, GL2.GL_ONE_MINUS_SRC_ALPHA);
    
    pg.endPGL();
  }

  if (showlines && lines != null) {
    pg.shape(lines);
  }
  if (!growcomplete) {
    Vector3d ps1 = new Vector3d(rts[0]);
    Vector3d ps2 = new Vector3d(rts[rt.getNextNode()]);
    float pdist = dist((float)ps1.x, (float)ps1.y, (float)ps1.z, (float)ps2.x, (float)ps2.y, (float)ps2.z);
    if (pdist < 45.0) {
      radius = radius + (int) sqrt(rt.getNumberOfPoints())/2;
      rts = rt.getPointList();
      initNodes(gl);
    } 
    else {
      initNodes(gl);
      growcomplete = true;
      lines = createLines();
    }
  }
  pg.endDraw();
}

public void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) pointSize += 10;
    else if (keyCode == DOWN) pointSize -= 10;
  } else {
    if (key == 'l') {
      showlines = !showlines;
    } else if (key == 'p') {
      showpoints = !showpoints;
    } else if (key == 's') {
      showskybox = !showskybox;
    } else if (key == 'f') {
      showfps = !showfps;
    }
  } 
}

