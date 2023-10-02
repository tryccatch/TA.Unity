using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "GameH2A_SO", menuName = "Mini Game Data/GameH2A_SO")]
public class GameH2A_SO : ScriptableObject
{
    [SceneName] public string gameName;
    [Header("球的名字和对应图片")]
    public List<BallDetails> ballDataList;

    [Header("游戏逻辑数据")]
    public List<Connections> lineConnections;
    public List<BallName> startBallOrder;

    public BallDetails GetBallDetails(BallName ballName)
    {
        return ballDataList.Find(b => b.ballName == ballName);
    }
}

[System.Serializable]
public class BallDetails
{
    public BallName ballName;
    public Sprite wrongSprite;
    public Sprite rightSprite;
}

[System.Serializable]
public class Connections
{
    public int from;
    public int to;
}