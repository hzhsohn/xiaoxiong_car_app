package myinfo.a;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseFragment;

import com.dou361.dialogui.DialogUIUtils;
import com.hx_kong.freesha.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Properties;

import ext.func.AssertAlert;
import ext.magr.ConfigMagr;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.unlogged.forgot.MyForgot;
import myinfo.logic.LoginInfo;
import myinfo.unlogged.reg.MyReg;

public class MyLogin extends BaseFragment {
    Context context = null;
    View contextView = null;
    Dialog loadDialog;

    //保存账号名
    TextView txtAccount = null;
    TextView txtPasswd = null;
    WebProc web = null;
    Button btnLogin = null;

    public static MyLogin newInstance(String param1) {
        MyLogin fragment = new MyLogin();
        Bundle args = new Bundle();
        args.putString("info", param1);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fgm_my_login, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        //
        context = view.getContext();
        contextView = view;
        txtAccount = (TextView) view.findViewById(R.id.txtAccount);
        txtPasswd = (TextView) view.findViewById(R.id.txtPasswd);
        //
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
                R.menu.menu_mylogin,
                onMenuItemClick);
        //
        btnLogin = view.findViewById(R.id.btnLogin);
        btnLogin.setOnClickListener(btnLogin_click);
        view.findViewById(R.id.btnForgot).setOnClickListener(btnForgot_click);

        //读取保存的账号名
        Properties prop = ConfigMagr.loadConfig(context,"hx-kong", "nor_cfg");
        if (prop != null) {
            String tstr = (String) prop.get("login_account");
            if (tstr != null) {
                txtAccount.setText(tstr);
            }
        }
    }

    void showBox(int rid) {
        AssertAlert.show(context, R.string.alert, rid);
    }

    private Toolbar.OnMenuItemClickListener onMenuItemClick = new Toolbar.OnMenuItemClickListener() {
        @Override
        public boolean onMenuItemClick(MenuItem menuItem) {
            switch (menuItem.getItemId()) {
                case R.id.action_0: {
                    Intent intent = new Intent(getActivity(), MyReg.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivityFromFragment(intent, (byte) 0, (byte) 111);
                    getActivity().overridePendingTransition(R.anim.in_0, R.anim.in_1);
                }
                break;
            }
            return true;
        }
    };

    private View.OnClickListener btnLogin_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //Toast.makeText(v.getContext(), "btnLogin_click", Toast.LENGTH_SHORT).show();
            Properties prop = new Properties();
            String txts = txtAccount.getText().toString();
            prop.put("login_account", txts);
            ConfigMagr.saveConfig(context,"hx-kong", "nor_cfg", prop);
            //登录
            web.getHtml(HTTPData.sUserUrl + "/sign_in.i.php",
                    "a=" + txts + "&p=" + txtPasswd.getText().toString());
            //
            btnLogin.setEnabled(false);
            //显示
            if (loadDialog==null||!loadDialog.isShowing())
                loadDialog = DialogUIUtils.showLoading(context,getString(R.string.Loading),true,false,false,true).show();

        }
    };

    private View.OnClickListener btnForgot_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //Toast.makeText(v.getContext(), "btnForgot_click", Toast.LENGTH_SHORT).show();

            Intent intent = new Intent(getActivity(), MyForgot.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            startActivityFromFragment(intent, (byte) 0, (byte) 200);
            getActivity().overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url,String cookie) {

        }

        @Override
        public void success_html(String url,String html) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1://
                    {
                        String szKey = person.getString("szKey");
                        LoginInfo.saveVerifyKey(context,szKey);
                        LoginInfo.saveKeyAliveNow();

                        //登录成功进入我的资料界面
                        FragmentTransaction transaction = getFragmentManager().beginTransaction();
                        transaction.setCustomAnimations(R.anim.in_0, R.anim.in_1); //自定义动画
                        transaction.addToBackStack(null)  //将当前fragment加入到返回栈中
                                .replace(R.id.container3, new MyInfo()).commit();

                    }
                    break;
                    case 2://登录失败
                    {
                        showBox(R.string.signin_login_fail);
                    }
                    break;
                    case 3://账号为空
                    {
                        showBox(R.string.signin_empty_account);
                    }
                    break;
                    case 4://密码为空
                    {
                        showBox(R.string.signin_empty_password);
                    }
                    break;
                    case 5://账号已被禁用
                    {
                        showBox(R.string.signin_empty_password);
                    }
                    break;
                    case 6://不存在的账号
                    {
                        showBox(R.string.signin_no_user);
                    }
                    break;

                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            btnLogin.setEnabled(true);
        }

        @Override
        public void fail(String url,String errMsg) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            Toast.makeText(getActivity(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            //恢复状态
            btnLogin.setEnabled(true);
        }
    };
}
