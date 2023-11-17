using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MaxSize : MonoBehaviour
{

    public float side = 0;
    float height;
    // Start is called before the first frame update
    void Start()
    {
        var rs = transform as RectTransform;
        height = rs.sizeDelta.y;
    }

    // Update is called once per frame
    void Update()
    {
        float maxY = height;

        var self = transform as RectTransform;
            
        var text = self.GetComponent<Text>();
        if (text != null) {
            if (text.preferredHeight > maxY) {
                maxY = text.preferredHeight;
            }
        }      


       
        
        for (var i=0; i<transform.childCount; i++) {
            var child = transform.GetChild(i);        

            if (!child.gameObject.activeSelf) continue;    

            var r = child.transform as RectTransform;
            
            var c = child.GetComponent<Text>();
            if (c != null) {
                r.sizeDelta = new Vector2(r.sizeDelta.x,c.preferredHeight);
            }            

            var y = -r.offsetMin.y + side;     
           
            if (y > maxY) {
                maxY = y;
            }
        }

        

        var rs = transform as RectTransform;
        rs.sizeDelta = new Vector2(rs.sizeDelta.x,maxY);
        
    }
}
