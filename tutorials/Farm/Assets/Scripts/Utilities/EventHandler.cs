using System;
using System.Collections.Generic;
using TA.Dialogue;
using UnityEngine;

public static class EventHandler
{
    public static event Action<InventoryLocation, List<InventoryItem>> UpdateInventoryUIEvent;
    public static void CallUpdateInventoryUIEvent(InventoryLocation location, List<InventoryItem> list)
    {
        UpdateInventoryUIEvent?.Invoke(location, list);
    }

    public static event Action<int, Vector3> InstantiateItemInSceneEvent;
    public static void CallInstantiateItemInSceneEvent(int ID, Vector3 pos)
    {
        InstantiateItemInSceneEvent?.Invoke(ID, pos);
    }

    public static event Action<int, Vector3, ItemType> DropItemEvent;
    public static void CallDropItemEvent(int ID, Vector3 pos, ItemType itemType)
    {
        DropItemEvent?.Invoke(ID, pos, itemType);
    }

    public static event Action<ItemDetails, bool> ItemSelectedEvent;
    public static void CallItemSelectedEvent(ItemDetails itemDetails, bool isSelected)
    {
        ItemSelectedEvent?.Invoke(itemDetails, isSelected);
    }

    public static event Action<int, int, int, Season> GameMinuteEvent;
    public static void CallGameMinuteEvent(int minute, int hour, int day, Season season)
    {
        GameMinuteEvent?.Invoke(minute, hour, day, season);
    }

    public static event Action<int, Season> GameDayEvent;
    public static void CallGameDayEvent(int day, Season season)
    {
        GameDayEvent?.Invoke(day, season);
    }

    public static event Action<int, int, int, int, Season> GameDateEvent;
    public static void CallGameDateEvent(int hour, int day, int month, int year, Season season)
    {
        GameDateEvent?.Invoke(hour, day, month, year, season);
    }

    public static event Action<string, Vector3> TransitionEvent;
    public static void CallTransitionEvent(string sceneName, Vector3 pos)
    {
        TransitionEvent?.Invoke(sceneName, pos);
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

    public static event Action<Vector3> MoveToPositionEvent;
    public static void CallMoveToPositionEvent(Vector3 targetPosition)
    {
        MoveToPositionEvent?.Invoke(targetPosition);
    }

    public static event Action<Vector3, ItemDetails> MouseClickedEvent;
    public static void CallMouseClickedEvent(Vector3 pos, ItemDetails itemDetails)
    {
        MouseClickedEvent?.Invoke(pos, itemDetails);
    }

    public static event Action<Vector3, ItemDetails> ExecuteActionAfterAnimation;
    public static void CallExecuteActionAfterAnimation(Vector3 pos, ItemDetails itemDetails)
    {
        ExecuteActionAfterAnimation?.Invoke(pos, itemDetails);
    }

    public static event Action<int, TileDetails> PlantSeedEvent;
    public static void CallPlantSeedEvent(int ID, TileDetails tileDetails)
    {
        PlantSeedEvent?.Invoke(ID, tileDetails);
    }

    public static event Action<int> HarvestAtPlayerPosition;
    public static void CallHarvestAtPlayerPosition(int ID)
    {
        HarvestAtPlayerPosition?.Invoke(ID);
    }

    public static event Action RefreshCurrentMap;
    public static void CallRefreshCurrentMap()
    {
        RefreshCurrentMap?.Invoke();
    }

    public static event Action<ParticleEffectType, Vector2> ParticleEffectEvent;
    public static void CallParticleEffectEvent(ParticleEffectType effectType, Vector2 pos)
    {
        ParticleEffectEvent?.Invoke(effectType, pos);
    }

    public static event Action GenerateCropEvent;
    public static void CallGenerateCropEvent()
    {
        GenerateCropEvent?.Invoke();
    }

    public static event Action<DialoguePiece> ShowDialogueEvent;
    public static void CallShowDialogueEvent(DialoguePiece piece)
    {
        ShowDialogueEvent?.Invoke(piece);
    }
}