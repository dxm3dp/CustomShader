Shader "Custom/URP/Base/Fresnel"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Power("Power", Float) = 5.0
        [Toggle] _Reflection("Reflection", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_local _ _REFLECTION_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;// 对象空间顶点坐标
                float3 normalOS : NORMAL;// 对象空间法线方向，法线加入
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                float3 normalWS : TEXCOORD0;// 世界空间法线方向存储至纹理寄存器0
                float3 viewWS : TEXCOORD1;// 世界空间视角方向存储至纹理寄存器1
            };

            // 常量缓冲区
            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Power;
            CBUFFER_END

            half Fresnel(half3 normal, half3 viewDir, half power)
            {
                // Unity 中常用的 Fresnel 近似实现 (1 - dot(n, v)) ^ power
                return pow(1.0 - saturate(dot(normalize(normal), normalize(viewDir))), power);
            }

            // 为了看到反射内容，直接采样了 ReflectionProbe 的 Cube 贴图
            half3 Reflection(float3 viewDirWS, float3 normalWS)
            {
                // ?
                float3 reflectVec = reflect(-viewDirWS, normalWS);
                // ?
                return DecodeHDREnvironment(SAMPLE_TEXTURECUBE(unity_SpecCube0, samplerunity_SpecCube0, reflectVec), unity_SpecCube0_HDR);
            }

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                // ?
                OUT.viewWS = GetWorldSpaceViewDir(positionWS);

                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                half3 normalWS = normalize(IN.normalWS);
                // ?
                half3 viewWS = SafeNormalize(IN.viewWS);
                half fresnel = Fresnel(normalWS, viewWS, _Power);
                half4 color = _Color * fresnel;
                #if defined(_REFLECTION_ON)
                    half3 cubemap = Reflection(viewWS, normalWS);
                    color.xyz *= cubemap;
                #endif

                return color;
            }
            ENDHLSL
        }
    }
}
