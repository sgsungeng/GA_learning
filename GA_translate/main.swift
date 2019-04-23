//
//  main.swift
//  GA_translate
//
//  Created by geng sun on 2019/4/22.
//  Copyright © 2019 geng sun. All rights reserved.
//
import Foundation

let pi = 3.14159
struct Individual:Comparable{
    static func < (lhs: Individual, rhs: Individual) -> Bool {
        return lhs.fitness <= rhs.fitness
    }
    
    static var minArray:[Double] = []
    static var maxArray:[Double] = []
    static var stepArray:[Double] = []
    static var fun:(([Double])->(Double))!
    private static var gl:[Int]?
    static var genelengthes:[Int]{
        if gl == nil{
            gl = []
            for i in 0..<minArray.count{
                var c = 0
                var count = Int((maxArray[i]-minArray[i])/stepArray[i])
                while(count > 0){
                    c += 1
                    count /= 2
                }
                gl?.append(c)
            }
        }
        return gl!
    }
    var gene_decimal:[Double] = []
    var gene_binary:[Int8] = []
    var fitness:Double = 0
    mutating func binary2decimal() {
        var indexOfGene = 0
        var currentGeneIndex = 0
        for lenth in Individual.genelengthes {
            var l:Double = 0;
            //let step  = Individual.stepArray[indexOfGene]
            for i in currentGeneIndex + 0 ..< currentGeneIndex+lenth{
                l  = l * 2 + Double(self.gene_binary[i])
            }
            gene_decimal[indexOfGene] = Individual.minArray[indexOfGene] + l * Individual.stepArray[indexOfGene]
            indexOfGene += 1
            currentGeneIndex += lenth
        }
    }
    mutating func decimal2binary(){
        var currentGeneIndex = 0
        for i in 0..<gene_decimal.count {
            var setp:Int = Int((gene_decimal[i] - Individual.minArray[i])/Individual.stepArray[i])
            let length = Individual.genelengthes[i]
            for _ in currentGeneIndex..<currentGeneIndex + length{
                gene_binary.append(Int8(setp % 2))
                setp = setp/2
            }
            currentGeneIndex = currentGeneIndex + length
        }
    }
    mutating func caculateFitness(){
        self.fitness = Individual.fun(gene_decimal)
        if self.fitness.isNaN {
            self.fitness = 0
        }
    }
    func toString() -> String {
        var str = "param: "
        for g in gene_decimal {
            str += g.description
            str += " "
        }
        str += "\nfitness: "
        str += self.fitness.description
        
        return str
    }
    init() {
        while true{
            for i in 0..<Individual.minArray.count {
                let gen = Double(arc4random()) / 0xFFFFFFFF * (Individual.maxArray[i] - Individual.minArray[i] + 1) + Individual.minArray[i]
                self.gene_decimal.append(gen)
            }
            self.decimal2binary()
            self.binary2decimal()
            if (self.paramIsFit()){
                break
            }else{
                self.gene_decimal.removeAll()
                self.gene_binary.removeAll()
            }
        }
        self.caculateFitness()
    }
    func paramIsFit() -> Bool{
        guard self.gene_decimal.count > 0 else {
            return false
        }
        for (index,dec) in self.gene_decimal.enumerated() {
            if(dec < Individual.minArray[index] || dec > Individual.maxArray[index]){
                return false
            }
        }
        return true
    }
}
struct GAOption {
    var crossRate:Double = 0.02
    var mutateRate:Double = 0.001
    var cycleTime = 500
    var populationSize:Int = 50
    var selectType = 1 // 轮盘赌
    
}
class GeneAAlgorithm {
    var population:[Individual] = [];
    var option:GAOption!
    var fitness:Individual!
    
