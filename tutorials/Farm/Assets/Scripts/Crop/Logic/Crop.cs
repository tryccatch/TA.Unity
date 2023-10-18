using System.Collections;
using UnityEngine;

public class Crop : MonoBehaviour
{
    public CropDetails cropDetails;
    public TileDetails tileDetails;
    private int harvestActionCount;
    public bool CanHarvest => tileDetails.growthDays >= cropDetails.TotalGrowthDays;
    private Animator anim;
    private Transform PlayerTransform => FindObjectOfType<Player>().transform;
    public void ProcessToolAction(ItemDetails tool, TileDetails tile)
    {
        tileDetails = tile;

        // 工具使用次数
        int requireActionCount = cropDetails.GetTotalRequireCount(tool.itemID);
        if (requireActionCount == -1) return;

        anim = GetComponentInChildren<Animator>();

        // 点击计数器
        if (harvestActionCount < requireActionCount)
        {
            harvestActionCount++;

            // 判断是否有动画 树木
            if (anim != null && cropDetails.hasAnimation)
            {
                if (PlayerTransform.position.x < transform.position.x)
                    anim.SetTrigger("RotateRight");
                else
                    anim.SetTrigger("RotateLeft");
            }

            // 播放粒子
            if (cropDetails.hasParticleEffect)
                EventHandler.CallParticleEffectEvent(cropDetails.effectType, transform.position + cropDetails.effectPos);
            // 播放声音
        }

        if (harvestActionCount >= requireActionCount)
        {
            if (cropDetails.generateAtPlayerPosition || !cropDetails.hasAnimation)
            {
                // 生成农作物
                SpawnHarvestItems();
            }
            else if (cropDetails.hasAnimation)
            {
                if (PlayerTransform.position.x < transform.position.x)
                    anim.SetTrigger("FallingRight");
                else
                    anim.SetTrigger("FallingLeft");

                StartCoroutine(HarvestAfterAnimation());
            }
        }
    }

    private IEnumerator HarvestAfterAnimation()
    {
        while (!anim.GetCurrentAnimatorStateInfo(0).IsName("End"))
        {
            yield return null;
        }

        SpawnHarvestItems();

        // 转换新物体
        if (cropDetails.transferItemID > 0)
        {
            CreateTransferItem();
        }
    }

    private void CreateTransferItem()
    {
        tileDetails.seedItemID = cropDetails.transferItemID;
        tileDetails.daysSinceLastHarvest = -1;
        tileDetails.growthDays = 0;

        EventHandler.CallRefreshCurrentMap();
    }

    /// <summary>
    /// 种子生成果实
    /// </summary>
    public void SpawnHarvestItems()
    {
        for (int i = 0; i < cropDetails.producedItemID.Length; i++)
        {
            int amountToProduce;

            if (cropDetails.producedMinAmount[i] == cropDetails.producedMaxAmount[i])
            {
                // 代表只生成指定数量的
                amountToProduce = cropDetails.producedMinAmount[i];
            }
            else    // 物品随机数量
            {
                amountToProduce = Random.Range(cropDetails.producedMinAmount[i], cropDetails.producedMaxAmount[i] + 1);
            }

            for (int j = 0; j < amountToProduce; j++)
            {
                if (cropDetails.generateAtPlayerPosition)
                {
                    EventHandler.CallHarvestAtPlayerPosition(cropDetails.producedItemID[i]);
                }
                else    // 世界地图上生成物品
                {
                    // 判断应该生成的物品方向
                    var dirX = transform.position.x > PlayerTransform.position.x ? 1 : -1;
                    // 一定范围内的随机
                    var spawnPos = new Vector3(transform.position.x + Random.Range(dirX, cropDetails.spawnRadius.x * dirX),
                                               transform.position.y + Random.Range(-cropDetails.spawnRadius.y, cropDetails.spawnRadius.y * dirX));
                    EventHandler.CallInstantiateItemInSceneEvent(cropDetails.producedItemID[i], spawnPos);
                }
            }

            if (tileDetails != null)
            {
                tileDetails.daysSinceLastHarvest++;

                // 是否可以重新生长
                if (cropDetails.daysToRegrow > 0 && tileDetails.daysSinceLastHarvest < cropDetails.regrowTimes)
                {
                    tileDetails.growthDays = cropDetails.TotalGrowthDays - cropDetails.daysToRegrow;
                    // 刷新种子
                    EventHandler.CallRefreshCurrentMap();
                }
                else    // 不可重复生长
                {
                    tileDetails.daysSinceLastHarvest = -1;
                    tileDetails.seedItemID = -1;

                    // FIXME:自己设计
                    tileDetails.daysSinceDug = -1;
                }

                Destroy(gameObject);
            }
        }
    }
}