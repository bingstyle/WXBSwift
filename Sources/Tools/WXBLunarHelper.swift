//
//  WXBLunarHelper.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import Foundation

public class LunarHelper: NSObject {
    
    private let startYear = 1900
    
    // 天干速查表
    let Gan = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
    // 地支速查表
    let Zhi = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
    // 生肖速查表
    let Animals = ["鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"]
    
    // 月份称呼速查表
    let MonthNames = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
    // 日期称呼速查表
    let DayNames = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
    "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
    "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
}

public extension LunarHelper {
    // 农历年份转换为干支纪年
    func ganzhiYear(y: Int) -> String {
        var ganKey = (y - 3) % 10
        var zhiKey = (y - 3) % 12
        //如果余数为0则为最后一个天干
        if ganKey == 0 {
            ganKey = 10
        }
        //如果余数为0则为最后一个地支
        if zhiKey == 0 {
            zhiKey = 12
        }
        return Gan[ganKey - 1] + Zhi[zhiKey - 1]
    }
    // 农历年份转生肖
    func getAnimal(y: Int) -> String {
        return  Animals[(y - 4) % 12]
    }
}

public extension LunarHelper {
    // 农历 y年闰哪个月 1-12 , 没闰传回 0
    func leapMonth(y: Int) -> Int {
        if y - startYear > lunarInfo.count - 1 || y - startYear < 0 {
            return 0
        }
        let result = (lunarInfo[y - startYear]) & 0xf
        return result
    }
    
    // 农历 y年m月的总天数
    func monthDays(y: Int, m: Int) -> Int {
        if y - startYear > lunarInfo.count - 1 || y - startYear < 0 {
            return 0
        }
        if ((lunarInfo[y - startYear] & (0x10000 >> m)) == 0) {
            return 29
        } else {
            return 30
        }
    }
    
    // 农历 y年闰月的天数
    func leapMonthDays(y: Int) -> Int {
        if y - startYear > lunarInfo.count - 1 || y - startYear < 0 {
            return 0
        }
        if (leapMonth(y: y) != 0) {
            if ((lunarInfo[y - startYear] & 0x10000) != 0) {
                return 30
            } else {
                return 29
            }
        } else {
            return 0
        }
    }
}

/*
 * 农历1900-2100的润月信息表
 */
fileprivate let lunarInfo = [
0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2, // 1900-1909
0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977, // 1910-1919
0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970,
0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557,
0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950, 0x06aa0,
0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0,
0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b5a0, 0x195a6,
0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570,
0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x055c0, 0x0ab60, 0x096d5, 0x092e0,
0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5, // 2000-2009
0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930, // 2010-2019
0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530,
0x05aa0, 0x076a3, 0x096d0, 0x04bd7, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45,
0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0, // 2050-2059
0x0a2e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4,
0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0,
0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160,
0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252, // 2090-2099
0x0d520, // 2100
];
