Shader "Unlit/Chapter11-ImageSequenceAnimation"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Image Sequence", 2D) = "white" {}
        // 水平方向关键帧图像数
        _HorizontalAmount("Horizontal Amount", float) = 4
        // 竖直方向关键帧图像数
        _VerticalAmount("Vertical Amount", float) = 4
        // 序列帧动画的播放速度
        _Speed("Speed", Range(1, 100)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
            };

            // 顶点着色器方法
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // 片元着色器方法
            fixed4 frag (v2f i) : SV_Target
            {
                // 计算时间因子
                float time = floor(_Time.y * _Speed);
                // 计算当前关键帧图像的行索引
                float row = floor(time / _HorizontalAmount);
                // 计算当前关键帧图像的列索引
                float column = time - row * _VerticalAmount;
                // 计算一个关键帧图像的uv坐标范围
                half2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount);
                // 计算当前关键帧图像uv坐标的x分量
                uv.x += column/_HorizontalAmount;
                // 计算当前关键帧图像uv坐标的y分量
                uv.y -= row/_VerticalAmount;
                // 对序列帧纹理进行采样
                fixed4 c = tex2D(_MainTex, uv);
                c.rgb *= _Color;

                return c;
            }
            ENDCG
        }
    }
}
