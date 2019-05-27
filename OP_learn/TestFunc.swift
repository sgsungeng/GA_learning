//
//  TestFunc.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/26.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

fileprivate let pi = Double.pi
func getTestFun() -> [OPInputParam] {
    var testFunc = [OPInputParam]()
    // 函数1
    testFunc.append(OPInputParam(fun: { (p) -> (Double) in
        return 10 + sin(1.0 / p[0]) / (pow(p[0]-0.16,2) + 0.1)
    }, numberOfParam: 1, minArray: [-0.5], maxArray: [0.5], stepArray: [0.01]))
    
    // 函数有问题
//    testFunc.append(GAInputParam(fun: { (p) -> (Double) in
//        return -(100 * (p[1] - pow(p[0], 2))^2 + (1-p[0])^2)
//    }, numberOfParam: 2, minArray: [-5.12,-5.12], maxArray: [5.12,5.12]))
    
    // 函数3 最优解为0.24
    testFunc.append(OPInputParam(fun: { (p) -> (Double) in
        let x = p[0]
        let y = p[1]
        return  -(pow(x, 2) + pow(y,2) - 0.3 * cos(3 * Double.pi * x) + 0.3 * cos(4 * Double.pi * y) + 0.3)
    }, numberOfParam: 2, minArray: [-1,-1], maxArray: [1,1])) // 最大x值为0.24 可以做到0.234
    
    // 函数4： 186.73
    testFunc.append(OPInputParam(fun: { (p) -> (Double) in
        var left = 0.0
        var right = 0.0
        for i in 1...5{
            left += Double(i) * cos(Double((i+1)) * p[0] + Double(i))
            right += Double(i) * cos(Double((i+1)) * p[1] + Double(i))
        }
        return -(left * right)
    }, numberOfParam: 2))
    
    // 函数5：多峰函数，有四个全局最大值2.118
    testFunc.append(OPInputParam(fun: { (p) -> (Double) in
        let x = p[0]
        let y = p[1]
        return -(1 + x * sin(4 * Double.pi * x) - y * sin(4 * Double.pi * y + Double.pi) + sin(6 * sqrt((x^2) + (y^2)))/(6 * sqrt((x^2) + (y^2)) + (10 ^ -15)))
    }, numberOfParam: 2, minArray: [-1,-1], maxArray: [1,1]))
    
    // 函数6：
    testFunc.append(OPInputParam(fun: { (p) -> (Double) in
        let x = p[0]
        let y = p[1]
        return -(1 + x * sin(4 * Double.pi * x) - y * sin(4 * Double.pi * y + Double.pi))
    }, numberOfParam: 2, minArray: [-1,-1], maxArray: [1,1]))
    
    // 函数7： 其最优解近似为3600
    testFunc.append(OPInputParam(fun: { (p) -> (Double) in
        let x = p[0]
        let y = p[1]
        return (pow(3/(0.05 + pow(x, 2) + pow(y, 2)), 2)  + pow((pow(x, 2) + pow(y, 2)), 2))
    }, numberOfParam: 2, minArray: [-5.12,-5.12], maxArray: [5.12,5.12]))
    return testFunc
}
