using System.Collections.Generic;
using TA.Save;

public class DataSlot
{
    /// <summary>
    /// 进度条，string是GUID
    /// </summary>
    public Dictionary<string, GameSaveData> dataDict = new Dictionary<string, GameSaveData>();

}