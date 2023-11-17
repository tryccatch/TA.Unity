using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIConfig : MonoBehaviour
{
    public enum DisType {
        String,         // 文本
        DateTime,       // 日期 年月日 时分秒
        CountDownTimer, // 倒记时

        Anim,       // 骨骼动画
        Image,      // 图片

        AnimSlider, // 动画变化进度条
    }

    public string resName;

    public Transform child;

    public DisType disType = DisType.String;

    // 0 代表不clone， 1 代表从前一个
    public int cloneChildLastCount = 1; 
}
