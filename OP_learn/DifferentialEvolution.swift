//
//  DifferentialEvolution.swift
//  OP_learn
//
//  Created by geng sun on 2019/5/27.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

class DEIndividual: OPIndividual {
    static var cachePool = [DEIndividual]()
    
    func productChildWith(individual1: DEIndividual, individual2: DEIndividual) -> DEIndividual {
        var newIndividual: DEIndividual!
        if DEIndividual.cachePool.isEmpty {
            newIndividual = DEIndividual()
        }else{
            newIndividual = DEIndividual.cachePool.popLast()!
        }
        
        repeat{
            newIndividual.argument.removeAll()
            let random = Random.getNormalDistribution()
            let i = Int(self.argument.count * Random.getUniformDistribution())
            for item in self.argument{
                newIndividual.argument.append(item)
            }
            newIndividual.argument[i] = self.argument[i] + random * (individual1.argument[i] - individual2.argument[i])
        }while(!newIndividual.isFitRestrain())
        
        newIndividual.caculateFitness()
        
        if(self.fitness > newIndividual.fitness){
            DEIndividual.cachePool.append(newIndividual)
            return self
        }else{
            DEIndividual.cachePool.append(self)
            return newIndividual
        }
        
    }
    
    
}


class DEOptimize: Optimizer {
    var population = [DEIndividual]()
    
    override func optimiz(inputParam: OPInputParam) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        return self.optimiz(aimFunc: inputParam.fun, restrain: self.convert(inputParam: inputParam), minAndMax: (inputParam.minArray,inputParam.maxArray), argumNum: inputParam.numberOfVar,option: OPOption())
    }
    override func optimiz(aimFunc: @escaping ([Double]) -> (Double), restrain: [(([Double]) -> (Bool))], minAndMax: ([Double], [Double]), argumNum: Int, option: OPOption = OPOption(cycleTimes: 300,parentNum: 20, sonNumMulit: 1)) -> (fitness: OPIndividual, population: [OPIndividual], exitInfo: OPExitInfo) {
        OPIndividual.minAndMax = minAndMax
        OPIndividual.restrain = restrain
        OPIndividual.aimfunc = aimFunc
        OPIndividual.numberOfArgument = argumNum
        self.population.removeAll()
        
        var index = 0;
        generalPopulation(count: option.parentNum)
        
        while isNotEnd(option: option, currentIndex: index) {
            
            index+=1
            mutating(count: option.parentNum)
//            print("第" + index.description + "代，最优值是：" + self.population.max()!.fitness.description)
            
            
        }
        return (self.population.max()!,self.population,exitinfo)
    }
    
    func generalPopulation(count:Int) {
        for _ in 0..<count {
            population.append(DEIndividual(isGenerateArgum: true))
        }
    }
    func mutating(count:Int){
        for i in 0..<count{
            let newIndex = Random.getUniformDistributions(count: 2, min: 0, max: Double(self.population.count)).map { (d) -> Int in
                return Int(d)
            }
            let i1 = self.population[newIndex[0]]
            let i2 = self.population[newIndex[1]]
            self.population[i] = self.population[i].productChildWith(individual1: i1, individual2: i2)
        }
    }
}
