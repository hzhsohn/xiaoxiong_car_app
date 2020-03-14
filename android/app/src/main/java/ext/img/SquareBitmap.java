package ext.img;

import android.graphics.Bitmap;
import android.os.Environment;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * Created by hzh on 2018/2/28.
 */

public class SquareBitmap {
    /**

     * @param bitmap      原图
     * @param edgeLength  希望得到的正方形部分的边长
     * @return  缩放截取正中部分后的位图。
     */
    public static Bitmap centerSquareScaleBitmap(Bitmap bitmap, int edgeLength)
    {
        if(null == bitmap || edgeLength <= 0)
        {
            return  null;
        }

        Bitmap result = bitmap;
        int widthOrg = bitmap.getWidth();
        int heightOrg = bitmap.getHeight();

        if(widthOrg > edgeLength && heightOrg > edgeLength)
        {
            //压缩到一个最小长度是edgeLength的bitmap
            int longerEdge = (int)(edgeLength * Math.max(widthOrg, heightOrg) / Math.min(widthOrg, heightOrg));
            int scaledWidth = widthOrg > heightOrg ? longerEdge : edgeLength;
            int scaledHeight = widthOrg > heightOrg ? edgeLength : longerEdge;
            Bitmap scaledBitmap;

            try{
                scaledBitmap = Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true);
            }
            catch(Exception e){
                return null;
            }


            int ffszie=0;
            //从图中截取正中间的正方形部分。
            int xTopLeft = 0;
            int yTopLeft = 0;

            if(scaledWidth < scaledHeight)
            {
                ffszie=scaledWidth;
                yTopLeft = (scaledHeight - ffszie) / 2;
            }
            else
            {
                ffszie=scaledHeight;
                xTopLeft = (scaledWidth - ffszie) / 2;
            }

            try{
                result = Bitmap.createBitmap(scaledBitmap, xTopLeft, yTopLeft, edgeLength, edgeLength);
                scaledBitmap.recycle();
            }
            catch(Exception e){
                return null;
            }
        }
        else
        {
            int ffszie=0;
            //从图中截取正中间的正方形部分。
            int xTopLeft = 0;
            int yTopLeft = 0;

            if(widthOrg < heightOrg)
            {
                ffszie=widthOrg;
                yTopLeft = (heightOrg - ffszie) / 2;
            }
            else
            {
                ffszie=heightOrg;
                xTopLeft = (widthOrg - ffszie) / 2;
            }

            try{
                result = Bitmap.createBitmap(bitmap, xTopLeft, yTopLeft, ffszie, ffszie);
                bitmap.recycle();
            }
            catch(Exception e){
                return null;
            }
        }

        return result;
    }

    public static void saveBitmap(Bitmap bitmap,String bitName) throws IOException
    {
        File file = new File(bitName);
        if(file.exists()){
            file.delete();
        }
        FileOutputStream out;
        try{
            out = new FileOutputStream(file);
            if(bitmap.compress(Bitmap.CompressFormat.PNG, 90, out))
            {
                out.flush();
                out.close();
            }
        }
        catch (FileNotFoundException e)
        {
            e.printStackTrace();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }
}
