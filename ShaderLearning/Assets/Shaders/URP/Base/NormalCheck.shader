Shader "Custom/URP/Base/NormalCheck"
{
    Properties
    {
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
                float3 normalOS : NORMAL;// 对象空间法线方向
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
                // 法线取值范围在 [-1, 1]，通过 normal * 0.5 + 0.5，将其映射到 [0, 1]
                OUT.color.xyz = IN.normalOS * 0.5 + 0.5;
                OUT.color.w = 1.0;
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                // 通过颜色观察法线的取值
                return IN.color;
            }

            ENDHLSL
        }
    }
}
