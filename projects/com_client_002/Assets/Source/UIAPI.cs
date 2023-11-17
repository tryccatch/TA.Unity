using UnityEngine;
using XLua;
using DG.Tweening;
using UnityEngine.UI;

public class UIAPI
{
    // global node
    public static Transform gNode;

    public static void SetGlobalNode(Transform node)
    {
        Input.multiTouchEnabled = false;
        gNode = node;
    }

    public static void Show(Transform node)
    {
        if (node == null) return;
        node.gameObject.SetActive(true);
    }

    public static Transform Load(string res, Transform parent)
    {
        if (res.IndexOf("/") < 0)
        {
            res = "UI/" + res;
        }
        var prefab = ResTools.Load(res);
        if (prefab == null) return null;

        var obj = GameObject.Instantiate(prefab) as GameObject;
        obj.name = prefab.name;

        if (parent == null)
        {
            obj.transform.SetParent(gNode, false);
        }
        else
        {
            obj.transform.SetParent(parent, false);
        }

        return obj.transform;
    }

    public static void EnableAll(Transform node, bool value)
    {
        for (var i = 0; i < node.childCount; i++)
        {
            var child = node.GetChild(i);
            child.gameObject.SetActive(value);
        }
    }

    static public Transform Clone(Transform t)
    {
        GameObject obj = GameObject.Instantiate(t.gameObject, t.parent) as GameObject;

        obj.transform.localPosition = t.localPosition;
        obj.transform.localScale = t.localScale;

        return obj.transform;
    }

    static string getNotINdexName(string name)
    {
        var pos = name.Length - 1;

        while (pos > 0 && name[pos] >= '0' && name[pos] <= '9')
        {
            pos--;
        }

        if (pos == name.Length - 1)
        {
            return name;
        }

        return name.Substring(0, pos + 1);
    }

    // 克隆节点到n个
    static public void CloneChild(Transform t, int count, int startIndex, Transform c)
    {
        if (t == null)
        {
            Debug.Log("can't clone child cause parent is NULL!");
            return;
        }
        if (c == null)
        {
            Transform child = t.GetChild(0);

            for (int i = t.childCount; i < count; i++)
            {
                GameObject obj = GameObject.Instantiate(child.gameObject, t) as GameObject;

                //obj.transform.parent = t;

                obj.transform.localPosition = child.localPosition;
                obj.transform.localScale = child.localScale;

                obj.name = getNotINdexName(child.name) + i;
            }

            for (int i = 0; i < t.childCount; i++)
            {
                child = t.GetChild(i);
                if (i >= count)
                {
                    child.gameObject.SetActive(false);
                }
                else
                {
                    child.gameObject.SetActive(true);
                }
            }

        }
        else
        {
            Transform child = c.transform;

            for (int i = t.childCount; i < count + startIndex; i++)
            {
                GameObject obj = GameObject.Instantiate(child.gameObject, t) as GameObject;

                //obj.transform.parent = t;

                obj.transform.localPosition = child.localPosition;
                obj.transform.localScale = child.localScale;
            }

            for (int i = startIndex; i < t.childCount; i++)
            {
                child = t.GetChild(i);
                if (i >= count + startIndex)
                {
                    child.gameObject.SetActive(false);
                }
                else
                {
                    child.gameObject.SetActive(true);
                }
            }

        }
        //GridLayoutGroup g = t.GetComponent<GridLayoutGroup>();
    }

    static public void CloneChildLast(Transform t, int count, int lastIndex)
    {


        for (int i = t.childCount; i < count; i++)
        {
            var child = t.GetChild(i - lastIndex);
            GameObject obj = GameObject.Instantiate(child.gameObject, t) as GameObject;

            //obj.transform.parent = t;

            obj.transform.localPosition = child.localPosition;
            obj.transform.localScale = child.localScale;

            obj.name = getNotINdexName(child.name) + i;
        }

        for (int i = 0; i < t.childCount; i++)
        {
            var child = t.GetChild(i);
            if (i >= count)
            {
                child.gameObject.SetActive(false);
            }
            else
            {
                child.gameObject.SetActive(true);
            }
        }
    }

    static public void CloneNode(Transform t, Transform p)
    {
        GameObject obj = GameObject.Instantiate(t.gameObject, p) as GameObject;
    }


