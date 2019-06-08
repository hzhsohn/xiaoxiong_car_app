package myinfo.logged.setting.about_softw;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.RequiresApi;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import android.zh.home.MainActivity;
import android.zh.home.VersionInfo;
import android.zh.home.VersionListener;

import com.dou361.dialogui.DialogUIUtils;
import com.hx_kong.freesha.R;

import ext.func.AssertAlert;
import ext.sys.AppRcInfo;
import myinfo.logged.setting.MySetting;
import myinfo.logic.LoginInfo;

public class AboutSoftware extends BaseActivity {
    Context context = null;
    VersionInfo ver;
    //
    Dialog loadDialog;
    //
    TextView txtVersion;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_about_softw);
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
        txtVersion = (TextView) findViewById(R.id.textView9);
        //
        findViewById(R.id.row4).setOnClickListener(funcIndc_click);
        findViewById(R.id.row5).setOnClickListener(checkUpdate_click);
    }

    @Override
    protected void onResume() {
        super.onResume();
        showInfo();
    }

    //显示在界面上
    void showInfo() {
        txtVersion.setText(getString(R.string.curVersionCode)+"  "+ AppRcInfo.getAppVersionName(context));
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener funcIndc_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Intent intent = new Intent(AboutSoftware.this, AboutSoftWeb.class);
            startActivity(intent);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
    private View.OnClickListener checkUpdate_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //
            if (loadDialog==null||!loadDialog.isShowing())
                loadDialog = DialogUIUtils.showLoading(AboutSoftware.this,getString(R.string.Loading),true,false,false,true).show();

            //--------------------------------
            //检测更新
            ver=new VersionInfo(AboutSoftware.this, new VersionListener() {
                @Override
                public void web_fail_cb() {
                    //
                    if (loadDialog!=null&&loadDialog.isShowing())
                        loadDialog.cancel();
                }

                @Override
                public void is_need_update_cb(boolean b) {
                    //
                    if (loadDialog!=null&&loadDialog.isShowing())
                        loadDialog.cancel();
                    //
                    if(false==b) {
                        AssertAlert.show(context,R.string.alert,R.string.not_need_update);
                    }
                }

                @Override
                public void download_ok() {
                    installProcess();
                }

            });
        }
    };

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
