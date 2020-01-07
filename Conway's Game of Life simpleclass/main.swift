//
//  main.swift
//  Conway's Game of Life simpleclass
//
//  Created by リノ on 2019/12/28.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

print("Hello, World!")

var gameOne = LifeGameEngine(Size: (x: 8, y: 8), seisei: CellMaker.raddom, Edge: (x: true, y: true))
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

//gameOne.lifeData = [[false, false, false, false, false], [true, true, false, false, false], [true, false, true, false, false], [true, false, false, false, false], [false, false, false, false, false]]

//[[true, true, false], [true, false, true], [true, false, false]]
//print(gameOne.lifeData)
gameOne.lifeView()
for _ in 0..<20{
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

print("回転機能を実行しています")

//let mimi = Houkou.allCases
//print(mimi)
for i in Houkou.allCases {
    ukeru.lifeData = StampArrey.glider.stamp(Houkou: i)
    ukeru.lifeView()
}



let uke = StampArrey.stamp(.hatinosu)
ukeru.lifeData = uke(.Right)
ukeru.lifeView()

gameOne.lifeView()
gameOne.lifeData = LifeGameEngine.mapKaiten(map: gameOne.lifeData, houkou: .Left)
gameOne.lifeView()

//LifeGameEngine.gameMode()

print("Qiita2年目の実行コード")
let gameStart = LifeGameEngine(Size: (x:3, y: 3), seisei: CellMaker.raddom, Edge: (x: true, y: true))
print("lifeDataの内容を表示します\(gameStart.lifeData)")
print("現在の生存セル数は、\(gameStart.lifeCellCount)セルです。")
print("マップの大きは、\(gameStart.cellXY)")


