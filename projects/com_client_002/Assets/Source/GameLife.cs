using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class GameLife : MonoBehaviour
{
    LuaFunction exitCallback;
    LuaFunction pauseCallback;

 
    private void OnApplicationPause(bool pause)
    {
        if (pauseCallback != null)
            pauseCallback.Call(pause);
#if UNITY_IPHONE
        OnApplicationQuit();
#endif
    }

    private void OnApplicationQuit()
    {
        if (exitCallback != null)
            exitCallback.Call();
    }

    public void setExitCallback(LuaFunction exitCallback)
    {
        this.exitCallback = exitCallback;
    }

    public void setPauseCallback(LuaFunction pauseCallback)
    {
        this.pauseCallback = pauseCallback;
    }

    public static void setPauseCallback(LuaFunction pauseCallback,Transform node)
    {
        if (node == null)
            return;
        var temp = node.GetComponent<GameLife>();
        if (temp == null)
            temp = node.gameObject.AddComponent<GameLife>();
        temp.setPauseCallback(pauseCallback);
    }

    //private void Update()
    //{
    //    if(Input.GetKey(KeyCode.Escape) ||Input.GetKey(KeyCode.Home) || Input.GetKey(KeyCode.Menu))
    //    {
    //        if(exitCallback != null)
    //        {
    //            exitCallback.Call();
    //        }
    //        else
    //        {
    //            Application.Quit();
    //        }
    //    }
    //}
}
