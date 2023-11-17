using UnityEditor;
using UnityEngine;
using System.Text;
using System.Collections.Generic;
using System;
using System.IO;
using System.Globalization;
using System.Security.Cryptography;

namespace ProjectBuild { 
    public class ResLoader
    {
        public static T Load<T>(string filePath) where T : UnityEngine.Object
        {
            var fullPath = "Assets/Editor Default Resources/" + filePath;
            return (T)EditorGUIUtility.Load(fullPath);
        }
    }

    public class BuildProject
    {
        static string TempPath = "Assets/Temp";
        static string[] scenes = { "Assets/Scenes/main.unity" };

        public static Dictionary<int, ChannelConfig> channelCfg;

        #region 文件、路径 操作
        static void MoveTo(string sourceDir,string desDir)
        {
            sourceDir = sourceDir.Replace('/', '\\');
            desDir = getProjectPath(desDir);
            desDir = desDir.Replace('/', '\\');
            if (Directory.Exists(desDir))
                Directory.Delete(desDir,true);
            if (!Directory.Exists(sourceDir))
                throw new Exception("dir not exit:" + sourceDir);
            Debug.Log("sourcePath=" + sourceDir);
            Debug.Log("desDir=" + desDir);
            File.Move(sourceDir, desDir);
        }

        private static void OpenDir(string dir)
        {
            System.Diagnostics.Process.Start("explorer.exe", dir.Replace("/", "\\"));
        }

        private static string getProjectPath(string dir)
        {
            return Application.dataPath + "/../../AndroidProjects/" + dir;
        }

        private static string CreateDir(string dir)
        {
            string dirPath = getProjectPath(dir);
            if (!Directory.Exists(dirPath))
            {
                Directory.CreateDirectory(dirPath);
            }
            return dirPath;
        }
        #endregion
    
        public static void StartBuild(Dictionary<int, bool> buildList,GameServerEnum allServerType = GameServerEnum.LocalTest)
        {
            var str = buildList == null ? "全部" : "选中";
            if(buildList == null)
            {
                buildList = new Dictionary<int, bool>();
                foreach(var value in channelCfg.Values)
                {
                    buildList.Add(value.id, true);
                    value.serverType = allServerType;
               
                }
            }
        
            if (!EditorUtility.DisplayDialog("提示", "是否导出   "+str+"   渠道工程？", "确定", "取消"))
            {
                return;
            }

            var result = new Dictionary<int, bool>();
            foreach(var key in buildList.Keys)
            {
                result.Add(key, buildList[key]);
            }

            foreach (var key in result.Keys)
            {
                if (result[key])
                {
                    if(!channelCfg[key].onlyBuildRes)
                        ExportSingleProject(key, channelCfg[key]);
                    ExportSingleAssets(key, channelCfg[key]);
                    CopyAndroidFile(channelCfg[key].channelSymbol);
                }
            }

            EditorUtility.DisplayDialog("提示", "打包完毕！", "退下");
        }

        private static void UseAndroidManifest(ChannelConfig cfg)
        {
            string src_filename = string.Format("AndroidManifest_{0}.xml", cfg.channelSymbol);
            string dst_filename = "AndroidManifest.xml";
            string path = Application.dataPath + "/Plugins/Android/";
            File.Copy(path + src_filename, path + dst_filename, true);

            PlayerSettings.Android.bundleVersionCode = cfg.appBundle;
            PlayerSettings.bundleVersion = cfg.appVer;
            AssetDatabase.Refresh();
        }

        private static void ChangePlugin(string[] path,bool import)
        {
            if (path != null && path.Length > 0)
            {
                foreach (var temp in path)
                {
                    if (string.IsNullOrEmpty(temp))
                        return;
                    var fullPath = "Assets/Plugins/" + temp;
                    PluginImporter vrlib = AssetImporter.GetAtPath(fullPath) as PluginImporter;
                    if (vrlib != null)
                    {
                        vrlib.SetCompatibleWithPlatform(BuildTarget.Android, import);
                        Debug.Log(import ? "添加:" : "剔除:" + fullPath);
                    }
                    else
                    {
                        throw new Exception("can't find lib by dir:" + fullPath);
                    }
                   
                }
            }
        }

        private static void ChangePlugin(ChannelConfig cfg)
        {
            foreach (var info in channelCfg.Values)
            {
                if (info.id != cfg.id)
                {
                    ChangePlugin(info.sdkPath, false);
                }
            }
            ChangePlugin(cfg.sdkPath, true);
     
        }

   

        private static string SetProjectSettings(ChannelConfig cfg)
        {
            string path = CreateDir("");

            //获取当前信息
            string tempid = PlayerSettings.applicationIdentifier;
            string name = PlayerSettings.productName;
            bool virtualRealitySupported = PlayerSettings.virtualRealitySupported;
            string defines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);

