using UnityEngine;
using UnityEngine.UI;

public class Slot : MonoBehaviour
{
    public int slotID;
    public Item slotItem;
    public Image slotImage;
    public Text slotNum;
    public GameObject itemInSlot;

    public void ItemOnClick()
    {
        InventoryManager.UpdateItemInfo(slotItem.itemDescription);
    }

    public void SetUpSlot(Item item)
    {
        slotItem = item;

        if (item == null)
        {
            itemInSlot.SetActive(false);
            return;
        }

        slotImage.sprite = item.itemImage;
        slotNum.text = item.itemHeld.ToString();
    }
}