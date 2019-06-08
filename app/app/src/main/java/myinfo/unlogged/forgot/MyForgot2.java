package myinfo.unlogged.forgot;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

public class MyForgot2 extends BaseActivity
{

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_forgot2);

        //
        initToolbar(0,
                R.id.toolbarId,
                null,
                null,
                0,
                null,
                0,
                null);
        //
        Button btn=(Button)findViewById(R.id.btnDone);
        btn.setOnClickListener(oDoneClick);

    }

    private View.OnClickListener oDoneClick =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            // 关闭并反回结果
            Intent retData = new Intent();
            setResult(1, retData);
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    //带窗体反回结果
    @Override
    protected void onActivityResult(int requestCode, int ResultCode, Intent data) {
        super.onActivityResult(requestCode, ResultCode, data);
        // 关闭并反回结果
        Intent retData = new Intent();
        setResult(1, retData);
        finish();
        overridePendingTransition(R.anim.back_0, R.anim.back_1);
    }
}
