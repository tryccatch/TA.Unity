using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;

public class GameSaveManager : MonoBehaviour
{
    public Inventory myInventory;
    private readonly string directory = "Data";
    private readonly string file = "myBag.txt";
    string directoryPath;
    string filePath;

    private void Awake()
    {
        directoryPath = Path.Combine(Application.persistentDataPath, directory);
        filePath = Path.Combine(directoryPath, file);
        Debug.Log(filePath);
    }

    public void SaveData()
    {
        if (!Directory.Exists(directoryPath))
        {
            Directory.CreateDirectory(directoryPath);
        }

        BinaryFormatter formatter = new();

        FileStream file = File.Create(filePath);

        var json = JsonUtility.ToJson(myInventory);

        formatter.Serialize(file, json);

        file.Close();
    }

    public void LoadData()
    {
        BinaryFormatter formatter = new();

        if (File.Exists(filePath))
        {
            FileStream file = File.Open(filePath, FileMode.Open);

            JsonUtility.FromJsonOverwrite((string)formatter.Deserialize(file), myInventory);

            file.Close();
        }
    }
}