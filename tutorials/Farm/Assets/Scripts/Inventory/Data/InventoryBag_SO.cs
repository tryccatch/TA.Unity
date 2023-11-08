using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "InventoryBag_SO", menuName = "Inventory/InventoryBag")]
public class InventoryBag_SO : ScriptableObject
{
    public List<InventoryItem> itemList;

    public InventoryItem GetInventoryItem(int ID)
    {
        return itemList.Find(t => t.itemID == ID);
    }
}