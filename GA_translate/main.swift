//
//  main.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/22.
//  Copyright © 2019 geng sun. All rights reserved.
//
import Foundation

let testF = getTestFun()

let ga = GeneAlgorithm()
for t in testF{
    var maxm = Double(Int.min)
    for _ in 0..<10{
        maxm = max(ga.ga(inputP: t).fitness.fitness,maxm)
    }
    print(maxm)
}
