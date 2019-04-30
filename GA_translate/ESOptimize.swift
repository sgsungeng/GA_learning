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
    init(isGenerateArgum: Bool = false) {
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
            self.standardDeviation = Random.getNormalDistributions(count: ESIndividual.numberOfArgument)
            self.caculateFitness()
        }
    }
    func  productChild(count: Int) -> [ESIndividual] {
        let re = [ESIndividual](repeating: ESIndividual(), count: count)
        
        for item in re {
            while true{
                for i in 0..<ESIndividual.numberOfArgument{
                    
                    item.argument.append(Random.getUniformDistribution(min: ESIndividual.minAndMax.min[i], max: ESIndividual.minAndMax.max[i]))
                }
                if item.isFitRestrain(){
                    break
                }else{
                    item.argument.removeAll()
                }
            }
            for i in 0..<ESIndividual.numberOfArgument{
                item.standardDeviation.append(self.standardDeviation[i] * e^Random.getUniformDistribution())
            }
        }
        for item in re {
            item.caculateFitness()
        }
        return re
    }
}
class ESOption: OPOption {
    var parentNum = 20
    var sonNumMulit = 7
    
}

class ESOptimize: Optimizer {
    func optimiz(inputParam: OPInputParam) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
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
        return self.optimiz(aimFunc: inputParam.fun, restrain: restrain, minAndMax: (inputParam.minArray,inputParam.maxArray), argumNum: inputParam.numberOfVar)
    }
    
    
    func optimiz(aimFunc: @escaping ([Double]) -> (Double), restrain: [(([Double]) -> (Bool))], minAndMax: ([Double], [Double]), argumNum: Int, option: OPOption = ESOption()) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        ESIndividual.minAndMax = minAndMax
        ESIndividual.restrain = restrain
        ESIndividual.aimfunc = aimFunc
        ESIndividual.numberOfArgument = argumNum
        self.population.removeAll()
        self.sonPopulation.removeAll()
        let option = option as! ESOption
        for _ in 0..<option.cycleTimes {
            generalPopulation(count: option.parentNum)
            mutating(multi: option.sonNumMulit)
            select(count: option.parentNum)
        }
        
        return (self.population[0],self.population,OPExitInfo())
    }
    
   
    
    
    var population = [ESIndividual]()
    var sonPopulation = [ESIndividual]()
    
    private func generalPopulation(count:Int) {
        for _ in 0..<count {
            population.append(ESIndividual(isGenerateArgum: true))
        }
    }
    private func mutating(multi: Int) {
        sonPopulation.removeAll()
        for i in 0..<population.count {
            sonPopulation += population[i].productChild(count: multi)
        }
        
    }
    private func select(count: Int) {
        self.sonPopulation += self.population
        self.sonPopulation.sort(by: >)
        self.population = Array(self.sonPopulation[0..<count])
    }
}
