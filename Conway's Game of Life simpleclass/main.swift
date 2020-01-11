//
//  main.swift
//  Conway's Game of Life simpleclass
//
//  Created by リノ on 2019/12/28.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

print("Qiita2年目の実行コード")
let gameStart = LifeGameEngine(Size: (x:5, y: 5), seisei: CellMaker.live20, Edge: (x: true, y: true))
print("lifeDataの内容を表示します\(gameStart.lifeData)")
print("現在の生存セル数は、\(gameStart.lifeCellCount)セルです。")
print("マップの大きは、\(gameStart.cellXY)")

print("lifeViewを実行しています")
gameStart.lifeView()
gameStart.nextLife(count:10)
gameStart.lifeView()

gameStart.reset()
print("nextLifeを実行しています")
gameStart.lifeView()
//通常のnextLifeの呼び出し
gameStart.nextLife()
gameStart.lifeView()
//nextLifeをオーバーロードして、countを呼び出している
gameStart.nextLife(count: 5)
gameStart.lifeView()


gameStart.reset()

print("神の手を実行します。")
gameStart.lifeView()
for i in 0..<gameStart.cellXY.x{
    gameStart.kamiNoTe(point: (i,0), sayou: CellMaker.live)
    gameStart.kamiNoTe(point: (i,1), sayou: .reverse)
    gameStart.kamiNoTe(point: (i,2), sayou: .dathe)
    gameStart.kamiNoTe(point: (i,3), sayou: .stripes)
}
gameStart.lifeView()

//ゲームモードを実行しています。
LifeGameEngine.gameMode()
