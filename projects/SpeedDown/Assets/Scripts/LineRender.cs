using UnityEngine;

public class LineRender : MonoBehaviour
{
    LineRenderer line;
    public Transform startPoint;
    public Transform endPoint;

    private void Start()
    {
        line = GetComponent<LineRenderer>();
    }

    private void Update()
    {
        line.SetPosition(0, startPoint.position);
        line.SetPosition(1, endPoint.position);
    }
}