package android.zh.b;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import com.dou361.dialogui.DialogUIUtils;


public class H5Web_acty extends BaseActivity {
    Context context = null;
    WebView webView = null;
    Dialog loadDialog;
    String my_title;
    String my_url;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_webview);
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
        //
        Bundle bundle = this.getIntent().getExtras();
        my_title = bundle.getString("title");
        my_url = bundle.getString("url");
        //
        TextView tvInfo = (TextView)findViewById(R.id.toolbar_title);
        tvInfo.setText(my_title);
        //
        //WEBView浏览器
        webView = (WebView) findViewById(R.id.webView);
        webView.loadUrl(my_url);
        //覆盖WebView默认使用第三方或系统默认浏览器打开网页的行为，使网页用WebView打开
        webView.setWebViewClient(new WebViewClient() {

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                return super.shouldOverrideUrlLoading(view, request);
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                if (loadDialog==null||!loadDialog.isShowing())
                loadDialog = DialogUIUtils.showLoading(H5Web_acty.this,getString(R.string.Loading),true,false,false,true).show();

            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                if (loadDialog!=null&&loadDialog.isShowing())
                    loadDialog.cancel();

            }
        });
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };
}
