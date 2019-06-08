package myinfo.logged.setting.account;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import myinfo.logic.LoginInfo;

public class AccountSafe extends BaseActivity {
    Context context = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_account_safe);
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
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.title_account_safe));
        //
        View row3 = (View) findViewById(R.id.row3);
        row3.setOnClickListener(row3_click);
        View row4 = (View) findViewById(R.id.row4);
        row4.setOnClickListener(row4_click);
    }

    @Override
    protected void onResume() {
        super.onResume();
        showInfo();
    }

    //显示在界面上
    void showInfo() {
        //
        TextView txtuid = (TextView) findViewById(R.id.userid);
        TextView txtem = (TextView) findViewById(R.id.em);
        TextView txtmob = (TextView) findViewById(R.id.mob);
        TextView txtcreatetime = (TextView) findViewById(R.id.createtime);
        //
        String uid = LoginInfo.infokey.get("userid");
        if (uid != null) {
            txtuid.setText(uid);
        }
        //
        String em = LoginInfo.infokey.get("email");
        if (em != null) {
            txtem.setText(em);
        }
        String mob = LoginInfo.infokey.get("phone");
        if (mob != null) {
            txtmob.setText(mob);
        }
        String createtime = LoginInfo.infokey.get("createtime");
        if (createtime != null) {
            txtcreatetime.setText(createtime);
        }
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener row3_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //跳到下一个窗体
            Intent intent = new Intent(AccountSafe.this, ModifyPhone.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 100);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
    private View.OnClickListener row4_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //跳到下一个窗体
            Intent intent = new Intent(AccountSafe.this, ModifyPasswd.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 200);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
}
