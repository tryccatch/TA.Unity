using UnityEngine;

namespace TA.Inventory
{
    public class InventoryManager : Singleton<InventoryManager>
    {
        [Header("物品数据")]
        public ItemDataList_SO itemDataList_SO;
        [Header("背包数据")]
        public InventoryBag_SO playerBag;

        /// <summary>
        /// 通过ID返回物品信息
        /// </summary>
        /// <param name="ID">Item ID</param>
        /// <returns></returns>
        public ItemDetails GetItemDetails(int ID)
        {
            return itemDataList_SO.itemDetailsList.Find(i => i.itemID == ID);
        }

        /// <summary>
        /// 添加物品到Player背包
        /// </summary>
        /// <param name="item"></param>
        /// <param name="toDestroy">是否要销毁物品</param>
        public void AddItem(Item item, bool toDestroy)
        {
            // 背包是否有空位
            // 是否已经有该物品
            InventoryItem newItem = new()
            {
                itemID = item.itemID,
                itemAmount = 1
            };

            playerBag.itemList[0] = newItem;

            Debug.Log(item.itemDetails.itemID + "\tName:" + item.itemDetails.itemName);
            if (toDestroy)
            {
                Destroy(item.gameObject);
            }
        }
    }
}