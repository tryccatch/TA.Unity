using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryManager : MonoBehaviour
{
    static InventoryManager instance;

    public Inventory myBag;
    public GameObject slotGrid;
    // public Slot slotPrefab;
    public GameObject slot;
    public Text itemDescription;

    public List<GameObject> slots = new();

    private void Awake()
    {
        if (instance != null)
            Destroy(this);
        instance = this;
    }

    private void OnEnable()
    {
        RefreshItem();
        itemDescription.text = "";
    }

    public static void UpdateItemInfo(string itemDescription)
    {
        instance.itemDescription.text = itemDescription;
    }

    /* 
    public static void CreateNewItem(Item item)
    {
        Slot newItem = Instantiate(instance.slotPrefab, instance.slotGrid.transform);

        newItem.slotItem = item;
        newItem.slotImage.sprite = item.itemImage;
        newItem.slotNum.text = item.itemHeld.ToString();
    } 
    // */

    public static void RefreshItem()
    {
        for (int i = 0; i < instance.slotGrid.transform.childCount; i++)
        {
            Destroy(instance.slotGrid.transform.GetChild(i).gameObject);
            instance.slots.Clear();
        }

        for (int i = 0; i < instance.myBag.itemList.Count; i++)
        {
            // CreateNewItem(instance.myBag.itemList[i]);
            instance.slots.Add(Instantiate(instance.slot, instance.slotGrid.transform));
            instance.slots[i].GetComponent<Slot>().SetUpSlot(instance.myBag.itemList[i]);
            instance.slots[i].GetComponent<Slot>().slotID = i;
        }
    }
}