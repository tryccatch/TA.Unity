
using System;
using UnityEngine;

public static class EventHandler
{
    public static event Action<ItemDetails, int> UpdateUIEvent;
    public static void CallUpdateUIEvent(ItemDetails itemDetails, int index)
    {
        UpdateUIEvent?.Invoke(itemDetails, index);
    }

    public static event Action BeforeSceneUnloadEvent;
    public static void CallBeforeSceneUnloadEvent()
    {
        BeforeSceneUnloadEvent?.Invoke();
    }

    public static event Action AfterSceneLoadedEvent;
    public static void CallAfterSceneLoadedEvent()
    {
        AfterSceneLoadedEvent?.Invoke();
    }

    public static event Action<ItemDetails, bool> ItemSelectEvent;
    public static void CallItemSelectEvent(ItemDetails itemDetails, bool isSelected)
    {
        ItemSelectEvent?.Invoke(itemDetails, isSelected);
    }

    public static event Action<ItemName> ItemUseEvent;
    public static void CallItemUseEvent(ItemName itemName)
    {
        ItemUseEvent?.Invoke(itemName);
    }

    public static event Action<int> ChangeItemEvent;
    public static void CallChangeItemEvent(int index)
    {
        ChangeItemEvent?.Invoke(index);
    }

    public static event Action<string> ShowDialogueEvent;
    public static void CallShowDialogueEvent(string dialogue)
    {
        ShowDialogueEvent?.Invoke(dialogue);
    }

    public static event Action<GameState> GameStateChangeEvent;
    public static void CallGameStateChangeEvent(GameState gameState)
    {
        GameStateChangeEvent?.Invoke(gameState);
    }

    public static event Action CheckGameStateEvent;
    public static void CallCheckGameStateEvent()
    {
        CheckGameStateEvent?.Invoke();
    }

    public static event Action<string> GamePassEvent;
    public static void CallGamePassEvent(string gameName)
    {
        GamePassEvent?.Invoke(gameName);
    }

    public static event Action<int> StartNewGameEvent;
    public static void CallStartNewGameEvent(int gameWeek)
    {
        StartNewGameEvent?.Invoke(gameWeek);
    }
}