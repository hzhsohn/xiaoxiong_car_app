package android.zh.b;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import com.dou361.dialogui.DialogUIUtils;

import java.util.Timer;
import java.util.TimerTask;

import myinfo.logic.LoginInfo;


public class H5Web_acty extends BaseActivity {

    Context context = null;
    WebView webView = null;
    Dialog loadDialog;
    String my_url;
    Timer timer=null;

    private ValueCallback<Uri> uploadMessage;
    private ValueCallback<Uri[]> uploadMessageAboveL;
    private final static int FILE_CHOOSER_RESULT_CODE = 10000;

    private TimerTask taskReloadPage = new TimerTask() {
        public void run() {

            //重新加载一次页面
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    //已在主线程中，可以更新UI
                    webView.loadUrl(my_url);
                }
            });

            System.gc();
        }
    };

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
        ((Toolbar)findViewById(R.id.toolbarId)).setVisibility(View.GONE);
        //
        //
        Bundle bundle = this.getIntent().getExtras();
        my_url = bundle.getString("url");
        //
        //WEBView浏览器
        webView = (WebView) findViewById(R.id.webView);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        //设置缓存模式
        //webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        //
        timer = new Timer();
        timer.schedule(taskReloadPage, 0,5000);

        //覆盖WebView默认使用第三方或系统默认浏览器打开网页的行为，使网页用WebView打开
        webView.setWebViewClient(new WebViewClient() {

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String urls) {

                if (urls.startsWith("newtab:")) {
                    //在这里拦截加了newtab:前缀的URL，来进行你要做的操作
                    //利用replace（）方法去掉前缀
                    String newurl=urls.replace("newtab:","");

                    Intent intent = new Intent(context, H5Web_acty.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    bundle.putString("url",newurl);
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivity(intent);
                    overridePendingTransition(R.anim.in_0, R.anim.in_1);

                }
                else {
                    view.loadUrl(urls); //如果是没有加那个前缀的就正常
                }
                return true;
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

                //设置标题
                TextView tvInfo = (TextView)findViewById(R.id.toolbar_title);
                tvInfo.setText(view.getTitle());

                //页面加载完成后加载下面的javascript，修改页面中所有用target="_blank"标记的url（在url前加标记为“newtab”）
                //这里要注意一下那个js的注入方法，不要在最后面放那个替换的方法，不然会出错
                view.loadUrl("javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.href = 'newtab:'+link.href;link.setAttribute('target','_self');}}}");

                //
                String key = LoginInfo.cfgVerifyKey(context);
                view.loadUrl( "javascript: function userkey(){return '"+key+"';}");

                timer.cancel(); //退出计时器
                timer=null;
            }

        });

        webView.setWebChromeClient(new WebChromeClient() {

            // For Android < 3.0
            public void openFileChooser(ValueCallback<Uri> valueCallback) {
                uploadMessage = valueCallback;
                openImageChooserActivity();
            }

            // For Android  >= 3.0
            public void openFileChooser(ValueCallback valueCallback, String acceptType) {
                uploadMessage = valueCallback;
                openImageChooserActivity();
            }

            //For Android  >= 4.1
            public void openFileChooser(ValueCallback<Uri> valueCallback, String acceptType, String capture) {
                uploadMessage = valueCallback;
                openImageChooserActivity();
            }

            // For Android >= 5.0
            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams) {
                uploadMessageAboveL = filePathCallback;
                openImageChooserActivity();
                return true;
            }

            /**
             * 处理alert弹出框
             */
            @Override
            public boolean onJsAlert(WebView view, String url,
                                     String message, JsResult result) {

                if (message.startsWith("cmd:")) {
                    //在这里拦截加了newtab:前缀的URL，来进行你要做的操作
                    //利用replace（）方法去掉前缀
                    String newmsg=message.replace("cmd:","");

                    if(newmsg.equals("closefrm"))
                    {
                        finish();
                        overridePendingTransition(R.anim.back_0, R.anim.back_1);
                    }
                    else if(newmsg.equals("loginout"))
                    {
                        LoginInfo.clearLoginCfg(context);
                    }
                }
                else {
                    Log.d("", "onJsAlert:" + message);
                    //对alert的简单封装
                    new AlertDialog.Builder(H5Web_acty.this).
                            setTitle("提示").setMessage(message).setPositiveButton("确定",
                            new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface arg0, int arg1) {
                                    //TODO
                                }
                            }).create().show();

                }

                result.confirm();
                result.cancel();
                return true;
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



    private void openImageChooserActivity() {
        Intent i = new Intent(Intent.ACTION_GET_CONTENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        i.setType("image/*");
        startActivityForResult(Intent.createChooser(i, "Image Chooser"), FILE_CHOOSER_RESULT_CODE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == FILE_CHOOSER_RESULT_CODE) {
            if (null == uploadMessage && null == uploadMessageAboveL) return;
            Uri result = data == null || resultCode != RESULT_OK ? null : data.getData();
            if (uploadMessageAboveL != null) {
                onActivityResultAboveL(requestCode, resultCode, data);
            } else if (uploadMessage != null) {
                uploadMessage.onReceiveValue(result);
                uploadMessage = null;
            }
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void onActivityResultAboveL(int requestCode, int resultCode, Intent intent) {
        if (requestCode != FILE_CHOOSER_RESULT_CODE || uploadMessageAboveL == null)
            return;
        Uri[] results = null;
        if (resultCode == Activity.RESULT_OK) {
            if (intent != null) {
                String dataString = intent.getDataString();
                ClipData clipData = intent.getClipData();
                if (clipData != null) {
                    results = new Uri[clipData.getItemCount()];
                    for (int i = 0; i < clipData.getItemCount(); i++) {
                        ClipData.Item item = clipData.getItemAt(i);
                        results[i] = item.getUri();
                    }
                }
                if (dataString != null)
                    results = new Uri[]{Uri.parse(dataString)};
            }
        }
        uploadMessageAboveL.onReceiveValue(results);
        uploadMessageAboveL = null;
    }

}
