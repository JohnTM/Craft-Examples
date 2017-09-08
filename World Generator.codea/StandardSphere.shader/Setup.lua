function setup(material)
    -- Shader Options
    material:addOption("GAMMA_CORRECTION", true)
    material:addOption("STANDARD", true)
    material:addOption("USE_LIGHTING", true)
    material:addOption("USE_COLOR", true)
    material:addOption("USE_MAP", false, {"map"})
    material:addOption("USE_NORMALMAP", false, {"normalMap"})
    material:addOption("USE_ROUGHNESSMAP", false, {"roughnessMap"})
    material:addOption("USE_METALNESSMAP", false, {"metalnessMap"})
    material:addOption("USE_DISPLACEMENTMAP", false, {"displacementMap"})
    material:addOption("USE_AOMAP", false, {"aoMap"})
    material:addOption("USE_ENVMAP", false, {"envMap"})
    material:addOption("ENVMAP_TYPE_CUBE", true)
    material:addOption("ENVMAP_MODE_REFLECTION", true)
    material:addOption("USE_FOG", false)

    -- Material Properties
    material:addProperty("map", craft.material.cubeTexture, nil)

    material:addProperty("normalMap", craft.material.cubeTexture, nil)
    material:addProperty("normalScale", craft.material.vec2, vec2(-0.1,-0.1))

    material:addProperty("roughnessMap", craft.material.cubeTexture, nil)
    material:addProperty("metalnessMap", craft.material.cubeTexture, nil)

    material:addProperty("displacementMap", craft.material.cubeTexture, nil)
    material:addProperty("displacementBias", craft.material.float, 0.0)
    material:addProperty("displacementScale", craft.material.float, 1.0)

    material:addProperty("aoMap", craft.material.cubeTexture, nil)
    material:addProperty("aoMapIntensity", craft.material.float, 0.5)

    material:addProperty("envMap", craft.material.cubeTexture, nil)
    material:addProperty("envMapIntensity", craft.material.float, 1.0)
    material:addProperty("flipEnvMap", craft.material.float, 1.0)
    material:addProperty("refractionRatio", craft.material.float, 0.5)

    material:addProperty("offsetRepeat", craft.material.vec4, vec4(0,0,1,1))
    material:addProperty("diffuse", craft.material.vec3, vec3(1,1,1))
    material:addProperty("emissive", craft.material.vec3, vec3(0,0,0))
    material:addProperty("roughness", craft.material.float, 0.0)
    material:addProperty("metalness", craft.material.float, 0.0)
    material:addProperty("opacity", craft.material.float, 1.0)
end
