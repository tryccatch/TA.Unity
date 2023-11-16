using UnityEngine;

public class InputHandler : MonoBehaviour
{
    private readonly MoveForward moveForward = new MoveForward();
    private readonly MoveLeft moveLeft = new MoveLeft();
    private readonly MoveRight moveRight = new MoveRight();
    private readonly MoveBack moveBack = new MoveBack();

    private GameObject player;
    private KeyCode[] keyCodes;

    private void Start()
    {
        player = gameObject;
        keyCodes = new[] { KeyCode.W, KeyCode.A, KeyCode.S, KeyCode.D, KeyCode.B };
    }

    private void Update()
    {
        PlayerInputHandler();
    }

    private void PlayerInputHandler()
    {
        if (Input.GetKeyDown(keyCodes[0]))
        {
            moveForward.Execute(player);
        }

        if (Input.GetKeyDown(keyCodes[1]))
        {
            moveLeft.Execute(player);
        }

        if (Input.GetKeyDown(keyCodes[2]))
        {
            moveBack.Execute(player);
        }

        if (Input.GetKeyDown(keyCodes[3]))
        {
            moveRight.Execute(player);
        }

        if (Input.GetKeyDown(keyCodes[4]))
        {
            StartCoroutine(CommandManager.Instance.UndoCommand());
        }
    }
}