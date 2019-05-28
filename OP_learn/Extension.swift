//
//  Extension.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/26.
//  Copyright © 2019 geng sun. All rights reserved.
//

import Foundation

infix operator ^: Precedenc
precedencegroup Precedenc{
    associativity: left
    higherThan: MultiplicationPrecedence
}
/// 定义方便的形式指数
func ^ (l:Double, r: Double) -> Double {
    return pow(l, r)
}

func * (l:Double,r: Int)->Double{
    return Double(r) * l
}
func * (l:Int,r: Double)->Double{
    return Double(l) * r
}
