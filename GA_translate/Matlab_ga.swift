//
//  Matlab_ga.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/22.
//  Copyright © 2019 geng sun. All rights reserved.
//  not use 



import Foundation



enum ExitFlat{
    
}
struct Option {
    var numberOfVariables  = 0
    var PopulationType = "doubleVector"
    var PopInitRange = [[Double]]()
    var PopulationSize:Int{
        if(numberOfVariables <= 5){
            return 50
        }else{
            return 200
        }
    }
    var EliteCount:Double{
        return Double(PopulationSize) * 0.05;
    }
    var CrossoverFraction = 0.8
    
    var MigrationDirection = "forward"
    var MigrationInterval = 20
    var MigrationFraction = 0.2
    var Generations:Double{
        return Double(numberOfVariables * 100)
    }
    var TimeLimit = Int.max
    var StallTimeLimit = Int.min
    var TolFun = 1e-6
    var TolCon = 1e-3
    var InitialPopulation = [[Double]]()
    var InitialScores = [Double]()
    var NonlinConAlgorithm = "auglag"
    var InitialPenalty = 10
    var PenaltyFactor = 100
    var PlotInterval = 1
    var CreationFcn:((Int,Int,[Int])->())?
    var FitnessScalingFcn: ((Int,Int,[Int])->())?
    var SelectionFcn: ((Int,Int,[Int])->())?
    var CrossoverFcn: ((Int,Int,[Int])->())?
    var MutationFcn: ((Int,Int,[Int])->())?
    var HybridFcn = [Double]()
    var Display = "final"
    var PlotFcns = [Double]()
    var OutputFcns = [Double]()
    var Vectorized = false
    var UseParallel = false
    init() {
        
    }
}
struct ReturnModel{
    var x:[Double] = [];
    var fval:Double = 0.0;
    var exitFlag:ExitFlat?;
    var output:Any?;
    var population:[[Double]] = [];
    var scores:Any?;
    
    init() {
    }
}

func ga(func:([Double])->Double,nvars:Int,Ainwq:[Double],Bineq:[Double],Aeq:[Double],Beq:[Double],lb:[Double],ub:[Double],nonlcon:Any,intcon:[Double],options:Option = Option()) -> ReturnModel {
    var defaultopt = options
    defaultopt.PopInitRange = [[-10],[10]]
    if !intcon.isEmpty {
        defaultopt.PopInitRange = [[-1e4+1],[1e4+1]]
    }
    
    return ReturnModel()
}



