using System.Collections.Generic;
using UnityEngine;

public class Spawner : MonoBehaviour
{
    public List<GameObject> platforms = new();
    public float SpawnTime;
    public float countTime;
    private Vector3 spawnPosition;

    private void Update()
    {
        SpawnPlatform();
    }

    public void SpawnPlatform()
    {
        countTime += Time.deltaTime;
        spawnPosition = transform.position;
        spawnPosition.x = Random.Range(-4.0f, 4.0f);

        if (countTime >= SpawnTime)
        {
            CreatePlatform();
            countTime = 0;
        }
    }

    private void CreatePlatform()
    {
        int index = Random.Range(0, platforms.Count);
        int spikeNum = 0;
        if (index == 4)
        {
            spikeNum++;
        }
        if (spikeNum > 1)
        {
            countTime = SpawnTime;
            return;
        }
        Instantiate(platforms[index], spawnPosition, Quaternion.identity, transform);
    }
}