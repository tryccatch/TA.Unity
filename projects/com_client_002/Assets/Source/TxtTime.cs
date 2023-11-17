using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

public class TxtTime : MonoBehaviour
{
    public Text txt = null;
    public double times = 0;
    public LuaFunction fun;
    private bool isFun = true;
    public string prefix;
    public string ending;
    public void Start()
    {
        txt = transform.GetComponent<Text>();
        OnApplicationPause(true);
        OnApplicationPause(false);
    }
    public static void SetShowTxtTime(Transform node, double times, LuaFunction fun,string prefix= "",string ending= "")
    {
        if (!node)
        {
            Debug.LogError("can not find Transform" + node.name);
            return;
        }
        if (times <= 0)
        {
            times = 0;
        }
        var com = node.GetComponent<TxtTime>() ? node.GetComponent<TxtTime>() : node.gameObject.AddComponent<TxtTime>();
        com.times = times;
        com.fun = null;
        com.fun = fun;
        com.prefix = prefix;
        com.ending = ending;
    }
    public void Update()
    {
        if (gameTime > 0)
        {
            times -= gameTime;
            gameTime = 0;
        }
        if (times > 0)
        {
            times -= Time.deltaTime;
            times = times < 0 ? times = 0 : times;
            txt.text = prefix + Tools.ParseTimeSeconds(times, 0)+ ending;
        }
        else
        {
            times = 0;
            if (isFun && fun != null)
            {
                isFun = false;
                fun.Call();
            }
        }
    }


    int startTime = 0;
    int gameTime = 0;

    private void OnApplicationPause(bool pause)
    {
        if (pause)
        {
            startTime = (int)Time.realtimeSinceStartup;
            Debug.Log("计时暂停:" + startTime);
        }
        else
        {
            gameTime = (int)Time.realtimeSinceStartup - startTime;
            Debug.Log("时间间隔:" + gameTime);
        }
    }

}
