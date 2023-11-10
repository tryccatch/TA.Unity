using System.Collections.Generic;
using UnityEngine;

namespace TA.Save
{
    [System.Serializable]
    public class GameSaveData : MonoBehaviour
    {
        public string dataSceneName;
        /// <summary>
        /// 存储人物坐标，sting人物名称
        /// </summary>
        public Dictionary<string, SerializableVector3> characterPosDict;
        public Dictionary<string, List<SceneItem>> sceneItemDict;
        public Dictionary<string, List<SceneFurniture>> sceneFurnitureDict;
        public Dictionary<string, TileDetails> titleDetailsDict;
        public Dictionary<string, bool> firstLoadDict;
        public Dictionary<string, List<InventoryItem>> inventoryDict;
        public Dictionary<string, int> timeDict;

        public int playerMoney;

        // NPC
        public string targetScene;
        public bool interactive;
        public int animationInstanceID;
    }
}