package myinfo.logged.setting.account;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
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
import myinfo.logic.LoginInfo;


public class ModifyPasswd extends BaseActivity {
    Context context = null;
    WebProc webPost = null;

    EditText txt1=null;
    EditText txt2=null;
    EditText txt3=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_modify_passwd);
        context = this;
        webPost = new WebProc();
        webPost.addListener(wlsPostData);
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
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.title_modify_passwd));
        //
        txt1 = (EditText) findViewById(R.id.txt1);
        txt2 = (EditText) findViewById(R.id.txt2);
        txt3 = (EditText) findViewById(R.id.txt3);
        Button btn1 = (Button) findViewById(R.id.btn1);
        btn1.setOnClickListener(modify_ok_click);
    }

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
                        AssertAlert.show(context,R.string.alert,R.string.modpwd_ok,clModOK);
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(context,R.string.alert,R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(context,R.string.alert,R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(context,R.string.alert,R.string.myprofile_key_invalid);
                    }
                    break;
                    case 5://旧密码不对
                    {
                        AssertAlert.show(context,R.string.alert,R.string.modpwd_oldp_fail);
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

    DialogInterface.OnClickListener clModOK = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener modify_ok_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            String a=txt1.getText().toString();
            if(a.equals(""))
            {
                AssertAlert.show(context,R.string.alert,R.string.modpwd_notnull);
                return;
            }
            String b=txt2.getText().toString();
            if(b.equals(""))
            {
                AssertAlert.show(context,R.string.alert,R.string.modpwd_notnull);
                return;
            }
            String c=txt3.getText().toString();
            if(!c.equals(b))
            {
                AssertAlert.show(context,R.string.alert,R.string.modpwd_notsame);
                return;
            }

            webPost.getHtml(HTTPData.sUserUrl + "/mod_passwd.i.php", "k="+LoginInfo.verifyKey+"&oldp="+a+"&newp="+b);
        }
    };
}
