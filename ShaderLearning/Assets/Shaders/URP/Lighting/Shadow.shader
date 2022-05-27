Shader "Custom/URP/Lighting/Shadow"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry" }

        // 正常着色
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION; 
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return half4(0, 0, 0, 1);
            }
            ENDHLSL
        }

        // 处理自己的影子形状
        pass
        {
            Name "ShadowCaster"
            Tags {"LightMode"="ShadowCaster"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                // 见 [Shadows.hlsl]
                //float3 ApplyShadowBias(float3 positionWS, float3 normalWS, float3 lightDirection)
                //{
                    //float invNdotL = 1.0 - saturate(dot(lightDirection, normalWS));
                    //float scale = invNdotL * _ShadowBias.y;

                    //// normal bias is negative since we want to apply an inset normal offset
                    //positionWS = lightDirection * _ShadowBias.xxx + positionWS;
                    //positionWS = normalWS * scale.xxx + positionWS;
                    //return positionWS;
                //}
                // 结果：positonWS = normalWS * _ShadowBias.y + positionWS;
                positionWS = ApplyShadowBias(positionWS, normalWS, float3(0, 0, 0));
                float4 positionHCS = TransformWorldToHClip(positionWS);
                // 以 WebGL 平台为例，见 [GLES3.hlsl]
                // #define UNITY_REVERSED_Z 0
                // 反向 z 的目的是
                #if UNITY_REVERSED_Z
                    positionHCS.z = min(positionHCS.z, positionHCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    positionHCS.z = max(positionHCS.z, positionHCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                OUT.positionHCS = positionHCS;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return half4(0, 0, 0, 0);
            }
            ENDHLSL
        }
    }
}
