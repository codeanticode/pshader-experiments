#version 150

in vec4 position;
in vec4 color;
in vec3 normal;
 
out VertexData {
  vec4 color;
  vec3 normal;
} VertexOut;
 
void main() {
  gl_Position = position;
  VertexOut.color = color;
  VertexOut.normal = normal;  
}
