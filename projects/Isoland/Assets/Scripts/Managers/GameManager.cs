using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour, ISaveable
{
    private Dictionary<string, bool> miniGameStateDict = new Dictionary<string, bool>();
    private GameController currentGame;
    private int gameWeek;
    private void OnEnable()
    {
        EventHandler.AfterSceneLoadedEvent += OnAfterSceneLoadedEvent;
        EventHandler.GamePassEvent += OnGamePassEvent;
        EventHandler.StartNewGameEvent += OnStartNewGameEvent;
    }

    private void OnDisable()
    {
        EventHandler.AfterSceneLoadedEvent -= OnAfterSceneLoadedEvent;
        EventHandler.GamePassEvent -= OnGamePassEvent;
        EventHandler.StartNewGameEvent += OnStartNewGameEvent;
    }

    private void OnStartNewGameEvent(int gameWeek)
    {
        this.gameWeek = gameWeek;
        miniGameStateDict.Clear();
    }

    private void Start()
    {
        SceneManager.LoadScene("Menu", LoadSceneMode.Additive);

        AudioManager.Instance.PlaySceneAudio("Menu");

        // TransitionManager.Instance.Transition(string.Empty, "Menu");
        EventHandler.CallGameStateChangeEvent(GameState.GamePlay);

        // 保存数据
        ISaveable saveable = this;
        saveable.SaveableRegister();
    }

    private void OnAfterSceneLoadedEvent()
    {
        foreach (var miniGame in FindObjectsOfType<MiniGame>())
        {
            if (miniGameStateDict.TryGetValue(miniGame.gameName, out bool isPass))
            {
                miniGame.isPass = isPass;
                miniGame.UpdateMiniGameState();
            }
        }

        currentGame = FindObjectOfType<GameController>();

        currentGame?.SetGameWeekData(gameWeek);
    }

    private void OnGamePassEvent(string gameName)
    {
        miniGameStateDict[gameName] = true;
    }

    public GameSaveData GenerateSaveData()
    {
        GameSaveData saveData = new GameSaveData();
        saveData.gameWeek = gameWeek;
        saveData.miniGameStateDict = miniGameStateDict;
        return saveData;
    }

    public void RestoreGameData(GameSaveData saveData)
    {
        gameWeek = saveData.gameWeek;
        miniGameStateDict = saveData.miniGameStateDict;
    }
}