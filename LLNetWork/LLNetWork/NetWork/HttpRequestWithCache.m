//
//  HttpRequestWithCache.m
//  LLNetWork
//
//  Created by LLVK on 29/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#import "HttpRequestWithCache.h"


#define kURLString(method) [BASEURL stringByAppendingFormat:@"%@",method]

NSString *const kStatus = @"status";
NSString *const kMessage = @"message";
NSString *const kData = @"data";

NSString *const kErrorInfo = @"网络异常,请检查网络链接";
NSString *const kSuccess = @"成功";

// 请求方式
typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeGet,
    RequestTypePost,
    RequestTypeUpLoad,
    RequestTypeMultiUpload,
    RequestTypeDownload
};
@interface HttpRequestWithCache ()
@property (nonatomic,strong) NSOperationQueue *queue;
@end
@implementation HttpRequestWithCache
{
    __weak HttpRequestWithCache *weakSelf;
    
}

#pragma mark - Get方法
+ (void)getRequestMethod:(NSString *)method param:(NSDictionary *)param isCache:(BOOL)cache withBlock:(void(^)(id response,NSInteger errorCode))block{
    [self httpRequestWithMethod:method param:param requestType:RequestTypeGet isCache:cache withImageData:nil withImageDataArray:nil block:block];
}

#pragma mark - Post方法
+ (void)postRequestMethod:(NSString *)method param:(NSDictionary *)param isCache:(BOOL)cache withBlock:(void(^)(id response,NSInteger errorCode))block{
    [self httpRequestWithMethod:method param:param requestType:RequestTypePost isCache:cache withImageData:nil withImageDataArray:nil block:block];
}

#pragma mark - 上传文件方法
//上传单张图片
+ (void)upLoadDataWithMethod:(NSString *)method param:(NSDictionary *)param imageKey:(NSString *)name withData:(NSData *)data withBlock:(void(^)(id response,NSInteger errorCode))block{
    [self httpRequestWithMethod:method param:param requestType:RequestTypeUpLoad isCache:NO withImageData:data withImageDataArray:nil block:block];
}
//上传多张图片
+ (void)upLoadDataWithMethod:(NSString *)method param:(NSDictionary *)param  withDataArray:(NSArray *)dataArray withBlock:(void(^)(id response,NSInteger errorCode))block{
    [self httpRequestWithMethod:method param:param requestType:RequestTypeUpLoad isCache:NO withImageData:nil withImageDataArray:dataArray block:block];
}

#pragma mark - 网络请求统一处理
/**
 *  @param method           接口名
 *  @param param            参数dict
 *  @param requestType      请求类型
 *  @param isCache          是否缓存标志
 *  @param imageData        图片的二进制数据(upload)
 *  @param imageDataArray   多图片上传时的imageDataArray
 */
+ (void)httpRequestWithMethod:(NSString *)method param:(NSDictionary *)param requestType:(RequestType)requestType isCache:(BOOL)isCache withImageData:(NSData *)imageData withImageDataArray:(NSArray *)imageDataArray block:(void(^)(id response,NSInteger errorCode))block{
    
    //对param进行处理 可以在此加上后台需要的Source,AppVersion,token
    if (param != nil) {
        
//        [param setObject:Source forKey:@"Source"];
//        [param setObject:AppVersion forKey:@"AppVersion"];
//        [param setObject:Token forKey:@"token"];
    }else{
        param = [NSMutableDictionary dictionary];
    }

    //打印完整的url
    DLog(@"url is ------> %@",[self urlDictToStringWithUrlStr:kURLString(method) WithDict:param]);
    
    //设置YYCache属性
    YYCache *cache = [[YYCache alloc] initWithName:CacheName];
    
    cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    id cacheData;
    /* 此处要修改为,服务端不要求重新拉取数据时执行;注意当缓存没取到时,重新访问接口
     if (isCache) {
     
     //根据网址从Cache中取数据
     cacheData = [cache objectForKey:cacheKey];
     if(cacheData!=nil)
     {
     //将数据统一处理
     [self returnDataWithRequestData:cacheData];
     }
     }
     */
    
    //进行网络检查
    if (![self requestBeforeJudgeConnect])
    {
        //断网
        [MBProgressHUD showErrorMessage:kErrorInfo];
        DLog(@"\n\n----%@------\n\n",@"没有网络");
        //断网后,根据网址从Cache中取数据进行显示
        id cacheData = [cache objectForKey:kURLString(method)];
        if( cacheData != nil )
        {
            //处理
            [self resultHandleWithData:(NSDictionary *)cacheData block:block];
        }
        return;
    }
    
    if (requestType == RequestTypeGet){
    
        [[self setOperationManager] GET:kURLString(method) parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self dealWithResponseObject:responseObject cacheUrl:method cacheData:cacheData isCache:isCache cache:cache cacheKey:kURLString(method) block:block];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            block(nil,2);
            [self showErrorInfo:error];

        }];
    }
    else if (requestType == RequestTypePost){
        [[self setOperationManager] POST:kURLString(method) parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self dealWithResponseObject:responseObject cacheUrl:method cacheData:cacheData isCache:isCache cache:cache cacheKey:kURLString(method) block:block];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            block(nil,2);
            [self showErrorInfo:error];

        }];
    
    }
    else if (requestType == RequestTypeUpLoad){
    
        [[self setOperationManager] POST:kURLString(method) parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                if (!kStringIsEmpty(obj))
                {
                    [formData appendPartWithFileData:[NSData dataWithContentsOfFile:obj] name:key fileName:obj mimeType:IMAGE_JPEG];
                }
            }];
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
                 [self dealWithResponseObject:responseObject cacheUrl:method cacheData:cacheData isCache:isCache cache:nil cacheKey:nil block:block];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            block(nil,2);
            [self showErrorInfo:error];


        }];
    }
    else if (requestType == RequestTypeMultiUpload){
        [[self setOperationManager] POST:kURLString(method) parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            for (NSInteger i = 0; i < imageDataArray.count; i++)
            {
                NSData *imageData = [imageDataArray objectAtIndex:i];
                //name和服务端约定好
                [formData appendPartWithFileData:imageData name:@"imageFile" fileName:[NSString stringWithFormat:@"%zi.png",i] mimeType:IMAGE_JPEG];
            }
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self dealWithResponseObject:responseObject cacheUrl:method cacheData:cacheData isCache:isCache cache:nil cacheKey:nil block:block];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            block(nil,2);
            [self showErrorInfo:error];
        }];
    }
}

