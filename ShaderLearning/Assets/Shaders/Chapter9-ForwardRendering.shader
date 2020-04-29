Shader "Unlit/Chapter9-ForwardRendering"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightModel"="ForwardBase"}

            CGPROGRAM
            // 保证我们在Shader中使用光照衰减等光照变量可以被正确赋值
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

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
                o.pos = UnityObjectToClipPos(v.vertex.xyz);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                // 获取环境光分量,环境光计算一次即可
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
                // 由于平行光没有衰减,我们令衰减值为1.0
                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }

        pass
        {
            // 为其他逐像素光源定义Additional Pass
            Tags {"LightModel"="ForwardAdd"}
            Blend One One

            CGPROGRAM
            #pragma multi_compile_fwdadd
            ENDCG
        }
    }
}
