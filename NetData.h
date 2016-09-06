//
//  NetData.h
//  SqrForEnvironmental
//
//  Created by dangxy on 16/8/2.
//  Copyright © 2016年 SqrBigData. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetData : NSObject


+ (instancetype)sharedInstance;


// .3G/GPRS流量统计

- (int)getGprs3GFlowIOBytes;


// .WIFI流量统计功能

- (long long int)getInterfaceBytes;


// 以上获取的数据可以通过以下方式进行单位转换

- (NSString *)bytesToAvaiUnit:(long long int)bytes;



@end
