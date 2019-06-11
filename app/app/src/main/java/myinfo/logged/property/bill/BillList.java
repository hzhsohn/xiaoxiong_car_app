package myinfo.logged.property.bill;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;

import com.dou361.dialogui.DialogUIUtils;
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
import myinfo.logged.caid.area.CAIDMagr;
import myinfo.logic.LoginInfo;
import myinfo.unlogged.reg.MyReg;

class BillListItem {
    public String caid;
    public String title;
};

class BillListAdapter extends BaseAdapter {
    private List<BillListItem> items;
    private LayoutInflater mInflater;
    private Context mContext = null;

    public BillListAdapter(Context context, List<BillListItem> lstData) {
        mContext = context;
        mInflater = LayoutInflater.from(mContext);
        if (null != items) {
            items.clear();
        }
        items = lstData;
    }

    public void reload()
    {
        this.notifyDataSetChanged();
    }

    public void reload(List<BillListItem> lstData) {
        if (null != items) {
            if(lstData!=items)
            {items.clear();}
            items = lstData;
            this.notifyDataSetChanged();
        }
    }

    public void clear() {  items.clear();   }

    public Object getItem(int arg0) {  return items.get(arg0);    }

    public long getItemId(int position) {
        return position;
    }

    public int getCount() {
        return items.size();
    }

    public View getView(int position, View convertView,
                        android.view.ViewGroup parent) {
        final TextView indexText;
        final TextView unfinishMoney;
        if (convertView == null) {
            // 和item_custom.xml脚本关联
            convertView = mInflater.inflate(R.layout.list_item_remote_dev, null);
        }
        indexText = (TextView) convertView.findViewById(R.id.tip);
        unfinishMoney= (TextView) convertView.findViewById(R.id.textView7);

        BillListItem it = items.get(position);
        String str1 = it.caid + " -- " + it.title;
        indexText.setText(str1);

        return convertView;
    }
};

public class BillList extends BaseActivity {
    BillListAdapter adapter;
    boolean isEditing;
    WebProc web=null;
    List<BillListItem> webDataList = new ArrayList<BillListItem>();
    Dialog loadDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_remote_dev);
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
                R.menu.menu_caid,
                onMenuItemClick);
        //
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.title_remotedev));

        //
        isEditing = false;
        //
        ListView listView = (ListView) findViewById(R.id.lv);
        adapter = new BillListAdapter(this, webDataList);
        //设置焦点响应问题    同时要将 item 中的焦点 focusable 设置为 false
        listView.setDescendantFocusability(ViewGroup.FOCUS_BLOCK_DESCENDANTS);
        listView.setOnItemClickListener(lvListern);
        listView.setAdapter(adapter);

    }

    @Override
    protected void onResume() {
        super.onResume();
        //获取CAID列表
        GetNetData();
    }

    void GetNetData()
    {
        if (loadDialog==null||!loadDialog.isShowing())
            loadDialog = DialogUIUtils.showLoading(this,getString(R.string.Loading),true,false,false,true).show();

        web.getHtml(HTTPData.sMoneyUrl + "/caid_money.i.php", "k=" + LoginInfo.verifyKey);
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
                    Intent intent = new Intent(getApplicationContext(), CAIDMagr.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    intent.putExtras(bundle);//附带上额外的数据
                    startActivity(intent);
                    overridePendingTransition(R.anim.in_0, R.anim.in_1);
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
            BillListItem item = (BillListItem) adapter.getItem(position);
            //跳到下一个窗体
            Intent intent = new Intent(getApplicationContext(), BillDetail.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("caid",item.caid);
            bundle.putString("title",item.title);
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 200);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    public WebProcListener wls = new WebProcListener() {
        @Override
        public void cookies(String url, String cookie) {

        }

        @Override
        public void success_html(String url, String html) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            int nRet = 0;
            try {
                JSONObject person = new JSONObject(html);
                nRet = person.getInt("nRet");
                switch (nRet) {
                    case 1:
                    {
                        JSONArray ary=person.getJSONArray("list");

                        webDataList.clear();
                        for(int i=0;i<ary.length();i++) {
                            JSONObject p2=ary.getJSONObject(i);
                            BillListItem item = new BillListItem();
                            item.caid = p2.getString("caid");
                            item.title = p2.getString("title");
                            webDataList.add(item);
                        }
                        adapter.reload();

                        //是否显示无数据的提示
                        if(0==webDataList.size())
                        {
                            findViewById(R.id.no_data).setVisibility(View.VISIBLE);
                        }
                        else
                        {
                            findViewById(R.id.no_data).setVisibility(View.GONE);
                        }

                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(getApplicationContext(), R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(getApplicationContext(), R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(getApplicationContext(), R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(getApplicationContext(), getString(R.string.lost_json_parameter), e.getMessage());
            }

        }

        @Override
        public void fail(String url, String errMsg) {
            //
            if (loadDialog!=null&&loadDialog.isShowing())
                loadDialog.cancel();
            //
            Toast.makeText(getApplicationContext(), getString(R.string.httpfaild), Toast.LENGTH_SHORT).show();
            //3秒后重新获取
            Timer timer = new Timer();
            TimerTask task = new TimerTask() {
                @Override
                public void run() {
                    GetNetData();
                }
            };
            timer.schedule(task, 2000);//此处的Delay
        }
    };


}
