using LitJson;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// 模块资源加载器
/// </summary>
public class AssetLoader : Singleton<AssetLoader>
{
    /// <summary>
    /// 加载模块对应的全局AssetBundle资源管理文件
    /// </summary>
    /// <param name="moduleName"></param>
    /// <returns></returns>
    public async Task<ModuleABConfig> LoadAssetBundleConfig(string moduleName)
    {
#if UNITY_EDITOR
        if (GlobalConfig.BundleMode == false)
        {
            return null;
        }
        else
        {
            return await LoadAssetBundleConfig_Runtime(moduleName);
        }
#else
        return await LoadAssetBundleConfig_Runtime(moduleName);
#endif
    }

    public async Task<ModuleABConfig> LoadAssetBundleConfig_Runtime(string moduleName)
    {
        string url = Application.streamingAssetsPath + "/" + moduleName + "/" + moduleName.ToLower() + ".json";

        UnityWebRequest request = UnityWebRequest.Get(url);

        await request.SendWebRequest();

        if (string.IsNullOrEmpty(request.error) == true)
        {
            return JsonMapper.ToObject<ModuleABConfig>(request.downloadHandler.text);
        }

        return null;
    }
}