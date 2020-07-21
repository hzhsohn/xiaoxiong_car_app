package android.zh.home;

import android.Manifest;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.RequiresApi;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Display;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.Privacy.AppUtil;
import android.zh.Privacy.PrivacyDialog;
import android.zh.Privacy.PrivacyPolicyActivity;
import android.zh.Privacy.SPUtil;
import android.zh.Privacy.TermsActivity;
import android.zh.b.H5Web_acty;
import android.zh.b.StatusNavUtils;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import found.a.FoundList;
import myinfo.a.MyinfoH5_Web;
import myinfo.logic.LoginInfo;
import vip.a.VipList;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppWakeUpAdapter;
import com.fm.openinstall.model.AppData;
import com.xiaoxiongcar.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Date;
import java.util.List;


public class MainActivity extends AppCompatActivity {

    private final int PERMISSION_ID=666;
    static public  NoScrollViewPager viewPager;
    private MenuItem menuItem;
    static public BottomNavigationView bottomNavigationView;

    VersionInfo ver;


/*
例子
File sdcardDir = Environment.getExternalStorageDirectory();
File sdcardDir = cxt.getCacheDir();
String path= sdcardDir.getPath()+"/mosquitto";
copyFilesFromAssets(cxt,"mosquitto",path);
*/
    public static void copyFilesFromAssets(Context context, String assetsPath, String savePath){
        try {
            String fileNames[] = context.getAssets().list(assetsPath);// 获取assets目录下的所有文件及目录名
            if (fileNames.length > 0) {// 如果是目录
                File file = new File(savePath);
                file.mkdirs();// 如果文件夹不存在，则递归
                for (String fileName : fileNames) {
                    copyFilesFromAssets(context, assetsPath + "/" + fileName,
                            savePath + "/" + fileName);
                }
            } else {// 如果是文件
                InputStream is = context.getAssets().open(assetsPath);
                FileOutputStream fos = new FileOutputStream(new File(savePath));
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {// 循环从输入流读取
                    // buffer字节
                    fos.write(buffer, 0, byteCount);// 将读取的输入流写入到输出流
                }
                fos.flush();// 刷新缓冲区
                is.close();
                fos.close();
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public static String createDir(String dirPath){
        //因为文件夹可能有多层，比如:  a/b/c/ff.txt  需要先创建a文件夹，然后b文件夹然后...
        try{
            File file=new File(dirPath);
            if(file.getParentFile().exists()){
                file.mkdir();
                return file.getAbsolutePath();
            }
            else {
                createDir(file.getParentFile().getAbsolutePath());
                file.mkdir();
            }

        }catch (Exception e){
            e.printStackTrace();
        }
        return dirPath;
    }
    public static String createFile(File file){
        try{
            if(file.getParentFile().exists()){
                file.createNewFile();
            }
            else {
                //创建目录之后再创建文件
                createDir(file.getParentFile().getAbsolutePath());
                file.createNewFile();
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return "";
    }

    public boolean isMainProcess() {
        int pid = android.os.Process.myPid();
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
            if (appProcess.pid == pid) {
                return getApplicationInfo().packageName.equals(appProcess.processName);
            }
        }
        return false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        StatusNavUtils.setStatusBarColor(MainActivity.this,0x00000000);

        // 获取唤醒参数
        OpenInstall.getWakeUp(getIntent(), wakeUpAdapter);

        //网页便捷控制和NFC的便捷控制
        Uri uri = getIntent().getData();
        if (uri != null)
        {
            String uriHostStr=uri.getHost().toString();
            if(uriHostStr.equals("www.daichepin.com")) {
                String para=uri.getQueryParameter("u");

                //弹出新窗体到注册
                Intent intent = new Intent(this, H5Web_acty.class);
                Bundle bundle = new Bundle();//该类用作携带数据
                //bundle.putString("url", HTTPData.sWebStartPage);
                String surl=uri.toString();
                bundle.putString("url", surl);
                intent.putExtras(bundle);//附带上额外的数据
                startActivity(intent);
                overridePendingTransition(R.anim.in_0, R.anim.in_1);

            }
        }


/////   /////////////////
        if(HTTPData.isTestApp)
        {
            HTTPData.sWeb=HTTPData.sWebTest;
        }
        else
        {
            HTTPData.sWeb = HTTPData.sWebOK;
        }

        //-------------------------
        HTTPData.sWebTestPage=HTTPData.sWebHost+"/testAAA.php";  //测试服务器
        HTTPData.sWebStartPage=HTTPData.sWebHost+"/startpage";  //测试服务器
        HTTPData.sWebPhoneUrl_Index=HTTPData.sWeb+"/webphone_index/#/common/index";
        HTTPData.sWebPhoneUrl_JiZhao=HTTPData.sWeb+"/webphone_vip/#/common/recommend";
        HTTPData.sWebPhoneUrl_Center=HTTPData.sWeb+"/webphone/#/client/center";
        HTTPData.sUpdateUrl=HTTPData.sWebHost+ "/app_update";

//web h5测试:
        if(HTTPData.isTestApp)
        {
            Intent intent = new Intent(this, H5Web_acty.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("url", HTTPData.sWebTestPage);
            intent.putExtras(bundle);//附带上额外的数据
            startActivity(intent);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
        else{
            //是否再次显示开始页
            if(!LoginInfo.readStartPageDone(this))
            {
                File sdcardDir = getBaseContext().getCacheDir();
                String path= sdcardDir.getPath()+"/startpage";
                copyFilesFromAssets(getBaseContext(),"startpage",path);

                //
                Intent intent = new Intent(this, H5Web_acty.class);
                Bundle bundle = new Bundle();//该类用作携带数据
                //bundle.putString("url", HTTPData.sWebStartPage);
                String surl="file:///"+path+"/index.html";
                bundle.putString("url", surl);
                intent.putExtras(bundle);//附带上额外的数据
                startActivity(intent);
                overridePendingTransition(R.anim.in_0, R.anim.in_1);
            }
            else
            {
                //---------------------------------
                //存储器
                if(0==checkPermission(PERMISSION_ID , Manifest.permission.WRITE_EXTERNAL_STORAGE))
                {
                    //--------------------------------
                    //检测更新
                    ver=new VersionInfo(MainActivity.this, new VersionListener() {

                        @Override
                        public void web_fail_cb() {

                        }

                        @Override
                        public void is_need_update_cb(boolean b) {

                        }

                        @Override
                        public void download_ok() {
                            installProcess();
                        }

                    });
                }

            }
        }

        /////////////////

        viewPager = (NoScrollViewPager) findViewById(R.id.viewpager);
        bottomNavigationView = (BottomNavigationView) findViewById(R.id.bottom_navigation);
        bottomNavigationView.setItemIconTintList(null);
        //禁用滑动
        viewPager.setNoScroll(true);

        //默认 >3 的选中效果会影响ViewPager的滑动切换时的效果，故利用反射去掉
        BottomNavigationViewHelper.disableShiftMode(bottomNavigationView);
        bottomNavigationView.setOnNavigationItemSelectedListener(
                new BottomNavigationView.OnNavigationItemSelectedListener() {
                    @Override
                    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.item_found:
                                viewPager.setCurrentItem(0);
                                bottomNavigationView.getMenu().findItem(R.id.item_found)
                                        .setIcon(R.drawable.a11) ;

                                bottomNavigationView.getMenu().findItem(R.id.item_vip)
                                        .setIcon(R.drawable.a2) ;

                                bottomNavigationView.getMenu().findItem(R.id.item_my)
                                        .setIcon(R.drawable.a3) ;

                                break;

                            case R.id.item_vip:
                                viewPager.setCurrentItem(1);
                                bottomNavigationView.getMenu().findItem(R.id.item_found)
                                        .setIcon(R.drawable.a1) ;

                                bottomNavigationView.getMenu().findItem(R.id.item_vip)
                                        .setIcon(R.drawable.a22) ;

                                bottomNavigationView.getMenu().findItem(R.id.item_my)
                                        .setIcon(R.drawable.a3) ;

                                break;

                            case R.id.item_my:
                                viewPager.setCurrentItem(2);
                                bottomNavigationView.getMenu().findItem(R.id.item_found)
                                        .setIcon(R.drawable.a1) ;

                                bottomNavigationView.getMenu().findItem(R.id.item_vip)
                                        .setIcon(R.drawable.a2) ;

                                bottomNavigationView.getMenu().findItem(R.id.item_my)
                                        .setIcon(R.drawable.a33) ;

                                break;
                        }
                        return false;
                    }
                });

        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                if (menuItem != null) {
                    menuItem.setChecked(false);
                } else {
                    bottomNavigationView.getMenu().getItem(0).setChecked(false);
                }
                menuItem = bottomNavigationView.getMenu().getItem(position);
                menuItem.setChecked(true);


                switch (position) {
                    case 0:
                        viewPager.setCurrentItem(0);
                        bottomNavigationView.getMenu().findItem(R.id.item_found)
                                .setIcon(R.drawable.a11) ;

                        bottomNavigationView.getMenu().findItem(R.id.item_vip)
                                .setIcon(R.drawable.a2) ;

                        bottomNavigationView.getMenu().findItem(R.id.item_my)
                                .setIcon(R.drawable.a3) ;

                        break;

                    case 1:
                        viewPager.setCurrentItem(1);
                        bottomNavigationView.getMenu().findItem(R.id.item_found)
                                .setIcon(R.drawable.a1) ;

                        bottomNavigationView.getMenu().findItem(R.id.item_vip)
                                .setIcon(R.drawable.a22) ;

                        bottomNavigationView.getMenu().findItem(R.id.item_my)
                                .setIcon(R.drawable.a3) ;

                        break;

                    case 2:
                        viewPager.setCurrentItem(2);
                        bottomNavigationView.getMenu().findItem(R.id.item_found)
                                .setIcon(R.drawable.a1) ;

                        bottomNavigationView.getMenu().findItem(R.id.item_vip)
                                .setIcon(R.drawable.a2) ;

                        bottomNavigationView.getMenu().findItem(R.id.item_my)
                                .setIcon(R.drawable.a33) ;

                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {


            }
        });

        //---------------------------------
        //初始化界面
        setupViewPager(viewPager);

        //系统重签名处理
        hookWebView();

    }

    //系统重签名处理
    public void hookWebView(){
        int sdkInt = Build.VERSION.SDK_INT;
        try {
            Class<?> factoryClass = Class.forName("android.webkit.WebViewFactory");
            Field field = factoryClass.getDeclaredField("sProviderInstance");
            field.setAccessible(true);
            Object sProviderInstance = field.get(null);
            if (sProviderInstance != null) {
                Log.i("hookWebView","sProviderInstance isn't null");
                return;
            }
            Method getProviderClassMethod;
            if (sdkInt > 22) {
                getProviderClassMethod = factoryClass.getDeclaredMethod("getProviderClass");
            } else if (sdkInt == 22) {
                getProviderClassMethod = factoryClass.getDeclaredMethod("getFactoryClass");
            } else {
                Log.i("hookWebView","Don't need to Hook WebView");
                return;
            }
            getProviderClassMethod.setAccessible(true);
            Class<?> factoryProviderClass = (Class<?>) getProviderClassMethod.invoke(factoryClass);
            Class<?> delegateClass = Class.forName("android.webkit.WebViewDelegate");
            Constructor<?> delegateConstructor = delegateClass.getDeclaredConstructor();
            delegateConstructor.setAccessible(true);
            if(sdkInt < 26){//低于Android O版本
                Constructor<?> providerConstructor = factoryProviderClass.getConstructor(delegateClass);
                if (providerConstructor != null) {
                    providerConstructor.setAccessible(true);
                    sProviderInstance = providerConstructor.newInstance(delegateConstructor.newInstance());
                }
            } else {
                Field chromiumMethodName = factoryClass.getDeclaredField("CHROMIUM_WEBVIEW_FACTORY_METHOD");
                chromiumMethodName.setAccessible(true);
                String chromiumMethodNameStr = (String)chromiumMethodName.get(null);
                if (chromiumMethodNameStr == null) {
                    chromiumMethodNameStr = "create";
                }
                Method staticFactory = factoryProviderClass.getMethod(chromiumMethodNameStr, delegateClass);
                if (staticFactory!=null){
                    sProviderInstance = staticFactory.invoke(null, delegateConstructor.newInstance());
                }
            }

            if (sProviderInstance != null){
                field.set("sProviderInstance", sProviderInstance);
                Log.i("hookWebView","Hook success!");
            } else {
                Log.i("hookWebView","Hook failed!");
            }
        } catch (Throwable e) {
            Log.w("hookWebView",e);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        // 此处要调用，否则App在后台运行时，会无法获取
        OpenInstall.getWakeUp(intent, wakeUpAdapter);
    }
    AppWakeUpAdapter wakeUpAdapter = new AppWakeUpAdapter() {
        @Override
        public void onWakeUp(AppData appData) {
            // 打印数据便于调试
            Log.d("OpenInstall", "getWakeUp : wakeupData = " + appData.toString());
            // 获取渠道数据
            String channelCode = appData.getChannel();
            // 获取绑定数据
            String bindData = appData.getData();
        }
    };
    @Override
    protected void onDestroy() {
        super.onDestroy();
        wakeUpAdapter = null;
    }

    //需要申请GETTask权限
    private boolean isApplicationBroughtToBackground() {
        ActivityManager am = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningTaskInfo> tasks = am.getRunningTasks(1);
        if (!tasks.isEmpty()) {
            ComponentName topActivity = tasks.get(0).topActivity;
            if (!topActivity.getPackageName().equals(getPackageName())) {
                return true;
            }
        }
        return false;
    }
    public boolean wasBackground= false;    //声明一个布尔变量,记录当前的活动背景
    @Override public void onPause()
    {
        super.onPause();
        if(isApplicationBroughtToBackground())
            wasBackground= true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(wasBackground){//
            Log.e("aa","从后台回到前台");
            //超过60秒就刷新
            if(FoundList.webView!=null) {
                Date endDate = new Date(System.currentTimeMillis());
                long diff = endDate.getTime() - FoundList.reloadLastTime;

                //1秒不动作就重新刷新
               // if(diff>1) {
                    Log.e("aa","刷新所有web内容");
                    FoundList.webView.loadUrl(HTTPData.sWebPhoneUrl_Index);
                    VipList.webView.loadUrl(HTTPData.sWebPhoneUrl_JiZhao);
                    MyinfoH5_Web.webView.loadUrl(HTTPData.sWebPhoneUrl_Center);
                //}
            }
        }
        wasBackground= false;
    }

    /*
    * return 1权限重新请求通过
    *        2权限被永久拒绝,要到设置里面手动设置
    *        0已经拥有该权限
    * */
    int  checkPermission(int deniedRebackID,String Manifest_permission_xxx) {
        if (ContextCompat.checkSelfPermission(this,
                Manifest_permission_xxx) != PackageManager.PERMISSION_GRANTED) {

            //请求权限
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest_permission_xxx},
                    deniedRebackID);

            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest_permission_xxx)) {
                return 1;
            } else {
                Log.v("checkPermission",Manifest_permission_xxx+" don't ask again");
                return 2;
            }
        }
        return 0;
    }

