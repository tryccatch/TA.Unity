using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System;
using System.Security.Cryptography;

public class BuildAssets
{
    static string TempPath = "Assets/Temp";
    static string ABPath = "../release/StreamingAssets";

    static void openDir(string dir)
    {
        System.Diagnostics.Process.Start("explorer.exe", dir.Replace("/", "\\"));
    }

    static void test(string url)
    {
        var toPath = TempPath + "/test/";
        var sysPath = toPath.Replace("/", "\\");
        Directory.CreateDirectory(sysPath);
        var path1 = toPath + "test1.bytes";
        var path2 = toPath + "test2.bytes";
        var content = File.ReadAllBytes(url);
        File.WriteAllBytes(path1, content);
        File.WriteAllBytes(path2, content);
        var ab1 = new AssetBundleBuild();
        ab1.assetBundleName = "test1";
        ab1.assetNames = new string[] { path1 };

        var ab2 = new AssetBundleBuild();
        ab2.assetBundleName = "test2";
        ab2.assetNames = new string[] { path2 };

        var buildMap = new AssetBundleBuild[] { ab1, ab2 };

        var abPath = TempPath + "/AB/";
        Directory.CreateDirectory(abPath.Replace("/", "\\"));
        BuildPipeline.BuildAssetBundles(abPath, buildMap,
        BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.Android);
        System.Diagnostics.Process.Start("explorer.exe", abPath.Replace("/","\\"));
    }

    [MenuItem("Tools/BuildAssets")] 
    static void Build() {


        if ( !UnityEditor.EditorUtility.DisplayDialog("提示","是不是要编译资源？","确定","取消") ) {
            return;    
        }

        try {
            Directory.CreateDirectory(ABPath);           
        } catch(Exception) {}     

         try {
            Directory.CreateDirectory(TempPath); 
        } catch(Exception) {}

        var oldHash = LoadHash(Path.Combine(ABPath, "filehash.ver"));
        var newHash = new Dictionary<String, String>();
       
        //var hash = new Dictionary<String, String>();
        //foreach (var h in oldHash)
        //{
        //    hash.Add(h.Value, h.Key);
        //}

		
        List<AssetBundleBuild> buildMaps = new List<AssetBundleBuild>();    
        
        var dirs = new string[]{"Lua","Resource"};

        Dictionary<string,bool> buildType = new Dictionary<string,bool>();
        buildType.Add("prefab",true);
        buildType.Add("mp3",true);
        buildType.Add("ogg",true);
        buildType.Add("wav",true);

        var fileMap = new Dictionary<string, string>();

        var files = new List<String>();

        foreach (var dir in dirs) {
            var path = Application.dataPath + "/" + dir + "/";
            string[] curFiles = Directory.GetFiles (path, "*.*", SearchOption.AllDirectories);
            files.AddRange(curFiles);
        }

        for (var i = 0; i < files.Count; i++)
        {
            EditorUtility.DisplayProgressBar("提示", "预处理资源", i * 1f / files.Count);

            var file = files[i];

            var pos = file.IndexOf(".meta");
            if (pos >= 0) continue;

            if (file.IndexOf(".idea") >= 0)
                continue;           
          
            pos = file.IndexOf("Assets");
            file = file.Substring(pos);

            var name = file.Substring("Assets/".Length);
            if (name.IndexOf("Resource") == 0)
            {
                name = name.Substring("Resource/".Length);
            }

            name = name.Replace("\\", "_");
            name = name.Replace("/", "_");

            pos = name.LastIndexOf(".");
            var type = name.Substring(pos + 1);

            var buildAsset = buildType.ContainsKey(type);
            name = name.Substring(0, pos);

            var keyName = name.ToLower();            

            if (!buildAsset)
            {
                /*
                 * 这里主要是图片处理:
                 * 1. 将图片写成二进制数据，再打包AB，会让AB包更小（等待验证）
                 * 2. 将MD5相同的图片，进行文件名映射，保证相同图片只打一次
                 */
                //Debug.Log("copy:" + file + " -> " + name);
                var toFile = TempPath + "/" + name + ".bytes";

                var bytes = File.ReadAllBytes(file);
                var h = GetFileLenAndMD5(bytes);

                //if(!hash.ContainsKey(h))
                //    hash.Add(h, keyName);
                if(!newHash.ContainsKey(keyName))
                    newHash.Add(keyName, h);

                File.WriteAllBytes(toFile, bytes);
                file = toFile;                
            }

            AssetBundleBuild buildMap = new AssetBundleBuild();
            buildMap.assetBundleName = keyName;

            string[] enemyAssets = new string[1];
            enemyAssets[0] = file;

            buildMap.assetNames = enemyAssets;

            buildMaps.Add(buildMap);

            Debug.Log("build:" + file + " -> " + name);
        }

        AssetDatabase.Refresh();

        var datas = buildMaps.ToArray();
        BuildPipeline.BuildAssetBundles(ABPath, datas, 
        BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.Android);


        for (var i = 0; i < datas.Length; i++)
        {
            var key = datas[i].assetBundleName;

            if (newHash.ContainsKey(key))
            {
                continue;
            }

            var file = Path.Combine(ABPath,key);

            var bytes = File.ReadAllBytes(file);
            var h = GetFileLenAndMD5(bytes);

            newHash.Add(key, h);
        }

        var verData = LoadHash(Path.Combine(ABPath, "ver.ver"));

        var verId = 0;
        if (verData.ContainsKey("ver"))
        {
            verId = int.Parse(verData["ver"]);
        }

        var isNewVersion = false;
        var bundleCode = PlayerSettings.Android.bundleVersionCode;
        var lines = new List<string>();

        if (verData.ContainsKey("bundle"))
            isNewVersion = bundleCode > int.Parse(verData["bundle"]);
        else
            isNewVersion = true;

        if (isNewVersion)
        {
            lines.Insert(0, "bundle," + bundleCode);
            lines.Insert(1, "version," + Application.version);
        }

        var hasNew = false;

        foreach (var v in newHash)
        {
            if (oldHash.ContainsKey(v.Key) && oldHash[v.Key] == v.Value)
            {
                lines.Add(v.Key + "," + verData[v.Key]);
            }
            else
            {
                if (!hasNew)
                {
                    verId++;
                    if (!isNewVersion)
                    {
                        lines.Insert(0, "bundle," + bundleCode);
                        lines.Insert(1, "version," + Application.version);
                    }
                    lines.Insert(lines.Count, "ver," + verId);
                    hasNew = true;
                }
                
                lines.Add(v.Key + "," + verId);
            }
        }

        if (hasNew||isNewVersion)
        {
            SaveHash(newHash, Path.Combine(ABPath,"filehash.ver"));
            File.WriteAllLines(Path.Combine(ABPath,"ver.ver"), lines);
            SaveHash(fileMap, Path.Combine(ABPath, "filemap.ver"));

            datas = new AssetBundleBuild[2];

            var file = Path.Combine(TempPath, "ver.bytes");   
			File.WriteAllLines(file, lines);
			
			AssetBundleBuild buildMap = new AssetBundleBuild();
            buildMap.assetBundleName = "ver";

            string[] enemyAssets = new string[1];
            enemyAssets[0] = file;

            buildMap.assetNames = enemyAssets;
			datas[0] = buildMap;


            file = Path.Combine(TempPath, "filemap.bytes");
            SaveHash(fileMap, file);
            buildMap = new AssetBundleBuild();
            buildMap.assetBundleName = "filemap";

            enemyAssets = new string[1];
            enemyAssets[0] = file;

            buildMap.assetNames = enemyAssets;
            datas[1] = buildMap;

            BuildPipeline.BuildAssetBundles(ABPath, datas, 
            BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.Android);
        }

        openDir(ABPath);

    }


