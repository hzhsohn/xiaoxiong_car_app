package vip.a;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.zh.home.BaseFragment;

import com.dou361.dialogui.DialogUIUtils;
import com.xiaoxiongcar.R;

import ext.magr.HTTPData;
import myinfo.logic.LoginInfo;


public class MyVipList extends BaseFragment {
    Context context = null;
    WebView webView = null;
    Dialog loadDialog;

    public static MyVipList newInstance(String param1) {
        MyVipList fragment = new MyVipList();
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
        //
        context = view.getContext();
        //
        TextView tvInfo = (TextView) view.findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.tiile_found));

        //
        String urlstr;
        String key = LoginInfo.cfgVerifyKey(context);
        //WEBView浏览器
        webView = (WebView) view.findViewById(R.id.webView);
        if(key.equals("")) {
            urlstr = HTTPData.sWebPhoneUrl_JiZhao;
        }
        else
        {
            urlstr=HTTPData.sWebPhoneUrl_JiZhao+"/?key=" + key;
        }
        webView.loadUrl(urlstr);
        //覆盖WebView默认使用第三方或系统默认浏览器打开网页的行为，使网页用WebView打开
        webView.setWebViewClient(new WebViewClient()
        {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                return super.shouldOverrideUrlLoading(view, request);
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

            }
        });
    }


}
