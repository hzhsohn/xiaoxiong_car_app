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
    static public final String sUserUrl="http://user.hx-kong.com/_j0";
    static public final String sIconUrl="http://user.hx-kong.com/u_icon";//文件名是<userid>.jpg
    static public final String sSMSUrl= "http://user.hx-kong.com/_sms";

    static public final String sFeedbackUrl= "http://www.hx-kong.com/qcline_hx-kong_com/feedback";
    static public final String sInfoUrl="http://www.hx-kong.com/qcline_hx-kong_com/_j2";
    static public final String sIotBindDevUrl="http://www.hx-kong.com/qcline_hx-kong_com/_j1/";

    static public final String sIotDevUrl="http://iot.d.hx-kong.com:8088";
    static public final String sIotDevUrl_get_dev_by_caid = HTTPData.sIotDevUrl + "/get-dev.php";
    static public final String sIotDevUrl_get_online_by_caid = HTTPData.sIotDevUrl + "/get-online.php";
    static public final String sIotDevUrl_remove_dev_by_caid = HTTPData.sIotDevUrl + "/remove-dev.php";
    static public final String sIotDevUrl_get_online_by_uuid= HTTPData.sIotDevUrl +"/check-online.php";
    
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
