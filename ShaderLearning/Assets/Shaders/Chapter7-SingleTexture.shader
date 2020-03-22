// 2020.3.23(1)

Shader "Custom/Chapter7-SingleTexture"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 256)) = 20
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

            fixed4 _Color;
            sampler2D _MainTex;
            // 在Unity中,使用 纹理名_ST 的方式来声明这个纹理的属性.
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            ENDCG
        }
    }
    Fallback "Diffuse"
}
