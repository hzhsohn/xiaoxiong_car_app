package android.zh.home;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.support.annotation.RequiresApi;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ProgressBar;

import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.util.EventListener;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Vector;

import ext.func.AssertAlert;
import ext.magr.ConfigMagr;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import ext.sys.AppRcInfo;

import static android.app.Activity.RESULT_OK;

/**
 * Created by h.zh on 2017/07/30.
 * 当前版本信息
 */

public class VersionInfo {

    //当前APK版本信息,这个数值对应网站上面的那个版本号,如果不一置会提示重复下载
    public String current_apk_veriosn;


    /**
     * 版本更新
     */
    private String web_apk_veriosn;
    // 下载进度条
    private ProgressBar progressBar;
    // 是否终止下载
    private boolean isInterceptDownload = false;
    //进度条显示数值
    private int progress = 0;
    //获取的下载链接
    private String apkDwonloadUrl ;
    //保存位置
    public String saveFilePath;
    //
    AlertDialog dia ;

    private Context _cxt;
    private WebProc web;

    private Vector eventListener = new Vector();
    public void addListener(Object listener) {
        eventListener.add(listener);
    }

    private void is_need_update_cb(final boolean b) {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                Iterator iterator = eventListener.iterator();
                while (iterator.hasNext()) {
                    VersionListener sl = (VersionListener) iterator.next();
                    sl.is_need_update_cb(b);
                }
            }
        });
    }

    private void web_fail_cb() {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                Iterator iterator = eventListener.iterator();
                while (iterator.hasNext()) {
                    VersionListener sl = (VersionListener) iterator.next();
                    sl.web_fail_cb();
                }
            }
        });
    }


    //下载完成回调
    private void download_ok_notify() {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                Iterator iterator = eventListener.iterator();
                while (iterator.hasNext()) {
                    VersionListener sl = (VersionListener) iterator.next();
                    sl.download_ok();
                }
            }
        });
    }

    public VersionInfo(Context cxt,VersionListener cb)
    {
        try {
            String pkName = cxt.getPackageName();
            current_apk_veriosn = cxt.getPackageManager().getPackageInfo(pkName, 0).versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        if(current_apk_veriosn.equals(""))
        {return;}

        _cxt=cxt;
        addListener(cb);

        web = new WebProc();
        web.addListener(wls);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                checkNewVersion();//自动检测版本更新
            }
        }, 2000);
    }

    //检测是否有更新
    void checkNewVersion() {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                web.getHtml(HTTPData.sUpdateUrl+"/android_ver.txt","");
            }
        });
    }

    //检测是否有更新回调
    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {
            //
            JSONObject person = null;
            try {
                person = new JSONObject(html);
                String webVer = person.getString("ver");
                String apkURL = person.getString("url");
                if(webVer!=null && !webVer.equals(""))
                {
                    web_apk_veriosn=webVer;
                    doCheckVersion(webVer,apkURL);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            web_fail_cb();
        }
    };

    /**
     * 声明一个handler来跟进进度条
     */
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0x111:
                    // 更新进度情况
                    progressBar.setProgress(progress);
                    break;
                case 0x222:
                    dia.setTitle(R.string.ver_download_ok);
                    progressBar.setVisibility(View.INVISIBLE);
                    // 通知下载完成
                    download_ok_notify();
                    break;
                default:
                    break;
            }
        }
    };


    /**
     * 版本更新请求
     */
    private void doCheckVersion(String version,String furl) {
        //如果当前的版本号小于服务器的版本号就弹出版本更新dialog
        if (!current_apk_veriosn.equals(version)) {
            Log.d("update","版本需要更新");
            is_need_update_cb(true);
            apkDwonloadUrl=furl;
            showUpdateDialog();
        } else {
            Log.d("update","此版本为最新版本，无需更新");
            is_need_update_cb(false);
        }
    }

    /**
     * 提示更新对话框
     * <p/>
     * 版本信息对象
     */
    private void showUpdateDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(_cxt);
        builder.setTitle(R.string.versionUpdate);
        builder.setMessage(_cxt.getString(R.string.downloadVersionCode)+" "+web_apk_veriosn+
                "\r\n"+
                _cxt.getString(R.string.curVersionCode)+" "+AppRcInfo.getAppVersionName(_cxt)
        );
        builder.setCancelable(false);
        builder.setPositiveButton(R.string.download, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                // 弹出下载框
                showDownloadDialog();
            }
        });
        builder.setNegativeButton(R.string.talkLater, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        builder.create().show();
    }

    /**
     * 弹出下载框
     */
    private void showDownloadDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(_cxt);
        builder.setTitle(R.string.versionUpdateing);
        builder.setCancelable(false);
        final LayoutInflater inflater = LayoutInflater.from(_cxt);
        View v = inflater.inflate(R.layout.activity_update_prgress, null);
        progressBar = (ProgressBar) v.findViewById(R.id.pb_update_progress);
        builder.setView(v);
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                //终止下载
                isInterceptDownload = true;
            }
        });
        builder.create();
        dia = builder.show();
        //下载apk
        downloadApk();
    }


    /**
     * 下载apk
     */
    private void downloadApk() {
        //开启另一线程下载
        Thread downLoadThread = new Thread(downApkRunnable);
        downLoadThread.start();
    }

    /**
     * 从服务器下载新版apk的线程
     */
    private Runnable downApkRunnable = new Runnable() {
        @Override
        public void run() {
            if (!Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
                //如果没有SD卡
                AlertDialog.Builder builder = new AlertDialog.Builder(_cxt);
                builder.setTitle(R.string.houseKeeperHint);
                builder.setMessage(R.string.loadHintInfo);
                builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
                builder.show();
            } else {
                try {
                    //服务器上新版apk地址
                    java.net.URL url = new java.net.URL(apkDwonloadUrl);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.connect();
                    int length = conn.getContentLength();
                    InputStream is = conn.getInputStream();
                    File file = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/Download/");
                    if (!file.exists()) {
                        //如果文件夹不存在,则创建
                        file.mkdir();
                    }
                    //下载服务器中新版本软件（写文件）
                    saveFilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/Download/" +web_apk_veriosn+".apk";
                    File ApkFile = new File(saveFilePath);
                    FileOutputStream fos = new FileOutputStream(ApkFile);
                    int count = 0;
                    byte buf[] = new byte[1024];
                    do {
                        int numRead = is.read(buf);
                        count += numRead;
                        //更新进度条
                        progress = (int) (((float) count / length) * 100);
                        android.os.Message message_ = new android.os.Message();
                        message_.what = 0x111;
                        handler.sendMessage(message_);
                        if (numRead <= 0) {
                            //下载完成通知安装
                            android.os.Message message = new android.os.Message();
                            message.what = 0x222;
                            handler.sendMessage(message);
                            break;
                        }
                        fos.write(buf, 0, numRead);
                        //当点击取消时，则停止下载
                    } while (!isInterceptDownload);
                } catch (MalformedURLException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    };

    /**
     * 安装apk
     */
    public void installApk() {
        // 获取当前sdcard存储路径
        File apkFile = new File(saveFilePath);
        if (!apkFile.exists()) {
            return;
        }
        VersionApkController.install(saveFilePath,_cxt);
        //隐藏更新框
        dia.dismiss();
    }
}
