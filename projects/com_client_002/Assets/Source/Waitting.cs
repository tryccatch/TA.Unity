using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Waitting : MonoBehaviour
{

    public float DisDlayTime = 0.5f;

    Image img;

    // Start is called before the first frame update
    void Start()
    {
        img = GetComponent<Image>();
        img.enabled = DisDlayTime <= 0;
    }

    // Update is called once per frame
    void Update()
    {

        if (DisDlayTime > 0)
        {
            DisDlayTime -= Time.deltaTime;
            img.enabled = false;
        }
        else
        {
            img.enabled = true;
        }
    }
}
