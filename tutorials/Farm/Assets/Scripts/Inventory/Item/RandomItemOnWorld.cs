using TA.Inventory;
using UnityEngine;

public class RandomItemOnWorld : MonoBehaviour
{
    public int randomAmount;
    public Item itemBase;
    private void Awake()
    {
        RandomItem();
    }

    private void RandomItem()
    {
        for (int i = 0; i < randomAmount; i++)
        {
            var item = Instantiate(itemBase, transform);
            item.transform.position = new Vector2(Random.Range(-i, i), Random.Range(-i, i));
            item.itemID = 1000 + Random.Range(0, 18);
        }
    }
}