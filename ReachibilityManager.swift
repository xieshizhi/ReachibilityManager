//
//  ReachibilityManager.swift
//  reachability
//
//  Created by xiaoniu on 16/3/19.
//  Copyright © 2016年 谢仕志. All rights reserved.

//  1）把Reachability.h和Reachability.m文件拖到项目中
//  2）在桥接文件中包含头文件 即添加 #import "Reachability.h"
//  3) 添加框架:SystemConfiguration.framework。
//  4）在 func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {}中添加 ReachibilityManager.shareInstance()即可实时检测网络状态 并提醒网络状态的变化

import UIKit

class ReachibilityManager: NSObject {
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    let reach: Reachability
    var status: NetworkStatus

    //MARK: >> 单例化
    class func shareInstance() -> ReachibilityManager {
        struct dbSingle{
            static var onceToken:dispatch_once_t = 0
            static var instance:ReachibilityManager? = nil
        }
        //保证单例只创建一次
        dispatch_once(&dbSingle.onceToken, {
            dbSingle.instance = ReachibilityManager()
            //通知
            NSNotificationCenter.defaultCenter().addObserver(dbSingle.instance!, selector: "ReachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        })
        return dbSingle.instance!
    }
   
    func ReachabilityChanged(notification: NSNotification) {
        print("notification:\(notification)")
        let reach2 = notification.object
        if reach2 is Reachability {
            self.status = (reach2?.currentReachabilityStatus())!
            //收到通知后弹框提示
            showAlert()
        }
    }
    
    override init() {
        self.reach = Reachability.reachabilityForInternetConnection()
        self.status = reach.currentReachabilityStatus()
        //检测网络变化
        reach.startNotifier()
    }
    
    func showAlert() {
        let alert = UIAlertView()
        alert.title = ""
        alert.message = self.stringFromStatus(self.status)
        alert.addButtonWithTitle("好")
        alert.show()
    }
    
    private func stringFromStatus(status: NetworkStatus) -> String {
        var string = ""
        switch  status {
        case NotReachable:
            print("网络不可用")
            string = "网络不可用"
        case ReachableViaWWAN:
            print("移动网络")
            string = "移动网络"
        case ReachableViaWiFi:
            print("WIFI网络")
            string = "WIFI网络"
        default:
            print("网络状态不可知")
            string = "网络状态不可知"
            break
        }
        return string
    }

}
