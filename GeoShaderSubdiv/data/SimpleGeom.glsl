#version 150

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;
 
uniform mat4 transformMatrix;
uniform mat4 modelviewMatrix;
uniform mat3 normalMatrix;
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8];
 
in VertexData {
  vec4 color;
  vec3 normal;
} VertexIn[3];
 
out FragData {
  vec4 color;
} FragOut;
 
float lambertFactor(vec3 lightDir, vec3 vecNormal) {
  return max(0.0, dot(lightDir, vecNormal));
} 
 
void main() {
  vec3 lpos = lightPosition[0].xyz;
  vec4 dcolor = vec4(lightDiffuse[0], 1);
  
  for (int i = 0; i < gl_in.length(); i++) {
    vec4 pos = gl_in[i].gl_Position;
    gl_Position = transformMatrix * pos;
    
    // Position and normal in eye coordinates.
    vec3 ecp = vec3(modelviewMatrix * pos);
    vec3 ecn = normalize(normalMatrix * VertexIn[i].normal);
     if (dot(-1.0 * ecp, ecn) < 0.0) {
      // If normal is away from camera, choose its opposite.
      // If we add backface culling, this will be backfacing  
      ecn *= -1.0;
    }
    
    // Calculate the diffuse light term
    vec3 ld = normalize(lpos - ecp);
    float factor = lambertFactor(ld, ecn);
    
    FragOut.color = dcolor * vec4(factor * VertexIn[i].color.rgb, 1);
    EmitVertex();
  }
}