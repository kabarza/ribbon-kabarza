
uniform float uProgress1;
uniform float uProgress2;
uniform float uProgress3;
uniform vec3 uResolution;

varying vec2 vUv;
varying vec3 vPos;


float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
	float fl = floor(p);
  float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}
	
float noise(vec2 n) {
	const vec2 d = vec2(0.0, 1.0);
  vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}


vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+10.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// // demo code:
// float color(vec2 xy) { return snoise(xy); }
// void mainImage(out vec4 fragColor, in vec2 fragCoord) {
//     vec2 p = (fragCoord.xy/uResolution.y) * 2.0 - 1.0;

//     vec3 xyz = vec3(p, 0);

//     float n = color(xyz.xy * 4.0);

//     fragColor.xyz = vec3(0.5 + 0.5 * vec3(n, n, n));

// }




float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}



void main() {

	vec3 pink = vec3(0.834, 0.066, 0.780);
	vec3 blue = vec3( 0.61, 0.75, 0.78 );
	vec3 sBlue = vec3( 0.73, 0.75, 0.76 );

	vec4 l1 = vec4(sBlue, 1.0);
	vec4 l2 = vec4(0.5, 0.5, 0.5 , 0.2);
	vec4 l3 = vec4(0.0, 0.0, 0.0 , 1.0);
	// vec4 l4 = vec4(0.0, 0.0, 0.0 , 1.0);

	vec2 p = (gl_FragCoord.xy/uResolution.y) * 2.0 - 1.0;

	float x = floor(vUv.x * 5.0 );
	float y = floor(vUv.y * 2.0);
	float pattern = snoise( vec2( p.x * 3.0, p.y * x * 0.5  ));
	pattern = clamp(pattern, 0.0, 1.0);

	float pattern2 = noise(vec2( y * vUv.y * 5.0, y * vUv.y * 10.0));
	pattern2 = clamp(pattern2, 0.0, 1.0);

	float w = 0.5;
	float p1 = uProgress1;
	p1 = map(p1 ,0.0, 1.0, -w, 1.0);
	p1 = smoothstep(p1 , p1 + w, vUv.x * vUv.y );
	float mix1 = 2.0 * p1 - pattern;
	mix1 = clamp(mix1, 0.0, 1.0);

	float p2 = uProgress2;
	p2 = map(p2 ,0.0, 1.0, -w, 1.0);
	p2 = smoothstep(p2 , p2 + w, vUv.x * vUv.y);
	float mix2 = 2.0 * p2 - pattern;
	mix2 = clamp(mix2, 0.0, 1.0);

	float p3 = uProgress3;
	p3 = map(p3 ,0.0, 1.0, -w, 1.0);
	p3 = smoothstep(p3 , p3 + w, vUv.x * vUv.y);
	float mix3 = 2.0 * p3 - pattern;
	mix3 = clamp(mix3, 0.0, 1.0);

	// float p4 = uProgress4;
	// p4 = map(p4 ,0.0, 1.0, -w, 1.0);
	// p4 = smoothstep(p4 , p4 + w, vUv.x * vUv.y);
	// float mix4 = 2.0 * p4 - pattern;
	// mix4 = clamp(mix4, 0.0, 1.0);


	vec4 layer0 = mix(vec4(0.0), l1, 1.0 - mix1);
	vec4 layer1 = mix(layer0, l2, 1.0 - mix2);
	vec4 layer2 = mix(layer1, l3, 1.0 - mix3);
	// vec4 layer3 = mix(layer2, l4, mix4);

	// gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);

	// gl_FragColor = layer0;
	gl_FragColor = layer2;

	#include <tonemapping_fragment>
    #include <colorspace_fragment>
}