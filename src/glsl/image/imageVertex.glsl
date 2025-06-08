
uniform float uOffsetTotal;
uniform float uOffset;
uniform float uTime;
uniform float uVelocity;
uniform float uProgress;

varying vec2 vUv;
varying float vElavation;
varying vec4 vModelPosition;
varying vec3 vNormal;
varying vec3 vNorm;

float calculateElevation ( vec3 pos) {
  float waveFreqPath1 = 0.25; float waveFreqWidth1 = 1.2; float waveAmp1 = 0.96;
  float waveFreqPath2 = 0.9; float waveFreqWidth2 = 2.3; float waveAmp2 = 0.32; float timeSpeed2 = 0.6;
  float waveFreqPath3 = 0.35; float waveFreqWidth3 = 1.3; float waveAmp3 = 0.96; float timeSpeed3 = 0.4;
  
  float elX1 = sin( pos.x * waveFreqPath1 + uTime * 3.5) * waveAmp1;
  float elY1 = cos(pos.y * waveFreqWidth1 * 0.4 + uTime * 0.8) * waveAmp1 * 0.4;
  float elX2 = sin(pos.x * waveFreqPath2 + uTime * timeSpeed2 * 3.5 + 5.0) * waveAmp2;
  float elY2 = cos(pos.y * waveFreqWidth2 * 0.4 + uTime * timeSpeed2 * 0.8 + 2.0) * waveAmp2 * 0.08;
  float elX3 = sin(pos.x * waveFreqPath3 + uTime * timeSpeed3 * 3.5 - 3.0) * waveAmp3;
  float elY3 = cos(pos.y * waveFreqWidth3 * 0.4 + uTime * timeSpeed3 * 0.8 - 1.0) * waveAmp3 * 0.4;
  
  // excessive wave when reaches the carousel 
  // float waveEmergeFactor = smoothstep(0.45, 0.6, uOffsetTotal) ;
  // float waveEmergeFactor = smoothstep(0.0, 5.0, uVelocity * 5.0);
  float elY4 = sin( position.x  * 0.35  + uTime * 3.8) *  0.4 ;
  float elX4 = sin( position.y  * 1.15  + uTime * 5.8 + 1.5) *  0.25 ;
  float elY5 = sin( position.x  * 0.65  + uTime * 6.4 + 1.7) *  0.38 ;
  float elX5 = sin( position.y  * 1.35  + uTime * 7.8 + 0.8) *  0.21 ;
  //  float elY6 = sin(( position.x * (2.0 - uv.x * uv.y)) * 0.25  + uTime * 0.8) *  0.4 ;
  float velocityElevation = elY4 + elY5 + elX4 + elX5;
  // float waveReduceFactor = smoothstep(1.0, 0.2, pow(uOffset,3.0));
  // float waveReduceFactor = smoothstep(0.05, 0.4, abs(2.0 * uOffset - 1.35 ));
  // waveReduceFactor = clamp(waveReduceFactor, 0.7, 1.0);

  float elevationX = elX1 + elX2 + elX3 ;
  float elevationY = elY1 + elY2 + elY3 ;
  float totalElevation = (elevationX + elevationY) ;
  float velocityController = smoothstep(0.0, 1.0, uVelocity * uVelocity);
  float elevationStop =  smoothstep(0.1 , 2.5 ,( 1.3 - uOffset / 8.0) * (4.8 - clamp(uTime / 1.2, 0.0, 4.8))) 
    + velocityController ;

  return totalElevation * elevationStop + (velocityElevation) * velocityController;
}

void main() {

  float progress = uProgress;
  progress = smoothstep(0.0, 1.0, uProgress);

  vec3 pos = position;

	pos.y += 2.0 *( 0.5 + uv.x) * progress;
	pos.x += vUv.y * 0.3 * progress;

  vec4 modelPosition = modelMatrix * vec4(pos , 1.0);

  modelPosition.y += sin(pos.y * 0.8 + uTime * 10.0 ) * 1.0 * progress * progress;
	modelPosition.x += sin(pos.y * 0.3 + uTime * 8.0 ) * 0.7 * progress * progress ;
	// modelPosition.x += -1.0 * progress ;

	float elevation = calculateElevation( modelPosition.xyz);

  modelPosition.xyz += normal * elevation;

	gl_Position = projectionMatrix * viewMatrix * modelPosition;

  vec3 transformedNormal = normalize(normalMatrix * normal);

	//varyings
	vUv = uv;
  vNormal = transformedNormal;
  vNorm = normal;
  vElavation = elevation;
  vModelPosition = modelPosition;
}