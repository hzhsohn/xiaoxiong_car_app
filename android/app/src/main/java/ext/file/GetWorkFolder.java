package ext.file;

import android.content.Context;
import android.os.Environment;
import java.io.File;

/**
 * Created by hzh on 2017/9/25.
 */

public class GetWorkFolder {

    //工作目录
    public static String getAddr(Context context, String folder) {
            //String mkdir = Environment.getExternalStorageDirectory()+"/"+folder+"/";
            String mkdir=context.getCacheDir()+"/"+folder+"/";
            makeRootDirectory(mkdir);
            return mkdir;
    }

    public static void makeRootDirectory(String filePath) {
        File file = null;
        try {
            file = new File(filePath);
            if (!file.exists()) {
                file.mkdir();
            }
        } catch (Exception e) {

        }
    }
}
