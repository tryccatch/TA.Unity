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
            property.intValue = itemList[newIndex].itemID;
    }

    private int GetCurrentIndex(SerializedProperty property)
    {
        int itemIndex = -1;

        if (property.intValue >= -1)
        {
            bool nameFound = false;

            for (int i = 0; i < itemList.Count; i++)
            {
                if (itemList[i].itemID == property.intValue)
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
        // Debug.Log(itemList[0].itemID);
    }

    private void GetItemIDArray(SerializedProperty property)
    {
        itemIDs = new GUIContent[itemList.Count];

        for (int i = 0; i < itemList.Count; i++)
        {
            itemIDs[i] = new GUIContent(itemList[i].itemID.ToString());
        }

        if (itemList.Count == 0)
        {
            itemIDs = new[] { new GUIContent("Check Your Build Settings") };
        }

        initData = true;
        property.intValue = itemList[GetCurrentIndex(property)].itemID;
    }
}