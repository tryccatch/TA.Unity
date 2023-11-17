using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class MaskClick : MonoBehaviour, IPointerClickHandler
{
    public Transform canClick;


    /*   
    public bool IsRaycastLocationValid (Vector2 sp, Camera eventCamera) {        

        
        if (canClick != null) {

            var com = canClick.GetComponent<Image>();

            if (com.IsRaycastLocationValid(sp,eventCamera)) {

                var rectTransform = (RectTransform)canClick;

                if ( RectTransformUtility.RectangleContainsScreenPoint(rectTransform,sp,eventCamera) ) {
                    return false;
                }

            }
        }

        return working;
    } */


    static public void SetClick(Transform t, Transform node)
    {

        if (t != null)
        {
            var com = t.GetComponent<MaskClick>();
            if (com == null)
            {
                com = t.gameObject.AddComponent<MaskClick>();
            }
            com.canClick = node;
            var image = t.GetComponent<Image>();
            image.enabled = true;
        }
    }

    static public void Clear(Transform t)
    {
        if (t != null)
        {
            var com = t.GetComponent<MaskClick>();
            if (com != null)
            {
                var image = t.GetComponent<Image>();
                image.enabled = false;
            }
        }
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        if (canClick != null)
        {
            var rectTransform = (RectTransform)canClick;

            if (RectTransformUtility.RectangleContainsScreenPoint(rectTransform, eventData.position, eventData.enterEventCamera))
            {
                Debug.Log(canClick.name);
                var button = canClick.GetComponent<Button>();
                if (button != null && button.enabled)
                {
                    button.OnPointerClick(eventData);
                    Debug.Log("eventData");
                    Debug.Log(eventData.button);
                    Debug.Log(button.enabled);
                    Transform mask = UIAPI.gNode.Find("Mask");
                    if (mask != null)
                    {
                        Debug.Log("将Mask设为True");
                        mask.gameObject.SetActive(true);
                        mask.SetAsLastSibling();
                    }
                    else
                    {
                        Transform node = UIAPI.Load("Base/Mask", UIAPI.gNode);
                        UIAPI.Show(node);
                        Debug.Log("增加Mask");
                    }
                    //Clear(gameObject.transform);
                }
                else
                {
                    var toggle = canClick.GetComponent<Toggle>();
                    if (toggle != null && toggle.enabled)
                    {
                        toggle.OnPointerClick(eventData);
                    }
                    else
                        Debug.Log("button无效");
                }
            }
        }
    }
}
