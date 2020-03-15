package myinfo.logged.iotinfo;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.Timer;
import java.util.TimerTask;

import ext.magr.HTTPData;
import ext.func.AssertAlert;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import myinfo.logic.LoginInfo;

public class MyIotInfo extends BaseActivity {
    WebProc web = null;
    Context context = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_my_iot_info);
        context = this;
        web = new WebProc();
        web.addListener(wls);
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
        View row1 = (View) findViewById(R.id.row1);
        row1.setOnClickListener(row1_click);
        View row2 = (View) findViewById(R.id.row2);
        row2.setOnClickListener(row2_click);
        //
        if(!LoginInfo.verifyKey.equals("")) {
            webNetIotInfo();
        }
        else
        {
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        showInfo();
    }

    void webNetIotInfo() {
        web.getHtml(HTTPData.sWebPhoneUrl + "/iot_info.i.php", "k=" + LoginInfo.verifyKey);
    }

    //显示在界面上
    void showInfo() {
        //
        ImageView icon = (ImageView) findViewById(R.id.icon);
        TextView nick = (TextView) findViewById(R.id.nickname);
        TextView userid = (TextView) findViewById(R.id.userid);
        //
        String iknick = LoginInfo.infokey.get("nickname");
        if (iknick != null) {
            nick.setText(iknick);
        }
        //
        String uid = LoginInfo.infokey.get("userid");
        if (uid != null) {
            userid.setText(uid);
        }

        //获取图像
        String stricon = LoginInfo.getUserIconLocalPath(context,uid);
        //头像
        File fp = new File(stricon);
        if (fp.exists()) {
            Bitmap bm = BitmapFactory.decodeFile(stricon);
            //将图片显示到ImageView中
            if (null != bm) {
                icon.setImageBitmap(bm);
            } else {
                icon.setImageDrawable(ContextCompat.getDrawable(context, R.drawable.def_user));
            }
        } else {
            icon.setImageDrawable(ContextCompat.getDrawable(context, R.drawable.def_user));
        }
    }

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
                        LoginInfo.infokey.put("activeTime", person2.getString("activeTime"));

                        showInfo();
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
            Toast.makeText(context, getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            //3秒后重新获取
            Timer timer = new Timer();
            TimerTask task = new TimerTask() {
                @Override
                public void run() {
                    webNetIotInfo();
                }
            };
            timer.schedule(task, 3000);//此处的Delay
        }
    };

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener row1_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //跳到下一个窗体
            Intent intent = new Intent(MyIotInfo.this, ModifyIcon.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 100);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
    private View.OnClickListener row2_click = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //跳到下一个窗体
            Intent intent = new Intent(MyIotInfo.this, ModifyNickname.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 200);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };
}
