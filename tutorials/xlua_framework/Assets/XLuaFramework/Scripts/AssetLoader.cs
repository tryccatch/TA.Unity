using LitJson;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEditor;
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

    /// <summary>
    /// 平台对应的只读路径下的资源
    /// Key 模块名字
    /// Value 模块所有的资源
    /// </summary>
    public Dictionary<string, Hashtable> base2Assets;

    /// <summary>
    /// 模块资源加载器的构造函数
    /// </summary>
    public AssetLoader()
    {
        base2Assets = new Dictionary<string, Hashtable>();
    }

    /// <summary>
    /// 根据模块的json配置文件 创建 内存中的资源容器
    /// </summary>
    /// <param name="moduleABConfig"></param>
    /// <returns></returns>
    public Hashtable ConfigAssembly(ModuleABConfig moduleABConfig)
    {
        Dictionary<string, BundleRef> name2BundleRef = new Dictionary<string, BundleRef>();

        foreach (KeyValuePair<string, BundleInfo> keyValue in moduleABConfig.BundleArray)
        {
            string bundleName = keyValue.Key;

            BundleInfo bundleInfo = keyValue.Value;

            name2BundleRef[bundleName] = new BundleRef(bundleInfo);
        }

        Hashtable Path2AssetRef = new Hashtable();

        for (int i = 0; i < moduleABConfig.AssetArray.Length; i++)
        {
            AssetInfo assetInfo = moduleABConfig.AssetArray[i];

            // 装配一个AssetRef对象

            AssetRef assetRef = new AssetRef(assetInfo);

            assetRef.bundleRef = name2BundleRef[assetInfo.bundle_name];

            int count = assetInfo.dependencies.Count;

            assetRef.dependencies = new BundleRef[count];

            for (int index = 0; index < count; index++)
            {
                string bundleName = assetInfo.dependencies[index];

                assetRef.dependencies[index] = name2BundleRef[bundleName];
            }

            // 装配好了放到Path2AssetRef容器中

            Path2AssetRef.Add(assetInfo.asset_path, assetRef);
        }

        return Path2AssetRef;
    }

    /// <summary>
    /// 克隆一个GameObject对象
    /// </summary>
    /// <param name="moduleName">模块的名字</param>
    /// <param name="path"></param>
    /// <returns></returns>
    public GameObject Clone(string moduleName, string path)
    {
        AssetRef assetRef = LoadAssetRef<GameObject>(moduleName, path);

        if (assetRef == null || assetRef.asset == null)
        {
            return null;
        }

        GameObject gameObject = UnityEngine.Object.Instantiate(assetRef.asset) as GameObject;

        if (assetRef.children == null)
        {
            assetRef.children = new List<GameObject>();
        }

        assetRef.children.Add(gameObject);

        return gameObject;
    }

    /// <summary>
    /// 加载 AssetRef 对象
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="moduleName">模块名字</param>
    /// <param name="assetPath">资源的相对路径</param>
    /// <returns></returns>
    private AssetRef LoadAssetRef<T>(string moduleName, string assetPath) where T : UnityEngine.Object
    {
#if UNITY_EDITOR
        if (GlobalConfig.BundleMode == false)
        {
            return LoadAssetRef_Editor<T>(moduleName, assetPath);
        }
        else
        {
            return LoadAssetRef_Runtime<T>(moduleName, assetPath);
        }
#else
        return LoadAssetRef_Runtime<T>(moduleName, assetPath);
#endif
    }

    /// <summary>
    /// 在编辑器模式下加载 AssetRef 对象
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="moduleName">模块名字</param>
    /// <param name="assetPath">资源的相对路径</param>
    /// <returns></returns>
    private AssetRef LoadAssetRef_Editor<T>(string moduleName, string assetPath) where T : UnityEngine.Object
    {
#if UNITY_EDITOR
        if (string.IsNullOrEmpty(assetPath))
        {
            return null;
        }

        AssetRef assetRef = new AssetRef(null);

        assetRef.asset = AssetDatabase.LoadAssetAtPath<T>(assetPath);

        return assetRef;
#else
        return null;
#endif
    }

    /// <summary>
    /// 在AB包模式下加载 AssetRef 对象
    /// </summary>
    /// <typeparam name="T">要加载的资源类型</typeparam>
    /// <param name="moduleName">模块名字</param>
    /// <param name="assetPath">资源的相对路径</param>
    /// <returns></returns>
    private AssetRef LoadAssetRef_Runtime<T>(string moduleName, string assetPath) where T : UnityEngine.Object
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            return null;
        }

        Hashtable module2AssetRef;

        bool moduleExsit = base2Assets.TryGetValue(moduleName, out module2AssetRef);

        if (moduleExsit == false)
        {
            Debug.LogError("未找到资源对应的模块：moduleName " + moduleName + " assetPath " + assetPath);

            return null;
        }

        AssetRef assetRef = (AssetRef)module2AssetRef[assetPath];

        if (assetRef == null)
        {
            Debug.LogError("未找到资源：moduleName " + moduleName + " path " + assetPath);

            return null;
        }

        if (assetRef.asset != null)
        {
            return assetRef;
        }

        // 1. 处理assetRef依赖的BundleRef列表

        foreach (BundleRef oneBundleRef in assetRef.dependencies)
        {
            if (oneBundleRef.bundle == null)
            {
                string bundlePath = BundlePath(moduleName, oneBundleRef.bundleInfo.bundle_name);

                oneBundleRef.bundle = AssetBundle.LoadFromFile(bundlePath);
            }

            if (oneBundleRef.children == null)
            {
                oneBundleRef.children = new List<AssetRef>();
            }

            oneBundleRef.children.Add(assetRef);
        }

        // 2. 处理assetRef属于的那个BundleRef对象

        BundleRef bundleRef = assetRef.bundleRef;

        if (bundleRef.bundle == null)
        {
            bundleRef.bundle = AssetBundle.LoadFromFile(BundlePath(moduleName, bundleRef.bundleInfo.bundle_name));
        }

        if (bundleRef.children == null)
        {
            bundleRef.children = new List<AssetRef>();
        }

        bundleRef.children.Add(assetRef);

        // 3. 从bundle中提取asset

        assetRef.asset = assetRef.bundleRef.bundle.LoadAsset<T>(assetRef.assetInfo.asset_path);

        if (typeof(T) == typeof(GameObject) && assetRef.assetInfo.asset_path.EndsWith(".prefab"))
        {
            assetRef.isGameObject = true;
        }
        else
        {
            assetRef.isGameObject = false;
        }

        return assetRef;
    }

    /// <summary>
    /// 工具函数 根据模块名字和bundle名字，返回其实际资源路径
    /// </summary>
    /// <param name="moduleName"></param>
    /// <param name="bundleName"></param>
    /// <returns></returns>
    private string BundlePath(string moduleName, string bundleName)
    {
        return Application.streamingAssetsPath + "/" + moduleName + "/" + bundleName;
    }
}