package myinfo.qrscan.result;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import ext.magr.HTTPData;
import ext.func.AssertAlert;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logic.LoginInfo;

public class QRAddCtrlDevice extends BaseActivity {
    WebProc web = null;
    WebProc web2 = null;
    WebProc web3 = null;
    Context context = null;
    String productID=null;
    String devuuid=null;
    String mark=null;
    String bind_caid=null;
    private static final String DECODED_CONTENT_KEY = "codedContent";
    private static final String DECODED_BITMAP_KEY = "codedBitmap";
    TextView txtProductID;
    TextView txtMark;
    TextView txtFrmCAID;
    TextView txtResult;
    Button btnBind;
    Timer tim;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_qr_add_ctrl_dev);
        context = this;
        web = new WebProc();
        web.addListener(wls);

        web2 = new WebProc();
        web2.addListener(wls2);

        web3 = new WebProc();
        web3.addListener(wls3);

        //
        initToolbar(0,
                R.id.toolbarId,
                null,
                null,
                R.drawable.nav_back,
                onBackClick,
                0,
                null);

        //
        txtProductID= (TextView) findViewById(R.id.txt1);
        txtMark= (TextView) findViewById(R.id.txt_flag);
        txtFrmCAID= (TextView) findViewById(R.id.txt_curfrm_caid);
        txtResult= (TextView) findViewById(R.id.result);
        btnBind= (Button) findViewById(R.id.button);
        //
        String content = this.getIntent().getStringExtra(DECODED_CONTENT_KEY);
        Bitmap bitmap = this.getIntent().getParcelableExtra(DECODED_BITMAP_KEY);
        //访问网络
        Map<String, String> mss= urlSplit(content);
        productID=mss.get("product_id");
        webNetDevInfo(productID);

        //
        // 添加一个Timer，可以让程序运行起来了
        tim = new Timer();
    }

    /**
     * 去掉url中的路径，留下请求参数部分
     * @param strURL url地址
     * @return url请求参数部分
     * @author lzf
     */
    private static String TruncateUrlPage(String strURL){
        String strAllParam=null;
        String[] arrSplit=null;
        strURL=strURL.trim().toLowerCase();
        arrSplit=strURL.split("[?]");
        if(strURL.length()>1){
            if(arrSplit.length>1){
                for (int i=1;i<arrSplit.length;i++){
                    strAllParam = arrSplit[i];
                }
            }
        }
        return strAllParam;
    }

    /**
     * 解析出url参数中的键值对
     * 如 "index.jsp?Action=del&id=123"，解析出Action:del,id:123存入map中
     * @param URL  url地址
     * @return  url请求参数部分
     * @author lzf
     */
    public static Map<String, String> urlSplit(String URL){
        Map<String, String> mapRequest = new HashMap<String, String>();
        String[] arrSplit=null;
        String strUrlParam=TruncateUrlPage(URL);
        if(strUrlParam==null){
            return mapRequest;
        }
        arrSplit=strUrlParam.split("[&]");
        for(String strSplit:arrSplit){
            String[] arrSplitEqual=null;
            arrSplitEqual= strSplit.split("[=]");
            //解析出键值
            if(arrSplitEqual.length>1){
                //正确解析
                mapRequest.put(arrSplitEqual[0], arrSplitEqual[1]);
            }else{
                if(arrSplitEqual[0]!=""){
                    //只有参数没有值，不加入
                    mapRequest.put(arrSplitEqual[0], "");
                }
            }
        }
        return mapRequest;
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    void webNetDevInfo(String pdid) {
        web.getHtml(HTTPData.sIotBindDevUrl + "/get_dev_info.php", "product_id="+pdid);
    }
    void webNetBindDev(String devUUID,String caid) {
        web2.getHtml(HTTPData.sIotBindDevUrl + "/set_caid.php", "device_uuid="+devUUID+"&caid="+caid);
    }
    void webNetBindDevCheck(String devUUID,String caid) {
        web3.getHtml(HTTPData.sIotBindDevUrl + "/set_caid_check.php", "device_uuid="+devUUID+"&caid="+caid);
    }

    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("ret");
                switch (nRet) {
                    case 1://
                    {
                        productID=person.getString("product_id");
                        mark=person.getString("mark");
                        bind_caid=person.getString("caid");
                        devuuid=person.getString("devuuid");

                        txtProductID.setText(productID);
                        txtMark.setText(mark);
                        txtFrmCAID.setText(LoginInfo.currentCAID_frm);
                        if(bind_caid.equals(""))
                        {
                            txtResult.setText(getString(R.string.qr_dev_enable_bind));
                            btnBind.setVisibility(View.VISIBLE);
                        }
                        else if(bind_caid.equals(LoginInfo.currentCAID_frm))
                        {
                            txtResult.setText(getString(R.string.qr_dev_retry_bind));
                            btnBind.setVisibility(View.VISIBLE);
                        }
                        else
                        {
                            txtResult.setText(getString(R.string.qr_dev_already_bind));
                            btnBind.setVisibility(View.GONE);
                        }
                    }
                    break;
                    case 2://未知产品设备
                    {
                        AssertAlert.show(context, R.string.alert, R.string.qr_unknow_product_id);
                    }
                    break;
                    case 3://数据库操作失败
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 4://缺少参数
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(context, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {

        }
    };
    public WebProcListener wls2 = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("ret");
                switch (nRet) {
                    case 1://
                    {
                        txtResult.setText(getString(R.string.qr_try_bind)+" CAID:"+LoginInfo.currentCAID_frm);
                        btnBind.setVisibility(View.GONE);
                        //检测是否成功
                        tim.schedule(task, 500, 2000); // 延时500ms后执行，2000ms执行一次
                    }
                    break;
                    case 2://设备已经被绑定
                    {
                        AssertAlert.show(context, R.string.alert, R.string.qr_dev_already_bind);
                    }
                    case 3://未知产品设备
                    {
                        AssertAlert.show(context, R.string.alert, R.string.qr_unknow_devuuid);
                    }
                    break;
                    case 4://数据库操作失败
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 5://缺少参数
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(context, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {

        }
    };
    public WebProcListener wls3 = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("ret");
                switch (nRet) {
                    case 1://
                    {
                        tim.cancel();
                        txtResult.setText(getString(R.string.qr_bind_ok)+" CAID:"+LoginInfo.currentCAID_frm);
                        btnBind.setVisibility(View.GONE);
                    }
                    break;
                    case 2://CAID未设置成功
                    {
                    }
                    case 3://未知产品设备
                    {
                        tim.cancel();
                        AssertAlert.show(context, R.string.alert, R.string.qr_unknow_devuuid);
                    }
                    break;
                    case 4://数据库操作失败
                    {
                        tim.cancel();
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 5://缺少参数
                    {
                        tim.cancel();
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                }
            } catch (JSONException e) {
                tim.cancel();
                e.printStackTrace();
                AssertAlert.show(context, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {

        }
    };
    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    public void click_bind(View v)
    {
        webNetBindDev(devuuid,LoginInfo.currentCAID_frm);
    }

    //////////////////////////////////////////////////
    private TimerTask task = new TimerTask() {

        public void run() {
            webNetBindDevCheck(devuuid,LoginInfo.currentCAID_frm);
            System.gc();//这一句最好加上.垃圾回收机制生效.防止某些版本系统关闭不了定时器
        }
    };

}
