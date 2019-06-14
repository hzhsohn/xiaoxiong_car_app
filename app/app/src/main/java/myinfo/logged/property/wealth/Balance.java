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
import myinfo.logged.property.bill.BillList;
import myinfo.logic.LoginInfo;
import myinfo.unlogged.reg.MyReg;

public class Balance extends BaseActivity {
    WebProc web=null;
    Dialog loadDialog;
    Context cxt=null;
    TextView txtIncome;
    TextView txtExpend;
    TextView txtBalance;
    double balance_money;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_balance);
        //
        cxt=Balance.this;
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
        tvInfo.setText(getString(R.string.wealth_magr));

        txtIncome=(TextView)findViewById(R.id.income_year);
        txtExpend=(TextView)findViewById(R.id.expend_year);
        txtBalance=(TextView)findViewById(R.id.balance_money);
        //
        View rowBtn1 = findViewById(R.id.rowBtn1);
        rowBtn1.setOnClickListener(rowBtn1_click);
        //
        View rowBtn2 = findViewById(R.id.rowBtn2);
        rowBtn2.setOnClickListener(rowBtn2_click);
        //
        if (loadDialog==null||!loadDialog.isShowing())
            loadDialog = DialogUIUtils.showLoading(Balance.this,getString(R.string.Loading),true,false,false,true).show();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cxt=null;
    }

    @Override
    protected void onResume() {
        super.onResume();
        //获取CAID列表
        GetNetData();
    }

    void GetNetData()
    {

        web.getHtml(HTTPData.sMoneyUrl + "/balance.i.php", "k=" + LoginInfo.verifyKey);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    public View.OnClickListener rowBtn1_click = new View.OnClickListener() {
        public void onClick(View v) {
            Intent intent = new Intent(Balance.this, BillList.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            startActivity(intent);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    public View.OnClickListener rowBtn2_click = new View.OnClickListener() {
        public void onClick(View v) {
            Intent intent = new Intent(Balance.this, DrawMoney.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putDouble("balance_money",balance_money);
            intent.putExtras(bundle);//附带上额外的数据
            startActivity(intent);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
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
                        String userid=person.getString("userid");
                        double income_year=person.getDouble("income_year"); //今年内收入
                        double expend_year=person.getDouble("expend_year"); //今年内支出
                        balance_money=person.getDouble("balance_money"); //可取余额
                        txtIncome.setText(getString(R.string.income_year)+": "+ income_year/100.0f + getString(R.string.moneyft));
                        txtExpend.setText(getString(R.string.expend_year)+": "+ expend_year/100.0f + getString(R.string.moneyft));
                        txtBalance.setText(balance_money/100.0f + getString(R.string.moneyft));
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(Balance.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(Balance.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(Balance.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(Balance.this, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();

            if(null!=cxt) {
                //
                Toast.makeText(Balance.this, getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
                //3秒后重新获取
                Timer timer = new Timer();
                TimerTask task = new TimerTask() {
                    @Override
                    public void run() {
                        Handler mainHandler = new Handler(Looper.getMainLooper());
                        mainHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                //已在主线程中，可以更新UI
                                GetNetData();
                            }
                        });
                    }
                };
                timer.schedule(task, 3000);//此处的Delay
            }
        }
    };


}
