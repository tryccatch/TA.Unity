using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;

public class OnPointEnter : MonoBehaviour, IPointerEnterHandler,IPointerExitHandler
{
    public float scale = 1;
    public LuaFunction pressfun;
    public void SetEnter(LuaFunction fun)
    {
        this.pressfun = fun;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (pressfun != null)
        {
            pressfun.Call();
        }
        else
            gameObject.transform.localScale = new Vector3(scale, scale, scale);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        gameObject.transform.localScale = new Vector3(1, 1, 1);
    }
}
