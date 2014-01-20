class GeometryShader extends PShader {
  int glGeometry;
  String geometrySource;

  GeometryShader(PApplet parent, String vertFilename, String geoFilename, String fragFilename) {
    super(parent, vertFilename, fragFilename);
    geometrySource = PApplet.join(parent.loadStrings(geoFilename), "\n");
  }

  // Setup the geometry shader (fragment and vertex shaders are automatically handled in 
  // by the PShader superclass).
  void setup() {
    glGeometry = pgl.createShader(GL3.GL_GEOMETRY_SHADER);
    pgl.shaderSource(glGeometry, geometrySource);
    pgl.compileShader(glGeometry);

    pgl.getShaderiv(glGeometry, PGL.COMPILE_STATUS, intBuffer);
    boolean compiled = intBuffer.get(0) == 0 ? false : true;
    if (!compiled) {
      println("Cannot compile geometry shader:\n" + pgl.getShaderInfoLog(glGeometry));
      return;
    }
    
    pgl.attachShader(glProgram, glGeometry);
  }
}

