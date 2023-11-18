using System.Collections;
using UnityEngine;
using System;

using XLua;


public enum GameServerEnum
{
    LocalHost = 1,          //����
    LocalTest = 3,          //�������Է�
    OuterNetTest = 2,       //�������Է�
    OuterNetOnline = 4,     //������ʽ��
    JGGNetTest = 5,         //JGG���Է�
    JGGNetOnline = 6        //JGG��ʽ��
}



public class LuaRunner : MonoBehaviour
{
    LuaEnv luaEnv;
    LuaFunction mainUpdateFun;
    LuaFunction reportLuaException;

    public string ip = "";
    public bool debug = true;
    public GameServerEnum serverEnum = GameServerEnum.LocalHost;
    public static string channel;

    // Start is called before the first frame update
    void Start()
    {
#if !UNITY_EDITOR
#if LocalHost
            serverEnum = GameServerEnum.LocalHost;
#elif LocalTest
            serverEnum = GameServerEnum.LocalTest;
#elif OuterNetTest
            serverEnum = GameServerEnum.OuterNetTest;
#elif OuterNetOnline
            serverEnum = GameServerEnum.OuterNetOnline;
#elif JGGNetTest
            serverEnum = GameServerEnum.JGGNetTest;
#elif JGGNetOnline
            serverEnum = GameServerEnum.JGGNetOnline;
#endif
#endif
        ChannelMgr.init();
        Servers();
        StartCoroutine(AutoGC());
    }

    public void Servers()
    {
        luaEnv = new LuaEnv();
        luaEnv.AddLoader(this.Loader);
        luaEnv.DoString(@"require 'servers'");
    }

    public void CheckVersionToTest(string addr)
    {
        Debug.Log("check servers");
        var com = gameObject.AddComponent<HttpDownload>();
        com.StartDownload(addr + "?code=" + ResTools.GetVerCode() + "&ver=" + 0 + "&channel=" + ChannelMgr.channel + "&version=" + Application.version, (step, bytes) =>
       {
           var code = System.Text.Encoding.Default.GetString(bytes);
           if (code == "test")
           {
               serverEnum = GameServerEnum.LocalTest;
           }
           Reset();
       });
    }


    private WaitForSeconds waitTime = new WaitForSeconds(5);
    IEnumerator AutoGC()
    {
        while (true)
        {
            yield return waitTime;
            Resources.UnloadUnusedAssets();
        }
    }

    public void Reset()
    {
        luaEnv = new LuaEnv();
        luaEnv.AddLoader(this.Loader);
        luaEnv.DoString(@"require 'update'");
        mainUpdateFun = luaEnv.Global.Get<LuaFunction>("main_update");
    }

    private byte[] Loader(ref string fileName)
    {
        return ResTools.ReadLuaBytes(ref fileName);
    }

    void EnterGame()
    {
        luaEnv = new LuaEnv();
        luaEnv.AddBuildin("pb", XLua.LuaDLL.Lua.LoadLuaProfobuf);
        luaEnv.AddLoader(this.Loader);
        luaEnv.DoString(@"require 'main'");
        mainUpdateFun = luaEnv.Global.Get<LuaFunction>("main_update");
        reportLuaException = luaEnv.Global.Get<LuaFunction>("reportLuaException");
    }

    // Update is called once per frame
    void Update()
    {
        if (mainUpdateFun != null)
        {
#if UNITY_EDITOR
            try
            {
                mainUpdateFun.Call(ip.Trim());
            }
            catch (Exception ex)
            {
                if (reportLuaException != null)
                    reportLuaException.Call(ex.ToString());
                Debug.Log(ex);
                mainUpdateFun = null;
            }
#else
            try
            {
                mainUpdateFun.Call();
            }
            catch (Exception ex)
            {
                if (reportLuaException != null)
                    reportLuaException.Call(ex.ToString());
                Debug.Log(ex);
                mainUpdateFun = null;
            }
#endif
        }
    }
}
