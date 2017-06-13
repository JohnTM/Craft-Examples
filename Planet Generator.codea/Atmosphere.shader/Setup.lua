function setup(material)
    -- Shader Options
	material:addOption("USE_COLOR", true)
	material:addOption("USE_MAP", false, {"map"})
    material:addOption("USE_ENVMAP", false, {"envMap"})
    material:addOption("ENVMAP_TYPE_CUBE", true)
    material:addOption("USE_NORMALMAP", false, {"normalMap"})
    material:addOption("ENVMAP_BLENDING_MULTIPLY", true)
    material:addOption("ENVMAP_MODE_REFLECTION", true)

    -- Material Properties
    material:addProperty("map", craft.material.texture2D, nil)
    material:addProperty("diffuse", craft.material.vec3, vec3(1,1,1))
    material:addProperty("opacity", craft.material.float, 1.0)
    material:addProperty("offsetRepeat", craft.material.vec4, vec4(0,0,1,1))
    material:addProperty("envMap", craft.material.cubeTexture, nil)
    material:addProperty("reflectivity", craft.material.float, 1.0)
    material:addProperty("flipEnvMap", craft.material.float, 1.0)
    material:addProperty("normalMap", craft.material.texture2D, nil)
    material:addProperty("normalScale", craft.material.vec2, vec2(-0.1,-0.1))

end
