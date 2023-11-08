using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

[CustomPropertyDrawer(typeof(ItemIDAttribute))]
public class ItemIDDrawer : PropertyDrawer
{
    private ItemDataList_SO dataBase;
    private List<ItemDetails> itemList = new();

    int itemIndex = -1;
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

        if (itemIndex == -1)
            GetItemIDArray(property);

        int oldIndex = GetItemIDIndex(property);

        if (property.propertyType == SerializedPropertyType.Integer)
            itemIndex = EditorGUI.Popup(position, label, oldIndex, itemIDs);
        else
            EditorGUI.LabelField(position, label.text, "Use ItemID with int.");

        if (oldIndex != itemIndex)
            property.intValue = itemIDArray[itemIndex];
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
    }

    private void GetItemIDArray(SerializedProperty property)
    {
        itemIDs = new GUIContent[itemIDArray.Length];

        for (int i = 0; i < itemIDArray.Length; i++)
        {
            itemIDs[i] = new GUIContent(itemIDArray[i] + "\t" + itemList.Find(t => t.itemID == itemIDArray[i])?.itemName);
        }

        if (itemList.Count == 0)
        {
            itemIDs = new[] { new GUIContent("Check Your Build Settings") };
        }

        property.intValue = itemIDArray[GetItemIDIndex(property)];
    }

    private int GetItemIDIndex(SerializedProperty property)
    {
        int index = -1;

        if (property.intValue >= -1)
        {
            bool nameFound = false;

            for (int i = 0; i < itemIDArray.Length; i++)
            {
                if (itemIDArray[i] == property.intValue)
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