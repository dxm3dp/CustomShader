
```glsl
Shader "Custom/Chapter9-ForwardRendering"
{
    Properties
    {
        // 漫反射光颜色
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        // 镜面反射光颜色
        _Specular("Specular", Color) = (1, 1, 1, 1)
        // 高光反射指数
        _Gloss("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        // 渲染类型为不透明物体
        Tags { "RenderType"="Opaque" }

        Pass
        {
            // 设置光照模式,指定该Pass在光照流水线中的角色
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            // 保证我们在Shader中使用的光照衰减等光照变量可以被正确赋值
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                // 模型空间下的顶点坐标
                float4 vertex : POSITION;
                // 模型空间下的法线向量
                float3 normal : NORMAL;
            };

            struct v2f 
            {
                // 裁剪空间下的顶点坐标
                float4 pos : SV_POSITION;
                // 世界空间下的法线向量
                float3 worldNormal : TEXCOORD0;
                // 世界空间下的顶点坐标
                float3 worldPos : TEXCOORD1;
            };

            // 顶点着色器
            v2f vert(a2v v)
            {
                v2f o;
                // 将顶点坐标从模型空间变换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                // 将顶点法线从模型空间变换到世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 将顶点坐标从模型空间变换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i) : SV_TARGET
            {
                // 获取环境光分量,环境光只在ForwardBasePass中计算一次
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 归一化世界空间的法线
                fixed3 worldNormal = normalize(i.worldNormal);
                // 归一化平行光的方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 计算漫反射光分量
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                // 计算高光反射分量
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                // 由于平行光没有衰减,令衰减值为1.0
                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
        
        Pass
        {
            // 为其他逐像素光源定义Additional Pass
            Tags {"LightMode"="ForwardAdd"}
            Blend One One

            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                #else
                    #if defined (POINT)
                        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined (SPOT)
                        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #else
                        fixed atten = 1.0;
                    #endif
                #endif

                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
```