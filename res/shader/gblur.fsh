#ifdef GL_ES
precision mediump float;
#endif
 
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
 
uniform vec2 blurSize;
 
vec4 SingleBlur(vec2 BlurSize)
{
	vec4 sum = vec4(0.0);
	sum += texture2D(CC_Texture0, v_texCoord - 0.0001 * BlurSize) * 0.33;
	sum += texture2D(CC_Texture0, v_texCoord) * 0.33;
	sum += texture2D(CC_Texture0, v_texCoord + 0.0001 * BlurSize) * 0.33;
	return sum;
}
 
void main() 
{
	vec4 sum = vec4(0.0);
	sum += SingleBlur(vec2(0, blurSize.y)) * 0.11111;
	sum += SingleBlur(vec2(0, -blurSize.y)) * 0.11111;
	sum += SingleBlur(vec2(-blurSize.x, 0)) * 0.11111;
	sum += SingleBlur(vec2(blurSize.x, 0)) * 0.11111;
	sum += SingleBlur(vec2(blurSize.x, blurSize.y)) * 0.11111;
	sum += SingleBlur(vec2(-blurSize.x, blurSize.y)) * 0.11111;
	sum += SingleBlur(vec2(blurSize.x, -blurSize.y)) * 0.11111;
	sum += SingleBlur(vec2(-blurSize.x, -blurSize.y)) * 0.11111;
	sum += SingleBlur(vec2(0, 0)) * 0.11111;
 
    gl_FragColor = sum * v_fragmentColor;
}