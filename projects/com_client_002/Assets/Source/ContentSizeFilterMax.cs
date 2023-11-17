using UnityEngine;
using UnityEngine.UI;
public class ContentSizeFilterMax : ContentSizeFitter
{
    public float maxWidth;
    public override void SetLayoutHorizontal()
    {
        var rect = transform as RectTransform;
        var size = LayoutUtility.GetPreferredSize(rect, 0);
        Debug.Log("preferred size：" + size);
        size = size > 100 ? 100 : size;
        
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, size);
        
            //    FitMode fitting = (axis == 0 ? horizontalFit : verticalFit);
            //    if (fitting == FitMode.Unconstrained)
            //    {
            //        // Keep a reference to the tracked transform, but don't control its properties:
            //        m_Tracker.Add(this, rectTransform, DrivenTransformProperties.None);
            //        return;
            //    }

            //    m_Tracker.Add(this, rectTransform, (axis == 0 ? DrivenTransformProperties.SizeDeltaX : DrivenTransformProperties.SizeDeltaY));

            //    // Set size to min or preferred size
            //    if (fitting == FitMode.MinSize)
            //        rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)axis, LayoutUtility.GetMinSize(m_Rect, axis));
            //    else
            //        rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)axis, LayoutUtility.GetPreferredSize(m_Rect, axis));
    }
}