using System;
using System.Collections;
using UnityEngine;
using XLua;

public class SoundHelper : MonoBehaviour
{
    public void OnPlay(LuaFunction func,float length)
    {
        if(func !=null)
            StartCoroutine(DelayCallLuaFun(func,length));
    }

    private IEnumerator DelayCallLuaFun(LuaFunction func,float length)
    {
        yield return new WaitForSeconds(length);
        func.Call();
    }
}