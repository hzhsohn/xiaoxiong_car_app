package myinfo.logged.caid.area;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logic.LoginInfo;

import static java.util.Random.*;

public class CAIDAdd extends BaseActivity {
    CAIDMagrAdapter adapter;
    WebProc webgetcaid = null;
    WebProc web = null;
    String caid = null;
    TextView txtCAID;
    TextView txtTitle;
    Button btnOK;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_caid_add);
        //
        web = new WebProc();
        web.addListener(wls);
        webgetcaid = new WebProc();
        webgetcaid.addListener(wlsgetcaid);
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
        txtCAID = (TextView) findViewById(R.id.txt1);
        txtTitle = (TextView) findViewById(R.id.txt2);
        btnOK = (Button) findViewById(R.id.btn1);
        //
        btnOK.setOnClickListener(onAddClick);
        btnOK.setEnabled(false);
        //
        Random r=new Random();
        txtTitle.setText(getString(R.string.caid_pos)+r.nextInt(10000));
        setCAIDText("");
        //获取一个分配的CAID
        GetNetData();
    }

    void setCAIDText(String s)
    {
        txtCAID.setText(getString(R.string.cmagr_caid)+"   "+s);
    }

    void GetNetData()
    {
        webgetcaid.getHtml(HTTPData.sInfoUrl + "/rand_caid.i.php", null);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener onAddClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            String a=txtTitle.getText().toString();
            if(a.equals(""))
            {
                AssertAlert.show(CAIDAdd.this,R.string.alert,R.string.caidedit_title_notnull);
                return;
            }
            //添加CAID
            web.getHtml(HTTPData.sInfoUrl + "/newcaid.i.php", "k=" + LoginInfo.verifyKey + "&caid=" + caid+ "&title=" + a);
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
                    case 1: {
                        //添加成功,关闭并反回结果
                        Intent retData = new Intent();
                        Bundle bundle = new Bundle();//该类用作携带数据
                        bundle.putString("exc", "add");
                        retData.putExtras(bundle);//附带上额外的数据
                        setResult(2001, retData);
                        finish();
                        overridePendingTransition(R.anim.back_0, R.anim.back_1);
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(CAIDAdd.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(CAIDAdd.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(CAIDAdd.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                    case 5://CAID already exist
                    {
                        AssertAlert.show(CAIDAdd.this, R.string.alert, R.string.caidadd_fail_already_exist);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(CAIDAdd.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            Toast.makeText(getApplicationContext(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
        }
    };

    public WebProcListener wlsgetcaid = new WebProcListener() {
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
                    case 1: {
                        caid=person.getString("caid");
                        setCAIDText(caid);
                        btnOK.setEnabled(true);
                    }
                    break;
                    default:
                    {
                        AssertAlert.show(CAIDAdd.this, R.string.alert, R.string.caid_get_fail);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(CAIDAdd.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            Toast.makeText(getApplicationContext(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            //1秒后重新获取
            Timer timer = new Timer();
            TimerTask task = new TimerTask() {
                @Override
                public void run() {
                    GetNetData();
                }
            };
            timer.schedule(task, 1000);//此处的Delay
        }
    };
}
