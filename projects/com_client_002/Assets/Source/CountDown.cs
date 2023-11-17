using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

public class CountDown : MonoBehaviour
{
    public Text text;
    public double second = 0;
    public LuaFunction fun;
    private bool run = true;
    int startTime = 0;
    int gameTime = 0;
    int type;
    bool visual;
    private void Start()
    {
        text = transform.GetComponent<Text>();
        OnApplicationPause(true);
        OnApplicationPause(false);
    }
    private void Update()
    {
        if (gameTime > 0)
        {
            second -= gameTime;
            gameTime = 0;
        }
        if (second > 0)
        {
            second -= Time.deltaTime;
            if (second < 0)
                second = 0;
            if (text)
            {
                text.text = TimeFormat(second, type);
            }
        }
        else
        {
            second = 0;
            if (run && fun != null)
            {
                text.enabled = visual;
                run = false;
                fun.Call();
            }
        }
    }
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
    public static void SetCountDownTimer(Transform node, double countDown, int type, bool visual, bool server, LuaFunction fun)
    {
        Debug.Log(countDown);
        if (!node)
        {
            Debug.LogError("can not find Transfrom" + node.name);
            return;
        }
        if (countDown <= 0)
        {
            countDown = 0;
        }
        var com = node.GetComponent<CountDown>();
        if (com == null)
        {
            node.gameObject.AddComponent<CountDown>();
            com = node.GetComponent<CountDown>();
        }
        com.second = countDown;
        if (server)
            com.second = countDown + 1;
        com.type = type;
        com.fun = fun;
        com.run = true;
        com.visual = visual;
        node.GetComponent<Text>().enabled = visual;
    }

    string d = "天";
    string h = "小时";
    string m = "分";
    string s = "秒";
    string TimeFormat(double time, int type)
    {
        string str = "";
        if (time < 0)
        {
            switch (type)
            {
                case 0:
                    return "0分";
                case 1:
                    return "0秒";
                case 2:
                    return "00:00";
                case 3:
                    return "00:00:00";
                default:
                    break;
            }
        }
        else
        {
            TimeSpan ts = new TimeSpan(0, 0, 0, (int)time);

            int days = ts.Days;
            int houes = ts.Hours;
            int minutes = ts.Minutes;
            int seconds = ts.Seconds;

            switch (type)
            {
                case 0:
                    str = (days > 0 ? days + d : "") +
                        (houes > 0 ? houes + h : "") +
                        (minutes > 0 ? minutes + m : "");
                    break;
                case 1:
                    str = (days > 0 ? days + d : "") +
                        (houes > 0 ? houes + h : "") +
                        (minutes > 0 ? minutes + m : "") +
                        (seconds >= 0 ? seconds + s : "");
                    break;
                case 2:
                    str = (minutes > 9 ? minutes.ToString() : "0" + minutes.ToString()) + ":" +
                        (seconds > 9 ? seconds.ToString() : "0" + seconds.ToString());
                    break;
                case 3:
                    houes = days > 0 ? days * 24 + houes : houes;
                    str = (houes > 9 ? houes.ToString() : "0" + houes.ToString()) + ":" +
                        (minutes > 9 ? minutes.ToString() : "0" + minutes.ToString()) + ":" +
                        (seconds > 9 ? seconds.ToString() : "0" + seconds.ToString());
                    break;
                default:
                    break;
            }
        }
        return str;
    }
}