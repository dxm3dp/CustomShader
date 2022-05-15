Shader "Custom/URP/Lighting/HalfLambert"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;// 对象空间顶点坐标
                float3 normalOS : NORMAL;// 对象空间法线方向
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                float3 normalWS : TEXCOORD0;// 世界空间法线方向
            };

            half LightingHalfLambert(half3 lightDirWS, half3 normalWS)
            {
                // NdotL 的范围在 [0.0, 1.0]
                // NdotL * 0.5 + 0.5 把亮度映射到[0.5, 1.0]，起到了背面提亮的效果。
                // 2.0 作为经验参数，也可随意调整。
                half NdotL = saturate(dot(normalWS, lightDirWS));
                half halfLambert = pow(NdotL * 0.5 + 0.5, 2.0);
                return halfLambert;
            }

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                Light light = GetMainLight();
                half3 lightColor = light.color * light.distanceAttenuation;
                half halfLambert = LightingHalfLambert(light.direction, normalize(IN.normalWS));
                half3 diffuseColor = halfLambert * lightColor;
                half4 totalColor = half4(diffuseColor.rgb, 1);
                return totalColor;
            }
            ENDHLSL
        }
    }
}
