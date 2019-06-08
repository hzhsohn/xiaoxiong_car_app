package myinfo.qrscan.result;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.hx_kong.freesha.R;

import myinfo.qrscan.zxing.android.CaptureActivity;

public class QRText extends BaseActivity {

    private static final String DECODED_CONTENT_KEY = "codedContent";
    private static final String DECODED_BITMAP_KEY = "codedBitmap";
    TextView txtResult=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_qrscan_text);
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
        txtResult= (TextView) findViewById(R.id.txt1);
        //
        String content = this.getIntent().getStringExtra(DECODED_CONTENT_KEY);
        Bitmap bitmap = this.getIntent().getParcelableExtra(DECODED_BITMAP_KEY);

        txtResult.setText(content);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

}
