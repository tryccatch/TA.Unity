using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using System.Text.RegularExpressions;
public static class StringTools
{
    public static int getStringLen(string value)
    {
        if (string.IsNullOrEmpty(value))
            return 0;
        else
        {

            int len = 0;
            byte[] b;

            for (int i = 0; i < value.Length; i++)
            {
                b = Encoding.Default.GetBytes(value.Substring(i, 1));
                if (b.Length > 1)
                    len += 2;
                else
                    len++;
            }

            return len;
        }
    }

    private static string pattern = "[\\[ \\] \\^ \\/ \\\\ \\-\\|_*×――(^)$%~!@#$…&%￥—+=<>《》{}【】!！（）.'??？:：•`·、。，；,;\"‘’“”-]";
    public static string RemoveSpecialCharacter(string hexData)
    {
        if (string.IsNullOrEmpty(hexData))
            return "";
        return Regex.Replace(hexData, pattern, "");
    }

    public static string SubString(string value, int limit)
    {
        if (string.IsNullOrEmpty(value) || limit <= 0)
            return value;
        else
        {
            int len = 0;
            byte[] b;

            for (int i = 0; i < value.Length; i++)
            {
                b = Encoding.Default.GetBytes(value.Substring(i, 1));
                if (b.Length > 1)
                    len += 2;
                else
                    len++;
                if (len >= limit)
                {
                    var index = len > limit ? i - 1 : i;
                    index = index < 0 ? 0 : index;
                    return value.Substring(0, index + 1);
                }
            }

            return value;

        }

    }

    public static int getStringLen(string value, int cLen)
    {
        if (string.IsNullOrEmpty(value))
            return 0;
        else
        {

            int len = 0;
            byte[] b;

            for (int i = 0; i < value.Length; i++)
            {
                b = Encoding.Default.GetBytes(value.Substring(i, 1));
                if (b.Length > 1)
                    len += cLen;
                else
                    len++;
            }

            return len;
        }
    }
    public static string SubString(string value, int limit, int cLen)
    {
        if (string.IsNullOrEmpty(value) || limit <= 0)
            return value;
        else
        {
            int len = 0;
            byte[] b;

            for (int i = 0; i < value.Length; i++)
            {
                b = Encoding.Default.GetBytes(value.Substring(i, 1));
                if (b.Length > 1)
                    len += cLen;
                else
                    len++;
                if (len >= limit)
                {
                    var index = len > limit ? i - 1 : i;
                    index = index < 0 ? 0 : index;
                    return value.Substring(0, index + 1);
                }
            }

            return value;

        }

    }
}
