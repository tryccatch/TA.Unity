using UnityEngine;
using UnityEditor;

#if UNITY_EDITOR
[CustomPropertyDrawer(typeof(SceneNameAttribute))]
public class SceneNameDrawer : PropertyDrawer
{
    int sceneIndex = -1;
    GUIContent[] sceneNames;

    readonly string[] scenePathSplit = { "/", ".unity" };
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        if (EditorBuildSettings.scenes.Length == 0)
        {
            EditorGUI.LabelField(position, "No scenes in build settings");
            return;
        }

        if (sceneIndex == -1)
            GetSceneNameArray(property);

        int oldIndex = GetSceneNameIndex(property);

        sceneIndex = EditorGUI.Popup(position, label, oldIndex, sceneNames);

        if (oldIndex != sceneIndex)
            property.stringValue = sceneNames[sceneIndex].text;
    }

    private void GetSceneNameArray(SerializedProperty property)
    {
        var scenes = EditorBuildSettings.scenes;

        // 初始化数组
        sceneNames = new GUIContent[scenes.Length];

        for (int i = 0; i < sceneNames.Length; i++)
        {
            string path = scenes[i].path;
            string[] splitPath = path.Split(scenePathSplit, System.StringSplitOptions.RemoveEmptyEntries);

            string sceneName;
            if (splitPath.Length > 0)
            {
                sceneName = splitPath[splitPath.Length - 1];
            }
            else
            {
                sceneName = "(Deleted Scene)";
            }
            sceneNames[i] = new GUIContent(sceneName);
        }

        if (sceneNames.Length == 0)
        {
            sceneNames = new[] { new GUIContent("Check Your Build Settings") };
        }

        property.stringValue = sceneNames[GetSceneNameIndex(property)].text;
    }

    private int GetSceneNameIndex(SerializedProperty property)
    {
        int index = -1;

        if (!string.IsNullOrEmpty(property.stringValue))
        {
            bool nameFound = false;

            for (int i = 0; i < sceneNames.Length; i++)
            {
                if (sceneNames[i].text == property.stringValue)
                {
                    index = i;
                    nameFound = true;
                    break;
                }
            }

            if (nameFound == false)
                index = 0;
        }
        else
        {
            index = 0;
        }

        return index;
    }
}
#endif