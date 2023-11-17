using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;

public class OnEndDrag : MonoBehaviour, IEndDragHandler
{
    public void SetDrag(LuaFunction fun)
    {
        this.fun = fun;
    }

    public LuaFunction fun;

    void IEndDragHandler.OnEndDrag(PointerEventData eventData)
    {
        if (fun != null)
            fun.Call();
    }
}
