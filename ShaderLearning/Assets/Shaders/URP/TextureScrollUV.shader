Shader "Custom/URP/Base/TextureScrollUV"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (1, 1, 1, 1)
        _BaseMap("BaseMap", 2D) = "white" {}
        _ScrollXSpeed("X Scroll Speed", Float) = 1
        _ScrollYSpeed("Y Scroll Speed", Float) = 1
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
                float2 uv : TEXCOORD0;// 第一套纹理坐标
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
                float2 uv : TEXCOORD0;// 变换后的纹理坐标
            };

            TEXTURE2D(_BaseMap);// 定义纹理
            SAMPLER(sampler_BaseMap);// 定义纹理的采样器

            // 常量缓冲区
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;// 纹理的缩放与偏移
            half4 _BaseColor;// 基础颜色
            float _ScrollXSpeed;// X轴向滚动速度
            float _ScrollYSpeed;// Y轴向滚动速度
            CBUFFER_END

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // 进行纹理坐标变换 IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                // [UnityInput.hlsl] 
                // Time (t = time since current level load) values from Unity
                // float4 _Time; (t/20, t, t*2, t*3)
                float2 scrollUV = float2(_ScrollXSpeed, _ScrollYSpeed) * _Time.y + OUT.uv;
                OUT.uv = scrollUV;

                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
            }

            ENDHLSL
        }
    }
}
