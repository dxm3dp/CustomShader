Shader "Custom/URP/Lighting/Lambert"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry"}

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
                float3 normalWS : TEXCOORD0;// 将世界空间法线方向存储至第一套纹理坐标
            };

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
                // [Lighting.hlsl]
                //Light GetMainLight()
                //{
                    //Light light;
                    //light.direction = _MainLightPosition.xyz;
                    //light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
                    //light.shadowAttenuation = 1.0;
                    //light.color = _MainLightColor.rgb;
                    //return light;
                //}
                Light light = GetMainLight();
                // 计算光源颜色
                half3 lightColor = light.color * light.distanceAttenuation;
                // 计算漫反射光颜色
                half3 diffuseColor = LightingLambert(lightColor, light.direction, normalize(IN.normalWS));
                half4 color = half4(diffuseColor.rgb, 1.0);
                return color;
            }
            ENDHLSL
        }
    }
}
