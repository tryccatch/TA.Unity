using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// 下载器 工具类
/// </summary>
public class Downloader : Singleton<Downloader>
{
    public async Task<bool> Download(ModuleConfig moduleConfig)
    {
        UnityWebRequest request = UnityWebRequest.Get("test_url");

        await request.SendWebRequest();

        if (string.IsNullOrEmpty(request.error) == true)
        {
            return true;
        }

        return false;
    }
}