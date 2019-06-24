package myinfo.logged.caid.remote;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.listener.DialogUIListener;
import com.hx_kong.freesha.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;
import hxkong.password.HXPassword;
import myinfo.logic.LoginInfo;
import myinfo.qrscan.zxing.android.CaptureActivity;


public class RemoteDeviceDetail extends BaseActivity {
    WebProc web = null;
    WebProc web3 = null;
    WebProc web4 = null;

    String caid = null;
    public String product_id;
    public String uuid;
    public String mark;

    TextView txtCAID;
    TextView txtPRODUCTID;
    TextView txtUUID;
    TextView txtFlag;
    TextView txtIsOnline;
    TextView txtResult;
    Button btnRmoveBind;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_dev_detail);

        //
        web = new WebProc();
        web.addListener(wls);
        //
        web3 = new WebProc();
        web3.addListener(wls3);

        web4 = new WebProc();
        web4.addListener(wls4);
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
        Bundle bundle = this.getIntent().getExtras();
        caid = bundle.getString("caid");
        product_id = bundle.getString("product_id");
        uuid = bundle.getString("uuid");
        mark = bundle.getString("mark");
        //
        txtPRODUCTID= (TextView) findViewById(R.id.txt0);
        txtUUID= (TextView) findViewById(R.id.txt1);
        txtFlag= (TextView) findViewById(R.id.txt2);
        txtCAID= (TextView) findViewById(R.id.txt3);
        txtIsOnline= (TextView) findViewById(R.id.txt4);
        txtResult= (TextView) findViewById(R.id.result);
        btnRmoveBind= (Button) findViewById(R.id.button);
        //
        txtPRODUCTID.setText(product_id);
        txtUUID.setText(uuid);
        txtFlag.setText(mark);
        txtCAID.setText(caid);
        txtResult.setText("");
        txtIsOnline.setText("...");
        //
        web.getHtml(HTTPData.sIotDevUrl_get_online_by_uuid,  "uuid=" + uuid);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    void GetNetDeleteDev() {
        web3.getHtml(HTTPData.sIotBindDevUrl+"/caid_reset.php", "caid=" + caid + "&device_uuid=" + uuid);
    }

    public void click_removebind(View v)
    {
        GetNetDeleteDev();
    }


    //设备在线列表
    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                    JSONObject person = new JSONObject(html);
                    JSONArray dev = person.getJSONArray("uuid");
                    if(1==dev.length()) {
                        String online_uuid = dev.get(0).toString();
                        txtIsOnline.setText(online_uuid.equals(uuid) ? getString(R.string.online) : getString(R.string.offline));
                    }

            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(RemoteDeviceDetail.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
        }
    };

    //解除设备的CAID值
    public WebProcListener wls3 = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {
            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("ret");
                switch (nRet) {
                    case 1://解除设备成功
                    {
                        txtResult.setText(getString(R.string.cmagr_try_reset_caid));
                        //检测是否成功
                        new Handler().postDelayed(new Runnable()
                        {
                            public void run()
                            {
                                web4.getHtml(HTTPData.sIotBindDevUrl + "/caid_reset_check.php", "device_uuid="+uuid);
                            }
                        }, 1000);
                    }
                    break;
                    case 2://CAID已经被绑定
                    {
                    }
                    break;
                    case 3://未知产品设备
                    {
                        AssertAlert.show(RemoteDeviceDetail.this, R.string.alert, R.string.qr_unknow_devuuid);
                        txtResult.setText(getString(R.string.qr_unknow_devuuid));
                    }
                    break;
                    case 4://数据库操作失败
                    {
                        AssertAlert.show(RemoteDeviceDetail.this, R.string.alert, R.string.myprofile_operat_fail);
                        txtResult.setText(getString(R.string.myprofile_operat_fail));
                    }
                    break;
                    case 5://缺少参数
                    {
                        AssertAlert.show(RemoteDeviceDetail.this, R.string.alert, R.string.myprofile_lost_param);
                        txtResult.setText(getString(R.string.myprofile_lost_param));
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(RemoteDeviceDetail.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            Toast.makeText(getApplicationContext(), getString(R.string.remove_bind_dev_http_fail), Toast.LENGTH_SHORT).show();
        }
    };

    //解除绑定检测
    public WebProcListener wls4 = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("ret");
                switch (nRet) {
                    case 1://CAID已经为空
                    {
                        txtResult.setText(getString(R.string.cmagr_reset_caid));
                        btnRmoveBind.setVisibility(View.GONE);
                    }
                    break;
                    case 2://CAID已经被绑定
                    {
                        txtResult.setText(getString(R.string.cmagr_reset_caid_fail));
                    }
                    break;
                    case 3://未知产品设备
                    {
                        AssertAlert.show(RemoteDeviceDetail.this, R.string.alert, R.string.qr_unknow_devuuid);
                        txtResult.setText(getString(R.string.qr_unknow_devuuid));
                    }
                    break;
                    case 4://数据库操作失败
                    {
                        AssertAlert.show(RemoteDeviceDetail.this, R.string.alert, R.string.myprofile_operat_fail);
                        txtResult.setText(getString(R.string.myprofile_operat_fail));
                    }
                    break;
                    case 5://缺少参数
                    {
                        AssertAlert.show(RemoteDeviceDetail.this, R.string.alert, R.string.myprofile_lost_param);
                        txtResult.setText(getString(R.string.myprofile_lost_param));
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(RemoteDeviceDetail.this, getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {

        }
    };

}
