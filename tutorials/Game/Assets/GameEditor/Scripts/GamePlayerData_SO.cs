using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "GamePlayerData_SO", menuName = "TA/GamePlayerData")]
public class GamePlayerData_SO : ScriptableObject
{
    public List<GamePlayer> playDataList = new List<GamePlayer>();

}

[System.Serializable]
public class GamePlayer
{
    public string playerName;
    public int playerAge;
    public Sprite playerHead;
    public GameObject playerObj;
    [TextArea]
    public string playerDescription;
    [HideInInspector]
    public bool canExpand;
    public List<string> options;
}