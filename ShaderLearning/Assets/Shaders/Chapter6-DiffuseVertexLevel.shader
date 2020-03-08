Shader "Custom/Chapter6-DiffuseVertexLevel"
{
    Properties
    {
        // 材质的漫反射颜色
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    } 
    SubShader
    {
        pass 
        {
            // 指定该pass的光照模型.
            // 只有定义了正确的光照模型,我们才能得到一些Unity的内置光照变量.如 _LightColor0.
            Tags {"LightModel"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // 为了使用Unity内置的一些变量,需要包含Unity的内置文件
            #include "Lighting.cginc"

            // 定义与在Properies中声明的属性同名的变量
            // 颜色属性的范围在(0, 1),因此我们可以用fixed精度的变量来存储它.
            fixed4 _Diffuse;

            // 顶点着色器的输入结构体
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // 顶点着色器的输出结构体
            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR; // 并不一定必须使用COLOR语义
            };

            // 顶点着色器
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 获取环境光的颜色
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 将顶点法线从模型空间变换到世界空间
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                // 获取世界空间中的光照方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 计算漫反射光照部分:漫反射颜色 = 光源颜色 * 材质颜色 * max(0, 顶点法线与光照方向的余弦值)
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                // 计算顶点着色器输出的顶点颜色
                o.color = ambient + diffuse;

                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i) : SV_TARGET
            {
                return fixed4(i.color, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}