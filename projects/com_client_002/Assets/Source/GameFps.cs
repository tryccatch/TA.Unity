using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameFps : MonoBehaviour
{
    float deltaTime = 0f;
    float maxFps = 0;
    private bool isDebug = true;
    private GameServerEnum serverEnum;
    private string gameName;

    // Start is called before the first frame update
    void Start()
    {
        var lua = gameObject.GetComponent<LuaRunner>();
        if (lua)
        {
            isDebug = lua.debug;
            serverEnum = lua.serverEnum;
            switch (serverEnum)
            {
                case GameServerEnum.LocalHost:
                    gameName = "开发版本";
                    break;
                case GameServerEnum.LocalTest:
                    gameName = "本地测试";
                    break;
                case GameServerEnum.OuterNetTest:
                    gameName = "外网测试服";
                    break;
                case GameServerEnum.OuterNetOnline:
                    gameName = "外网正式服";
                    break;
                case GameServerEnum.JGGNetTest:
                    gameName = "JGG测试服";
                    break;
                case GameServerEnum.JGGNetOnline:
                    gameName = "JGG正式服";
                    break;
            }
        }

    }

    // Update is called once per frame
    void Update()
    {
        deltaTime += (Time.unscaledDeltaTime - deltaTime) * 0.1f;
    }

    private List<float> list = new List<float>();
    GUIContent content;
    Rect rect;
    GUIStyle style;
    private void OnGUI()
    {
        if (serverEnum == GameServerEnum.OuterNetOnline || serverEnum == GameServerEnum.JGGNetOnline)
            return;
        GUI.backgroundColor = Color.black;
        if (content == null)
        {
            int w = Screen.width, h = Screen.height;
            rect = new Rect(0, 0, w, h * 2 / 100);
            content = new GUIContent();
            style = new GUIStyle();
            style.alignment = TextAnchor.UpperLeft;
            style.normal.textColor = Color.white;
            style.fontSize = 24;
        }


        float msec = deltaTime * 1000.0f;
        float fps = 1.0f / deltaTime;
        if (fps > maxFps || maxFps == 0f)
            maxFps = fps;
        list.Add(fps);
        if (list.Count > 30)
            list.RemoveAt(0);
        var totalFPS = 0f;
        for (int i = 0; i < list.Count; i++)
            totalFPS += list[i];
        var avgFps = totalFPS / list.Count;
        string result = string.Format("{0:0.0} ms ({1:0.} fps)  max:{2:0.}  avg:{3:0.}  {4}-V{5} {6}", msec, fps, maxFps, avgFps, gameName, Application.version, ChannelMgr.channel);
        if (serverEnum == GameServerEnum.OuterNetTest || serverEnum == GameServerEnum.JGGNetTest)
            result = string.Format("{0}-V{1} {2}", gameName, Application.version, ChannelMgr.channel);
        GUI.Box(rect, content);
        GUI.Label(rect, result, style);
    }


}
