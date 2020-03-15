package myinfo.a;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseFragment;
import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Timer;
import java.util.TimerTask;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import myinfo.logic.LoginInfo;


public class MyMain extends BaseFragment {
    Context context;

    public static MyMain newInstance(String param1) {
        MyMain fragment = new MyMain();
        Bundle args = new Bundle();
        args.putString("info", param1);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fgm_my_main, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        //
        context = view.getContext();
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

    }

    @Override
    public void onResume() {
        super.onResume();
        //
        if (true == LoginInfo.isLogin) {
            //直接进入我的资料界面
            jumpFormMyInfo(false);
        } else if (false == LoginInfo.readVerifyKey(context)) {
            jumpFormMyLogin(false);
        } else {
            long tmpt = LoginInfo.getCurrentSecond();
            //超过半小时要重新验证
            if (tmpt - LoginInfo.lastVerifySecTime > 1800) {
                //验证钥匙
                HTTPData.getHttpData(handler, HTTPData.sUserUrl + "/verify_key.i.php", "k=" + LoginInfo.verifyKey);
            } else {
                //直接进入我的资料界面
                jumpFormMyInfo(false);
            }
        }
    }

    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1: {
                    int nRet = 0;
                    try {
                        String text = (String) msg.obj;
                        JSONObject person = new JSONObject(text);
                        nRet = person.getInt("nRet");
                        switch (nRet) {
                            case 1://
                            {
                                String szKey = person.getString("szKey");
                                LoginInfo.saveVerifyKey(context,szKey);
                                LoginInfo.saveKeyAliveNow();

                                //直接进入我的资料界面
                                jumpFormMyInfo(true);
                            }
                            break;
                            case 2://钥匙为空
                            {
                                AssertAlert.show(context, R.string.alert, R.string.useda_empty_key, gotoLogin_cl);
                            }
                            break;
                            case 3://账号未激活
                            {
                                AssertAlert.show(context, R.string.alert, R.string.useda_inaction, gotoLogin_cl);
                            }
                            break;
                            case 4://无效钥匙
                            case 5://钥匙与账户不匹配
                            case 6://不存在此用户
                            {
                                LoginInfo.clearLoginCfg(context);
                                //进入登录界面
                                jumpFormMyLogin(true);
                            }
                            break;
                            case 7://账号被禁用
                            {
                                //account has been disabled
                                AssertAlert.show(context, R.string.alert, R.string.account_has_been_disabled, gotoLogin_cl);
                            }
                            break;
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
                break;
                case -1: {
                    //Toast.makeText(context, getString(R.string.http_retry), Toast.LENGTH_SHORT).show();

                    //5秒后继续访问
                    Timer timer = new Timer();
                    TimerTask task = new TimerTask() {
                        @Override
                        public void run() {
                            //验证钥匙
                            HTTPData.getHttpData(handler, HTTPData.sUserUrl + "/verify_key.i.php", "k=" + LoginInfo.verifyKey);
                        }
                    };
                }
                break;
            }
        }
    };

    DialogInterface.OnClickListener gotoLogin_cl = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            jumpFormMyLogin(true);
        }
    };

    void jumpFormMyLogin(final boolean ani) {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {

                FragmentTransaction transaction = getFragmentManager().beginTransaction();
                if(true==ani)
                {
                    transaction.setCustomAnimations(R.anim.in_0, R.anim.in_1); //自定义动画
                }
                transaction.addToBackStack(null)  //将当前fragment加入到返回栈中
                        .replace(R.id.container3, new MyLogin()).commit();
            }
        });
    }

    void jumpFormMyInfo(final boolean ani) {
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {

                FragmentTransaction transaction = getFragmentManager().beginTransaction();
                if(true==ani){
                    transaction.setCustomAnimations(R.anim.in_0, R.anim.in_1); //自定义动画
                }
                transaction.addToBackStack(null)  //将当前fragment加入到返回栈中
                        .replace(R.id.container3, new MyInfo()).commit();
            }
        });

    }
}