    public static void Destroy(Transform node)
    {
        //Debug.Log("destroy" + node.name);
        if (node == null) return;
        GameObject.Destroy(node.gameObject);
    }
    //public static void Destroy(Object obj,float f = 0)
    //{
    //    if (obj == null) return;
    //    GameObject.Destroy(obj, f);
    //}
    public static void AddUpdate(Transform node, LuaFunction fun)
    {
        if (node == null)
        {
            Debug.Log("AddUpdate node is null!");
        }
        var luaUpdate = node.gameObject.GetComponent<LuaUpdate>();
        if (luaUpdate != null)
        {
            luaUpdate.enabled = true;
        }
        else
        {
            luaUpdate = node.gameObject.AddComponent<LuaUpdate>();

        }
        luaUpdate.fun = fun;
    }

    public static void EnableUpdate(Transform node)
    {

        if (node == null)
        {
            Debug.Log("AddUpdate node is null!");
        }

        var luaUpdate = node.gameObject.GetComponent<LuaUpdate>();
        if (luaUpdate != null)
        {
            luaUpdate.enabled = false;
        }
    }

    public static void AddOnClick(Transform node, LuaFunction fun, bool multi)
    {

        if (node == null)
        {
            Debug.Log("AddUpdate node is null!");
        }

        if (multi)
        {
            var luaUpdate = node.gameObject.AddComponent<LuaOnClick>();
            luaUpdate.fun = fun;
        }
        else
        {
            var luaUpdate = node.gameObject.GetComponent<LuaOnClick>();
            if (luaUpdate == null)
            {
                luaUpdate = node.gameObject.AddComponent<LuaOnClick>();
            }
            luaUpdate.fun = fun;
        }
    }

    public static void AddOnValueChanged(Transform node, LuaFunction fun, bool multi)
    {

        if (node == null)
        {
            Debug.Log("AddUpdate node is null!");
        }

        var silder = node.gameObject.GetComponent<Slider>();
        if (silder == null) return;



        if (multi)
        {
            var luaUpdate = node.gameObject.AddComponent<LuaFunc>();
            luaUpdate.fun = fun;
            silder.onValueChanged.AddListener(luaUpdate.DoFun);
        }
        else
        {
            var luaUpdate = node.gameObject.GetComponent<LuaFunc>();
            if (luaUpdate == null)
            {
                luaUpdate = node.gameObject.AddComponent<LuaFunc>();
                silder.onValueChanged.AddListener(luaUpdate.DoFun);
            }
            luaUpdate.fun = fun;
        }

    }

    public static double Delay(Transform node, float time, LuaFunction fun)
    {
        var luaUpdate = node.gameObject.GetComponent<LuaDelayUpdate>();
        if (luaUpdate == null)
        {
            luaUpdate = node.gameObject.AddComponent<LuaDelayUpdate>();
        }

        return luaUpdate.AddDelay(time, fun);
    }

    public static void RemoveDelay(Transform node, double id)
    {
        var luaUpdate = node.gameObject.GetComponent<LuaDelayUpdate>();
        if (luaUpdate != null)
        {
            luaUpdate.RemoveDelay((long)id);
        }
    }


    public static void AddProccessUpdate(Transform node, double count, float time, LuaFunction fun, bool stopOther)
    {
        var luaUpdate = node.gameObject.GetComponent<LuaProccessUpdate>();
        if (luaUpdate == null)
        {
            luaUpdate = node.gameObject.AddComponent<LuaProccessUpdate>();
        }

        luaUpdate.AddUpdate(count, time, fun, stopOther);
    }

    public static void RemoveProcessUpdate(Transform node)
    {
        var luaUpdate = node.gameObject.GetComponent<LuaProccessUpdate>();
        if (luaUpdate != null)
        {
            luaUpdate.clearAll();
        }
    }

    public static void ClearAll()
    {
        for (int i = 0; i < gNode.childCount; i++)
        {
            GameObject.Destroy(gNode.GetChild(i).gameObject);
        }
        gNode.DetachChildren();
    }

    public static int GetChildIndex(Transform child)
    {
        var gNode = child.parent;
        for (int i = 0; i < gNode.childCount; i++)
        {
            if (gNode.GetChild(i) == child)
            {
                return i;
            }
        }
        return 0;
    }

    public static void AnimSlider(Transform node, float toValue)
    {
        var com = node.GetComponent<AnimSlider>();
        if (com == null)
        {
            com = node.gameObject.AddComponent<AnimSlider>();
        }

        //UnityEngine.Debug.Log(com);
        if (com != null)
        {
            //UnityEngine.Debug.Log(com.animationName);
            com.startAnim(toValue);
        }
    }

