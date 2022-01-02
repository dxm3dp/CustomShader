# ShaderLab

Shader files in Unity are written using two languages . A unity-specific ShaderLab language is used define the shader properties , subshaders and passes , while actual shader code is written in HLSL(High Level Shading Language).

The ShaderLab syntax hasn't changed much compare to the built-in pipeline . Unity provides some documentation but I'm going over some important parts of it here too . If you are already familiar with ShaderLab you'll mainly want to read the **Render Pipeline** , **LightMode Tag** , and **Multi Pass** sctions .

All shaders start with the **Shader** block , which includes a path and name to determine how it appears in the dropdown when changing the shader on the Material in the Inspector window .

```shader
Shader "Custom/UnlitShaderExample"
{
    ...
}
```

Other blocks will go inside here , including a Properties block and various Subshader blocks .