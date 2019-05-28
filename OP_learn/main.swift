//
//  main.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/22.
//  Copyright © 2019 geng sun. All rights reserved.
//
import Foundation

let testF = getTestFun()

let op = DEOptimize()
//let a = Random.getNormalDistribution()
//print(a)
for t in testF{
    let maxm = op.optimiz(inputParam: t).fitness //Double(Int.min)
//    for _ in 0..<10{
//        maxm = max(op.optimiz(inputParam: t).fitness.fitness,maxm)
//    }
    
    print(maxm.fitness)
    print(maxm.isFitRestrain())
    print(maxm.argument)
}