    public static void StopAnim(Transform node)
    {
        var com = node.GetComponent<DragonBones.UnityArmatureComponent>();
        //UnityEngine.Debug.Log(com);
        if (com != null)
        {
            //UnityEngine.Debug.Log(com.animationName);
            com.animation.Stop();
        }

        var frameAnim = node.GetComponent<FramePlayer>();
        if (frameAnim != null)
        {
            frameAnim.Stop();
        }

        var sAnims = node.GetComponentsInChildren<SAnim>();
        foreach (var sAnim in sAnims)
        {
            sAnim.Reset();
            sAnim.Stop();
        }
    }


    public static void PlayAnim(Transform node, string anim, bool loop)
    {
        var com = node.GetComponent<DragonBones.UnityArmatureComponent>();
        //UnityEngine.Debug.Log(com);
        if (com != null)
        {
            com.animationName = anim;
            //UnityEngine.Debug.Log(com.animationName);
            com.animation.Play();
        }

        var frameAnim = node.GetComponent<FramePlayer>();
        if (frameAnim != null)
        {
            frameAnim.Play(anim, loop);
        }

        var sAnims = node.GetComponentsInChildren<SAnim>();
        foreach (var sAnim in sAnims)
        {
            sAnim.Play();
        }
    }

    public static int GetAnimFrame(Transform node)
    {
        var frameAnim = node.GetComponent<FramePlayer>();
        if (frameAnim != null)
        {
            return frameAnim.GetAnimFrame();
        }
        return 0;
    }

    public static bool IsEndAnim(Transform node)
    {
        var frameAnim = node.GetComponent<FramePlayer>();
        if (frameAnim != null)
        {
            return frameAnim.IsEnd();
        }
        return true;
    }

    public static void ChangAnimSlot(Transform node, string res, string slot, string replaceName)
    {

        var anim = node.GetComponent<DragonBones.UnityArmatureComponent>();
        var s = anim.armature.GetSlot(slot);
        DragonBones.UnityFactory.factory.ReplaceSlotDisplay(res, anim.armatureName, slot, replaceName, s);
    }

    public static void SetRotation(Transform node, float x, float y, float z)
    {
        node.localEulerAngles = new Vector3(x, y, z);
    }

    public static void TweenAlpha(Transform node, float to, float time)
    {
        var com = node.GetComponent<Image>();
        if (com != null)
        {
            var r = com.color.r;
            var g = com.color.g;
            var b = com.color.b;

            DOTween.To(() => com.color.a, x =>
            {
                if (com != null) com.color = new Color(r, g, b, x);
            }, to, time);
        }

        var text = node.GetComponent<Text>();
        if (text != null)
        {
            var r = text.color.r;
            var g = text.color.g;
            var b = text.color.b;
            DOTween.To(() => text.color.a, x =>
            {
                if (text != null) text.color = new Color(r, g, b, x);
            }, to, time);
        }
    }

    public static void TweenAlphaAll(Transform node, float to, float time)
    {
        TweenAlpha(node, to, time);
        for (var i = 0; i < node.childCount; i++)
        {
            var child = node.GetChild(i);
            TweenAlphaAll(child, to, time);
        }
    }

    public static void TweenScale(Transform node, float to, float time)
    {
        DOTween.To(() => node.transform.localScale.x, x =>
        {
            if (node != null) node.transform.localScale = Vector3.one * x;
        }, to, time);
    }

    public static void TweenAddScale(Transform node, float to, float time)
    {
        DOTween.To(() => node.transform.localScale.x, x =>
        {
            if (node != null) node.transform.localScale = Vector3.one * x;
        }, to * node.transform.localScale.x, time);
    }

    public static void TweenProcessValue(Transform node, float value, float time)
    {
        var slider = node.transform.GetComponent<Slider>();
        DOTween.To(() => slider.value, v =>
        {
            if (node != null) slider.value = v;
        }, value, time);
    }


    public static void TweenPos(Transform node, Vector3 to, float time)
    {
        DOTween.To(() => node.transform.localPosition, x =>
        {
            if (node != null) node.transform.localPosition = x;
        }, to, time);
    }

