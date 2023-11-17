using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ImageDrap : MonoBehaviour, IBeginDragHandler, IDragHandler
{

    float offX;
    float startPosX;
    float endPosX;

    public void Start() {

        var parntR = transform.parent as RectTransform;
        var r = transform as RectTransform;

        startPosX = transform.localPosition.x;
        endPosX = startPosX - r.rect.width + parntR.rect.width;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        //Vector3 newPosition;
        //RectTransformUtility.ScreenPointToWorldPointInRectangle(transform as RectTransform, eventData.position, eventData.enterEventCamera, out newPosition);

        //Debug.Log("开始拖拽");
        offX = transform.localPosition.x - eventData.position.x;
    }

    public void OnDrag(PointerEventData eventData)
    {        


        var x  = eventData.position.x + offX;

        if (x > startPosX)
        {
            x = startPosX;
        }

       
        
        if (x < endPosX)
        {
            x = endPosX;
        }

        transform.localPosition = new Vector3(x, transform.localPosition.y, transform.localPosition.z);
    }
}