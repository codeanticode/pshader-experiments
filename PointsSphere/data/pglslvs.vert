#version 110
uniform float pointSize;
uniform float gui;
uniform float fogval;
varying vec4 vFragColor;

void main(void) {
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	vec4 modv = vec4( gl_ModelViewMatrix * gl_Vertex );
	vFragColor = gl_Color;
    	if(gui == 0.0) {
		gl_PointSize = 200.0 * pointSize/ -modv.z;
		float fog = fogval/ -modv.z;
		if (fog < 1.5) {
			vFragColor = smoothstep(0.0, 1.5, fog) * vFragColor;
		}
    	} else {
		gl_PointSize = pointSize;
    	}
	gl_FrontColor = vFragColor;
}
