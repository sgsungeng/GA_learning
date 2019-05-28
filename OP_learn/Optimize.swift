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
    init(isGenerateArgum: Bool = false) {
        if isGenerateArgum {
            while true{
                for i in 0..<OPIndividual.numberOfArgument{
                    
                    self.argument.append(Random.getUniformDistribution(min: OPIndividual.minAndMax.min[i], max: OPIndividual.minAndMax.max[i]))
                }
                if self.isFitRestrain(){
                    break
                }else{
                    self.argument.removeAll()
                }
            }
            self.caculateFitness()
        }
    }
}

enum ExitFlag {
    case timesOver // 迭代次数完成
    case minEqualToMax // 最小值等于最大值
    case _50TimesNoChange // 50次循环最优解没有变化
}

class OPOption {
    var cycleTimes = 300
    var parentNum = 20
    var sonNumMulit = 7
    init() {
        
    }
    init(cycleTimes: Int,parentNum: Int, sonNumMulit: Int) {
        self.cycleTimes = cycleTimes
        self.parentNum = parentNum
        self.sonNumMulit = sonNumMulit
    }
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

///   优化器类
class Optimizer {
    var exitinfo = OPExitInfo() // 退出原因
    /// 常用优化h方法
    ///
    /// - Parameters:
    ///   - aimFunc: 目标函数
    ///   - restrain: 约束条件
    ///   - minAndMax: 变量上下界
    ///   - argumNum: 参数个数
    ///   - option: 优化参数
    /// - Returns: (fitness: 最优个体,population: 种群,exitInfo: 结束信息)
    func optimiz(aimFunc: @escaping ([Double])->(Double),restrain: [(([Double])->(Bool))],minAndMax:([Double],[Double]),argumNum: Int,option: OPOption = OPOption()) -> (fitness: OPIndividual,population: [OPIndividual],exitInfo: OPExitInfo){
        return (OPIndividual(),[],OPExitInfo())
    }
    func isNotEnd(option: OPOption,currentIndex: Int) -> Bool {
        return option.cycleTimes >= currentIndex
    }
    
    func optimiz(inputParam: OPInputParam) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
         return self.optimiz(aimFunc: inputParam.fun, restrain: self.convert(inputParam: inputParam), minAndMax: (inputParam.minArray,inputParam.maxArray), argumNum: inputParam.numberOfVar,option: OPOption())
    }
    func convert(inputParam: OPInputParam) -> [(([Double])->(Bool))] {
        var  restrain = inputParam.otherRestrain
        for item in inputParam.minArray.enumerated() {
            restrain.append { (p) -> Bool in
                return p[item.offset] > item.element
            }
        }
        for item in inputParam.maxArray.enumerated() {
            restrain.append { (p) -> Bool in
                return p[item.offset] < item.element
                
            }
        }
        if let unequalA = inputParam.unEqualArrayA,let unequalB = inputParam.unEqualArrayB {
            for item in unequalA.enumerated(){
                if let ele =  item.element{
                    restrain.append { (p) -> Bool in
                        return ele * p[item.offset] - unequalB[item.offset]! > 0
                    }
                }
                
            }
        }
        if let equalA = inputParam.EqualArrayA, let equalB = inputParam.EqualArrayB {
            for item in equalA.enumerated(){
                if let ele =  item.element{
                    restrain.append { (p) -> Bool in
                        return ele * p[item.offset] - equalB[item.offset]! == 0
                    }
                }
                
            }
        }
        return restrain
    }
}


