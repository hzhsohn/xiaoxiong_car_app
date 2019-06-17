package myinfo.logged.property.wealth;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
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
import myinfo.unlogged.reg.MyReg;

public class DrawMoney extends BaseActivity {
    WebProc web=null;
    Dialog loadDialog;
    Context cxt=null;
    TextView txtBalance;
    double available_balance;
    Button submitbtn;
    EditText txtRequire_money;
    int oooGetMoney;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_draw_money);
        //
        cxt=DrawMoney.this;
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
        tvInfo.setText(getString(R.string.draw_money));
        //
        Bundle bundle = this.getIntent().getExtras();
        available_balance = bundle.getDouble("available_balance");
        txtBalance=(TextView)findViewById(R.id.balance_money);
        txtRequire_money=(EditText) findViewById(R.id.editText);

        //
        showMoney();
        //
        submitbtn=(Button)findViewById(R.id.button2);
        submitbtn.setOnClickListener(submit_click);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cxt=null;
    }

    void showMoney()
    {
        //
        txtBalance.setText(getString(R.string.available_balance)+": "+(available_balance/100)+ getString(R.string.moneyft));
    }

    void GetNetData(int money)
    {
        if (loadDialog==null||!loadDialog.isShowing())
            loadDialog = DialogUIUtils.showLoading(DrawMoney.this,getString(R.string.Loading),true,false,false,true).show();

        oooGetMoney=money;
        web.getHtml(HTTPData.sMoneyUrl + "/drawmoney.i.php", "k=" + LoginInfo.verifyKey+"&money="+money+"&label=安卓APP提款");
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    public View.OnClickListener submit_click = new View.OnClickListener() {
        public void onClick(View v) {
            String str1= txtRequire_money.getText().toString();
            if(str1.equals(""))
            {
                AssertAlert.show(DrawMoney.this, R.string.alert, R.string.input_require_money);
            }
            else
            {
                double rmoney = Double.parseDouble(str1);
                if(rmoney>0) {
                    rmoney *= 100;
                    rmoney = (int) rmoney;
                    if(rmoney<=available_balance) {
                            //提款申请
                            GetNetData((int) rmoney);
                    }
                    else
                    {
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.input_require_money_notenough);
                    }
                }
                else
                {
                    AssertAlert.show(DrawMoney.this, R.string.alert, R.string.input_require_money_not0);
                }
            }
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
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.input_require_money_ok);
                        available_balance-=oooGetMoney;
                        //
                        showMoney();
                        txtRequire_money.setText("");
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                    case 5://金额必须大于0
                    {
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.input_require_money_not0);
                    }
                    break;
                    case 6://余额不足
                    {
                        AssertAlert.show(DrawMoney.this, R.string.alert, R.string.input_require_money_notenough);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(DrawMoney.this, getString(R.string.lost_json_parameter), e.getMessage());
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
