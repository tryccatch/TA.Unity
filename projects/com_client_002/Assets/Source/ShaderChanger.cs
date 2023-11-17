using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

/// <summary>
/// 图片置灰
/// </summary>
public static class ShaderChanger {
    private static Dictionary<string,Material> mats;

    /// <summary>
    /// 创建置灰材质球
    /// </summary>
    /// <returns></returns>
    private static Material GetGrayMat(string shaderName)
    {
        if (mats == null) {
            mats = new Dictionary<string, Material>();
        }

        if (!mats.ContainsKey(shaderName))
        {
            Shader shader = Shader.Find(shaderName);
            if(shader==null)
            {
                Debug.Log("can't find shader:" + shader);
                return null;
            }

            Material mat = new Material(shader);
            mats.Add(shaderName,mat);

            return mat;
        }

        return mats[shaderName];
    }

    /// <summary>
    /// 图片置灰
    /// </summary>
    /// <param name="img"></param>
    public static void Set(Transform node,string shader)
    {
        var img = node.GetComponent<MaskableGraphic>();
        if (img != null)  {
            img.material = GetGrayMat(shader);
            img.SetMaterialDirty();
        }

    }

     public static void Clear(Transform node)
    {
        var img = node.GetComponent<MaskableGraphic>();
        if (img != null)  {        
            img.material = null;
            img.SetMaterialDirty();
        }
    }    

}