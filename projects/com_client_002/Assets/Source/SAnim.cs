using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class SAnim : MonoBehaviour {

    public enum Type
    {
        pos,
        scale,
        rotate,
        Color,
        Alpha,
        Light,
        AddColor,
		Color3D,
		Width,
		AddRotate,
    }

    public Type    type = Type.pos;
    public Vector3  param = Vector3.one;
    public AnimationCurve curve;
	public bool reset;
	public bool stop;
	public bool start;

    private float time = 0;
    private Vector3 oldCurverValue;
    private Material m;

	private bool playing = true;
	private Vector3 firstLocalEulerAngles;
	private Vector3 firstLocalPos;

    // Use this for initialization
    void Start () {
		firstLocalEulerAngles = transform.localEulerAngles;
		firstLocalPos = transform.localPosition;
        oldCurverValue = Vector3.zero;

        if (type == Type.Color3D)
        {
            Renderer t = GetComponent<Renderer>();

   
            if (t.material.HasProperty("_Color")) {
               var c = t.material.GetColor("_Color");
                param = new Vector3(c.r, c.g, c.b);
            }

            if (t.material.HasProperty("_TintColor"))
            {
                var c = t.material.GetColor("_TintColor");
                param = new Vector3(c.r, c.g, c.b);
            }

           
        }

        Update ();
    }

    public void Reset()
    {
		if (time > 0) {
			time = 0;
			oldCurverValue = Vector3.zero;
			transform.localScale = Vector3.one;
			transform.localEulerAngles = firstLocalEulerAngles;
			transform.localPosition = firstLocalPos;
			UpdateFun ();
		}
    }

	public void Stop () {
		playing = false;

		
	}

	public void Play () {
		playing = true;
	}

	// Update is called once per frame
	void Update () {

        if (reset)
        {
			Reset();
			reset = false;
        }

        if (stop)
        {
			Stop();
			stop = false;

        }

        if (start)
        {
			Play();
			start = false;
        }
		if (!playing) {
			return;
		}

        time += Time.deltaTime;
		UpdateFun ();
    }

	void UpdateFun()
	{		

		float v = 0;
		if (curve==null)
		{
			v = time;
		}
		else
		{
			v = curve.Evaluate(time);
		}

		Vector3 value = param * v;


		switch ( type )
		{
		case Type.pos:
			{

				transform.localPosition += value - oldCurverValue;
			}
			break;
		case Type.scale:
			{
				transform.localScale += value - oldCurverValue;
			}
			break;
		case Type.rotate:
			{
				transform.Rotate(value - oldCurverValue);
			}
			break;
		case Type.Color:
			{
				MaskableGraphic t = GetComponent<MaskableGraphic>();

				if (oldCurverValue == Vector3.zero)
				{
					oldCurverValue = new Vector3(t.color.r,t.color.g,t.color.b);
				}

				value = value + oldCurverValue * (1-v);
				t.color = new Color(value.x , value.y, value.z);

				value = oldCurverValue;
			}
			break;
		case Type.Color3D:
			{
				Renderer t = GetComponent<Renderer>();

                if (t.material.HasProperty("_Color"))
                {
                    t.material.SetColor("_Color", new Color(value.x, value.y, value.z));
                }

                if (t.material.HasProperty("_TintColor"))
                {
                    t.material.SetColor("_TintColor", new Color(value.x, value.y, value.z));
                }
			}
			break;
		case Type.Alpha:
			{
				MaskableGraphic t = GetComponent<MaskableGraphic>();
				t.CrossFadeAlpha(v, 0, false);
			}
			break;
		case Type.Light:
			{

				if ( m == null )
				{
					m = new Material(Shader.Find("aoe/ui_light"));

					Image t = GetComponent<Image>();
					t.material = m;
				}

				m.SetFloat("_Light", v);
			}
			break;
		case Type.AddColor:
			{

				if (m == null)
				{
					m = new Material(Shader.Find("aoe/ui_add"));


					MaskableGraphic t = GetComponent<MaskableGraphic>();
					if (t != null)
					{
						t.material = m;
						m.SetColor("_Color", new Color(value.x, value.y, value.z));
					}

				}

				m.SetFloat("_Light", v);
			}
			break;
		case Type.Width:
			{
				var t = transform as RectTransform;
				
				t.sizeDelta = new Vector2(value.x,t.sizeDelta.y);
                
			}
			break;	
		case Type.AddRotate:
			{
				transform.Rotate(Time.deltaTime * param);
			}
			break;
		}
		oldCurverValue = value;
	}

}
