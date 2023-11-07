using System;
using UnityEngine;
using UnityEngine.UI;

namespace TA.Inventory
{
    public class TradeUI : MonoBehaviour
    {
        public Image itemIcon;
        public Text itemName;
        public InputField tradeAmount;
        public Button submitButton;
        public Button cancelButton;

        private ItemDetails item;
        private bool isSellTrade;

        private void Awake()
        {
            cancelButton.onClick.AddListener(CancelTrade);
            submitButton.onClick.AddListener(TradeItem);
        }

        public void SetupTradeUI(ItemDetails item, bool isSell)
        {
            this.item = item;
            itemIcon.sprite = item.itemIcon;
            itemName.text = item.itemName;
            isSellTrade = isSell;
            tradeAmount.text = string.Empty;
        }

        private void TradeItem()
        {
            // var amount = Convert.ToInt32(tradeAmount.text);
            int.TryParse(tradeAmount.text, out var amount);

            InventoryManager.Instance.TradeItem(item, amount, isSellTrade);

            CancelTrade();
        }

        private void CancelTrade()
        {
            this.gameObject.SetActive(false);
        }
    }
}