Shader "Custom/06AlphaBlendZWrite" {
	Properties {
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{} 
	    _AlphaScale("Alpha Scale", Range(0,1)) = 1
	}
	SubShader {
		Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		//专门负责把模型的深度信息写入深度缓冲区的pass
		pass{
			//开启深度缓冲区的写入
			ZWrite On
			//不写入任何颜色通道
			ColorMask 0
		}
		//负责进行正常透明度混合的pass
		pass{
			Tags{"LightMode"="ForwardBase"}
			//关闭深度缓冲区的写入
			ZWrite Off
			//开启混合，并设置混合参数
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;//材质的主色彩
			sampler2D _MainTex;//材质的纹理
			float4 _MainTex_ST;//材质纹理的缩放量和偏移量
			fixed _AlphaScale;//控制整体透明度的参数

			//顶点着色器的输入结构体
			struct a2v{
			 	float4	vertex : POSITION;//模型空间下的顶点坐标 
				float3 normal : NORMAL;//模型空间下的法线向量
				float4 texcoord : TEXCOORD0;//顶点的第1组纹理坐标
			};
			//顶点着色器的输出结构体
			struct v2f{
				float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
				float3 worldNormal : TEXCOORD0;//世界空间下的顶点法线向量
				float3 worldPos : TEXCOORD1;//世界空间下的顶点坐标
				float2 uv : TEXCOORD2;//顶点最终的纹理坐标
			};

			//顶点着色器方法
			v2f vert(a2v v) {
				//定义返回结果变量
				v2f result;
				//将顶点坐标由模型空间变换到裁剪空间
				result.pos = UnityObjectToClipPos(v.vertex);
				//将顶点的法线向量由模型空间变换到世界空间
				result.worldNormal = UnityObjectToWorldNormal(v.normal);
				//将顶点坐标由模型空间变换到世界空间
				result.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//计算顶点的实际纹理坐标
				result.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return result;
			}
			//片元着色器方法
			fixed4 frag(v2f f) : SV_TARGET {
				fixed3 worldNormal = normalize(f.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));
				//进行纹理采样
				fixed4 texColor = tex2D(_MainTex, f.uv);
				//材质反射率 = 材质的纹理颜色 * 材质的主色彩
				fixed3 albedo = texColor.rgb * _Color.rgb;
				//计算环境光光照
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				//返回片元的最终颜色
				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
			}
			ENDCG
		}

	}
	FallBack "Diffuse"
}
