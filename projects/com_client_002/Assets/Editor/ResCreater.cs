using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEditor;
 
public class ResCreater 
{

    [MenuItem("Tools/CreateRes")] 
    static void CreateRes() {

        

        var files = new List<string>();

        foreach (var guid in Selection.assetGUIDs)
        {
            files.Add(AssetDatabase.GUIDToAssetPath(guid));
        }

        files.Sort( (a, b) => {
            var na = getNumber(a); 
            var nb = getNumber(b); 
            return na - nb;
        });

        var datas = new List<Sprite>();
        for (var i=0; i<files.Count; i++) {
            var assetPath = files[i];        
            var img = UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite> (assetPath);            
            datas.Add(img);
        }

        var obj = new GameObject();
        var res = obj.AddComponent<Images>();
        res.datas = datas.ToArray();
        
    }

    public static int getNumber(string value) {
        var found = false;
        var ret = 0;
        var pos = 1;
        var len = value.Length;
        while(len > 0) {
            var ch = value[len-1];

            if (ch >='0' && ch <='9') {
                found = true;
                ret += pos * (ch - '0');
                pos *= 10;
            } else {
                if (found) {
                    break;
                }
            }

            len--;
        }

        return ret;
    }

}