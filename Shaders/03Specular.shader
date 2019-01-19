// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SpecularPixel" {
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}
	SubShader{
		pass{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;//材质的漫反射颜色
			fixed4 _Specular;//材质的高光反射颜色
			float _Gloss;//材质的光泽度

			//顶点着色器的输入结构体
			struct a2v{
				float4 vertex : POSITION;//模型空间下的顶点坐标
				float3 normal : NORMAL;//模型空间下的顶点法线
			};
			//顶点着色器的输出结构体
			struct v2f{
				float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
				float3 worldNormal : TEXCOORD0;//顶点的第1组纹理坐标
				float3 worldPos : TEXCOORD1;//顶点的第2组纹理坐标
			};

			//顶点着色器方法
			v2f vert(a2v v) {
				v2f result;
				//将顶点坐标由模型空间变换到投影空间
				result.pos = UnityObjectToClipPos(v.vertex);
				//将顶点法线由模型空间变换到世界空间
				result.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				//将顶点位置由模型空间变换到世界空间
				result.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return result;
			}
			//片元着色器方法
			fixed4 frag(v2f i) : SV_TARGET{
				//获取环境光的颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//标准化世界空间下的顶点法线
				fixed3 worldNormal = normalize(i.worldNormal);
				//标准化世界空间下的光源方向向量
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				//计算反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//计算视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//计算高光反射光照
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate( dot(reflectDir, viewDir)), _Gloss);

				//返回最后的颜色
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}