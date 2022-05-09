Shader "Custom/URP/Base/Noise"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry" }

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
                float2 uv : TEXCOORD0;// 第一套纹理坐标
            };

            // 低成本 Noise 函数，简单的伪随机
            float RandomNoise(float2 seed)
            {
                return frac(sin(dot(seed, float2(12.9898, 78.233)))*43758.5453);
            }

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                //噪波一般通过采样单通道的由其他软件生成的噪波图实现
                //常见噪波类型记录一下 Perlin Noise、Simplex Noise、Wavelet Noise、Value Noise、Worley Noise
                //ShaderGraph的生成代码中有现成的算法可以使用
                //因为程序化生成上述噪波计算量过大，所以这里使用一个简单的伪随机来程序化生成噪点
                //RandomNoise(floor(IN.uv * _BlockSize));可以生成块状的随机区域
                float n = RandomNoise(IN.uv);
                return half4(n, n, n, n);
            }
            ENDHLSL
        }
    }
}
