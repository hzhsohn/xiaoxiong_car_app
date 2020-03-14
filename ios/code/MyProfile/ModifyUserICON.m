//
//  ModifyUserICON.m
//  home
//
//  Created by Han.zh on 2017/7/15.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "ModifyUserICON.h"
#import <AFNetworking.h>
#import "GlobalParameter.h"
#import "LoginInfo.h"
#import "MD5File.h"

@interface ModifyUserICON ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    __weak IBOutlet UILabel *lbStatus;
    NSData* upImageData;
}
- (IBAction)btnSelect_click:(id)sender;

@end

@implementation ModifyUserICON

- (void)viewDidLoad {
    [super viewDidLoad];

    ///////////////////////////////////////////////
    //加载图像
    NSString*userid=[LoginInfo get:@"userid"];
    NSString*stricon=[GlobalParameter getUserIconLocalPath:userid];
    if(stricon)
    {
        UIImageView * picImageView = (UIImageView *)[self.view viewWithTag:500];
        UIImage*img=[UIImage imageWithContentsOfFile:stricon];
        picImageView.image=img;
    }
    
    [lbStatus setText:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//上传图片
- (void)saveImageToNet:(NSString*)url :(NSString*)filename :(UIImage *)image
{
    //
    NSString*userid=[LoginInfo get:@"userid"];
    if(!userid)
    {
        return ;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//初始化请求对象
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置服务器允许的请求格式内容
    //上传图片/文字，只能同POST
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id  _Nonnull formData) {
        [lbStatus setText:NSLocalizedString(@"upload begin", nil)];
        //对于图片进行压缩
        upImageData = UIImageJPEGRepresentation(image, 0.2);
        //NSData *data = UIImagePNGRepresentation(image);
        //第一个代表文件转换后data数据，第二个代表图片的名字，第三个代表图片放入文件夹的名字，第四个代表文件的类型
        [formData appendPartWithFileData:upImageData name:@"1"
                                fileName:[NSString stringWithFormat:@"%@.jpg",filename]
                                mimeType:@"image/jpg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSString *str=[NSString stringWithFormat:@"%.1f%%",uploadProgress.fractionCompleted];
        [lbStatus setText:str];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@, task = %@",responseObject,task);
        //        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        //        NSLog(@"obj = %@",obj);
        
        [lbStatus setText:NSLocalizedString(@"upload ok", nil)];
        //完成
        NSString*userid=[LoginInfo get:@"userid"];
        if(userid)
        {
            NSString*stricon=[GlobalParameter createUserIconLocalPath:userid];
            
            //保存图片到本地
            [upImageData writeToFile:stricon atomically:YES];
            
            if(stricon)
            {
                //更新MD5值
                NSString*pic_md5=[MD5File getFileMD5WithPath:stricon];
                if(pic_md5)
                {
                    [LoginInfo set:pic_md5 key:@"icon_md5"];
                }
                else{
                    [LoginInfo remove:@"icon_md5"];
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        [lbStatus setText:NSLocalizedString(@"upload fail", nil)];
    }];
}

#pragma mark 调用系统相册及拍照功能实现方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * chosenImage = info[UIImagePickerControllerEditedImage];
    UIImageView * picImageView = (UIImageView *)[self.view viewWithTag:500];
    picImageView.image = chosenImage;
    chosenImage = [self imageWithImageSimple:chosenImage scaledToSize:CGSizeMake(512, 512)];
    //将图片上传到服务器
    NSString*userid=[LoginInfo get:@"userid"];
    NSString*url=[GlobalParameter getAccountAddrByMob:@"up_icon.i.php"];
    [self saveImageToNet:url :userid :chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
//用户取消选取时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
- (IBAction)btnBack_click:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnSelect_click:(id)sender {
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alert.view.tintColor = [UIColor blackColor];
    //通过拍照上传图片
    UIAlertAction * takingPicAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }];
    //从手机相册中选择上传图片
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:takingPicAction];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];

}
@end
