#version 150

layout (triangles) in;
layout (triangle_strip, max_vertices = 128) out;
 
uniform mat4 projectionMatrix;
uniform mat4 modelviewMatrix;
uniform mat3 normalMatrix;
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8];
 
uniform int level; 
 
in VertexData {
  vec4 color;
  vec3 normal;
} VertexIn[3];
 
out FragData {
  vec4 color;
} FragOut;
 
vec3 V0, V01, V02;
vec4 C0;
vec3 lightPos;
vec4 diffuseColor;

float lambertFactor(vec3 lightDir, vec3 vecNormal) {
  return max(0.0, dot(lightDir, vecNormal));
} 
 
void ProduceVertex(float s, float t) {
  vec3 v = normalize(V0 + s*V01 + t*V02);  
  vec4 c = C0;
  vec3 n = v;
  
  // Position and normal in eye coordinates.
  vec3 ecn = normalize(normalMatrix * n);
  vec4 ecp = modelviewMatrix * vec4(v, 1.0);
  
  // Calculate the diffuse light term
  vec3 ld = normalize(lightPos - vec3(ecp));
  float diffuseFactor = lambertFactor(ld, ecn);
    
  FragOut.color = diffuseColor * vec4(diffuseFactor * c.rgb, 1);    
  gl_Position = projectionMatrix * ecp;
  EmitVertex();
} 
 
void main() {
  V01 = (gl_in[1].gl_Position - gl_in[0].gl_Position).xyz;
  V02 = (gl_in[2].gl_Position - gl_in[0].gl_Position).xyz;
  V0 = gl_in[0].gl_Position.xyz;
  
  C0 = VertexIn[0].color;
  
  int numLayers = int(pow(2, level));
  float dt = 1.0 / float(numLayers);
  float t_top = 1.0;

  lightPos = lightPosition[0].xyz;
  diffuseColor = vec4(lightDiffuse[0], 1);  
  
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
      ProduceVertex(s_bot, t_bot);
      ProduceVertex(s_top, t_top);
      s_top += ds_top;
      s_bot += ds_bot;
    }
    ProduceVertex(s_bot, t_bot);
    EndPrimitive();
    t_top = t_bot;
    t_bot -= dt;
  }
}