using System;
using System.Collections;
using System.Collections.Generic;
using TA.AStar;
using UnityEngine;
using UnityEngine.SceneManagement;

[RequireComponent(typeof(Rigidbody2D))]
[RequireComponent(typeof(Animator))]
public class NPCMovement : MonoBehaviour
{
    public ScheduleDataList_SO scheduleData;
    private SortedSet<ScheduleDetails> scheduleSet;
    private ScheduleDetails currentSchedule;
    // 临时存储信息
    [SerializeField][SceneName] private string currentScene;
    private string targetScene;
    private Vector3Int currentGridPosition;
    private Vector3Int targetGridPosition;
    private Vector3Int nextGridPosition;
    private Vector3 nextWorldPosition;

    public string StartScene { set => currentScene = value; }

    [Header("移动属性")]
    public float normalSpeed = 2f;
    private float minSpeed = 1;
    private float maxSpeed = 3;
    private Vector2 dir;
    public bool isMoving;

    // Components
    private Rigidbody2D rb;
    private SpriteRenderer spriteRenderer;
    private BoxCollider2D coll;
    private Animator anim;
    private Grid grid;
    private Stack<MovementStep> movementSteps;

    private bool isInitialised;
    private bool npcMove;
    private bool sceneLoaded;

    private TimeSpan GameTime => TimeManager.Instance.GameTime;
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        coll = GetComponent<BoxCollider2D>();
        anim = GetComponent<Animator>();
        movementSteps = new Stack<MovementStep>();
    }

    private void OnEnable()
    {
        EventHandler.BeforeSceneUnloadEvent += OnBeforeSceneUnloadEvent;
        EventHandler.AfterSceneLoadedEvent += OnAfterSceneLoadedEvent;
    }

    private void OnDisable()
    {
        EventHandler.BeforeSceneUnloadEvent -= OnBeforeSceneUnloadEvent;
        EventHandler.AfterSceneLoadedEvent -= OnAfterSceneLoadedEvent;
    }

    private void FixedUpdate()
    {
        if (sceneLoaded)
            Movement();
    }

    private void OnBeforeSceneUnloadEvent()
    {
        sceneLoaded = false;
    }

    private void OnAfterSceneLoadedEvent()
    {
        grid = FindObjectOfType<Grid>();
        CheckVisible();

        if (!isInitialised)
        {
            InitNPC();
            isInitialised = true;
        }

        sceneLoaded = true;
    }

    private void CheckVisible()
    {
        if (currentScene == SceneManager.GetActiveScene().name)
            SetActiveInScene();
        else
            SetInactiveInScene();
    }

    private void InitNPC()
    {
        targetScene = currentScene;

        // 保持在当前坐标的网格中心
        currentGridPosition = grid.WorldToCell(transform.position);
        // transform.position = new Vector3(currentGridPosition.x + Settings.gridCellSize / 2f, currentGridPosition.y + Settings.gridCellSize / 2f, 0);
        transform.position = GetWorldPosition(currentGridPosition);

        targetGridPosition = currentGridPosition;
    }

    private void Movement()
    {
        if (!npcMove)
        {
            if (movementSteps.Count > 0)
            {
                MovementStep step = movementSteps.Pop();

                currentScene = step.sceneName;

                CheckVisible();

                nextGridPosition = (Vector3Int)step.gridCoordinate;

                TimeSpan stepTime = new TimeSpan(step.hour, step.minute, step.second);

                MoveToGridPosition(nextGridPosition, stepTime);
            }
        }
    }

    private void MoveToGridPosition(Vector3Int gridPos, TimeSpan stepTime)
    {
        StartCoroutine(MoveRoutine(gridPos, stepTime));
    }

    private IEnumerator MoveRoutine(Vector3Int gridPos, TimeSpan stepTime)
    {
        npcMove = true;
        nextWorldPosition = GetWorldPosition(gridPos);

        // 还有时间用来移动
        if (stepTime > GameTime)
        {
            // 用来移动的时间差，以秒为单位
            float timeToMove = (float)(stepTime.TotalSeconds - GameTime.TotalSeconds);
            // 实际移动距离
            float distance = Vector3.Distance(transform.position, nextWorldPosition);
            // 实际移动速度
            float speed = Mathf.Max(minSpeed, (distance / timeToMove / Settings.secondThreshold));

            if (speed < maxSpeed)
            {
                while (Vector3.Distance(transform.position, nextWorldPosition) > Settings.pixelSize)
                {
                    dir = (nextWorldPosition - transform.position).normalized;

                    Vector2 posOffset = new Vector2(dir.x * speed * Time.fixedDeltaTime, dir.y * speed * Time.fixedDeltaTime);
                    rb.MovePosition(rb.position + posOffset);
                    yield return new WaitForFixedUpdate();
                }
            }
        }
        // 如果时间已经到了就瞬移
        rb.position = nextWorldPosition;
        currentGridPosition = gridPos;
        nextGridPosition = currentGridPosition;

        npcMove = false;
    }

    /// <summary>
    /// 构建Schedule构建路径
    /// </summary>
    /// <param name="schedule"></param>
    public void BuildPath(ScheduleDetails schedule)
    {
        movementSteps.Clear();
        currentSchedule = schedule;

        if (schedule.targetScene == currentScene)
        {
            AStar.Instance.BuildPath(schedule.targetScene, (Vector2Int)currentGridPosition, schedule.targetGridPosition, movementSteps);
        }

        // TODO:跨场景移动
        if (movementSteps.Count > 1)
        {
            // 更新每一步对应的时间戳
            UpdateTimeOnPath();
        }
    }

    private void UpdateTimeOnPath()
    {
        MovementStep previousStep = null;

        TimeSpan currentGameTime = GameTime;

        foreach (MovementStep step in movementSteps)
        {
            if (previousStep == null)
                previousStep = step;

            step.hour = currentGameTime.Hours;
            step.minute = currentGameTime.Minutes;
            step.second = currentGameTime.Seconds;

            TimeSpan gridMovementStepTime;

            if (MoveInDiagonal(step, previousStep))
                gridMovementStepTime = new TimeSpan(0, 0, (int)(Settings.gridCellDiagonalSize / normalSpeed / Settings.secondThreshold));
            else
                gridMovementStepTime = new TimeSpan(0, 0, (int)(Settings.gridCellSize / normalSpeed / Settings.secondThreshold));

            // 累加获得下一步的时间戳
            currentGameTime = currentGameTime.Add(gridMovementStepTime);
            // 循环下一步
            previousStep = step;
        }
    }

    /// <summary>
    /// 判断是否走斜方向
    /// </summary>
    /// <param name="currentStep"></param>
    /// <param name="previousStep"></param>
    /// <returns></returns>
    private bool MoveInDiagonal(MovementStep currentStep, MovementStep previousStep)
    {
        return (currentStep.gridCoordinate.x != previousStep.gridCoordinate.x && currentStep.gridCoordinate.y != previousStep.gridCoordinate.y);
    }

    /// <summary>
    /// 网格坐标返回世界坐标中心点
    /// </summary>
    /// <param name="gridPos"></param>
    /// <returns></returns>
    private Vector3 GetWorldPosition(Vector3Int gridPos)
    {
        Vector3 worldPos = grid.CellToWorld(gridPos);
        return new Vector3(worldPos.x + Settings.gridCellSize / 2f, worldPos.y + Settings.gridCellSize / 2f);
    }

    #region 设置NPC显示情况
    private void SetActiveInScene()
    {
        spriteRenderer.enabled = true;
        coll.enabled = true;
        // TODO:影子
        // transform.GetChild(0).gameObject.SetActive(true);
    }

    private void SetInactiveInScene()
    {
        spriteRenderer.enabled = false;
        coll.enabled = false;
        // TODO:影子关闭
        // transform.GetChild(0).gameObject.SetActive(false);
    }
    #endregion
}