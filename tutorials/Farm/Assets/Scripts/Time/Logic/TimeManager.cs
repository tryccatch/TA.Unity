using System;
using UnityEngine;

public class TimeManager : Singleton<TimeManager>
{
    private int gameSecond, gameMinute, gameHour, gameDay, gameMonth, gameYear;
    private Season gameSeason = Season.春天;
    private int monthInSeason = 3;

    public bool gameClockPause;
    private float tikTime;

    // 灯光时间差
    private float timeDifference;

    public TimeSpan GameTime => new TimeSpan(gameHour, gameMinute, gameSecond);

    protected override void Awake()
    {
        base.Awake();
        NewGameTime();
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

    private void OnAfterSceneLoadedEvent()
    {
        gameClockPause = false;
    }

    private void OnBeforeSceneUnloadEvent()
    {
        gameClockPause = true;
    }

    private void Start()
    {
        EventHandler.CallGameMinuteEvent(gameMinute, gameHour, gameDay, gameSeason);
        EventHandler.CallGameDateEvent(gameHour, gameDay, gameMonth, gameYear, gameSeason);
        EventHandler.CallGameDayEvent(gameDay, gameSeason);
        EventHandler.CallLightShiftChangeEvent(gameSeason, GetCurrentLightShift(), timeDifference);
    }

    private void Update()
    {
        if (!gameClockPause)
        {
            tikTime += Time.deltaTime;

            if (tikTime >= Settings.secondThreshold)
            {
                tikTime -= Settings.secondThreshold;
                UpdateGamTime();
            }
        }

        if (Input.GetKey(KeyCode.T))
        {
            for (int i = 0; i < 60; i++)
            {
                UpdateGamTime();
            }
        }

        if (Input.GetKeyDown(KeyCode.G))
        {
            gameDay++;
            EventHandler.CallGameDayEvent(gameDay, gameSeason);
            EventHandler.CallGameDateEvent(gameHour, gameDay, gameMonth, gameYear, gameSeason);
        }
    }

    private void NewGameTime()
    {
        gameSecond = 0;
        gameMinute = 0;
        gameHour = 7;
        gameDay = 13;
        gameMonth = 10;
        gameYear = 2023;
        gameSeason = Season.春天;
    }

    private void UpdateGamTime()
    {
        gameSecond++;
        if (gameSecond > Settings.secondHold)
        {
            gameMinute++;
            gameSecond = 0;

            if (gameMinute > Settings.minuteHold)
            {
                gameHour++;
                gameMinute = 0;

                if (gameHour > Settings.hourHold)
                {
                    gameDay++;
                    gameHour = 0;

                    if (gameDay > Settings.dayHold)
                    {
                        gameMonth++;
                        gameDay = 1;

                        if (gameMonth > Settings.monthHold)
                            gameMonth = 1;

                        monthInSeason--;
                        if (monthInSeason == 0)
                        {
                            monthInSeason = 3;
                            int seasonNumber = (int)gameSeason;
                            seasonNumber++;

                            if (seasonNumber > Settings.seasonHold)
                            {
                                seasonNumber = 0;
                                gameYear++;
                            }

                            gameSeason = (Season)seasonNumber;

                            if (gameYear > 9999)
                            {
                                gameYear = 2023;
                            }
                        }
                    }
                    // 用来刷新地图和农作物相关
                    EventHandler.CallGameDayEvent(gameDay, gameSeason);
                }
                EventHandler.CallGameDateEvent(gameHour, gameDay, gameMonth, gameYear, gameSeason);
            }
            EventHandler.CallGameMinuteEvent(gameMinute, gameHour, gameDay, gameSeason);
            // 切换灯光
            EventHandler.CallLightShiftChangeEvent(gameSeason, GetCurrentLightShift(), timeDifference);
        }
        // Debug.Log("Second: " + gameSecond + " Minute: " + gameMinute + " Hour: " + gameHour + " Day: " + gameDay + " Month: " + gameMonth + " Year: " + gameYear + " Season: " + gameSeason);
    }

    // 返回LightShift同时计算时间差
    private LightShift GetCurrentLightShift()
    {
        if (GameTime >= Settings.morningTime && GameTime < Settings.nightTime)
        {
            timeDifference = Mathf.Abs((float)(GameTime - Settings.morningTime).TotalMinutes);
            return LightShift.Morning;
        }

        if (GameTime < Settings.morningTime || GameTime >= Settings.nightTime)
        {
            timeDifference = (float)(GameTime - Settings.nightTime).TotalMinutes;
            return LightShift.Night;
        }

        return LightShift.Morning;
    }
}