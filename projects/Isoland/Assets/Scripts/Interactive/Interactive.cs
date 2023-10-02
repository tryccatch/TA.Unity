using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactive : MonoBehaviour
{
    public ItemName requireItem;
    public bool isDone;

    public void CheckItem(ItemName itemName)
    {
        if (itemName == requireItem && !isDone)
        {
            isDone = true;
            // 使用这个物品，移除物品
            OnClickAction();
            EventHandler.CallItemUseEvent(itemName);
        }
    }

    /// <summary>
    /// 默认是正确物品的情况执行
    /// </summary>
    protected virtual void OnClickAction() { }

    public virtual void EmptyClick()
    {
        Debug.Log("Empty Click");
    }
}
