Shader "Custom/URP/Base/VertexAnimation"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (1, 1, 1, 1)
        _Speed("Speed", Float) = 1.0
        _MaxHeight("Max Height", Float) = 1.0
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
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
            };

            // 常量缓冲区
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;// 基础颜色
            float _Speed;// 速度
            float _MaxHeight;// 最大高度
            CBUFFER_END

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // 将顶点坐标从对象空间变换到世界空间
                // [SpaceTranforms.hlsl]
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                // 利用 sin 或 cos 等周期函数来实现循环往复的数据变化，然后对世界空间中的顶点坐标进行偏移
                // 这里使用偏移世界空间Y轴来实现弹跳效果，这一句是实现效果的关键代码
                float3 positionOffset = positionWS + abs(sin(_Time.y * _Speed) * float3(0, _MaxHeight, 0));
                // 将顶点坐标从世界空间变换到齐次裁剪空间
                // [SpaceTransforms.hlsl]
                OUT.positionHCS = TransformWorldToHClip(positionOffset);
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                return _BaseColor;
            }

            ENDHLSL
        }
    }
}
