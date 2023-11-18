//#define TestLoad 
using UnityEngine;
using System.IO;
using System.Collections.Generic;
using XLua;


public class ResTools
{
    class Counter {
        public float lastTime;
        public Object obj;
    }

    static Dictionary<string, Counter> cachRes = new Dictionary<string, Counter>();

    public static Object Load(string orgRes,bool isLua=false,bool cache = true)
    {
        
        var key = orgRes.Replace("/", "_");
        key = key.Replace("\\", "_");
        key = key.ToLower();

        var keyWithChannel = GetChannelResKey(key, isLua);

        if (cachRes.ContainsKey(keyWithChannel))
        {
            var ret = cachRes[keyWithChannel];
            ret.lastTime = Time.time;
            return ret.obj;
        }

        var verPackage = getPackageVer(keyWithChannel);
        var verDownload = getDownloadVer(keyWithChannel);

        Debug.Log("�ԱȰ汾�ļ���" + verPackage + "��" + verDownload);
        Object prefab;
        if (verDownload > verPackage)
        {
            prefab = LoadDownload(orgRes, keyWithChannel, isLua);
        } else
        {
            prefab = LoadPackage(orgRes, key,isLua);
        }

        if (cache)
        {
            var counter = new Counter();
            counter.lastTime = Time.time;
            counter.obj = prefab;
            cachRes[keyWithChannel] = counter;
        }  

        return prefab;
    }

    public static Object LoadDownload(string orgRes, string resKeyWithChannel,bool isLua)
    {
        Object prefab = null;

        try
        {
           
            var bundle = AssetBundle.LoadFromFile(Path.Combine(Application.persistentDataPath,resKeyWithChannel));
            Debug.Log("��������AB:" + Path.Combine(Application.persistentDataPath, resKeyWithChannel));
            if (bundle == null)
            {
                Debug.Log("can't found res:" + resKeyWithChannel);
                return null;
            }

            var objs = bundle.LoadAllAssets();
            prefab = objs[0];
        }
        catch (System.Exception e)
        {
            Debug.Log("can't found res:" + resKeyWithChannel);
            return null;
        }

        //Debug.Log(prefab);
        if (prefab == null)
        {
            Debug.Log("can't found res:" + orgRes);
            return null;
        }

        return prefab;
    }

    private static bool IsChannelRes(string resName)
    {
        if (netChannelFile != null)
            return netChannelFile.Contains(ChannelMgr.channelPrefix + resName);
        else if (pkgChannelFile != null)
            return pkgChannelFile.Contains(ChannelMgr.channelPrefix + resName);
        else
            return false;
    }

    private static string GetChannelResKey(string resName,bool isLua =false)
    {
        if (isLua)
            return resName;
        else if (IsChannelRes(resName))
            return ChannelMgr.channelPrefix + resName;
        else
            return "common_" + resName;
    }
    
    
    public static Object LoadPackage(string orgRes,string res,bool isLua) {       

        //Debug.Log(res);
        Object prefab = null;

#if UNITY_EDITOR && (!TestLoad)
        string[] resType = { ".prefab", ".ogg", ".mp3", ".wav" };
        for (int j = 0; j < resType.Length; j++)
        {
            string path = "";
            if(!isLua){
                if(IsChannelRes(res))
                    path = ChannelMgr.channelDir + "/";
                else
                    path = "Common/";
            }
            
            prefab = UnityEditor.AssetDatabase.LoadAssetAtPath<Object>("Assets/Resource/" + path + orgRes + resType[j]);

            if (prefab != null)
            {
                break;
            }
        }
#else

        try
        {
            var realRes = GetChannelResKey(res,isLua);
        
#if UNITY_EDITOR
            var bundle = AssetBundle.LoadFromFile(Path.Combine(Application.streamingAssetsPath, realRes));
#else
            var bundle = AssetBundle.LoadFromFile(Application.dataPath+"!assets/"+realRes);
            Debug.Log("���� Package android AB:"+(Application.dataPath+"!assets/"+realRes));
#endif
            if (bundle == null) {
                Debug.Log("can't found res:" + realRes);
                return null;
             }
                
             var objs = bundle.LoadAllAssets();            
             prefab =  objs[0];                  
    } catch(System.Exception e) {
         Debug.Log("can't found res:" + res);
         return null;
    }
            
#endif

        //Debug.Log(prefab);
        if (prefab == null) {
            Debug.Log("can't found res:" + orgRes);
            return null;
        }      

        return prefab;
    }

