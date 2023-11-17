using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TestScript : MonoBehaviour
{
    InputField filed;
    // Start is called before the first frame update
    void Start()
    {
        filed = transform.GetComponent<InputField>();
        if (filed != null)
        {
            filed.onValueChanged.AddListener(onValueChange);

        }

        //SensitiveCheck.init();
    }

    void onValueChange(string value)
    {

        var result = StringTools.SubString(value, 1);
        Debug.Log(result);
        //var result = SensitiveCheck.IsContainSensitiveWords(ref value, out string temp);
        //Debug.Log("结果:" + result + "," + value + "," + temp);
    }

    // Update is called once per frame
    void Update()
    {

    }


}
