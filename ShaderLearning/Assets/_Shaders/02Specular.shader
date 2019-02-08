
Shader "Custom/SpecularVertex" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
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

			struct a2v{
				float4 vertex : POSITION;//模型空间下的顶点坐标
				float3 normal : NORMAL;//模型空间下的顶点法线
			};
			struct v2f{
				float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
				fixed3 color : COLOR;//顶点的颜色
			};

			//顶点着色器方法
			v2f vert(a2v v) {
				//定义结果变量
				v2f result;
				//将顶点坐标由模型空间转换到裁剪空间
				result.pos = UnityObjectToClipPos(v.vertex);
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//将顶点法线由模型空间转换到世界空间
				fixed3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				//标准化顶点法线
				worldNormal = normalize(worldNormal);
				//获取世界空间中的光源方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				//计算世界空间中的反射方向
				fixed3 reflectDir = reflect(-worldLightDir, worldNormal);
				//计算视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//计算高光反射光照
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				//计算最后结果
				result.color = ambient + diffuse + specular;

				return result;
			}

			//片元着色器方法
			fixed4 frag(v2f f) : SV_TARGET {
				//返回在顶点着色器中计算好的颜色
				return fixed4(f.color, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}