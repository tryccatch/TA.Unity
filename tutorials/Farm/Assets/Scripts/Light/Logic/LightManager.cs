using UnityEngine;

public class LightManager : MonoBehaviour
{
    private LightControl[] sceneLights;
    private LightShift currentLightShift;
    private Season currentSeason;
    private float timeDifference;

    private void OnEnable()
    {
        EventHandler.AfterSceneLoadedEvent += OnAfterSceneLoadedEvent;
        EventHandler.LightShiftChangeEvent += OnLightShiftChangeEvent;
    }

    private void OnDisable()
    {
        EventHandler.AfterSceneLoadedEvent -= OnAfterSceneLoadedEvent;
        EventHandler.LightShiftChangeEvent -= OnLightShiftChangeEvent;
    }

    private void OnLightShiftChangeEvent(Season season, LightShift lightShift, float timeDifference)
    {
        currentSeason = season;
        this.timeDifference = timeDifference;
        if (currentLightShift != lightShift)
        {
            currentLightShift = lightShift;
            foreach (LightControl light in sceneLights)
            {
                // LightControl 改变灯光的方法
                light.ChangeLightShift(currentSeason, currentLightShift, timeDifference);
            }
        }
    }

    private void OnAfterSceneLoadedEvent()
    {
        sceneLights = FindObjectsOfType<LightControl>();

        foreach (LightControl light in sceneLights)
        {
            // LightControl 改变灯光的方法
            light.ChangeLightShift(currentSeason, currentLightShift, timeDifference);
        }
    }
}