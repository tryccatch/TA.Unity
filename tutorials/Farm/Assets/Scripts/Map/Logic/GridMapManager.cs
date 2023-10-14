using System.Collections.Generic;
using UnityEngine;

public class GridMapManager : MonoBehaviour
{
    [Header("地图信息")]
    public List<MapData_SO> mapDataList;

    private Dictionary<string, TileDetails> tileDetailsDict = new Dictionary<string, TileDetails>();

    private void Start()
    {
        foreach (var mapData in mapDataList)
        {
            InitTileDetailsDict(mapData);
        }
    }

    private void InitTileDetailsDict(MapData_SO mapData)
    {
        foreach (TileProperty tileProperty in mapData.tileProperties)
        {
            TileDetails tileDetails = new TileDetails
            {
                gridX = tileProperty.tileCoordinate.x,
                gridY = tileProperty.tileCoordinate.y,
            };

            // 字典的key
            string key = tileDetails.gridX + "x" + tileDetails.gridY + "y" + mapData.sceneName;

            if (GetTileDetails(key) != null)
            {
                tileDetails = GetTileDetails(key);
            }

            switch (tileProperty.gridType)
            {
                case GridType.Diggable:
                    tileDetails.canDig = tileProperty.boolTypeValue;
                    break;
                case GridType.DropItem:
                    tileDetails.canDropItem = tileProperty.boolTypeValue;
                    break;
                case GridType.PlaceFurniture:
                    tileDetails.canPlaceFurniture = tileProperty.boolTypeValue;
                    break;
                case GridType.NPCObstacle:
                    tileDetails.isNPCObstacle = tileProperty.boolTypeValue;
                    break;
            }

            if (GetTileDetails(key) != null)
                tileDetailsDict[key] = tileDetails;
            else
                tileDetailsDict.Add(key, tileDetails);
        }
    }

    /// <summary>
    /// 根据key返回瓦片信息
    /// </summary>
    /// <param name="key">x+y+地图名字</param>
    /// <returns></returns>
    private TileDetails GetTileDetails(string key)
    {
        if (tileDetailsDict.ContainsKey(key))
        {
            return tileDetailsDict[key];
        }
        return null;
    }
}