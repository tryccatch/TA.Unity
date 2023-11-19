using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 在内存中的一个Bundle对象
/// </summary>
public class BundleRef
{
    /// <summary>
    /// 这个 bundle 的静态配置信息
    /// </summary>
    public BundleInfo bundleInfo;

    /// <summary>
    /// 加载到内存的Bundle对象
    /// </summary>
    public AssetBundle bundle;

    /// <summary>
    /// 这些BundleRef对象被哪些AssetRef对象依赖
    /// </summary>
    public List<AssetRef> children;

    /// <summary>
    /// BundleRef的构造函数
    /// </summary>
    /// <param name="bundleInfo"></param>
    public BundleRef(BundleInfo bundleInfo)
    {
        this.bundleInfo = bundleInfo;
    }
}