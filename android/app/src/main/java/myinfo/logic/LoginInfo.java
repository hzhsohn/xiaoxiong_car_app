package myinfo.logic;

import android.content.Context;
import android.os.Environment;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;

import ext.file.DeleteFile;
import ext.magr.ConfigMagr;


/**
 * Created by hzh on 2017/8/27.
 */

public class LoginInfo {
    static public String verifyKey=""; //验证的钥匙KEY,从配置文档里获取
    static public long lastVerifySecTime=0; //最后一次验证的时间
    static public boolean isLogin=false;  //免钥匙登录,或者账号登录后设为true
    static public Map<String,String> infokey=new HashMap<String, String>(); //保存登录信息用的变量

    static public String currentCAID_frm;//当前进入的CAID界面

    static public long getCurrentSecond()
    {
        return System.currentTimeMillis()/1000;
    }
    static public void saveKeyAliveNow()
    {
        lastVerifySecTime=System.currentTimeMillis()/1000;
        isLogin=true;
    }

    //返回配置中的KEY值
    static public String cfgVerifyKey(Context cxt) {
        //读
        Properties prop = ConfigMagr.loadConfig(cxt,"hx-kong", "verify-key");
        if (prop != null) {
            return (String) prop.get("key");
        }
        return "";
    }

    static public boolean readVerifyKey(Context cxt) {
        boolean b = false;
        //读
        Properties prop = ConfigMagr.loadConfig(cxt,"hx-kong", "verify-key");
        if (prop != null) {
            verifyKey = (String) prop.get("key");
            if(verifyKey!=null) {
                if (!verifyKey.equals("")) {
                    b = true;
                }
            }else {
                verifyKey = "";
            }
        } else {
            verifyKey = "";
        }
        return b;
    }

    static public void saveVerifyKey(Context cxt,String key) {
        verifyKey=key;
        //写
        Properties prop = new Properties();
        prop.put("key", key);
        ConfigMagr.saveConfig(cxt,"hx-kong", "verify-key", prop);
    }

    static public void clearLoginCfg(Context cxt)
    {
        //删除临时文件
        String uid=infokey.get("userid");
        if(null!=uid) {
            //String fn =;
            //DeleteFile.deleteFile(fn);
        }
        verifyKey="";
        saveVerifyKey(cxt,"");
        isLogin=false;
    }

    //本地储存器的头像
    static public String getUserIconLocalPath(Context cxt, String filename)
    {
        String dir= cxt.getCacheDir()+"/hx-kong/";
        File file = new File(dir);
        if (!file.exists()) {
            file.mkdir();
        }
        String fn=dir+filename+".jpg";
        return fn;
    }

    static public void saveStartPageDone(Context cxt,String key) {
        verifyKey=key;
        //写
        Properties prop = new Properties();
        prop.put("key", key);
        ConfigMagr.saveConfig(cxt,"hx-kong", "startpage-done", prop);
    }

    static public boolean readStartPageDone(Context cxt) {
        boolean b = false;
        //读
        Properties prop = ConfigMagr.loadConfig(cxt,"hx-kong", "startpage-done");
        if (prop != null) {
            String key = (String) prop.get("key");
            if(key!=null) {
                if (!key.equals("")) {
                    b = true;
                }
            }
        }
        return b;
    }
}
