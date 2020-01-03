//
//  LifeGameEngine.swift
//  Conway's Game of Life simpleclass
//
//  Created by リノ on 2019/12/28.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation
//　MARK:　- LifeGameEngineの基礎部分

/**
 ライフゲームのモデルを提供します
 内部データはlifeData:[[Bool]]です。
 */
class LifeGameEngine {
    //格納型プロパティ
    
    ///ライフゲームの基礎マップ　２重配列の真理値　ライフゲームの基礎データ[X軸[Y軸]] 変更した場合　自動でlifeMapLiveYearが修正されます
    var lifeData:[[Bool]]  = [[Bool]] () {
        didSet{
            guard usedLifeMapLiveYear else {
                usedLifeMapLiveYear = true
                return
            }
            //マップのサイズが変更された場合。生存年数と過密度をリセットする
            guard lifeData.count == oldValue.count && lifeData[0].count == oldValue[0].count else {
                //ライフデータが何も入っていないと動作停止するので、警告を出し,既定値で初期化する
                if lifeData.count != 0 {
                    lifeMapLiveYear = Array(repeating: Array(repeating: 0, count: lifeData[0].count), count: lifeData.count)
                    lifeKamitudo = Array(repeating:{Array(repeating: 0, count: lifeData[0].count + 2)}(), count: lifeData.count + 2)
                }else{
                    print("ライフデータが何も入っていません。エラーです。調査して下さい。")
                    lifeData = [[false]]
                    return
                }
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
    ///生存年数の経過停止 falseにすると一度だけ更新を行わない。ずっと止めていたければ、毎回falseを与えること。
    var usedLifeMapLiveYear = true
    
    ///ライフセルの過密度
    var lifeKamitudo = [[Int]]()
    ///端の処理 反対側と接続するかどうか tureで端を反対側と接続する X(横方向)の接続　Y(縦方向)の接続
    var mapEdge:(x:Bool,y:Bool)  = (true,true)
    ///強調表示基準　設定された値を超えたら強調する いわゆるマジックナンバーだが、外部からいじることもないだろうしこのままで行く。
    var coreLevel:(Int,Int) = (5,7)
    ///経過年月
    var yearCount = 0
    
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

    
    
    

// MARK: - CellMaker
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

// MARK: - stamp スタンプ配列
/**
 スタンプ配列を引き渡します。
メソッドstampで[[Bool]]を得られます
 */
enum StampArrey {
    //固定系
    case sikaku,hatinosu
    //振動系
    case blinker,beacon
    //移動系
    case glider

    /**
     特定の構造を持った。配列[[Bool]]を返します
     回転は、stampの回転方向です。
     
    - parameter Houkou : 回転方向
    - returns : [[Bool]]
 */
    func stamp(Houkou H:Houkou = .Up) -> [[Bool]] {
        //スタンプを受け取る
        var stampTemp = [[Bool]]()
        //stamp呼び出し
        switch self {
        case .sikaku:
            stampTemp = [[true, true], [true, true]]
        case .hatinosu:
            stampTemp = [[false, true, false], [true, false, true],[true, false, true], [false, true, false]]
        case .blinker:
            stampTemp = [[false, false, false],[true, true, true], [false, false, false]]
        case .beacon:
            stampTemp = [[true, true, false, false], [true, false, false, false], [false, false, false, true], [false, false, true, true]]
        case .glider:
            stampTemp = [[true, true, false], [true, false, true], [true, false, false]]
        }
        //回転機能
        //大きな数字が入力された際ようにあまりを出すようにすることで安全にする
//        let kaitenTemp = k % 4
//        switch kaitenTemp {
//        //上
//        case 0:
//            stampKotae = stampTemp
//        //左
//        case 3 :
//            //反転させておいてから、右と同じ処理をする　fallthrougで下のケースを強制実行できる
//            for i in 0..<stampTemp.count {
//                stampKotae.append(stampTemp[i].reversed())
//            }
//            stampTemp = stampKotae.reversed()
//            stampKotae = [[Bool]]()
//            fallthrough
//        //右
//        case 1 :
//            //回転させる　移動前nのセルを読み出す。移動後の位置に移す
//            for y in 0..<stampTemp[0].count {
//                //型が[[Bool]]と違うので一時的に変数を宣言する。
//                var itiji = [Bool]()
//                for x in 0..<stampTemp.count {
//                    itiji.append(stampTemp[x][stampTemp[0].count - y - 1])
//                }
//                stampKotae.append(itiji)
//            }
//        //下
//        case 2 :
//            //revaersedは、配列を反対にしたものを返してくれる
//            for i in 0..<stampTemp.count {
//                stampKotae.append(stampTemp[i].reversed())
//            }
//            stampKotae = stampKotae.reversed()
//        default:
//            stampKotae = stampTemp
//        }
        stampTemp = LifeGameEngine.mapKaiten(map: stampTemp, houkou: H)
        return stampTemp
    }
}


/**
 方向示す列挙型
 */
enum Houkou:Int {
    case Up = 0 ,Right,Down,Left
}



// MARK: - LifeGameEngineの拡張定義
// MARK:  nextLife系
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
        yearCount += 1
    }
}

//　MARK: - View表示
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
        print("\(yearCount)年目 - 生き残りは、\(ikinokori)です。約\(ikinokori*100/(lifeData.count * lifeData[0].count))%です。")
    }
}


