Shader "TA/04_Diffuse_Vertex"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }    //

            CGPROGRAM

            #include "Lighting.cginc"   //取得第一个直射光的颜色 -> _LightColor0 | 第一个直射光的位置 -> _WorldSpaceLightPos0
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;       // 模型空间顶点 -> vertex
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.position = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 normalDir = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);  // 光方向

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(normalDir,lightDir));  // 漫反射颜色

                f.color = diffuse + ambient;

                return f;
            }

            float4 frag(v2f f) : SV_Target
            {
                return fixed4(f.color, 1);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"
}