Shader "Custom/URP/Base/Texture"
{
    Properties
    {
        [MainColor] _BaseColor("BaseColor", Color) = (1, 1, 1, 1) 
        [MainTexture] _BaseMap("BaseMap", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry"}

        pass
        {
            HLSLPROGRAM 
            #pragma vertex vert 
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;// 对象空间顶点坐标
                float2 uv : TEXCOORD0;// 第一套纹理坐标
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                float2 uv : TEXCOORD0;// 第一套纹理坐标
            };

            TEXTURE2D(_BaseMap);// 定义纹理
            SAMPLER(sampler_BaseMap);// 定义纹理的采样器

            // 常量缓冲区
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;// 定义纹理的缩放与偏移
            half4 _BaseColor;// 定义基础颜色
            CBUFFER_END

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // 将顶点坐标从对象空间变换到齐次裁剪空间
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // 进行纹理坐标变换 IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw
                // [Macros.hlsl] #define TRANSFORM_TEX(tex, name) ((tex.xy) * name##_ST.xy + name##_ST.zw)
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                // 纹理采样结果 * 基础颜色
                // 
                return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
            }

            ENDHLSL
        }
    }
}
