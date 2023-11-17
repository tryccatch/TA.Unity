using System.Collections.Generic;
using UnityEngine;
using XLua;

public class API {

    public static bool IsDebug() {
#if UNITY_EDITOR
        var com = GameObject.Find("Canvas").GetComponent<LuaRunner>();
        return com.debug;
#else
        return false;
#endif
    }

    public static bool IsEditor()
    {
#if UNITY_EDITOR        
        return true;
#else
        return false;
#endif
    }

    public static int ServerEnum()
    {
        var com = GameObject.Find("Canvas").GetComponent<LuaRunner>();
        return (int)com.serverEnum;
    }

    public static bool Check(Object obj) {               
        return obj != null;
    }

    public static double Distance2D(Vector3 pos1,Vector3 pos2) {
        var d = pos1 - pos2;        
        return Mathf.Sqrt(d.x*d.x+d.y*d.y);
    }

    public static void MoveTo2D(Transform node1,Transform node2,float speed) {
        var d = node2.transform.localPosition - node1.transform.localPosition;        
        var dis = Mathf.Sqrt(d.x*d.x+d.y*d.y);

        if (dis > 0) {
            var moveDis = speed * Time.deltaTime;
            if (moveDis > dis) {
                moveDis = dis;    
            }

            node1.transform.localPosition += new Vector3(d.x*moveDis/dis,d.y*moveDis/dis,0);
        }
    }

    public static void ResetApp()
    {
        TcpNet.Close();
        ResTools.ClearAllRes(true);
        var com = GameObject.Find("Canvas").GetComponent<LuaRunner>();
        com.Reset();
    }

}
