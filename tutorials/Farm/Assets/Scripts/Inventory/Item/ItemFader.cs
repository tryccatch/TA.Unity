using DG.Tweening;
using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class ItemFader : MonoBehaviour
{
    private SpriteRenderer spriteRenderer;
    private Tween tweenFadeIn;
    private Tween tweenFadeOut;


    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
    }

    /// <summary>
    /// 逐渐恢复颜色
    /// </summary>
    public void FadeIn()
    {
        Color targetColor = new(1, 1, 1, 1);
        tweenFadeIn = spriteRenderer.DOColor(targetColor, Settings.itemFadeDuration);
    }

    /// <summary>
    /// 逐渐半透明
    /// </summary>
    public void FadeOut()
    {
        Color targetColor = new(1, 1, 1, Settings.targetAlpha);
        tweenFadeOut = spriteRenderer.DOColor(targetColor, Settings.itemFadeDuration);
    }

    private void OnDestroy()
    {
        tweenFadeIn?.Kill();
        tweenFadeOut?.Kill();
    }
}