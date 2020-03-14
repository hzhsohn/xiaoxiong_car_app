package android.zh.home;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;


import static android.app.Activity.RESULT_OK;

/**
 * Created by han.zh on 2017/8/6.
 * BaseFragment
 *
 *
 * Fragment XML Content:
 *
 <?xml version="1.0" encoding="utf-8"?>
 <RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
 android:layout_width="match_parent"
 android:layout_height="match_parent"
 android:id="@+id/container"
 android:orientation="vertical">
 <android.support.v7.widget.Toolbar
 android:id="@+id/toolbarId"
 android:layout_width="match_parent"
 android:layout_height="wrap_content"
 android:layout_alignParentLeft="true"
 android:layout_alignParentStart="true"
 android:layout_alignParentTop="true"
 android:background="@android:color/holo_blue_light"
 android:minHeight="?attr/actionBarSize"
 android:theme="?attr/actionBarTheme" >
 <TextView
 android:id="@+id/toolbar_title"
 android:layout_width="wrap_content"
 android:layout_height="wrap_content"
 android:layout_gravity="center"
 android:textColor="#FFF"
 android:textSize="20sp" />
 </android.support.v7.widget.Toolbar>
 </RelativeLayout>



 *
 *
 * Menu XML Content:
 *
 <menu xmlns:android="http://schemas.android.com/apk/res/android"
 xmlns:app="http://schemas.android.com/apk/res-auto"
 xmlns:tools="http://schemas.android.com/tools"
 tools:context=".MainActivity">

 <item android:id="@+id/action_0"
 android:title="AA"
 android:orderInCategory="80"
 android:icon="@mipmap/item_camera"
 app:showAsAction="ifRoom" />
 </menu>



 *
 *
 * AndroidMaifest.xml XML Content:
 *
 <application
 android:allowBackup="true"
 android:icon="@mipmap/ic_launcher"
 android:label="@string/app_name"
 android:roundIcon="@mipmap/ic_launcher_round"
 android:supportsRtl="true"
 android:theme="@style/Theme.AppCompat.Light.NoActionBar">
 <activity android:name=".MainActivity" android:windowSoftInputMode="adjustPan|stateHidden">
     <intent-filter>
     <action android:name="android.intent.action.MAIN" />
     <category android:name="android.intent.category.LAUNCHER" />
     </intent-filter>
 </activity>
 <activity
     android:theme="@style/Theme.AppCompat.Light.NoActionBar"
     android:name="android.zh.home.BaseActivity">
 </activity>
 </application>


 */

public class BaseActivity extends AppCompatActivity {
    private int nMenuID;
    /*例子
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_ctrldev_setting);
        //
        initToolbar(R.drawable.ic_home_black_24dp,
                R.id.toolbarId,
                getString(R.string.title_control_setting),
                "BBBB",
                R.mipmap.nav_back,
                onBackClick,
                R.menu.menu_ctrldev_setting,
                onMenuItemClick);
        //
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.title_control_setting));
    }

    private View.OnClickListener onBackClick =  new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Snackbar.make(v, "Don't click me.please!111111.2222222", Snackbar.LENGTH_SHORT).show();
        }
    };

    private Toolbar.OnMenuItemClickListener onMenuItemClick = new Toolbar.OnMenuItemClickListener() {
        @Override
        public boolean onMenuItemClick(MenuItem menuItem) {
            switch (menuItem.getItemId()) {
                case R.id.action_0:

                    break;
            }
            return true;
        }
    };*/
    /////////////////////////////////////////////////////
    //往下加载TOOLBAR
    public void initToolbar(int titleImage,int toolbarID,String title,String subTitle,
                            int backButtonImage,View.OnClickListener backlistener,
                            int menuID,
                            Toolbar.OnMenuItemClickListener listener)
    {
        Toolbar toolbar = (Toolbar)findViewById(toolbarID);
        nMenuID=0;
        //
        toolbar.getMenu().clear();
        // App Logo
        if(titleImage!=0) {
            toolbar.setLogo(titleImage);
        }
        // Title
        if(null!=title && ""!=title)
        {
            toolbar.setTitle(title);
        }
        else
        {
            toolbar.setTitle("\0");
        }
        // Sub Title
        if(null!=subTitle)
        {toolbar.setSubtitle(subTitle);}

        //要放在setTitle函数后面
        setSupportActionBar(toolbar);

        toolbar.setTitleTextColor(Color.WHITE);
        toolbar.setSubtitleTextColor(Color.WHITE);

        if(0!=menuID)
        {
            nMenuID=menuID;
            toolbar.setOnMenuItemClickListener(listener);
            toolbar.inflateMenu(menuID);
        }
        else
        {
            toolbar.setOnMenuItemClickListener(null);
        }

        if(backButtonImage!=0) {
            toolbar.setNavigationOnClickListener(backlistener);
            toolbar.setNavigationIcon(backButtonImage);
        }
    }

    /** 创建菜单 */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if(0!=nMenuID) {
            getMenuInflater().inflate(nMenuID, menu);
        }
        return true;
    }

}
