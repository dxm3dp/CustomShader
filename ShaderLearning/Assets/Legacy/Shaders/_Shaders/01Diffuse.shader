// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DiffusePixel" {
	Properties{
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader{
        pass{
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            //顶点着色器的输入结构体
            struct a2v{
                float4 pos : POSITION;//模型空间下的顶点坐标
                float3 normal : NORMAL;//模型空间下的法线向量
            };

            //片元着色器的输入结构体
            struct v2f{
                float4 pos : SV_POSITION;//裁剪空间下的顶点坐标
                float3 worldNormal : TEXCOORD0;//顶点的第一组纹理坐标
            };

            //顶点着色方法
            v2f vert(a2v v)
            {
                v2f f;
                f.pos = UnityObjectToClipPos(v.pos);//将顶点坐标由模型空间变换到裁剪空间
                f.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));//计算顶点法线在世界空间下的方向

                return f;
            }

            //片元着色方法
            fixed4 frag(v2f f) : SV_TARGET
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光的颜色
                fixed3 worldNormal = normalize(f.worldNormal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//计算光源方向
                fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldLight, worldNormal));//计算漫反射部分的颜色
                fixed3 color = ambient + diffuse;//片元颜色 = 环境光颜色 + 漫反射颜色

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
	Fallback "Diffuse"
}
