// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Practicing/NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="White"{}
        _BumpMap("Bump Map",2D)="Bump"{}
        _BumpScale("Bump Scale", float)=1
        _Specular("Specular", Color)=(1,1,1,1)
        _Gloss("Gloss", Range(8,256))=20
    }
    SubShader
    {
        Tags{"LightModel"="ForwardBase"}
        pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
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
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v) {
                v2f result;
                result.pos = UnityObjectToClipPos(v.vertex);
                result.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                result.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 binormal = cross(normalize( v.normal),normalize( v.tangent.xyz)) *v.tangent.w; 
                //v.tangent binormal v.normal
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                result.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                result.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return result; 
            }

            fixed4 frag(v2f f) : SV_TARGET {
                fixed3 tangentLightDir = normalize(f.lightDir);
                fixed3 tangentViewDir = normalize(f.viewDir);
                fixed4 albedo = tex2D(_MainTex, f.uv.xy) * _Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed4 packedNormal = tex2D(_BumpMap, f.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentLightDir, tangentNormal));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)),_Gloss);
            
                return fixed4(ambient + diffuse + specular,1);
            }

            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
