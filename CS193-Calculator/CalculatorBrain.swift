//
//  CalculatorBrain.swift
//  CS193-Calculator
//
//  Created by Zhiheng Yi on 2015-05-27.
//  Copyright (c) 2015 Zhiheng Yi. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    private var opStack = [Op]()    //数组的定义方法
    private var knownOps = [String: Op]()   //字典的定义方法
    
    init () {
        //每次 var try = CalculatorBrain() 都会调用这个函数
        //闭包的写法，两个参数可以用$0, $1...代替
        
        knownOps["×"] = Op.BinaryOperation("×", { $0 * $1 })
        knownOps["÷"] = Op.BinaryOperation("÷", { $1 / $0 })
        knownOps["+"] = Op.BinaryOperation("+", { $1 + $0 })
        knownOps["-"] = Op.BinaryOperation("-", { $1 - $0 })
        knownOps["√"] = Op.UnaryOperation("√", { sqrt($0) })
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) { //返回值是一个tuple,tuple写法,函数的参数都是read-only的
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)  //operandEvaluation是个tuple类型,这是个递归用法,调用自己
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            default: break  //这句可加可不加,当你handle所有的问题时,不需要用这个break
            }
        }
        return (nil, ops)
    }
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol] {
            //opetation 的类型是 optional Op
            opStack.append(operation)
        }
        return evaluate()
    }
    
}
