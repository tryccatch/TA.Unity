using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace ProjectBuild
{
    public class CfgParser
    {
        static string cfgPath = Application.dataPath + "/Editor Default Resources/channelConfig.csv";
        public static Dictionary<int, ChannelConfig> getChannelConfig()
        {
            var channelCfg = new Dictionary<int, ChannelConfig>();
            cfgPath = cfgPath.Replace("/", "\\");
            var reader = new CsvStreamReader(cfgPath, Encoding.UTF8);
            var types = new List<string>();
            var filedNames = new List<string>();
            for (int j = 1; j <= reader.ColCount; ++j)//列数
            {
                types.Add(reader[3, j]);
                filedNames.Add(reader[2, j]);
            }

            for (int i = 4; i <= reader.RowCount; ++i)//横着的
            {
                var item = new ChannelConfig();
                channelCfg.Add(i - 3, item);

                for (int j = 1; j <= reader.ColCount; j++)//竖着的
                {
                    parseData(types[j - 1], reader[i, j], item, filedNames[j - 1]);
                }

                //Debug.Log(item.ToString());
            }

            return channelCfg;
        }

        private static void parseData(string type, string data, ChannelConfig cfg, string filedName)
        {
            switch (type)
            {
                case "int":
                    int.TryParse(data, out int result);
                    setPropertyValue(cfg, filedName, result);
                    break;
                case "string":
                    setPropertyValue(cfg, filedName, data);
                    break;
                case "list<string>":
                    var values = data.Split(',');
                    setPropertyValue(cfg, filedName, values);
                    break;
                default:
                    Debug.LogError("Unsupport type in channelCfg:" + type);
                    break;
            }
        }

        private static void setPropertyValue<T>(ChannelConfig cfg, string filedName, T data)
        {
            Type t = cfg.GetType();
            var propertyInfo = t.GetField(filedName);
            propertyInfo.SetValue(cfg, data);
        }
    }
}
