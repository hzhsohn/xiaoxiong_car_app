package myinfo.unlogged.reg;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import ext.func.AssertAlert;

public class MyRegByEmail extends BaseActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_reg_by_email);
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
        Button btn=(Button)findViewById(R.id.btnNext);
        btn.setOnClickListener(oNextClick);

    }

    private View.OnClickListener onBackClick =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0,R.anim.back_1);
        }
    };

    private View.OnClickListener oNextClick =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            TextView txt1 = (TextView)findViewById(R.id.txt_account);
            TextView txt2 = (TextView)findViewById(R.id.txt_nickname);

            if (txt1.getText().toString().equals(""))
            {
                // 提示框
                AssertAlert.show(MyRegByEmail.this, R.string.alert, R.string.msg_not_null_email);
                return ;
            }

            if (txt2.getText().toString().equals(""))
            {
                AssertAlert.show(MyRegByEmail.this,R.string.msg_alert,R.string.msg_not_null_nickname);
                return ;
            }

            Intent intent = new Intent(MyRegByEmail.this, MyRegByEmail2.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("email",txt1.getText().toString());
            bundle.putString("nickname",txt2.getText().toString());
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent,1000);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    //带窗体反回结果
    @Override
    protected void onActivityResult(int requestCode, int ResultCode, Intent data) {
        super.onActivityResult(requestCode, ResultCode, data);

        if(1==ResultCode) {
            // 关闭并反回结果
            Intent retData = new Intent();
            setResult(1, retData);
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    }
}
