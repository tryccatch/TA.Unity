using UnityEngine;
using XLua;
using System;
using System.IO;
#if GK
using EcchiGamer.Sdk.Unity;
#endif
using System.Collections;

public class GameAPI : MonoBehaviour
{

    static string gameId;

    public static void Init(string value, LuaFunction fun)
    {
        gameId = value;

        var ret = UIAPI.gNode.GetComponent<GameAPI>();
        if (ret == null)
        {
            ret = UIAPI.gNode.gameObject.AddComponent<GameAPI>();
        }
        ret.StartCoroutine(ret.InitFun(fun));
    }

    IEnumerator InitFun(LuaFunction fun)
    {
#if GK
        yield return StartCoroutine(EcchiGamerSDK.Initialize());
#endif
        
        yield return null;

        fun.Call();
    }

    static public void Login(LuaFunction fun)
    {
#if GK
        EcchiGamerSDK.OpenLogin(gameId, result => {
            var exception = result.Exception;

            if (exception == null)
            {
                var isGuest = string.IsNullOrEmpty(result.Data.user_info.account);
                fun.Call("ok", result.Data.user_info.user_id, EcchiGamerSDK.Token, isGuest);
            }
            else
            {
                fun.Call("exception", exception.ToString(), "", true);
            }
        });
#endif
    }


    static public void Logout()
    {
#if GK
        EcchiGamerSDK.OpenLogout( result => {
            return;
        });
#endif
    }


    static public void BindAccount(string account, LuaFunction fun)
    {
#if GK
        EcchiGamerSDK.PostAccountBindGame(gameId,account,result => {
            if (result.IsSuccess)
            {                
                fun.Call(true);
            } else
            {
                fun.Call(false);
            }
        });
#endif
    }

    static public void GuestBindAccount(string account, LuaFunction fun)
    {
#if GK
        EcchiGamerSDK.OpenAccountBindGame(gameId, account, result => {
            if (result.IsSuccess)
            {
                if (result.Exception == null)
                {
                    fun.Call(true, result.Data.user_info.user_id, EcchiGamerSDK.Token);
                    return;
                }                
            }
            fun.Call(false,"","");
        });
#endif
    }

    static public void OpenPayment()
    {
#if GK
        EcchiGamerSDK.OpenPayment();
#endif
    }
}
