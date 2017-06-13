#extension GL_OES_standard_derivatives : enable
//
// A basic fragment shader
//

//Default precision qualifier
precision highp float;

//This represents the current texture on the mesh
uniform lowp sampler2D texture;

//The interpolated vertex color for this fragment
varying lowp vec4 vColor;

//The interpolated texture coordinate for this fragment
varying highp vec2 vTexCoord;

uniform vec3 right;
uniform vec3 up;
uniform vec3 forward;
uniform vec2 strength; 


vec3 packNormalToRGB( const in vec3 normal ) 
{
    return normalize( normal ) * 0.5 + 0.5;
}

vec3 unpackRGBToNormal( const in vec3 rgb ) 
{
    return 1.0 - 2.0 * rgb.xyz;
}

mat3 jacobian(float s, float t, float h)
{
    float w = length(vec3(s,t,1.0));
    float w2 = w*w;
    float w3 = w*w*w;
    float s2 = s*s;
    float t2 = t*t;
    
    vec3 c1 = vec3(h / w * (1.0-s2/w2), -s*t*h/w3, s/w);
    vec3 c2 = vec3(-s*t*h/w3, h/w*(1.0-t2/w2), t/w);
    vec3 c3 = vec3(-s*h/w3, -t*h/w3, 1.0/w);   
        
    return mat3(vec3(c1.x, c2.x,c3.x), vec3(c1.y, c2.y,c3.y), vec3(c1.z, c2.z,c3.z));
}

mat3 jacobian2(float s, float t, float h)
{  
    vec3 n = normalize( vec3(s,t,h) );  
    vec3 n2 = vec3(1.0,0.0,0.0);
    vec3 tv = cross(n, n2);
    vec3 tu = cross(tv,n);
    tv = cross(tu,n);
 
    return mat3(-tu, tv, n);
}

void main()
{   
    vec2 dx = dFdx(vTexCoord);
    vec2 dy = dFdy(vTexCoord);    
    
    vec4 x1 = texture2D( texture, vTexCoord - dx );
    vec4 x2 = texture2D( texture, vTexCoord + dx );
    vec4 y1 = texture2D( texture, vTexCoord - dy );
    vec4 y2 = texture2D( texture, vTexCoord + dy );    
    
    float sx = (x2.r - x1.r);
    float sy = (y2.r - y1.r);
      
    vec2 st = vec2(dx.x, dy.y) + vTexCoord * (1.0 - 2.0 * vec2(dx.x, dy.y));
    
    float s = (st.s - 0.5) * 2.0;
    float t = (st.t - 0.5) * 2.0;       
    float h = 1.0;

    mat3 j = jacobian2(s,t,h);
    j = jacobian(s,t,h);   
    
    vec3 tu = j * normalize( vec3(1.0, 0, sx * strength.x) );
    vec3 tv = j * normalize( vec3(0.0, 1.0, sy * strength.y) );
    
    vec3 n = cross(tu, tv) ;
    vec3 tn = right * n.x + up * -n.y + forward * n.z;

    //Set the output color to the texture color
    // gl_FragColor = vec4(sx, sx, sx, 1.0);
    gl_FragColor =  vec4(packNormalToRGB(tn), 1.0);
}
