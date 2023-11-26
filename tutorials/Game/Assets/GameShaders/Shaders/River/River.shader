// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/Rever"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Distortion Frequency", Float) = 1
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) =0.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

        Pass
        {
            Tags { "LingtMode" ="ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed3 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f f;

                float4 offset;
                offset.xyz = float3(0.0, 0.0, 0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                f.pos = UnityObjectToClipPos(v.vertex + offset);

                f.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                f.uv += float2(0.0, _Time.y * _Speed);

                return f;
            }

            float4 frag(v2f f) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, f.uv);
                c.rgb *= _Color.rgb;

                return c;
            }


            ENDCG
        }
    }

    Fallback "Transparent/VertexLit"
}