    public static void TweenRotation(Transform node, Vector3 to, float time)
    {
        to += node.transform.localEulerAngles;
        DOTween.To(() => node.transform.localEulerAngles, x =>
        {
            if (node != null) node.transform.localEulerAngles = x;
        }, to, time);
    }

    public static void TweenNormalizePosition(ScrollRect rect, Vector2 endValue, float time)
    {
        DOTween.To(() => rect.normalizedPosition, x =>
        {
            if (rect != null) rect.normalizedPosition = x;
        }, endValue, time).SetAutoKill(true);
    }

    public static void TweenShake(Transform node, Vector3 power, float time, bool fadeOut)
    {
        node.transform.DOShakePosition(time, power, 10, 0, false, fadeOut);
    }

    public static void TweenShake(Transform node, Vector3 power, float time)
    {
        node.transform.DOShakePosition(time, power, 10, 50, true);
    }

    public static void TweenShake(Transform node, float power, float time)
    {
        node.transform.DOShakePosition(time, power, 10, 50, true);
    }


    public static void SetAlpha(Transform node, float alpha)
    {
        var com = node.GetComponent<Image>();
        if (com != null)
        {
            com.color = new Color(com.color.r, com.color.g, com.color.b, alpha);
        }

        var text = node.GetComponent<Text>();
        if (text != null)
        {
            text.color = new Color(text.color.r, text.color.g, text.color.b, alpha);
        }
    }

    public static void SetGray(Transform node)
    {
        if (node == null) return;

        ShaderChanger.Set(node, "Custom/UI-Gray");

        for (var i = 0; i < node.childCount; i++)
        {
            SetGray(node.GetChild(i));
        }
    }

    public static void ClearGray(Transform node)
    {
        if (node == null) return;

        ShaderChanger.Clear(node);

        for (var i = 0; i < node.childCount; i++)
        {
            ClearGray(node.GetChild(i));
        }
    }

    public static string GetResName(Transform node)
    {
        var r = node.GetComponent<UIConfig>();
        if (r != null)
        {
            var ret = r.resName;
            if (ret != null)
            {
                ret = ret.Trim();
                if (ret == "")
                {
                    ret = null;
                }
            }
            return ret;
        }

        return null;
    }


    // 取得克隆间隔
    public static int GetCloneLastCount(Transform node)
    {
        var r = node.GetComponent<UIConfig>();
        if (r != null)
        {
            return r.cloneChildLastCount;
        }

        return 1;
    }

    public static Transform GetNeedToChild(Transform node)
    {
        Transform ret = null;
        var r = node.GetComponent<UIConfig>();
        while (r != null && r.child != null)
        {
            ret = r.child;
            r = ret.GetComponent<UIConfig>();
        }

        return ret;
    }

    public static string GetDisType(Transform node)
    {
        string ret = "";
        var r = node.GetComponent<UIConfig>();
        if (r != null)
        {
            ret = r.disType.ToString();
        }
        return ret;
    }


    public static void ReplaceImage(Transform node1, Transform node2)
    {

        var img1 = node1.GetComponent<Image>();
        var img2 = node2.GetComponent<Image>();

        img1.sprite = img2.sprite;
    }
    public static void ToggleFun(Transform node, LuaFunction fun, Transform toggleGroup, bool callWhenFalse)
    {
        Toggle toggle = node.GetComponent<Toggle>();
        if (!toggle)
        {
            Debug.LogError("找不到toggle 组件:" + node.name);
        }
        if (toggleGroup == null)
        {
            ToggleGroup group = node.parent.GetComponent<ToggleGroup>() ? node.parent.GetComponent<ToggleGroup>() : null;
            if (group)
            {
                toggle.group = group;
            }
        }
        toggle.onValueChanged.RemoveAllListeners();
        LuaFunc luafun = node.gameObject.GetComponent<LuaFunc>() ?
            node.gameObject.GetComponent<LuaFunc>() : node.gameObject.AddComponent<LuaFunc>();

        luafun.fun = fun;
        if (callWhenFalse)
            toggle.onValueChanged.AddListener(luafun.DoFunBool);
        else
            toggle.onValueChanged.AddListener(luafun.DoFun);
    }
    public static void ToggleIsOn(Transform node)
    {
        node.GetComponent<Toggle>().isOn = true;
        node.GetComponent<Toggle>().onValueChanged?.Invoke(true);
    }
    public static void RawImage(Transform node1, string res, bool cache = true)
    {

        var img = ResTools.LoadImage(res, cache);
        if (img != null)
        {
            var raw = node1.GetComponent<RawImage>();
            if (raw == null)
            {
                Debug.Log("can't found <RawImage> in:" + node1.name);
            }
            else
            {
                raw.enabled = true;
                raw.texture = img;
            }
        }
        else
        {
            var raw = node1.GetComponent<RawImage>();
            if (raw == null)
            {
                if (res != "")
                {
                    Debug.Log("can't found <RawImage> in:" + node1.name);
                }
            }
            else
            {
                raw.enabled = false;
            }
        }
    }

