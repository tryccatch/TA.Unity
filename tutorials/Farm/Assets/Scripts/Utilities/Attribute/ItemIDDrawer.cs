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

        int oldIndex = itemIndex;

        itemIndex = EditorGUI.Popup(position, label, itemIndex, itemIDs);

        if (oldIndex != itemIndex)
            property.intValue = itemList[itemIndex].itemID;
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

        if (property.intValue >= 1000)
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

        property.intValue = itemList[itemIndex].itemID;
    }
}