using TA.Map;
using UnityEngine;

namespace TA.CropPlant
{
    public class CropGenerator : MonoBehaviour
    {
        private Grid currentGrid;

        [ItemID] public int seedItemID;
        public int growthDays;

        private void Awake()
        {
            currentGrid = FindObjectOfType<Grid>();
        }

        private void OnEnable()
        {
            EventHandler.GenerateCropEvent += GenerateCrop;
        }

        private void OnDisable()
        {
            EventHandler.GenerateCropEvent -= GenerateCrop;
        }

        private void GenerateCrop()
        {
            Vector3Int cropGridPos = currentGrid.WorldToCell(transform.position);

            if (seedItemID != 0)
            {
                var tile = GridMapManager.Instance.GetTileDetailsOnMousePosition(cropGridPos);

                if (tile == null)
                {
                    tile = new TileDetails
                    {
                        gridX = cropGridPos.x,
                        gridY = cropGridPos.y
                    };
                }

                tile.daysSinceDug = -1;
                tile.seedItemID = seedItemID;
                tile.growthDays = growthDays;

                GridMapManager.Instance.UpdateTileDetails(tile);
            }
        }
    }
}