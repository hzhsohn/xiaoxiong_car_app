package myinfo.logged.caid.area;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
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
import myinfo.logged.setting.feedback.Feedback;
import myinfo.logic.LoginInfo;

class CAIDMagrItem {
    public String autoid;
    public String caid;
    public String title;
};

class CAIDMagrAdapter extends BaseAdapter {
    private List<CAIDMagrItem> items;
    private LayoutInflater mInflater;
    private Context mContext = null;
    View.OnClickListener btn1OCL;

    public CAIDMagrAdapter(Context context, List<CAIDMagrItem> lstData,View.OnClickListener btnEdit) {
        mContext = context;
        mInflater = LayoutInflater.from(mContext);
        if (null != items) {
            items.clear();
        }
        items = lstData;
        btn1OCL=btnEdit;
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
        final TextView indexText;
        final TextView indexText2;
        final ImageButton btn1;
        if (convertView == null) {
            // 和item_custom.xml脚本关联
            convertView = mInflater.inflate(R.layout.list_item_caid_magr, null);
        }
        indexText = (TextView) convertView.findViewById(R.id.txt1);
        indexText2 = (TextView) convertView.findViewById(R.id.txt2);

        btn1=(ImageButton) convertView.findViewById(R.id.btn1);

        btn1.setOnClickListener(btn1OCL);

        CAIDMagrItem it = items.get(position);

        indexText.setText(it.caid);
        indexText2.setText(it.title);

        btn1.setTag(it);

        return convertView;
    }
};

public class CAIDMagr extends BaseActivity {
    CAIDMagrAdapter adapter;
    WebProc web = null;
    List<CAIDMagrItem> webDataList = new ArrayList<CAIDMagrItem>();
    Dialog loadDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_caid_magr);
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
                R.menu.pub_menu_add,
                onMenuItemClick);
        //
        ListView listView = (ListView) findViewById(R.id.lv);
        adapter = new CAIDMagrAdapter(this, webDataList,onEditClick);
        listView.setAdapter(adapter);
    }

    @Override
    protected void onResume() {
        super.onResume();
        //获取网络数据
        GetNetData();
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    private View.OnClickListener onEditClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            CAIDMagrItem item=(CAIDMagrItem)v.getTag();
            //跳到下一个窗体
            Intent intent = new Intent(CAIDMagr.this, CAIDEdit.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            bundle.putString("autoid",item.autoid);
            bundle.putString("caid",item.caid);
            bundle.putString("title",item.title);
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 1001);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);
        }
    };

    private Toolbar.OnMenuItemClickListener onMenuItemClick = new Toolbar.OnMenuItemClickListener() {
        @Override
        public boolean onMenuItemClick(MenuItem menuItem) {
            switch (menuItem.getItemId()) {
                case R.id.action_0: {
                    //跳到下一个窗体
                    Intent intent = new Intent(CAIDMagr.this, CAIDAdd.class);
                    Bundle bundle = new Bundle();//该类用作携带数据
                    intent.putExtras(bundle);//附带上额外的数据
                    //带返回结果
                    startActivityForResult(intent, 2001);
                    overridePendingTransition(R.anim.in_0, R.anim.in_1);
                }
                break;
            }
            return true;
        }
    };


    void GetNetData() {
        if (loadDialog==null||!loadDialog.isShowing())
            loadDialog = DialogUIUtils.showLoading(this,getString(R.string.Loading),true,false,false,true).show();

        web.getHtml(HTTPData.sInfoUrl + "/getcaid.i.php", "k=" + LoginInfo.verifyKey);
    }

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
                    case 1: {
                        JSONArray ary = person.getJSONArray("ary");

                        webDataList.clear();
                        for (int i = 0; i < ary.length(); i++) {
                            JSONObject p2 = ary.getJSONObject(i);
                            CAIDMagrItem item = new CAIDMagrItem();
                            item.caid = p2.getString("caid");
                            item.title = p2.getString("title");
                            item.autoid = p2.getString("autoid");

                            webDataList.add(item);
                        }
                        adapter.notifyDataSetChanged();
                    }
                    break;
                    case 2://操作数据库失败
                    {
                        AssertAlert.show(CAIDMagr.this, R.string.alert, R.string.myprofile_operat_fail);
                    }
                    break;
                    case 3://缺少参数
                    {
                        AssertAlert.show(CAIDMagr.this, R.string.alert, R.string.myprofile_lost_param);
                    }
                    break;
                    case 4://key参数不正确
                    {
                        AssertAlert.show(CAIDMagr.this, R.string.alert, R.string.myprofile_key_invalid);
                    }
                    break;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                AssertAlert.show(CAIDMagr.this, getString(R.string.lost_json_parameter), e.getMessage());
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
                    Handler mainHandler = new Handler(Looper.getMainLooper());
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            //已在主线程中，可以更新UI
                            GetNetData();
                        }
                    });
                }
            };
            timer.schedule(task, 2000);//此处的Delay
        }
    };

    //窗体反回结果
    @Override
    protected void onActivityResult(int requestCode, int ResultCode, Intent data) {
        super.onActivityResult(requestCode, ResultCode, data);

        if(null==data)
        {return;}

        if(1001==requestCode) {//分享CAID界面返回
            //更新返回结果
            Bundle bundle = data.getExtras();
            String exc = bundle.getString("exc");
            String autoid = bundle.getString("autoid");
            if(exc.equals("delete")) {
                for (int i = 0; i < webDataList.size(); i++) {
                    if (webDataList.get(i).autoid.equals(autoid)) {
                        webDataList.remove(i);
                        break;
                    }
                }
                adapter.notifyDataSetChanged();
            }
        }
        else if(1002==requestCode) {//分享CAID界面返回
            //更新返回结果
            Bundle bundle = data.getExtras();
            String autoid = bundle.getString("autoid");
            String caid = bundle.getString("caid");
            for (int i = 0; i < webDataList.size(); i++) {
                if (webDataList.get(i).autoid.equals(autoid)) {
                    break;
                }
            }
            adapter.notifyDataSetChanged();
        }
    }
}
