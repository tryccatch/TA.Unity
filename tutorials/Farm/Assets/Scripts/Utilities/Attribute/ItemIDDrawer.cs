using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

[CustomPropertyDrawer(typeof(ItemIDAttribute))]
public class ItemIDDrawer : PropertyDrawer
{
    private ItemDataList_SO dataBase;
    private List<ItemDetails> itemList = new();
    // int itemIndex = -1;
    private bool initData = false;
    GUIContent[] itemIDs;
    int[] itemIDArray;
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        if (dataBase == null)
            LoadDataBase();

        if (itemList.Count == 0)
        {
            EditorGUI.LabelField(position, "No ItemData In GameData");
            return;
        }

        if (!initData)
            GetItemIDArray(property);

        int oldIndex = GetCurrentIndex(property);
        int newIndex = -1;
        if (property.propertyType == SerializedPropertyType.Integer)
            newIndex = EditorGUI.Popup(position, label, oldIndex, itemIDs);
        else
            EditorGUI.LabelField(position, label.text, "Use ItemID with int.");

        if (oldIndex != newIndex)
            property.intValue = itemIDArray[newIndex];
    }

    private int GetCurrentIndex(SerializedProperty property)
    {
        int itemIndex = -1;

        if (property.intValue >= -1)
        {
            bool nameFound = false;

            for (int i = 0; i < itemIDArray.Length; i++)
            {
                if (itemIDArray[i] == property.intValue)
                {
                    itemIndex = i;
                    nameFound = true;
                    break;
                }
            }

            if (nameFound == false)
                itemIndex = 0;
        }
        else
        {
            itemIndex = 0;
        }

        return itemIndex;
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

        itemIDArray = new int[itemList.Count + 1];

        itemIDArray[0] = 0;

        for (int i = 1; i < itemIDArray.Length; i++)
        {
            itemIDArray[i] = itemList[i - 1].itemID;
        }
        // Debug.Log(itemIDArray.Length);
    }

    private void GetItemIDArray(SerializedProperty property)
    {
        itemIDs = new GUIContent[itemIDArray.Length];

        for (int i = 0; i < itemIDArray.Length; i++)
        {
            itemIDs[i] = new GUIContent(itemIDArray[i].ToString());
        }
        // Debug.Log(itemIDs.Length);
        if (itemList.Count == 0)
        {
            itemIDs = new[] { new GUIContent("Check Your Build Settings") };
        }

        initData = true;
        property.intValue = itemIDArray[GetCurrentIndex(property)];
    }
}