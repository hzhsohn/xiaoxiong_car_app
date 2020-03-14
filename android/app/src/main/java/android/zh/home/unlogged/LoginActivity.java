package android.zh.home.unlogged;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.b.H5Web_acty;

import com.dou361.dialogui.DialogUIUtils;
import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;

import ext.func.AssertAlert;
import ext.magr.ConfigMagr;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.a.MyInfo;
import myinfo.logged.iotinfo.ModifyIcon;
import myinfo.logged.iotinfo.MyIotInfo;
import myinfo.logic.LoginInfo;

public class LoginActivity extends AppCompatActivity {
    Context cxt = null;
    Dialog loadDialog;

    //保存账号名
    TextView txtAccount = null;
    TextView txtPasswd = null;
    WebProc web = null;
    Button btnLogin = null;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_login);
        //
        cxt = this.getApplicationContext();
        txtAccount = (TextView) findViewById(R.id.txtAccount);
        txtPasswd = (TextView) findViewById(R.id.txtPasswd);
        //
        web = new WebProc();
        web.addListener(wls);
        //
        btnLogin = findViewById(R.id.btnLogin);
        btnLogin.setOnClickListener(btnLogin_click);
        findViewById(R.id.btnForgot).setOnClickListener(btnForgot_click);

        //读取保存的账号名
        Properties prop = ConfigMagr.loadConfig(cxt,"hx-kong", "nor_cfg");
        if (prop != null) {
            String tstr = (String) prop.get("login_account");
            if (tstr != null) {
                txtAccount.setText(tstr);
            }
        }
    }

    void showBox(int rid) {
        AssertAlert.show(cxt, R.string.alert, rid);
    }


    @Override
    public void onResume() {
        super.onResume();
        //
        if (true == LoginInfo.isLogin) {
            //直接进入我的资料界面
            jumpFormMyInfo(false);
        } else if (true == LoginInfo.readVerifyKey(cxt)) {
            long tmpt = LoginInfo.getCurrentSecond();
            //超过半小时要重新验证
            if (tmpt - LoginInfo.lastVerifySecTime > 1800) {
                //验证钥匙
                HTTPData.getHttpData(handler, HTTPData.sUserUrl + "/verify_key.i.php", "k=" + LoginInfo.verifyKey);
            } else {
                //直接进入我的资料界面
                jumpFormMyInfo(false);
            }
        }
    }


    private View.OnClickListener btnLogin_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //Toast.makeText(v.getContext(), "btnLogin_click", Toast.LENGTH_SHORT).show();
            Properties prop = new Properties();
            String txts = txtAccount.getText().toString();
            prop.put("login_account", txts);
            ConfigMagr.saveConfig(cxt,"hx-kong", "nor_cfg", prop);
            //登录
            web.getHtml(HTTPData.sUserUrl + "/sign_in.i.php",
                    "a=" + txts + "&p=" + txtPasswd.getText().toString());
            //
            btnLogin.setEnabled(false);
            //显示
            if (loadDialog==null||!loadDialog.isShowing())
                loadDialog = DialogUIUtils.showLoading(cxt,getString(R.string.Loading),true,false,false,true).show();

        }
    };

    private View.OnClickListener btnForgot_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //Toast.makeText(v.getContext(), "btnForgot_click", Toast.LENGTH_SHORT).show();

           // Intent intent = new Intent(cxt, MyForgot.class);
           // Bundle bundle = new Bundle();//该类用作携带数据
            //intent.putExtras(bundle);//附带上额外的数据
           // startActivity(intent, (byte) 0, (byte) 200);
           // overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url,String cookie) {

        }

        @Override
        public void success_html(String url,String html) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1://
                    {
                        String szKey = person.getString("szKey");
                        LoginInfo.saveVerifyKey(cxt,szKey);
                        LoginInfo.saveKeyAliveNow();

                        //登录成功进入我的资料界面
                        jumpFormMyInfo(true);
                    }
                    break;
                    case 2://登录失败
                    {
                        showBox(R.string.signin_login_fail);
                    }
                    break;
                    case 3://账号为空
                    {
                        //直接跳到注册页
                        Intent intent = new Intent(cxt, H5Web_acty.class);
                        Bundle bundle = new Bundle();//该类用作携带数据
                        bundle.putString("title","注册");
                        bundle.putString("url",HTTPData.sWebPhoneUrl_Reg);
                        intent.putExtras(bundle);//附带上额外的数据
                        //带返回结果
                        startActivityForResult(intent, 1);
                        overridePendingTransition(R.anim.in_0, R.anim.in_1);
                    }
                    break;
                    case 4://密码为空
                    {
                        showBox(R.string.signin_empty_password);
                    }
                    break;
                    case 5://账号已被禁用
                    {
                        showBox(R.string.signin_empty_password);
                    }
                    break;
                    case 6://不存在的账号
                    {
                        showBox(R.string.signin_no_user);
                    }
                    break;

                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            btnLogin.setEnabled(true);
        }

        @Override
        public void fail(String url,String errMsg) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            Toast.makeText(cxt, getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            //恢复状态
            btnLogin.setEnabled(true);
        }
    };

    void jumpFormMyInfo(final boolean ani) {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                // 关闭并反回结果
                Intent retData = new Intent();
                setResult(888, retData);
                finish();
                overridePendingTransition(R.anim.back_0, R.anim.back_1);
            }
        });

    }

    DialogInterface.OnClickListener gotoLogin_cl = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
        }
    };

    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1: {
                    int nRet = 0;
                    try {
                        String text = (String) msg.obj;
                        JSONObject person = new JSONObject(text);
                        nRet = person.getInt("nRet");
                        switch (nRet) {
                            case 1://
                            {
                                String szKey = person.getString("szKey");
                                LoginInfo.saveVerifyKey(cxt,szKey);
                                LoginInfo.saveKeyAliveNow();

                                //直接进入我的资料界面
                                jumpFormMyInfo(true);
                            }
                            break;
                            case 2://钥匙为空
                            {
                                AssertAlert.show(cxt, R.string.alert, R.string.useda_empty_key, gotoLogin_cl);
                            }
                            break;
                            case 3://账号未激活
                            {
                                AssertAlert.show(cxt, R.string.alert, R.string.useda_inaction, gotoLogin_cl);
                            }
                            break;
                            case 4://无效钥匙
                            case 5://钥匙与账户不匹配
                            case 6://不存在此用户
                            {
                                LoginInfo.clearLoginCfg(cxt);
                            }
                            break;
                            case 7://账号被禁用
                            {
                                //account has been disabled
                                AssertAlert.show(cxt, R.string.alert, R.string.account_has_been_disabled, gotoLogin_cl);
                            }
                            break;
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
                break;
                case -1: {
                    //Toast.makeText(context, getString(R.string.http_retry), Toast.LENGTH_SHORT).show();

                    //5秒后继续访问
                    Timer timer = new Timer();
                    TimerTask task = new TimerTask() {
                        @Override
                        public void run() {
                            //验证钥匙
                            HTTPData.getHttpData(handler, HTTPData.sUserUrl + "/verify_key.i.php", "k=" + LoginInfo.verifyKey);
                        }
                    };
                }
                break;
            }
        }
    };

}
