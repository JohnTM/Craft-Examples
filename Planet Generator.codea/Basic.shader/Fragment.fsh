precision highp float;
precision highp int;

uniform mat4 viewMatrix;
uniform vec3 cameraPosition;

uniform vec3 diffuse;
uniform float opacity;

#ifndef FLAT_SHADED

varying vec3 vNormal;

#endif
#define PI 3.14159265359
#define PI2 6.28318530718
#define RECIPROCAL_PI 0.31830988618
#define RECIPROCAL_PI2 0.15915494
#define LOG2 1.442695
#define EPSILON 1e-6

#define saturate(a) clamp( a, 0.0, 1.0 )
#define whiteCompliment(a) ( 1.0 - saturate( a ) )

float pow2( const in float x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float average( const in vec3 color ) { return dot( color, vec3( 0.3333 ) ); }
// expects values in the range of [0,1]x[0,1], returns values in the [0,1] range.
// do not collapse into a single function per: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float rand( const in vec2 uv ) {
    const highp float a = 12.9898, b = 78.233, c = 43758.5453;
    highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
    return fract(sin(sn) * c);
}

struct IncidentLight {
    vec3 color;
    vec3 direction;
    bool visible;
};

struct ReflectedLight {
    vec3 directDiffuse;
    vec3 directSpecular;
    vec3 indirectDiffuse;
    vec3 indirectSpecular;
};

struct GeometricContext {
    vec3 position;
    vec3 normal;
    vec3 viewDir;
};


vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
    
    return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
    
}

// http://en.wikibooks.org/wiki/GLSL_Programming/Applying_Matrix_Transformations
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
    
    return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
    
}

vec3 projectOnPlane(in vec3 point, in vec3 pointOnPlane, in vec3 planeNormal ) {
    
    float distance = dot( planeNormal, point - pointOnPlane );
    
    return - distance * planeNormal + point;
    
}

float sideOfPlane( in vec3 point, in vec3 pointOnPlane, in vec3 planeNormal ) {
    
    return sign( dot( point - pointOnPlane, planeNormal ) );
    
}

vec3 linePlaneIntersect( in vec3 pointOnLine, in vec3 lineDirection, in vec3 pointOnPlane, in vec3 planeNormal ) {
    
    return lineDirection * ( dot( planeNormal, pointOnPlane - pointOnLine ) / dot( planeNormal, lineDirection ) ) + pointOnLine;
    
}
#ifdef USE_COLOR

varying vec3 vColor;

#endif
#if defined( USE_MAP ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( USE_SPECULARMAP ) || defined( USE_ALPHAMAP ) || defined( USE_EMISSIVEMAP ) || defined( USE_ROUGHNESSMAP ) || defined( USE_METALNESSMAP )

varying vec2 vUv;

#endif
#if defined( USE_LIGHTMAP ) || defined( USE_AOMAP )

varying vec2 vUv2;

#endif
#ifdef USE_MAP

uniform sampler2D map;

#endif
#ifdef USE_ALPHAMAP

uniform sampler2D alphaMap;

#endif
#ifdef USE_AOMAP

uniform sampler2D aoMap;
uniform float aoMapIntensity;

#endif
#if defined( USE_ENVMAP ) || defined( PHYSICAL )
uniform float reflectivity;
uniform float envMapIntenstiy;
#endif

#ifdef USE_ENVMAP

//#if ! defined( PHYSICAL ) && ( defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) )
varying vec3 vWorldPosition;
//#endif

#ifdef ENVMAP_TYPE_CUBE
uniform samplerCube envMap;
#else
uniform sampler2D envMap;
#endif
uniform float flipEnvMap;

//#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( PHYSICAL )
uniform float refractionRatio;
//#else
//varying vec3 vReflect;
//#endif

#endif
#ifdef USE_FOG

uniform vec3 fogColor;

#ifdef FOG_EXP2

uniform float fogDensity;

#else

uniform float fogNear;
uniform float fogFar;
#endif

#endif
#ifdef USE_SPECULARMAP

uniform sampler2D specularMap;

#endif
#ifdef USE_LOGDEPTHBUF

uniform float logDepthBufFC;

#ifdef USE_LOGDEPTHBUF_EXT

varying float vFragDepth;

#endif

#endif

vec4 mapTexelToLinear( vec4 value )
{
    return value;
}

vec4 envMapTexelToLinear( vec4 value )
{
    return value;
}

vec3 packNormalToRGB( const in vec3 normal )
{
    return normalize( normal ) * 0.5 + 0.5;
}

