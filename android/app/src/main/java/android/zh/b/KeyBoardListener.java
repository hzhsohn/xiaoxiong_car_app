package android.zh.b;

import android.app.Activity;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

/**
 * 解决webView键盘遮挡问题的类
 * Created by han.zh on 2020/7/3.
 *
 * 调用方式为：KeyBoardListener.getInstance(this).init();
 *
 */
public class KeyBoardListener {
    private Activity activity;
// private Handler mhanHandler;


    private View mChildOfContent;
    private int usableHeightPrevious;
    private FrameLayout.LayoutParams frameLayoutParams;

    private static KeyBoardListener keyBoardListener;


    public static KeyBoardListener getInstance(Activity activity) {
// if(keyBoardListener==null){
        keyBoardListener=new KeyBoardListener(activity);
// }
        return keyBoardListener;
    }


    public KeyBoardListener(Activity activity) {
        super();
// TODO Auto-generated constructor stub
        this.activity = activity;
// this.mhanHandler = handler;

    }


    public void init() {


        FrameLayout content = (FrameLayout) activity
                .findViewById(android.R.id.content);
        mChildOfContent = content.getChildAt(0);
        mChildOfContent.getViewTreeObserver().addOnGlobalLayoutListener(
                new ViewTreeObserver.OnGlobalLayoutListener() {
                    public void onGlobalLayout() {
                        possiblyResizeChildOfContent();
                    }
                });
        frameLayoutParams = (FrameLayout.LayoutParams) mChildOfContent
                .getLayoutParams();


    }


    private void possiblyResizeChildOfContent() {

        Rect r = new Rect();
        mChildOfContent.getWindowVisibleDisplayFrame(r);
        int usableHeightNow = (r.bottom - r.top);
        if (usableHeightNow != usableHeightPrevious) {
            int usableHeightSansKeyboard = mChildOfContent.getRootView()
                    .getHeight();
            int heightDifference = usableHeightSansKeyboard - usableHeightNow;
            if (heightDifference > (usableHeightSansKeyboard / 4)) {
// keyboard probably just became visible
                frameLayoutParams.height = usableHeightSansKeyboard - heightDifference;
            } else {
// keyboard probably just became hidden
                frameLayoutParams.height = r.bottom;
            }
            mChildOfContent.requestLayout();
            usableHeightPrevious = usableHeightNow;
        }
    }


// private void showLog(String title, String msg) {
// Log.d("Unity", title + "------------>" + msg);
// }

}