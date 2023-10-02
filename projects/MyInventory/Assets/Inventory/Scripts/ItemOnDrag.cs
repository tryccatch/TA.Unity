using UnityEngine;
using UnityEngine.EventSystems;

public class ItemOnDrag : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    private Transform originalParent;
    public Inventory myBag;
    private int currentItemID;
    public void OnBeginDrag(PointerEventData eventData)
    {
        originalParent = transform.parent;
        currentItemID = originalParent.GetComponent<Slot>().slotID;
        transform.SetParent(transform.parent.parent);
        transform.position = eventData.position;
        GetComponent<CanvasGroup>().blocksRaycasts = false;
    }

    public void OnDrag(PointerEventData eventData)
    {
        transform.position = eventData.position;
        // Debug.Log(eventData.pointerCurrentRaycast.gameObject.name);
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        var tempTransform = eventData.pointerCurrentRaycast.gameObject != null ? eventData.pointerCurrentRaycast.gameObject.transform : null;
        var tempTag = tempTransform != null ? tempTransform.tag : null;

        switch (tempTag)
        {
            case "Item":
                {
                    transform.SetParent(tempTransform.parent);

                    tempTransform.SetParent(originalParent);
                    tempTransform.localPosition = Vector2.zero;

                    var tempID = tempTransform.GetComponentInParent<Slot>().slotID;
                    (myBag.itemList[currentItemID], myBag.itemList[tempID]) = (myBag.itemList[tempID], myBag.itemList[currentItemID]);
                }
                break;
            case "Slot":
                {
                    transform.SetParent(tempTransform);

                    myBag.itemList[tempTransform.GetComponent<Slot>().slotID] = myBag.itemList[currentItemID];
                    myBag.itemList[currentItemID] = null;
                }
                break;
            default:
                transform.SetParent(originalParent);
                break;
        }

        transform.localPosition = Vector2.zero;
        GetComponent<CanvasGroup>().blocksRaycasts = true;
    }
}