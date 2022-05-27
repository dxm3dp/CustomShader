Shader "Custom/URP/Outline"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth("Outline Width", Range(0, 0.01)) = 0.002

        [Space]
        [Header(Cull State)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 2.0

        [Space]
        [Header(ZTest State)]
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest("ZTest", Float) = 0.0
    }
    SubShader
    {
        pass
        {
            Tags{"LightMode"="UniversalForward" "RenderType"="Opaque" "Queue"="Geometry+10"}

            colormask 0
            ZWrite Off
            ZTest Off

            Stencil
            {
                Ref 1
                Comp Always
                Pass replace
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;// 对象空间顶点坐标
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;// 齐次裁剪空间顶点坐标
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return half4(0.5, 0, 0, 1);
            }

            ENDHLSL
        }

        pass
        {
            Tags {"RenderType"="Transparent" "Queue"="Transparent+20"}

            ZWrite on
            ZTest [_ZTest]
            Cull [_Cull]
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            Stencil
            {
                Ref 1
                Comp notEqual
                Pass keep
            }

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

            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _OutlineWidth;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, IN.normalOS);
                float3 offset = any(viewNormal) ? TransformWViewToHClip(normalize(viewNormal)) : 0.0.xxx;
                float z = lerp(UNITY_Z_0_FAR_FROM_CLIPSPACE(OUT.positionHCS.z), 2.0, UNITY_MATRIX_P[3][3]);
                z = 1 * (z - 2.0) + 2.0;
                OUT.positionHCS.xy += offset.xy * z * _OutlineWidth;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}
