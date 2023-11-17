using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class LuaDelayUpdate : MonoBehaviour
{

    class UpdateData {  
        public long id;

        public float time;
        float stepTime;

        public LuaFunction fun;

        public void Update(float dt) {
            stepTime += dt;
            if (IsEnd() && fun!=null) {
                 fun.Call(); 
            }           
        }

        public bool IsEnd() {
            return stepTime >= time;
        }
    }

    List<UpdateData> datas = new List<UpdateData>();
    List<UpdateData> addDatas = new List<UpdateData>();

    List<long> removeIds = new List<long>();

    long maxId;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
         if (!gameObject.activeSelf) {
             Debug.Log("test!!!!");

            datas.Clear();
            addDatas.Clear();

            return;
        }

       
        // 插入新数据
        datas.AddRange(addDatas);
        addDatas.Clear();

         // 移除的id   
        foreach (var id in removeIds) {
            datas.RemoveAll( a => a.id == id);
        }
        removeIds.Clear();
        
        foreach(var data in datas) {
            data.Update(Time.deltaTime);           
        }

        datas.RemoveAll( a => a.IsEnd() );

       
    }
    

    public long AddDelay(float time,LuaFunction fun) {
        maxId++;

        var newData = new UpdateData();    
        newData.id = maxId;
        newData.time = time;
        newData.fun = fun; 
        addDatas.Add(newData);

        return maxId;
    }

    public void RemoveDelay(long id) {
        removeIds.Add(id);    
    }    

}
