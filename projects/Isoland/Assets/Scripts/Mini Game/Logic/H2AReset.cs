using UnityEngine;
using DG.Tweening;

public class H2AReset : Interactive
{
    private Transform gearSprit;

    private void Awake()
    {
        gearSprit = transform.GetChild(0);
    }

    public override void EmptyClick()
    {
        // 重置游戏
        GameController.Instance.ResetGame();
        gearSprit.DOPunchRotation(Vector3.forward * 180, 1, 1, 0);
    }
}