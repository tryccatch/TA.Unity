using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net.Sockets;
using System;
using System.Net;
using System.IO;

public class TcpNet : MonoBehaviour {

    enum TcpState{
		none,
		waitting,
		running,
		error,
		stopped,
	}

    TcpState state = TcpState.none;
	Socket   socket;
    Queue packages;

    const int MAX_PACKAGE_COUNT = 50;
    bool waittingHeart;
#if UNITY_EDITOR
	int HeartTimeOutInval = 1000000; // 单位秒，测试的时候做成无线大
#else
	int HeartTimeOutInval = 5; // 单位秒，测试的时候做成无线大
#endif

	float readTime;
    float sendTime;

    // connet to IP and port
	static public TcpNet Connect(string ip, int port)
	{
		var tcpNet = UIAPI.gNode.GetComponent<TcpNet> ();
		if (tcpNet != null) {
			tcpNet.OnDestroy ();
			GameObject.Destroy (tcpNet);
		}

		tcpNet = UIAPI.gNode.gameObject.AddComponent<TcpNet> ();
		tcpNet.DoConnect (ip, port);

		return tcpNet;
	}

	static public void Close()
	{
		var tcpNet = UIAPI.gNode.GetComponent<TcpNet> ();
		if (tcpNet != null) {
			tcpNet.OnDestroy ();
			GameObject.Destroy (tcpNet);
		}
	}

    public void DoConnect(string ip, int port) {
		state = TcpState.waitting;
        packages = new Queue();
		StartCoroutine(ConnectSocket(ip,port));
	}

