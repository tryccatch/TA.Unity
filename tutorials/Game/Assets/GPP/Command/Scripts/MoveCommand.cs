using UnityEngine;

public class MoveForward : Command
{
    private GameObject _player;
    public override void Execute(GameObject player)
    {
        _player = player;
        _player.transform.Translate(Vector3.forward);
        CommandManager.Instance.AddCommand(this);
    }

    public override void Undo()
    {
        _player.transform.Translate(Vector3.back);
    }
}

public class MoveLeft : Command
{
    private GameObject _player;
    public override void Execute(GameObject player)
    {
        _player = player;
        _player.transform.Translate(Vector3.left);
        CommandManager.Instance.AddCommand(this);
    }

    public override void Undo()
    {
        _player.transform.Translate(Vector3.right);
    }
}

public class MoveRight : Command
{
    private GameObject _player;
    public override void Execute(GameObject player)
    {
        _player = player;
        _player.transform.Translate(Vector3.right);
        CommandManager.Instance.AddCommand(this);
    }

    public override void Undo()
    {
        _player.transform.Translate(Vector3.left);
    }
}

public class MoveBack : Command
{
    private GameObject _player;
    public override void Execute(GameObject player)
    {
        _player = player;
        _player.transform.Translate(Vector3.back);
        CommandManager.Instance.AddCommand(this);
    }

    public override void Undo()
    {
        _player.transform.Translate(Vector3.forward);
    }
}
