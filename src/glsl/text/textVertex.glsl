
uniform float uProgress1;
uniform float uProgress2;
uniform float uProgress3;
uniform float uTime;


varying vec2 vUv;
varying vec3 vPos;

void main() {

	vec3 pos = position;
	pos.y += 10.0 *( 0.5 + uv.x) * ( 1.0 - uProgress2 );
	pos.x += vUv.y * 0.5 * (1.0 - uProgress2);

	vec4 modelPosition = modelMatrix * vec4(pos, 1.0);

	modelPosition.y += sin(modelPosition.y * 0.5 + uTime * 4.0 ) * 10.5 * ( 1.0 - uProgress2 );
	modelPosition.x += sin(pos.y* 0.4 + uTime * 2.0 ) * 2.5 * (1.0 - uProgress2 );
	modelPosition.x += -20.0 * ( 1.0 - uProgress1);

	gl_Position = projectionMatrix * viewMatrix * modelPosition; 

	//varyings
	vUv = uv;
	vPos = pos;
}