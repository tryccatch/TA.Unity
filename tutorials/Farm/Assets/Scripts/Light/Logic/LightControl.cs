using UnityEngine;
using UnityEngine.Rendering.Universal;

public class LightControl : MonoBehaviour
{
    public LightPattenList_SO lightData;
    private Light2D currentLight;
    private LightDetails currentLightDetails;

    private void Awake()
    {
        currentLight = GetComponent<Light2D>();
    }

    // 实际切换灯光
}