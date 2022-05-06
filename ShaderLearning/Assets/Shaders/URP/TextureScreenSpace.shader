Shader "Custom/URP/Base/TextureScreenSpace"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white" {}
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
                float4 screenPosition : TEXCOORD0;// 第一套纹理坐标
            };

            TEXTURE2D(_BaseMap);// 定义纹理
            SAMPLER(sampler_BaseMap);// 定义纹理采样器

            // 常量缓冲区
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;// 定义纹理的缩放与偏移
            CBUFFER_END

            // 顶点着色方法
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // 将对象空间顶点坐标变换到齐次裁剪空间 Canonical View Volumn
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // 根据齐次裁剪空间坐标，计算屏幕空间坐标
                // [ShaderVariablesFunction.hlsl]
                //float4 ComputeScreenPos(float4 positionCS)
                //{
                    //float4 o = positionCS * 0.5f;
                    //o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                    //o.zw = positionCS.zw;
                    //return o;
                //}
                OUT.screenPosition = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            // 片元着色方法
            half4 frag(Varyings IN) : SV_TARGET
            {
                // - 对象空间顶点坐标经过 MVP 变换后得到齐次裁剪空间坐标（也就是顶点着色器的输出）。
                // - 在 CVV(Canonical View Volumn)中进行裁剪。
                // - 执行透视除法（除以 w 分量），得到 NDC(Normalised Device Coordinate)坐标。
                // - 进行视口变换，得到屏幕空间坐标。

                // ComputeScreenPos 并没有做透视除法，所以得我们自己除 w
                // 为什么 ComputeScreenPos 没有在顶点着色器中除以 w 分量？
                // 在片段着色器中除以 w 分量的目的是为了得到准确的线性插值，因为齐次坐标是非线性数值，具体的就要查公式了

                // 执行透视除法
                float2 textureCoordinate = IN.screenPosition.xy / IN.screenPosition.w;
                // 根据屏幕宽高比，计算 UV 的适配
                float aspect = _ScreenParams.x / _ScreenParams.y;
                textureCoordinate.x = textureCoordinate.x * aspect;
                // TRANSFORM_TEX: textureCoordinate.xy * _BaseMap_Scale + _BaseMap_Translate
                textureCoordinate = TRANSFORM_TEX(textureCoordinate, _BaseMap);
                return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, textureCoordinate);
            }

            ENDHLSL
        }
    }
}
