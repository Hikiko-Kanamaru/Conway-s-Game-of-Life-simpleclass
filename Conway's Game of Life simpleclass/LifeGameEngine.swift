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
    ///ライフゲームの基礎マップ　２重配列の真理値　ライフゲームの基礎データ[X軸[Y軸]] 変更した場合　自動でlifeMapLiveYearが修正されます
    var lifeData:[[Bool]]  = [[Bool]] () {
        didSet{
            //マップのサイズが変更された場合。生存年数と過密度をリセットする
            guard lifeData.count == oldValue.count && lifeData[0].count == oldValue[0].count else {
                lifeMapLiveYear = Array(repeating: Array(repeating: 0, count: lifeData[0].count), count: lifeData.count)
                lifeKamitudo = Array(repeating:{Array(repeating: 0, count: lifeData[0].count + 2)}(), count: lifeData.count + 2)
                return
            }
            //生存年数の計算
            
            for x in 0..<lifeData.count{
                for y in 0..<lifeData[0].count{
                    if lifeData[x][y] == true{
                        if oldValue[x][y] == true {
                            lifeMapLiveYear[x][y] += 1
                        }
                        
                    }else {
                        lifeMapLiveYear[x][y] = 0
                    }
                }
            }
            
        }
    }
    ///ライフセルの生存年数
    var lifeMapLiveYear = [[Int]]()
    ///ライフセルの過密度
    var lifeKamitudo = [[Int]]()
    ///端の処理 反対側と接続するかどうか tureで端を反対側と接続する X横方向の接続　Y縦方向の接続
    var mapEdge:(x:Bool,y:Bool)  = (true,true)
    ///強調表示基準　設定された値を超えたら強調する いわゆるマジックナンバーだが、外部からいじることもないだろうしこのままで行く。
    var coreLevel:(Int,Int) = (5,7)
    
    
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
    /**
     セルのxy軸(x:Int,y:Int) 計算型　get節のみ
    同じデータが複数の場所に保存されると危険なので、計算型にして値を保持しないようにしている。
     */
    var cellXY:(x:Int,y:Int){
        return (x:lifeData.count,y:lifeData[0].count)
    }
    //なぜ危険なのか、それは値を変えれば内部が変わると思って変更された際に、同じことを示すデータが二つあると衝突を起こすからである。
    //どっちらに従うべきか分からず問題になるので、同じデータなら、保存場所は一カ所に統一したい。
    
    //mapCreateを基本にして、必要な情報を増やしている
    /**
     LifeGameを構成します。内部が見たい場合は、LifeData[[Bool]]を呼び出して確認して下さい。
     
     - parameter Size : LifeGameMapのサイズ　上限は10,000です
     - parameter seisei : セルの生死指定　CellMakerを選択して下さい。
     - parameter Edge : 端の処理の仕方。trueの場合、反対側と接続されます。　x横方向　y縦方向
     */
    init(Size size:(x:Int,y:Int),seisei s:CellMaker  = .raddom, Edge edge:(x:Bool,y:Bool)) {
        var xSize = size.x
        var ySize = size.y
        if xSize > 10000 || xSize < 0 {
            xSize = 10000
        }
        if ySize > 10000 || ySize < 0 {
            ySize = 10000
        }
        //lifeDataを作る
        let initLifeData = LifeGameEngine.mapCreate(Xjiku: xSize, Yjiku: ySize, seisei: s)
        lifeData = initLifeData
        //生存年数の初期化
        lifeMapLiveYear = (Array(repeating:{Array(repeating: 0, count: ySize)}(), count: xSize ))
        //過密度の初期化
            lifeKamitudo = (Array(repeating:{Array(repeating: 0, count: ySize + 2)}(), count: xSize + 2))
        //端の処理の初期化
        mapEdge = edge
    }

    //外部から呼び出したい場合があるので、公開するためにclass関数化する
    /// マップを生成してくれる 引数　X軸,Y軸,値生成方法(デフォルはランダム)省略可
    class func mapCreate(Xjiku x:Int,Yjiku y:Int,seisei s:CellMaker = .raddom ) -> [[Bool]] {
        var map = [[Bool]]()
        //seiseiはクロージャではなく列挙型をを受け取っているので、クロージャーを呼び出し格納する
        let boolmaker = s.maker()
        for _ in 0..<x {
            var yjiku = [Bool]()
            for _ in 0..<y {
                //値生成部分
                yjiku.append(boolmaker(true))
            }
            map.append(yjiku)
        }
        return map
    }
    
}

    
    
    


//列挙型 セルの処理の仕方を毎回書いていると面倒なので、外部から注入する方式にする
/**
 セルをどのような値にするかをcaseで選ぶ。
 maker()でcaseにあった、処理をおこなうクロージャを返値として得られる
 (Bool)->Bool の型で受け取れる
 stripesは、自動で生死が切り替わる仕様です。生死順番を調整したい場合は、stripesBoolを調整して下さい。
 live+numberは、生存セルの割合です。
 */
