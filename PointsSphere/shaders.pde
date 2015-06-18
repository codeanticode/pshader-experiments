void initShaders(GL2 gl) {
  shader = new GLSLshader(gl);
  shader.loadVertexShader("pglslvs.vert");
  shader.loadFragmentShader("pglslfs.frag");
  shader.useShaders();
}

class GLSLshader
{
  GL2 gl;
  int programObject;
  int vertexShader;
  int fragmentShader;

  GLSLshader(GL2 gl0)
  {
    gl = gl0;
    programObject = (int)gl.glCreateProgramObjectARB();
    vertexShader = -1;
    fragmentShader = -1;
  }

  void loadVertexShader(String file)
  {
    String shaderSource = join(loadStrings(file), "\n");
    vertexShader = (int)gl.glCreateShaderObjectARB(GL2.GL_VERTEX_SHADER);
    gl.glShaderSourceARB(vertexShader, 1, new String[] {
      shaderSource
    }
    , (int[]) null, 0);
    gl.glCompileShaderARB(vertexShader);
    checkLogInfo(gl, vertexShader);
    gl.glAttachObjectARB(programObject, vertexShader);
  }

  void loadFragmentShader(String file)
  {
    String shaderSource = join(loadStrings(file), "\n");
    fragmentShader = (int)gl.glCreateShaderObjectARB(GL2.GL_FRAGMENT_SHADER);
    gl.glShaderSourceARB(fragmentShader, 1, new String[] {
      shaderSource
    }
    , (int[]) null, 0);
    gl.glCompileShaderARB(fragmentShader);
    checkLogInfo(gl, (int)fragmentShader);
    gl.glAttachObjectARB(programObject, fragmentShader);
  }

  int getAttribLocation(String name)
  {
    return(gl.glGetAttribLocation(programObject, name));
  }

  int getUniformLocation(String name)
  {
    return(gl.glGetUniformLocation(programObject, name));
  }

  void useShaders()
  {
    gl.glLinkProgramARB(programObject);
    gl.glValidateProgramARB(programObject);
    checkLogInfo(gl, programObject);
  }

  void startShader(GL2 gl)
  {
    this.gl = gl;
    gl.glUseProgramObjectARB(programObject);
  }

  void endShader()
  {
    gl.glUseProgramObjectARB(0);
  }

  void checkLogInfo(GL2 gl, int obj)
  {
    IntBuffer iVal = ByteBuffer.allocateDirect(1).order(ByteOrder.nativeOrder()).asIntBuffer();
    gl.glGetObjectParameterivARB(obj, GL2.GL_OBJECT_INFO_LOG_LENGTH_ARB, iVal);
    int length = 0;
    try {
      length = iVal.get();
    } 
    catch (Exception e) {
    }
    if (length <= 1) return;
    ByteBuffer infoLog =  ByteBuffer.allocateDirect(length).order(ByteOrder.nativeOrder());
    iVal.flip();
    gl.glGetInfoLogARB(obj, length, iVal, infoLog);
    byte[] infoBytes = new byte[length];
    infoLog.get(infoBytes);
    println("GLSL Validation: \n" + new String(infoBytes));
  }
}