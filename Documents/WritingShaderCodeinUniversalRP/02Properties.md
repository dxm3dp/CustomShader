# Properties

The Properties block is for any values that need to be exposed to the Material Inspector , so that we can use the same shader for materials with different textures/colours for example .

```shader
Properties
{
    _BaseMap("Base Texture", 2D) = "white" {}
    _BaseColor("Base Colour", Color) = (0, 0.66, 0.73, 1)
}
```

We can also change these properties from C# scripts(e.g. using material.SetColor / SetFloat / SetVector / etc). If the properties will different per material , we must include them in the Properies block as well as the UnityPerMaterial CBUFFER to support the SRP Batcher correctly , which explained later .

If all shaders should share the same value , then we don't have to expose them here . Instead we only define them later in the HLSL code . We can still set them from C# using Shader.SetGlobalColor / SetGlobalFloat / SetGlobalVector / etc .
