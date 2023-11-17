using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class Sound
{
    static AudioSource audio;           // 背景音乐  可控制声音大小
    static AudioSource audioOne;        // 音效 和 同时存在一条的音效
    static SoundHelper helper;
    static void Init()
    {
        if (audio == null)
        {
            audio = UIAPI.gNode.gameObject.AddComponent<AudioSource>();
            audioOne = UIAPI.gNode.gameObject.AddComponent<AudioSource>();

            helper = UIAPI.gNode.gameObject.AddComponent<SoundHelper>();

            if (isOn)
            {
                audio.volume = 1;
                audioOne.volume = 1;
            }
            else
            {
                audio.volume = 0;
                audioOne.volume = 0;
            }
        }
    }

    static bool isOn = true;

    static public void SetOn(bool value)
    {
        isOn = value;

        if (audio != null)
        {
            if (isOn)
            {
                audio.volume = 1;
                audioOne.volume = 1;
            }
            else
            {
                audio.volume = 0;
                audioOne.volume = 0;
            }
        }
    }
    static public bool GetVolume()
    {

        if (audio.volume == 0)
        {
            return false;
        }
        return true;

    }

    static public void PlayMusic(string res, bool isLoop = true, float value = 1.0f)
    {
        Init();

        var sound = ResTools.LoadSound(res);
        if (sound == null)
        {
            return;
        }

        if (audio.clip == sound && audio.isPlaying)
        {
            return;
        }

        audio.clip = sound as AudioClip;
        audio.Play();
        audio.loop = isLoop;

        if (isOn)
        {
            audio.volume = value;
        }
    }


    static public void Play(string res, float value = 1.0f)
    {
        Init();

        if (!isOn)
        {
            return;
        }

        var sound = ResTools.LoadSound(res);
        if (sound == null)
        {
            return;
        }

        audioOne.PlayOneShot(sound as AudioClip, value);
    }

    static public void PlayOne(string res, float value = 1.0f)
    {
        Init();

        if (res == "")
        {
            audioOne.Stop();
            return;
        }

        var sound = ResTools.LoadSound(res);
        if (sound == null)
        {
            return;
        }

        audioOne.Stop();
        audioOne.clip = sound as AudioClip;
        audioOne.Play();
        audioOne.loop = false;
        audioOne.volume = value;
    }

    static public void PlayGuide(string res, bool isLoop = true, float value = 1.0f)
    {
        Init();

        var sound = ResTools.LoadSound(res);
        if (sound == null)
        {
            return;
        }

        if (audioOne.clip == sound && audioOne.isPlaying)
        {
            return;
        }

        audioOne.clip = sound as AudioClip;
        audioOne.Play();
        audioOne.loop = isLoop;

        if (isOn)
        {
            audioOne.volume = value;
        }
    }

    static public void PlayWithBack(string res, LuaFunction callback, float value = 1.0f)
    {
        PlayOne(res, value);
        float time = audioOne.clip == null ? 1.0f : audioOne.clip.length;
        helper.OnPlay(callback, time);
    }

    static public void ChangeSoundVolume(string res,float value)
    {
        changeVolume(res, value, audioOne);
    }

    static public void ChangeMusicVolume(string res,float value)
    {
        changeVolume(res, value, audio);
    }

    private static void changeVolume(string res,float value,AudioSource source)
    {
        if (value > 1.0f)
            value = 1.0f;

        var resName = res.Split('/');
        if (resName != null && resName.Length > 0)
        {
            var key = resName[resName.Length - 1];
            if(source.isPlaying && source.clip.name == key)
            {
                source.volume = value;
            }
        }
    }
}
