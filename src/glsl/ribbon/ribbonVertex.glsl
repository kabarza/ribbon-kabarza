

uniform float uTime;
uniform sampler2D uSpatialTexture;
uniform vec2 uTextureSize;
uniform float uLengthRatio;
uniform vec3 uObjSize;
uniform float uOffset;
uniform float uTwistAmt;
uniform sampler2D uFabricTexture;

varying vec2 vUv;
varying float vElavation;


varying vec3 vPosition; 
varying vec3 vNormal;
varying mat4 vModelMatrix;
varying float vFadeAlpha;


#define PI 3.14159265359

// Rodrigues' rotation formula
vec3 rotateRodrigues(vec3 v, vec3 axis, float angle) {
  axis = normalize(axis);
  float cost = cos(angle);
  float sint = sin(angle);
  return v * cost + cross(axis, v) * sint + axis * dot(axis, v) * (1.0 - cost);
}

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}


struct splineData {
  vec3 point;
  vec3 binormal;
  vec3 normal;
};

splineData getSplineData(float t){
  float step = 1. / uTextureSize.y;
  float halfStep = step * 0.5;
  splineData sd;
  sd.point    = texture(uSpatialTexture, vec2(t, step * 0. + halfStep)).rgb;
  sd.binormal = texture(uSpatialTexture, vec2(t, step * 1. + halfStep)).rgb;
  sd.normal   = texture(uSpatialTexture, vec2(t, step * 2. + halfStep)).rgb;
  return sd;
}


vec3 calculateSurfacePoint(float t, float px, float py, float wStep) {
  float hWStep = wStep * 0.5;
  t = clamp(t, 0.0, 1.0);
  float numPrev = floor(t / wStep);
  float numNext = numPrev + 1.;
  float tPrev = clamp(numPrev * wStep + hWStep, hWStep, 1.0 - hWStep);
  float tNext = clamp(numNext * wStep + hWStep, hWStep, 1.0 - hWStep);
  splineData splinePrev = getSplineData(tPrev);
  splineData splineNext = getSplineData(tNext);

  float f = (t - tPrev) / wStep;
  vec3 P = mix(splinePrev.point, splineNext.point, f);
  vec3 B_initial = normalize(mix(splinePrev.binormal, splineNext.binormal, f)); // Initial "Thickness/Up"
  vec3 N_initial = normalize(mix(splinePrev.normal, splineNext.normal, f));     // Initial "Width"


  vec3 projectedN = vec3(0.4, 1.0, 0.2);
  // Interpolate N towards the target Y-axis
  // vec3 finalN = normalize(mix(N_initial, N_target, rotationFactor));
  vec3 finalN = normalize(projectedN);

  vec3 finalB = normalize(B_initial - dot(B_initial, finalN) * finalN);

  // vec3 basePos = P + (N_initial * px) + (B_initial * py);
  vec3 basePos = P + (finalN * px) + (B_initial * py);

  return basePos ;
}


float calculateElevation ( vec3 position ) {
  float waveFreqPath1 = 0.29; float waveFreqWidth1 = 1.2; float waveAmp1 = 0.99;
  float waveFreqPath2 = 1.1; float waveFreqWidth2 = 2.3; float waveAmp2 = 0.36; float timeSpeed2 = 0.6;
  float waveFreqPath3 = 0.45; float waveFreqWidth3 = 1.3; float waveAmp3 = 0.98; float timeSpeed3 = 0.4;
  
  float elX1 = sin( position.x * waveFreqPath1 + uTime * 3.5) * waveAmp1;
  float elY1 = cos(position.y * waveFreqWidth1 * 0.4 + uTime * 0.8) * waveAmp1 * 0.4;
  float elX2 = sin(position.x * waveFreqPath2 + uTime * timeSpeed2 * 3.5 + 5.0) * waveAmp2;
  float elY2 = cos(position.y * waveFreqWidth2 * 0.4 + uTime * timeSpeed2 * 0.8 + 2.0) * waveAmp2 * 0.08;
  float elX3 = sin(position.x * waveFreqPath3 + uTime * timeSpeed3 * 3.5 - 3.0) * waveAmp3;
  float elY3 = cos(position.y * waveFreqWidth3 * 0.4 + uTime * timeSpeed3 * 0.8 - 1.0) * waveAmp3 * 0.4;
  

  float elY4 = sin(( position.y * (2.0 - uv.y)) * 0.95  + uTime * 0.8) *  0.9  * clamp(0.0, 1.0, uv.y - 0.4);

  // reduce other waves when reaches the carousel
  // float waveReduceFactor = smoothstep(0.05, 0.4, abs(2.0 * uOffset - 1.35 ));
  // waveReduceFactor = clamp(waveReduceFactor, 0.7, 1.0);
  float waveReduceFactor = 1.0;

  float elevationX = elX1 + elX2 + elX3 ;
  float elevationY = elY1 + elY2 + elY3 ;
  float totalElevation = (elevationX + elevationY) * waveReduceFactor + elY4 ;
  // float totalElevation = (elevationX + elevationY);

  return totalElevation;
}

