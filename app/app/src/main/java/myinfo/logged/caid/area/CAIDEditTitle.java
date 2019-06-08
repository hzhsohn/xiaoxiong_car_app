package myinfo.logged.caid.area;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import org.json.JSONException;
import org.json.JSONObject;

import ext.magr.HTTPData;
import ext.func.AssertAlert;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logic.LoginInfo;


public class CAIDEditTitle extends BaseActivity {
    Context context = null;
    WebProc webPost = null;
    EditText txt1=null;
    String title=null;
    String autoid=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_editcaid_title);
        context = this;
        webPost = new WebProc();
        webPost.addListener(wlsPostData);
        //
        Bundle bundle = this.getIntent().getExtras();
        autoid= bundle.getString("autoid");
        title = bundle.getString("title");
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
        txt1 = (EditText) findViewById(R.id.txt1);
        if(title!=null)
        {txt1.setText(title);}
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
                        title=txt1.getText().toString();
                        AssertAlert.show(context,R.string.alert,R.string.caidedit_mod_title_ok,clModOK);
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
            // 关闭并反回结果
            Intent retData = new Intent();
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("title", title);
            retData.putExtras(bundle);//附带上额外的数据
            setResult(1102, retData);
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
                AssertAlert.show(context,R.string.alert,R.string.caidedit_title_notnull);
                return;
            }

            webPost.getHtml(HTTPData.sInfoUrl + "/caid_mod.i.php", "k="+LoginInfo.verifyKey+"&autoid="+autoid+"&content="+a);
        }
    };
}
