package android.zh.home.unlogged.forgot;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import ext.magr.HTTPData;
import ext.func.AssertAlert;
import ext.magr.WebProc;
import ext.magr.WebProcListener;

public class MyForgotPhone2 extends BaseActivity {

    Context context = null;
    String phone=null;
    String randid=null;
    WebProc web=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_forgot_phone2);
        context = this;
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
        //
        web = new WebProc();
        web.addListener(wls);
        //
        Button btn = (Button) findViewById(R.id.btnRegNext2);
        btn.setOnClickListener(oDoneClick);
        //
        Bundle bundle = this.getIntent().getExtras();
        phone = bundle.getString("phone");
        randid = bundle.getString("randid");
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            // 关闭并反回结果
            Intent retData = new Intent();
            setResult(1000, retData);
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener oDoneClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            TextView txt1 = (TextView) findViewById(R.id.txt_passwd1);
            TextView txt2 = (TextView) findViewById(R.id.txt_passwd2);

            if (txt1.getText().toString().equals(""))
            {
                AssertAlert.show(MyForgotPhone2.this,R.string.msg_alert,R.string.msg_not_null_passwd);
                return ;
            }

            if (txt1.getText().toString().equals(txt2.getText().toString())) {
                //注册
                web.getHtml(HTTPData.sUserUrl+"/forgot_phone_ret.i.php","p="+txt1.getText()+"&randid="+randid+"&ph="+phone);

            } else {
                AssertAlert.show(MyForgotPhone2.this,R.string.msg_alert,R.string.msg_not_same_passwd);
            }
        }
    };


    public WebProcListener wls = new WebProcListener() {
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
                    case 1://成功
                    {
                        DialogInterface.OnClickListener cl = new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                // 关闭并反回结果
                                Intent retData = new Intent();
                                setResult(1, retData);
                                finish();
                                overridePendingTransition(R.anim.back_0, R.anim.back_1);
                            }
                        };

                        AssertAlert.show(context,R.string.alert,R.string.modpwd_ok,cl);
                    }
                    break;
                    case 2://格式不对
                    {
                        AssertAlert.show(context,R.string.alert,R.string.signup_phone_err);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(context,R.string.alert,R.string.lost_param);
                    }
                    break;
                    case 4://用户不存在
                    {
                        AssertAlert.show(context,R.string.alert,R.string.signup_account_not_exist);
                    }
                    break;
                    case 5://验证码错误
                    {
                        AssertAlert.show(context,R.string.alert,R.string.checkcode_error);
                    }
                    break;
                    case 6:// 操作失败
                    {
                        AssertAlert.show(context,R.string.alert,R.string.signup_operat_fail);
                    }
                    break;
                }
            } catch (JSONException e) {
                Toast.makeText(getApplicationContext(), getString(R.string.json_error), Toast.LENGTH_SHORT).show();
                e.printStackTrace();
            }

        }

        @Override
        public void fail(String url, String errMsg) {
        }
    };

}
