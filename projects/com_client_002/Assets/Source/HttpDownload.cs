using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;

public class HttpDownload : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public delegate void UpdateFun(int process,byte[] datas);



    public void StartDownload(string url,UpdateFun fun)
    {
        StartCoroutine(DownloadFile(url, fun));

    }

    public void StartDownload(string url, string file, UpdateFun fun)
    {
        StartCoroutine(DownloadFileTo(url, file, fun));

    }

    IEnumerator DownloadFile(string url,UpdateFun fun)
    {
        using (UnityWebRequest webRequest = UnityWebRequest.Get(url))
        {
            yield return webRequest.SendWebRequest();
            if (webRequest.isNetworkError)
            {
                Debug.LogError(webRequest.error);
                fun(-1, null);
            }
            else
            {
                DownloadHandler fileHandler = webRequest.downloadHandler;
                using (MemoryStream memory = new MemoryStream(fileHandler.data))
                {
                    byte[] buffer = new byte[1024 * 1024];

                    int pos = 0;
                    int readBytes = 0;
                    while ((readBytes = memory.Read(buffer, pos, buffer.Length - pos)) > 0)
                    {
                        pos += readBytes;

                        if (pos >= buffer.Length) break;
                    }

                    var ret = new byte[pos];
                    System.Array.Copy(buffer, ret, pos);

                    fun(100, ret);
                }
            }
        }
    }

    IEnumerator DownloadFileTo(string url, string downloadFileName, UpdateFun fun)
    {
        using (UnityWebRequest downloader = UnityWebRequest.Get(url))
        {
            downloader.downloadHandler = new DownloadHandlerFile(Path.Combine(Application.persistentDataPath,downloadFileName));

            downloader.SendWebRequest();

            while (!downloader.isDone)
            {
                var value = (int)(downloader.downloadProgress * 100);
                if (value >= 100) value = 99;
                fun(value, null);
                yield return null;
            }

            if (downloader.error != null)
            {
                fun(-1, null);
            }
            else
            {
                fun(100, null);
            }
        }
    }
}
