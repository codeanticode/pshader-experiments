#version 150

layout (triangles) in;
layout (line_strip, max_vertices = 128) out;
 
uniform mat4 projectionMatrix;
uniform mat4 modelviewMatrix;
uniform mat3 normalMatrix;
 
uniform int level; 
 
in VertexData {
  vec4 color;
  vec3 normal;
} VertexIn[3];
 
out FragData {
  vec4 color;
} FragOut;
 
vec3 V0, V01, V02;
vec4 C0, C1, C2;
 
void ProduceNormal(float s, float t) {
  vec3 v = normalize(V0 + s*V01 + t*V02);
  vec4 c = C0 + s*C1 + t*C2;
  vec3 n = v;
  
  // Position and normal in eye coordinates.
  vec3 ecn = normalize(normalMatrix * n);
  vec4 ecp = modelviewMatrix * vec4(v, 1.0);  
      
  gl_Position = projectionMatrix * ecp;
  FragOut.color = vec4(0, 1, 0, 1);
  EmitVertex();
  
  gl_Position = projectionMatrix * (ecp + 20.0 * vec4(ecn, 0.0));  
  FragOut.color = vec4(0, 1, 0, 1);
  EmitVertex();
} 
 
void main() {
  V01 = (gl_in[1].gl_Position - gl_in[0].gl_Position).xyz;
  V02 = (gl_in[2].gl_Position - gl_in[0].gl_Position).xyz;
  V0 = gl_in[0].gl_Position.xyz;
  
  C0 = VertexIn[0].color;
  C1 = VertexIn[1].color;
  C2 = VertexIn[2].color;
  
  int numLayers = int(pow(2, level));
  float dt = 1.0 / float(numLayers);
  float t_top = 1.0;

  for (int it = 0; it < numLayers; it++) {
    float t_bot = t_top - dt;
    float smax_top = 1.0 - t_top;
    float smax_bot = 1.0 - t_bot;
    int nums = it + 1;
    float ds_top = smax_top / float(nums - 1);
    float ds_bot = smax_bot / float(nums);
    float s_top = 0.0;
    float s_bot = 0.0;
    for (int is = 0; is < nums; is++) {
      ProduceNormal(s_bot, t_bot);
      EndPrimitive();
      ProduceNormal(s_top, t_top);
      EndPrimitive();
      s_top += ds_top;
      s_bot += ds_bot;
    }
    ProduceNormal(s_bot, t_bot);
    EndPrimitive();
    t_top = t_bot;
    t_bot -= dt;
  }
}