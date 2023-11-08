using UnityEngine;

public class LightManager : MonoBehaviour
{
    private LightControl[] sceneLights;
    private LightShift currentLightShift;
    private Season currentSeason;

    private void OnEnable()
    {
        EventHandler.AfterSceneLoadedEvent += OnAfterSceneLoadedEvent;
    }

    private void OnDisable()
    {
        EventHandler.AfterSceneLoadedEvent -= OnAfterSceneLoadedEvent;
    }

    private void OnAfterSceneLoadedEvent()
    {
        sceneLights = FindObjectsOfType<LightControl>();

        foreach (LightControl light in sceneLights)
        {
            // LightControl 改变灯光的方法
        }
    }
}