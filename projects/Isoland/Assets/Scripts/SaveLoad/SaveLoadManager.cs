using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using UnityEngine;

public class SaveLoadManager : Singleton<SaveLoadManager>
{
    private string jsonFolder;
    private List<ISaveable> saveableList = new();
    public Dictionary<string, GameSaveData> saveDataDict = new();
    protected override void Awake()
    {
        base.Awake();
        jsonFolder = Application.persistentDataPath + "/SAVE/";
    }

    private void OnEnable()
    {
        EventHandler.StartNewGameEvent += OnStartNewGamEvent;
    }

    private void OnDisable()
    {
        EventHandler.StartNewGameEvent -= OnStartNewGamEvent;
    }

    private void OnStartNewGamEvent(int obj)
    {
        var resultPath = jsonFolder + "data.sav";
        if (File.Exists(resultPath))
            File.Delete(resultPath);

    }

    public void Register(ISaveable saveable)
    {
        saveableList.Add(saveable);
    }

    public void Save()
    {
        saveDataDict.Clear();

        foreach (var saveable in saveableList)
        {
            saveDataDict.Add(saveable.GetType().Name, saveable.GenerateSaveData());
        }

        var resultPath = jsonFolder + "data.sav";

        var jsonData = JsonConvert.SerializeObject(saveDataDict, Formatting.Indented);

        if (!File.Exists(resultPath))
        {
            Directory.CreateDirectory(jsonFolder);
        }

        File.WriteAllText(resultPath, jsonData);
    }

    public void Load()
    {
        var resultPath = jsonFolder + "data.sav";

        if (!File.Exists(resultPath)) return;

        var stringData = File.ReadAllText(resultPath);

        var jsonData = JsonConvert.DeserializeObject<Dictionary<string, GameSaveData>>(stringData);

        foreach (var saveable in saveableList)
        {
            saveable.RestoreGameData(jsonData[saveable.GetType().Name]);
        }
    }
}