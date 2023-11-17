using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class LuaFunc : MonoBehaviour
{
    public LuaFunction fun;

    const long Base = 10000L;

    // Start is called before the first frame update
    public void DoFun(float value)
	{
		if (fun == null) return;

        
        long longValue = (long)(value * Base);
        if ((longValue%Base) == 0) {
            longValue = longValue/Base;
            int intValue = (int)value;
            if (intValue == longValue) {
                fun.Call(intValue);
                return;
            }
        }

		
        fun.Call(value);
	}

	public void DoFun(bool b)
    {
        if (b)
        {
            fun.Call();
        }
    }

    public void DoFunBool(bool b)
    {
        fun.Call(b);
    }

    public void DoFun(Vector2 b)
    {
        fun.Call(b);
    }
}
