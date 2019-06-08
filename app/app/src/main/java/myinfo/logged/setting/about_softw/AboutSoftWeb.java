package myinfo.logged.setting.about_softw;

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
import com.hx_kong.freesha.R;

import com.dou361.dialogui.DialogUIUtils;

import ext.magr.HTTPData;
import myinfo.logic.LoginInfo;

public class AboutSoftWeb extends BaseActivity {
    Context context = null;
    WebView webView = null;
    Dialog loadDialog;
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
        TextView tvInfo = (TextView)findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.func_introduce));
        //
        //WEBView浏览器
        webView = (WebView) findViewById(R.id.webView);
        String urlstr ="http://home.hx-kong.com/about_software";
        webView.loadUrl(urlstr);
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
                loadDialog = DialogUIUtils.showLoading(AboutSoftWeb.this,getString(R.string.Loading),true,false,false,true).show();

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
