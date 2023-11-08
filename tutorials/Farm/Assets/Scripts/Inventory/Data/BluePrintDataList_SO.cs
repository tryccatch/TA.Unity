using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "BluePrintDataList_SO", menuName = "Inventory/BluePrintDataList_SO")]
public class BluePrintDataList_SO : ScriptableObject
{
    public List<BluePrintDetails> bluePrintDataList;

    public BluePrintDetails GetBluePrintDetails(int itemID)
    {
        return bluePrintDataList.Find(x => x.ID == itemID);
    }
}

[System.Serializable]
public class BluePrintDetails
{
    [ItemID] public int ID;
    public InventoryItem[] resourceItem = new InventoryItem[4];
    public GameObject buildPrefab;
}