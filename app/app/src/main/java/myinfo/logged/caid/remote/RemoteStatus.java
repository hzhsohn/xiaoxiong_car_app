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
    public String dpid;
    public String devname;
    public String uuid;
    public String flag;
    public boolean isOnline;

};

class RemoteStatusAdapter extends BaseAdapter {
    private List<RemoteStatusItem> items;
    private LayoutInflater mInflater;
    private Context mContext = null;
    private boolean IsShowDelete;
    View.OnClickListener deleteCL;

    public RemoteStatusAdapter(Context context, List<RemoteStatusItem> lstData, View.OnClickListener dcl) {
        mContext = context;
        mInflater = LayoutInflater.from(mContext);
        if (null != items) {
            items.clear();
        }
        items = lstData;
        IsShowDelete = false;
        deleteCL = dcl;
    }

    public void setShowDelete(boolean showDelete) {

        IsShowDelete = showDelete;
        this.notifyDataSetChanged();
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
        final ImageButton delBtn;
        if (convertView == null) {
            // 和item_custom.xml脚本关联
            convertView = mInflater.inflate(R.layout.list_item_dev_status, null);
        }

        RemoteStatusItem it = items.get(position);

        indexTitle = (TextView) convertView.findViewById(R.id.devname);
        indexImage = (ImageView) convertView.findViewById(R.id.img1);
        delBtn = (ImageButton) convertView.findViewById(R.id.btn1);

        //
        indexTitle.setText(it.devname);
        //
        delBtn.setTag(it);
        delBtn.setOnClickListener(deleteCL);

        //在线状态图标更改
        if (it.isOnline) {
            indexImage.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.devlst_cell_online1));
        } else {
            indexImage.setImageDrawable(ContextCompat.getDrawable(mContext, R.drawable.devlst_cell_online0));
        }

        //显示 和隐藏删除按键
        if (IsShowDelete) {
            convertView.findViewById(R.id.btn1).setVisibility(View.VISIBLE);
        } else {
            convertView.findViewById(R.id.btn1).setVisibility(View.GONE);
        }

        return convertView;
    }
};

public class RemoteStatus extends BaseActivity {
    RemoteStatusAdapter adapter;
    boolean isEditing;
    WebProc web = null;
    WebProc web3 = null;
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
        web3 = new WebProc();
        web3.addListener(wls3);
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
        adapter = new RemoteStatusAdapter(this, webDataList, onDeleteClick);
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
                case R.id.action_0: {
                    isEditing = !isEditing;
                    adapter.setShowDelete(isEditing);
                }
                break;
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

    private View.OnClickListener onDeleteClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            ImageButton btn = (ImageButton) v;
            RemoteStatusItem rsi = (RemoteStatusItem) v.getTag();
            if (rsi.isOnline) {
                Toast.makeText(RemoteStatus.this, getString(R.string.cmagr_online_undel), Toast.LENGTH_SHORT).show();
            } else {
                //Toast.makeText(RemoteStatus.this, "删除记录=" + rsi.devname, Toast.LENGTH_SHORT).show();
                GetNetDeleteDev(rsi.uuid);
            }
        }
    };

    //----------点击item事件:
    public AdapterView.OnItemClickListener lvListern = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            final RemoteStatusItem item = (RemoteStatusItem) adapter.getItem(position);

            //跳转到对应的控制界面
            /*if (item.isOnline) {}*/



        }
    };

    void GetNetData() {
        web.getHtml(HTTPData.sIotDevUrl_get_dev_by_caid, "caid=" + caid);
    }

    void GetNetDeleteDev(String uuid) {
        web3.getHtml(HTTPData.sIotDevUrl_remove_dev_by_caid, "caid=" + caid + "&uuid=" + uuid);
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

                JSONArray dev = person.getJSONArray("dev");
                webDataList.clear();
                for (int i = 0; i < dev.length(); i++) {
                    JSONObject p2 = dev.getJSONObject(i);
                    RemoteStatusItem item = new RemoteStatusItem();
                    item.dpid = p2.getString("dpid");
                    item.devname = p2.getString("name");
                    item.uuid = p2.getString("uuid");
                    item.flag = p2.getString("flag");
                    item.isOnline = p2.getInt("online") != 0 ? true : false;
                    webDataList.add(item);
                }
                adapter.notifyDataSetChanged();
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

    //删除设备
    public WebProcListener wls3 = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {

            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                String del_caid = (String) person.get("caid");
                String del_uuid = (String) person.get("uuid");
                if (del_caid.equals(caid)) {
                    String dev_name = null;
                    for (int j = 0; j < webDataList.size(); j++) {
                        if (webDataList.get(j).uuid.equals(del_uuid)) {
                            dev_name = webDataList.get(j).devname;
                            webDataList.remove(j);
                        }
                    }
                    adapter.notifyDataSetChanged();
                    Toast.makeText(RemoteStatus.this, getString(R.string.cmagr_del) + " " + dev_name, Toast.LENGTH_SHORT).show();
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(RemoteStatus.this, getString(R.string.lost_json_parameter), e.getMessage());
            }
        }

        @Override
        public void fail(String url, String errMsg) {
            Toast.makeText(getApplicationContext(), getString(R.string.cmagr_del_dev_http_fail), Toast.LENGTH_SHORT).show();
        }
    };
}
