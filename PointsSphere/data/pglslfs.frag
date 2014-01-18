#version 110
uniform sampler2D tex;
varying vec4 vFragColor;

void main() {
	gl_FragColor = texture2D(tex,gl_TexCoord[0].st) * vFragColor;
}