    public static byte[] ReadLuaBytes(ref string res)
    {


#if UNITY_EDITOR && (!TestLoad)

        if (res.IndexOf(".bytes") < 0) {
            res = "Lua/" + res.Replace('.', '/');
            res += ".lua";
        } else {
            res = "Lua/" + res;
        }

        var filePath = Path.Combine(Application.dataPath, res);
        //Debug.Log(filePath);
        if (File.Exists(filePath)) {
            return File.ReadAllBytes(filePath);
        }
        else {
            Debug.Log("can't found:" + res);
            return null;
        }
#else
            var pos = res.IndexOf(".bytes");
            if ( pos < 0) {                
                res = "Lua/" + res.Replace('.', '/');
            } else {
                res = "Lua/" + res.Substring(0,pos);
            }

            var obj = Load(res,true) as TextAsset;
            return obj.bytes;     
#endif
    }


    public static Object LoadSound(string res) {
        Object prefab = Load("Sound/" + res);

        //Debug.Log(prefab);
        if (prefab == null) {
            return null;
        }

        return prefab;
    }

    class TexCounter
    {
        public Texture tex;
        public float time;
        public TexCounter(Texture tex)
        {
            this.tex = tex;
            time = Time.time;
        }
    }
    private static Dictionary<string, TexCounter> texturePool;
    static int maxCacheTexCount = 50;
    static int cleanTexCount = 25;

    private static string getKeyByPath(string tempPath)
    {
        var key = tempPath.Replace("/", "_");
        key = key.Replace("\\", "_");
        key = key.ToLower();
        if (filemap != null && filemap.ContainsKey(key)) {
            key = filemap[key];
            Debug.Log("��ӳ��ͼƬ��Ϣ:ԭʼ·��=" + tempPath + "��value=" + key);
        }
        else
        {
            Debug.Log("û��ӳ��ͼƬ��Ϣ:ԭʼ·��=" + tempPath + "��value=" + key);
        }
        return key;
    }

    public static Texture LoadImage(string path,bool cache =true) {

        if (path == null) return null;
        path = path.Trim();
        if (path == "") return null;

        if (texturePool == null)
            texturePool = new Dictionary<string, TexCounter>();

#if UNITY_EDITOR && (!TestLoad)
        var filePath = Application.dataPath + "/Resource/Common/Image/" + path;

        byte[] datas = null;

        string[] resType = { ".png", ".jpg" };
        string tempPath = "";
        for (int j = 0; j < resType.Length; j++) {
            tempPath = filePath + resType[j];
            if (texturePool.ContainsKey(tempPath) && cache)
            {
                return texturePool[tempPath].tex;
            }
            if (File.Exists(tempPath)) {
                datas = File.ReadAllBytes(filePath + resType[j]);
                break;
            }
        }

        if (datas != null) {
            var ret = new Texture2D(1, 1);
            ret.LoadImage(datas);
            if (cache)
            {
                
                tryReleaseImage(tempPath);
                texturePool.Add(tempPath, new TexCounter(ret));
            }
            return ret;
        }

#else
            var tempPath = "Image/" + path;
            Debug.Log("LoadImage:"+tempPath);
            var key = GetChannelResKey(tempPath);
            if (texturePool.ContainsKey(key) && cache)
                return texturePool[key].tex;

            var obj = Load(tempPath);          

            if (obj != null) {
                var res = obj as TextAsset;
                var ret = new Texture2D(1, 1);
                ret.LoadImage(res.bytes);
                if(cache){
                    tryReleaseImage(key);
                    texturePool.Add(key, new TexCounter(ret));
                }
                return ret;
            } 
#endif

        if (path != "") {
            Debug.Log("can't found image:" + path);
        }

        return null;
    }

