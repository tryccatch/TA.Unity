using UnityEngine;
using UnityEngine.UI;

public class ShaderUtility : MonoBehaviour
{
    public static void SetGray(GameObject obj, bool isGray)
    {
        obj.GetComponent<Image>().color = isGray ? new Color(1, 1, 1, 0.999f) : new Color(1, 1, 1, 1f);
        obj.GetComponent<Button>().interactable = !isGray;
    }
}