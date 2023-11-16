using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CommandManager : Singleton<CommandManager>
{
    private Stack<Command> commands = new Stack<Command>();

    public void AddCommand(Command command)
    {
        commands.Push(command);
    }

    public IEnumerator UndoCommand()
    {
        while (commands.Count > 0)
        {
            var command = commands.Pop();
            command.Undo();

            yield return new WaitForSeconds(0.3f);
        }

        commands.Clear();
    }
}