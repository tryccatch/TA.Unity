using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using DragonBones;
 
public class AnimCreater 
{

    [MenuItem("Tools/CreateFrameAnim")] 
    static void CreateFrameAnim() {
          
        if (Selection.assetGUIDs.Length != 1) {
            UnityEditor.EditorUtility.DisplayDialog("提示", "请选择一个目录", "");
            return;
        }

        
        var path = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);

        var root = new DirectoryInfo(path);

        if (root.GetDirectories().Length <= 0) {
            CreateFrameAnim(root);
        } else {
            foreach (DirectoryInfo d in root.GetDirectories()) {            
                CreateFrameAnim(d);        
            }
        }        
    }

    static void CreateFrameAnim(DirectoryInfo root) {
        var files = new List<string>();
         foreach (FileInfo f in root.GetFiles()) {
            if (f.Extension == ".png") {
                files.Add(f.FullName);                
            } 
        }

        var name = root.FullName;
        var startPos = name.LastIndexOf("\\");
        if (startPos < 0) {
            startPos = name.LastIndexOf("/");
        }
        startPos++;   
        var resName = name.Substring(startPos);

        files.Sort( (a, b) => {
            var na = getOrderKey(a); 
            var nb = getOrderKey(b); 
            return System.String.Compare(na,nb);   
        });


        List<Sprite> datas = new List<Sprite>();  
        List<string> keys = new List<string>();  

        for (var i=0; i<files.Count; i++) {
            var key = getKey(files[i]);
            keys.Add(key);
            
            var assetPath = files[i];   
            var dirPos = assetPath.IndexOf("Assets");   
            assetPath = assetPath.Substring(dirPos);     
            var img = UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite> (assetPath);      
            datas.Add(img);
        }

        createAnim(resName,datas,keys);  
    }

    static void createAnim(string name,List<Sprite> datas,List<string> keys) {
        GameObject obj = new GameObject();   
        var res = obj.AddComponent<Images>(); 
        res.datas = datas.ToArray();

        var framePlayer = obj.AddComponent<FramePlayer>(); 
        framePlayer.UpdateFrame();
        framePlayer.SetAnimKeys(keys);

        string localPath = "Assets/Resource/FrameAnim/" + name + ".prefab";            
        PrefabUtility.SaveAsPrefabAsset(obj,localPath);                
        GameObject.DestroyImmediate(obj);  
    }

    public static string getKey(string value) {
        var found = false;
        var len = value.Length;
        while(len > 0) {
            var ch = value[len-1];

            if (ch >='0' && ch <='9') {
                found = true;                
            } else {
                if (found) {
                    break;
                }
            }

            len--;
        }

        var posEnd = len;        
        while(len > 0) { 
            var ch = value[len];
            if (ch == '_') {
                len++;
                break;
            }
            len--;
        }

        return value.Substring(len,posEnd-len);
    }

    public static string getOrderKey(string value) {
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

        var posEnd = len;        
        while(len > 0) { 
            var ch = value[len];
            if (ch == '_') {
                len++;
                break;
            }
            len--;
        }

        if (ret > 9) {
            return value.Substring(len,posEnd-len) + "" + ret; 
        } else {
            return value.Substring(len,posEnd-len) + "0" + ret; 
        }
    }

    [MenuItem("Tools/CreateDragonAnim")] 
    static void CreateDragonAnim() {

        
        if (Selection.assetGUIDs.Length != 1) {
            UnityEditor.EditorUtility.DisplayDialog("提示", "请选择一个目录", "");
            return;
        }

        var path = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);

        var root = new DirectoryInfo(path);

        UnityEngine.Debug.Log(path);
        
        
        var files = getFiles(root);

        foreach (var file in files) {

            var dirPos = file.IndexOf("Assets");   
            var name = file.Substring(dirPos);


            var startPos = name.LastIndexOf("\\");
            if (startPos < 0) {
                startPos = name.LastIndexOf("/");
            }
            startPos++;

            var posEnd = name.LastIndexOf(".");
            var resName = name.Substring(startPos,posEnd-startPos-5);
            resName = resName.Replace("\\","_");
            resName = resName.Replace("/","_");       

            var com = _CreateEmptyObject();
            
            UnityEngine.Debug.Log(resName);
            var data = AssetDatabase.LoadAssetAtPath<Object>(name);

            com.unityData = (UnityDragonBonesData)data; 

            DragonBones.UnityEditor.ChangeDragonBonesData(com, com.unityData.dragonBonesJSON);

            //UnityEngine.Debug.Log(data);
            //UnityEngine.Debug.Log(com.unityData);
            
            string localPath = "Assets/Resource/Anim/" + resName + ".prefab";

            //PrefabUtility.SaveAsPrefabAsset(com.gameObject,Application.dataPath + "/Resource/Anim");
            PrefabUtility.SaveAsPrefabAsset(com.gameObject,localPath);
            
            GameObject.DestroyImmediate(com.gameObject);
        }
    }

    private static UnityArmatureComponent _CreateEmptyObject()
    {              

        var canvas = GameObject.Find("/Canvas");

        var gameObject = new GameObject("new anim", typeof(UnityArmatureComponent));

        var armatureComponent = gameObject.GetComponent<UnityArmatureComponent>();
        gameObject.transform.SetParent(canvas.transform, false);


        armatureComponent.isUGUI = true;
        if (armatureComponent.GetComponentInParent<Canvas>() == null)
        {
            if (canvas)
            {
                armatureComponent.transform.SetParent(canvas.transform);
            }
        }

        armatureComponent.transform.localScale = Vector2.one * 100.0f;
        armatureComponent.transform.localPosition = Vector3.zero;

        return armatureComponent;
    }

    static List<string> getFiles(DirectoryInfo root) {

        var ret = new List<string>();

        getFiles(root,ret);       

        return ret;
    }

    static void getFiles(DirectoryInfo root,List<string> ret) {
        

        foreach (FileInfo f in root.GetFiles()) {
            if (f.Extension == ".asset") {
                ret.Add(f.FullName);                
            } 
        }

        foreach (DirectoryInfo d in root.GetDirectories()) {            
            getFiles(d,ret);
        }
    }
}