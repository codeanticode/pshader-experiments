public void initNodes(GL2 gl) 
{
  if (nodecount > 0) 
  {
    gl.glGenBuffers( 1, nodes_vbo, 0 );
    gl.glBindBuffer( GL2.GL_ARRAY_BUFFER, nodes_vbo[0] );
    gl.glBufferData( GL2.GL_ARRAY_BUFFER, rts.length * 3 * 4, point3d_to_float_buffer( rts ), GL2.GL_STATIC_DRAW );
    gl.glBindBuffer( GL2.GL_ARRAY_BUFFER, 0);
  }
}

// buffer converters
FloatBuffer point3d_to_float_buffer(Point3d[] _vector) 
{
  FloatBuffer a  = ByteBuffer.allocateDirect(_vector.length * 3 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();

  for (int i = 0; i < _vector.length; i++) 
  {
    Vector3d v = new Vector3d(_vector[i]);
    a.put( (float)v.x );
    a.put( (float)v.y );
    a.put( (float)v.z );
  }
  a.rewind();
  return a;
}
