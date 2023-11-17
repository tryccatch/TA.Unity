using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
 
public class DragUI : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    /// <summary>
    /// UI和指针的位置偏移量
    /// </summary>
    Vector3 offset;

    void Update()
    {
        DragRangeLimit();
    }
 
 
    /// <summary>
    /// 拖拽范围限制
    /// </summary>
    void DragRangeLimit()
    {
        var parentRt = transform.parent.GetComponent<RectTransform>();
        var rt = GetComponent<RectTransform>();
 
        var minWidth = 0;                           
        var maxWidth = rt.rect.width - parentRt.rect.width;
        var minHeight = 0;
        var maxHeight = rt.rect.height - parentRt.rect.height;

        //限制水平/垂直拖拽范围在最小/最大值内
        var rangeX = Mathf.Clamp(rt.localPosition.x, minWidth, maxWidth);
        var rangeY = Mathf.Clamp(rt.localPosition.y, minHeight, maxHeight);
        //更新位置
        rt.localPosition = new Vector3(rangeX, rangeY, 0);

        //Debug.Log(parentRt.rect.height + ":" + rt.rect.height);
    }
 
    /// <summary>
    /// 开始拖拽
    /// </summary>
    public void OnBeginDrag(PointerEventData eventData)
    {
        var rt = GetComponent<RectTransform>();
        Vector3 globalMousePos;
 
        //将屏幕坐标转换成世界坐标
        if (RectTransformUtility.ScreenPointToWorldPointInRectangle(rt, eventData.position, null, out globalMousePos))
        {
            //计算UI和指针之间的位置偏移量
            offset = transform.localPosition - globalMousePos;
        }
    }
 
    /// <summary>
    /// 拖拽中
    /// </summary>
    public void OnDrag(PointerEventData eventData)
    {
        SetDraggedPosition(eventData);
    }
 
    /// <summary>
    /// 结束拖拽
    /// </summary>
    public void OnEndDrag(PointerEventData eventData)
    {
 
    }
 
    /// <summary>
    /// 更新UI的位置
    /// </summary>
    private void SetDraggedPosition(PointerEventData eventData)
    {
        var rt = GetComponent<RectTransform>();
        Vector3 globalMousePos;
 
        if (RectTransformUtility.ScreenPointToWorldPointInRectangle(rt, eventData.position, null, out globalMousePos))
        {
            transform.localPosition = offset + globalMousePos;
        }
    }
}
 