            //设置配置渠道信息
            PlayerSettings.virtualRealitySupported = true;
            PlayerSettings.applicationIdentifier = cfg.bundleName;
            Debug.Log("bundleName:" + cfg.bundleName);
            PlayerSettings.productName = cfg.apkName;
            PlayerSettings.Android.bundleVersionCode = cfg.appBundle;
            PlayerSettings.bundleVersion = cfg.appVer;
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
            EditorUserBuildSettings.SetBuildLocation(BuildTarget.Android, path);
            PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android,cfg.channelSymbol+";"+cfg.serverType.ToString());
            UseAndroidManifest(cfg);
            ChangePlugin(cfg);

            //导出工程
            BuildPipeline.BuildPlayer(scenes, path, BuildTarget.Android, BuildOptions.None);

            //恢复配置
            PlayerSettings.virtualRealitySupported = virtualRealitySupported;
            PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, defines);
            PlayerSettings.applicationIdentifier = tempid;
            PlayerSettings.productName = name;
            //PlayerSettings.Android.keystoreName = "";
            //PlayerSettings.Android.keyaliasName = "";
            //PlayerSettings.Android.keyaliasPass = "";
            //PlayerSettings.Android.keystorePass = "";

            string dirName = string.Format("{0}-{1}-{2}-{3}",
               cfg.channelSymbol, cfg.appVer, cfg.appBundle,cfg.serverType.ToString());
            MoveTo(path+ cfg.apkName, cfg.channelSymbol);
            var file = File.CreateText(path + dirName);
            file.Close();
            //OpenDir(getProjectPath(cfg.channelSymbol));
            Debug.Log("导出AS工程完毕");
            return dirName;
        }

        private static string ExportSingleProject(int key, ChannelConfig cfg)
        {
            if(cfg == null)
            {
               throw new Exception("can't export project cause cfg is NULL,key=" + key);
            }
           return  SetProjectSettings(cfg);
        }

        #region AB资源打包


        static int getVer(string ABPath)
        {
            if (!File.Exists(ABPath + "/ver")) return 0;

            var datas = File.ReadAllLines(ABPath + "/ver");
            var strs = datas[0].Split(',');
            

            return int.Parse(strs[1]);
        }


        static Dictionary<String, String> LoadHash(string fileName)
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

        static List<string> LoadList(string fileName)
        {
            var ret = new List<String>();

            if (!File.Exists(fileName)) return ret;

            var datas = File.ReadAllLines(fileName);

            ret.AddRange(datas);

            return ret;
        }

        static void SaveHash(Dictionary<string, string> ret, string fileName)
        {

            var lines = new List<string>();
            foreach (var key in ret.Keys)
            {
                lines.Add(key + "," + ret[key]);
            }
            File.WriteAllLines(fileName, lines);
        }

        static void SaveList(List<string> ret, string fileName)
        {
            File.WriteAllLines(fileName, ret);
        }

        static string GetFileLenAndMD5(byte[] fromData)
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

        private static void ExportSingleAssets(int key,ChannelConfig cfg)
        {
            Debug.Log("开始打包资源:"+cfg.channelSymbol);
            var ABPath = CreateDir(cfg.channelSymbol+"-Assets");
            try { Directory.CreateDirectory(ABPath); }
            catch (Exception) { }

            try { Directory.CreateDirectory(TempPath); }
            catch (Exception) { }

            Dictionary<string, bool> buildType = new Dictionary<string, bool>();
            buildType.Add("prefab", true);
            buildType.Add("mp3", true);
            buildType.Add("ogg", true);
            buildType.Add("wav", true);

            var filePathList = new List<String>();
            var newHash = new Dictionary<String, String>();
            var buildMaps = new List<AssetBundleBuild>();
            var channelFileList = new List<string>();

            GetAllFiles(cfg, filePathList);
            GenerateBuildMap(filePathList,buildMaps,buildType,newHash,cfg,channelFileList);

            var buildMapArr = buildMaps.ToArray();
            BuildAB(buildMapArr, ABPath);
            GenFileHash(ABPath, buildMapArr, newHash);
            GenABVersion(ABPath, cfg, newHash,channelFileList);
            Debug.Log("打包资源完毕:"+cfg.channelSymbol);
        }

        private static void GenFileHash(string ABPath,AssetBundleBuild[] datas, Dictionary<String, String> newHash)
        {
            for(var i = 0; i < datas.Length; i++)
            {
                var key = datas[i].assetBundleName;
                if (newHash.ContainsKey(key))
                    continue;
                var abPath = Path.Combine(ABPath, key);
                var abbytes = File.ReadAllBytes(abPath);
                var md5 = GetFileLenAndMD5(abbytes);
                newHash.Add(key, md5);
            }
        }

        private static void GenABVersion(string ABPath,ChannelConfig cfg,Dictionary<string,string> newHash,
            List<string> channelFileList)
        {
            var versionDict = LoadHash(Path.Combine(ABPath, "ver.ver"));
            var oldHash = LoadHash(Path.Combine(ABPath, "filehash.ver"));

            var verFileVersion = 0;
            if (versionDict.ContainsKey("ver"))
                verFileVersion = int.Parse(versionDict["ver"]);

            var isNewBundleVersion = false;
            var bundleCode = cfg.appBundle;
            var lines = new List<string>();
            if (versionDict.ContainsKey("bundle"))
                isNewBundleVersion = bundleCode > int.Parse(versionDict["bundle"]);
            else
                isNewBundleVersion = true;

            if (isNewBundleVersion)
            {
                lines.Insert(0, "bundle," + bundleCode);
                lines.Insert(1, "version," + cfg.appVer);
            }

            var hasNewFile = false;

            foreach (var v in newHash)
            {
                if (oldHash.ContainsKey(v.Key) && oldHash[v.Key] == v.Value)
                {
                    lines.Add(v.Key + "," + versionDict[v.Key]);
                }
                else
                {
                    if (!hasNewFile)
                    {
                        verFileVersion++;
                        if (!isNewBundleVersion)
                        {
                            lines.Insert(0, "bundle," + bundleCode);
                            lines.Insert(1, "version," + cfg.appVer);
                        }
                        lines.Insert(lines.Count, "ver," + verFileVersion);
                        hasNewFile = true;
                    }

                    lines.Add(v.Key + "," + verFileVersion);
                }
            }

            if (hasNewFile || isNewBundleVersion)
            {
                SaveHash(newHash, Path.Combine(ABPath, "filehash.ver"));
                SaveList(lines,Path.Combine(ABPath, "ver.ver"));
                SaveList(channelFileList,Path.Combine(ABPath, "channelfile.ver"));

                var verByteFilePath = Path.Combine(TempPath, "ver.bytes");
                var channelByteFilePath = Path.Combine(TempPath, "channelfile.bytes");
                SaveList(lines,verByteFilePath);
                SaveList(channelFileList, channelByteFilePath);

                var fileInfoBuildArr = new AssetBundleBuild[2];
                fileInfoBuildArr[0] = CreateAssetBundleBuild("ver", verByteFilePath);
                fileInfoBuildArr[1] = CreateAssetBundleBuild("channelFile", channelByteFilePath);

                BuildAB(fileInfoBuildArr, ABPath);
            }

            openDir(ABPath);

        }

        static void openDir(string dir)
        {
    #if UNITY_EDITOR_WIN
            System.Diagnostics.Process.Start("explorer.exe", dir.Replace("/", "\\"));
    #endif
        }

        private static void GetAllFiles(ChannelConfig cfg,List<string> filePathList)
        {
            string[] dirs = { "Lua", "Resource" };
            GetFolderAllFilePath("Lua", filePathList);
            GetFolderAllFilePath("Resource/Common", filePathList);
            GetFolderAllFilePath("Resource/Channel_" + cfg.channelSymbol, filePathList);
        }

        private static void GetFolderAllFilePath(string folder,List<string> filePathList)
        {
            var path = Application.dataPath + "/" + folder + "/";
            string[] curFiles = Directory.GetFiles(path, "*.*", SearchOption.AllDirectories);
            filePathList.AddRange(curFiles);
        }

        private static string[] ignoreFileExtensionNames = { ".meta", ".idea" };
        private static bool isNoUseFiles(string filePath)
        {
            foreach (var item in ignoreFileExtensionNames)
            {
                if (filePath.IndexOf(item) >= 0)
                    return true;
            }

            return false;
        }

        private static string GetFileNameByPath(string filePath)
        {
            var pos = filePath.IndexOf("Assets");
            filePath = filePath.Substring(pos);//去除Assets之前的目录

            var name = filePath.Substring("Assets/".Length);//去除 Assets/
            if (name.IndexOf("Resource") == 0)
            {
                name = name.Substring("Resource/".Length);//去除 Resouce/
            }

            name = name.Replace("\\", "_");
            name = name.Replace("/", "_");

            return name;
        }

        private static string getFileTypeByPath(string fileName)
        {
            var pos = fileName.LastIndexOf(".");
            if (pos >= 0)
                return fileName.Substring(pos + 1);
            else
                return null;
        }

        private static string copyFileToTempPath(string filePath,string fileName,string keyName,Dictionary<string, string> newHash)
        {
            var toFile = string.Format("{0}/{1}.bytes", TempPath, fileName);
            var fileBytes = File.ReadAllBytes(filePath);
            var md5 = GetFileLenAndMD5(fileBytes);
            if(!newHash.ContainsKey(keyName))
                newHash.Add(keyName, md5);
            File.WriteAllBytes(toFile, fileBytes);
            return toFile;
        }

        private static AssetBundleBuild CreateAssetBundleBuild(string keyName,string filePath)
        {
            var pos = filePath.IndexOf("Assets");
            if(pos>=0)
                filePath = filePath.Substring(pos);
            var buildMap = new AssetBundleBuild();
            buildMap.assetBundleName = keyName;
            string[] assetPath = { filePath };
            buildMap.assetNames = assetPath;
            return buildMap;
        }

        private static void GenerateBuildMap(List<String> filePathList, List<AssetBundleBuild> buildMaps,
            Dictionary<string, bool> buildType,Dictionary<string,string> newHash,ChannelConfig cfg,
            List<string> channelFileList)
        {
            for (var i = 0; i < filePathList.Count; ++i)
            {
                EditorUtility.DisplayProgressBar("提示", "预处理资源", i * 1f / filePathList.Count);
                var crtFilePath = filePathList[i];
                if (isNoUseFiles(crtFilePath))
                    continue;
           
                var fileName = GetFileNameByPath(crtFilePath);
                var fileType = getFileTypeByPath(fileName);
                fileName = fileName.Replace("." + fileType, "");
                var keyFileName = fileName.ToLower();

                if (CheckIsChannelFile(crtFilePath, cfg))
                    if(!channelFileList.Contains(keyFileName))
                        channelFileList.Add(keyFileName);

                if (!buildType.ContainsKey(fileType))//处理图片
                    crtFilePath = copyFileToTempPath(crtFilePath, fileName, keyFileName, newHash);
                buildMaps.Add(CreateAssetBundleBuild(keyFileName, crtFilePath));
                Debug.Log("build:" + crtFilePath + " -> " + fileName+"keyName->"+keyFileName);
            }
        }

        private static bool CheckIsChannelFile(string filePath,ChannelConfig cfg)
        {
            return filePath.IndexOf("Channel_" + cfg.channelSymbol) >= 0;
        }

        private static void BuildAB(AssetBundleBuild[] buildMaps,string ABPath)
        {
            AssetDatabase.Refresh();
            BuildPipeline.BuildAssetBundles(ABPath, buildMaps,
                BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.Android);
        }

        #endregion

        #region 文件复制

        private static string getWindowPath(string path)
        {
            return path.Replace('/', '\\');
        }

        private static void CopyAndroidFile(string channelSymbol)
        {
            var motherAsResPath = getWindowPath(getProjectPath("Mother_" + channelSymbol+"/src/main/assets"));
            var crtAsResPath = getWindowPath(getProjectPath(channelSymbol + "/src/main/assets"));
            var crtABResPath = getWindowPath(getProjectPath(channelSymbol+ "-Assets"));
            if (Directory.Exists(motherAsResPath))
                Directory.Delete(motherAsResPath, true);
            CopyFolder(crtAsResPath, motherAsResPath);
            CopyFolder(crtABResPath, motherAsResPath);

            var sourceGradle = File.ReadAllBytes(getWindowPath(getProjectPath(channelSymbol + "/build.gradle")));
            var targetGradlePath = getWindowPath(getProjectPath("Mother_" + channelSymbol + "/build.gradle"));
            if (File.Exists(targetGradlePath))
                File.Delete(targetGradlePath);
            File.WriteAllBytes(targetGradlePath, sourceGradle);

            
        }

        /// <summary>
        /// 复制文件夹及文件
        /// </summary>
        /// <param name="sourceFolder">原文件路径</param>
        /// <param name="destFolder">目标文件路径</param>
        /// <returns></returns>
        static int CopyFolder(string sourceFolder, string destFolder)
        {
            try
            {
                //如果目标路径不存在,则创建目标路径
                if (!System.IO.Directory.Exists(destFolder))
                {
                    System.IO.Directory.CreateDirectory(destFolder);
                }
                //得到原文件根目录下的所有文件
                string[] files = System.IO.Directory.GetFiles(sourceFolder);
                foreach (string file in files)
                {
                    string name = System.IO.Path.GetFileName(file);
                    string dest = System.IO.Path.Combine(destFolder, name);
                    System.IO.File.Copy(file, dest,true);//复制文件
                }
                //得到原文件根目录下的所有文件夹
                string[] folders = System.IO.Directory.GetDirectories(sourceFolder);
                foreach (string folder in folders)
                {
                    string name = System.IO.Path.GetFileName(folder);
                    string dest = System.IO.Path.Combine(destFolder, name);
                    CopyFolder(folder, dest);//构建目标路径,递归复制文件
                }
                return 1;
            }
            catch (Exception e)
            {
                EditorUtility.DisplayDialog("复制出错",e.Message,"退下");
                return 0;
            }

        }
        #endregion
    }
}