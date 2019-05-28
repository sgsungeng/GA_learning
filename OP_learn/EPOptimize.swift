//
//  EPOptimize.swift
//  OP_learn
//
//  Created by geng sun on 2019/5/26.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation
 class EPOption: ESOption {
    var Q = 0.5
    override init() {
        super.init()
        self.sonNumMulit = 2
    }
}
class EPIndividual: ESIndividual{
    var winTime = 0
    override func productChild(count: Int, success: Double) -> [ESIndividual] {
        var re = [EPIndividual]()
        
        for _ in 0..<count {
            var item:EPIndividual!
            if !EPIndividual.pool.isEmpty{
                item = (EPIndividual.pool.popLast() as! EPIndividual)
            }else{
                item = EPIndividual()
            }
            
            while true{
                for i in 0..<EPIndividual.numberOfArgument{
                    let newValue = self.argument[i] + self.standardDeviation[i] * Random.getNormalDistribution()
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
            
            for i in 0..<EPIndividual.numberOfArgument{
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
            re.append(item)
        }
        for item in re {
            item.caculateFitness()
        }
        return re
    }
}
class EPOptimize: ESOptimize {
    
    override func optimiz(inputParam: OPInputParam) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        return self.optimiz(aimFunc: inputParam.fun, restrain: self.convert(inputParam: inputParam), minAndMax: (inputParam.minArray,inputParam.maxArray), argumNum: inputParam.numberOfVar,option: EPOption())
    }
    
    override func optimiz(aimFunc: @escaping ([Double]) -> (Double), restrain: [(([Double]) -> (Bool))], minAndMax: ([Double], [Double]), argumNum: Int, option: OPOption = EPOption()) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        EPIndividual.minAndMax = minAndMax
        EPIndividual.restrain = restrain
        EPIndividual.aimfunc = aimFunc
        EPIndividual.numberOfArgument = argumNum
        self.sucssTime = 0
        self.population.removeAll()
        self.sonPopulation.removeAll()
        let option = option as! EPOption
        generalPopulation(count: option.parentNum)
        for index in 0..<option.cycleTimes {
            var ss = 0.2
            if index > 50{
                ss = self.sucssTime / Double(index)
            }
            mutating(multi: option.sonNumMulit, success: ss)
            select(count: option.parentNum,Q: option.Q)
//            print("第" + index.description + "代，最优值是：" + self.fitMax.fitness.description)
        }
        
        return (self.population[0],self.population,OPExitInfo())
    }
    override func generalPopulation(count:Int) {
        for _ in 0..<count {
            population.append(EPIndividual(isGenerateArgum: true))
        }
    }
    
    override func mutating(multi: Int, success: Double) {
        for item in (population as! [EPIndividual]) {
            sonPopulation += item.productChild(count: multi,success: success)
        }
    }
    
    fileprivate var trials = [EPIndividual]()
    func select(count: Int,Q:Double) { // q竞争法
        self.sonPopulation += self.population
        
        var son = self.sonPopulation as! [EPIndividual]
        self.trials.removeAll()
        let r = Random.getUniformDistributions(count: Int(Q*self.sonPopulation.count)).map { (d) -> Int in
            return Int(d * son.count)
        }
        trials = r.map { (i) -> EPIndividual in
            return son[i]
        }
        for item   in son{
            item.winTime = 0
            for trial in trials {
                if item > trial{
                    item.winTime += 1
                }
            }
        }
        son.sort { (l, r) -> Bool in
            return l.winTime > r.winTime
        }
        
        self.population = Array(son[0..<count])
        EPIndividual.pool = Array(son[count..<son.count])
        self.sonPopulation = [EPIndividual]()
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
