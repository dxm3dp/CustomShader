// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/08ForwardRendering" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0,256)) = 20
	}
	SubShader {
		pass{
			Tags{"LightModel"="ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;//材质的漫反射颜色
			fixed4 _Specular;//材质的高光反射颜色
			float _Gloss;//材质的光泽度

			//顶点着色器的输入结构体
			struct a2v{
				float4 vertex : POSITION;//模型空间下的顶点坐标
				float3 normal : NORMAL;//模型空间下的顶点法向量
			};
			//顶点着色器的输出结构体
			struct v2f{
				float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
				float3 worldNormal : TEXCOORD0;//世界空间下的顶点法向量，存储到顶点的第1组纹理坐标中
				float3 worldPos : TEXCOORD1;//世界空间下的顶点坐标，存储到顶点的第2组纹理坐标中
			};
			//顶点着色器方法
			v2f vert(a2v v) {
				v2f result;
				//将物体的顶点坐标由模型空间变换到裁剪空间下
				result.pos = UnityObjectToClipPos(v.vertex);
				//将顶点的法向量由模型空间变换到世界空间下
				result.worldNormal = UnityObjectToWorldNormal(v.normal);
				//将物体的顶点坐标由模型空间变换到世界空间下
				result.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return result;
			}
			//片元着色器方法
			fixed4 frag(v2f f) : SV_TARGET{
				//归一化世界空间下的顶点法向量
				fixed3 worldNormal = normalize(f.worldNormal);
				//_WorldSpaceLightPos0是该pass处理的逐像素光源的位置。
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//获取环境光的颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//计算漫反射光照。_LightColor0是该pass处理的逐像素光源的颜色。
				//漫反射光照 = 光源颜色 * 材质的漫反射颜色 * max(0, n*I)
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//从顶点指向视点的观察方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldPos.xyz);
				//
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				//高光反射光照 = 光源颜色 * 材质的高光反射颜色 * max(0, n*half)^Gloss
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				//方向光的光照衰减总是1
				fixed atten = 1.0;

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}
		//负责其它逐像素光照的pass
		pass{
			Tags{"LightModel"="ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;//材质的漫反射颜色
			fixed4 _Specular;//材质的高光反射颜色
			float _Gloss;//材质的光泽度

			//顶点着色器的输入结构体
			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			//顶点着色器的输出结构体
			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			//顶点着色器方法
			v2f vert(a2v v) {
				v2f result;
				result.pos = UnityObjectToClipPos(v.vertex);
				result.worldNormal = UnityObjectToWorldNormal(v.normal);
				result.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return result;
			}
			//片元着色器方法
			fixed4 frag(v2f f) : SV_TARGET{
				fixed3 worldNormal = normalize(f.worldNormal);
				//根据光源类型，计算世界空间下由顶点指向光源的方向向量
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - f.worldPos.xyz);
				#endif
				//计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//计算视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldPos.xyz);
				//
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				//计算高光反射光照
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				//根据光源类型，计算光源的衰减
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined(POINT)//点光源
						float3 lightCoord = mul(unity_WorldToLight, float4(f.worldPos, 1)).xyz;
						fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined(SPOT)//聚光灯
						float4 lightCoord = mul(unity_WorldToLight, float4(f.worldPos, 1));
						fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).while * 
						tex2D(_LightTexture0, dot(lightCoord, lightCooord).rr).UNITY_ATTEN_CHANNEL;
					#else//其它
						fixed atten = 1.0
					#endif
				#endif

				return fixed4((diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}