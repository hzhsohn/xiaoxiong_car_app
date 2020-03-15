package myinfo.a;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseFragment;
import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

import ext.file.MD5File;
import ext.func.AssertAlert;
import ext.magr.DownloadPic;
import ext.magr.DownloadPicListener;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logged.iotinfo.MyIotInfo;
import myinfo.logic.LoginInfo;
import myinfo.logged.setting.MySetting;

public class MyInfo extends BaseFragment {
    Context context = null;
    View contextView = null;
    WebProc web = null;

    public static MyInfo newInstance(String param1) {
        MyInfo fragment = new MyInfo();
        Bundle args = new Bundle();
        args.putString("info", param1);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fgm_my_info, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        //
        context = view.getContext();
        contextView = view;
        web = new WebProc();
        web.addListener(wls);
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
        ImageView toIcon = (ImageView) contextView.findViewById(R.id.icon);
        toIcon.setImageDrawable(ContextCompat.getDrawable(context, R.drawable.def_user));
        //添加事件
        View row1 = contextView.findViewById(R.id.row1);
        row1.setOnClickListener(row1_click);
        View row2 = contextView.findViewById(R.id.row2);
        row2.setOnClickListener(row2_click);
        View row3 = contextView.findViewById(R.id.row3);
        row3.setOnClickListener(row3_click);
        View row4 = contextView.findViewById(R.id.row4);
        row4.setOnClickListener(row4_click);
        View row5 = contextView.findViewById(R.id.row5);
        row5.setOnClickListener(row5_click);
        //
        if(!LoginInfo.verifyKey.equals("")) {
            webNetInfo();
        }
        else
        {
            exitLogin();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (LoginInfo.isLogin) {
            showInfo();
        } else {
            exitLogin();
        }
    }

    void webNetInfo() {
        web.getHtml(HTTPData.sUserUrl + "/get_info.i.php", "k=" + LoginInfo.verifyKey);
    }

    void getIconPic(String uid) {
        if(null!=uid) {
            //如果文件不存在就下载这个图片
            DownloadPic dp = new DownloadPic(context);
            dp.addListener(dpl);
            String fname = uid + ".jpg";
            dp.download(HTTPData.sIconUrl + "/" + fname, "hx-kong", fname);
        }
    }

    //显示在界面上
    void showInfo() {
        TextView tnk = (TextView) contextView.findViewById(R.id.nickname);
        tnk.setText(getString(R.string.info_title_nick) + LoginInfo.infokey.get("nickname"));

        TextView tid = (TextView) contextView.findViewById(R.id.userid);
        tid.setText(getString(R.string.info_title_uid) + LoginInfo.infokey.get("userid"));

        //获取图像
        String uid = LoginInfo.infokey.get("userid");
        String stricon = LoginInfo.getUserIconLocalPath(context,uid);
        String icon_md5 = LoginInfo.infokey.get("icon_md5");

        File fp = new File(stricon);
        if (fp.exists()) {
            //将图片显示到ImageView中
            ImageView toIcon = (ImageView) contextView.findViewById(R.id.icon);
            Bitmap bm = BitmapFactory.decodeFile(stricon);
            if (null != bm) {
                toIcon.setImageBitmap(bm);
            }

            //更新ICON
            try {
                String md5 = MD5File.getFileMD5String(fp);
                if (!icon_md5.equals(md5)) {
                    getIconPic(uid);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            getIconPic(uid);
        }
    }

    void exitLogin() {
        //退出登录
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.setCustomAnimations(R.anim.in_0, R.anim.in_1); //自定义动画
        transaction.addToBackStack(null)  //将当前fragment加入到返回栈中
                .replace(R.id.container3, new MyLogin()).commit();
    }

    DownloadPicListener dpl = new DownloadPicListener() {

        @Override
        public void success(String url) {
            //Toast.makeText(getActivity(), "图片下载成功", Toast.LENGTH_SHORT).show();
            //将图片显示到ImageView中
            String uid = LoginInfo.infokey.get("userid");
            String stricon = LoginInfo.getUserIconLocalPath(context,uid);
            ImageView toIcon = (ImageView) contextView.findViewById(R.id.icon);
            Bitmap bm = BitmapFactory.decodeFile(stricon);
            //将图片显示到ImageView中
            toIcon.setImageBitmap(bm);

            //更新MD5值
            File fp = new File(stricon);
            if (fp.exists()) {
                String md5 = null;
                try {
                    md5 = MD5File.getFileMD5String(fp);
                    LoginInfo.infokey.put("icon_md5", md5);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void connect_fail(String url) {

        }

        @Override
        public void save_pic_fail(String url) {

        }
    };

    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1://
                    {
                        JSONObject person2 = person.getJSONObject("info");
                        //获取信息
                        int all_disable = person2.getInt("all_disable");
                        if (0 == all_disable) {
                            LoginInfo.infokey.put("userid", person2.getString("userid"));
                            LoginInfo.infokey.put("createtime", person2.getString("createtime"));
                            LoginInfo.infokey.put("nickname", person2.getString("nickname"));
                            LoginInfo.infokey.put("email", person2.getString("email"));
                            LoginInfo.infokey.put("phone", person2.getString("phone"));
                            LoginInfo.infokey.put("icon_md5", person2.getString("icon_md5"));

                            showInfo();
                        } else {
                            LoginInfo.clearLoginCfg(context);
                            AssertAlert.show(context, R.string.alert, R.string.myprofile_account_disable);
                            exitLogin();
                        }
                    }
                    break;
                    case 2://不存在此用户
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_no_user);
                    }
                    break;
                    case 3://操作数据库失败
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 4://缺少参数
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 5://key参数不正确
                    {
                        AssertAlert.show(context, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(context, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {
            if(null!=context) {
                //Toast.makeText(getActivity(), getString(R.string.http_retry), Toast.LENGTH_SHORT).show();
                //2秒后重新获取
                Timer timer = new Timer();
                TimerTask task = new TimerTask() {
                    @Override
                    public void run() {
                        Handler mainHandler = new Handler(Looper.getMainLooper());
                        mainHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                //已在主线程中，可以更新UI
                                webNetInfo();
                            }
                        });
                    }
                };
                timer.schedule(task, 3000);//此处的Delay
            }
        }
    };
    public View.OnClickListener row1_click = new View.OnClickListener() {
        public void onClick(View v) {
            Intent intent = new Intent(getActivity(), MyIotInfo.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            startActivityFromFragment(intent, (byte) 0, (byte) 1);
            getActivity().overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
    public View.OnClickListener row2_click = new View.OnClickListener() {
        public void onClick(View v) {
        }
    };
    public View.OnClickListener row3_click = new View.OnClickListener() {
        public void onClick(View v) {
        }
    };
    public View.OnClickListener row4_click = new View.OnClickListener() {
        public void onClick(View v) {
        }
    };
    public View.OnClickListener row5_click = new View.OnClickListener() {
        public void onClick(View v) {
            Intent intent = new Intent(getActivity(), MySetting.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            startActivityFromFragment(intent, (byte) 0, (byte) 5);
            getActivity().overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
}