    static int getVer()
    {
        if (!File.Exists(ABPath + "/ver")) return 0;

        var datas = File.ReadAllLines(ABPath + "/ver");
        var strs = datas[0].Split(',');

        return int.Parse(strs[1]);
    }


    static Dictionary<String,String> LoadHash(string fileName)
    {
        var ret = new Dictionary<String, String>();

        if (!File.Exists(fileName)) return ret;

        var datas = File.ReadAllLines(fileName);

        foreach (var line in datas)
        {
            var strs = line.Split(',');
            ret.Add(strs[0], strs[1]);
        }

        return ret;
    }

    static void SaveHash(Dictionary<String, String> ret,String fileName)
    {

        var lines = new List<string>();
        foreach (var key in ret.Keys) {
            lines.Add(key + "," + ret[key]);
        }
        File.WriteAllLines(fileName, lines);
    }


    public static string GetFileLenAndMD5(byte[] fromData)
    {

        var md5 = new MD5CryptoServiceProvider();

        byte[] targetData = md5.ComputeHash(fromData);
        string byte2String = "";

        for (int i = 0; i < targetData.Length; i++)
        {
            byte2String += targetData[i].ToString("x");
        }

        return fromData.Length + "-" + byte2String;
    }

    static string getNameOnly(string file)
    {
        var pos1 = file.LastIndexOf("/");
        var pos2 = file.LastIndexOf("\\");
        var pos = Mathf.Max(pos1, pos2);

        if (pos < 0)
        {
            pos = 0;
        }
        else
        {
            pos++;
        }

        return file.Substring(pos);

    }
}