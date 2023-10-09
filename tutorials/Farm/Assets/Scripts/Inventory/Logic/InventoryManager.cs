using UnityEngine;

namespace TA.Inventory
{
    public class InventoryManager : Singleton<InventoryManager>
    {
        public ItemDataList_SO itemDataList_SO;

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
            Debug.Log(item.itemDetails.itemID + "\tName:" + item.itemDetails.itemName);
            if (toDestroy)
            {
                Destroy(item.gameObject);
            }
        }
    }
}