    //回调
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_ID: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    //摄像头
                    checkPermission(PERMISSION_ID+1 ,Manifest.permission.CAMERA);
                } else {
                    //请求权限被拒绝
                    AssertAlert.show(this, R.string.alert, R.string.no_strong_permission_do_myself, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                            intent.setData(Uri.parse("package:" + getPackageName())); // 根据包名打开对应的设置界面
                            startActivity(intent);
                            //退出APP
                            System.exit(0);
                        }
                    });
                }
                break;
            }
            case PERMISSION_ID+1:
                break;
        }
    }

    private void setupViewPager(final ViewPager viewPager) {
        //加载界面
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());

        adapter.addFragment(FoundList.newInstance("@Index"));
        adapter.addFragment(VipList.newInstance("@Vip"));
        adapter.addFragment(MyinfoH5_Web.newInstance("@My"));
        viewPager.setAdapter(adapter);
        viewPager.setOffscreenPageLimit(adapter.getCount());
    }

    //安装应用的流程
    private void installProcess() {
        boolean haveInstallPermission;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //先获取是否有安装未知来源应用的权限
            haveInstallPermission = getPackageManager().canRequestPackageInstalls();
            if (!haveInstallPermission) {//没有权限
                //弹框提示用户手动打开
                AssertAlert.show(this, "安装权限", "需要打开允许来自此来源，请去设置中开启此权限", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            //此方法需要API>=26才能使用
                            startInstallPermissionSettingActivity();
                        }
                    }
                });
                return;
            }
        }
        //有权限，开始安装应用程序
        ver.installApk();
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private void startInstallPermissionSettingActivity() {
        Uri packageURI = Uri.parse("package:" + getPackageName());
        //注意这个是8.0新API
        Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI);
        startActivityForResult(intent, 16667);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK && requestCode == 16667) {
            Toast.makeText(this,"安装应用",Toast.LENGTH_SHORT).show();
            //有权限，开始安装应用程序
            ver.installApk();
        }
    }

}