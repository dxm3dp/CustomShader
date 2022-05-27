Shader "Custom/URP/Experimental/Outline2"
{
    Properties
    {
        _Matcap("Matcap", 2D) = "white"{}
        _Color("Outline Color", Color) = (1, 1, 1, 1)
        _Width("Outline Width", Range(0, 1)) = 0.2
        _Factor("Factor", Range(0, 1)) = 0.5

        [Space]
        [Header(ZTest State)]
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest("ZTest", Float) = 0.0
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry" "IgnoreProjector"="True"}

        LOD 300
        Cull Back

        pass
        {
            Name "Forward"
            Tags {"LightMode"="UniversalForward"}

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            // GPUInstancing s1
            #pragma multi_compile_instancing
            // 
            #pragma prefer_hlslcc gles
            // 
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;

                // GPUInstancing s2
                // [UnityInstancing.hlsl]
                // uint instanceID : SV_InstanceID
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 texcoord3 : TEXCOORD3;

                // GPUInstancing s3
                // [UnityInstancing.hlsl]
                UNITY_VERTEX_INPUT_INSTANCE_ID
                // [UnityInstancing.hlsl]
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _Matcap;

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Width;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // GPUInstancing s4
                // [UnityInstancing.hlsl]
                UNITY_SETUP_INSTANCE_ID(IN);
                // GPUInstancing s5
                // [UnityInstancing.hlsl]
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                // [UnityInstancing.hlsl]
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                half3 worldNormal = TransformObjectToWorldNormal(IN.normalOS);
                OUT.texcoord3.xyz = worldNormal;
                OUT.texcoord3.w = 0;

                float3 vertexValue = float3(0, 0, 0);

                IN.positionOS.xyz += vertexValue;
                IN.normalOS = IN.normalOS;

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float4 positionHCS = TransformWorldToHClip(positionWS);

                OUT.positionHCS = positionHCS;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                // GPUInstancing
                // [UnityInstance.hlsl]
                UNITY_SETUP_INSTANCE_ID(IN);
                // [UnityInstance.hlsl]
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
 
                float4 ShadowCoords = float4(0, 0, 0, 0);

                half3 worldNormal = IN.texcoord3.xyz;
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = tex2D(_Matcap, ((mul(UNITY_MATRIX_V, half4(worldNormal , 0.0)).xyz * 0.5) + 0.5).xy).rgb;
                float Alpha = 1;
                float AlphaClipThreshold = 0.5;

                #ifdef _ALPHATEST_ON
                    clip(Alpha - AlphaClipThreshold);
                #endif
 
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
 
                return half4(Color, Alpha);
            }
            ENDHLSL
        }

        pass
        {
            Name "Mask"
            Tags {"LightMode"="Mask" "RenderType"="Transparent" "Queue"="Transparent + 10"}

            Cull Off
            ColorMask 0
            ZWrite off
            ZTest Always

            Stencil
            {
                Ref 1
                Comp Always
                Pass replace
            }
        }

        pass
        {
            Name "Fill"
            Tags {"LightMode"="Fill" "RenderType"="Transparent" "Queue"="Transparent + 20" "DisableBatching"="True"}

            Cull Off
            ZWrite on
            ZTest [_ZTest]
 
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

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 color : COLOR;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            //CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Width;
            half _Factor;
            //CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
 
                //VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                //float3 viewPosition = vertexPositionInputs.positionVS;
                //float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, IN.normalOS));
                //OUT.positionHCS = mul(UNITY_MATRIX_P, float4(viewPosition + viewNormal * -viewPosition.z * _Width / 100.0, 1.0));

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 vertexDir = normalize(IN.positionOS.xyz);
                vertexDir = lerp(vertexDir, normalize(IN.normalOS), _Factor);
                vertexDir = mul((float3x3)UNITY_MATRIX_IT_MV, vertexDir);
                float3 offset = TransformWViewToHClip(vertexDir);
                OUT.positionHCS.xy += offset.xy * OUT.positionHCS.z * _Width;
                OUT.color = _Color;
 
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                return IN.color;
            }

            ENDHLSL
        }
    }
}
