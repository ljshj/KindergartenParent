//
//  HttpTool.m
//  新浪微博
//
//  Created by apple on 13-10-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "HttpTool.h"
#import "AFNetworking.h"

@implementation HttpTool
+ (void)requestWithPath:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure method:(NSString *)method
{
    
     NSString *urlString = [NSString stringWithFormat:@"kindergarten/service/app!%@.action",path];
    
    // 1.创建post请求
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    // 拼接传进来的参数
    if (params) {
        [allParams setDictionary:params];
    }
   // MyLog(@"%@",allParams);
    NSMutableURLRequest *request = [client requestWithMethod:method path:urlString parameters:allParams];
    
    
    MyLog(@"Request: %@ --- params : %@",request.URL,allParams);
    //设置超时
    [request setTimeoutInterval:10];
    // 2.创建AFJSONRequestOperation对象
    NSOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success == nil) return;
        success(JSON);
        //MyLog(@"%@",JSON);
    }
    failure : ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure == nil) return;
        //[SVProgressHUD showErrorWithStatus:@"网络请求错误" duration:1];
//#warning 错误信息
        failure(error);
    }];
    
    // 3.发送请求
    [op start];
}

#pragma mark 上传图像
+ (void)updateFileWithPath:(NSString *)path params:(NSDictionary *)params withImag:(UIImage*)image success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure
{

    // 1. 定义httpClient
    // 所谓baseURL就是此后所有的请求都基于此地址
    NSURL *url = [NSURL URLWithString:kBaseUrl];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
     NSString *urlString = [NSString stringWithFormat:@"kindergarten/service/app!%@.action?username=%@&role=0&isParse=false&profileimg=123",path,[LoginUser sharedLoginUser].userName];
    // 2. 根据httpClient生成post请求
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 提示：UIImage不能为空
        NSData *data = UIImagePNGRepresentation(image);
        
        /**
         参数说明：
         
         1. fileData:   要上传文件的数据
         2. name:       负责上传文件的远程服务中接收文件使用的字段名称
         3. fileName：   要上传文件的文件名
         4. mimeType：   要上传文件的文件类型
         
         提示，在日常开发中，如果要上传图片到服务器，一定记住不要出现文件重名的问题！
         这个问题，通常涉及到前端程序员和后端程序员的沟通。
         
         通常解决此问题，可以使用系统时间作为文件名！
         */
        // 1) 取当前系统时间
        NSDate *date = [NSDate date];
        // 2) 使用日期格式化工具
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        // 3) 指定日期格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateStr = [formatter stringFromDate:date];
        // 4) 使用系统时间生成一个文件名
        NSString *fileName = [NSString stringWithFormat:@"%@.png", dateStr];
        
        [formData appendPartWithFileData:data name:@"filename" fileName:fileName mimeType:@"image/png"];
        
    }];
    
    // 准备做上传的工作！
    // 3. operation
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    MyLog(@"%@--->%@",request,params);
    
    // 显示上传进度
    /*
     bytesWritten   本次上传的字节数(本次上传了5k)
     totalBytesWritten  已经上传的字节数(已经上传了80k)
     totalBytesExpectedToWrite  文件总字节数（100k）
     */
    [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        
       // NSLog(@"上传 %f", (float)(totalBytesWritten / totalBytesExpectedToWrite));
    }];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        MyLog(@"%@",responseObject);
//          NSLog(@"成功呢！json ===%@",operation.responseString);
//         NSLog(@"upload finish ---%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
        //NSLog(@"上传文件成功");
        success(operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure(error);
       // NSLog(@"上传文件失败 %@", error);
    }];
    
    // 4. operation start
    [op start];
    
}

+ (void)postWithPath:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure
{
    [self requestWithPath:path params:params success:success failure:failure method:@"POST"];
}

+ (void)getWithPath:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure
{
    [self requestWithPath:path params:params success:success failure:failure method:@"GET"];
}


@end