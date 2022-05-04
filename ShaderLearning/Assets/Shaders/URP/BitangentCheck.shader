Shader "Custom/URP/Base/BitangentCheck"
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

            struct Attributes
            {
                float4 positionOS : POSITION;// 对象空间顶点坐标
                float3 normalOS : NORMAL;// 对象空间法线方向
                float4 tangentOS : TANGENT; // 对象空间切线方向
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                half4 color : COLOR;// 顶点颜色
            };

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // IN.tangentOS.xyz 是对象空间切线方向
                // IN.tangentOS.w 决定了[副切线]方向取[法线]与[切线]叉乘结果的正方向还是反方向
                float3 bitangent = cross(IN.normalOS, IN.tangentOS.xyz) * IN.tangentOS.w;
                OUT.color.xyz = bitangent * 0.5 + 0.5;
                OUT.color.w = 1.0;
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                return IN.color;
            }
            ENDHLSL
        }
    }
}
