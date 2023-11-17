using ProjectBuild;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;

public class ChangeChannel
{
    private static string[] channels = { "GK", "H365", "JGG" };

    [MenuItem("切换渠道/GK渠道")]
    static void toGK()
    {
        var oldDefines = RemoveAllChannelSymbol();
        AddChannelDefine(channels[0], oldDefines);
        ShowTip(channels[0]);
    }

    [MenuItem("切换渠道/H365渠道")]
    static void toH365()
    {
        var oldDefines = RemoveAllChannelSymbol();
        AddChannelDefine(channels[1], oldDefines);
        ShowTip(channels[1]);

    }

    [MenuItem("切换渠道/JGG渠道")]
    static void toJGG()
    {
        var oldDefines = RemoveAllChannelSymbol();
        AddChannelDefine(channels[2], oldDefines);
        ShowTip(channels[2]);

    }

    static void ShowTip(string channel)
    {
        EditorUtility.DisplayDialog("提示", "渠道已切换为：" + channel, "了解");
    }

    static string RemoveAllChannelSymbol()
    {
        string defines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);

        if (string.IsNullOrEmpty(defines))
            return "";
        else
        {
            var arr = defines.Split(';');
            foreach (var channel in channels)
            {
                for (var i = 0; i < arr.Length; ++i)
                {
                    if (arr[i] == channel)
                        arr[i] = null;
                }
            }

            var result = new StringBuilder();
            for (var i = 0; i < arr.Length; ++i)
            {
                if (arr[i] != null)
                {
                    result.Append(arr[i]);
                    result.Append(";");
                }
            }



            return result.ToString();
        }
    }

    static void AddChannelDefine(string channel, string oldDefines)
    {
        string newDefines;
        if (string.IsNullOrEmpty(oldDefines))
            newDefines = channel;
        else
        {
            newDefines = oldDefines + channel;
        }

        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, newDefines);

    }
}
