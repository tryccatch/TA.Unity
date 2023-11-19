using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 生成AssetBundle的编辑器工具
/// </summary>
public class ABEditor : MonoBehaviour
{
    /// <summary>
    /// 热更资源的根目录
    /// </summary>
    public static string rootPath = Application.dataPath + "/GAssets";

    /// <summary>
    /// 所有需要打包的AB包信息：一个AssetBundle文件对应了一个AssetBundleBuild对象
    /// </summary>
    public static List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();

    /// <summary>
    /// AB包文件的输出路径
    /// </summary>
    public static string abOutputPath = Application.streamingAssetsPath;

    /// <summary>
    /// 记录哪个asset资源属于哪个AB包文件
    /// </summary>
    public static Dictionary<string, string> asset2bundle = new Dictionary<string, string>();

    /// <summary>
    /// 打包AssetBundle资源
    /// </summary>
    [MenuItem("ABEditor/BuildAssetBundle")]
    public static void BuildAssetBundle()
    {
        Debug.Log("开始--->>>生成所有模块的AB包!");

        if (Directory.Exists(abOutputPath) == true)
        {
            Directory.Delete(abOutputPath, true);
        }

        // 遍历所有模块，针对所有模块都分别打包

        DirectoryInfo rootDir = new DirectoryInfo(rootPath);

        DirectoryInfo[] Dirs = rootDir.GetDirectories();

        foreach (DirectoryInfo moduleDir in Dirs)
        {
            string moduleName = moduleDir.Name;

            assetBundleBuildList.Clear();

            asset2bundle.Clear();

            // 开始给这个模块生成AB包文件

            ScanChildDireations(moduleDir);

            AssetDatabase.Refresh();

            string moduleOutputPath = abOutputPath + "/" + moduleName;

            if (Directory.Exists(moduleOutputPath) == true)
            {
                Directory.Delete(moduleOutputPath, true);
            }

            Directory.CreateDirectory(moduleOutputPath);

            // 压缩选项详解
            // BuildAssetBundleOptions.None：使用LZMA算法压缩，压缩的包更小，但是加载时间更长。使用之前需要整体解压。一旦被解压，这个包会使用LZ4重新压缩。使用资源的时候不需要整体解压。在下载的时候可以使用LZMA算法，一旦它被下载了之后，它会使用LZ4算法保存到本地上。
            // BuildAssetBundleOptions.UncompressedAssetBundle：不压缩，包大，加载快
            // BuildAssetBundleOptions.ChunkBasedCompression：使用LZ4压缩，压缩率没有LZMA高，但是我们可以加载指定资源而不用解压全部

            // 参数一: bundle文件列表的输出路径
            // 参数二：生成bundle文件列表所需要的AssetBundleBuild对象数组（用来指导Unity生成哪些bundle文件，每个文件的名字以及文件里包含哪些资源）
            // 参数三：压缩选项BuildAssetBundleOptions.None默认是LZMA算法压缩
            // 参数四：生成哪个平台的bundle文件，即目标平台

            BuildPipeline.BuildAssetBundles(moduleOutputPath, assetBundleBuildList.ToArray(), BuildAssetBundleOptions.None, EditorUserBuildSettings.activeBuildTarget);

            AssetDatabase.Refresh();
        }

        Debug.Log("结束--->>>生成所有模块的AB包!");
    }

    /// <summary>
    /// 根据指定的文件夹
    /// 1. 将这个文件夹下的所有一级子文件打成一个AssetBundle
    /// 2. 并且递归遍历这个文件夹下的所有子文件夹
    /// </summary>
    /// <param name="directoryInfo"></param>
    public static void ScanChildDireations(DirectoryInfo directoryInfo)
    {
        if (directoryInfo.Name.EndsWith("CSProject~"))
        {
            return;
        }

        // 收集当前路径下的文件 把它们打成一个AB包

        ScanCurrDirectory(directoryInfo);

        // 遍历当前路径下的子文件夹

        DirectoryInfo[] dirs = directoryInfo.GetDirectories();

        foreach (DirectoryInfo info in dirs)
        {
            ScanChildDireations(info);
        }
    }

    /// <summary>
    /// 遍历当前路径下的文件 把它们打成一个AB包
    /// </summary>
    /// <param name="directoryInfo"></param>
    private static void ScanCurrDirectory(DirectoryInfo directoryInfo)
    {
        List<string> assetNames = new List<string>();

        FileInfo[] fileInfoList = directoryInfo.GetFiles();

        foreach (FileInfo fileInfo in fileInfoList)
        {
            if (fileInfo.FullName.EndsWith(".meta"))
            {
                continue;
            }

            // assetName的格式类似 "Assets/GAssets/Launch/Sphere.prefab"

            string assetName = fileInfo.FullName.Substring(Application.dataPath.Length - "Assets".Length).Replace('\\', '/');

            assetNames.Add(assetName);
        }

        if (assetNames.Count > 0)
        {
            // 格式类似 gassets_Launch

            string assetbundleName = directoryInfo.FullName.Substring(Application.dataPath.Length + 1).Replace('\\', '_').ToLower();

            AssetBundleBuild build = new AssetBundleBuild();

            build.assetBundleName = assetbundleName;

            build.assetNames = new string[assetNames.Count];

            for (int i = 0; i < assetNames.Count; i++)
            {
                build.assetNames[i] = assetNames[i];

                // 记录单个资源属于哪个bundle文件

                asset2bundle.Add(assetNames[i], assetbundleName);
            }

            assetBundleBuildList.Add(build);
        }
    }
}