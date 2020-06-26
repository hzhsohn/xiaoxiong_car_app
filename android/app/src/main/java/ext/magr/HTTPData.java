package ext.magr;

import android.os.Handler;
import android.os.Message;

import java.io.InputStream;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookieStore;
import java.net.HttpCookie;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

/**
 * Created by han.zh on 2016/11/8.
 */

public class HTTPData {

    static public final boolean isTestApp=false;

    //-------------------------
    static public final String sWebTest="http://47.115.187.147/webphone_ios";  //测试服务器
    //static public final String sWebOK="https://8.129.208.43/webphone_ios";      //正式服务器
    static public final String sWebOK="https://daichepin.com/webphone_ios";      //正式服务器

    //-------------------------
    static public  String sWeb;
    static public  String sWebTestPage;  //测试服务器
    static public  String sWebStartPage;  //测试服务器

    //-------------------------
    static public  String sWebPhoneUrl_Index;
    static public  String sWebPhoneUrl_JiZhao;
    static public  String sWebPhoneUrl_Center;
    static public  String sUpdateUrl;

    /* 例子
    private Handler handler = new Handler(Looper.getMainLooper()){
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1: {
                    int nRet = 0;
                    try {
                        String text = (String) msg.obj;
                        JSONObject person = new JSONObject(text);
                        nRet = person.getInt("ret");
                        switch (nRet) {
                            case 0: {
                            }
                            break;
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                break;
                case -1:
                    Toast.makeText(getApplication(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
                    break;
            }
        };
    };
    */

    static public void getHttpData(final Handler handler, final String str_url, final String parameter) {
        //访问网络，把html源文件下载下来
        new Thread() {
            public void run() {
                try {
                    String url_path = str_url + "?" + parameter;
                    CookieManager manager = new java.net.CookieManager();
                    CookieHandler.setDefault(manager);
                    URL url = new URL(url_path);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");//声明请求方式 默认get
                    conn.setConnectTimeout(5000);//设置请求超时时间
                    Object obj = conn.getContent();
                    /////////////////////////////////////////////
                    int code = conn.getResponseCode();
                    if (code == 200) {
                        InputStream is = conn.getInputStream();
                        String result = StreamTools.readStream(is);
                        /////////////////////////////////////////////
                        Message msg = Message.obtain();//减少消息创建的数量
                        msg.obj = result;
                        msg.what = 1;
                        handler.sendMessage(msg);
                    }
                } catch (Exception e) {
                    Message msg = Message.obtain();//减少消息创建的数量
                    msg.what = -1;
                    handler.sendMessage(msg);
                    e.printStackTrace();
                }
            }

            ;
        }.start();
    }
}
