//
//  TestFunc.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/26.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

func getTestFun() -> [GAInputParam] {
    var testFunc = [GAInputParam]()
    
    testFunc.append(GAInputParam(fun: { (p) -> (Double) in
        return 10 + sin(1.0 / p[0]) / (pow(p[0]-0.16,2) + 0.1)
    }, numberOfParam: 1, minArray: [-0.5], maxArray: [0.5], stepArray: [0.01]))
    
    // 函数有问题
//    testFunc.append(GAInputParam(fun: { (p) -> (Double) in
//        return -(100 * (p[1] - pow(p[0], 2))^2 + (1-p[0])^2)
//    }, numberOfParam: 2, minArray: [-5.12,-5.12], maxArray: [5.12,5.12]))
    
    testFunc.append(GAInputParam(fun: { (p) -> (Double) in
        return -(p[0]^2 + p[1]^2 - 0.3 * cos(3 * Double.pi * p[0]) + 0.3 * cos(4 * Double.pi * p[1]) + 0.3)
    }, numberOfParam: 2, minArray: [-1,-1], maxArray: [1,1])) // 最大x值为0.24 可以做到0.234
    
    testFunc.append(GAInputParam(fun: { (p) -> (Double) in
        var left = 0.0
        var right = 0.0
        for i in 1...5{
            left += Double(i) * cos(Double((i+1)) * p[0] + Double(i))
            right += Double(i) * cos(Double((i+1)) * p[1] + Double(i))
        }
        return -(left * right)
    }, numberOfParam: 2)) // 最大值为 186.73
    return testFunc
}
