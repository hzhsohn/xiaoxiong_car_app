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

 <!-- navigationItemLeftButton -->
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

 */

public class BaseFragment extends Fragment {
/*
加载例子
package mydevice.a;

import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import android.widget.TextView;
import android.zh.home.BaseFragment;
import com.xiaoxiongcar.R;

//-----------------------------------
//进入另一个Fragment界面
void jumpForm()
{
    FragmentTransaction transaction = getFragmentManager().beginTransaction();
    transaction.setCustomAnimations(R.anim.in_0, R.anim.in_1); //自定义动画
    transaction.addToBackStack(null)  //将当前fragment加入到返回栈中
            .replace(R.id.container3, new MyLogin()).commit();
}

//从栈中将当前fragment推出
getFragmentManager().popBackStack();

//从Fragment界面进入另一个Activity
Intent intent = new Intent(getActivity(), ControlSetting.class);
Bundle bundle = new Bundle();//该类用作携带数据
intent.putExtras(bundle);//附带上额外的数据
startActivityFromFragment(intent,(byte)0,(byte)123);
//跳转动画 getActivity().overridePendingTransition(R.anim.in_anim,R.anim.out_anim);
//------------------------------------

public class ControlMain extends BaseFragment {

    public static ControlMain newInstance(String param1)
    {
        ControlMain fragment = new ControlMain();
        Bundle args = new Bundle();
        args.putString("info", param1);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fgm_ctrl_main, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        //
        initToolbar(view,
                R.drawable.ic_home_black_24dp,
                R.id.toolbarId,
                getString(R.string.title_control_setting),
                "BBBB",
                R.mipmap.nav_back,
                onBackClick,
                R.menu.menu_ctrl_main,
                onMenuItemClick);
        //
        TextView tvInfo = (TextView) view.findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.title_my_device));
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
    };

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        int fragmentIndex=requestCode>>8;
        int reqCode=requestCode&0xff;
    }
}

    */

    /////////////////////////////////////////////////////
    //往下加载TOOLBAR
    public void initToolbar(View view,int titleImage,int toolbarID,String title,String subTitle,
                            int backButtonImage,View.OnClickListener backlistener,
                            int menuID,
                            Toolbar.OnMenuItemClickListener listener)
    {
        Toolbar toolbar = (Toolbar)view.findViewById(toolbarID);
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
        // Sub Title
        if(null!=subTitle)
        {toolbar.setSubtitle(subTitle);}

        toolbar.setTitleTextColor(Color.WHITE);
        toolbar.setSubtitleTextColor(Color.WHITE);

        if(0!=menuID)
        {
            setHasOptionsMenu(true);
            toolbar.setOnMenuItemClickListener(listener);
            toolbar.inflateMenu(menuID);
        }
        else
        {
            setHasOptionsMenu(false);
            toolbar.setOnMenuItemClickListener(null);
        }

        if(backButtonImage!=0) {
            toolbar.setNavigationOnClickListener(backlistener);
            toolbar.setNavigationIcon(backButtonImage);
        }
    }

    public void startActivityFromFragment(Intent intent,
                                          byte fragmentIndex,
                                          byte requestCode) {
        int rcode=fragmentIndex<<8|requestCode&0xff;
        super.startActivityForResult(intent, rcode);
         /*
            用于Activity界面关闭并返回结果的事件
            public void btnBack_click(View v)
            {
                // 关闭并反回结果
                Intent data = new Intent();
                data.putExtra("name", "hah");
                this.setResult(222, data);
                this.finish();  //finish当前activity
                this.overridePendingTransition(R.anim.back_0,R.anim.back_1);
            }
        */
    }

    public void startActivityFromFragment(Intent intent) {
        super.startActivity(intent);
         /*
            用于Activity界面关闭并返回结果的事件
            public void btnBack_click(View v)
            {
                // 关闭并反回结果
                Intent data = new Intent();
                data.putExtra("name", "hah");
                this.setResult(222, data);
                this.finish();  //finish当前activity
                this.overridePendingTransition(R.anim.back_0,R.anim.back_1);
            }
        */
    }
}
