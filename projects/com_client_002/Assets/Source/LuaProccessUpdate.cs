using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class LuaProccessUpdate : MonoBehaviour
{

    class UpdateData {
        
        public double max;
        public float time;
        float stepTime;

        public LuaFunction fun;

        public void Stop() {
            if (max >= 0) {
                fun.Call(max); 
            } else {
                fun.Call(0); 
            } 
        }

        public void Update(float dt) {
            stepTime += dt;

            if (max > 0.0001 ) {
                var step = max * stepTime / time;
                if (step > max) { 
                    step = max;
                }
                fun.Call(step); 
            } else {
                if (IsEnd()) {
                    fun.Call(0); 
                }
            }            
        }

        public bool IsEnd() {
            return stepTime >= time;
        }
    }

    List<UpdateData> datas = new List<UpdateData>();

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        foreach(var data in datas) {
            data.Update(Time.deltaTime);
        }

        datas.RemoveAll( a => a.IsEnd() );
    }
    

    public void AddUpdate(double max,float time,LuaFunction fun,bool stopOther) {
        if (stopOther) {
            foreach(var data in datas) {
                data.Stop();
            }

            datas.Clear();
        }     

        var newData = new UpdateData();

        newData.max = max;
        newData.time = time;
        newData.fun = fun; 
        datas.Add(newData);
    }

    public void clearAll()
    {
        foreach (var data in datas)
        {
            data.Stop();
        }
        datas.Clear();
    }
}
