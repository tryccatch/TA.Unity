Shader "TA/01_Shader"
{
    Properties
    {
        // 此处是材质属性声明
        // [optional: attribute] name("display text in Inspector", type name) = default value
        _Integer("m_Integer", Integer) = 1      // float4
        _Float("m_Float", Float) = 0.1      // float4
        _Range("m_Range", Range(0.0, 1.0)) = 0.1    // float4

        _2D("m_Texture2D", 2D) = "" {}      // sampler2D
        _2D_Color("m_Texture2D_Color", 2D) = "red" {}
        _2D_Array("m_Texture2D_Array", 2DArray) = "" {}
        _3D("m_Texture3D", 3D) = "" {}

        _Cubemap("m_Cubemap", Cube) = "" {}     // samplerCube
        _CubemapArray("m_CubemapArray", CubeArray) = "" {}

        _Color("m_Color", Color) = (1, 1, 1, 1)     // float4
        _Vector("m_Vector", Vector) = (.3, .3, .3, .3)      // float4
    }
    SubShader
    {
        // 此处是定义子着色器的其余代码

        Pass
        {
            // 此处是定义通道的代码

            CGPROGRAM
            // 使用CG语言
            //float -> 32bit (-2,147,483,648 ~ 2,147,483,647)
            //half -> 16bit (-32,768 ~ 32,767)
            //fixed -> 11bit (-2 ~ 2)
            float _Integer;
            float _Float;
            float _Range;

            sampler2D _2D;
            sampler3D _3D;
            samplerCube _Cube;

            float4 _Color;  // fixed _Color
            float4 _Vector;

            ENDCG
        }
    }

    // 分配回退
    Fallback "VertexLit"
}