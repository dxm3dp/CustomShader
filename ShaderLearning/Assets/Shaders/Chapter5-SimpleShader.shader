// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader"
{
    // 1
    Properties {
        // 声明一个Color类型的属性
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    // 2
    SubShader
    {
        // 4
        pass{
            // 5
            CGPROGRAM

            // 指定顶点着色器函数
            #pragma vertex vert
            // 指定片元着色器函数
            #pragma fragment frag

            // 在Cg代码中,我们需要定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;

            // 应用程序传递给顶点着色器的模型数据
            struct a2v{
                // POSITION语义表示用模型空间的顶点坐标填充vertex变量
                float4 vertex : POSITION;
                // NORMAL语义表示用模型空间的法线方向填充normal变量
                float3 normal : NORMAL;
                // TEXCOORD0语义表示用模型的第一组纹理坐标填充texcoord变量
                float4 texcoord : TEXCOORD0;
            };

            // 在顶点着色器与片元着色器之间传递数据
            struct v2f{
                // SV_POSITION表示用pos中包含了顶点在裁剪空间中的位置
                float4 pos : SV_POSITION;
                // COLOR0语义可以用于存储颜色信息
                fixed3 color : COLOR0;
            };

            // 顶点着色器,逐顶点执行.
            // POSITION语义表示v是顶点在模型空间中的位置
            // SV_POSITION语义表示该函数的返回值(float4)是裁剪空间中的位置
            // 语义是不可省略的,它们告诉渲染器需要做哪些操作.
            v2f vert(a2v v)
            {
                // 声明输出结构
                v2f o;
                // 将顶点坐标从模型空间变换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                // 顶点法线的分量范围在(-1.0, 1.0),这句代码把分量范围映射到(0.0, 1.0)
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

                return o;
            }

            // 片元着色器,逐片元执行.
            // 片元着色器的输入实际上是把顶点着色器的输出进行插值后的结果
            // SV_TARGET语义表示将用户的输出颜色存储到一个渲染目标
            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 c = i.color;
                // 使用_Color属性来控制输出颜色
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }

            ENDCG
        }
    }
    // 3
    FallBack "Diffuse"
}
