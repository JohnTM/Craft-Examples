//
// A basic fragment shader
//

//Default precision qualifier
precision highp float;

//This represents the current texture on the mesh
uniform lowp sampler2D texture;
uniform lowp sampler2D ramp;

//The interpolated vertex color for this fragment
varying lowp vec4 vColor;

//The interpolated texture coordinate for this fragment
varying highp vec2 vTexCoord;

void main()
{
    //Sample the texture at the interpolated coordinate

    lowp vec4 col = texture2D( texture, vTexCoord ) * vColor;
    lowp vec4 r = texture2D(ramp, vec2(clamp(col.r, 0.01, 0.99), 0.5));
    
    //Set the output color to the texture color
    gl_FragColor = r;
}
