using TA.Inventory;
using UnityEngine;

[RequireComponent(typeof(SlotUI))]
public class ActionBarButton : MonoBehaviour
{
    public KeyCode key;
    private SlotUI slotUI;
    private bool canUse;
    private void Awake()
    {
        slotUI = GetComponent<SlotUI>();
        canUse = true;
    }

    private void OnEnable()
    {
        EventHandler.UpdateGameStateEvent += OnUpdateGameStateEvent;
    }

    private void OnDisable()
    {
        EventHandler.UpdateGameStateEvent -= OnUpdateGameStateEvent;
    }

    private void Update()
    {
        if (canUse && Input.GetKeyDown(key))
        {
            if (slotUI.itemDetails != null)
            {
                slotUI.isSelected = !slotUI.isSelected;
                if (slotUI.isSelected)
                    slotUI.inventoryUI.UpdateSlotHighlight(slotUI.slotIndex);
                else
                    slotUI.inventoryUI.UpdateSlotHighlight(-1);

                EventHandler.CallItemSelectedEvent(slotUI.itemDetails, slotUI.isSelected);
            }
        }
    }

    private void OnUpdateGameStateEvent(GameState gameState)
    {
        canUse = gameState == GameState.GamePlay;
    }
}