    IEnumerator ConnectSocket(string server, int port)
	{
		yield return new WaitForEndOfFrame();

		IPAddress addr = null;
		if (IPAddress.TryParse(server, out addr) == false)
		{

			IPHostEntry hostEntry = null;

			try {
				hostEntry = Dns.GetHostEntry(server);
				foreach (IPAddress address in hostEntry.AddressList)
				{
					if (address.AddressFamily == AddressFamily.InterNetwork)
					{
						addr = address;
						break;
					}
				}
			}
			catch(Exception) {
				addr = null;
			}
		}

		if (addr == null) {
			state = TcpState.error;
		} else {

			IPEndPoint ipe = new IPEndPoint (addr, port);
			var s = new Socket (ipe.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

			try {
				s.BeginConnect (ipe, OnConnect, s);
			} catch (Exception) {
				state = TcpState.error;
			}


			float time = Time.realtimeSinceStartup + 1f;
			while (state == TcpState.waitting) {
				if (time < Time.realtimeSinceStartup) {
                    Debug.Log("connect timeout!");
					s.Close ();
					state = TcpState.error;
					break;
				}
				yield return new WaitForEndOfFrame ();
			}

			if (state == TcpState.running) {
				StartRead ();
			}
		}

	}

    byte[] receiveBuffer = new byte[1024*64];
    int    receivePos = 0;
    int    receiveLen = 0;

	SocketAsyncEventArgs receiveSaea = new SocketAsyncEventArgs();
	void StartRead()
	{
		receiveSaea = new SocketAsyncEventArgs();

		receiveSaea.SetBuffer(receiveBuffer, 0, 4);
		receiveSaea.Completed += OnReceiveCompleted;

		try {
		    socket.ReceiveAsync(receiveSaea);
        } catch (Exception e) {
			Debug.LogError(e);
        }
	}


	void OnConnect(IAsyncResult iar)
	{
		try
		{
            var s = iar.AsyncState as Socket;
			s.EndConnect(iar);
			if (state == TcpState.waitting)
			{
				socket = s;
			}
			state = TcpState.running;
		}
		catch (System.Exception e)
		{
			print(e);
		}
	}


	bool lz4;

	void OnReceiveCompleted(object sender, SocketAsyncEventArgs e)
	{
		if (e.SocketError == SocketError.OperationAborted) return;
		var socket = sender as Socket;

		if (e.SocketError == SocketError.Success && e.BytesTransferred > 0)
		{
			if (packages.Count > MAX_PACKAGE_COUNT) {
				state = TcpState.error;
				socket.Close ();
			} else {
				readTime = 0;
				waittingHeart = false;

				//Debug.Log("e.BytesTransferred:" + e.BytesTransferred );
				if (receiveLen == 0) {
					lz4 = receiveBuffer[3] == 1;
					receiveBuffer[3] = 0;
					receiveLen = bytesToInt(receiveBuffer,0);
                    //Debug.Log("receive time:" + DateTime.Now.ToString() );
                    //Debug.Log("receive len: " + receiveLen);
                } else {
                    if (receiveLen == e.BytesTransferred + receivePos) {
                        var bin = new CSBin();
		
						//Debug.Log("received:" + hexStr(receiveBuffer,0,receiveLen));

                        
						if (lz4)
                        {
							var input = new MemoryStream(receiveBuffer, 0, receiveLen);
							var output = new MemoryStream();
							ICSharpCode.SharpZipLib.GZip.GZip.Decompress(input, output,false);

							var bytes = output.GetBuffer();
							bin.bytes = subBytes(bytes, 4, bytes.Length);
							bin.ackId = bytesToInt16(bytes, 0);
							bin.msgId = bytesToInt16(bytes, 2);
						} else
                        {
							bin.bytes = subBytes(receiveBuffer, 4, receiveLen);
							bin.ackId = bytesToInt16(receiveBuffer, 0);
							bin.msgId = bytesToInt16(receiveBuffer, 2);
						}

                        

						//Debug.Log("bytes:" + hexStr(bin.bytes,0,receiveLen-4));

						//Debug.Log("msgId:" + bin.msgId);
						if (bin.msgId != 0) {
                        	packages.Enqueue(bin);
						} else {
							//Debug.Log("heart!");
						}
                        receiveLen = 0;
                    } else {
                        receivePos += e.BytesTransferred;
                    }
                }               

                if (receiveLen == 0) {
                    receivePos = 0;
                    e.SetBuffer(this.receiveBuffer, 0, 4);
                } else {
                    if (receiveLen > receiveBuffer.Length) {
                        state = TcpState.error;
        				socket.Close ();
                        return;
                    }
                    e.SetBuffer(this.receiveBuffer, receivePos, receiveLen-receivePos);
                }

				socket.ReceiveAsync (e);
			}
		}
		else if (e.SocketError == SocketError.WouldBlock)
		{
			try
			{
				socket.ReceiveAsync(e);
			}
			catch (System.Exception)
			{
				state = TcpState.stopped;
				if (socket != null) socket.Close();
			}
		}
		else if (e.SocketError == SocketError.TimedOut)
		{
			try
			{
				socket.ReceiveAsync(e);
			}
			catch (System.Exception)
			{
				state = TcpState.stopped;
				if (socket != null) socket.Close();
			}
		}
		else
		{
			state = TcpState.stopped;
			if (socket != null) socket.Close();
		}
	}

	void OnDestroy(){

		if (socket != null) {
			try {
				socket.Close();
			}
			catch(Exception)
			{
			}
		}
	}

    public bool IsConnecting() {
        return (state == TcpState.waitting);
    }

    public bool CheckState()
	{
        CheckHeart ();

        if (state == TcpState.running) {
    		if (socket == null) {
    			return false;
    		} else {
                return socket.Connected;
            }
        }

        if (state == TcpState.waitting) {
            return true;
        }

		return false;
	}

	public string GetState()
	{
		return state.ToString();
	}

	void CheckHeart()
	{
		//UnityEngine.Debug.Log("readTime:" + readTime);
		//UnityEngine.Debug.Log("sendTime:"+ sendTime);

		if (state == TcpState.running) {
			var time = Time.deltaTime;
			if (time > 0.1f) time = 0.1f;
			readTime += time;
            sendTime += time;
			if (waittingHeart) {
				// time up
				if (readTime >= HeartTimeOutInval) {
					state = TcpState.error;
				}
			} else {
                if (readTime >= 3 || sendTime >= 3) {
                    // heart
                    SendBin(null);
                    waittingHeart = true;
                    readTime = 0;
                }
            }
		}
	}

	public void Send(int id, int ackId, byte[] msg) {
		var bin = new CSBin();
		bin.msgId = id;
		bin.ackId = ackId;
		bin.bytes = msg;
		SendBin(bin);
	}

    public void SendBin(CSBin bin) {
		// if (bin != null) {
		// 	Debug.Log(bin.msgId);
		// 	Debug.Log(bin.ackId);
		// 	Debug.Log(bin.bytes);
		// }

		byte[] bytes = null;
		if (bin != null) {
			bytes = bin.bytes;
		}
      
		var len = 0;
		len += 4;
		if (bytes != null) {
			len += bytes.Length;
		}		

        byte[] buf = new byte[len+4];
		var pos = 0;
        writeInt(buf,pos,len);
		pos += 4;
		
		if (bin != null) {
			writeInt16(buf,pos,bin.ackId);
		}
		pos += 2;

		if (bin != null) {
			writeInt16(buf,pos,bin.msgId);
		}	
		pos += 2;	

		if (bytes != null) {
			Array.Copy(bytes,0,buf,pos,bytes.Length);
		}

        //Debug.Log("send time:" + DateTime.Now.ToString() );
        //Debug.Log("send length:" + len );

        try {
            socket.Send (buf, buf.Length, SocketFlags.None);
            sendTime = 0;
        } catch(Exception) {

        }
    }

	public void writeInt(byte[] src, int offset, int value)
	{
		src[offset+3] = (byte)((value >> 24) & 0xFF);
		src[offset+2] = (byte)((value >> 16) & 0xFF);
		src[offset+1] = (byte)((value >> 8) & 0xFF);
		src[offset+0] = (byte)(value & 0xFF);
	}

	public void writeInt16(byte[] src, int offset, int value)
	{
		src[offset+1] = (byte)((value >> 8) & 0xFF);
		src[offset+0] = (byte)(value & 0xFF);
	}

	public  int bytesToInt(byte[] src, int offset)
	{
		int value;
		value = (int)((src[offset] & 0xFF)
				| ((src[offset + 1] & 0xFF) << 8)
				| ((src[offset + 2] & 0xFF) << 16)
				| ((src[offset + 3] & 0xFF) << 24));
		return value;
	}  

	public  int bytesToInt16(byte[] src, int offset)
	{
		int value;
		value = (int)((src[offset] & 0xFF)
				| ((src[offset + 1] & 0xFF) << 8));
		return value;
	}  

	public byte[]  subBytes(byte[] src, int offset,int len)
	{
		var ret = new byte[len-offset];
		Array.Copy(src,offset,ret,0,ret.Length);
		return ret;
	}  

	private String hexStr(byte[] bin,int offset,int len)
	{
		char[] HexChar = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
		
		var ret = "";
		for(int i=0; i<len; i++) {
			var value = bin[i+offset];

			char hexH = HexChar[value / 16];
			char hexL = HexChar[value % 16];

			if (ret != "") {
				ret += "-";	
			}
			ret += hexH + hexL;
		}
		return ret;
	}

    public CSBin Read() {
        CSBin ret = null;
        if (packages.Count > 0) {
            ret = (CSBin)packages.Dequeue();
        }
        return ret;
    }
}
