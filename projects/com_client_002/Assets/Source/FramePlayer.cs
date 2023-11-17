using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FramePlayer : MonoBehaviour
{

    public int frameRate = 10;
    public int offX = 0;
    public int offY = 0;
    public Image image;

    public string[] keys;

    Dictionary<string,int> startFrames;
    Dictionary<string,int> endFrames;

    public string curAnim;

    int frameIndex = 0;
    float time = 0;
    bool dirty = true;
    bool loop = true;

    Images images;

    void Awake()
    {
        startFrames = new Dictionary<string, int>();
        endFrames = new Dictionary<string, int>();

        

        if (keys != null) {
            var oldKey = "";
            for (var i=0; i<keys.Length; i++) {
                var key = keys[i];
                if (oldKey !=key) {
                    startFrames[key] = i;
                }
                endFrames[key] = i;

                oldKey = key;
            
            }
        }
    }

    // Start is called before the first frame update
    void Start()
    {        
    }

    // Update is called once per frame
    void Update()
    {        
        time += Time.deltaTime;
        if (time >= 1.0f / frameRate) {
            time -= 1.0f / frameRate;
            frameIndex++;
            dirty = true;

            if (images == null) {
                images = GetComponent<Images>();
            }

            var endFrame = images.datas.Length-1;
            var startFrame = 0;

            if (startFrames!=null && endFrames!=null) {
                if (curAnim != null && curAnim != "") {
                    if (startFrames.ContainsKey(curAnim) && endFrames.ContainsKey(curAnim)) {
                        startFrame = startFrames[curAnim];
                        endFrame = endFrames[curAnim];
                    }
                }
            }
            
            
            if (frameIndex > endFrame) {
                if (loop) {
                    frameIndex = startFrame;    
                } else {
                    frameIndex = endFrame;           
                }         
            }                        
        }
        UpdateFrame();
    }

    public void Play(string anim,bool loop) {
        if (startFrames.ContainsKey(anim) && endFrames.ContainsKey(anim)) {
            if (curAnim != anim) {
                this.loop = loop;
                curAnim = anim;
                time = 0;
                frameIndex = startFrames[curAnim];       
                UpdateFrame();
            }
        }
    }

    public void Stop() {
        
    }

    public int GetAnimFrame() {
        var startFrame = 0;

        if (startFrames!=null) {
            if (curAnim != null && curAnim != "") {
                if (startFrames.ContainsKey(curAnim)) {
                    startFrame = startFrames[curAnim]; 
                }
            }
        }
        return (frameIndex - startFrame);    
    }

    public bool IsEnd() {
        var endFrame = images.datas.Length-1;

        if (endFrames!=null) {
            if (curAnim != null && curAnim != "") {
                if (endFrames.ContainsKey(curAnim)) {
                    endFrame = endFrames[curAnim];
                }
            }
        }
        return (frameIndex >= endFrame);    
    }

    public void UpdateFrame() {
        if (!dirty) return;

         if (images == null) {
            images = GetComponent<Images>();
        }

        if (image == null) {
            var img = images.datas[0];
            var obj = new GameObject("anim");
            obj.transform.parent = this.transform;
            obj.transform.localPosition = Vector3.zero;
            obj.transform.localScale = Vector3.one;

            image = obj.AddComponent<Image>();   
            
            obj.transform.localPosition = new Vector3(offX,offX+img.textureRect.height,0);
        } 
        
        image.sprite = images.datas[frameIndex];

        dirty = false;
    }

    public void SetAnimKeys(List<string> keys) {
        this.keys = keys.ToArray();
    }

}
