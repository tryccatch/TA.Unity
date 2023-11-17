namespace ProjectBuild
{
    public class ChannelConfig
    {
        public int id;
        public string channelName;
        public string channelSymbol;
        public string[] sdkPath;
        public string apkName;
        public string releasePath;
        public string appVer;
        public int appBundle;
        public string bundleName;
        public GameServerEnum serverType;
        public bool onlyBuildRes;
        public override string ToString()
        {
            var path = "";

            foreach (var str in sdkPath)
            {
                path += (str + "\n");
            }
            return string.Format("id:{0}, cName:{1}, cSymbol:{2}, sdkPath:{3}, apkName:{4}, releasePath:{5}, appVer:{6}, appBundle:{7},serverType:{8}",
                id, channelName, channelSymbol, path, apkName, releasePath, appVer, appBundle, serverType.ToString());
        }
    }
}
