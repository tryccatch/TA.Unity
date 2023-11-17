using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AutoWidth : MonoBehaviour
{
    public float side = 0;
    
    // Start is called before the first frame update


    Text text;
    
    void Start()
    {
        text = GetComponent<Text>();        
    }

    // Update is called once per frame
    void Update()
    {
        var t = transform as RectTransform;
        t.sizeDelta = new Vector2(text.preferredWidth,t.sizeDelta.y);
    }
}