    public static void RawImageResize(Transform node1, string res, bool cache = true)
    {

        var img = ResTools.LoadImage(res, cache);
        if (img != null)
        {
            var raw = node1.GetComponent<RawImage>();
            if (raw == null)
            {
                Debug.Log("can't found <RawImage> in:" + node1.name);
            }
            else
            {
                raw.enabled = true;
                raw.texture = img;
                var r = node1 as RectTransform;
                r.sizeDelta = new Vector2(img.width, img.height);
            }
        }
        else
        {
            var raw = node1.GetComponent<RawImage>();
            if (raw == null)
            {
                if (res != "")
                {
                    Debug.Log("can't found <RawImage> in:" + node1.name);
                }
            }
            else
            {
                raw.enabled = false;
            }
        }
    }


    public static void AddViewDragBottom(Transform node, LuaFunction fun)
    {
        if (node == null) return;

        var v = node.gameObject.GetComponent<ViewDragBottom>();
        if (v == null)
        {
            v = node.gameObject.AddComponent<ViewDragBottom>();
        }
        v.fun = fun;
    }

    public static void SetAsLastChild(Transform node)
    {
        node.SetAsLastSibling();
    }
    public static void SetScale(Transform node, float x)
    {
        node.localScale = new Vector3(x, x, x);
    }
    public static void SetScaleX(Transform node, float x)
    {
        node.localScale = new Vector3(x, node.localScale.y, node.localScale.z);
    }
    public static void SetScaleY(Transform node, float x)
    {
        node.localScale = new Vector3(node.localScale.x, x, node.localScale.z);
    }
    public static void SetScaleZ(Transform node, float x)
    {
        node.localScale = new Vector3(node.localScale.x, node.localScale.y, x);
    }
    public static void RefreshSVC(Transform node, bool value)
    {
        var rect = node.gameObject.GetComponent<RectTransform>();
        if (rect != null)
        {
            var vec = rect.transform.position;
            rect.anchoredPosition = Vector3.zero;
            Rect oldRect = rect.rect;
            LayoutRebuilder.ForceRebuildLayoutImmediate(rect);
            Rect newRect = rect.rect;
            if (oldRect != newRect)
            {
                LayoutRebuilder.ForceRebuildLayoutImmediate(rect);
            }
            if (value)
            {
                rect.transform.position = vec;
            }
        }
    }

    public static void MoveBottom(Transform node, float off, bool atonce)
    {
        if (node == null) return;
        var com = node.GetComponent<MoveBottom>();
        if (com == null) com = node.gameObject.AddComponent<MoveBottom>();

        com.downOffset = off;

        if (atonce)
        {
            com.ToBottom();
        }
        else
        {
            com.downBottom = true;
        }

    }

    public static void ScrollRectFun(Transform node, LuaFunction callback)
    {
        if (node == null || callback == null)
            return;
        var scrollRect = node.gameObject.GetComponent<ScrollRect>();
        if (scrollRect)
        {
            LuaFunc luafun = node.gameObject.GetComponent<LuaFunc>() ?
        node.gameObject.GetComponent<LuaFunc>() : node.gameObject.AddComponent<LuaFunc>();
            luafun.fun = callback;
            scrollRect.onValueChanged.RemoveAllListeners();
            scrollRect.onValueChanged.AddListener(luafun.DoFun);
        }
    }

    public static void OnEndDrag(Transform node, LuaFunction callback)
    {
        if (node == null || callback == null)
            return;
        var comp = node.GetComponent<OnEndDrag>();
        if (comp == null)
            comp = node.gameObject.AddComponent<OnEndDrag>();
        comp.SetDrag(callback);
    }

    public static bool ObjIsNull(Object obj)
    {
        return obj == null;
    }

    public static void copyToClipBoard(string value)
    {
        GUIUtility.systemCopyBuffer = value;
    }
}
