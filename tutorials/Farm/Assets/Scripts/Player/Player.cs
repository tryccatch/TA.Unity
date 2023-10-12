using UnityEngine;

public class Player : MonoBehaviour
{
    private Rigidbody2D rb;

    public float speed;
    private float inputX;
    private float inputY;

    private Vector2 movementInput;

    private Animator[] animators;
    private bool isMoving;

    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        animators = GetComponentsInChildren<Animator>();
    }

    private void Update()
    {
        PlayerInput();
        SwitchAnimation();
    }

    private void FixedUpdate()
    {
        Movement();
    }

    private void PlayerInput()
    {
        // if (inputY == 0)
        inputX = Input.GetAxisRaw("Horizontal");
        // if (inputX == 0)
        inputY = Input.GetAxisRaw("Vertical");

        if (inputX != 0 && inputY != 0)
        {
            inputX *= 0.6f;
            inputY *= 0.6f;
        }

        // 走路状态速度
        if (Input.GetKey(KeyCode.LeftShift))
        {
            inputX *= 0.5f;
            inputY *= 0.5f;
        }

        movementInput = new Vector2(inputX, inputY);

        isMoving = movementInput != Vector2.zero;
    }

    private void Movement()
    {
        rb.MovePosition(rb.position + speed * Time.deltaTime * movementInput);
    }

    private void SwitchAnimation()
    {
        foreach (var anim in animators)
        {
            anim.SetBool("isMoving", isMoving);
            if (isMoving)
            {
                anim.SetFloat("InputX", inputX);
                anim.SetFloat("InputY", inputY);
            }
        }
    }
}