    private static void tryReleaseImage(string crtImgPath)
    {
        if(texturePool.Values.Count > maxCacheTexCount)
        {
            Debug.Log("�ͷ���Դ��");
            var list = new List<KeyValuePair<string, TexCounter>>();
            foreach(var item in texturePool)
            {
                list.Add(item);
            }

            list.Sort((a, b) =>
            {
                if (a.Value.time > b.Value.time)
                    return 1;
                else
                    return -1;
            });

            for(int i=0;i < cleanTexCount; i++)
            {
                if(list[i].Key != crtImgPath)
                {
                    texturePool.Remove(list[i].Key);
                }
            }
        }
    }
    static string downloadAddr = "http://127.0.0.1:9788/";
    static string hotFixAddr = "http://127.0.0.1:9788/";

    static Dictionary<string, int> pakageVer;//�洢����ver.ver
    static Dictionary<string, int> downloadVer;//�洢����ver.ver
    static Dictionary<string, int> netVer;
    static List<string> pkgChannelFile;
    static List<string> netChannelFile;
    static Dictionary<string, string> filemap;


    public static int getPackageVer(string resWithChannel)
    {
        if  (pakageVer == null)
        {
            return 0;
        }

        if (pakageVer.ContainsKey(resWithChannel))
        {
            return pakageVer[resWithChannel];
        }

        return 0;
    }

    public static int getDownloadVer(string resWithChannel)
    {
        if (downloadVer == null)
        {
            return 0;
        }

        if (downloadVer.ContainsKey(resWithChannel))
        {
            return downloadVer[resWithChannel];
        }

        return 0;
    }

    public static void ClearAllRes(bool unloadAllObjects)
    {
        cachRes.Clear();
        Images.ClearAll();

        Resources.UnloadUnusedAssets();
        AssetBundle.UnloadAllAssetBundles(unloadAllObjects);
    }

    public static void LoadConfig(LuaFunction fun)
    {
        ClearAllRes(false);

        pakageVer = new Dictionary<string, int>();
        downloadVer = new Dictionary<string, int>();
        netVer = new Dictionary<string, int>();
        pkgChannelFile = new List<string>();
        netChannelFile = new List<string>();

        var data = LoadPackage("ver", "ver",true);
        //Debug.Log("1. ���ر��ذ汾�ļ�:"+(data == null));

        if (data != null) {
            LoadVer(pakageVer, (data as TextAsset).text);
        }

        var channelFile = LoadPackage("channelfile", "channelfile",true);
        //Debug.Log("1. ���ر���channelFile:" + (channelFile == null));
        if (channelFile != null)
            LoadChannelFile(pkgChannelFile,(channelFile as TextAsset).text);

        try
        {
            var bytes = File.ReadAllBytes(Application.persistentDataPath + "/ver");
            //Debug.Log("�������ذ汾�ļ���" + (bytes == null));
            var text = System.Text.Encoding.Default.GetString(bytes);
            LoadVer(downloadVer, text);
        }
        catch (System.Exception ex) 
        {
            Debug.Log(ex.ToString());
        }

        fun.Call();
    }

    public static void SaveVer(Dictionary<string, int> datas)
    {
        var lines = new List<string>();
        foreach (var data in datas)
        {
            lines.Add(data.Key + "," + data.Value);
        }
        File.WriteAllLines(Application.persistentDataPath + "/ver",lines);
    }


    static void LoadVer(Dictionary<string, int> vers, string data)
    {
        var lines = data.Split('\n');
        foreach (var line in lines) {
            var strs = line.Split(',');
            if (strs.Length == 2 && strs[0] != "version")
            {
                int.TryParse(strs[1], out  int version);
                vers.Add(strs[0],version);
            }            
        }
    }

    static void LoadChannelFile(List<string>list, string data)
    {
        var lines = data.Split('\n');
        list.AddRange(lines);
    }

