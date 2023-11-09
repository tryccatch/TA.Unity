using UnityEngine;

namespace TA.Inventory
{
    public class ItemPickUp : MonoBehaviour
    {
        private void OnTriggerEnter2D(Collider2D other)
        {
            Item item = other.GetComponent<Item>();

            if (item != null)
            {
                if (item.itemDetails.canPickedup)
                {
                    // 拾取物品添加到背包
                    InventoryManager.Instance.AddItem(item, true);

                    // 播放音效
                    EventHandler.CallPlaySoundEvent(SoundName.Pickup);
                }
            }
        }
    }
}