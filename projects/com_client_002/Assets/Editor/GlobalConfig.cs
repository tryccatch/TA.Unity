using UnityEngine;
using System.Collections;

public class GlobalConfig
{
#if GK
    public const int ClientVersionCode = 1;
    public const string ClientVersion = "1.0";
#elif H365
    public const int ClientVersionCode = 2;
    public const string ClientVersion = "1.1";
#endif
}