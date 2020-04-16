package android.zh.home;

import android.Manifest;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
import android.widget.Toast;
import android.zh.b.H5Web_acty;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import found.a.FoundList;
import myinfo.a.MyMain;
import vip.a.VipList;

import com.xiaoxiongcar.R;

import static com.dou361.dialogui.DialogUIUtils.showToast;


public class MainActivity extends AppCompatActivity {

    private final int PERMISSION_ID=666;
    private ViewPager viewPager;
    private MenuItem menuItem;
    private BottomNavigationView bottomNavigationView;

    VersionInfo ver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

/////   /////////////////

//web h5测试:
/*        Intent intent = new Intent(this, H5Web_acty.class);
        Bundle bundle = new Bundle();//该类用作携带数据
        //bundle.putString("url", "http://xt-sys.com/aaa.php");
        bundle.putString("url", "http://47.115.187.147/webphone/#/common/index");
        intent.putExtras(bundle);//附带上额外的数据
        startActivity(intent);
        overridePendingTransition(R.anim.in_0, R.anim.in_1);
*/
        /////////////////

        viewPager = (ViewPager) findViewById(R.id.viewpager);
        bottomNavigationView = (BottomNavigationView) findViewById(R.id.bottom_navigation);
        bottomNavigationView.setItemIconTintList(null);

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

        adapter.addFragment(FoundList.newInstance("@Found"));
        adapter.addFragment(VipList.newInstance("@Vip"));
        adapter.addFragment(MyMain.newInstance("@My"));
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