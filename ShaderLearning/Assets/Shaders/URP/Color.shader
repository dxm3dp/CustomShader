Shader "Custom/URP/Base/Color"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry"}
        // Geometry = 2000

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 顶点着色方法的输入数据
            struct Attributes
            {
                float4 positionOS : POSITION;// 对象空间顶点坐标
            };

            // 顶点着色方法的输出数据
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 裁剪空间顶点坐标 Homogeneous Coordinate Space
            };

            // 常量缓冲区 Constant Buffer
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            CBUFFER_END

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // 将顶点坐标由对象空间变换到齐次裁剪空间
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            // 片段着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}
