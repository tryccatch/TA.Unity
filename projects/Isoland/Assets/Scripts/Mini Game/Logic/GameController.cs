using UnityEngine;
using UnityEngine.Events;

public class GameController : Singleton<GameController>
{
    public UnityEvent OnFinish;

    [Header("游戏数据")]
    public GameH2A_SO gameData;
    public GameH2A_SO[] gameDataArray;
    public GameObject lineParent;
    public LineRenderer linePrefab;
    public Ball ballPrefab;

    public Transform[] holderTransforms;

    private void OnEnable()
    {
        EventHandler.CheckGameStateEvent += OnCheckGameStateEvent;
    }

    private void OnDisable()
    {
        EventHandler.CheckGameStateEvent -= OnCheckGameStateEvent;
    }

    private void Start()
    {
        // DrawLine();
        // CreateBall();
    }
    private void OnCheckGameStateEvent()
    {
        foreach (var ball in FindObjectsOfType<Ball>())
        {
            if (!ball.isMatch)
            {
                return;
            }
        }

        Debug.Log("Game Over");
        foreach (var holder in holderTransforms)
        {
            holder.GetComponent<Collider2D>().enabled = false;
        }
        EventHandler.CallGamePassEvent(gameData.gameName);
        OnFinish?.Invoke();
    }

    public void ResetGame()
    {
        /* 
        for (int i = 0; i < lineParent.transform.childCount; i++)
        {
            Destroy(lineParent.transform.GetChild(i).gameObject);
        }
        DrawLine();
        // */

        foreach (var holder in holderTransforms)
        {
            if (holder.childCount > 0)
                Destroy(holder.GetChild(0).gameObject);
        }

        CreateBall();
    }

    public void DrawLine()
    {
        foreach (var connections in gameData.lineConnections)
        {
            var line = Instantiate(linePrefab, lineParent.transform);
            line.SetPosition(0, holderTransforms[connections.from].position);
            line.SetPosition(1, holderTransforms[connections.to].position);

            // 创建每个Holder的连线数据
            holderTransforms[connections.from].GetComponent<Holder>().linkHolders.Add(holderTransforms[connections.to].GetComponent<Holder>());
            holderTransforms[connections.to].GetComponent<Holder>().linkHolders.Add(holderTransforms[connections.from].GetComponent<Holder>());
        }
    }

    public void CreateBall()
    {
        for (int i = 0; i < gameData.startBallOrder.Count; i++)
        {
            if (gameData.startBallOrder[i] == BallName.None)
            {
                holderTransforms[i].GetComponent<Holder>().isEmpty = true;
                continue;
            }
            Ball ball = Instantiate(ballPrefab, holderTransforms[i]);

            holderTransforms[i].GetComponent<Holder>().CheckBall(ball);
            holderTransforms[i].GetComponent<Holder>().isEmpty = false;
            ball.SetupBall(gameData.GetBallDetails(gameData.startBallOrder[i]));
        }
    }

    public void SetGameWeekData(int week)
    {
        gameData = gameDataArray[week];
        DrawLine();
        CreateBall();
    }
}