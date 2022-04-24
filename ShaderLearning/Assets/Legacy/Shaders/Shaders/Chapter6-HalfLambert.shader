// 2020.3.12(4) 3.21(6)
// 半兰伯特光照模型
Shader "Custom/Chapter6-HalfLambert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
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

            // 顶点着色器输入
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // 顶点着色器输出
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            // 顶点着色器
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i) : SV_TARGET 
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 将世界空间下的顶点法线与光照方向的余弦值由[-1, 1]映射到 [0, 1], 以此来增强光照效果
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal, worldLightDir) * 0.5 + 0.5);

                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
