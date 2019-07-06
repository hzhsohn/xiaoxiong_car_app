package myinfo.unlogged.forgot;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.zh.home.BaseActivity;

import com.hx_kong.freesha.R;

import ext.func.AssertAlert;

public class MyForgot extends BaseActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_forgot);
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
        Button btn1=(Button)findViewById(R.id.btnNext1);
        btn1.setOnClickListener(oNext1Click);
        //
        Button btn2=(Button)findViewById(R.id.btnNext2);
        btn2.setOnClickListener(oNext2Click);
    }

    private View.OnClickListener onBackClick =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0,R.anim.back_1);
        }
    };

    private View.OnClickListener oNext1Click =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            Intent intent = new Intent(MyForgot.this, MyForgotEMail.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent,1000);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
    private View.OnClickListener oNext2Click =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            Intent intent = new Intent(MyForgot.this, MyForgotPhone.class);
            Bundle bundle = new Bundle();//该类用作携带数据
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
