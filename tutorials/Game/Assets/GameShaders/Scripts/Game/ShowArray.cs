using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShowArray : MonoBehaviour
{
    [Range(1, 10)][SerializeField] private float m_Spacing = 1;
    private void Update()
    {
        Sort();
    }

    private void Sort()
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            transform.GetChild(i).position = new Vector3(i * m_Spacing, 0, 0);
        }
    }
}