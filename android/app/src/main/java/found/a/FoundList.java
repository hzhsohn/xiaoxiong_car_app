package found.a;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Message;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.zh.b.H5Web_acty;
import android.zh.home.BaseFragment;

import com.dou361.dialogui.DialogUIUtils;
import com.xiaoxiongcar.R;

import ext.magr.HTTPData;
import myinfo.logic.LoginInfo;


public class FoundList extends BaseFragment {
    Context context = null;
    WebView webView = null;
    Dialog loadDialog;
    View g_view=null;

    public static FoundList newInstance(String param1) {
        FoundList fragment = new FoundList();
        Bundle args = new Bundle();
        args.putString("info", param1);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fgm_found_main, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        //
        initToolbar(view,
                0,
                R.id.toolbarId,
                null,
                null,
                0,
                null,
                0,
                null);
        ((Toolbar)view.findViewById(R.id.toolbarId)).setVisibility(View.GONE);
        //
        context = view.getContext();
        //
        TextView tvInfo = (TextView) view.findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.tiile_found));
        g_view=view;
        //
        String urlstr;
        String key = LoginInfo.cfgVerifyKey(context);
        //WEBView浏览器
        webView = (WebView) view.findViewById(R.id.webView);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        //设置缓存模式
        //webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        //
        webSettings.setDomStorageEnabled(true);  // 开启 DOM storage 功能
        webSettings.setAppCacheMaxSize(1024*1024*8);
        String appCachePath = context.getApplicationContext().getCacheDir().getAbsolutePath();
        webSettings.setAppCachePath(appCachePath);
        webSettings.setAllowFileAccess(true);    // 可以读取文件缓存
        webSettings.setAppCacheEnabled(true);    //开启H5(APPCache)缓存功能

        if(key.equals("")) {
            urlstr = HTTPData.sWebPhoneUrl_Index;
        }
        else
        {
            urlstr=HTTPData.sWebPhoneUrl_Index+"/?key=" + key;
        }

        webView.loadUrl(urlstr);
        //覆盖WebView默认使用第三方或系统默认浏览器打开网页的行为，使网页用WebView打开
        webView.setWebViewClient(new WebViewClient() {

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String urls) {

                if (urls.startsWith("newtab:")) {
                    //在这里拦截加了newtab:前缀的URL，来进行你要做的操作
                    //利用replace（）方法去掉前缀
                    String newurl=urls.replace("newtab:","");

                    Intent intent = new Intent(getActivity(), H5Web_acty.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    bundle.putString("url",newurl);
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivityFromFragment(intent, (byte) 0, (byte) 111);
                    getActivity().overridePendingTransition(R.anim.in_0, R.anim.in_1);

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
                    loadDialog = DialogUIUtils.showLoading(context,getString(R.string.Loading),true,false,false,true).show();

            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                if (loadDialog!=null&&loadDialog.isShowing())
                    loadDialog.cancel();


                //设置标题
                TextView tvInfo = (TextView)g_view.findViewById(R.id.toolbar_title);
                tvInfo.setText(view.getTitle());

                //页面加载完成后加载下面的javascript，修改页面中所有用target="_blank"标记的url（在url前加标记为“newtab”）
                //这里要注意一下那个js的注入方法，不要在最后面放那个替换的方法，不然会出错
                view.loadUrl("javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.href = 'newtab:'+link.href;link.setAttribute('target','_self');}}}");
                //
                String key = LoginInfo.cfgVerifyKey(context);
                view.loadUrl( "javascript: function userkey(){return '"+key+"';}");
            }
        });


        webView.setWebChromeClient(new WebChromeClient() {

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

                    if(newmsg.equals("loginout"))
                    {
                        LoginInfo.clearLoginCfg(context);
                    }
                    else if (newmsg.equals("token:"))
                    {
                        String szKey=newmsg.replace("token:","");
                        LoginInfo.saveVerifyKey(context,szKey);
                        LoginInfo.saveKeyAliveNow();
                    }
                }
                else if(message.startsWith("url:"))
                {
                    String newurl=message.replace("url:","");

                    Intent intent = new Intent(getActivity(), H5Web_acty.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    bundle.putString("url",newurl);
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivityFromFragment(intent, (byte) 0, (byte) 111);
                    getActivity().overridePendingTransition(R.anim.in_0, R.anim.in_1);
                }
                else {
                    Log.d("", "onJsAlert:" + message);
                    //对alert的简单封装
                    new AlertDialog.Builder(context).
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


}
