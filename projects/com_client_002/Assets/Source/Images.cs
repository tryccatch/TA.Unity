using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Images : MonoBehaviour
{
    public Sprite[] datas;
    Dictionary<int, int> realIndexs;

    static Dictionary<string, Images> resDatas = new Dictionary<string, Images>();
    

    public static void Load(string path, string name)
    {        
        if (resDatas.ContainsKey(name)) return;

        var prefab = ResTools.Load(path);

        if (prefab == null) {
            UnityEngine.Debug.Log("can't found " + path);
            return;
        }

        var obj = GameObject.Instantiate(prefab) as GameObject;

        resDatas[name] = obj.GetComponent<Images>();
    }

    public static void Free(string path, string name)
    {
    }

    public static bool SetSprite(Transform node, string resName, int index)
    {     
        if (!resDatas.ContainsKey(resName))
        {
            Debug.Log("can't find name res:" + resName);
            return false;
        }

        var data = resDatas[resName];
        if (data == null) {
            Debug.Log("can't find data res:" + resName);
            return false;
        }
        
        var realIndex = data.getRealIndex(index);
        if (realIndex < 0) {
            //Debug.Log("can't find inde:"+index + " in " + resName);
            return false;
        } else {
            index = realIndex;
        }

        var sprite = data.datas[index];
        
        var image = node.GetComponent<Image>();
        image.sprite = sprite;

        return true;
    }

    public static bool SetSpriteKey(Transform node, string resName, string index)
    {
        if (!resDatas.ContainsKey(resName))
        {
            return false;
        }

        foreach (var sprite in resDatas[resName].datas) {
            //Debug.Log(sprite.name);

            if (sprite.name == index) {
                var image = node.GetComponent<Image>();
                image.sprite = sprite;
                return true;
            }
        }

        return false;
    }


    public static Sprite GetSprite(string resName, int index)
    {
        if (!resDatas.ContainsKey(resName))
        {
            return null;
        } 

        var data = resDatas[resName];
        index = data.getRealIndex(index);
        if (index < 0) return null;

        var sprite = data.datas[index];
        
        return sprite;
    }

    int getRealIndex(int index) {
        if (realIndexs == null) {
            realIndexs = new Dictionary<int, int>();

            for (var i=0; i<datas.Length; i++) {

                if (datas[i] == null)
                {
                    Debug.Log(this.gameObject.name + " index " + i + " is null!");
                    continue;
                }

                var m = getNumber(datas[i].name);
                //Debug.Log(datas[i].name + "=>" + m);
                if (m >= 0) {
                    realIndexs.Add(m,i);
                }                
            }
        }

        if (realIndexs.ContainsKey(index)) {
            return realIndexs[index];
        }

        return -1;
    }

    public static int getNumber(string value) {

        if (value == null || value.Length <= 0) return -1;

        var found = false;
        var endPos = value.Length-1;
        while(endPos >= 0) {
            var ch = value[endPos];
            if (ch >='0' && ch <='9') {
                found = true;
                break;
            } 
            endPos--;
        }

        if (!found) return -1;

        var startPos = endPos;        
        while(startPos >= 0) { 
            var ch = value[startPos];
            if (ch >='0' && ch <='9') {
                startPos--;  
            } else {
                startPos++;
                break;
            }
        }

        if (startPos < 0) startPos = 0;

        while(value[startPos] == '0' && startPos < endPos) { 
            startPos++;
        }       

        //Debug.Log(startPos);
        //Debug.Log(endPos);
        var ret = value.Substring(startPos,endPos-startPos+1);
        return int.Parse(ret);
    }

    public static void ClearAll()
    {
        foreach(var data in resDatas)
        {
            GameObject.Destroy(data.Value.gameObject);
        }
        resDatas.Clear();
    }
}
