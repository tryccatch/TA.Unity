using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using UnityEngine.EventSystems;

public class OnPointDown : MonoBehaviour, IPointerDownHandler
{
    public void SetDown(LuaFunction fun)
    {
        this.fun = fun;
    }

    public LuaFunction fun;

    public void OnPointerDown(PointerEventData eventData)
    {
        if (fun != null)
        {
            fun.Call();
        }
    }
}
