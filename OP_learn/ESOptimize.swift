//
//  ESOptimize.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/27.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

fileprivate let e = 2.718281828459
class ESIndividual: OPIndividual {
    var standardDeviation:[Double] = []
    var p1:Double = 200
    static var pool = [ESIndividual]() // 缓存池避免多次创建
    override init(isGenerateArgum: Bool = false) {
        super.init()
        if isGenerateArgum {
            while true{
                for i in 0..<ESIndividual.numberOfArgument{
                    
                    self.argument.append(Random.getUniformDistribution(min: ESIndividual.minAndMax.min[i], max: ESIndividual.minAndMax.max[i]))
                }
                if self.isFitRestrain(){
                    break
                }else{
                    self.argument.removeAll()
                }
            }
            self.standardDeviation = Random.getNormalDistributions(count: ESIndividual.numberOfArgument).map({ (a) -> Double in
                return a > 0 ? a: -a
            })
            self.caculateFitness()
        }
    }
    func  productChild(count: Int,success: Double) -> [ESIndividual] {
        var re = [ESIndividual]()
        
        for _ in 0..<count {
            var item:ESIndividual!
            if !ESIndividual.pool.isEmpty{
                item = ESIndividual.pool.popLast()
            }else{
                item = ESIndividual()
            }
            for i in 0..<ESIndividual.numberOfArgument{
                var sigma = self.standardDeviation[i]
                if success - 0.2 > 0.00000001{
                    sigma *= 1.22
                }else if success - 0.2 < 0.00000001{
                    sigma *= 0.82
                }
                if item.standardDeviation.count > i { // 各项异性变异算子
                    item.standardDeviation[i] = sigma
                }else{
                    item.standardDeviation.append(sigma)
                }
            }
            while true{
                for i in 0..<ESIndividual.numberOfArgument{
                    let newValue = self.argument[i] + item.standardDeviation[i] * Random.getNormalDistribution()
                    if item.argument.count > i {
                        item.argument[i] = newValue
                    }else{
                        item.argument.append(newValue)
                    }
                }
                if item.isFitRestrain(){
                    break
                }else{
                    item.argument.removeAll()
                }
            }
            re.append(item)
        }
        for item in re {
            item.caculateFitness()
        }
        return re
    }
    static func cachePool(popu:[ESIndividual]){
        ESIndividual.pool = popu
        
    }
}
class ESOption: OPOption {
    var c_i = 1.22 //1/5成功法则参数
    var c_d = 0.82
}

class ESOptimize: Optimizer {
    var fitMax:ESIndividual!
    var sucssTime = 0.0
    override func optimiz(inputParam: OPInputParam) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        return self.optimiz(aimFunc: inputParam.fun, restrain: self.convert(inputParam: inputParam), minAndMax: (inputParam.minArray,inputParam.maxArray), argumNum: inputParam.numberOfVar,option: ESOption())
    }
    override func optimiz(aimFunc: @escaping ([Double]) -> (Double), restrain: [(([Double]) -> (Bool))], minAndMax: ([Double], [Double]), argumNum: Int, option: OPOption = ESOption()) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        ESIndividual.minAndMax = minAndMax
        ESIndividual.restrain = restrain
        ESIndividual.aimfunc = aimFunc
        ESIndividual.numberOfArgument = argumNum
        self.sucssTime = 0
        self.population.removeAll()
        self.sonPopulation.removeAll()
        let option = option as! ESOption
        generalPopulation(count: option.parentNum)
        for index in 0..<option.cycleTimes {
            var ss = 0.2
            if index > 50{
                ss = self.sucssTime / Double(index)
            }
            mutating(multi: option.sonNumMulit, success: ss)
            select(count: option.parentNum)
//            print("第" + index.description + "代，最优值是：" + self.fitMax.fitness.description)
        }
        
        return (self.population[0],self.population,OPExitInfo())
    }
    
   
    
    
    var population = [ESIndividual]()
    var sonPopulation = [ESIndividual]()
    
    func generalPopulation(count:Int) {
        for _ in 0..<count {
            population.append(ESIndividual(isGenerateArgum: true))
        }
    }
    func mutating(multi: Int, success: Double) {
        EPIndividual.cachePool(popu: sonPopulation)
        sonPopulation = [ESIndividual]()
        for item in population {
            sonPopulation += item.productChild(count: multi,success: success)
        }
    }
    func select(count: Int) {
        self.sonPopulation += self.population
        self.sonPopulation.sort(by: >)
        self.population = Array(self.sonPopulation[0..<count])
        if let m = self.fitMax{
            if self.population[0].fitness > m.fitness{
                sucssTime += 1
            }
        }else{
            sucssTime += 1
        }
        self.fitMax = self.population[0]
    }
}
