#if GK
using EcchiGamer.Sdk.Unity;
#endif
#if H365
using H365.Sdk.Unity;
using H365.Sdk.Unity.Payment;
#endif
using System.Collections;
using UnityEngine;
using XLua;

public class SDKMgr : MonoBehaviour
{
    static string gameId;
    public static void Init(string gameId, LuaFunction fun)
    {
        SDKMgr.gameId = gameId;
#if GK
        var ret = UIAPI.gNode.GetComponent<SDKMgr>();
        if (ret == null)
            ret = UIAPI.gNode.gameObject.AddComponent<SDKMgr>();
        ret.StartCoroutine(ret.InitGK(fun));
#elif H365
        var result = H365SDK.AuthClient;
        fun.Call();
#elif JGG
        var ret = UIAPI.gNode.GetComponent<SDKMgr>();
        if (ret == null)
            ret = UIAPI.gNode.gameObject.AddComponent<SDKMgr>();
#if UNITY_EDITOR
        ret.StartCoroutine(ret.InitGK(fun));
#else
        fun.Call();
#endif
#endif

    }

    IEnumerator InitGK(LuaFunction fun)
    {
#if GK
        yield return StartCoroutine(EcchiGamerSDK.Initialize());
#endif
        yield return null;
        fun.Call();
    }



    static void CallJggMethod(string methodName, params object[] arvgs)
    {
        using (var javaClass = new AndroidJavaClass("com.xreal.agame.UnityPlayerActivity"))
        {
            javaClass.CallStatic(methodName, arvgs);
        }
    }

    static LuaFunction LoginCallback;
    void JggLoginCallBack(string parm)
    {
        Debug.Log("JGGTips LoginCall" + parm);
        JGGSDKManager.Session session = JGGSDKManager.GetSession(parm);
        if (session.Title != null)
        {
            LoginCallback.Call("JGG", session, session.accessToken, true);
        }
        else
        {
            LoginCallback.Call("exception", JGGSDKManager.GetJGGError(parm), "", true);
        }
    }

    public static void Login(LuaFunction loginCallback)
    {
#if GK
        EcchiGamerSDK.OpenLogin(gameId, result =>
        {
            var exception = result.Exception;

            if (exception == null)
            {
                var isGuest = string.IsNullOrEmpty(result.Data.user_info.account);
                loginCallback.Call("ok", result.Data.user_info, EcchiGamerSDK.Token, isGuest);
            }
            else
            {
                loginCallback.Call("exception", exception.ToString(), "", true);
            }
        });
#elif H365
        H365SDK.AuthClient.Login(result =>
       {
           var exception = result.Exception;
           if (exception == null)
               H365SDK.AuthClient.Validate(result2 =>
               {
                   var exception2 = result2.Exception;
                   if (exception2 == null)
                       loginCallback.Call("ok", result2.UserId, result.Token, false);
                   else
                       loginCallback.Call("exception", exception2.ToString(), "", true);
               });
           else
               loginCallback.Call("exception", exception.ToString(), "", true);
       });
#elif JGG
#if UNITY_EDITOR
        EcchiGamerSDK.OpenLogin(gameId, result =>
        {
            var exception = result.Exception;

            if (exception == null)
            {
                var isGuest = string.IsNullOrEmpty(result.Data.user_info.account);
                loginCallback.Call("ok", result.Data.user_info, EcchiGamerSDK.Token, isGuest);
            }
            else
            {
                loginCallback.Call("exception", exception.ToString(), "", true);
            }
        });
#else
        LoginCallback = loginCallback;
        CallJggMethod("JggLogin");
#endif
#endif
    }

    public static void Register(LuaFunction registerCallback)
    {
#if GK

#elif H365
        Login(registerCallback);
#endif

    }



    static LuaFunction LogoutCallback;
    void JggLogoutCallBack()
    {
        LogoutCallback.Call("ok");
    }

    public static void LogOut(LuaFunction logOutCallback)
    {
#if GK
        EcchiGamerSDK.OpenLogout(result =>
        {
            logOutCallback.Call("ok");
        });
#elif H365
        H365SDK.AuthClient.Logout(result =>
        {
            var exception = result.Exception;
            if (exception == null)
                logOutCallback.Call("ok");
            else
                logOutCallback.Call("exception", exception.ToString(), "", true);
        });
#elif JGG
#if UNITY_EDITOR
        EcchiGamerSDK.OpenLogout(result =>
        {
            logOutCallback.Call("ok");
        });
#else
        LogoutCallback = logOutCallback;
        CallJggMethod("JggLogout");
#endif
#endif
    }

    public static void OpenPayment()
    {
#if GK
        EcchiGamerSDK.OpenPayment();
#elif H365

#endif
    }


    static public void GuestBindAccount(string account, LuaFunction fun)
    {
#if GK
        EcchiGamerSDK.OpenAccountBindGame(gameId, account, result =>
        {
            if (result.IsSuccess)
            {
                if (result.Exception == null)
                {
                    fun.Call(true, result.Data.user_info, EcchiGamerSDK.Token);
                    return;
                }
            }
            fun.Call(false, "", "");
        });
#endif
    }

    static public void BindAccount(string account, LuaFunction fun)
    {
#if GK
        EcchiGamerSDK.PostAccountBindGame(gameId, account, result =>
        {
            if (result.IsSuccess)
            {
                fun.Call(true);
            }
            else
            {
                fun.Call(false);
            }
        });
#endif
    }



    static LuaFunction PayCallback;
    void JggPayCallBack(string parm)
    {
        Debug.Log("JGGTips PayCall" + parm);
        var result = JGGSDKManager.GetPurchaseResult(parm);
        if (result.Title != null)
        {
            PayCallback.Call("ok", result);
        }
        else
        {
            PayCallback.Call("exception", JGGSDKManager.GetJGGError(parm));
        }
    }

    static public void Pay(string itemName, string desc, string url, long userId, string callbackUrl
        , string type, int count, double money, string time, LuaFunction callback)
    {
#if H365
        PaymentItem item = new PaymentItem(string.Format("{0}_{1}", type, count), itemName, money, 1, url, desc);
        PaymentData data = new PaymentData(string.Format("{0}_{1}", userId, time), callbackUrl, "charge", item);
        H365SDK.PaymentClient.Purchase(data, result =>
        {
            Debug.Log("payment result:" + result.Data.Message);
            if (result.Exception == null)
                callback.Call("ok");
            else
                callback.Call("exception", result.Exception.ToString());
        });
#elif JGG
        CallJggMethod("JggPay", string.Format("{0}_{1}_{2}_{3}", userId, type, count, time), itemName, money * 100, 1, "http://18.162.47.123/web/img/jgg.png", desc, callbackUrl);
        PayCallback = callback;
#endif
    }

    public static void PostAccountBindGame(string gameId, string account, LuaFunction callback)
    {
#if GK
        EcchiGamerSDK.PostAccountBindGame(gameId, account, result =>
        {
            if (!result.IsSuccess)
            {
                callback.Call("exception", result.Result);
            }
            else
            {
                callback.Call("ok");
            }
        });

#endif
    }

    public static void H365LoginEvent()
    {
#if H365
        H365SDK.DataAnalystManager.Login();
#endif
    }

    public static void H365RegistrationEvent()
    {
#if H365
        H365SDK.DataAnalystManager.Registration();
#endif
    }
}