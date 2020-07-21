package android.zh.home;

import android.app.Application;

import com.fm.openinstall.OpenInstall;

public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // 只在主进程中调用初始化
        if (OpenInstall.isMainProcess(getApplicationContext())) {
            OpenInstall.init(getApplicationContext());
        }
    }
}