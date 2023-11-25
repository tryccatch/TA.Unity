Shader "TA/12_NormalMap"
{
    Properties
    {
        //_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}    // bump 没有法线贴图使用模型自带信息
        _BumpScale("Bump Scale", Range(0, 100)) = 1
        // _Specular("Specular Color", Color) = (1, 1, 1, 1)
        // _Gloss("Gloss", Range(10, 200)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            // fixed4 _Diffuse;
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float _BumpScale;
            // fixed4 _Specular;
            // half _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                // 切线空间的确定是通过(存储到模型里面的)法线和(存储到模型里面的)切线确定的
                float3 normal : NORMAL;
                float4 tangent : TANGENT;  // tangent.w —> 确定切线空间中坐标轴的方向
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 svPos : SV_POSITION;
                float3 lightDir : TEXCOORD0;    // 切线空间下 平行光的方向
                float4 worldVertex : TEXCOORD1;
                float4 uv : TEXCOORD2;      // xy -> 存储MainTex的纹理坐标 | zw -> 存储NormalMap贴图纹理坐标
            };

            v2f vert(a2v v)
            {
                v2f f;

                f.svPos = UnityObjectToClipPos(v.vertex);
                // f.worldNormal = UnityObjectToWorldNormal(v.normal);
                f.worldVertex = mul(v.vertex, unity_WorldToObject);
                f.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                f.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

                TANGENT_SPACE_ROTATION;     // 调用宏后，会得到一个rotation矩阵 -> 模型空间下转换成切线空间下 

                // ObjSpaceLightDir(v.vertex);    //得到模型空间下的平行光方向
                f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                return f;
            }

            // 所有跟法线方向有关的运算都放在切线空间下
            // 从法线贴图里面获取的法线是在切线空间下的
            fixed4 frag(v2f f) : SV_Target
            {
                // fixed3 normalDir = normalize(f.worldNormal);
                fixed4 normalColor = tex2D(_NormalMap, f.uv.zw);

                // fixed3 tangentNoraml = normalize(normalColor.xyz * 2 - 1);     // 切线空间下的法线 
                fixed3 tangentNoraml = UnpackNormal(normalColor);
                tangentNoraml.xy = tangentNoraml.xy * _BumpScale;
                tangentNoraml = normalize(tangentNoraml);

                fixed3 lightDir = normalize(f.lightDir);
                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(dot(normalDir, lightDir),0);

                fixed3 texColor = tex2D(_MainTex, f.uv.xy) * _Color.rgb;                
                fixed3 diffuse = _LightColor0.rgb * texColor * max(dot(tangentNoraml, lightDir),0);

                /* 去除高光反射
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertex));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(normalDir, halfDir),0),_Gloss);

                fixed3 tempColor = diffuse + specular + UNITY_LIGHTMODEL_AMBIENT.rgb * texColor;
                */
                fixed3 tempColor = diffuse + UNITY_LIGHTMODEL_AMBIENT.rgb * texColor;
                
                return fixed4(tempColor, 1);
            }

            ENDCG
        }
    }

    Fallback "Specular"
}