    public static int GetVerCode()
    {
#if UNITY_ANDROID
        try
        {
            var cls = new AndroidJavaClass("com.xreal.agame.UnityPlayerActivity");
            var ver = cls.CallStatic<int>("GetVer");
            //Debug.Log("�ͻ��˰汾�ţ�" + ver);
            return ver;
        } catch(System.Exception) { }
#endif

        return 0;
    }

    public static void CheckUpdate(string addr,LuaFunction fun)
    {       
        var com = UIAPI.gNode.gameObject.AddComponent<HttpDownload>();

        Debug.Log(Application.persistentDataPath);

        var maxValue = Mathf.Max(getDownloadVer("ver"), getPackageVer("ver"));
        //Debug.Log("���汾�ţ�" + maxValue);
        com.StartDownload(addr + "?code=" + GetVerCode() + "&ver=" + maxValue+"&channel="+ChannelMgr.channel, (step, bytes) => {

            if (step == -1)
            {
                fun.Call(false);
            }
            else
            {
                var data = System.Text.Encoding.Default.GetString(bytes);

                var lines = data.Split('\n');
#if GK
                Games.Coresdk.Unity.ConfigLoader.loginAddr = lines[0];
                Games.Coresdk.Unity.ConfigLoader.payAddr = lines[1];
#endif
                hotFixAddr = lines[2];
                //Debug.Log("�ȸ���ַ��" + hotFixAddr);
                downloadAddr = lines[3];
                var isUpdate = lines[4];
                if(isUpdate == "forceUpdate")
                {
                    var param = new List<string>();
                    param.Add(isUpdate);
                    param.Add(downloadAddr);
                    fun.Call(param);
                    return;
                }
                for (var i=4; i<lines.Length; i++)
                {
                    var strs = lines[i].Split(',');
                    if (strs.Length == 2)
                    {
                        if (strs[1] == "channelFile")
                            netChannelFile.Add(strs[0]);
                        else
                            netVer.Add(strs[0], int.Parse(strs[1]));
                    }
                }

                var ret = new List<string>();

                foreach(var ver in netVer)
                {
                    var oldVer = Mathf.Max(getDownloadVer(ver.Key), getPackageVer(ver.Key));

                    if (oldVer < ver.Value)
                    {                       
                        ret.Add(ver.Key);
                    }
                }    
                fun.Call(ret);
            }
        });
    }    

    public static void DownloadFile(string res,LuaFunction fun)
    {
        if (res == "ver")
        {            
            fun.Call(100);
            return;
        }

        var com = UIAPI.gNode.gameObject.AddComponent<HttpDownload>();
        com.StartDownload( hotFixAddr +  res+"&channel="+ChannelMgr.channel, res, (step, bytes) => {
            fun.Call(step);
        });
    }

    public static void UpdateVersion(string res)
    {
        if (res != "ver" && !downloadVer.ContainsKey(res))
        {
            downloadVer.Add(res, netVer[res]);
        }       
    }

    public static void StopUpdate()
    {
        Debug.Log(Application.persistentDataPath);

        bool hasDownload = false;

        GameObject.Find("Canvas").transform.SendMessage("EnterGame");

        if (netVer != null && netVer.ContainsKey("ver"))
        {
            if (netVer["ver"] > getDownloadVer("ver")) 
            {
                if (downloadVer.ContainsKey("ver"))
                    downloadVer["ver"] = netVer["ver"];
                else
                    downloadVer.Add("ver", netVer["ver"]);
                hasDownload = true;
            }
        }

        var data = Load("filemap");
        if (data != null)
        {
            filemap = new Dictionary<string, string>();
            var lines = (data as TextAsset).text.Split('\n');
            foreach (var line in lines)
            {
                var strs = line.Split(',');
                if (strs.Length == 2)
                {
                    filemap.Add(strs[0],strs[1]);
                    //Debug.Log("��ʼ��FileMap:" + line);
                }
            }
        }

        if (hasDownload)
        {
            SaveVer(downloadVer);
            hasDownload = false;
        }
    }

}
