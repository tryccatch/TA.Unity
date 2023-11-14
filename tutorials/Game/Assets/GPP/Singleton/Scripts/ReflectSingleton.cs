using System;
using UnityEngine;

public class ReflectSingleton<T>
{
    private static T instance;

    static ReflectSingleton()
    {
        instance = (T)Activator.CreateInstance(typeof(T), true);
    }

    public static T Instance
    {
        get => instance;
    }
}