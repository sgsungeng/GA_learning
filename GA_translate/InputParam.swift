//
//  InputParam.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/26.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

struct GAInputParam {
    var fun:(([Double])->Double)!
    var numberOfVar = 0
    var minArray:[Double] = []
    var maxArray:[Double] = []
    var stepArray:[Double] = []
    var unEqualArrayA:[Double?]?
    var unEqualArrayB:[Double?]?
    var EqualArrayA:[Double?]?
    var EqualArrayB:[Double?]?
    
    
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
