# HLSL

Shader code is written using the High Level Shading Language (HLSL) in Unity .

## HLSLPROGRAM & HLSLINCLUDE

Inside each ShaderLab Pass , we define blocks for HLSL code using HLSLPROGRAM and ENDHLSL tags . Each of these blocks must include a Vertex and Fragment shader . We use the `#pragma vertex/fragment` to set which function is going to be used .

For built-in pipeline shaders "vert" and "frag" are the most common names , but they can be anythings. For URP , it tends to use functions like "UnlitPassVertex" and "UnlitPassFragment" which is a bit more descriptive of what the shader pass is doing .

Inside the SubShader we can also use HLSLINCLUDE to include the code **in every Pass inside that SubShader** . This is very useful for writing shaders in URP as every pass needs to use the same `UnityPerMaterial CBUFFER` to have compatibility with the SRP Batcher and this helps us reuse the same code for every pass instead of needing to define it separately . We could alternatively use a separate include file instead too .

```shader
SubShader
{
    Tags {"RenderPipeline"="UniversalPipeline" "Queue"="Geometry"}

    HLSLINCLUDE
    ...
    ENDHLSL

    Pass
    {
        Name "Forward"
	// LightMode tag . Using default here as the shader is Unlit
	// Cull, ZWrite, ZTest, Blend, etc

	HLSLPROGRAM
	#pragma vertex UnlitPassVertex
	#pragma fragment UnlitPassFragment
	...
	ENDHLSL
    }
}
```

We'll discuss the contents of these code block later . For now , we need to go over some basics of HLSL which is impottant to know to be able to understand the later sections .

## Variables

In HLSL , we have a few different variable types , the most common consisting of Scalars , Vectors and Materials . There's also special objects for Textures/Samplers . Arrays and Buffers also exist for passing more data into the shader .

### Scalar

The scalar types include :

