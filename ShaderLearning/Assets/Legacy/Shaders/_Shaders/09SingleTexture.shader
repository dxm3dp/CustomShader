// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/09SingleTexture" {
	Properties{
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader{
        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            //
            struct a2v{
                float4 vertex : POSITION;//模型空间下的顶点坐标
                float3 normal : NORMAL;//模型空间下的法线方向
                float4 texcoord : TEXCOORD0;//模型的第一组纹理坐标
            };
            //
            struct v2f{
                float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
                float3 worldNormal : TEXCOORD0;//法线方向
                float3 worldPos : TEXCOORD1;//顶点坐标
                float2 uv : TEXCOORD2;//uv坐标
            };

            v2f vert(a2v v) {
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.worldNormal = UnityObjectToWorldNormal(v.normal);
                f.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                f.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return f;
            }

            fixed4 frag(v2f f ) : SV_TARGET {
                fixed3 worldNormal = normalize(f.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));

                fixed3 albedo = tex2D(_MainTex, f.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
}
