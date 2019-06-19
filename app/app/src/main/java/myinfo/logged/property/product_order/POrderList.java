package myinfo.logged.property.product_order;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
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

class POrderListItem {
    public String product_id;
    public String order_num;
    public int order_status; //支付状态-1未支付1支付成功2支付失败3退款成功4退款失败
    public String order_time;
    public int device_contrl;
    public String caid;
    public double price;
    public int is_bill_operat;
    public String title;
};

class POrderListAdapter extends BaseAdapter {
    private List<POrderListItem> items;
    private LayoutInflater mInflater;
    private Context mContext = null;

    public POrderListAdapter(Context context, List<POrderListItem> lstData) {
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

    public void reload(List<POrderListItem> lstData) {
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

    String getOrderType(View convertView,int t)
    {
        //支付状态 -1未支付1支付成功2支付失败3退款成功4退款失败
        switch (t)
        {
            case -1:
                return convertView.getResources().getString(R.string.order_paystatus_s1);
            case 1:
                return convertView.getResources().getString(R.string.order_paystatus_1);
            case 2:
                return convertView.getResources().getString(R.string.order_paystatus_2);
            case 3:
                return convertView.getResources().getString(R.string.order_paystatus_3);
            case 4:
                return convertView.getResources().getString(R.string.order_paystatus_4);
        }
        return "";
    }

    String getDevDo(View convertView,int t)
    {
        switch (t)
        {
            case 0:
                return convertView.getResources().getString(R.string.device_contrl_no);
            case 1:
                return convertView.getResources().getString(R.string.device_contrl_yes);
        }
        return "";
    }

    String getBillDo(View convertView,int t)
    {
        switch (t)
        {
            case 0:
                return convertView.getResources().getString(R.string.order_operat_no);
            case 1:
                return convertView.getResources().getString(R.string.order_operat_yes);
        }
        return "";
    }

    public View getView(int position, View convertView,
                        android.view.ViewGroup parent) {
        final TextView indexText;
        final TextView txt2,txt3,txt4,txt5,txt6,txt7,txt8,txt9,txt10;
        if (convertView == null) {
            // 和item_custom.xml脚本关联
            convertView = mInflater.inflate(R.layout.list_item_porderlist, null);
        }
        indexText = (TextView) convertView.findViewById(R.id.txt1);
        txt2= (TextView) convertView.findViewById(R.id.txt2);
        txt4= (TextView) convertView.findViewById(R.id.txt4);
        txt5= (TextView) convertView.findViewById(R.id.txt5);
        txt6= (TextView) convertView.findViewById(R.id.txt6);
        txt7= (TextView) convertView.findViewById(R.id.txt7);
        txt8= (TextView) convertView.findViewById(R.id.txt8);
        txt10= (TextView) convertView.findViewById(R.id.txt10);

        String str1="";
        POrderListItem it = items.get(position);
        indexText.setText(convertView.getResources().getString(R.string.order_id)+": " +it.order_num);
        txt2.setText(convertView.getResources().getString(R.string.qr_product_id)+": " +it.product_id);
        if(it.price>=0)
        {
            txt4.setTextColor(Color.argb(0xff,0xff,0,0));
            str1= convertView.getResources().getString(R.string.operat_money_in)+": " +it.price/100 + convertView.getResources().getString(R.string.moneyft);
        }
        else
        {
            txt4.setTextColor(Color.argb(0xff,0x5f,0xb3,0));
            str1=convertView.getResources().getString(R.string.operat_money_out)+": " +it.price/100 + convertView.getResources().getString(R.string.moneyft);
        }
        txt4.setText(str1);
        txt5.setText(convertView.getResources().getString(R.string.order_status)+": " +getOrderType(convertView,it.order_status));
        txt6.setText(convertView.getResources().getString(R.string.device_contrl)+": " +getDevDo(convertView,it.device_contrl));
        txt7.setText(convertView.getResources().getString(R.string.is_bill_operat)+": " +getBillDo(convertView,it.is_bill_operat));
        txt8.setText(convertView.getResources().getString(R.string.order_caid)+": " +it.title +" ("+it.caid+")");
        txt10.setText(it.order_time);
        return convertView;
    }
};

public class POrderList extends BaseActivity {
    POrderListAdapter adapter;
    boolean isEditing;
    WebProc web=null;
    List<POrderListItem> webDataList = new ArrayList<POrderListItem>();
    Dialog loadDialog;
    Context cxt=null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_porderlst);
        //
        cxt=getApplicationContext();
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
        TextView tvInfo = (TextView) findViewById(R.id.toolbar_title);
        tvInfo.setText(getString(R.string.money_magr));

        //
        isEditing = false;
        //
        ListView listView = (ListView) findViewById(R.id.lv);
        adapter = new POrderListAdapter(this, webDataList);
        //设置焦点响应问题    同时要将 item 中的焦点 focusable 设置为 false
        listView.setDescendantFocusability(ViewGroup.FOCUS_BLOCK_DESCENDANTS);
        listView.setOnItemClickListener(lvListern);
        listView.setAdapter(adapter);

        //
        if (loadDialog==null||!loadDialog.isShowing())
            loadDialog = DialogUIUtils.showLoading(this,getString(R.string.Loading),true,false,false,true).show();

    }

    @Override
    protected void onResume() {
        super.onResume();
        //获取CAID列表
        GetNetData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cxt=null;
    }

    void GetNetData()
    {
        web.getHtml(HTTPData.sMoneyUrl + "/order_list.i.php", "k=" + LoginInfo.verifyKey);
    }

    private View.OnClickListener onBackClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            finish();
            overridePendingTransition(R.anim.back_0, R.anim.back_1);
        }
    };

    //----------点击item事件:
    public AdapterView.OnItemClickListener lvListern = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            /*POrderListItem item = (POrderListItem) adapter.getItem(position);
            //跳到下一个窗体
            Intent intent = new Intent(getApplicationContext(), xxx.class);
            Bundle bundle = new Bundle();//该类用作携带数据
            intent.putExtras(bundle);//附带上额外的数据
            //带返回结果
            startActivityForResult(intent, 200);
            overridePendingTransition(R.anim.in_0, R.anim.in_1);*/
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
                            POrderListItem item = new POrderListItem();
                            item.product_id = p2.getString("product_id");
                            item.order_num = p2.getString("order_num");
                            item.order_status = p2.getInt("order_status");
                            item.order_time = p2.getString("order_time");
                            item.device_contrl = p2.getInt("device_contrl");
                            item.caid = p2.getString("caid");
                            item.price = p2.getDouble("price");
                            item.is_bill_operat = p2.getInt("is_bill_operat");
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
            if(null!=cxt) {
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
                timer.schedule(task, 3000);//此处的Delay
            }
        }
    };


}
