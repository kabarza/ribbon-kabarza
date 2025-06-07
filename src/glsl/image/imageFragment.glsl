
uniform sampler2D uImageTexture;
uniform float uOffset;

varying vec2 vUv;
varying float vElavation;
varying vec4 vModelPosition;
varying vec3 vNormal;
varying vec3 vNorm;

#include "../includes/ambientLight.glsl";
#include "../includes/directionalLight.glsl";
#include "../includes/pointLight.glsl";


void main() {

	vec3 normal = normalize(vNormal) ; 
	vec3 newPos = vModelPosition.xyz;
	vec3 viewDirection = normalize(newPos - cameraPosition);
	vec2 uv = vUv ;

	    // Lights
    vec3 light = vec3(0.0);

    light += ambientLight(
        vec3(1.0), // Light color
        0.05       // Light intensity
    );
    // light += pointLight(
    //     vec3(1.0, 1.0, 1.0), // Light color
    //     50.5,                 // Light intensity,
    //     normal,              // normal
    //     vec3(-40.0, 25.0, -45.0), // Light position
    //     viewDirection,       // View direction
    //     1.0 ,                // Specular power
    //     newPos,           // Position
    //     .015                  // Light decay
    // );

    // light += pointLight(
    //     vec3(1.0, 1.0, 1.0), // Light color
    //     3.5,                 // Light intensity,
    //     normal,              // normal
    //     vec3(30.0, 20.0, -50.0), // Light position
    //     viewDirection,       // View direction
    //     1.0 ,                // Specular power
    //     newPos,           // Position
    //     .015                  // Light decay
    // );
    //  light += pointLight(
    //     vec3(1.0, 1.0, 1.0), // Light color
    //     1.5,                 // Light intensity,
    //     normal,              // normal
    //     vec3(0.0, 15.0, -60.0), // Light position
    //     viewDirection,       // View direction
    //     1.0 ,                // Specular power
    //     newPos,           // Position
    //     .015                  // Light decay
    // );

    light += directionalLight(
         vec3(1.0, 1.0, 1.0), // Light color
        1.0,                 // Light intensity,
        vNorm,              // Normal
        vec3(0.0, 95.0, 160.0), // Light position
        viewDirection,       // View direction
        30.0             // Specular power
    );

    light += directionalLight(
         vec3(1.0, 1.0, 1.0), // Light color
        1.0,                 // Light intensity,
        normal,              // Normal
        vec3(0.0, 35.0, -160.0), // Light position
        viewDirection,       // View direction
        30.0             // Specular power
    );

    // light += directionalLight(
    //     vec3(0.2, 0.2, 0.2), // Light color
    //     1.0,                 // Light intensity,
    //     -vNormal,              // Normal
    //     vec3(0.0, 30.0, 10.0), // Light position
    //     viewDirection,       // View direction
    //     30.0             // Specular power
    // );

    light = clamp(light, 0.0, 0.95);


	vec3 imageTexture = texture(uImageTexture, uv).rgb ;
    // vec3 lightedImage = imageTexture;

	float offset = clamp(uOffset , 0.0, 1.0);

	// gl_FragColor = vec4( imageTexture, 1.0);
//   gl_FragColor = vec4(imageTexture, offset * clamp(2.0 - uv.x , 0.0, 1.0) );
// float alphaControl = clamp(offset * (0.8 - uv.x) + offset , -0.2, 1.0);

// vec3 ribbonColor = vec3 (0.55, 0.55, 0.65);
float elevationSum = vElavation ;
// float mixStrength = (elevationSum + 0.975) * 0.2;
float mixStrength = smoothstep(0.0, 1.0, vElavation);
vec3 elevationColor = mix(vec3(0.7, 0.7, 0.75), vec3(0.85, 0.85, 0.9), mixStrength);

float mixControl = smoothstep(0.95, 0.3 ,pow(offset * (0.8 - uv.x) + offset + 1.5 , -2.0) * 2.0 );
// float mixControl = smoothstep(0.0, 1.0 ,(1.5 - uv.x) );

vec3 mixTexture = mix(elevationColor, imageTexture, mixControl);

// Calculate how much this face is lit by main light
float faceLighting = dot(normal, viewDirection);
float shadowFactor = smoothstep(-0.2, 0.4, faceLighting);

// Apply shadow
light *= mix(0.6, 1.0, shadowFactor); // 0.2 = shadow darkness

vec3 lightedTexture = mixTexture * light;

  gl_FragColor = vec4(lightedTexture, offset );
//   gl_FragColor = vec4(imageTexture, 1.0 );

      if (gl_FragColor.a < 0.12) {
        discard;
    }

// // Use built-in gl_FrontFacing for reliable backface detection
// if (gl_FrontFacing) {
//     gl_FragColor = vec4(lightedTexture , offset); // Front face - normal
// } else {
//     gl_FragColor = vec4(lightedTexture * 0.3, offset); // Back face - darker
// }

	#include <tonemapping_fragment>
    #include <colorspace_fragment>
}