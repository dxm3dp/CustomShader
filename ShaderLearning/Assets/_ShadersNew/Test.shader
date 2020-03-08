// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Test"
{
    Properties
    {
        
    }
    SubShader
    {
        pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            struct a2v{
                float4 vertex : POSITION;//模型空间顶点坐标
                float3 normal : NORMAL;//模型空间法线方向
                float4 texcoord : TEXCOORD0;//模型第一套纹理坐标
            };

            struct v2f {
                float4 pos : SV_POSITION;//裁剪空间坐标
                fixed3 color : COLOR0;//?
            };

            v2f vert(a2v v ) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            float4 frag(v2f i) : SV_Target{
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
