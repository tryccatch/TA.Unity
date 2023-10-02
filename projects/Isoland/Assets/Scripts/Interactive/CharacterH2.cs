using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(DialogueController))]
public class CharacterH2 : Interactive
{
    private DialogueController dialogueController;

    private void Awake()
    {
        dialogueController = GetComponent<DialogueController>();
    }

    public override void EmptyClick()
    {
        if (isDone)
            dialogueController.ShowDialogueFinish();
        else
            // 对话内容A
            dialogueController.ShowDialogueEmpty();
    }

    protected override void OnClickAction()
    {
        // 对话内容B
        dialogueController.ShowDialogueFinish();
    }
}