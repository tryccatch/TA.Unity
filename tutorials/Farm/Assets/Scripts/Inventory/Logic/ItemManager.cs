using UnityEngine;

namespace TA.Inventory
{
    public class ItemManager : MonoBehaviour
    {
        public Item itemPrefab;
        private Transform itemParent;
        private void OnEnable()
        {
            EventHandler.InstantiateItemInSceneEvent += OnInstantiateItemInScene;
            EventHandler.AfterSceneLoadedEvent += OnAfterSceneLoadedEvent;
        }

        private void OnDisable()
        {
            EventHandler.InstantiateItemInSceneEvent -= OnInstantiateItemInScene;
            EventHandler.AfterSceneLoadedEvent -= OnAfterSceneLoadedEvent;
        }

        private void OnAfterSceneLoadedEvent()
        {
            itemParent = GameObject.FindWithTag("ItemParent").transform;
        }

        /* 
        private void Start()
        {
            itemParent = GameObject.FindWithTag("ItemParent").transform;
        }
        // */

        private void OnInstantiateItemInScene(int ID, Vector3 pos)
        {
            var item = Instantiate(itemPrefab, pos, Quaternion.identity, itemParent);
            item.itemID = ID;
        }
    }
}