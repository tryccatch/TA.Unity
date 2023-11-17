using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextWithEllipsis : MonoBehaviour
{
    public string symbol = "…";
    Text text;
    void Start()
    {
        text = transform.GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        if (text != null)
        {
            SetTextWithEllipsis(text.text);
        }
    }
    public void SetTextWithEllipsis(string value)
    {
        var generator = new TextGenerator();
        var textRect = text.GetComponent<RectTransform>();
        var settings = text.GetGenerationSettings(textRect.rect.size);
        generator.Populate(value, settings);

        var cvisual = generator.characterCountVisible;
        var updatedText = value;
        if (value.Length > cvisual)
        {
            updatedText = value.Substring(0, cvisual);
            updatedText += symbol;
        }
        text.text = updatedText;
        //return updatedText;
    }
}
