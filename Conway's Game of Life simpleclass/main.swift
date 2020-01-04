//
//  main.swift
//  Conway's Game of Life simpleclass
//
//  Created by リノ on 2019/12/28.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

print("Hello, World!")

var gameOne = LifeGameEngine(Size: (x: 15, y: 15), seisei: CellMaker.live33, Edge: (x: true, y: true))
gameOne.lifeView()
//print(gameOne.lifeData)
//print(gameOne.lifeMapLiveYear)
//lifeView(world: gameOne.lifeData)
//print(gameOne.lifeMapLiveYear)
//gameOne.lifeData = lifeData
//gameOne.lifeData = lifeData
//print(gameOne.lifeMapLiveYear)
//
//lifeView(world: gameOne.lifeData)
////gameOne.nextLife()
////print(gameOne.lifeKamitudo)

for _ in 0..<10{
gameOne.nextLife()
//lifeView(world: gameOne.lifeData)
    gameOne.lifeView()
}

for i in 0..<gameOne.cellXY.x{
    gameOne.kamiNoTe(point: (i,0), sayou: .live)
}
gameOne.lifeView()

for _ in 0..<10 {
    gameOne.nextLife()
    gameOne.lifeView()
}
var ukeru = LifeGameEngine(Size: (x:3, y: 3), seisei: CellMaker.live, Edge: (x: true, y: true))

ukeru.lifeView()
print(ukeru.lifeData)


for i in 0...3{
    ukeru.lifeData = StampArrey.glider.stamp(Houkou: Houkou(rawValue: i)!)
    ukeru.lifeView()
}

let uke = StampArrey.stamp(.hatinosu)
ukeru.lifeData = uke(.Right)
ukeru.lifeView()

gameOne.lifeView()
gameOne.lifeData = LifeGameEngine.mapKaiten(map: gameOne.lifeData, houkou: .Left)
gameOne.lifeView()

