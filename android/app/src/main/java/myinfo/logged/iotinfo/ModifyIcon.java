package myinfo.logged.iotinfo;

import android.annotation.TargetApi;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import android.zh.home.BaseActivity;
import com.xiaoxiongcar.R;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import ext.func.AssertAlert;
import ext.img.SquareBitmap;
import ext.magr.HTTPData;
import myinfo.logic.LoginInfo;
import ext.file.CopyFile;

public class ModifyIcon extends BaseActivity {
    final int TAKE_CAMERA = 1;
    final int CHOOSE_PHOTO = 2;
    Uri imageUri;
    Context context = null;
    ImageView icon;
    String uploadImagePath = null;
    TextView txttip;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.acty_modify_icon);
        context = this;
        //
        initToolbar(0,
                R.id.toolbarId,
                null,
                null,
                R.drawable.nav_back,
                onBackClick,
                R.menu.menu_uploadicon,
                onMenuItemClick);
        //
        txttip = (TextView) findViewById(R.id.txt_tip);
        txttip.setText("");
        //
        showPic();
    }

    void showPic() {
        icon = (ImageView) findViewById(R.id.img1);

        String uid = LoginInfo.infokey.get("userid");
        if (uid != null) {
            //获取图像
            String stricon = LoginInfo.getUserIconLocalPath(context,uid);
            //头像
            File fp = new File(stricon);
            if (fp.exists()) {
                Bitmap bm = BitmapFactory.decodeFile(stricon);
                //将图片显示到ImageView中
                if (null != bm) {
                    icon.setImageBitmap(bm);
                } else {
                    icon.setImageDrawable(ContextCompat.getDrawable(context, R.drawable.def_user));
                }
            } else {
                icon.setImageDrawable(ContextCompat.getDrawable(context, R.drawable.def_user));
            }
        }
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
                    //选择相册图片
                    String uid = LoginInfo.infokey.get("userid");
                    if (uid != null) {
                        String stricon = LoginInfo.getUserIconLocalPath(context,"tmp_icon_" + uid);
                        File imageFile = new File(stricon);
                        if (imageFile.exists()) {
                            imageFile.delete();
                        }
                        try {
                            imageFile.createNewFile();

                            //转换成Uri
                            imageUri = Uri.fromFile(imageFile);
                            //开启选择呢绒界面
                            Intent intent = new Intent("android.intent.action.GET_CONTENT");
                            //设置可以缩放
                            intent.putExtra("scale", true);
                            //设置可以裁剪
                            intent.putExtra("crop", true);
                            intent.setType("image/*");
                            //设置输出位置
                            intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
                            //开始选择
                            startActivityForResult(intent, CHOOSE_PHOTO);
                        } catch (IOException e) {
                        }
                    }
                }
                break;
            }
            return true;
        }
    };

    //new Thread(uploadTh).start();
    private Runnable uploadTh = new Runnable() {
        public void run() {
            String uid = LoginInfo.infokey.get("userid");
            if (uid != null) {
                File fp = new File(uploadImagePath);
                if (fp.exists()) {
                    //已在主线程中，可以更新UI
                    uploadFile(HTTPData.sUserUrl + "/up_icon.i.php", uid, uploadImagePath);
                }
            }
        }
    };

    /**
     * userid 文件名(不带后缀)
     * filePath 文件的本地路径 (xxx / xx / test.jpg)
     */
    public void uploadFile(String up_url, String userid, String filePath) {

        HttpURLConnection conn = null;

        /// boundary就是request头和上传文件内容的分隔符(可自定义任意一组字符串)
        String BOUNDARY = "----WebKitFormBoundaryHGQJ0LPEEPxZeL5p";
        // 用来标识payLoad+文件流的起始位置和终止位置(相当于一个协议,告诉你从哪开始,从哪结束)
        String preFix = ("\r\n--" + BOUNDARY + "\r\n");

        try {
            // (HttpConst.uploadImage 上传到服务器的地址
            URL url = new URL(up_url);
            conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(30000);
            conn.setDoOutput(true);
            conn.setDoInput(true);
            conn.setUseCaches(false);
            // 设置请求方法
            conn.setRequestMethod("POST");
            // 设置header
            conn.setRequestProperty("Accept", "*/*");
            conn.setRequestProperty("Connection", "keep-alive");
            conn.setRequestProperty("Content-Type",
                    "multipart/form-data; boundary=" + BOUNDARY);
            // 获取写输入流
            OutputStream out = new DataOutputStream(conn.getOutputStream());
            // 获取上传文件
            File file = new File(filePath);

            if (!file.exists()) {
                Log.v("ModifyIcon", "找不到上传的文件");
                return;
            }

            // 要上传的数据
            StringBuffer strBuf = new StringBuffer();

            // 标识payLoad + 文件流的起始位置
            strBuf.append(preFix);

            // 下面这三行代码,用来标识服务器表单接收文件的name和filename的格式
            // 在这里,我们是file和filename.后缀[后缀是必须的]。
            // 这里的fileName必须加个.jpg,因为后台会判断这个东西。
            // 这里的Content-Type的类型,必须与fileName的后缀一致。
            // 如果不太明白,可以问一下后台同事,反正这里的name和fileName得与后台协定！
            // 这里只要把.jpg改成.txt，把Content-Type改成上传文本的类型，就能上传txt文件了。
            strBuf.append("Content-Disposition: form-data; name=\"1\"; filename=\"" + userid + ".jpg" + "\"\r\n");
            strBuf.append("Content-Type: image/jpeg" + "\r\n\r\n");
            out.write(strBuf.toString().getBytes());

            // 获取文件流
            FileInputStream fileInputStream = new FileInputStream(file);
            DataInputStream inputStream = new DataInputStream(fileInputStream);

            // 每次上传文件的大小(文件会被拆成几份上传)
            int bytes = 0;
            // 计算上传进度
            float count = 0;
            // 获取文件总大小
            int fileSize = fileInputStream.available();
            // 每次上传的大小
            byte[] bufferOut = new byte[1024];
            // 上传文件
            while ((bytes = inputStream.read(bufferOut)) != -1) {
                // 上传文件(一份)
                out.write(bufferOut, 0, bytes);
                // 计算当前已上传的大小
                count += bytes;
                // 打印上传文件进度(已上传除以总大*100就是进度)
                final float pct = (count / fileSize * 100);
                //Log.v("ModifyIcon", "progress:" + pct+ "%");
                //
                Handler mainHandler = new Handler(Looper.getMainLooper());
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        txttip.setText(getString(R.string.upload_file_now) + pct + "%");
                    }
                });
            }

            //上传完成
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(context, getString(R.string.upload_file_ok), Toast.LENGTH_SHORT).show();
                    ;
                    txttip.setText("");
                }
            });

            // 关闭文件流
            inputStream.close();

            // 标识payLoad + 文件流的结尾位置
            out.write(preFix.getBytes());

            // 至此上传代码完毕

            // 总结上传数据的流程：preFix + payLoad(标识服务器表单接收文件的格式) + 文件(以流的形式) + preFix
            // 文本与图片的不同,仅仅只在payLoad那一处的后缀的不同而已。

            // 输出所有数据到服务器
            out.flush();

            // 关闭网络输出流
            out.close();

            // 重新构造一个StringBuffer,用来存放从服务器获取到的数据
            strBuf = new StringBuffer();

            // 打开输入流 , 读取服务器返回的数据
            BufferedReader reader = new BufferedReader(new
                    InputStreamReader(conn.getInputStream()));

            String line;

            // 一行一行的读取服务器返回的数据
            while ((line = reader.readLine()) != null) {
                strBuf.append(line).append("\n");
            }

            // 关闭输入流
            reader.close();

            // 打印服务器返回的数据
            Log.v("ModifyIcon", "上传成功:" + strBuf.toString());

            //上传成功后替换本地图片
            String uid = LoginInfo.infokey.get("userid");
            String stricon = LoginInfo.getUserIconLocalPath(context,uid);
            CopyFile.copy(uploadImagePath, stricon);

        } catch (Exception e) {
            Log.v("ModifyIcon", "上传图片出错:" + e.toString());
            AssertAlert.show(context, R.string.alert, R.string.upload_file_fail);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }

    }

    //--------------------------
    //显示图片
    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void handleImageOnKitkat(Intent data) {
        String imagePath = null;
        Uri uri = data.getData();
        if (DocumentsContract.isDocumentUri(this, uri)) {
            // 如果是document类型的Uri，则通过document id处理
            String docId = DocumentsContract.getDocumentId(uri);
            if ("com.android.providers.media.documents".equals(uri
                    .getAuthority())) {
                String id = docId.split(":")[1]; // 解析出数字格式的id
                String selection = MediaStore.Images.Media._ID + "=" + id;
                imagePath = getImagePath(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, selection);
            } else if ("com.android.providers.downloads.documents".equals(uri
                    .getAuthority())) {
                Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"),
                        Long.valueOf(docId));
                imagePath = getImagePath(contentUri, null);
            }
        } else if ("content".equalsIgnoreCase(uri.getScheme())) {
            // 如果不是document类型的Uri，则使用普通方式处理
            imagePath = getImagePath(uri, null);
        }
        displayImage(imagePath); // 根据图片路径显示图片
        System.err.println(imagePath);
    }

    private String getImagePath(Uri uri, String selection) {
        String path = null;
        // 通过uri和selection来获取真实的图片路径
        Cursor cursor = getContentResolver().query(uri, null, selection, null,
                null);
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                path = cursor.getString(cursor
                        .getColumnIndex(MediaStore.Images.Media.DATA));
            }
            cursor.close();
        }
        return path;
    }

    private void displayImage(String imagePath) {
        if (imagePath != null) {
            Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
            //将图片改成正方形,然后保存到临时目录里面
            bitmap=SquareBitmap.centerSquareScaleBitmap(bitmap,500);
            String stricon = context.getCacheDir() + "/hx-kong/myicon.tmp";
            try {
                SquareBitmap.saveBitmap(bitmap,stricon);
            } catch (IOException e) {
                e.printStackTrace();
            }
            //
            icon.setImageBitmap(bitmap);
            //上传图片
            uploadImagePath = stricon;
            new Thread(uploadTh).start();
        } else {
            Toast.makeText(this, "failed to get image", Toast.LENGTH_SHORT)
                    .show();
        }
    }

    //-----------------------
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case CHOOSE_PHOTO:
                if (resultCode == RESULT_OK) {
                    handleImageOnKitkat(data);
                }

                break;
        }
    }

}
