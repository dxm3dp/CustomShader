Shader "Custom/URP/Base/TangentCheck"
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
                float4 tangentOS : TANGENT;// 对象空间切线方向
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                float4 color : COLOR;// 顶点颜色
            };

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // 对象空间切线取值范围在 [-1, 1]，通过 tangent * 0.5 + 0.5，将其映射到 [0, 1]
                OUT.color = IN.tangentOS * 0.5 + 0.5;
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
