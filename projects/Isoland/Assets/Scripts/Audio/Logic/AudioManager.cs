using UnityEngine;
using Unity.VisualScripting;

public class AudioManager : Singleton<AudioManager>
{
    public SceneAudioData_SO audioData;

    private AudioSource sceneAudioSource;

    public void PlaySceneAudio(string sceneName)
    {
        if (sceneAudioSource == null)
        {
            sceneAudioSource = transform.AddComponent<AudioSource>();
            sceneAudioSource.loop = true;
        }

        SceneAudios sceneAudio = audioData.GetSceneAudios(sceneName);

        if (sceneAudioSource.clip != sceneAudio.audioClip)
        {
            sceneAudioSource.volume = sceneAudio.volume;
            sceneAudioSource.clip = sceneAudio.audioClip;
            sceneAudioSource.Play();
        }
    }
}