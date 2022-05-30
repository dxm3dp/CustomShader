Shader "Custom/URP/Wireframe"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeColor2("Edge Color2", Color) = (1, 1, 1, 1)
        _Width("Width", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
        
        Pass
        {
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half4 _EdgeColor;
            float _Width;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                half4 color;
                // step(a, x) : 0 if x < a; 1 if x >= a
                float LowX = step(_Width, IN.uv.x);
                float LowY = step(_Width, IN.uv.y);
                float HighX = step(IN.uv.x, 1.0 - _Width);
                float HighY = step(IN.uv.y, 1.0 - _Width);
                float num = LowX * LowY * HighX * HighY;

                // num 等于 0，表示 LowX、LowY、HighX、HighY 其中有一项或几项为零，即片元位于线框显示区域内
                // num 等于 1，表示 LowX、LowY、HighX、HighY 全为 1，即片元位于镂空区域内
                color = lerp(_EdgeColor, _Color, num);

                // num 等于 0，则绘制片元
                // num 等于 1，则舍弃片元
                clip((1 - num) - 0.1f);

                return color;
            }

            ENDHLSL
        }
        
        Pass
        {
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half4 _EdgeColor2;
            float _Width;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                half4 color;
                //step(a, x) : 0 if x < a; 1 if x >= a
                float LowX = step(_Width, IN.uv.x);
                float LowY = step(_Width, IN.uv.y);
                float HighX = step(IN.uv.x, 1.0 - _Width);
                float HighY = step(IN.uv.y, 1.0 - _Width);
                float num = LowX * LowY * HighX * HighY;
                color = lerp(_EdgeColor2, _Color, num);

                clip((1 - num) - 0.1f);
                return color;
            }

            ENDHLSL
        }
    }
}
