package android.zh.b;

import android.Manifest;
import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.provider.Settings;
import android.support.annotation.RequiresApi;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.Toolbar;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.Privacy.AppUtil;
import android.zh.Privacy.PrivacyDialog;
import android.zh.Privacy.PrivacyPolicyActivity;
import android.zh.Privacy.SPUtil;
import android.zh.Privacy.TermsActivity;
import android.zh.home.BaseActivity;
import android.zh.home.MainActivity;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallAdapter;
import com.fm.openinstall.model.AppData;
import com.xiaoxiongcar.R;

import com.dou361.dialogui.DialogUIUtils;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import found.a.FoundList;
import myinfo.a.MyinfoH5_Web;
import myinfo.logic.LoginInfo;
import vip.a.VipList;

import android.zh.home.NoScrollViewPager;

import org.json.JSONException;
import org.json.JSONObject;


public class H5Web_acty extends BaseActivity {

    Context context = null;
    WebView webView = null;
    String my_url;
    Timer timer=null;
    SwipeRefreshLayout mSwipe=null;
    private static final int MY_PERMISSIONS_REQUEST_CALL_PHONE = 1;
    String telphone_number;
    //相机拍完后的相片路径
    private String mCM;
    private final static int FCR = 1;

    private ValueCallback<Uri> uploadMessage;
    private ValueCallback<Uri[]> uploadMessageAboveL;
    private final static int FILE_CHOOSER_RESULT_CODE = 10000;

    //隐私政策用的变量
    private String SP_PRIVACY = "sp_privacy";
    private String SP_VERSION_CODE = "sp_version_code";
    private boolean isCheckPrivacy = false;
    private long versionCode;
    private long currentVersionCode;


