using UnityEngine;

public class LogManager : MonoSingleton<LogManager>
{



    public void Log()
    {
        Debug.Log("Test Log");
    }
}