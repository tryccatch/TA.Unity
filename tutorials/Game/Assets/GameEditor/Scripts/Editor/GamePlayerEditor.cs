using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditorInternal;
using System.Collections.Generic;
using System.IO;

[CustomEditor(typeof(GamePlayerData_SO))]
public class GamePlayerCustomEditor : Editor
{
    public override void OnInspectorGUI()
    {
        if (GUILayout.Button("Open in Editor"))
        {
            GamePlayerEditor.InitWindow((GamePlayerData_SO)target);
        }

        base.OnInspectorGUI();
    }
}

public class GamePlayerEditor : EditorWindow
{
    GamePlayerData_SO currentGamePlayerData;

    ReorderableList reorderList = null;

    Dictionary<string, ReorderableList> optionsListDict = new Dictionary<string, ReorderableList>();

    Vector2 scrollPos = Vector2.zero;

    [MenuItem("TA/TA Editor Window")]
    private static void ShowWindow()
    {
        var window = GetWindow<GamePlayerEditor>();
        window.titleContent = new GUIContent("TA Editor Window");
        window.Show();
    }

    public static void InitWindow(GamePlayerData_SO data)
    {
        GamePlayerEditor editorWindow = GetWindow<GamePlayerEditor>();
        editorWindow.currentGamePlayerData = data;
    }

    [OnOpenAsset]
    public static bool OnOpenAsset(int instanceID, int line)
    {
        GamePlayerData_SO data = EditorUtility.InstanceIDToObject(instanceID) as GamePlayerData_SO;

        if (data != null)
        {
            InitWindow(data);
            return true;
        }
        return false;
    }

    private void OnSelectionChange()
    {
        var newData = Selection.activeObject as GamePlayerData_SO;

        if (newData != null)
        {
            currentGamePlayerData = newData;
            SetupReorderableList();
        }
        else
        {
            currentGamePlayerData = null;
            reorderList = null;
        }
        Repaint();
    }

    private void OnGUI()
    {
        if (currentGamePlayerData != null)
        {
            EditorGUILayout.LabelField(currentGamePlayerData.name, EditorStyles.boldLabel);
            GUILayout.Space(10);

            scrollPos = GUILayout.BeginScrollView(scrollPos, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));

            if (reorderList == null)
                SetupReorderableList();

            reorderList.DoLayoutList();

            GUILayout.EndScrollView();
        }
        else
        {
            if (GUILayout.Button("Create New TA"))
            {
                string dataPath = "Assets/Game Data/TA Data/";
                if (!Directory.Exists(dataPath))
                    Directory.CreateDirectory(dataPath);

                GamePlayerData_SO newData = ScriptableObject.CreateInstance<GamePlayerData_SO>();
                AssetDatabase.CreateAsset(newData, dataPath + "New TA.asset");
                currentGamePlayerData = newData;
            }
            GUILayout.Label("NO DATA SELECTED!", EditorStyles.boldLabel);
        }
    }

    private void OnDisable()
    {
        optionsListDict.Clear();
    }

    private void SetupReorderableList()
    {
        reorderList = new ReorderableList(currentGamePlayerData.playDataList, typeof(GamePlayerData_SO));

        reorderList.drawHeaderCallback += OnDrawDataHeader;
        reorderList.drawElementCallback += OnDrawDataElement;
        reorderList.elementHeightCallback += OnElementHeight;
    }

    private float OnElementHeight(int index)
    {
        return GetTaHeight(currentGamePlayerData.playDataList[index]);
    }

    float GetTaHeight(GamePlayer ta)
    {
        var height = EditorGUIUtility.singleLineHeight;

        var isExpand = ta.canExpand;

        if (isExpand)
        {
            height += EditorGUIUtility.singleLineHeight * 9;

            var option = ta.options;

            if (option != null && option.Count > 0)
            {
                height += EditorGUIUtility.singleLineHeight * option.Count;
            }
        }

        return height;
    }

    private void OnDrawDataElement(Rect rect, int index, bool isActive, bool isFocused)
    {
        EditorUtility.SetDirty(currentGamePlayerData);

        GUIStyle textStyle = new GUIStyle("TextField");
        if (index < currentGamePlayerData.playDataList.Count)
        {
            var currentPlayerData = currentGamePlayerData.playDataList[index];

            var tempRect = rect;

            tempRect.height = EditorGUIUtility.singleLineHeight;

            currentPlayerData.canExpand = EditorGUI.Foldout(tempRect, currentPlayerData.canExpand, currentPlayerData.playerName);

            if (currentPlayerData.canExpand)
            {
                tempRect.width = 52;
                tempRect.y += tempRect.height;
                EditorGUI.LabelField(tempRect, "Name");

                tempRect.x += tempRect.width;
                tempRect.width = 100;
                currentPlayerData.playerName = EditorGUI.TextField(tempRect, currentPlayerData.playerName);

                tempRect.x += tempRect.width + 20;
                EditorGUI.LabelField(tempRect, "GameObject");

                tempRect.x += tempRect.width;
                tempRect.width = 160;
                currentPlayerData.playerObj = (GameObject)EditorGUI.ObjectField(tempRect, currentPlayerData.playerObj, typeof(GameObject), false);

                tempRect.y += EditorGUIUtility.singleLineHeight + 5;
                tempRect.x = rect.x;
                tempRect.height = 60;
                tempRect.width = tempRect.height;
                currentPlayerData.playerHead = (Sprite)EditorGUI.ObjectField(tempRect, currentPlayerData.playerHead, typeof(Sprite), false);

                tempRect.x += tempRect.width + 5;
                tempRect.width = rect.width - tempRect.x;
                textStyle.wordWrap = true;
                currentPlayerData.playerDescription = EditorGUI.TextField(tempRect, currentPlayerData.playerDescription, textStyle);

                tempRect.y += tempRect.height + 5;
                tempRect.x = rect.x;
                tempRect.width = rect.width;

                string optionListKey = currentPlayerData.playerName + currentPlayerData.playerAge;

                if (optionListKey != string.Empty)
                {
                    if (!optionsListDict.ContainsKey(optionListKey))
                    {
                        var optionList = new ReorderableList(currentPlayerData.options, typeof(string));

                        optionList.drawElementCallback = (optionRect, optionIndex, optionActive, optionFocused) =>
                        {
                            OnDrawOptionElement(currentPlayerData, optionRect, optionIndex, optionActive, optionFocused);
                        };

                        optionsListDict[optionListKey] = optionList;
                    }

                    optionsListDict[optionListKey].DoList(tempRect);
                }
            }
        }
    }

    private void OnDrawOptionElement(GamePlayer currentData, Rect optionRect, int optionIndex, bool optionActive, bool optionFocused)
    {
        var currentOption = currentData.options[optionIndex];
        var tempRect = optionRect;

        tempRect.width = optionRect.width * 0.5f;
        currentOption = EditorGUI.TextField(tempRect, currentOption);
    }

    private void OnDrawDataHeader(Rect rect)
    {
        GUI.Label(rect, "ta data");
    }
}