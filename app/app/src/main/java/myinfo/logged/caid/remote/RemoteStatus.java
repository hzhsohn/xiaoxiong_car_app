package myinfo.logged.caid.remote;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
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
import org.w3c.dom.Text;

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

class RemoteStatusItem {
    //已经绑定设备的信息
    public String product_id;
    public String price;
    public String device_uuid;
    public String mark;
    public String use_time;
    //已经联网的信息
    // public String devname;
    // public String flag;
    public boolean isOnline;
};

class RemoteStatusAdapter extends BaseAdapter {
    private List<RemoteStatusItem> items;
    private LayoutInflater mInflater;
    private Context mContext = null;

    public RemoteStatusAdapter(Context context, List<RemoteStatusItem> lstData) {
        mContext = context;
        mInflater = LayoutInflater.from(mContext);
        if (null != items) {
            items.clear();
        }
        items = lstData;
    }

    public void clear() {
        items.clear();
    }

    public Object getItem(int arg0) {
        return items.get(arg0);
    }

    public long getItemId(int position) {
        return position;
    }

    public int getCount() {
        return items.size();
    }

    public View getView(int position, View convertView,
                        android.view.ViewGroup parent) {
        final TextView indexTitle;
        final ImageView indexImage;
        if (convertView == null) {
            // 和item_custom.xml脚本关联
            convertView = mInflater.inflate(R.layout.list_item_dev_status, null);
        }

        RemoteStatusItem it = items.get(position);

        indexTitle = (TextView) convertView.findViewById(R.id.devname);
        indexImage = (ImageView) convertView.findViewById(R.id.img1);

        //
        indexTitle.setText(it.product_id);

        //在线状态图标更改
        if (it.isOnline) {
            ((TextView)convertView.findViewById(R.id.textView6)).
                    setText(convertView.getResources().getString(R.string.status_online));
        } else {
            ((TextView)convertView.findViewById(R.id.textView6)).
                    setText(convertView.getResources().getString(R.string.status_offline));
        }
        return convertView;
    }
};

public class RemoteStatus extends BaseActivity {
    RemoteStatusAdapter adapter;
    WebProc web = null;
    WebProc web2 = null;
    List<RemoteStatusItem> webDataList = new ArrayList<RemoteStatusItem>();
    String caid = null;
    String title = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_dev_status);
        //
        web = new WebProc();
        web.addListener(wls);
        //
        web2 = new WebProc();
        web2.addListener(wls2);
        //
        initToolbar(0,
                R.id.toolbarId,
                null,
                null,
                R.drawable.nav_back,
                onBackClick,
                R.menu.pub_menu_edit,
                onMenuItemClick);
        //
        Bundle bundle = this.getIntent().getExtras();
        caid = bundle.getString("caid");
        title = bundle.getString("title");
        LoginInfo.currentCAID_frm = caid;
        //
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(title);

        //
        ListView listView = (ListView) findViewById(R.id.lv);
        adapter = new RemoteStatusAdapter(this, webDataList);
        listView.setOnItemClickListener(lvListern);
        listView.setAdapter(adapter);
    }

    @Override
    protected void onResume() {
        super.onResume();
        //刷新设备
        GetNetData();
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private Toolbar.OnMenuItemClickListener onMenuItemClick = new Toolbar.OnMenuItemClickListener() {
        @Override
        public boolean onMenuItemClick(MenuItem menuItem) {
            switch (menuItem.getItemId()) {
                case R.id.action_1:{
                    Intent intent = new Intent(RemoteStatus.this, CaptureActivity.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivity(intent);
                    RemoteStatus.this.overridePendingTransition(R.anim.in_0, R.anim.in_1);
                }
                break;
            }
            return true;
        }
    };

    //----------点击item事件:
    public AdapterView.OnItemClickListener lvListern = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            final RemoteStatusItem item = (RemoteStatusItem) adapter.getItem(position);

            //跳转到对应的控制界面
            /*if (item.isOnline) {}*/

            //跳到下一个窗体
            Intent intent = new Intent(RemoteStatus.this, RemoteDeviceDetail.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("caid",caid);
            bundle.putString("product_id",item.product_id);
            bundle.putString("uuid",item.device_uuid);
            bundle.putString("mark",item.mark);
            bundle.putBoolean("isonline",item.isOnline);
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 201);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);


        }
    };

    void GetNetData() {
        web.getHtml(HTTPData.sIotBindDevUrl+"/devlist_by_caid.php", "caid=" + caid);
    }

    //设备列表
    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                int ret=person.getInt("ret");
                if(1==ret) {
                    JSONArray dev = person.getJSONArray("dev");
                    webDataList.clear();
                    for (int i = 0; i < dev.length(); i++) {
                        JSONObject p2 = dev.getJSONObject(i);
                        RemoteStatusItem item = new RemoteStatusItem();
                        item.product_id = p2.getString("product_id");
                        item.price = p2.getString("price");
                        item.device_uuid = p2.getString("device_uuid");
                        item.mark = p2.getString("mark");
                        item.use_time = p2.getString("use_time");
                        webDataList.add(item);
                    }
                    adapter.notifyDataSetChanged();

                    //获取设备在线状态
                    web2.getHtml(HTTPData.sIotDevUrl_get_online_by_caid,  "caid="+caid);
                }
                else
                {
                    Toast.makeText(getApplicationContext(), getString(R.string.getdevlist_json_fail), Toast.LENGTH_SHORT).show();
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(RemoteStatus.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            Toast.makeText(getApplicationContext(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            //3秒后重新获取
            Timer timer = new Timer();
            TimerTask task = new TimerTask() {
                @Override
                public void run() {
                    GetNetData();
                }
            };
            timer.schedule(task, 1000);//此处的Delay
        }
    };


    //设备在线列表
    public WebProcListener wls2 = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                JSONArray dev = person.getJSONArray("uuid");
                for(RemoteStatusItem r : webDataList )
                {
                    for (int i = 0; i < dev.length(); i++) {
                        String online_uuid = dev.get(i).toString();
                        if (online_uuid.equals(r.device_uuid))
                        {
                            r.isOnline=true;
                        }
                    }
                }
                adapter.notifyDataSetChanged();

            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(RemoteStatus.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
        }
    };
}
