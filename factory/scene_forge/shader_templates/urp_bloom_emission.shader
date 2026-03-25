Shader "DriveAI/Generated/{SHADER_NAME}"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        _EmissionColor ("Emission Color", Color) = ({EMISSION_COLOR})
        _EmissionIntensity ("Emission Intensity", Float) = {EMISSION_INTENSITY}
        _PulseSpeed ("Pulse Speed", Float) = {PULSE_SPEED}
        _BloomThreshold ("Bloom Threshold", Range(0, 2)) = {BLOOM_THRESHOLD}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "EmissionPass"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _Color;
                half4 _EmissionColor;
                float _EmissionIntensity;
                float _PulseSpeed;
                float _BloomThreshold;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half4 baseColor = tex * _Color;

                // Pulsing emission
                float pulse = (sin(_Time.y * _PulseSpeed) * 0.5 + 0.5);
                float intensity = _EmissionIntensity * (0.5 + 0.5 * pulse);
                half3 emission = _EmissionColor.rgb * intensity;

                // Add emission to base color (bloom picks this up via threshold)
                half4 finalColor;
                finalColor.rgb = baseColor.rgb + emission;
                finalColor.a = baseColor.a;

                return finalColor;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
