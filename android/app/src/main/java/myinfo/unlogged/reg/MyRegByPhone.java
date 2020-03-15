package myinfo.unlogged.reg;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

import ext.magr.HTTPData;
import ext.func.AssertAlert;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logic.LoginInfo;


public class MyRegByPhone extends BaseActivity {
    Context context = null;
    WebProc webGetSMS = null;
    WebProc webCheckCode = null;
    WebProc webPost = null;

    TextView txtsms = null;
    TextView txtphone = null;
    Button btnGetSMS = null;
    int secTimeCount;
    String postPhone=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_reg_by_phone);
        context = this;
        webCheckCode = new WebProc();
        webCheckCode.addListener(wlsCheckCode);
        webPost = new WebProc();
        webPost.addListener(wlsPostData);
        webGetSMS = new WebProc();
        webGetSMS.addListener(wlsGetSMS);
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
        txtphone = (TextView) findViewById(R.id.txtphone);
        txtphone.setText(LoginInfo.infokey.get("phone"));
        txtsms = (TextView) findViewById(R.id.txtsms);
        btnGetSMS = (Button) findViewById(R.id.btn1);
        btnGetSMS.setOnClickListener(get_sms_click);
        Button btn2 = (Button) findViewById(R.id.btn2);
        btn2.setOnClickListener(next_click);
    }

    //生成随机用户名
    public String getRandomUserString(int length){
        String str="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        Random random=new Random();
        StringBuffer sb=new StringBuffer();
        for(int i=0;i<length;i++){
            int number=random.nextInt(62);
            sb.append(str.charAt(number));
        }
        return getString(R.string.sign_unkown_user)+sb.toString();
    }

    public WebProcListener wlsCheckCode = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1://
                    {
                        Intent intent = new Intent(MyRegByPhone.this, MyRegByPhone2.class);
                        Bundle bundle = new Bundle();//该类用作携带数据
                        bundle.putString("phone",postPhone);
                        bundle.putString("nickname",getRandomUserString(10));
                        intent.putExtras(bundle);//附带上额外的数据
                        //带返回结果
                        startActivityForResult(intent,1000);
                        overridePendingTransition(R.anim.in_0, R.anim.in_1);
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(context, R.string.alert,R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(context, R.string.alert,R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://不存在验证的电话号码
                    case 5://验证码错误
                    case 6://验证码已失效
                    {
                        AssertAlert.show(context, R.string.alert,R.string.vode_invalid);
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
            Toast.makeText(context, getString(R.string.http_retry), Toast.LENGTH_SHORT).show();
        }
    };

    public WebProcListener wlsPostData = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1://
                    {
                        //可以注册
                        //获取验证码
                        webGetSMS.getHtml(HTTPData.sSMSUrl + "/vcode_sign_up.i.php", "ph=" + postPhone);
                        btnGetSMS.setEnabled(false);
                    }
                    break;
                    case 2:
                    {
                        //不能注册
                        AssertAlert.show(context, R.string.alert ,R.string.signup_account_repeat);
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
            Toast.makeText(context, getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
        }
    };

    Runnable taskGetSMS = new Runnable() {
        @Override
        public void run() {
            while(secTimeCount>0) {
                secTimeCount--;
                Handler mainHandler = new Handler(Looper.getMainLooper());
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (0 == secTimeCount) {
                            btnGetSMS.setText(getString(R.string.modphone_getsms));
                            btnGetSMS.setEnabled(true);
                        } else {
                            btnGetSMS.setEnabled(false);
                            String lastTime = secTimeCount + getString(R.string.modphone_sec);
                            btnGetSMS.setText(lastTime);
                        }
                    }
                });
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    };

    public WebProcListener wlsGetSMS = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1://
                    {
                        //倒数60秒后才能再次获取短信
                        secTimeCount = 60;
                        new Thread(taskGetSMS).start();
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
            Toast.makeText(context, getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            btnGetSMS.setEnabled(true);
        }
    };

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener get_sms_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            String a=txtphone.getText().toString();
            if(a.equals(""))
            {
                AssertAlert.show(context,R.string.alert,R.string.modphone_nophone);
                return;
            }
            //获取验证码
            webPost.getHtml(HTTPData.sUserUrl + "/sign_up_check_user.i.php", "user=" + a);
            postPhone=a;
        }
    };
    private View.OnClickListener next_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            String a=txtphone.getText().toString();
            if(a.equals(""))
            {
                AssertAlert.show(context,R.string.alert,R.string.modphone_nophone);
                return;
            }
            String b=txtsms.getText().toString();
            if(b.equals(""))
            {
                AssertAlert.show(context,R.string.alert,R.string.modphone_nocode);
                return;
            }

            postPhone=txtphone.getText().toString();
            webCheckCode.getHtml(HTTPData.sSMSUrl + "/vcode_check.i.php", "ph="+postPhone+"&c="+txtsms.getText());
        }
    };

    //带窗体反回结果
    @Override
    protected void onActivityResult(int requestCode, int ResultCode, Intent data) {
        super.onActivityResult(requestCode, ResultCode, data);

        if(1==ResultCode) {
            // 关闭并反回结果
            Intent retData = new Intent();
            setResult(1, retData);
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    }
}
