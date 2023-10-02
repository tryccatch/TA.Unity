using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    Rigidbody2D rb;
    Collider2D coll;
    Animator anim;

    public float speed;
    Vector2 movement;

    [Header("背包系统")]
    public GameObject myBag;
    bool isOpen;

    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        coll = GetComponent<Collider2D>();
        anim = GetComponent<Animator>();
#if UNITY_EDITOR
        Application.targetFrameRate = 60;
#endif
    }

    private void Update()
    {
        Movement();
        SwitchAnim();
        OpenMyBag();
    }

    void Movement()//移动
    {
        movement.x = Input.GetAxisRaw("Horizontal");
        movement.y = Input.GetAxisRaw("Vertical");
        rb.MovePosition(rb.position + speed * Time.deltaTime * movement);

    }

    void SwitchAnim()//切换动画
    {
        if (movement != Vector2.zero)//保证Horizontal归0时，保留movement的值来切换idle动画的blend tree
        {
            anim.SetFloat("horizontal", movement.x);
            anim.SetFloat("vertical", movement.y);
        }
        anim.SetFloat("speed", movement.magnitude);//magnitude 也可以用 sqrMagnitude 具体可以参考Api 默认返回值永远>=0
    }

    void OpenMyBag()
    {
        if (Input.GetKeyDown(KeyCode.O))
        {
            isOpen = !isOpen;
            myBag.SetActive(isOpen);
            InventoryManager.RefreshItem();
        }
    }

    public void CloseMyBag()
    {
        isOpen = false;
        myBag.SetActive(isOpen);
    }
}