    func ga(fun:@escaping ([Double])->(Double),numberOfParam: Int,minArray:[Double] = [],maxArray:[Double] = [],stepArray:[Double] = [],option: GAOption = GAOption()) -> (Individual) {
        guard minArray.count == maxArray.count && minArray.count == stepArray.count else {
            
            fatalError("param error")
        }
        var minArray = minArray
        var maxArray = maxArray
        var stepArray = stepArray
        if(minArray.count == 0){
            
            for _ in 0..<numberOfParam{
                minArray.append(-10)
                maxArray.append(10)
                stepArray.append(0.01)
            }
            
        }
        Individual.minArray = minArray
        Individual.maxArray = maxArray
        Individual.stepArray = stepArray
        Individual.fun = fun
        self.option = option
        
        if numberOfParam >= 5 {
            self.option.populationSize = 200
        }
        initPopulation(populationSize: self.option.populationSize)
        print(population.map({ (i) -> [Double] in
            return i.gene_decimal
        }))
        self.fitness = self.population.max()!
        for _ in 0..<option.cycleTime {
            across()
            mutation()
            select()
            let popuMax = self.population.max()!
            if(self.fitness.fitness < popuMax.fitness){
                self.fitness = popuMax
            }else{
                self.population[0] = self.fitness
            }
            print(self.fitness.toString() + "\n")
        }
        return self.fitness
    }
    /// 初始化种群
    ///
    /// - Parameter populationSize: 种群大小
    func initPopulation(populationSize: Int) {
        for _ in 0..<populationSize {
            self.population.append(Individual())
        }
    }
    
    /// 交叉操作
    ///
    /// - Parameters:
    ///   - population: 种群
    ///   - crossRate: 交叉概率
    func across() -> () {
        
        for i in stride(from: 0, to: population.count-1, by: 2) {
            
            let random = Double(arc4random()) / 0xFFFFFFFF
            if random == 0 || random == 1 || random > self.option.crossRate{
                continue
            }
            let p1p = Int(arc4random()) % population.count
            let p2p = Int(arc4random()) % population.count
            var p1 = population[p1p]
            var p2 = population[p2p]
            for j in stride(from: 0, to: Int(Float(arc4random()) / 0xFFFFFFFF * Float(population[i].gene_binary.count)), by: 1){
                let a = p1.gene_binary[j];
                p1.gene_binary[j] = p2.gene_binary[j]
                p2.gene_binary[j] = a
            }
            
            p1.binary2decimal()
            p2.binary2decimal()
            if p1.paramIsFit() && p2.paramIsFit(){
                p1.caculateFitness()
                p2.caculateFitness()
                population[p1p] = p1
                population[p2p] = p2
            }
           
        }
    }
    /// 变异操作
    ///
    /// - Parameters:
    ///   - population: 种群
    ///   - mutateRate: 变异率
    func mutation() -> () {
        for i in 0..<self.population.count {
            let random = Double(arc4random()) / 0xFFFFFFFF
            if random > self.option.mutateRate{
                continue
            }
//            print("发生变异操作")
            let postion = Int(Double(population[i].gene_binary.count) * getRandom())
            population[i].gene_binary[postion] = population[i].gene_binary[postion] == 1 ? 0 : 1
            population[i].binary2decimal()
            if population[i].paramIsFit(){
                population[i].caculateFitness()
            }else{
                population[i].gene_binary[postion] = population[i].gene_binary[postion] == 1 ? 0 : 1
            }
            
        }
    }
    func getRandom() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    func select() -> () {
        if self.option.selectType == 1 {
            var sum:Double = 0.0
            for ind in population{
//                let str = "sum: " + sum.description + "ind.fitness: " +  ind.fitness.description
                sum += ind.fitness
//                if(sum.isNaN){
//                    print(str)
//                }
            }
            let probability = population.map { (i) -> Double in
                i.fitness/sum
            }
            var qe = [Double]()
            for _ in 0..<population.count{
                qe.append(getRandom())
            }
            var newPopulation:[Individual] = []
            var cur = 0.0
            for q in qe{
                for (index,p) in probability.enumerated(){
                    cur += p
                    if cur >= q{
                        newPopulation.append(population[index])
                        cur = 0
                        break
                    }
                }
            }
            
            self.population = newPopulation
        }
    }

}

let ga  = GeneAAlgorithm()
let re = ga.ga(fun: { (x) -> (Double) in
    return 21.5 + x[0] * sin(4 * pi * x[0]) + x[1] * sin(20 * pi * x[1])
}, numberOfParam: 2, minArray: [-0.3,4.1], maxArray: [12.1,5.8],stepArray: [0.01,0.01])
//let re = ga.ga(fun: { (d) -> (Double) in
//    return -d[0] * d[0] + 20
//}, numberOfParam: 1)
print(re.toString())

