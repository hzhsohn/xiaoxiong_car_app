package myinfo.logged.caid.remote;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AlertDialog;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;

import com.hx_kong.freesha.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import ext.func.AssertAlert;
import ext.magr.HTTPData;
import ext.magr.WebProc;
import ext.magr.WebProcListener;


public class DeviceSetPriceWorktime extends BaseActivity {
    WebProc web = null;
    public String uuid;
    public String price;
    public String use_time;

    public int set_price;
    public int set_use_time;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_dev_price_worktime);

        //
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
        Bundle bundle = this.getIntent().getExtras();
        uuid = bundle.getString("uuid");
        price = bundle.getString("price");
        use_time = bundle.getString("use_time");
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    //进入设置价格和工作时间
    public void click_price_and_worktime(View v)
    {
        Object vvv= (Object) v.getTag();
        int tag=Integer.parseInt(String.valueOf(vvv));
        switch (tag)
        {
            case 1:
                set_price=100;
                set_use_time=30*60;
                break;
            case 2:
                set_price=200;
                set_use_time=30*60;
                break;
            case 3:
                set_price=250;
                set_use_time=30*60;
                break;

            case 4:
                set_price=100;
                set_use_time=60*60;
                break;
            case 5:
                set_price=200;
                set_use_time=60*60;
                break;
            case 6:
                set_price=250;
                set_use_time=60*60;
                break;

            case 7:
                set_price=150;
                set_use_time=2*60*60;
                break;
            case 8:
                set_price=250;
                set_use_time=2*60*60;
                break;
            case 9:
                set_price=300;
                set_use_time=2*60*60;
                break;
        }
        web.getHtml(HTTPData.sIotSetParameterUrl+"/set_price_worktime.php", "devuuid=" + uuid+"&price=" + set_price + "&work_time=" + set_use_time );
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
                    nRet = person.getInt("nRet");
                    switch (nRet)
                    {
                        case 1: {
                            // 提示框
                            AlertDialog alert = new AlertDialog.Builder(DeviceSetPriceWorktime.this).create();
                            alert.setMessage(getString(R.string.setprice_worktime_ok));
                            DialogInterface.OnClickListener cl = new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    //返回窗体
                                    //添加成功,关闭并反回结果
                                    Intent retData = new Intent();
                                    Bundle bundle = new Bundle();//该类用作携带数据
                                    bundle.putInt("set_price", set_price);
                                    bundle.putInt("set_use_time", set_use_time);
                                    retData.putExtras(bundle);//附带上额外的数据
                                    setResult(1, retData);
                                    finish();
                                    overridePendingTransition(R.anim.back_0, R.anim.back_1);
                                }
                            };
                            alert.setButton(DialogInterface.BUTTON_NEGATIVE, getString(R.string.ok), cl);
                            alert.show();
                        }
                            break;
                        case 2: {
                            AssertAlert.show(DeviceSetPriceWorktime.this, "", getString(R.string.lost_json_parameter));
                        }
                            break;
                    }

            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(DeviceSetPriceWorktime.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
        }
    };
}