#pragma mark  统一处理数据
+ (void)dealWithResponseObject:(NSData *)responseData cacheUrl:(NSString *)cacheUrl cacheData:(id)cacheData isCache:(BOOL)isCache cache:(YYCache*)cache cacheKey:(NSString *)cacheKey block:(void(^)(id response,NSInteger errorCode))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    
    
    NSString * dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    dataString = [self deleteSpecialCodeWithStr:dataString];
    NSData *requestData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (isCache) {
        //需要缓存,就进行缓存
        [cache setObject:requestData forKey:cacheKey];
    }
    /*
     //如果不缓存 或 数据不相同,就把网络返回的数据显示
     if (!isCache || ![cacheData isEqual:requestData]) {
     
     [self returnDataWithRequestData:requestData];
     }
     */
    
    DLog(@"response is %@",[self jsonSerialization:requestData]);

    
    //不管缓不缓存都要显示数据
    [self resultHandleWithData:[self jsonSerialization:requestData] block:block];
    

}
#pragma mark - 请求成功处理
+ (void)resultHandleWithData:(NSDictionary *)data block:(void(^)(id response,NSInteger errorCode))block
{
    
    if ([data[kStatus] isEqualToNumber:@0])
    {
        NSString *msg = data[kMessage];
        
        if (!kStringIsEmpty(msg) && ![msg isEqualToString:kSuccess]) {
            [MBProgressHUD showErrorMessage:msg];
        }else{
            block(data[kData],0);
            DLog(@"%@",data[kData])
        }
    }else{
        
        [MBProgressHUD showErrorMessage:[data[kStatus] isEqualToNumber:@1]?data[kMessage]:kErrorInfo];
        block(nil,1);
    }
}
#pragma mark - json解析
+ (instancetype)jsonSerialization:(id)data
{
    NSError *error = nil;
    return  !error?[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error]:nil;
}

#pragma mark - setOperationManager
+ (AFHTTPSessionManager *)setOperationManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [HttpRequestWithCache sharedInstace].queue = [manager operationQueue];
    
    return manager;
}
#pragma mark -- 处理json格式的字符串中的换行符、回车符
+ (NSString *)deleteSpecialCodeWithStr:(NSString *)str {
    NSString *string = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    return string;
}
+ (HttpRequestWithCache *)sharedInstace
{
    static HttpRequestWithCache *request = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[HttpRequestWithCache alloc]init];
    });
    return request;
}
/**
 *  拼接请求的网络地址
 *
 *  @param urlStr     基础网址
 *  @param parameters 拼接参数
 *
 *  @return 拼接完成的网址
 */
+ (NSString *)urlDictToStringWithUrlStr:(NSString *)urlString WithDict:(NSDictionary *)parameters
{
    if (!parameters) {
        return urlString;
    }
    
    
    NSMutableArray *parts = [NSMutableArray array];
    //enumerateKeysAndObjectsUsingBlock会遍历dictionary并把里面所有的key和value一组一组的展示给你，每组都会执行这个block 这其实就是传递一个block到另一个方法，在这个例子里它会带着特定参数被反复调用，直到找到一个ENOUGH的key，然后就会通过重新赋值那个BOOL *stop来停止运行，停止遍历同时停止调用block
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //字符串处理
        key=[NSString stringWithFormat:@"%@",key];
        obj=[NSString stringWithFormat:@"%@",obj];
        
        //接收key
        NSString *finalKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //接收值
        NSString *finalValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *part =[NSString stringWithFormat:@"%@=%@",finalKey,finalValue];
        
        [parts addObject:part];
        
    }];
    
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    
    queryString = queryString.length!=0 ? [NSString stringWithFormat:@"?%@",queryString] : @"";
    
    NSString *pathStr = [NSString stringWithFormat:@"%@%@",urlString,queryString];
    
    return pathStr;
    
}
#pragma mark  网络判断
+ (BOOL)requestBeforeJudgeConnect
{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable  =(isReachable && !needsConnection) ? YES : NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible =isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    });
    return isNetworkEnable;
}
+ (void)showErrorInfo:(NSError * _Nonnull )error{
    
    [MBProgressHUD showErrorMessage:[self errorInfo:error.code]];
    DLog(@"\n-------------请求错误：---------------\nerror.code:%@\n\nerror.description:%@\n\nerror.domain:%@\n------------------------------------",@(error.code),error.description,error.domain)

}
#pragma mark 根据后台返回的errorCode定义报错内容
+ (NSString *)errorInfo:(NSInteger)errorCode
{
    switch (errorCode)
    {
        case -1009: return @"网络异常，请检查网络链接";
        default: return kErrorInfo;
    }
}

@end