// MARK: - マップを操作
extension LifeGameEngine {
    ///特定のマスを指示してデータを操作する関数 worldは現在の状態、pointは編集する場所(X軸,Y軸)、sayouは、セルに行う操作　デフォルトは、反転
    func kamiNoTe(point p :(Int,Int),sayou s:CellMaker = .reverse ) {
        let sTemp = s.maker()
        //生存年数が計算されないように止める。
        usedLifeMapLiveYear = false
        lifeData[p.0][p.1] = sTemp(lifeData[p.0][p.1])
    }
    //マップの回転
    /**
     マップを回転させます　<T>はジェネリクス。方向は回転させる方向　UPは回転させません
     - parameter map : 多重配列であればなんでも可
     - parameter houkou : Houkou型、回転させたい方向を入れてね
     - returns:[[T]]
     */
    class func mapKaiten<T>(map m : [[T]],houkou h:Houkou = .Right) -> [[T]] {
        var mapTemp  = m
        var mapKotae = [[T]]()
        switch h {
        //上
        case .Up:
            mapKotae = mapTemp
        //左
        case .Left :
            //反転させておいてから、右と同じ処理をする　fallthrougで下のケースを強制実行できる
            for i in 0..<mapTemp.count {
                mapKotae.append(mapTemp[i].reversed())
            }
            mapTemp = mapKotae.reversed()
            mapKotae = [[T]]()
            fallthrough
        //右
        case .Right :
            //回転させる　移動前nのセルを読み出す。移動後の位置に移す
            for y in 0..<mapTemp[0].count {
                //型が[[Bool]]と違うので一時的に変数を宣言する。
                var mapItiji = [T]()
                for x in 0..<mapTemp.count {
                    mapItiji.append(mapTemp[x][mapTemp[0].count - y - 1])
                }
                mapKotae.append(mapItiji)
            }
        //下
        case .Down :
            //revaersedは、配列を反対にしたものを返してくれる
            for i in 0..<mapTemp.count {
                mapKotae.append(mapTemp[i].reversed())
            }
            mapKotae = mapKotae.reversed()
        default:
            mapKotae = mapTemp
        }
        return mapKotae
    }
    //マップ拡大
    //マップ縮小
    //スタンプ
    
}




// MARK: - コマンドライン　機能調査のため
//extension LifeGameEngine{
//    ///コマンドラインで遊ぶゲームモードを起動します
//    func gameMode(){
//        print("ここから、ゲームモード")
//        //世界の大きさ
//        var ookisa:Int = 0
//        //ゲームモードのマップ
//        var gameMap:[[Bool]]
//
//        repeat {
//            print("数字を入力してください1~50まで")
//            //readLineで入力を受け付ける
//            let readOokisa = readLine() ?? "0"
//            ookisa = Int(readOokisa) ?? 0
//        }while ookisa == 0 || ookisa > 50
//
//        print("\(ookisa)を受け取りました。マップを製造します")
//        gameMap = mapCreate(Xjiku: ookisa, Yjiku: ookisa)
//        lifeView(world: gameMap)
//
//        //操作するループ　next change changeAll view exti
//        //文字入力用文字列
//        var readString = ""
//        repeat{
//            print("操作を英字で入力して下さい。\n next:次の時代に進みます \n change:対象のマスを変更します \n changeAll:すべてを変更します　\n view:現在の状態を表示します　即時実行されます　\n exit:終了します")
//            readString = readLine() ?? ""
//            //switch文で条件分岐
//            switch readString {
//            case "next":
//                var readKaisuu = ""
//                var nextkaisuu = 0
//                repeat {
//                    print("どれくらい進めますか？1回以上")
//                    readKaisuu = readLine() ?? "0"
//                    nextkaisuu = Int(readKaisuu) ?? 0
//                }while nextkaisuu == 0
//                for _ in 0..<nextkaisuu{
//                    gameMap = nextLife(world: gameMap)
//                }
//            case "change":
//                //x軸
//                let xMax = gameMap.count
//                var xjiku:Int = xMax
//                repeat {
//                    print("x軸を入力して下さい。最大値は\(xMax - 1)です")
//                    let readX = readLine() ?? ""
//                    xjiku = Int(readX) ?? xjiku
//                }while xjiku >= xMax
//                //y軸
//                let yMax = gameMap[0].count
//                var yjiku:Int = yMax
//                repeat {
//                    print("y軸を入力して下さい。最大値は\(yMax - 1)です")
//                    let ready = readLine() ?? ""
//                    yjiku = Int(ready) ?? yjiku
//                }while yjiku >= yMax
//                //操作部
//                print("x:\(xjiku) y:\(yjiku)を、反転させます")
//                kamiNoTe(world: &gameMap, point: (xjiku,yjiku))
//            case "changeAll":
//                print("世界を再構成します")
//                //新たにマップを作って上書きする。
//                gameMap = mapCreate(Xjiku: ookisa, Yjiku: ookisa)
//            case "view":
//                lifeView(world: gameMap)
//            case "exit":
//                print("終了します")
//            default:
//                print("指示を理解できません")
//            }
//            //exitが入力されない限り繰り返す
//        }while readString != "exit"
//
//    }
//
//}
