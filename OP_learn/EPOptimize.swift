//
//  EPOptimize.swift
//  OP_learn
//
//  Created by geng sun on 2019/5/26.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

class EPOptimize: Optimizer {
    func optimiz(aimFunc: @escaping ([Double]) -> (Double), restrain: [(([Double]) -> (Bool))], minAndMax: ([Double], [Double]), argumNum: Int, option: OPOption) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
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
    
    private func generalPopulation(count:Int) {
        for _ in 0..<count {
            population.append(ESIndividual(isGenerateArgum: true))
        }
    }
    private func mutating(multi: Int, success: Double) {
        ESIndividual.cachePool(popu: sonPopulation)
        sonPopulation = [ESIndividual]()
        for i in 0..<population.count {
            sonPopulation += population[i].productChild(count: multi,success: success)
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
