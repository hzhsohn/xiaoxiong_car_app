package ext.qrscan.result;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

public class QRUrl extends BaseActivity {

    private static final String DECODED_CONTENT_KEY = "codedContent";
    private static final String DECODED_BITMAP_KEY = "codedBitmap";
    TextView txtResult=null;
    Button btn1=null;
    String urlContent;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_qrscan_url);
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
        btn1= (Button) findViewById(R.id.btn1);
        btn1.setOnClickListener(btn1Click);
        //
        urlContent = this.getIntent().getStringExtra(DECODED_CONTENT_KEY);
        Bitmap bitmap = this.getIntent().getParcelableExtra(DECODED_BITMAP_KEY);

        txtResult.setText(urlContent);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener btn1Click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            Uri content_url = Uri.parse(urlContent);
            intent.setData(content_url);
            startActivity(intent);
        }
    };

}
