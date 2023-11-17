using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

public class ViewDragBottom : MonoBehaviour
{
    private bool hasActived;

    public LuaFunction fun;

    public void Start() {
        hasActived = false;

        var s = transform.parent.parent.GetComponent<ScrollRect>();
        s.onValueChanged.AddListener(this.OnDrag);        
    }

    public void OnDrag(Vector2 data)
    {        
        var view = transform.parent.parent as RectTransform;
        var cont = transform as RectTransform;

        //Debug.Log((cont.rect.height - transform.localPosition.y) + ":" + view.rect.height);
        if (cont.rect.height - transform.localPosition.y < view.rect.height) {
            if (!hasActived) {
                if (fun != null) {
                    fun.Call();
                }
            } 
            hasActived = true;
        } else {
            hasActived = false;
        }
    }
}
