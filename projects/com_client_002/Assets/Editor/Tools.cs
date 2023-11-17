using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEditor;

public class Tools 
{
    [MenuItem("Tools/Copy Node Path %#o")]
    public static void OutputNodePath()
    {
        Transform trans = Selection.activeTransform;
        
        var path = "";
        while(trans != null) {
            if (path != "") {
                path = "/" + path;
            }
            path = trans.name + path;
            trans = trans.parent;

            // for this project
            if (trans != null && trans.parent != null && trans.parent.parent == null) {
                if (trans.parent.name == "Canvas" && trans.name == "Center") {
                    break;
                }
            }

            if (trans != null && trans.parent == null) {
                if (trans.name == "Canvas") {
                    break;
                }
            }
        }

        UnityEngine.Debug.Log(path);

        GUIUtility.systemCopyBuffer = path;
    }

    [MenuItem("Tools/Clear All Save")]
    public static void ClearAllSave()
    {
        UnityEngine.PlayerPrefs.DeleteAll();
    }
}
