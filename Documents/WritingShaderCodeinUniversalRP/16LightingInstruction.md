# Lighting Introduction

In the built-in pipeline , custom shaders that required lighting/shading was usually handled by **Surface Shaders** . These had the option to choose which lighting model to use , either the physically-based **Standard/StandardSpecular** or **Lambert** (diffuse) **BlinnPhone** (specular) models . You could also write custom lighting models , which you would use if you wanted to produce a toon shaded result for example .

The Univeral RP does not support surface shaders , however the ShaderLibrary does provide functions to help handle a lot of the lighting calculations for us . These are contained in Lighting.hlsl - (which isn't included automatically with Core.hlsl , it must be included separately) .

There are even functions inside that lighting file that can completely handle lighting for us , including **UniversalFragmentPBR** and **UniversalFragmentBlinnPhong** . These functions are really useful but there is still some setup involved , such as the InputData and SurfaceData structures that need to be passed into the functions .

We'll need a bunch of exposed Properties (which should also be added to the CBUFFER) to be able to send data into the shader and alter it per-material . You can check the templates for the exact properties used - for example , [<u>PBRLitTemplate</u>](https://github.com/Cyanilux/URP_ShaderCodeTemplates/blob/main/URP_PBRLitTemplate.shader).

There's also keywords that need to be defined before including the Lighting.hlsl file , to ensure the functions handle all the calculations we want , such as shadows and baked lighting . It's common for a shader to also include some shader feature keywords (not included below but see template) to be able to toggle features , e.g. to avoid unnecessary texture samples and make the shader cheaper .

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
// Note , v11 changes this to :
// #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION

#pragma multi_compile_fog
#pragma multi_compile_instancing

// Include Lighting.hlsl
#include "Packages/com.unity.render-pipeline.universal/ShaderLibrary/Lighting.hlsl
```

## Surface Data & Input Data

Both of these *`UniversalFragmentPBR / UniversalFragmentBlinnPhong`* functions use two structures to pass data through : *`SurfaceData`* and *`InputData`* .

The **SurfaceData** struct is responsible for sampling textures and providing the same inputs as you'd find on the URP/Lit shader . Specifically it contains the following :

```hlsl
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half metallic;
    half smoothness;
    half3 normalTS;
    half3 emission;
    half occlusion;
    half alpha;

    // And added in v10 :
    half clearCoatMask;
    half clearCoatSmoothness;
};
```

Note that you don't need to include this code , as this struct is part of the ShaderLibrary and we can instead include the file it is contained in . Prior to v10 , the struct existed in [<u>SurfaceInput.hlsl</u>](https://github.com/Unity-Technologies/Graphics/blob/v8.3.1/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl) but the functions in Lighting.hlsl did not actually make use of it .

While you could still use the struct , you would instead need to do :

```hlsl
half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, 
surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha);
```

In v10+ the struct moved to it's own file , [<u>SurfaceData.hlsl</u>](https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl) , and the *`UniversalFragmentPBR`* function was updated so we can simply pass both structs through instead (for the *`UniversalFragmentBlinnPhone`* function a SurfaceData version is being added in v12 but current versions will need to split it . Examples shown later) .

```hlsl
half4 color = UniversalFragmentPBR(inputData, surfaceData);
```

We can still include **SurfaceInput.hlsl** instead though , as SurfaceData.hlsl will automatically be included by that file too , and it also contains the *`_BaseMap`* , *`_BumpMap`* and *`_EmissionMap`* texture definitions for us and some functions to assist with sampling them . We'll of course still need the Lighting.hlsl include too in order to have access to those functions .

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
```

The **InputData** struct is used to pass some extra things through that are required for lighting calculations . In v10 , includes the following :

```hlsl
struct InputData
{
    float3 positionWS;
    half3 normalWS;
    half3 viewDirectionWS;
    float4 shadowCoord;
    half fogCoord;
    half3 vertexLighting;
    half3 bakedGI;
    float2 normalizedScreenSpaceUV;
    half4 shadowMask;
};
```

Again , we don't need to include this code as it's already in [<u>Input.hlsl</u>](https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl) and that's automatically included when we include Core.hlsl anyway .

Since the lighting functions use these structs , we'll need to create them and set each variable it contains . To be more organised , we should do this in separate functions then call them in the fragment shader . The exact contents of the functions can vary slightly depending on what is actually needed for the lighting model .

For now I'm leaving the functions blank to first better see how the file is structured . The next few sections will go through the contents of the *`InitializeSurfaceData`* and *`InitializeInputData`* functions .

```hlsl
// Includes
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

// Attributes, Varyings, Texture definitions etc.
// ...

// Functions
// ...

// SurfaceData & InputData
void InitializeSurfaceData(Varyings IN, out SurfaceData surfaceData){
    surfaceData = (SurfaceData)0; // avoids "not completely initalized" errors
    // ...
}

void InitializeInputData(Varyings IN, half3 normalTS, out InputData inputData) {
    inputData = (InputData)0; // avoids "not completely initalized" errors
    // ...
}

// Vertex Shader
// ...

// Fragment Shader
half4 LitPassFragment(Varyings IN) : SV_Target
{
    // Setup SurfaceData
    SurfaceData surfaceData;
    InitializeSurfaceData(IN, surfaceData);

    // Setup InputData
    InputData inputData;
    InitializeInputData(IN, surfaceData.normalTS, inputData);

    // Lighting Model, e.g.
    half4 color = UniversalFragmentPBR(inputData, surfaceData);

    // or
    // half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData); // v12 only
    // half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData.albedo, half4(surfaceData.specular, 1), 
    // surfaceData.smoothness, surfaceData.emission, surfaceData.alpha);

    // or something custom

    // Handle Fog
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    return color;
}
```

It's also not too important that the functions are void as far as I'm aware . We could instead return the struct itself . I kinda prefer it that way , but I thought I'd try keeping it more consistent with how the URP/Lit shader code looks .

If you want to organise thins further , we could also move all the functions to **separate.hlsl** files and use a *`#include`* for it . This would also allow you to reuse that code for multiple shaders , and the Meta pass if you need to support that (discussed in more detail in a later section) . At the very least , I'd recommend having a hlsl file containing *`InitializeSurfaceData`* and it's required fcuntions / texture definitions .