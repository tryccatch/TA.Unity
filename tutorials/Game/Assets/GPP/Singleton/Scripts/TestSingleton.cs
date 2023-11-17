using UnityEngine;

public class TestSingleton : MonoBehaviour
{

    private void Start()
    {
        LogManager.Instance.Log();
    }
}