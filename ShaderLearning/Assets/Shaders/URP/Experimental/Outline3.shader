Shader "Custom/URP/Experimental/Outline3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineWidth("Outline Offset", Float) = 0.01
        _Cull("Cull Mode", Int) = 2
        _ConstantWidth("Constant Width", Float) = 1.0
        _OutlineZTest("ZTest", Int) = 4
        _Cutoff("CutOff", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+120" "DisableBatching"="True" }

        // Outline
        Pass
        {
            Stencil
            {
                Ref 2
                Comp NotEqual
                Pass replace
                ReadMask 2
                WriteMask 2
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull [_Cull]
            ZTest [_OutlineZTest]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _OutlineColor;
            float _OutlineWidth;
            float _ConstantWidth;
            float4 _MainTex_ST;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, IN.normalOS);
                float3 offset = any(viewNormal.xyz) !=0 ? TransformWViewToHClip(normalize(viewNormal)) : 0.0.xxx;
                float z = lerp(UNITY_Z_0_FAR_FROM_CLIPSPACE(OUT.positionHCS.z), 2.0, UNITY_MATRIX_P[3][3]);
                z = _ConstantWidth * (z - 2.0) + 2.0;
                //float4 outlineDirection = 
                OUT.positionHCS.xy += offset.xy * z * _OutlineWidth;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return _OutlineColor;
            }
            ENDHLSL
        }

        // Outline Clear Stencil
        pass
        {
            Stencil
            {
                Ref 2
                Comp Always
                Pass zero
            }

            ColorMask 0
            ZWrite Off
            Cull [_Cull]
            ZTest [_OutlineZTest]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            half4 _OutlineColor;
            float _OutlineWidth;
            float _ConstantWidth;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, IN.normalOS);
                 float3 offset = any(viewNormal.xyz) !=0 ? TransformWViewToHClip(normalize(viewNormal)) : 0.0.xxx;
                float z = lerp(UNITY_Z_0_FAR_FROM_CLIPSPACE(OUT.positionHCS.z), 2.0, UNITY_MATRIX_P[3][3]);
                z = _ConstantWidth * (z - 2.0) + 2.0;
                OUT.positionHCS.xy += offset.xy * z * _OutlineWidth;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }
    }
}
