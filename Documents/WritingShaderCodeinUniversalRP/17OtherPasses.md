# Other Passes

There are other passes that the Universal RP uses , such as the **ShadowCaster** , **DepthOnly** , **DepthNormals**(v10+) and **Meta** passes . We can also create passes with a custom LightMode tag , discussed in the earlier *Multi-Pass* section.

## ShadowCaster

The pass tagged with *`"LightMode"="ShadowCaster"`* is responsible for allowing the object to cast realtime shadows .

In a section earlier I mentioned that *`UsePass`* could be used to trigger the shader to use a pass from a different shader , however since this breaks the SRP Batching compatibility we need to instead define the pass in the shader itself .

I find that the easiest way to handle this is let the [<u>ShadowCasterPass.hlsl</u>](https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl) do the work for us (used by shaders like URP/Lit) . It contains the Attributes and Varyings structs and fairly simple Vertex and Fragment shaders , handling the shadow bias offsets and alpha clipping/cutout .

```hlsl
// UsePass "Universal Render Pipeline/Lit/ShadowCaster"
// Breaks SRP Batcher compatibility , instead we define the pass 
// ourself :

Pass 
{
    Name "ShadowCaster"
    Tags { "LightMode"="ShadowCaster" }

    ZWrite On
    ZTest LEqual

    HLSLPROGRAM
    #pragma vertex ShadowPassVertex
    #pragma fragment ShadowPassFragment

    // Material Keywords
    #pragma shader_feature _ALPHATEST_ON
    #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

    // GPU Instancing
    #pragma multi_compile_instancing
    // (Note, this doesn't support instancing for properties though. Same as URP/Lit)
    // #pragma multi_compile _ DOTS_INSTANCING_ON
    // (This was handled by LitInput.hlsl. I don't use DOTS so haven't bothered to 
    // support it)

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
    ENDHLSL
}
```

The URP/Lit shader usually includes LitInput.hlsl , however this defines many textures that our shader might not use (which would likely be ignored/compiled out anyway) and it also includes a *`UnityPerMaterial CBUFFER`* which we've already defined in our *`HLSLINCLUDE`* . This causes redefinition errors so I'm instead including a few of the ShaderLibrary files that was included by LitInput.hlsl to make sure the pass still functions without erroring .

CommonMaterial.hlsl is mainly included because of the LerpWhiteTo function is used by Shadows.hlsl when sampling the shadowmap . SurfaceInput.hlsl is included as ShadowCasterPass.hlsl makes use of the *`_BaseMap`* and *`SampleAlbedoAlpha`* function for the alpha clipping/cutout support .