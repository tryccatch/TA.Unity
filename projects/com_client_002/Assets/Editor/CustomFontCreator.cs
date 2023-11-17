using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEditor;
 
public class CustomFontCreator : EditorWindow
{
    float m_TileWidth;
    float m_TileHeight;
    float m_TileMaxY;
    string m_Key = "0123456789";
    bool m_UseFontTxt;
 
    [MenuItem("Tools/CustomFontCreator")]
    static void Init()
    {
        var window = (CustomFontCreator)EditorWindow.GetWindow(typeof(CustomFontCreator));
        window.Show();
    }
 
    void OnGUI()
    {
        var tex = Selection.activeObject as Texture;
        if (tex == null)
        {
            EditorGUILayout.LabelField("请选择一张字体贴图");
        }
        else
        {   
            var texWidth = tex.width;
            var texHeith = tex.height;
            EditorGUILayout.BeginVertical();
            if (!m_UseFontTxt)
            {
                m_Key = EditorGUILayout.TextField("Keys", m_Key);
 
                if (m_TileWidth == 0 && m_Key.Length > 0)
                {
                    m_TileWidth = texWidth / m_Key.Length;
                }
                if (m_TileHeight == 0)
                {
                    m_TileHeight = texHeith;
                }
 
                EditorGUILayout.BeginHorizontal();
                var tileWidth = EditorGUILayout.FloatField("TileWidth", m_TileWidth);
                if (tileWidth != m_TileWidth)
                {
                    m_TileWidth = tileWidth;
                }
 
                var tileHeight = EditorGUILayout.FloatField("TileHeight", m_TileHeight);
                if (tileHeight != m_TileHeight)
                {
                    m_TileHeight = tileHeight;
                }
 
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                m_TileMaxY = EditorGUILayout.FloatField("TileMaxY", m_TileMaxY);
                EditorGUILayout.EndHorizontal();
            }
 
            m_UseFontTxt = EditorGUILayout.Toggle("UseFontTxt", m_UseFontTxt);
            if (m_UseFontTxt)
            {
                string tips = "建立一个texture同名txt文件，格式如下：\n碎图宽 碎图高 \n与图片对应数据" +
                              "\n例如：\n" +
                              "28 40 \n0123456789";
                string[] tipArr = tips.Split('\n');
                for (int i = 0; i < tipArr.Length; i++)
                {
                    EditorGUILayout.LabelField(tipArr[i]);
                }
            }
 
            if (GUILayout.Button("Create"))
            {
                CreateCustomFont();
            }
            EditorGUILayout.EndVertical();
        }
    }
 
    void OnSelectionChange()
    {
        m_TileWidth = m_TileHeight = m_TileMaxY = 0;
        this.Repaint();
    }
 
    void OnInspectorUpdate()
    {
        this.Repaint();
    }
 
 
    public void CreateCustomFont()
    {
        foreach (Object o in Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets))
        {
            Texture2D tex = o as Texture2D;
 
            if (!tex)
            {
                continue;
            }
            string AssetFile = AssetDatabase.GetAssetPath(o);
 
            //修改贴图导入方式
 
            TextureImporter texImporter = (TextureImporter)AssetImporter.GetAtPath(AssetFile);
            if (texImporter == null)
            {
                continue;
            }
 
            texImporter.textureType = TextureImporterType.Sprite;
            texImporter.textureCompression = TextureImporterCompression.Uncompressed;
 
            texImporter.SaveAndReimport();
 
            tex = (Texture2D)AssetDatabase.LoadAssetAtPath(AssetFile, typeof(Texture2D));
 
 
            string PathNameNotExt = AssetFile.Remove(AssetFile.LastIndexOf('.'));
 
            string FileNameNotExt = PathNameNotExt.Remove(0, PathNameNotExt.LastIndexOf('/') + 1);
 
            string MatPathName = PathNameNotExt + ".mat";
            string FontPathName = PathNameNotExt + ".fontsettings";
 
            float tileWidth = m_TileWidth;
            float tileHeight = m_TileHeight;
            float tileMaxY = m_TileMaxY;
            char[] keys = m_Key.ToCharArray();
 
            if (m_UseFontTxt)
            {
                string TextPathName = PathNameNotExt + ".txt";
                TextAsset text = (TextAsset)AssetDatabase.LoadAssetAtPath(TextPathName, typeof(TextAsset));
 
                if (text == null)
                {
                    continue;
                }
                int idx = text.text.IndexOf("\r\n");
                string wh = text.text.Substring(0, idx);
                string[] whs = wh.Split(' ');
                if (whs.Length != 2)
                {
                    Debug.LogError("TXT格式异常！！！");
                    continue;
                }
                tileWidth = System.Convert.ToInt32(whs[0]);
                tileHeight = System.Convert.ToInt32(whs[1]);
 
                keys = text.text.Substring(idx + 2).Trim().ToCharArray();
            }
 
            Material mat = (Material)AssetDatabase.LoadAssetAtPath(MatPathName, typeof(Material));
            if (mat == null)
            {
                //创建材质球
                mat = new Material(Shader.Find("UI/Default Font"));
                mat.SetTexture("_MainTex", tex);
                AssetDatabase.CreateAsset(mat, MatPathName);
            }
            else
            {
                mat.shader = Shader.Find("UI/Default Font");
                mat.SetTexture("_MainTex", tex);
            }
 
            Font font = (Font)AssetDatabase.LoadAssetAtPath(FontPathName, typeof(Font));
 
            if (font == null)
            {
                font = new Font(FileNameNotExt);
 
                AssetDatabase.CreateAsset(font, FontPathName);
            }
 
            font.material = mat;
 
            float texWidth = tex.width;
            float texHeight = tex.height;
 
            List<CharacterInfo> _list = new List<CharacterInfo>();
 
            float uvTileWidth = tileWidth / texWidth;
            float uvTileHeiht = tileHeight / texHeight;

            var x = 0;
            var y = (int)(texHeight / tileHeight) - 1;
            for (int i = 0; i < keys.Length; ++i)
            {
                CharacterInfo info = new CharacterInfo();
                info.index = (int)keys[i];
 
                info.uvBottomLeft = new Vector2(tileWidth * x / texWidth, y*uvTileHeiht);
                info.uvBottomRight = info.uvBottomLeft + new Vector2(uvTileWidth, 0);
                info.uvTopLeft = info.uvBottomLeft + new Vector2(0, uvTileHeiht);
                info.uvTopRight = info.uvBottomLeft + new Vector2(uvTileWidth, uvTileHeiht);
 
                info.minY = -(int)(tileHeight - tileMaxY);
                info.maxX = (int)tileWidth;
                info.maxY = (int)tileMaxY;
 
                info.advance = (int)tileWidth;
 
                _list.Add(info);

                x++;
                if (tileWidth * (x + 0.5) >= texWidth) {
                    y--;
                    x = 0;
                } 
            }
 
 
            font.characterInfo = _list.ToArray();
 
            AssetImporter importer = AssetImporter.GetAtPath(AssetFile);
            importer.SaveAndReimport();

            EditorUtility.SetDirty(font);
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}