using System.Collections.Generic;
using UnityEngine;

public class Holder : Interactive
{
    public BallName matchBall;
    private Ball currentBall;
    public HashSet<Holder> linkHolders = new HashSet<Holder>();
    public bool isEmpty;

    public void CheckBall(Ball ball)
    {
        currentBall = ball;
        if (ball.ballDetails.ballName == matchBall)
        {
            currentBall.isMatch = true;
            currentBall.SetRight();
        }
        else
        {
            currentBall.isMatch = false;
            currentBall.SetWrong();
        }
    }

    public override void EmptyClick()
    {
        foreach (var holder in linkHolders)
        {
            if (holder.isEmpty)
            {
                //移动球
                currentBall.transform.position = holder.transform.position;
                currentBall.transform.SetParent(holder.transform);

                holder.CheckBall(currentBall);
                currentBall = null;

                // 改变状态
                isEmpty = true;
                holder.isEmpty = false;

                EventHandler.CallCheckGameStateEvent();
            }
        }
    }
}