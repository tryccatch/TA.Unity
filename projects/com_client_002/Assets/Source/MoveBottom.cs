using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveBottom : MonoBehaviour
{

    public float downOffset;
    public bool downBottom;

    public void ToBottom()
    {
        downBottom = false;

        var rt = transform as RectTransform;
        var maxY = rt.sizeDelta.y;
        var toY = maxY - downOffset;

        if (toY <= 0) return;

        var offY = toY - transform.localPosition.y;
        transform.localPosition += new Vector3(0, offY, 0);
    }

    // Update is called once per frame
    void Update()
    {
        if (downBottom)
        {
            var rt = transform as RectTransform;
            var maxY = rt.sizeDelta.y;
            var toY = maxY - downOffset;

            if (toY <= 0)
            {
                downBottom = false;
                return;
            }

            if (transform.localPosition.y < toY)
            {
                var offY = toY - transform.localPosition.y;
                var moveY = 0f;

                if (offY <= 10)
                {
                    downBottom = false;
                    moveY = offY;
                }
                else
                {
                    if (offY > 500) offY = 500;
                    if (offY < 100) offY = 100;

                    moveY = offY * Time.deltaTime * 5;
                }



                transform.localPosition += new Vector3(0, moveY, 0);
            }
        }
    }
}
