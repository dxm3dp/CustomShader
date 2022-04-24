# SubShader

Our Shader block can include multiple **SubShaders** . Unity will use the first SubShader block that is supported on the GPU . The **RenderPipeline** tag , as I'll explain more in the next section , should also prevent the SubShader from being chosen if the shader shouldn't be used in that pipeline , allowing a shader to have multiple versions for each pipeline .

We can also define a **Fallback** if no SubShaders are supported . If a fallback isn't used , then it'll show the magenta error shader instead .

```hlsl
Shader "Custom/UnlitShaderExample"
{
    Properties {...}
    SubShader {...}
    FallBack "Path/Name"
}
```

Later we'll define passes in each SubShader which can include HLSL code . Inside this we can specify a [<u>Shader Compile Target</u>](https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html) . Higher targets support more GPU features but might not be supported on all platforms .

For versions prior to v10 , URP used to use the following in all passes :

```hlsl
// Required to compile gles 2.0 with standard SRP library
// All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc 
// by default
#pragma prefer_hlslcc gles
#pragma exclude_renderers d3d11_9x
#pragma target 2.0
```

You can see an example of this in the [<u>URP/Lit shader(v8.3.1)</u>](https://github.com/Unity-Technologies/Graphics/blob/v8.3.1/com.unity.render-pipelines.universal/Shaders/Lit.shader) .

With v10+ , deferred support has started to be added so it appears the [<u>provided shaders</u>](https://github.com/Unity-Technologies/Graphics/tree/master/com.unity.render-pipelines.universal/Shaders) use two SubShaders instead . The first uses this for each pass :

```hlsl
#pragma exclude_renderers gles gles3 glcore
#pragma target 4.5
```

Basically meaning "use this for all platforms except OpenGL ones" . The second SubShader uses :

```hlsl
#pragma only_renderers gles glcore d3d11
#pragma target 2.0
```

As far as I can tell both SubShaders are indentical , except for these targets and the second SubShader excludes the UniversalGBuffer pass , used for [<u>deferred rendering</u>](https://docs.unity3d.com/Manual/RenderTech-DeferredShading.html) , likely because it can't be supported on those platforms at this time (note that link is for the built-in pipeline's deferred rendering , but the technique is the same ) . For this post/turotial I'm not including this target stuff but it might be important if you're supporting deferred and targetting OpenGL platforms to split it into two SubShaders like the [<u>URP/Lit.shader(v10.5.0)](https://github.com/Unity-Technologies/Graphics/blob/v10.5.0/com.unity.render-pipelines.universal/Shaders/Lit.shader) .