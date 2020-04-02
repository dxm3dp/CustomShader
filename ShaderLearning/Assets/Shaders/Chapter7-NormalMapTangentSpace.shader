// 2020.3.25(3) 4.2(4)

Shader "Custom/Chapter7-NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", float) = 1.0
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightModel"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                // TANGENT语义告诉Unity把顶点的切线方向填充到tangent变量中.
                // 需要注意的是,tangent的类型是float4, 而非float3,因为我们需要使用tangent.w分量
                // 来决定切线空间中的第三个坐标轴--副切线的方向性.
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                // uv坐标
                float4 uv : TEXCOORD0;
                // 切线空间下的光照方向
                float3 lightDir : TEXCOORD1;
                // 切线空间下的视角方向
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                // 计算副法线(副切线)
                float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                // 将模型空间下的切线方向,副切线方向,法线方向按行排列来得到从模型空间到切线空间的变换矩阵.
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                // 将模型空间下的光照方向和视角方向变换到切线空间中.
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                // 切线空间下的光照方向
                fixed3 tangentLightDir = normalize(i.lightDir);
                // 切线空间下的视角方向
                fixed3 tangentViewDir = normalize(i.viewDir);

                // 对法线纹理进行采样
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy , tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentLightDir, tangentNormal));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular , 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
