using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEditor.UIElements;
using System.Collections.Generic;
using System;


public class ItemEditor : EditorWindow
{
    private ItemDataList_SO dataBase;
    private List<ItemDetails> itemList = new();

    private VisualTreeAsset itemRowTemplate;
    // 获取VisualElement
    private ListView itemListView;


    [MenuItem("TA/ItemEditor")]
    public static void ShowExample()
    {
        ItemEditor wnd = GetWindow<ItemEditor>();
        wnd.titleContent = new GUIContent("ItemEditor");
    }

    public void CreateGUI()
    {
        // Each editor window contains a root VisualElement object
        VisualElement root = rootVisualElement;

        // VisualElements objects can contain other VisualElement following a tree hierarchy.
        // VisualElement label = new Label("Hello World! From C#");
        // root.Add(label);

        // Import UXML
        var visualTree = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/Editor/UI Builder/ItemEditor.uxml");
        VisualElement labelFromUXML = visualTree.Instantiate();
        root.Add(labelFromUXML);

        // A stylesheet can be added to a VisualElement.
        // The style will be applied to the VisualElement and all of its children.
        // var styleSheet = AssetDatabase.LoadAssetAtPath<StyleSheet>("Assets/Editor/UI Builder/ItemEditor.uss");
        // VisualElement labelWithStyle = new Label("Hello World! With Style");
        // labelWithStyle.styleSheets.Add(styleSheet);
        // root.Add(labelWithStyle);

        // 拿到模板数据
        itemRowTemplate = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/Editor/UI Builder/ItemRowTemplate.uxml");

        // 变量赋值
        itemListView = root.Q<VisualElement>("ItemList").Q<ListView>("ListView");

        // 加载数据
        LoadDataBase();

        // 生成ListView
        GenerateListView();
    }

    private void LoadDataBase()
    {
        var dataArray = AssetDatabase.FindAssets("t:ItemDataList_SO");

        if (dataArray.Length > 0)
        {
            var path = AssetDatabase.GUIDToAssetPath(dataArray[0]);
            dataBase = AssetDatabase.LoadAssetAtPath(path, typeof(ItemDataList_SO)) as ItemDataList_SO;
        }

        itemList = dataBase.itemDetailsList;
        // 如果不标记则无法保存数据
        EditorUtility.SetDirty(dataBase);
        // Debug.Log(itemList[0].itemID);
    }

    private void GenerateListView()
    {
        Func<VisualElement> makeItem = () => itemRowTemplate.CloneTree();

        Action<VisualElement, int> bindItem = (e, i) =>
        {
            if (itemList.Count > 0)
            {
                if (itemList[i].itemIcon != null)
                    e.Q<VisualElement>("Icon").style.backgroundImage = itemList[i].itemIcon.texture;
                e.Q<Label>("Name").text = itemList[i] == null ? "NO ITEM" : itemList[i].itemName;
            }
        };

        // itemListView.fixedItemHeight = 60;
        itemListView.itemsSource = itemList;
        itemListView.makeItem = makeItem;
        itemListView.bindItem = bindItem;
    }
}