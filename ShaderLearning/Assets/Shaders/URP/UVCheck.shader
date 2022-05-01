Shader "Custom/URP/Base/UVCheck"
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
                float2 uv : TEXCOORD0;// 第一套 UV 坐标
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                float2 uv : TEXCOORD0;// 第一套 UV 坐标
            };

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // 将顶点坐标由对象空间变换到齐次裁剪空间
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // 记录原始 UV
                OUT.uv = IN.uv;
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                // UV 坐标显示为红色和绿色，蓝色应用于 0-1 范围之外的坐标
                // 1.模型没有 UV 信息，c = (0, 0, 0, 0)，最终输出颜色为(0, 0, 0, 0)
                // 2.模型 UV 在 [0, 1]范围，最终输出颜色为(c.x, c.y, 0, 0)
                // 3.模型 UV 超出 [0, 1]范围，最终输出颜色为(c.x, c.y, 0.5, 0)

                float4 uv = float4(IN.uv.xy, 0, 0);
                // 取 uv 变量的小数部分
                half4 c = frac(uv);
                // saturate 方法相当于 damp(x, 0, 1)
                // any 方法检查参数的每一个分量，有任一分量不为零则返回 true，否则返回 false
                if (any(saturate(uv) - uv))
                    c.b = 0.5;

                return c;
            }
            ENDHLSL
        }
    }
}
