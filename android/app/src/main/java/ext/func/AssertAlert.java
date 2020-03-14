package ext.func;

import android.content.Context;
import android.content.DialogInterface;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import com.xiaoxiongcar.R;

public class AssertAlert {
    static public void show(@NonNull Context context, String title, String msg) {
        // 提示框
        AlertDialog alert = new AlertDialog.Builder(context).create();
        alert.setTitle(title);
        alert.setIcon(R.drawable.ic_dashboard_black_24dp);
        alert.setMessage(msg);
        DialogInterface.OnClickListener cl = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            }
        };
        alert.setButton(DialogInterface.BUTTON_NEGATIVE, context.getString(R.string.ok), cl);
        alert.show();
    }

    static public void show(@NonNull Context context, int titleID, int msgID) {
        // 提示框
        AlertDialog alert = new AlertDialog.Builder(context).create();
        alert.setTitle(context.getString(titleID));
        alert.setIcon(R.drawable.ic_dashboard_black_24dp);
        alert.setMessage(context.getString(msgID));
        DialogInterface.OnClickListener cl = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            }
        };
        alert.setButton(DialogInterface.BUTTON_NEGATIVE, context.getString(R.string.ok), cl);
        alert.show();
    }

    static public void show(@NonNull Context context, String title, String msg,DialogInterface.OnClickListener cl) {
        // 提示框
        AlertDialog alert = new AlertDialog.Builder(context).create();
        alert.setTitle(title);
        alert.setIcon(R.drawable.ic_dashboard_black_24dp);
        alert.setMessage(msg);
        alert.setButton(DialogInterface.BUTTON_NEGATIVE, context.getString(R.string.ok), cl);
        alert.show();
    }

    static public void show(@NonNull Context context, int titleID, int msgID,DialogInterface.OnClickListener cl) {
        // 提示框
        AlertDialog alert = new AlertDialog.Builder(context).create();
        alert.setTitle(context.getString(titleID));
        alert.setIcon(R.drawable.ic_dashboard_black_24dp);
        alert.setMessage(context.getString(msgID));
        alert.setButton(DialogInterface.BUTTON_NEGATIVE, context.getString(R.string.ok), cl);
        alert.show();
    }

    static public void show(@NonNull Context context, String title, String msg, String btn1_text, String btn2_text, DialogInterface.OnClickListener cl) {
        // 提示框
        AlertDialog alert = new AlertDialog.Builder(context).create();
        alert.setTitle(title);
        alert.setIcon(R.drawable.ic_dashboard_black_24dp);
        alert.setMessage(msg);
        //
        if(null!=btn1_text)
            alert.setButton(DialogInterface.BUTTON_POSITIVE, btn1_text, cl);
        if(null!=btn2_text)
        alert.setButton(DialogInterface.BUTTON_NEGATIVE, btn2_text, cl);
        //
        alert.show();
    }

    static public void show(@NonNull Context context, int titleID, int msgID,int btn1_text_rid,int btn2_text_rid,DialogInterface.OnClickListener cl) {
        // 提示框
        AlertDialog alert = new AlertDialog.Builder(context).create();
        alert.setTitle(context.getString(titleID));
        alert.setIcon(R.drawable.ic_dashboard_black_24dp);
        alert.setMessage(context.getString(msgID));
        //
        if(0!=btn1_text_rid)
            alert.setButton(DialogInterface.BUTTON_POSITIVE, context.getString(btn1_text_rid), cl);
        if(0!=btn2_text_rid)
            alert.setButton(DialogInterface.BUTTON_NEGATIVE, context.getString(btn2_text_rid), cl);
        //
        alert.show();
    }
}