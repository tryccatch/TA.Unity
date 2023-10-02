using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "SceneAudioData_SO", menuName = "Audio/SceneAudioData_SO")]
public class SceneAudioData_SO : ScriptableObject
{
    public List<SceneAudios> sceneAudios;

    public SceneAudios GetSceneAudios(string sceneName)
    {
        return sceneAudios.Find(i => i.sceneName == sceneName);
    }
}

[System.Serializable]
public class SceneAudios
{
    [SceneName] public string sceneName;
    public AudioClip audioClip;

    [Range(0, 1)]
    public float volume = 1;
}