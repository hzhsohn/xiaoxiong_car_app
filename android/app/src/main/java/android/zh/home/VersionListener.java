package android.zh.home;

import java.util.EventListener;

/**
 * Created by hzh on 2017/8/28.
 *
 */
public interface VersionListener extends EventListener {
    void web_fail_cb();
    void is_need_update_cb(boolean b);
    void download_ok();
}
