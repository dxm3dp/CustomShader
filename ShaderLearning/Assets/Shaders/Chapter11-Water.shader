Shader "Unlit/Chapter11-Water"
{
    Properties
    {
        // 主纹理
        _MainTex ("Main Tex", 2D) = "white" {}
        // 控制整体颜色
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        // 控制水流波动的幅度
        _Magnitude ("Distortion Magnitude" , Float) = 1
        // 控制波动的频率
        _Frequency ("Distortion Frequency" , Float) = 1
        // 控制波长的倒数
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        // 
        _Speed ("Speed", Float) = 0.1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" 
            "DisableBatching"="True"}
        //LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _Magnitude;
            fixed _Frequency;
            float _InvWaveLength;
            fixed _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                // 顶点的偏移量
                float4 offset;
                // 顶点的yzw分量不发生偏移
                offset.yzw = float3(0.0, 0.0, 0.0);
                // 计算顶点x分量的便宜
                offset.x = sin(_Frequency * _Time.y + 
                    v.vertex.x * _InvWaveLength + 
                    v.vertex.y * _InvWaveLength + 
                    v.vertex.z * _InvWaveLength ) * _Magnitude;
                // 将偏移量添加到顶点坐标
                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // 添加纹理动画
                o.uv += float2( 0.0 , _Time.y * _Speed);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
