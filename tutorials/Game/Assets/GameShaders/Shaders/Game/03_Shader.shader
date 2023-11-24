Shader "TA/03_Shader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct a2v
            {
                float4 vertex : POSITION;       // 模型空间顶点 -> vertex
                float3 normal : NORMAL;         // 模型法线方向 -> normal
                float4 texcoord : TEXCOORD0;    // 第一套纹理坐标 -> texcoord
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 temp : COLOR0;
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.position = UnityObjectToClipPos(v.vertex);
                f.temp = v.normal;
                return f;
            }

            float4 frag(v2f f) : SV_Target
            {
                return fixed4(f.temp, 1);
            }

            ENDCG
        }
    }

    Fallback "VertexLit"
}