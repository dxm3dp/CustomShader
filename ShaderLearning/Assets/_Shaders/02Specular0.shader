// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/02Specular0" {
	Properties {
		_Diffuse("Diffuse", Color)=(1,1,1,1)
		_Specular("Specular", Color)=(1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256.0)) = 20.0
	}
	SubShader {
		pass{
			Tags{"LightMode"="ForwardBase"}
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
				fixed3 color : COLOR;
			};

			v2f vert(a2v v) {
				v2f f;
				f.pos = UnityObjectToClipPos(v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize( mul( unity_ObjectToWorld, v.normal));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 reflectDir = normalize( reflect(-worldLightDir, worldNormal));
				fixed3 worldVertex = normalize(mul(unity_ObjectToWorld, v.vertex).xyz);
				fixed3 viewDir = normalize( _WorldSpaceCameraPos.xyz - worldVertex);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate(dot(reflectDir, viewDir)) , _Gloss);
				f.color = ambient + diffuse + specular;

				return f;
			}

			fixed4 frag(v2f f) : SV_TARGET {
				return fixed4(f.color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
