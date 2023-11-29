using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    private void Awake()
    {
        A a = new A();
        B b = new B();
        a.Fun2(b);  // 2    5
        b.Fun2(a);  // 1    6
        b.Fun3(4);  // 4
        a = b;
        a.Fun3(7);  // 7
    }
}

public class A
{
    public virtual void Fun1(int i)
    {
        Debug.Log(i);
    }
    public void Fun2(A a)
    {
        a.Fun1(1);
        Fun1(5);
    }
    public virtual void Fun3(int i)
    {
        Debug.Log(i + 1);
    }
}

public class B : A
{
    public override void Fun1(int i)
    {
        base.Fun1(i + 1);
    }
    public override void Fun3(int i)
    {
        Debug.Log(i);
    }
}