    private TimerTask taskReloadPage = new TimerTask() {
        public void run() {

            //重新加载一次页面
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    //已在主线程中，可以更新UI
                    Map extraHeaders = new HashMap();
                    extraHeaders.put("Referer", HTTPData.sWebHost);
                    webView.loadUrl(my_url, extraHeaders);
                }
            });

            System.gc();
        }
    };

    public void to_url(String url)
    {
        my_url=url;
        //
        timer = new Timer();
        timer.schedule(taskReloadPage, 0,5000);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_webview);
        context = this;
        KeyBoardListener.getInstance(this).init();
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
        StatusNavUtils.setStatusBarColor(H5Web_acty.this,0x30000000);

        //
        //mSwipe=findViewById(R.id.sf_layout);

        //WEBView浏览器
        webView = (WebView) findViewById(R.id.webView);

        /*
         * 设置下拉刷新的监听

        mSwipe.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                //刷新需执行的操作
                //刷新完成
                webView.reload();
                mSwipe.setRefreshing(false);
            }
        });
 */
        //设置WEB参数
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


        //
        Bundle bundle = this.getIntent().getExtras();
        to_url(bundle.getString("url"));

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
                    Map<String, String> extraHeaders = new HashMap<String, String>();
                    extraHeaders.put("Referer", HTTPData.sWebHost);
                    view.loadUrl(urls, extraHeaders);

                }

                // 如下方案可在非微信内部WebView的H5页面中调出微信支付
                if (urls.startsWith("weixin://wap/pay?")) {
                    Intent intent = new Intent();
                    intent.setAction(Intent.ACTION_VIEW);
                    intent.setData(Uri.parse(urls));
                    startActivity(intent);


                    Map<String, String> extraHeaders = new HashMap<String, String>();
                    extraHeaders.put("Referer", HTTPData.sWebHost);
                    view.loadUrl(my_url, extraHeaders);

                    return true;
                } else {
                    Map<String, String> extraHeaders = new HashMap<String, String>();
                    extraHeaders.put("Referer", HTTPData.sWebHost);
                    view.loadUrl(urls, extraHeaders);
                }

                return true;
            }


            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
              //  if (loadDialog==null||!loadDialog.isShowing())
               // loadDialog = DialogUIUtils.showLoading(H5Web_acty.this,getString(R.string.Loading),true,false,false,true).show();

            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
             //   if (loadDialog!=null&&loadDialog.isShowing())
             //       loadDialog.cancel();

                //设置标题
                TextView tvInfo = (TextView)findViewById(R.id.toolbar_title);
                tvInfo.setText(view.getTitle());

                //页面加载完成后加载下面的javascript，修改页面中所有用target="_blank"标记的url（在url前加标记为“newtab”）
                //这里要注意一下那个js的注入方法，不要在最后面放那个替换的方法，不然会出错
                view.loadUrl("javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.href = 'newtab:'+link.href;link.setAttribute('target','_self');}}}");


                String key = LoginInfo.cfgVerifyKey(context);
                view.loadUrl( "javascript: function userkey(){return '"+key+"';}");

                if(null!=timer) {
                    timer.cancel(); //退出计时器
                    timer = null;
                }
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
                openImageChooserActivity5();
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
                    //执行指令
                    cmd_do(newmsg);

                }
                else if(message.startsWith("url:"))
                {
                    String newurl=message.replace("url:","");

                    Intent intent = new Intent(context, H5Web_acty.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    bundle.putString("url",newurl);
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivity(intent);
                    overridePendingTransition(R.anim.in_0, R.anim.in_1);
                }
                else if(message.startsWith("lurl:"))
                {
                    String newurl=message.replace("lurl:","");
                    my_url=newurl;

                    Map<String, String> extraHeaders = new HashMap<String, String>();
                    extraHeaders.put("Referer", HTTPData.sWebHost);
                    webView.loadUrl(my_url, extraHeaders);
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



        //SPUtil.put(H5Web_acty.this, SP_VERSION_CODE, 0L);
        //SPUtil.put(H5Web_acty.this, SP_PRIVACY, false);

        //隐私政策检测
        check();
    }
    /**
     * 显示隐私政策或跳转到其他界面
     */
    private void check() {

        //先判断是否显示了隐私政策
        currentVersionCode = AppUtil.getAppVersionCode(H5Web_acty.this);
        versionCode = (long) SPUtil.get(H5Web_acty.this, SP_VERSION_CODE, 0L);
        isCheckPrivacy = (boolean) SPUtil.get(H5Web_acty.this, SP_PRIVACY, false);

        if (!isCheckPrivacy || versionCode != currentVersionCode) {
            showPrivacy();
        } else {
            //Toast.makeText(H5Web_acty.this, getString(R.string.confirmed), Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * 显示用户协议和隐私政策
     */
    private void showPrivacy() {

        final PrivacyDialog dialog = new PrivacyDialog(H5Web_acty.this);
        TextView tv_privacy_tips = dialog.findViewById(R.id.tv_privacy_tips);
        TextView btn_exit = dialog.findViewById(R.id.btn_exit);
        TextView btn_enter = dialog.findViewById(R.id.btn_enter);
        dialog.show();

        String string = getResources().getString(R.string.privacy_tips);
        String key1 = getResources().getString(R.string.privacy_tips_key1);
        String key2 = getResources().getString(R.string.privacy_tips_key2);
        int index1 = string.indexOf(key1);
        int index2 = string.indexOf(key2);

        //需要显示的字串
        SpannableString spannedString = new SpannableString(string);
        //设置点击字体颜色
        ForegroundColorSpan colorSpan1 = new ForegroundColorSpan(Color.BLUE);
        spannedString.setSpan(colorSpan1, index1, index1 + key1.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        ForegroundColorSpan colorSpan2 = new ForegroundColorSpan(Color.BLUE);
        spannedString.setSpan(colorSpan2, index2, index2 + key2.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        //设置点击字体大小
        AbsoluteSizeSpan sizeSpan1 = new AbsoluteSizeSpan(18, true);
        spannedString.setSpan(sizeSpan1, index1, index1 + key1.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        AbsoluteSizeSpan sizeSpan2 = new AbsoluteSizeSpan(18, true);
        spannedString.setSpan(sizeSpan2, index2, index2 + key2.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        //设置点击事件
        ClickableSpan clickableSpan1 = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(H5Web_acty.this, TermsActivity.class);
                startActivity(intent);
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                //点击事件去掉下划线
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan1, index1, index1 + key1.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        ClickableSpan clickableSpan2 = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(H5Web_acty.this, PrivacyPolicyActivity.class);
                startActivity(intent);
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                //点击事件去掉下划线
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan2, index2, index2 + key2.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        //设置点击后的颜色为透明，否则会一直出现高亮
        tv_privacy_tips.setHighlightColor(Color.TRANSPARENT);
        //开始响应点击事件
        tv_privacy_tips.setMovementMethod(LinkMovementMethod.getInstance());

        tv_privacy_tips.setText(spannedString);

        //设置弹框宽度占屏幕的80%
        WindowManager m = getWindowManager();
        Display defaultDisplay = m.getDefaultDisplay();
        final WindowManager.LayoutParams params = dialog.getWindow().getAttributes();
        params.width = (int) (defaultDisplay.getWidth() * 0.80);
        dialog.getWindow().setAttributes(params);

        btn_exit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
                SPUtil.put(H5Web_acty.this, SP_VERSION_CODE, currentVersionCode);
                SPUtil.put(H5Web_acty.this, SP_PRIVACY, false);
                //finish();
                exitAPP();
            }
        });

        btn_enter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
                SPUtil.put(H5Web_acty.this, SP_VERSION_CODE, currentVersionCode);
                SPUtil.put(H5Web_acty.this, SP_PRIVACY, true);

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

    // Create an image file
    private File createImageFile() throws IOException {
        @SuppressLint("SimpleDateFormat") String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "img_" + timeStamp + "_";
        File storageDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
        return File.createTempFile(imageFileName, ".jpg", storageDir);
    }

    private void openImageChooserActivity5() {

        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(this.getPackageManager()) != null) {
            File photoFile = null;
            try {
                photoFile = createImageFile();
                takePictureIntent.putExtra("PhotoPath", mCM);
            } catch (IOException ex) {
                Log.e("", "Image file creation failed", ex);
            }
            if (photoFile != null) {
                mCM = "file:" + photoFile.getAbsolutePath();
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
            } else {
                takePictureIntent = null;
            }
        }
        Intent contentSelectionIntent = new Intent(Intent.ACTION_GET_CONTENT);
//                contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE);
        contentSelectionIntent.setType("image/*");
        Intent[] intentArray;
        if (takePictureIntent != null) {
            intentArray = new Intent[]{takePictureIntent};
        } else {
            intentArray = new Intent[0];
        }

        Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
        chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent);
        chooserIntent.putExtra(Intent.EXTRA_TITLE, "Image Chooser");
        chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);
        startActivityForResult(chooserIntent, FCR);
    }


    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
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
        else  if (requestCode == FCR) {
            Uri[] results = null;
            if(resultCode == Activity.RESULT_OK) {
                if (null == uploadMessageAboveL) return;

                if (data == null) {
                    //Capture Photo if no image available
                    if (mCM != null) {
                        results = new Uri[]{Uri.parse(mCM)};
                    }
                } else {
                    String dataString = data.getDataString();
                    if (dataString != null) {
                        results = new Uri[]{Uri.parse(dataString)};
                    }
                }
            }
            uploadMessageAboveL.onReceiveValue(results);
            uploadMessageAboveL = null;
            mCM = null;
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

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void exitAPP() {
        ActivityManager activityManager = (ActivityManager) context.getApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.AppTask> appTaskList = activityManager.getAppTasks();
        for (ActivityManager.AppTask appTask : appTaskList) {
            appTask.finishAndRemoveTask();
        }
    }
    //JS指令
    private void cmd_do(String command)
    {
        if(command.startsWith("closefrm"))
        {
            // alert("cmd:closefrm");
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
        else if(command.startsWith("closeapp"))
        {
            exitAPP();
        }
        else if(command.startsWith("startpage_clear"))
        {
            LoginInfo.saveStartPageDone(context,"");
        }
        else if(command.startsWith("startpage_done"))
        {
            LoginInfo.saveStartPageDone(context,"ok");
        }
        else if(command.startsWith("loginout"))
        {
            // alert("cmd:closefrm");
            LoginInfo.clearLoginCfg(context);
        }
        else if(command.startsWith("tel"))
        {
            String newmsg=command.replace("tel|","");
            String[] strArr = newmsg.split("\\|",-1);
            if(strArr.length>=1) {
                //电话功能
                telOpen(strArr[0]);
            }else{
                new AlertDialog.Builder(H5Web_acty.this).
                        setTitle("提示").setMessage("share 需要三个参数 cmd:share|分享|标题|我是分享的内容").setPositiveButton("确定",
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {
                                //TODO
                            }
                        }).create().show();
            }
        }
        else if(command.startsWith("share|"))
        {
            String newmsg=command.replace("share|","");
            // alert("cmd:share|分享url|标题|我是分享的内容http://www.hanzhihong.cn");
            String[] strArr = newmsg.split("\\|",-1);
            if(strArr.length>=3) {
                Share("分享", strArr[1], strArr[2]);
            }else{
                new AlertDialog.Builder(H5Web_acty.this).
                        setTitle("提示").setMessage("share 需要三个参数 cmd:share|分享url|标题|我是分享的内容").setPositiveButton("确定",
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {
                                //TODO
                            }
                        }).create().show();
            }
        }
        else if(command.startsWith("setitem|")) {
            String newmsg = command.replace("setitem|", "");
            // alert("cmd:setitem|0|撸啊撸");
            String[] strArr = newmsg.split("\\|", -1);
            if (strArr.length >= 2) {
                if (strArr[0].equals("0")) {
                    MainActivity.bottomNavigationView.getMenu().findItem(R.id.item_found)
                            .setTitle(strArr[1]);
                } else if (strArr[0].equals("1")) {
                    MainActivity.bottomNavigationView.getMenu().findItem(R.id.item_vip)
                            .setTitle(strArr[1]);
                } else if (strArr[0].equals("2")) {
                    MainActivity.bottomNavigationView.getMenu().findItem(R.id.item_my)
                            .setTitle(strArr[1]);
                }
            } else {
                new AlertDialog.Builder(H5Web_acty.this).
                        setTitle("提示").setMessage("setitem 需要两个参数 cmd:setitem|0|撸啊撸").setPositiveButton("确定",
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {
                                //TODO
                            }
                        }).create().show();
            }
        }
        else if(command.startsWith("noscroll"))
        {
            MainActivity.viewPager.setNoScroll(true);
        }
        else if(command.startsWith("scroll"))
        {
            MainActivity.viewPager.setNoScroll(false);
        }
        else if (command.startsWith("reload|"))
        {
            String page=command.replace("reload|","");
            if(page.equals("0"))
            {
                FoundList.webView.reload();
            }
            else if(page.equals("1"))
            {
                VipList.webView.reload();
            }
            else if(page.equals("2"))
            {
                MyinfoH5_Web.webView.reload();
            }
        }


    }


//////////////////////////////////////////////////////
    //第三方功能
    /**
     * Android原生分享功能
     * 默认选取手机所有可以分享的APP
     */
    public void Share(String digName,String title,String content){
        Intent share_intent = new Intent();
        share_intent.setAction(Intent.ACTION_SEND);//设置分享行为
        share_intent.setType("text/plain");//设置分享内容的类型
        share_intent.putExtra(Intent.EXTRA_SUBJECT, title);//添加分享内容标题
        share_intent.putExtra(Intent.EXTRA_TEXT, content);//添加分享内容
        //创建分享的Dialog
        share_intent = Intent.createChooser(share_intent, digName);
        startActivity(share_intent);
    }


    private void CallPhone() {
        if (TextUtils.isEmpty(telphone_number)) {
            // 提醒用户
            // 注意：在这个匿名内部类中如果用this则表示是View.OnClickListener类的对象，
            // 所以必须用H5Web_acty.this来指定上下文环境。
            Toast.makeText(H5Web_acty.this, "号码不能为空！", Toast.LENGTH_SHORT).show();
        } else {
            // 拨号：激活系统的拨号组件
            Intent intent = new Intent(); // 意图对象：动作 + 数据
            intent.setAction(Intent.ACTION_CALL); // 设置动作
            Uri data = Uri.parse("tel:" + telphone_number); // 设置数据
            intent.setData(data);
            startActivity(intent); // 激活Activity组件
        }
    }

    // 处理权限申请的回调
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode){
            case MY_PERMISSIONS_REQUEST_CALL_PHONE: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // 授权成功，继续打电话
                    CallPhone();
                } else {
                    // 授权失败！
                    Toast.makeText(this, "授权失败！", Toast.LENGTH_LONG).show();
                }
                break;
            }
        }

    }


    //
    public void telOpen(String phone) {
        telphone_number=phone;
        // 检查是否获得了权限（Android6.0运行时权限）
        if (ContextCompat.checkSelfPermission(H5Web_acty.this,
                Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED){
            // 没有获得授权，申请授权
            if (ActivityCompat.shouldShowRequestPermissionRationale(H5Web_acty.this,
                    Manifest.permission.CALL_PHONE)) {
                // 返回值：
//                          如果app之前请求过该权限,被用户拒绝, 这个方法就会返回true.
//                          如果用户之前拒绝权限的时候勾选了对话框中”Don’t ask again”的选项,那么这个方法会返回false.
//                          如果设备策略禁止应用拥有这条权限, 这个方法也返回false.
                // 弹窗需要解释为何需要该权限，再次请求授权
                Toast.makeText(H5Web_acty.this, "请授权！", Toast.LENGTH_LONG).show();

                // 帮跳转到该应用的设置界面，让用户手动授权
                Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                Uri uri = Uri.fromParts("package", getPackageName(), null);
                intent.setData(uri);
                startActivity(intent);
            }else{
                // 不需要解释为何需要该权限，直接请求授权
                ActivityCompat.requestPermissions(H5Web_acty.this,
                        new String[]{Manifest.permission.CALL_PHONE},
                        MY_PERMISSIONS_REQUEST_CALL_PHONE);
            }
        }else {
            // 已经获得授权，可以打电话
            CallPhone();
        }
    }
}
