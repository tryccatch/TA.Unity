using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ProjectBuild
{
    class BuildWindow : EditorWindow
    {
        BuildWindow window;
        private Dictionary<int, ChannelConfig> cfg;


        [MenuItem("项目打包/设置")]
        static void Build()
        {
            testPath();
            BuildProject.channelCfg = CfgParser.getChannelConfig();
            new BuildWindow().showWindow(BuildProject.channelCfg);
        }

        static void testPath()
        {
            var file = Application.dataPath + "/Lua/config.lua";
            var pos = file.IndexOf("Assets");
            file = file.Substring(pos);

            var name = file.Substring("Assets/".Length);
            if (name.IndexOf("Resource") == 0)
            {
                name = name.Substring("Resource/".Length);
            }

            name = name.Replace("\\", "_");
            name = name.Replace("/", "_");

            pos = name.LastIndexOf(".");
            var type = name.Substring(pos + 1);

        }

        public void showWindow(Dictionary<int, ChannelConfig> cfg)
        {
            this.cfg = cfg;
            window = GetWindow<BuildWindow>("项目打包");
            window.titleContent = new GUIContent("项目打包");
            window.Show();
        }


        Dictionary<int, bool> addToList = new Dictionary<int, bool>();
        GameServerEnum allServerEnum = GameServerEnum.LocalTest;
        private Vector2 scrollValue;
        private void OnGUI()
        {
            scrollValue = EditorGUILayout.BeginScrollView(scrollValue);
            for (int i = 0; i < 1; i++)
            {
                foreach (var value in cfg.Values)
                {
                    GUILayout.Label(value.channelName, EditorStyles.boldLabel);
                    GUILayout.Label("包名:"+value.bundleName, EditorStyles.boldLabel);
                    value.appVer = EditorGUILayout.TextField("版本号", value.appVer);
                    value.appBundle = EditorGUILayout.IntField("Bundle", value.appBundle);
                    value.serverType = (GameServerEnum)EditorGUILayout.EnumPopup("服务器类型", value.serverType);
                    if (!addToList.ContainsKey(value.id))
                        addToList.Add(value.id, false);
                    value.onlyBuildRes = EditorGUILayout.Toggle("只打资源包", value.onlyBuildRes);
                    addToList[value.id] = EditorGUILayout.Toggle("打包", addToList[value.id]);
                    EditorGUILayout.Space();
                }
            }

            EditorGUILayout.Space();
            EditorGUILayout.Space();

            allServerEnum = (GameServerEnum)EditorGUILayout.EnumPopup("全部包服务器类型", allServerEnum);

            EditorGUILayout.EndScrollView();

            EditorGUILayout.Space();

            if (GUILayout.Button("打包选中渠道"))
            {
                BuildProject.StartBuild(addToList);
            }
            if (GUILayout.Button("打包全部渠道"))
            {
                BuildProject.StartBuild(null, allServerEnum);
            }

        }
    }
}

