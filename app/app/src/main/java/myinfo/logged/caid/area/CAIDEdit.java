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

public class CAIDEdit extends BaseActivity {
    CAIDMagrAdapter adapter;
    WebProc web = null;
    String caid = null;
    String title = null;
    String autoid = null;
    TextView txtCAID;
    TextView txtTitle;
    Button btnOK;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_caid_edit);
        //
        web = new WebProc();
        web.addListener(wls);
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
        Bundle bundle = this.getIntent().getExtras();
        autoid = bundle.getString("autoid");
        caid = bundle.getString("caid");
        title = bundle.getString("title");
        //
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(title);
        //
        txtCAID = (TextView) findViewById(R.id.txt1);
        txtTitle = (TextView) findViewById(R.id.txt2);
        btnOK = (Button) findViewById(R.id.btn1);
        View row2=(View)findViewById(R.id.row2);
        //
        btnOK.setOnClickListener(onDeleteClick);
        row2.setOnClickListener(onEditTitleClick);
        //
        showContet();
    }

    void showContet()
    {
        //
        txtCAID.setText(getString(R.string.cmagr_caid)+" "+caid);
        txtTitle.setText(getString(R.string.caidedit_title)+" "+title);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener onDeleteClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            // 提示框
            AlertDialog alert = new AlertDialog.Builder(CAIDEdit.this).create();
            alert.setTitle(getString(R.string.alert));
            alert.setIcon(R.drawable.ic_dashboard_black_24dp);
            alert.setMessage(getString(R.string.caidedit_isdel));
            DialogInterface.OnClickListener cl = new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    if(-1==which)
                    {
                        //删除当前CAID
                        web.getHtml(HTTPData.sInfoUrl + "/delcaid.i.php", "k=" + LoginInfo.verifyKey + "&autoid=" + autoid);
                    }
                }
            };
            alert.setButton(DialogInterface.BUTTON_NEGATIVE, getString(R.string.cancel), cl);
            alert.setButton(DialogInterface.BUTTON_POSITIVE, getString(R.string.ok), cl);
            alert.show();
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
                        //删除成功,关闭并反回结果
                        Intent retData = new Intent();
                        Bundle bundle = new Bundle();//该类用作携带数据
                        bundle.putString("exc", "delete");
                        bundle.putString("autoid", autoid);
                        retData.putExtras(bundle);//附带上额外的数据
                        setResult(1001, retData);
                        finish();
                        overridePendingTransition(R.anim.back_0, R.anim.back_1);
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(CAIDEdit.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(CAIDEdit.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(CAIDEdit.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(CAIDEdit.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            Toast.makeText(getApplicationContext(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
        }
    };

    private View.OnClickListener onEditTitleClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            CAIDMagrItem item = (CAIDMagrItem) v.getTag();
            //跳到下一个窗体
            Intent intent = new Intent(CAIDEdit.this, CAIDEditTitle.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("autoid", autoid);
            bundle.putString("caid", caid);
            bundle.putString("title", title);
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 1102);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    //窗体反回结果
    @Override
    protected void onActivityResult(int requestCode, int ResultCode, Intent data) {
        super.onActivityResult(requestCode, ResultCode, data);

        if(null==data)
        {return;}

        if (1102 == requestCode) {
            //更新返回结果
            Bundle bundle = data.getExtras();
            title = bundle.getString("title");
            showContet();
        }
    }

}
