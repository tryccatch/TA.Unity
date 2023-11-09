using UnityEngine;

public class AnimationEvent : MonoBehaviour
{
    public void FootstepSoftSound()
    {
        EventHandler.CallPlaySoundEvent(SoundName.FootStepSoft);
    }

    public void FootstepHardSound()
    {
        EventHandler.CallPlaySoundEvent(SoundName.FootStepHard);
    }
}