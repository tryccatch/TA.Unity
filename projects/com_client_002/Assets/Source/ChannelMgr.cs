using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class ChannelMgr
{
    public static string channel;
    public static string channelDir;
    public static string channelPrefix;

    public static void init()
    {
#if GK
        channel = "GK";
        channelDir = "Channel_GK";
        channelPrefix = "channel_gk_";
#elif H365
        channel = "H365";
        channelDir = "Channel_H365";
        channelPrefix = "channel_h365_";
#elif JGG
        channel = "JGG";
        channelDir = "Channel_JGG";
        channelPrefix = "channel_jgg_";
#else
        channel = "ALL";
#endif
    }

    public static string getChannel()
    {
        return channel;
    }
}
