
uniform vec3 uColor;
uniform vec3 uLightDirection;
uniform vec3 uObjSize;
uniform sampler2D uFabricTexture;
uniform sampler2D uFabricTextureNormal;
uniform sampler2D uFabricAO;
uniform sampler2D uFabricRoughness;
uniform float uOffset;
uniform float uLengthRatio;

varying vec2 vUv;
varying float vElavation;
varying vec3 vPosition;
varying vec3 vNormal;
varying mat4 vModelMatrix;
varying float vFadeAlpha; 

#include "../includes/ambientLight.glsl";
#include "../includes/directionalLight.glsl";
#include "../includes/pointLight.glsl";


vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm, vec3 mapN, vec2 vUv ) {
    // Assuming mapN is the unpacked normal from the normal map in [-1, 1] range
    // And surf_norm is the interpolated vertex normal (world space)

    vec3 q0 = dFdx( eye_pos.xyz );
    vec3 q1 = dFdy( eye_pos.xyz );
    vec2 st0 = dFdx( vUv.st );
    vec2 st1 = dFdy( vUv.st );

    vec3 S = normalize( q0 * st1.t - q1 * st0.t );
    vec3 T = normalize( -q0 * st1.s + q1 * st0.s );
    vec3 N = normalize( surf_norm );

    mat3 tsn = mat3( S, T, N ); // This creates the TBN matrix
    return normalize( tsn * mapN );
}


void main() {


 	vec3 normal = normalize(vNormal); 

    vec4 worldPosition = vModelMatrix * vec4(vPosition, 1.0);
	vec3 viewDirection = normalize(vPosition - cameraPosition);

    mat3 normalMatrix = transpose(inverse(mat3(vModelMatrix)));
    vec3 geometryNormal = normalize(normalMatrix * vNormal); // World space geometry normal


    vec2 scaledUv = vec2(vUv.x * uObjSize.x / 2.0  , vUv.y * uObjSize.z / 2.0 );
    vec3 normalMapSample = texture(uFabricTextureNormal, scaledUv).rgb;
    vec3 textureColor = texture(uFabricTexture, scaledUv).rgb;

    textureColor = clamp(textureColor + vec3(0.1) , 0.1, 0.95);

    vec3 tangentSpaceNormal = normalize(normalMapSample * 2.0 - 1.0);

    vec3 finalNormal = perturbNormal2Arb( -worldPosition.xyz, geometryNormal, tangentSpaceNormal, vUv );
    // vec3 finalNormal = normal * normalMapSample;

    // Lights
    // float specularPower = mix(50.0, 1.0, roughnessValue);
    vec3 ambient = ambientLight(
        vec3(1.0), // Light color
        0.1    // Light intensity
    );

    vec3 directLight = vec3(0.0);

    directLight += pointLight(
        vec3(0.2, 0.2, 1.0), // Light color
        2.0,                 // Light intensity,
        finalNormal * 1.0  ,              // Normal
        vec3(50.0, 70.0, 40.0), // Light position
        viewDirection,       // View direction
        30.0 ,                // Specular power
        vPosition,           // Position
        .01                 // Light decay
    );

     directLight += directionalLight(
        vec3(0.9, 0.9, 0.96), // Light color
        1.7,                 // Light intensity,
        finalNormal * 1.0 ,              // Normal
        vec3(20.0, 76.0, 20.0), // Light position
        viewDirection,       // View direction
        30.0             // Specular power
    );
    //  directLight += directionalLight(
    //     vec3(0.9, 0.9, 0.96), // Light color
    //     1.4,                 // Light intensity,
    //     -finalNormal * 1.0 ,              // Normal
    //     vec3(20.0, 30.0, -30.0), // Light position
    //     viewDirection,       // View direction
    //     30.0             // Specular power
    // );


        // --- Apply AO to Ambient Light ---
    // ambient *= clamp(aoValue, 0.5 ,1.0);
    // ambient *= aoValue;
	vec3 totalLight = ambient + directLight;

	float elevationSum = vElavation ;
    float mixStrength = (elevationSum + 0.275) * 0.2;
    mixStrength = smoothstep(-1.8, 0.5, mixStrength);

    vec3 elevationColor = mix(uColor - 0.34, uColor, mixStrength);


    // vec3 finalColor = color * light;
    vec3 finalColor = textureColor * elevationColor * totalLight;
    finalColor = smoothstep(-0.5, 0.7, finalColor);

    float fadeRibbon = vFadeAlpha * step(0.02, 1.0 - vUv.y);

	gl_FragColor.rgba = vec4(finalColor, 1.0);
    gl_FragColor.a *= fadeRibbon;

    if (gl_FragColor.a < 0.8) {
        discard;
    }
	    // --- DEBUGGING OPTIONS (uncomment one at a time) ---
    // gl_FragColor.rgba = vec4(finalNormal, 1.0 ); // Visualize normals
    // gl_FragColor.rgba = vec4(normal, 1.0 ); // Visualize normals
    // gl_FragColor.rgba = vec4(vec3(lightIntensity), 1.0); // Visualize direct light intensity
    // gl_FragColor.rgba = vec4(vec3(ambientIntensity), 1.0); // Visualize ambient intensity
    // gl_FragColor.rgba = vec4(elevationColor, 1.0); // Visualize base color before lighting
    // gl_FragColor.rgba = vec4(textureColor, 1.0); // Visualize base color before lighting
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}


