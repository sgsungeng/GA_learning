//
//  Optimize.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/27.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation


/// 优化器的个体表示
class OPIndividual:Comparable,CustomStringConvertible {
    static func < (lhs: OPIndividual, rhs: OPIndividual) -> Bool {
        return lhs.fitness < rhs.fitness
    }
    
    static func == (lhs: OPIndividual, rhs: OPIndividual) -> Bool {
        return lhs.fitness == rhs.fitness
    }
    
    var description: String{
        get{
            var str = "参数："
            str += self.argument.description
            str += "\n适应度："
            str += self.fitness.description
            return str
        }
    }
    
    /// 个体的参数
    var argument:[Double] = []
    static var numberOfArgument = 0 // 参数个数
    var fitness = 0.0 // 当前函数适应度
    
    /// 约束函数，可以包含等式，不等式
    static var restrain:[(([Double])->(Bool))] = []
    
    /// 变量范围，用于产生变量时使用方便
    static var minAndMax:(min:[Double],max:[Double]) = ([],[])
    
    /// 判断是否满足约束条件
    func isFitRestrain() -> Bool {
        for fun in OPIndividual.restrain{
            if fun(self.argument) == false{
                return false
            }
        }
        return true
    }
    static var aimfunc:(([Double])->(Double))!
    
    /// 计算适应度
    func caculateFitness() {
        self.fitness = OPIndividual.aimfunc(self.argument)
    }
    
}

enum ExitFlag {
    case timesOver // 迭代次数完成
    case minEqualToMax // 最小值等于最大值
    case _50TimesNoChange // 50次循环最优解没有变化
    
}

class OPOption {
    var cycleTimes = 300
}

class OPExitInfo {
    var exitFlag = ExitFlag.timesOver
    
}

/// 优化输入结构体
struct OPInputParam {
    var fun:(([Double])->Double)!
    var numberOfVar = 0
    var minArray:[Double] = []
    var maxArray:[Double] = []
    var stepArray:[Double] = []
    var unEqualArrayA:[Double?]? // A * X - B > 0
    var unEqualArrayB:[Double?]?
    var EqualArrayA:[Double?]? // A * X - B = 0
    var EqualArrayB:[Double?]?
    var otherRestrain = [([Double])->Bool]()
    
    
    init(fun: @escaping ([Double])->(Double),numberOfParam: Int,minArray:[Double] = [],maxArray:[Double] = [],stepArray:[Double] = []) {
        guard minArray.count == maxArray.count else {
            
            fatalError("param error")
        }
        if(minArray.count == 0){
            for _ in 0..<numberOfParam{
                self.minArray.append(-10)
                self.maxArray.append(10)
                self.stepArray.append(0.01)
            }
        }else{
            self.minArray = minArray
            self.maxArray = maxArray
        }
        if stepArray.count == 0 {
            for _ in 0..<numberOfParam{
                self.stepArray.append(0.01)
            }
        }else{
            self.stepArray = stepArray
        }
        self.fun = fun
        self.numberOfVar = numberOfParam
    }
}

///   优化器协议
protocol Optimizer {
    
    /// 常用优化h方法
    ///
    /// - Parameters:
    ///   - aimFunc: 目标函数
    ///   - restrain: 约束条件
    ///   - minAndMax: 变量上下界
    ///   - argumNum: 参数个数
    ///   - option: 优化参数
    /// - Returns: (fitness: 最优个体,population: 种群,exitInfo: 结束信息)
    func optimiz(aimFunc: @escaping ([Double])->(Double),restrain: [(([Double])->(Bool))],minAndMax:([Double],[Double]),argumNum: Int,option: OPOption) -> (fitness: OPIndividual,population: [OPIndividual],exitInfo: OPExitInfo)
    
    func optimiz(inputParam: OPInputParam)-> (fitness: OPIndividual,population: [OPIndividual],exitInfo: OPExitInfo)
}


