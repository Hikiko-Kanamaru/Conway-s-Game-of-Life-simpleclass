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
    var lifeData = [[Bool]] ()
    ///ライフセルの生存年数
    var lifeMapLiveYear = [[Int]]()
    ///ライフセルの過密度
    var lifeKamitudo = [[Int]]()
    ///端の処理 反対側と接続するかどうか
    var mapEdge:(x:Bool,y:Bool)  = (true,true)

    //計算型プロパティ
    ///生きているセル数　計算型　get節のみ
    var lifeCellCount:Int{
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
    var cellAllCount:Int{
        return lifeData.count * lifeData[0].count
    }
    ///セルのxy軸(x:Int,y:Int) 計算型　get節のみ
    /// 同じデータが複数の場所に保存されると危険なので、計算型にして値を保持しないようにしている。
    var cellXY:(x:Int,y:Int){
        return (x:lifeData.count,y:lifeData[0].count)
    }
    
    //mapCreateを基本にして、必要な情報を増やしている
    ///
    init(Size size:(x:Int,y:Int),seisei s:CellMaker  = .raddom, Edge edge:(x:Bool,y:Bool)) {
        //lifeDataを作る
        let maker = s.maker()
        for _ in 0..<size.x {
            //一度に列を入れるために一度変数に入れる。
            var yjiku = [Bool]()
            for _ in 0..<size.y{
                //値生成部分
                yjiku.append(maker(true))
                
            }
            lifeData.append(yjiku)
            //lifeMapLiveYearの初期化
            lifeMapLiveYear.append(Array.init(repeating: 0, count: size.y))
        }
        //過密度の初期化
            lifeKamitudo = (Array(repeating:{Array(repeating: 0, count: size.y + 2)}(), count: size.y + 2))
        //端の処理の初期化
        mapEdge = edge
    }
    
    
    
}


//列挙型 セルの処理の仕方を毎回書いていると面倒なので、外部から注入する方式にする
/**
 セルをどのような値にするかをcaseで選ぶ。
 maker()でcaseにあった、処理をおこなうクロージャを返値として得られる
 (Bool)->Bool の型で受け取れる
 stripesは、自動で生死が切り替わる仕様です。生死順番を調整したい場合は、stripesBoolを調整して下さい。
 */
enum CellMaker{
    case dathe
    case live
    case reverse
    case raddom
    case stripes
    static var stripesBool = false
    ///caseに合わせて処理用のクロージャを返します。
    func maker() -> (Bool)-> Bool {
        switch self {
        case .dathe:
            return {_ in false}
        case .live:
            return {_ in true}
        case .raddom:
            return {_ in Bool.random()}
        case .reverse :
            return {(t:Bool) -> Bool in return !t}
        case .stripes :
            return {_ in CellMaker.stripesBool = !CellMaker.stripesBool
                return CellMaker.stripesBool }
        }
    }
}