void main() {


  vec3 pos = position;

      // --- Apply Orientation Correction ---
  // float transitionStart = 0.42; // Start t value for rotation
  // float transitionEnd = 0.65;   // End t value for rotation (adjust as needed)
  // // float rotationFactor = smoothstep(transitionStart, transitionEnd, uOffset);
  // float rotationFactor = 1.0 - smoothstep(0.1, 2.6, abs(2.0 * uOffset - 1.0 ));

  // bending mesh on path
  float wStep = 1. / uTextureSize.x;
  float hWStep = wStep * 0.5;
  float d = pos.z / uObjSize.z;
  // float t = mod(uTime * 0.12, 1.7)  + (d * uLengthRatio);
  float t = uOffset  + (d * uLengthRatio);

  float fadeStartT = 0.49;
  float fadeEndT = 0.5; 
  float fadeAlpha =  smoothstep(fadeEndT, fadeStartT, abs(t - 0.5));
  // float fadeAlpha =  smoothstep(-20.0, -19.4, pos.z);
  // fadeAlpha = clamp(fadeAlpha, 0.0, 1.0); 
  fadeAlpha *= step(0.0001, 1.0 - uv.y) * pos.z;
  fadeAlpha = clamp(fadeAlpha, 0.0, 1.0); // Ensure alpha stays within [0, 1]


  float shift = 0.01;

  vec3 centerPos = calculateSurfacePoint(t, pos.x, pos.y, wStep);
  vec4 modelPosition = modelMatrix * vec4(centerPos, 1.0);


  vec3 modelPositionA = modelPosition.xyz + vec3 (shift, 0.0, 0.0);
  vec3 modelPositionB = modelPosition.xyz + vec3 (0.0, 0.0, -shift);



  float centerElevation = calculateElevation(centerPos);
  float posZShiftElevation = calculateElevation(modelPositionB);
  float posXShiftElevation = calculateElevation(modelPositionA);

  //  float elY4 = sin(( centerPos.y *(1.0 - uv.y)) * 3.2  + uTime * 0.8) *  0.9;


  // adding the evelation to y to calculate the elevated normals;
  vec4 centerModelPos = modelPosition;
  centerModelPos.y += centerElevation;

  modelPositionA.y += posXShiftElevation;
  modelPositionB.y += posZShiftElevation;

  vec3 toA = normalize(modelPositionA -  centerModelPos.xyz); // Approx. path direction tangent
  vec3 toB = normalize(modelPositionB - centerModelPos.xyz); // Approx. width direction tangent

  vec3 finalNormalObject = cross(toA, toB);

    // this is the elevation that adding to the z of the ribbon
  modelPosition.z += centerElevation;


  gl_Position = projectionMatrix * viewMatrix * modelPosition;


  //varyings
  vNormal = finalNormalObject; 
  vModelMatrix = modelMatrix;
  // Pass other varyings
  vPosition = modelPosition.xyz;
  vUv = uv;
  vElavation = centerElevation;
  vFadeAlpha = fadeAlpha; 


}

