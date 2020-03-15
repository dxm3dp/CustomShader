// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chapter6-SpecularVertexLevel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        // 材质的高光反射颜色
        _Specular("Specular", Color) = (1, 1, 1, 1)
        // 高光反射系数,用于控制高光区域的大小
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        pass{
            Tags {"LightModel"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            // 顶点着色器的输入结构体
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // 顶点着色器的输出结构体
            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            // 顶点着色器
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 获取环境光分量
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 计算世界空间的法线
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                // 计算世界空间的光照方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 计算漫反射分量
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                // 计算反射方向向量
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                // 计算视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                // 计算高光反射分量
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                // 计算最终颜色值
                o.color = ambient + diffuse + specular;

                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i) : SV_TARGET {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
