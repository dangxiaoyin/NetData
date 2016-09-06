//
//  NetData.m
//  SqrForEnvironmental
//
//  Created by dangxy on 16/8/2.
//  Copyright © 2016年 SqrBigData. All rights reserved.
//
// 原理：通过函数getifaddrs来得到系统网络接口的信息，网络接口的信息, 包含在if_data字段中, 有很多信息, 但我现在只关心ifi_ibytes, ifi_obytes, 应该就是接收到的字节数和发送的字节数, 加起来就是流量了. 还发现, 接口的名字, 有en, pdp_ip, lo等几种形式, en应该是wifi, pdp_ip大概是3g或者gprs, lo是环回接口, 通过名字区分可以分别统计

#import "NetData.h"

#include <ifaddrs.h>

#include <sys/socket.h>

#include <net/if.h>

@implementation NetData


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static NetData *net;
    dispatch_once(&onceToken, ^{
        net = [[self alloc] init];
    });
    return net;
}

// .3G/GPRS流量统计

- (int)getGprs3GFlowIOBytes {
    
    struct ifaddrs *ifa_list= 0, *ifa;
    
    if (getifaddrs(&ifa_list)== -1) {
        
        return 0;
        
    }
    
    uint32_t iBytes =0;
    
    uint32_t oBytes =0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
        
    {
        
        if (AF_LINK!= ifa->ifa_addr->sa_family)
            
            continue;
        
        if (!(ifa->ifa_flags& IFF_UP) &&!(ifa->ifa_flags& IFF_RUNNING))
            
            continue;
        
        if (ifa->ifa_data== 0)
            
            continue;
        
        if (!strcmp(ifa->ifa_name,"pdp_ip0")) {
            
            struct if_data *if_data = (struct if_data*)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            
            oBytes += if_data->ifi_obytes;
            
            NSLog(@"%s :iBytes is %d, oBytes is %d",ifa->ifa_name, iBytes, oBytes);
            
        }
        
    }
    
    freeifaddrs(ifa_list);
    
    return iBytes + oBytes;

}


// .WIFI流量统计功能

- (long long int)getInterfaceBytes {
    
    struct ifaddrs *ifa_list = 0, *ifa;
    
    if (getifaddrs(&ifa_list) == -1) {
        
        return 0;
        
    }
    
    uint32_t iBytes = 0;
    
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        
        if (AF_LINK != ifa->ifa_addr->sa_family)
            
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            
            continue;
        
        if (ifa->ifa_data == 0)
            
            continue;
        
        /* Not a loopback device. */
        
        if (strncmp(ifa->ifa_name, "lo", 2))
            
        {
            
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            
            oBytes += if_data->ifi_obytes;
            
            //            NSLog(@"%s :iBytes is %d, oBytes is %d",
            
            //                  ifa->ifa_name, iBytes, oBytes);
            
        }
        
    }
    
    freeifaddrs(ifa_list);
    
    return iBytes+oBytes;
    
}


// 以上获取的数据可以通过以下方式进行单位转换

- (NSString *)bytesToAvaiUnit:(long long int)bytes {
    if(bytes < 1024)   { // B
        
        return [NSString stringWithFormat:@"%lldB", bytes];
        
    }
    
    else if(bytes >= 1024 && bytes < 1024 * 1024) { // KB
        
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
        
    }
    
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)  { // MB
        
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
        
    }
    
    else {// GB
        
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
        
    }
}


@end
