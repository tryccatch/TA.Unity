using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class LoadFromFileExample : MonoBehaviour
{
    void Start()
    {
        var myLoadedAssetBundle
            = AssetBundle.LoadFromFile(Path.Combine(Application.streamingAssetsPath, "myassetBundle"));
        if (myLoadedAssetBundle == null)
        {
            Debug.Log("Failed to load AssetBundle!");
            return;
        }
        var prefab = myLoadedAssetBundle.LoadAsset<GameObject>("Assets/AssetBundleExample/Prefabs/Cube.prefab");
        Instantiate(prefab);
    }
}