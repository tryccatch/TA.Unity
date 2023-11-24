using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestGray : MonoBehaviour
{
    [SerializeField] private GameObject m_grayRoot;

    private void OnGUI()
    {
        if (GUILayout.Button("Set Gray"))
        {
            ShaderUtility.SetGray(m_grayRoot, true);
        }
        if (GUILayout.Button("Set Color"))
        {
            ShaderUtility.SetGray(m_grayRoot, false);

        }
    }
}