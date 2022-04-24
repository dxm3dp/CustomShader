
// 使用假色彩图像进行调试,主要思想是:
// 把需要调试的变量映射到[0, 1]之间,并把它们作为颜色输出到屏幕上.然后通过屏幕上显示
// 的像素颜色来判断这个值是否正确.

// 如果我们要调试的是一个一维数据,那么可以选择一个单独的颜色分量(如R分量)进行输出,
// 而把其他颜色分量置为0.如果是多维数据,可以选择对他的每一个分量单独调试,或者选择多
// 个颜色分量进行输出.

// 下面的例子,我们会使用假彩色图像的方式来可视化一些模型数据,如法线 切线 纹理坐标 顶
// 点颜色以及它们之间的运算结果等.

Shader "Custom/Chapter5-FalseColor" {
    SubShader {
        pass{
            CGPROGRAM

            #pragma vertex vertex
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_full_copy {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                float4 texcoord3 : texcoord3;
                fixed4 color : COLOR;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            v2f vert(appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 可视化法线方向
                o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化切线方向
                o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化副切线方向
                fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化顶点颜色
                o.color = v.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                return i.color;
            }

            ENDCG
        }
    }
}