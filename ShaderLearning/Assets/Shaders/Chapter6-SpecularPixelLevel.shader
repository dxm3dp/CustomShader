﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// 2020.3.14(6) 3.22(7)

Shader "Custom/Chapter6-SpecularPixelLevel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 256.0)) = 20
    }
    SubShader
    {
        pass
        {
            Tags {"LightModel"="ForwardBase"}

            CGPROGRAM

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
                // 这里的类型是 float3
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = mul(unity_ObjectToWorld, v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET 
            {
                // 环境光分量
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 漫反射光分量
                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // 镜面反射光分量
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * 
                pow(saturate(dot(reflectDir, worldViewDir)), _Gloss);

                // 最终颜色
                fixed4 color = fixed4(ambient + diffuse + specular, 1.0);
                return color;
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
