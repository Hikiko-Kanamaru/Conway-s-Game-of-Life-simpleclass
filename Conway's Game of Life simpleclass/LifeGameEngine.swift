//
//  LifeGameEngine.swift
//  Conway's Game of Life simpleclass
//
//  Created by リノ on 2019/12/28.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

class LifeGameEngine {
    //格納型プロパティ
    ///ライフゲームの基礎マップ　２重配列の真理値　ライフゲームの基礎データ[X軸[Y軸]]
    var lifeData:[[Bool]]
    ///ライフセルの生存年数
    var lifeMapLiveYear:[[Int]]
    ///ライフセルの過密度
    var lifeKamitudo:[[Int]]
    ///端の処理 反対側と接続するかどうか
    var Edge:(x:Bool,y:Bool)  = (true,true)

    //計算型プロパティ
    ///生きているセル数　計算型　get節のみ
    var lifeCell:Int{
            var kotae = 0
            lifeData.forEach { (y:[Bool]) in
                y.forEach { (c:Bool) in
                    if c == true {
                        kotae += 1
                    }
                }
            }
        return kotae
    }
    ///総合セル数　計算型　get節のみ
    var cellCount:Int{
        return lifeData.count * lifeData[0].count
    }
    ///セルのxy軸(x:Int,y:Int) 計算型　get節のみ
    var cellXY:(x:Int,y:Int){
        return (x:lifeData.count,y:lifeData[0].count)
    }
    
        
    init(Size size:(x:Int,y:Int),FirstSet F:[(Int,Int)->(Bool)], Edge edge:(x:Bool,y:Bool)) {
        <#statements#>
    }
}

//求められている機能 true false　ランダム　反転　ストライプ縦横 ストライプを無視するれば、全てBool受け取りで行ける。
//反転させるには,相手のセルの値が必要　ストライプには、添字が必要。なしの適当なのにする。
//列挙型 セルの処理の仕方を毎回書いていると面倒なので、外部から注入する方式にする
enum CellMaker{
    case dathe
    case live
    case reverse
    case raddom
    case stripes
}
