Shader "Custom/URP/Base/AlphaTest"
{
    Properties
    {
        [Toggle(_ALPHATEST_ON)]_AlphaTestEnable("AlphaTest Enable", Float) = 1.0
        _AlphaTestTexture("AlphaTest Texture", 2D) = "white" {}
        _ClipThreshold("AlphaTest Threshold", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="AlphaTest" }
        // AlphaTest = 2450

        Pass
        {
            HLSLPROGRAM

            // local 作用域，只影响 fragment 着色器
            #pragma shader_feature_local_fragment _ALPHATEST_ON

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

            TEXTURE2D(_AlphaTestTexture);// 定义纹理
            SAMPLER(sampler_AlphaTestTexture);// 定义纹理的采样器

            // 常量缓冲区
            CBUFFER_START(UnityPerMaterial)
            float4 _AlphaTestTexture_ST;// 存储纹理的缩放与平移
            float _ClipThreshold;
            CBUFFER_END

            // 顶点着色器
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _AlphaTestTexture);
                return OUT;
            }

            // 片元着色器
            half4 frag(Varyings IN) : SV_TARGET
            {
                half alpha = SAMPLE_TEXTURE2D(_AlphaTestTexture, sampler_AlphaTestTexture, IN.uv).r;
                 
                // [ShaderVariablesFunctions.hlsl]
                // void AlphaDiscard(real alpha, real cutoff, real offset = 0.0h)
                // {
                // #ifdef _ALPHATEST_ON
                    //clip(alpha - cutoff + offset);
                // #endif
                // }
                AlphaDiscard(alpha, _ClipThreshold);
                return half4(1, 1, 1, 1);
            }

            ENDHLSL
        }
    }
}
