package android.zh.home;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
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
import android.util.AttributeSet;
import android.util.Log;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.widget.Toast;
import android.zh.b.H5Web_acty;
import android.zh.b.StatusNavUtils;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import found.a.FoundList;
import myinfo.a.MyinfoH5_Web;
import myinfo.logic.LoginInfo;
import vip.a.VipList;
import com.xiaoxiongcar.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;


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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        StatusNavUtils.setStatusBarColor(MainActivity.this,0x00000000);

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
        HTTPData.sWebTestPage=HTTPData.sWeb+"/testAAA.php";  //测试服务器
        HTTPData.sWebStartPage=HTTPData.sWeb+"/startpage";  //测试服务器
        HTTPData.sWebPhoneUrl_Index=HTTPData.sWeb+"/webphone_index/#/common/index";
        HTTPData.sWebPhoneUrl_JiZhao=HTTPData.sWeb+"/webphone_vip/#/common/recommend";
        HTTPData.sWebPhoneUrl_Center=HTTPData.sWeb+"/webphone/#/client/center";
        HTTPData.sUpdateUrl=HTTPData.sWeb+ "/app_update";

//web h5测试:
        if(HTTPData.isTestApp) {
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