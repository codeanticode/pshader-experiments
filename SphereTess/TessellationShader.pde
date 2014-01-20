class TessellationShader extends PShader {
  int glTessControl;
  String tessControlSource; 
  int glTessEval;
  String tessEvalSource;    
  int glGeometry;
  String geometrySource;

  TessellationShader(PApplet parent, String vertFilename, 
                                     String tessControlFilename, 
                                     String tessEvalFilename, 
                                     String geoFilename, 
                                     String fragFilename) {
    super(parent, vertFilename, fragFilename);
    tessControlSource = PApplet.join(parent.loadStrings(tessControlFilename), "\n");
    tessEvalSource = PApplet.join(parent.loadStrings(tessEvalFilename), "\n");
    geometrySource = PApplet.join(parent.loadStrings(geoFilename), "\n");
  }

  void setup() {
    boolean compiled;

    glTessControl = pgl.createShader(GL4.GL_TESS_CONTROL_SHADER);
    pgl.shaderSource(glTessControl, tessControlSource);
    pgl.compileShader(glTessControl);      
    pgl.getShaderiv(glTessControl, PGL.COMPILE_STATUS, intBuffer);
    compiled = intBuffer.get(0) == 0 ? false : true;
    if (!compiled) {
      println("Cannot compile tessellation control shader:\n" + pgl.getShaderInfoLog(glTessControl));
      return;
    }

    glTessEval = pgl.createShader(GL4.GL_TESS_EVALUATION_SHADER);
    pgl.shaderSource(glTessEval, tessEvalSource);
    pgl.compileShader(glTessEval);       
    pgl.getShaderiv(glTessEval, PGL.COMPILE_STATUS, intBuffer);
    compiled = intBuffer.get(0) == 0 ? false : true;
    if (!compiled) {
      println("Cannot compile tessellation evaluation shader:\n" + pgl.getShaderInfoLog(glTessEval));
      return;
    }      

    glGeometry = pgl.createShader(GL3.GL_GEOMETRY_SHADER);
    pgl.shaderSource(glGeometry, geometrySource);
    pgl.compileShader(glGeometry);      
    pgl.getShaderiv(glGeometry, PGL.COMPILE_STATUS, intBuffer);
    compiled = intBuffer.get(0) == 0 ? false : true;
    if (!compiled) {
      println("Cannot compile geometry shader:\n" + pgl.getShaderInfoLog(glGeometry));
      return;
    }

    pgl.attachShader(glProgram, glTessControl);
    pgl.attachShader(glProgram, glTessEval);
    pgl.attachShader(glProgram, glGeometry);
  }

  void draw(int idxId, int count, int offset) {
    GL4 gl4 = ((PJOGL)pgl).gl.getGL4();
    gl4.glPatchParameteri(GL4.GL_PATCH_VERTICES, 3);      
    pgl.bindBuffer(PGL.ELEMENT_ARRAY_BUFFER, idxId);
    pgl.drawElements(GL4.GL_PATCHES, count, GL.GL_UNSIGNED_SHORT, 
    offset * Short.SIZE / 8);
    pgl.bindBuffer(PGL.ELEMENT_ARRAY_BUFFER, 0);
  }
}

