package myinfo.unlogged.forgot;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import org.json.JSONException;
import org.json.JSONObject;

import ext.magr.HTTPData;
import ext.func.AssertAlert;

public class MyForgotEMail extends BaseActivity {

    Context context = null;
    Button btn=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_forgot_email);
        context=this;
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
        btn = (Button) findViewById(R.id.btnNext);
        btn.setOnClickListener(oNextClick);

    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener oNextClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            btn.setEnabled(false);
            TextView txt1 = (TextView) findViewById(R.id.txt_account);

            if (txt1.getText().toString().equals("")) {
                // 提示框
                AssertAlert.show(context,R.string.alert,R.string.msg_not_null_email);
                return;
            }

            //发送邮件
            HTTPData.getHttpData(handler,HTTPData.sUserUrl+"/forgot_by_email.i.php","em="+txt1.getText());
        }
    };

    private Handler handler = new Handler(){
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1: {
                    int code = 0;
                    try {
                        String text = (String) msg.obj;
                        JSONObject person = new JSONObject(text);
                        code = person.getInt("nRet");
                        switch (code) {
                            case 1://
                            {
                                //跳到下一个窗体
                                Intent intent = new Intent(MyForgotEMail.this, MyForgotEMail2.class);
                                Bundle bundle = new Bundle();//该类用作携带数据
                                intent.putExtras(bundle);//附带上额外的数据
                                //带返回结果
                                startActivityForResult(intent, 1000);
                                overridePendingTransition(R.anim.in_0, R.anim.in_1);
                            }
                            break;
                            case 2://邮箱格式不对
                            {
                                AssertAlert.show(context,R.string.alert,R.string.forgot_mail_format_err);
                            }
                            break;
                            case 3://不存在此邮箱用户
                            {
                                AssertAlert.show(context,R.string.alert,R.string.forgot_no_user);
                            }
                            break;
                            case 4://发送失败
                            {
                                AssertAlert.show(context,R.string.alert,R.string.forgot_send_fail);
                            }
                            break;
                            case 5://缺少em参数
                            {
                                AssertAlert.show(context,R.string.alert,R.string.forgot_empty_email);
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
            btn.setEnabled(true);
    };
    };

    //带窗体反回结果
    @Override
    protected void onActivityResult(int requestCode, int ResultCode, Intent data) {
        super.onActivityResult(requestCode, ResultCode, data);
        // 关闭并反回结果
        Intent retData = new Intent();
        setResult(1, retData);
        finish();
        overridePendingTransition(R.anim.back_0, R.anim.back_1);
    }
}
