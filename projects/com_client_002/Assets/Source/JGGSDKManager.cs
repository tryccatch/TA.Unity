using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JGGSDKManager : MonoBehaviour
{
    public class Session
    {
        public String Title;
        public String accessToken;
        public String createdAt;
        public String expireAt;
        public String gameId;
        public String nickname;
        public String userId;

        public Session()
        {

        }

        //public String debugString()
        //{
        //    return "Session{accessToken='" + this.accessToken + '\'' + ", createdAt='" + this.createdAt + '\'' + ", expireAt='" + this.expireAt + '\'' + ", gameId='" + this.gameId + '\'' + ", nickname='" + this.nickname + '\'' + ", userId='" + this.userId + '\'' + ", isQuickSignUp=" + this.isQuickSignUp + ", quickSignUpCredentials=" + this.quickSignUpCredentials + '}';
        //}
    }


    public static Session GetSession(string result)
    {
        Session session = new Session();

        //result = result.Replace(" ", "");

        int firstS = result.IndexOf('{');
        int lastS = result.IndexOf('}');

        string callResultType = result.Substring(0, firstS);
        Console.WriteLine(lastS);
        Console.WriteLine(callResultType);

        if (callResultType.Equals("Session"))
        {
            session.Title = "Session";
            string content = result.Substring(firstS + 1, lastS - firstS - 1);
            content = content.Replace("\'", "");

            var arr = content.Split(',');

            for (int i = 0; i < arr.Length; i++)
            {
                arr[i] = arr[i].Trim();
                int s = arr[i].IndexOf('=');

                switch (arr[i].Substring(0, s))
                {
                    case "accessToken":
                        session.accessToken = arr[i].Substring(s + 1, arr[i].Length - s - 1);
                        break;
                    case "createdAt":
                        session.createdAt = arr[i].Substring(s + 1, arr[i].Length - s - 1);
                        break;
                    case "expireAt":
                        session.expireAt = arr[i].Substring(s + 1, arr[i].Length - s - 1);
                        break;
                    case "gameId":
                        session.gameId = arr[i].Substring(s + 1, arr[i].Length - s - 1);
                        break;
                    case "nickname":
                        session.nickname = arr[i].Substring(s + 1, arr[i].Length - s - 1);
                        break;
                    case "userId":
                        session.userId = arr[i].Substring(s + 1, arr[i].Length - s - 1);
                        break;
                    default:
                        break;
                }
            }
        }
        return session;
    }

    public class PurchaseResult
    {
        public String Title;
        public bool success;
        public String transactionId;
        public String status;
        public String message;

        public PurchaseResult()
        {

        }

        //public String debugString()
        //{
        //    return "PurchaseResult{success=" + this.success + ", transactionId='" + this.transactionId + '\'' + ", status='" + this.status + '\'' + ", message='" + this.message + '\'' + '}';
        //}
    }

    public static PurchaseResult GetPurchaseResult(string result)
    {
        PurchaseResult purchaseResult = new PurchaseResult();

        //result = result.Replace(" ", "");

        int lb = result.IndexOf('{');
        int rb = result.IndexOf('}');

        string title = result.Substring(0, lb);
        if (title.Equals("PurchaseResult"))
        {
            purchaseResult.Title = "PurchaseResult";
            string content = result.Substring(lb + 1, rb - lb - 1);
            content = content.Replace("\'", "");

            string[] arr = content.Split(',');

            for (int i = 0; i < arr.Length; i++)
            {
                arr[i] = arr[i].Trim();
                int es = arr[i].IndexOf('=');

                var er = arr[i].Substring(es + 1, arr[i].Length - es - 1);
                if (!er.Equals("null"))
                {
                    switch (arr[i].Substring(0, es))
                    {
                        case "success":
                            purchaseResult.success = er.Equals("true");
                            break;
                        case "transactionId":
                            purchaseResult.transactionId = er;
                            break;
                        case "status":
                            purchaseResult.status = er;
                            break;
                        case "message":
                            purchaseResult.message = er;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return purchaseResult;
    }

    public class TransactionStatus
    {
        public String transactionId;
        public String status;
        public String Title;

        public TransactionStatus()
        {
        }

        public String debugString()
        {
            return "TransactionStatus{transactionId='" + this.transactionId + '\'' + ", status='" + this.status + '\'' + '}';
        }
    }

    public static TransactionStatus GetJGGTransactionStatus(string result)
    {
        TransactionStatus transactionStatus = new TransactionStatus();

        //result = result.Replace(" ", "");

        int lb = result.IndexOf('{');
        int rb = result.IndexOf('}');

        string title = result.Substring(0, lb);
        if (title.Equals("JGGError"))
        {
            transactionStatus.Title = "TransactionStatus";
            string content = result.Substring(lb + 1, rb - lb - 1);
            content = content.Replace("\'", "");

            string[] arr = content.Split(',');

            for (int i = 0; i < arr.Length; i++)
            {
                arr[i] = arr[i].Trim();
                int es = arr[i].IndexOf('=');

                var er = arr[i].Substring(es + 1, arr[i].Length - es - 1);
                if (!er.Equals("null"))
                {
                    switch (arr[i].Substring(0, es))
                    {
                        case "transactionId":
                            transactionStatus.transactionId = er;
                            break;
                        case "status":
                            transactionStatus.status = er;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return transactionStatus;
    }

    public class JGGError
    {
        public String Title;
        public String statusCode;
        public String message;

        public JGGError()
        {

        }

        public String debugString()
        {
            return "JGGError{statusCode=" + this.statusCode + ", message='" + this.message + '\'' + '}';
        }
    }



    public static JGGError GetJGGError(string result)
    {
        JGGError jGGError = new JGGError();

        //result = result.Replace(" ", "");

        int lb = result.IndexOf('{');
        int rb = result.IndexOf('}');

        string title = result.Substring(0, lb);
        if (title.Equals("JGGError"))
        {
            jGGError.Title = "JGGError";
            string content = result.Substring(lb + 1, rb - lb - 1);
            content = content.Replace("\'", "");

            string[] arr = content.Split(',');

            for (int i = 0; i < arr.Length; i++)
            {
                arr[i] = arr[i].Trim();
                int es = arr[i].IndexOf('=');

                var er = arr[i].Substring(es + 1, arr[i].Length - es - 1);
                if (!er.Equals("null"))
                {
                    switch (arr[i].Substring(0, es))
                    {
                        case "statusCode":
                            jGGError.statusCode = er;
                            break;
                        case "message":
                            jGGError.message = er;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return jGGError;
    }

}
