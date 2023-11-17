using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;

public class LuaOnClick : MonoBehaviour
{
    public LuaFunction fun;

    // Start is called before the first frame update
    public void OnPointerClick(PointerEventData eventData)
	{
		if (fun == null) return;
		fun.Call();
	} 
}
