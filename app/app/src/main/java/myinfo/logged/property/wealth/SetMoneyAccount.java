package myinfo.logged.property.wealth;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;

import com.dou361.dialogui.DialogUIUtils;
import com.hx_kong.freesha.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logged.caid.area.CAIDMagr;
import myinfo.logic.LoginInfo;

public class SetMoneyAccount extends BaseActivity {
    WebProc web_get=null;
    WebProc web=null;
    Dialog loadDialog;
    Context cxt=null;
    Button submitbtn;
    boolean isGetAccountInfo;
    String payinfoJson="";
    //
    String payTool="";
    EditText txtPayAccount;
    ImageView imgPic;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_set_money_account);
        //
        cxt=SetMoneyAccount.this;
        //
        web_get = new WebProc();
        web_get.addListener(wls_get);
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
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.draw_money_account));
        //
        txtPayAccount=(EditText)findViewById(R.id.editText);
        imgPic=(ImageView)findViewById(R.id.imageView8);
        //
        submitbtn=(Button)findViewById(R.id.button2);
        submitbtn.setOnClickListener(submit_click);
        //
        ((Button)findViewById(R.id.button3)).setOnClickListener(selectpaytool_click);
        //获取账户信息
        isGetAccountInfo=false;
        web_get.getHtml(HTTPData.sMoneyUrl + "/payinfo_get.i.php", "k=" + LoginInfo.verifyKey);
    }


    void SetNetData(String payTool,String payAccount)
    {
        if(isGetAccountInfo) {
            if (loadDialog == null || !loadDialog.isShowing())
                loadDialog = DialogUIUtils.showLoading(SetMoneyAccount.this, getString(R.string.Loading), true, false, false, true).show();
            web.getHtml(HTTPData.sMoneyUrl + "/payinfo_update.i.php", "k=" + LoginInfo.verifyKey + "&pt=" + payTool + "&pa=" + payAccount);
        }
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };


    public View.OnClickListener selectpaytool_click = new View.OnClickListener() {
        public void onClick(View v) {
            //弹出选择框
            new AlertDialog.Builder(cxt)
                    .setTitle(getString(R.string.input_paytool))
                    .setItems(new String[]{getString(R.string.alipay)}, dol)
                    .show();
        }
    };

    //为列表添加监听事件
    DialogInterface.OnClickListener dol = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            Log.v("DialogInterface", "which=" + which);
            switch (which)
            {
                case 0:
                    payTool="alipay";
                    selectImg(payTool);
                    break;
            }
            dialog.cancel();  //用户选择后，关闭对话框
        }
    };

    void selectImg(String pt)
    {
        if(pt.equals("alipay"))
        {
            Bitmap bm = BitmapFactory.decodeResource(getResources(), R.drawable.alipay);
            imgPic.setImageBitmap(bm);
        }
    }

    public View.OnClickListener submit_click = new View.OnClickListener() {
        public void onClick(View v) {

            if(payTool.equals(""))
            {
                AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.input_paytool);
                return;
            }
            String payAccount= txtPayAccount.getText().toString();
            if(payAccount.equals(""))
            {
                AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.input_payaccount);
                return;
            }

            SetNetData(payTool,payAccount);
        }
    };


    public WebProcListener wls_get = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1:
                    {
                        isGetAccountInfo=true;
                        payinfoJson = person.getString("payinfo");
                        if(null != payinfoJson && !payinfoJson.equals("")) {
                            JSONObject person2 = new JSONObject(payinfoJson);
                            if (null != person2) {
                                payTool = person2.getString("pay_tool");
                                selectImg(payTool);
                                String payAccount = person2.getString("pay_account");
                                txtPayAccount.setText(payAccount);
                            }
                        }
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(SetMoneyAccount.this, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {
        }
    };

    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1:
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.set_money_account_ok);
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(SetMoneyAccount.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(SetMoneyAccount.this, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
        }
    };


}