void main() {
    float f = max(dot(vNormal, vec3(0.0,0.0,1.0)), 0.0 );
    vec4 diffuseColor = vec4( diffuse, f);
#if defined(USE_LOGDEPTHBUF) && defined(USE_LOGDEPTHBUF_EXT)
    
    gl_FragDepthEXT = log2(vFragDepth) * logDepthBufFC * 0.5;
    
#endif
#ifdef USE_MAP
    
    vec4 texelColor = texture2D( map, vUv );
    
    texelColor = mapTexelToLinear( texelColor );
    diffuseColor *= texelColor;
    
#endif
#ifdef USE_COLOR
    
    diffuseColor.rgb *= vColor;
    
#endif
#ifdef USE_ALPHAMAP
    
    diffuseColor.a *= texture2D( alphaMap, vUv ).g;
    
#endif
#ifdef ALPHATEST
    
    if ( diffuseColor.a < ALPHATEST ) discard;
    
#endif
    float specularStrength;
    
#ifdef USE_SPECULARMAP
    
    vec4 texelSpecular = texture2D( specularMap, vUv );
    specularStrength = texelSpecular.r;
    
#else
    
    specularStrength = 1.0;
    
#endif
    
    ReflectedLight reflectedLight;
    reflectedLight.directDiffuse = vec3( 0.0 );
    reflectedLight.directSpecular = vec3( 0.0 );
    reflectedLight.indirectDiffuse = diffuseColor.rgb;
    reflectedLight.indirectSpecular = vec3( 0.0 );
#ifdef USE_AOMAP
    
    float ambientOcclusion = ( texture2D( aoMap, vUv2 ).r - 1.0 ) * aoMapIntensity + 1.0;
    
    reflectedLight.indirectDiffuse *= ambientOcclusion;
    
#if defined( USE_ENVMAP ) && defined( PHYSICAL )
    
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    
    reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.specularRoughness );
    
#endif
    
#endif
    
    
    vec3 outgoingLight = reflectedLight.indirectDiffuse;
#ifdef DOUBLE_SIDED
    float flipNormal = ( float( gl_FrontFacing ) * 2.0 - 1.0 );
#else
    float flipNormal = 1.0;
#endif

#ifdef USE_ENVMAP // 1
    
//#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) // 2
    
    vec3 cameraToVertex = normalize( vWorldPosition - cameraPosition );
    
    // Transforming Normal Vectors with the Inverse Transformation
    vec3 normal = normalize(vNormal);
    vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
    
#ifdef ENVMAP_MODE_REFLECTION // 3
    
    vec3 reflectVec = reflect( cameraToVertex, worldNormal );
    
#else
    
    vec3 reflectVec = refract( cameraToVertex, worldNormal, refractionRatio );
    
#endif // 3
    
//#else
    
//    vec3 reflectVec = vReflect;
    
//#endif // 2
    
#ifdef ENVMAP_TYPE_CUBE // 2
    
    vec4 envColor = textureCube( envMap, flipNormal * vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );
    
    //envColor.rgb = packNormalToRGB(reflectVec);
    
#elif defined( ENVMAP_TYPE_EQUIREC )
    
    vec2 sampleUV;
    sampleUV.y = saturate( flipNormal * reflectVec.y * 0.5 + 0.5 );
    sampleUV.x = atan( flipNormal * reflectVec.z, flipNormal * reflectVec.x ) * RECIPROCAL_PI2 + 0.5;
    vec4 envColor = texture2D( envMap, sampleUV );
    
#elif defined( ENVMAP_TYPE_SPHERE )
    
    vec3 reflectView = flipNormal * normalize( ( viewMatrix * vec4( reflectVec, 0.0 ) ).xyz + vec3( 0.0, 0.0, 1.0 ) );
    vec4 envColor = texture2D( envMap, reflectView.xy * 0.5 + 0.5 );
    
#else
    
    vec4 envColor = vec4( 0.0 );
    
#endif // 2
    
    //envColor = envMapTexelToLinear( envColor );
    
#ifdef ENVMAP_BLENDING_MULTIPLY // 2
    
    outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
    
#elif defined( ENVMAP_BLENDING_MIX )
    
    outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
    
#elif defined( ENVMAP_BLENDING_ADD )
    
    outgoingLight += envColor.xyz * specularStrength * reflectivity;
    
#endif // 2
        
#endif // 1
    
    
    gl_FragColor = vec4( outgoingLight, diffuseColor.a );
#ifdef PREMULTIPLIED_ALPHA
    
    // Get get normal blending with premultipled, use with CustomBlending, OneFactor, OneMinusSrcAlphaFactor, AddEquation.
    gl_FragColor.rgb *= gl_FragColor.a;
    
#endif
#if defined( TONE_MAPPING )
    
    gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
    
#endif
    
#ifdef USE_FOG
    
#ifdef USE_LOGDEPTHBUF_EXT
    
    float depth = gl_FragDepthEXT / gl_FragCoord.w;
    
#else
    
    float depth = gl_FragCoord.z / gl_FragCoord.w;
    
#endif
    
#ifdef FOG_EXP2
    
    float fogFactor = whiteCompliment( exp2( - fogDensity * fogDensity * depth * depth * LOG2 ) );
    
#else
    
    float fogFactor = smoothstep( fogNear, fogFar, depth );
    
#endif
    
    gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
    
#endif
}
