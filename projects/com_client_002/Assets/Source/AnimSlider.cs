using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AnimSlider : MonoBehaviour
{
    public float toValue;
    public float toTime = 0.5f;
    public float time = 0;

    Slider slider;

    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        if (time <= 0) return;

        if (slider == null) {
            slider = GetComponent<Slider>();   
        }

         if (slider == null) {
             return;
         }

        float value = toValue - slider.value;

        if (time > Time.deltaTime) {
            slider.value += value * Time.deltaTime / time;   
            time -= Time.deltaTime;     
        } else {
            time  = 0;   
            slider.value = toValue; 
        }
    }

    public void startAnim(float value) {
        toValue = value;
        time += toTime;
        if (time > 1) {
            time = 1;
        }
    }
}
