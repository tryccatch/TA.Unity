using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using System.IO;
using System.Text;

public static class SensitiveCheck
{
    static bool hasInit = false;
    static string[] sensitiveWordsArray = null;
    static string fileName = "SensitiveWords1.bytes";
    static char ReplaceValue = '*';
    static Dictionary<char, IList<string>> keyDict;

    public static void init()
    {
        if (hasInit)
            return;
        hasInit = !hasInit;
        var bytes = ResTools.ReadLuaBytes(fileName);
        var content = Encoding.UTF8.GetString(bytes);

        
        //Debug.Log(content);
        if (!string.IsNullOrEmpty(content))
        {
            content = content.Trim('\"');
            sensitiveWordsArray = content.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            keyDict = new Dictionary<char, IList<string>>();
            foreach (string s in sensitiveWordsArray)
            {
                if (string.IsNullOrEmpty(s))
                    continue;
                var t = s[0];
                var index = 0;
                while(t == '\"')
                {
                    t = s[++index];
                }
                if (keyDict.ContainsKey(t))
                    keyDict[t].Add(s.Trim(new char[] { '\r' }));
                else
                    keyDict.Add(t, new List<string> { s.Trim(new char[] { '\r' }) });
            }
        }
    }


    //判断一个字符串是否包含敏感词，包括含的话将其替换为*
    public static bool IsContainSensitiveWords(ref string text, out string SensitiveWords)
    {
        init();
        bool isFind = false;
        SensitiveWords = "";
        if (null == sensitiveWordsArray || string.IsNullOrEmpty(text))
            return isFind;

        int len = text.Length;
        StringBuilder sb = new StringBuilder(len);
        bool isOK = true;
        for (int i = 0; i < len; i++)
        {
            if (keyDict.ContainsKey(text[i]))
            {
                var list = keyDict[text[i]];
                foreach (string s in list)
                {
                    isOK = true;
                    int j = i;
                    foreach (char c in s)
                    {
                        if (j >= len || c != text[j++])
                        {
                            isOK = false;
                            break;
                        }
                    }
                    if (isOK)
                    {
                        SensitiveWords = s;
                        isFind = true;
                        i += s.Length - 1;
                        sb.Append(ReplaceValue, s.Length);
                        break;
                    }

                }
                if (!isOK)
                    sb.Append(text[i]);
            }
            else
                sb.Append(text[i]);
        }
        if (isFind)
            text = sb.ToString();

        return isFind;
    }
}
