using System.Collections.Generic;
using TA.Save;
using TA.Transition;

public class DataSlot
{
    /// <summary>
    /// 进度条，string是GUID
    /// </summary>
    public Dictionary<string, GameSaveData> dataDict = new Dictionary<string, GameSaveData>();

    #region 用来UI显示进度详情
    public string DataTime
    {
        get
        {
            var key = TimeManager.Instance.GUID;

            if (dataDict.ContainsKey(key))
            {
                var timeData = dataDict[key];
                return timeData.timeDict["gameYear"] + "年/" + (Season)timeData.timeDict["gameSeason"] + "/" + timeData.timeDict["gameMonth"] + "月/" + timeData.timeDict["gameDay"] + "日/" + timeData.timeDict["gameHour"] + "时" + timeData.timeDict["gameMinute"] + "分";
            }
            else return string.Empty;
        }
    }

    public string DataScene
    {
        get
        {
            var key = TransitionManager.Instance.GUID;
            if (dataDict.ContainsKey(key))
            {
                var transitionData = dataDict[key];
                return transitionData.dataSceneName switch
                {
                    "00.Start" => "海边",
                    "01.Field" => "农场",
                    "02.Home" => "小木屋",
                    "03.Stall" => "市场",
                    _ => string.Empty
                };
            }
            else return string.Empty;
        }
    }
    #endregion
}