// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Practicing/SpecularPixel"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss", Range(8,256))=20
    }
    SubShader
    {
        pass{
            Tags{"LightModel"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f result;
                result.pos = UnityObjectToClipPos(v.vertex);
                result.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                result.worldPos = mul(unity_ObjectToWorld,v.vertex);

                return result;
            }

            fixed4 frag(v2f f) : SV_TARGET {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(f.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldPos.xyz);
                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, reflectDir)),_Gloss);
                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
