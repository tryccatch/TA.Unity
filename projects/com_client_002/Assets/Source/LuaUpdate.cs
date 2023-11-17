using UnityEngine;
using XLua;
using System;
using System.IO;

public class LuaUpdate : MonoBehaviour {

    public LuaFunction fun;

    void Update() {
        fun.Call(Time.deltaTime);
    }
}
