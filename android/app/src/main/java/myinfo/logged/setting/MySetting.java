package myinfo.logged.setting;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import myinfo.logic.LoginInfo;
import myinfo.logged.setting.account.AccountSafe;

public class MySetting extends BaseActivity {

    Context context;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_setting);
        //
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
        findViewById(R.id.row1).setOnClickListener(account_click);
        findViewById(R.id.row2_0).setOnClickListener(about_software_click);
        findViewById(R.id.row2).setOnClickListener(freeback_click);
        findViewById(R.id.row3).setOnClickListener(loginout_click);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener account_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //跳到下一个窗体
            Intent intent = new Intent(MySetting.this, AccountSafe.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 1000);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
    private View.OnClickListener about_software_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
        }
    };
    private View.OnClickListener freeback_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //跳到下一个窗体
        }
    };
    private View.OnClickListener loginout_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //退出用户
            LoginInfo.clearLoginCfg(context);
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };
}
