// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Practicing/NormalMapWorldSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
       _MainTex("Main Tex", 2D) = "white"{}
       _BumpTex("Normal Map", 2D) = "bump"{}
       _BumpScale("Bump Scale", float) = 1
       _Specular("Specular", Color) = (1,1,1,1)
       _Gloss("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        pass{
            Tags{"LightModel"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v) {
                v2f result;
                result.pos = UnityObjectToClipPos(v.vertex);
                result.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                result.uv.zw = v.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 worldTangent = normalize( UnityObjectToWorldDir(v.tangent.xyz));
                fixed3 worldBinormal = normalize( cross(worldNormal, worldTangent) * v.tangent.w);
                result.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                result.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                result.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return result;
            }

            fixed4 frag(v2f f) : SV_TARGET{
                float3 worldPos = float3(f.TtoW0.w, f.TtoW1.w, f.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 tangentNormal = UnpackNormal( tex2D(_BumpTex, f.uv.zw));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1- saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                fixed3 worldNormal = normalize(half3(dot(f.TtoW0.xyz, tangentNormal), 
                dot(f.TtoW1.xyz, tangentNormal), dot(f.TtoW2.xyz, tangentNormal)));

                fixed3 albedo = tex2D(_MainTex, f.uv.xy) * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }

            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