- bool - true or false .
- float - 32 bit floating point number . Generally used for world space positions , texture coordinates , or scalar computations involving complex functions such as trigonometry or power/exponentiation .
- half - 16 bit floating point number . Generally used for short vectors , directions , object space positions , colours .
- double - 64 bit floating point number . Cannot be used as inputs/outputs , see note here .
- real - Used in URP/HDRP when a function can support either half or float . It defaults to half (assuming they are supported on the platform) , unless the shader specifies "#define PREFER_HALF 0" , then it will use float precision . Many of the common math functions in the ShaderLibrary functions use this type .
- int - 32 bit signed integer .
- uint - 32 bit unsigned integer (except GLES2 , where this isn't supported , and is defined as an int instead) .

Also of notes :

- fixed - 11 (ish) bit fixed point number with -2 to 2 range . Generally used for LDR colours . Is something from the older CG syntax , though all platforms seem to just convert it to half now even in CGPROGRAM . HLSL does not support this but I felt it was important to mention as you'll likely see the "fixed" type used in shaders written for the Built-in RP , use half instead !

### Vector

A vector is created by appending a component size (integer from 1 to 4) to one of these scalar data types . Some examples include :

- float4 - (A float vector containing 4 floats)
- half3 - (A half vector , 3 components)
- int2 , etc
- Technically float1 would also be a one dimensional vector , but as far as I'm aware it's equivalent to float .

In order to get one of the components of a vector , we can use .x , .y , .z , or .w (or .r , .g , .b , .a instead , which makes more sense when working with colours) . We can also use .xy to obtain a vector2 and .xyz to obtain a vector3 from a higher dimensional vector .

We can even take this further and return a vector with components rearranged , which is referred to as swizzling . Here is a few examples :

```shader
float3 vector = float3(1, 2, 3);

float3 a = vector.xyz; // or .rgb,  a = (1, 2, 3)
float3 b = vector.zyx; // or .bgr,  b = (3, 2, 1)
float3 c = vector.xxx; // or .rrr,  c = (1, 1, 1)
float2 d = vector.zy;  // or .bg,   d = (3, 2)
float4 e = vector.xxzz; // or .rrbb, e = (1, 1, 3, 3)
float f = vector.y; // or .g,  f = 2

// Note that mixing xyzw/rgba is not allowed .
```

### Matrix

A matrix is created by appending two sizes (integers between 1 and 4) to the scalar , separated by an "x" . The first integer is the number of **rows** , while the second is the number of **columns** in the matrix . For example :

- `float4x4` - 4 rows , 4 columns
- `int4x3` - 4 rows , 3 columns
- `half2*1` - 2 rows , 1 column
- `float1x4` - 1 row , 4 columns

Matrix are used for transforming between different spaces . If you aren't very familiar with them , I'd recommend looking at [this tutorial by CatlikeCoding](https://catlikecoding.com/unity/tutorials/rendering/part-1/) .

Unity has built-in transformation matrices which are used for transforming between common spaces , such as :

- `UNITY_MATRIX_M` (or `unity_ObjectToWorld`) - **Model** Matrix , Converts from Object space to World space .
- `UNITY_MATRIX_V` - **View** Matrix , Converts from world space to View space
- `UNITY_MATRIX_P` - **Projection** Matrix , Converts from View space to Clip space
- `UNITY_MATRIX_VP` - **View Projection** Matrix , Converts from World space to Clip space .

Also inverse versions :

- `UNITY_MATRIX_I_M` (or `unity_WorldToObject`) - **Inverse Model** Matrix , Converts from World space to Object space
- `UNITY_MATRIX_I_V` - **Inverse View** Matrix , Converts from View space to World space
- `UNITY_MATRIX_I_P` - **Inverse Projection** Matrix , Converts from Clip space to View space
- `UNITY_MATRIX_I_VP` - **Inverse View Projection** Matrix , Converts from Clip space to World space

While you can use these matrices to convert between spaces via matrix multiplication (e.g. `mul(matrix, float4(position.xyz, 1))`) , there is also helper function in the SRP Core ShaderLibrary [SpaceTransforms.hlsl](https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl) .

Something to be aware of is when dealing with matrix multiplication , the order is important . Usually the matrix will be in the first input and the vector in the second . A Vector in the second input is treated like a Matrix consisting of up to 4 rows (depending on the size of the vector) , and a single column . A Vector in the first input is instead treated as a Matrix consisting of 1 row and up to 4 columns .

Each component in the matrix can also be accessed using either of the following : The zero-based row-column position :

- ._m00, ._m01, ._m02, ._m03
- ._m10, ._m11, ._m12, ._m13
- ._m20, ._m21, ._m22, ._m23
- ._m30, ._m31, ._m32, ._m33

The one-based row-column position:

- ._m11, ._m12, ._m13, ._m14
- ._m21, ._m22, ._m23, ._m24
- ._m31, ._m32, ._m33, ._m34
- ._m41, ._m42, ._m43, ._m44

The zero-based array access notation:

- [0][0], [0][1], [0][2], [0][3]
- [1][0], [1][1], [1][2], [1][3]
- [2][0], [2][1], [2][2], [2][3]
- [3][0], [3][1], [3][2], [3][3]

With the first two options , you can also use swizzling . e.g. `._m00_m11` or `._11_22` .

Of note , `._m03_m13_m23` corresponds to the translation part of each matrix . So `UNITY_MATRIX_M._m03_m13_m23` gives you the World space postion of the origin of the GameObject , (assuming there is no static/dynamic batching involved for reasons explained in my [Intro to Shaders post](https://www.cyanilux.com/tutorials/intro-to-shaders/#material-instances) .

### Texture Objects

Textures store a colour for each **texel** - basically the same as a pixel , but they are known as texels (short for texture elements) when referring to textures and they also aren't limited to just two demensions .

The fragment shader stage runs on a per-fragment/pixel basis , where we can access the colour of a texel with a given coordinate . Textures can have different sizes (widths/heights/depth) , but the coordinate used to sample the texture is normalised to a 0-1 range . These are known as Texture Coordinates or UVs . (where U corresponds to the horizontal axis of the texture , while V is the vertical . Sometimes you'll see UVW where W is the third dimension / depth slice of the texture) .

The most common texture is a 2D one , which can be defined in URP using the following macros in the global scope (outside any functions) :

```shader
TEXTURE2D(textureName);
SAMPLE(sampler_textureName);
```

For each texture object we also define a [SampleState](https://docs.unity3d.com/Manual/SL-SamplerStates.html) which contains the wrap and filter modes from the texture's import settings . Alternatively , we can define an inline sampler , e.g. `SAMPLER(sampler_linear_repeat)` .

#### Filter Modes

- **Point** (or Nearest-Point) : The colour is taken from the nearest texel . The result is blocky/pixellated , but that if you're sampling pixel art you'll likely want to use this .
- **Linear / Bilinear** : The colour is taken as a weighted average of close texels , based on the distance to them .
- **Trilinear** : The same as Linear/Bilinear , but it is also blends between mipmap levels .

#### Wrap Modes

- **Repeat** : UV values outside of 0-1 will cause the texture to tile/repeat .
- **Clamp** : UV values outside of 0-1 are clamped , causing the edges of the texture to stretch out .
- **Mirror** : The texture tiles/repeats while also mirroring at each integer boundary .
- **Mirror Once** : The texture is mirrored once , then clamps UV values lower than -1 and higher than 2 .

Later in the fragment shader we use another macro to sample the Texture2D with a uv coordinate that would also be passed through from the vertex shader :

```shader
float4 color = SAMPLE_TEXTURE2D(textureName, sampler_textureName, uv);
// Note, this can only be used in fragment as it calculates the mipmap level used .
// If you need to sample a texture in the vertex shader, use the LOD version
// to specify a mipmap (e.g. 0 for full resolution) :
float4 color = SAMPLE_TEXTURE2D_LOD(textureName, sampler_textureName, uv, 0);
```

Some other texture types include : Texture2DArray , Texture3D , TextureCube (known as a Cubemap outside of the shader) & TextureCubeArray , each using the following macros :

```shader
// Texture2DArray
TEXTURE2D_ARRAY(textureName);
SAMPLER(sampler_textureName);
// ...
float4 color = SAMPLE_TEXTURE2D_ARRAY(textureName, sampler_textureName, uv, index);
float4 color = SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, sampler_textureName, uv, lod);

// Texture3D
TEXTURE3D(textureName);
SAMPLER(sampler_textureName);
// ...
float4 color = SAMPLE_TEXTURE3D(textureName, sampler_textureName, uvw);
float4 color = SAMPLE_TEXTURE3D_LOD(textureName, sampler_textureName, uvw, lod);
// uses 3D uv coord (commonly referred to as uvw)

// TextureCube
TEXTURECUBE(textureName);
SAMPLER(sampler_textureName);
// ...
float4 color = SAMPLE_TEXTURECUBE(textureName, sampler_textureName, dir);
float4 color = SAMPLE_TEXTURECUBE_LOD(textureName, sampler_textureName, dir, lod);
// uses 3D uv coord (named dir here, as it is typically a direction)

// TextureCubeArray
TEXTURECUBE_ARRAY(textureName);
SAMPLER(sampler_textureName);
// ...
float4 color = SAMPLE_TEXTURECUBE_ARRAY(textureName, sampler_textureName, dir, index);
float4 color = SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, sampler_textureName, dir, lod);
```

