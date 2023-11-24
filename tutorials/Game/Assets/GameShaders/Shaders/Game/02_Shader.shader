// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/02_Shader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            // 顶点函数 -> 声明顶点函数名
            // 基本作用 -> 完成顶点坐标从模型空间到裁剪空间的转换(从游戏环境转换到视野相机屏幕上)
            #pragma vertex vert

            // 顶点函数 -> 声明片元函数名
            // 基本作用 -> 返回模型对应的屏幕上的每一个像素的颜色值
            #pragma fragment frag

            // 通过语义告诉系统参数的作用 POSITION -> 传入模型空间顶点坐标 SV_POSITION -> 返回剪裁空间顶点坐标(System Value)
            float4 vert(float4 v : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(v);
            }

            float4 frag() : SV_Target
            {
                return fixed4(0.5, 0.5, 1, 1);
            }

            ENDCG
        }
    }

    Fallback "VertexLit"
}