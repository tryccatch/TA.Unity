using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Tools 
{
    ///<summary>
    ///由秒数得到剩余日期几天几小时。。。
    ///</summary
    ///<param name="t">秒数</param>
    ///<param name="type">0：转换后带秒，1:转换后不带秒</param>
    ///<returns>几天几小时几分几秒</returns>
    public static string ParseTimeSeconds(double t, int type)
    {
        if(t <= 0)
        {
            return "0秒";
        }
        string r = "";
        double day, hour, minute, second;
        if (t >= 86400) //天,
        {
            day =Math.Floor(t / 86400);
            hour = Math.Floor((t % 86400) / 3600);
            minute = Math.Floor((t % 86400 % 3600) / 60);
            second = Math.Floor(t % 86400 % 3600 % 60);
            if (type == 0)
                r = day + ("天") + hour + ("小时") + minute + ("分") + second + ("秒");
            else
                r = day + ("天") + hour + ("小时") + minute + ("分");

        }
        else if (t >= 3600)//时,
        {
            hour = Math.Floor(t / 3600);
            minute = Math.Floor((t % 3600) / 60);
            second = Math.Floor(t % 3600 % 60);
            if (type == 0)
                r = hour + ("小时") + minute + ("分") + second + ("秒");
            else
                r = hour + ("小时") + minute;
        }
        else if (t >= 60)//分
        {
            minute = Math.Floor(t / 60);
            second = Math.Floor(t % 60);
            r = minute + ("分") + second + ("秒");
        }
        else
        {
            second = Math.Floor(t);
            r = second + ("秒");
        }
        return r;   
    }
}
