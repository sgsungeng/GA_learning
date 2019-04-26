//
//  Random.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/25.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

fileprivate let pi = 3.14159
class Random {
    
    /// 产生单个0~1.0的随机数
    static func getUniformDistribution() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// 产生均匀分布的随机数
    ///
    /// - Parameters:
    ///   - count: 数量
    ///   - min: 最小值
    ///   - max: 最大值
    static func getUniformDistributions(count: Int,min: Double = 0,max: Double = 1)->[Double]{
        var d = [Double]()
        for _ in 0..<count {
            d.append(getUniformDistribution() * (max - min) + min)
        }
        return d
    }
    
    /// 产生正态分布的随机数组
    ///
    /// - Parameters:
    ///   - count: 个数
    ///   - meanValue: 均值
    ///   - standardDeviation: 标准差
    static func getNormalDistributions(count: Int, meanValue: Double = 0,standardDeviation:Double = 1.0)->[Double]{
        var d = [Double]()
        for _ in 0..<count{
            let x = getUniformDistribution()
            let y = getUniformDistribution()
            let z = pow(-2*log(x),0.5) * cos(2 * pi * y)
            d.append(z)
        }
        if meanValue != 0 || standardDeviation != 1 {
            d = d.map { (a) -> Double in
                return a * standardDeviation + meanValue
            }
        }
        return d
    }
    
}