enum CellMaker{
    case dathe
    case live
    case reverse
    case raddom
    case stripes
    case live33
    case live20
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
        case .live33  :
            return {_ -> Bool in let ikiteriru = [true,false,false]
                return ikiteriru[Int.random(in: 0...2)]}
        case .live20 :
            return {_ -> Bool in
                return (Int.random(in: 1...5) == 5)
            }
        }
    }
}


extension LifeGameEngine {
    func nextLife() {
        let xCount = lifeData.count
        let yCount = lifeData[0].count
        lifeKamitudo = Array(repeating:{Array(repeating: 0, count: yCount + 2)}(), count: xCount + 2)
        var nextWorld  = LifeGameEngine.mapCreate(Xjiku: xCount, Yjiku: yCount, seisei: .dathe)
    
        //引数worldを読み込み過密状況を調査する
        for x in 0..<xCount {
            for y in 0..<yCount{
                //マスに生命が存在したら、周辺の過密度を上昇させる
                if lifeData[x][y] == true{
                    //過密度を書き込むループ 9方向に加算する
                    for i in 0...2 {
                        for t in 0...2{
                            lifeKamitudo[x+i][y+t] += 1
                        }
                    }
                    //自分は隣接する個数に含まれないので、１減らす
                    lifeKamitudo[x+1][y+1] -= 1
                }
            }
        }
        
        //新設された端の解決。
        //何度も呼び出すと重いので一時変数(Temp)に受ける
        let kamituXTemp = lifeKamitudo.count - 1
        let kamituYTemp = lifeKamitudo[1].count - 1
        if mapEdge.x == true {
            for y in 1..<kamituYTemp  {
                //端の過密度を反対側に加算する
                lifeKamitudo[1][y] += lifeKamitudo[kamituXTemp][y]
                lifeKamitudo[kamituXTemp - 1][y] += lifeKamitudo[0][y]
                
            }
        }
        if mapEdge.y == true {
            for x in 1..<kamituXTemp {
                lifeKamitudo[x][1] += lifeKamitudo[x][kamituYTemp]
                lifeKamitudo[x][kamituYTemp - 1] += lifeKamitudo[x][0]
            }
        }
        //角の斜め方向の処理
        if mapEdge == (true,true){
            //左上
            lifeKamitudo[1][1] += lifeKamitudo[kamituXTemp][kamituYTemp]
            //左下
            lifeKamitudo[1][kamituYTemp - 1 ] += lifeKamitudo[kamituXTemp][0]
            //右上
            lifeKamitudo[kamituXTemp - 1 ][1] += lifeKamitudo[0][kamituYTemp]
            //右下
            lifeKamitudo[kamituXTemp - 1 ][kamituYTemp - 1] += lifeKamitudo[0][0]
        }
        
        
        // lifeKamitudo(過密度)に基づき生存判定をしていく
        for x in 1...xCount{
            for y in 1...yCount {
                switch lifeKamitudo[x][y] {
                //３なら誕生
                case 3 :
                    nextWorld[x-1][y-1] = true
                //２なら、マスに生命がいれば生存させる
                case 2 :
                    if lifeData [x-1][y-1] == true {
                        nextWorld[x-1][y-1] = true
                    }
                //それ以外は、基礎値でfalseのまま
                default:
                    //xcodeのエラー抑止　*defaultに何も設定しないとエラーが出ます。
                    {}()
                }
            }
        }
        lifeData = nextWorld
    }
}


extension LifeGameEngine {
    /**
     ブロック状に表示します。コマンドラインではゲーム画面を表示するのに利用しますが、UIVIewでは、デバック用として使って下さい。
     */
    func lifeView(){
            print("現在の世界を表示します")
        //今回は生存は、黒、絶滅は白の記号で表示していく　非常に長く続いているところは、黄色くする。さらに続いたところは赤くする
        let life = ["⬛️","🟨","🟥"]
        let death = "⬜️"
        //生存者集を計算数変数
        var ikinokori = 0
        print("|", separator: "", terminator: "")
        for y in 0..<lifeData[0].count{
            //列番号の表示 きれいに表示されるのは,10*10くらいまで
            print("\(y%10)|", separator: "", terminator: "")
        }
        print("")
        //ループを回して、マップを読み込む
        for y in 0..<lifeData[0].count {
            for x in 0..<lifeData.count{
                //値を把握して、どちらを表示するか決める
                if lifeData[x][y] == true {
                    ikinokori += 1
                    var t = 0
                    switch lifeMapLiveYear[x][y] {
                    case coreLevel.1... :
                        t = 2
                    case coreLevel.0..<coreLevel.1:
                        t = 1
                    default:
                        t = 0
                    }
                    print(life[t], separator: "", terminator: "")
                }else{
                    print(death, separator: "", terminator: "")
                }
            }
            //改行コード　端まできたら改行する
            //行番号の表示
            print(":\(y)", separator: "", terminator: "\n")
        }
        print("現在生き残りは、\(ikinokori)です。約\(ikinokori*100/(lifeData.count * lifeData[0].count))%です。")
    }
}
