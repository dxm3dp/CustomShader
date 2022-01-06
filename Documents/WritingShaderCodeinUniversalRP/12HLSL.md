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

- float4x4 - 4 rows , 4 columns
- int4x3 - 4 rows , 3 columns
- half2*1 - 2 rows , 1 column
- float1x4 - 1 row , 4 columns

Matrix are used for transforming between different spaces . If you aren't very familiar with them , I'd recommend looking at [this tutorial by CatlikeCoding](https://catlikecoding.com/unity/tutorials/rendering/part-1/) .

Unity has built-in transformation matrices which are used for transforming between common spaces , such as :

- UNITY_MATRIX_M (or Unity_ObjectToWorld) - **Model** Matrix , Converts from Object space to World space .
- UNITY_MATRIX_V - **View** Matrix , Converts from world space to View space
- UNITY_MATRIX_P - **Projection** Matrix , Converts from View space to Clip space
- UNITY_MATRIX_VP - **View Projection** Matrix , Converts from World space to Clip space .

Also inverse versions :




