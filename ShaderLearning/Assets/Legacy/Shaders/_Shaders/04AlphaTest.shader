// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/AlphaTest" {
	Properties {
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
	}
	SubShader {
		Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenterType"="TransparentCutout"}
		pass{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;//材质的主色彩
			sampler2D _MainTex;//材质的纹理
			float4 _MainTex_ST;//材质纹理的缩放量和偏移量
			fixed _CutOff;//透明度测试的阈值

			//顶点着色器的输入结构体
			struct a2v{
				float4 vertex : POSITION;//模型空间下的顶点坐标
				float3 normal : NORMAL;//模型空间下顶点的法线向量
				float4 texcoord : TEXCOORD0;//顶点的第1组纹理坐标
			};
			//顶点着色器的输出结构体
			struct v2f{
				float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
				float3 worldNormal : TEXCOORD0;//世界空间下顶点的法线向量
				float3 worldPos : TEXCOORD1;//世界空间下的顶点坐标
				float2 uv : TEXCOORD2;//顶点最终的纹理坐标
			};
			//顶点着色器方法
			v2f vert(a2v v) {
				//定义返回结果变量
				v2f result;
				//将模型的顶点坐标由模型空间变换到裁剪空间
				result.pos = UnityObjectToClipPos(v.vertex);
				//将模型的法线向量由模型空间变换到世界空间
				result.worldNormal = UnityObjectToWorldNormal(v.normal);
				//将模型的顶点坐标由模型空间变换到世界空间下
				result.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//计算顶点经过变换后的最终纹理坐标
				result.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return result;
			}
			//片元着色器方法
			fixed4 frag(v2f f) : SV_TARGET{
				fixed3 worldNormal = normalize(f.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));
				//对纹理进行采样
				fixed4 texColor = tex2D(_MainTex, f.uv);
				//依据纹理颜色值中的alpha值进行透明度测试
				clip(texColor.a - _CutOff);
				//材质的反射率 = 材质的纹理颜色 * 材质的主色彩
				fixed3 albedo = texColor.rgb * _Color.rgb;
				//计算环境光光照
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				//返回环境光照和漫反射光照相加之后的结果
				return fixed4(ambient + diffuse, 1.0);
			}
			ENDCG
		}
		
	}
	FallBack "Transparent/Cutout/VertexLit"//设置合适的Fallback
}