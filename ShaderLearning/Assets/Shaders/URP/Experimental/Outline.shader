Shader "Custom/URP/Experimental/Outline"
{
    Properties
    {
        _Color("Outline Color", Color) = (1, 1, 1, 1)
        _Width("Outline Width", Range(0, 1)) = 0.2
        _Factor("Factor", Range(0, 1)) = 0.2
    }
    SubShader
    {
        pass
        {
            Tags {"LightMode"="UniversalForward" "RenderType"="Opaque" "Queue"="Geometry + 10"}

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
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
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
            //Tags{ "RenderType"="Opaque" "Queue"="Geometry + 20"}
            //ZTest Off

            Tags {"RenderType"="Transparent" "Queue"="Transparent + 20"}
            Cull Off
            ZWrite on
            ZTest Off
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
            half4 _Color;
            half _Width;
            half _Factor;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                float3 vertexDir = normalize(IN.positionOS.xyz);
                vertexDir = lerp(vertexDir, normalize(IN.normalOS), _Factor);
                vertexDir = mul((float3x3)UNITY_MATRIX_IT_MV, vertexDir);
                float3 offset = TransformWViewToHClip(vertexDir);
                OUT.positionHCS.xy += offset.xy * OUT.positionHCS.z * _Width;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return _Color;
            }
            ENDHLSL
        }
    }
}
