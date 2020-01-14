# Conway-s-Game-of-Life-simpleclass
以前作った。SimpleLifeGameのclass化を行っています。  
前回のライフゲームを、クラスとして実装します。
記事は[ここから](https://qiita.com/hikiko/items/e1f31acfb3a293525db6)

今回は、クラス化します。
追加機能として、以下の２つを追加します。

* 端をつなげる　
* 長く生き残っているCellを強調する

橋をつなげるのは下のような感じです。グライダーが上から下に抜けて行っています。

```glider.swift
|0|1|2|3|4|          |0|1|2|3|4|         |0|1|2|3|4|
⬜️⬛️⬛️⬛️⬜️:0        ⬜️⬛️⬛️⬜️⬜️:0       ⬜️⬛️⬜️⬛️⬜️:1
⬜️⬛️⬜️⬜️⬜️:1        ⬜️⬛️⬜️⬛️⬜️:0       ⬜️⬛️⬜️⬜️⬜️:1
⬜️⬜️⬛️⬜️⬜️:2    →   ⬜️⬜️⬜️⬜️⬜️:0  →    ⬜️⬜️⬜️⬜️⬜️:1
⬜️⬜️⬜️⬜️⬜️:3        ⬜️⬜️⬜️⬜️⬜️:0       ⬜️⬜️⬜️⬜️⬜️:1
⬜️⬜️⬜️⬜️⬜️:4        ⬜️⬜️⬛️⬜️⬜️:0       ⬜️⬛️⬛️⬜️⬜️:1
    0年目                 1年目               2年目
```

強調は、同じ場所で長く生き残った場合に強調します。

* 5年以上生き残ったら🟨
* 7年以上生き残ったら🟥

```kyoutyou.swift
現在の世界を表示します
|0|1|2|3|4|5|6|7|
⬜️⬜️⬛️⬜️⬜️⬜️⬜️⬜️:0
⬜️⬜️⬛️⬜️⬛️⬜️⬜️⬜️:1
⬛️⬜️⬛️🟥⬜️⬜️⬛️⬜️:2
⬜️⬜️⬜️⬜️⬜️⬛️⬛️⬛️:3
⬜️⬜️⬜️⬛️⬜️⬛️⬜️⬜️:4
⬜️⬛️⬛️🟨⬛️⬛️⬜️⬜️:5
⬜️⬛️⬜️🟨⬜️⬛️⬛️⬜️:6
⬜️⬛️⬜️⬜️⬜️⬛️⬜️⬛️:7
8年目 - 生き残りは、24です。約37%です。
```

それと次の記事の準備として変数や機能が足されています。
今後の予定として、フィールドを大きくしたり、スタンプ機能を実装する準備として変数を色々足します。


前回の記事は[ここから](https://qiita.com/hikiko/items/e1f31acfb3a293525db6)、
GitHubは[ここから](https://github.com/Hikiko-Kanamaru/Conway-s-Game-of-Life-simpleclass)です。

今回は、前回の記事のクラス化と言うことで、雑多な説明は、コード内に埋め込んでいます。
基本的な考え方やコードは前回の記事と変わりません。
この記事では、大まかな目的と説明していない構文を説明します。
説明するにあたって、ひとつのコードを見ながらやるのはわかりづらいので、
クラス宣言のみをして、その他のコード、関数や付属する列挙型は、拡張(extension)を使って
個別に説明していきます。

##LifeGameClass初期化

前回のlifeDataとmapCreateをまとめたものです。
**lifeGameのモデルを提供します。**

1. lifeData :[[Bool]]型のライフゲームのデータを入れておく場所です。Classのプロパティになります。
2. macCreate : ライフゲームマップを製造します。外部からのアクセスを認めます。列挙型で動作を受け取らせます。
3. CellMaker : セル製造するクロージャー(無名関数)を返します。外部呼び出しに耐えるために、Class外に置きます。

前回と大きな違いは、cell生成が列挙型に変更されました。
列挙型`CellMaker`が宣言されています。

>**クラスについて**
単純に言うと設計図です。今回は、lifeGameの実物(実体:インスタンス)を作るための設計図です
実物(実体)に、製造(生成)して利用します。
プログラム上では、``let 実体 = 設計図（仮引数)``と記します。
今回だと、　let lifeGame実体 = lifeGameクラス(仮引数)となります。
クラス内部には、関数やプロパティ(定数や変数)を作ることができます。
関数やプロパティの呼び出しは、.(ドット)関数名で行います。
``実体.関数名``　で内部の関数を呼び出して使います。
今回の場合、lifeGame実体.lifeView になります。
その他、継承・カプセル化・多様性、等々ありますが、詳しい説明は省きます。
ここの記事では、``lfieGameの設計図を作る``ことが目標です。

クラス化にあたって、変数が複数宣言されています。ゲームデータの保存は、クラス内変数の``lifeData``に格納されました。
変数の格納は、拡張``extension``で追加することが難しいので、クラス宣言の中に書く必要性があります。
拡張については後で説明します。
swiftの初期化(init)においては、``全て``の変数に、値を与える必要があります。
安全のために、できる限り初期値が与えてあります。


>**列挙型について**
複数の定数を一つにまとめたものです。複数の定数から、``一つの定数(case)``を選んで使用します。
宣言は、
``enum 列挙型名{case 　列挙ケース1 case  列挙ケース2 }``
となります。
今回は　enum CellMaker{　case dathe　case live メンバ関数 }
の形で利用されています。
swiftの列挙型は、非常に機能が多く、整数の集合だけではなく、実数、真理値、文字列の実態をとることができます。
実態を持たない、共用型も作ることが可能です。内部に関数とプロパティを持つことができます。
そのため、クラスのように振る舞えわせることが可能です。
列挙型は、定数の集合です。定められた定数によって機能を変えることもできます。

今回の場合、入力を簡便化するのと、機能追加の際に、複数の箇所を変更しなくて済むように、列挙型を利用しています。
実例としては、セルの生成方法に利用されいます。なぜ利用するかと言うと、

* セル生成は、様々な箇所で利用するので、外部化する利益が大きい
* 整備性が良い。具体的には、セルの生成を調整したいとき、列挙ケースを追加するだけで済むからです。


```init.swift
/**
 ライフゲームのモデルを提供します
 内部データはlifeData:[[Bool]]です。
 */
class LifeGameEngine {
    //格納型プロパティ
    ///ライフゲームの基礎マップ　２重配列の真理値　ライフゲームの基礎データ[X軸[Y軸]] 変更した場合　自動でlifeMapLiveYearが修正されます
    var lifeData:[[Bool]]  = [[Bool]] () {
        didSet{
            //年数経過をとめる
            guard usedLifeMapLiveYear else {
                usedLifeMapLiveYear = true
                return
            }            //マップのサイズが変更された場合。生存年数と過密度をリセットする
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
    init(Size size:(x:Int,y:Int),seisei s:CellMaker  = .raddom, Edge edge:(x:Bool,y:Bool) = (true,true)) {
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
```
実行コードは、配列の表示と、変数へのアクセスを行ってみます。まだ導入コードが少ないので簡素になります。
クラス実体(インスタンス)は、定数(Let)にするのが基本です。内部の変数は、変更可能のなので、特に困ることはありません。
swiftにおいて、クラスは``参照渡し``にです。もし引き渡しが必要であれば、その都度定数に移して利用して下さい。

```initRun.swift
print("Qiita2年目の実行コード")
let gameStart = LifeGameEngine(Size: (x:3, y: 3), seisei: CellMaker.raddom, Edge: (x: true, y: true))
print("lifeDataの内容を表示します\(gameStart.lifeData)")
print("現在の生存セル数は、\(gameStart.lifeCellCount)セルです。")
print("マップの大きは、\(gameStart.cellXY)")
```

実行結果
>Qiita2年目の実行コード
lifeDataの内容を表示します[[true, true, true], [true, true, true], [false, false, true]]
現在の生存セル数は、7セルです。
マップの大きは、(x: 3, y: 3)

これでクラス実体が製造可能になりました。
ここを基準として、機能を追加していきます。

##LifeView 画面表示+生存年数強調
lifeViewを搭載していきます。
**LifeGameのセルマップを表示します**
具体的機能は、2つあります。
1. lifeDataをゲーム画面を表示する
2. セルの生存年数(lifeMapLiveYear)に基づいて強調表示する


**拡張について**
今回、メソッド``lifeViewを追加する``にあたって、拡張(extension)を利用します。
拡張とは、既存のクラスや列挙型などに、機能(メソッドやプロパティ)を追加する方法です。利用法は、下記の通りです。

> extension 既存のクラス名 { 追加メソッド　追加計算型プロパティ}

今回の場合 ``extension LifeGameEngine {lifeView{プログラム}}``となります。
拡張は、どこにでも書くことができます。システムが提供する既存のクラス(Intやprint)などにも機能追加することができます。
必要な機能を一時的(そのコードの中でだけ)に、追加するような運用も可能です。


セルの強調表示は、5年以上続いたら🟨、7年以上で🟥とします。
プログラムでは、変数coreLevelと比較して強調します。格納型のインスタンスプロパティは、swiftの拡張(extension)では追加できないので、class宣言に追加してあります。

>    ///強調表示基準　設定された値を超えたら強調する いわゆるマジックナンバーだが、外部からいじることもないだろうしこのままで行く。
    var coreLevel:(Int,Int) = (5,7)




```lifeView.swift
extension LifeGameEngine {
    /**
     ブロック状に表示します。コマンドラインではゲーム画面を表示するのに利用しますが、UIVIewでは、デバック用として使って下さい。
     */
    func lifeView(){
            print("現在の世界を表示します")
        //今回は生存は、黒、絶滅は白の記号で表示していく　非常に長く続いているところは、黄色くする。さらに続いたところは赤くする
        let life = ["⬛️","🟨","🟥"]
        let death = "⬜️"
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
        //生存者数を受け取る
        let ikinokori = lifeCellCount
        print("\(yearCount)年目 - 生き残りは、\(ikinokori)です。約\(ikinokori*100/(cellXY.x * cellXY.y))%です。")    }
}
```
実行していきます。ゲーム画面の表示としては、同じ画面を更新する形で行いたいのは山々ですが、今回は、毎回別の表示になる形式で行きます。
実行コードと実行結果が同時に書かれています。
それと、強調表示の動作を確認するために、年数を経過(nextLife(_:))させています。

```lifeViewRun.Swift
print("lifeViewを実行しています")
gameStart.lifeView()
gameStart.nextLife(count:10)
gameStart.lifeView()

///実行結果///
lifeViewを実行しています
現在の世界を表示します
|0|1|2|3|4|
⬜️⬜️⬜️⬛️⬜️:0
⬜️⬛️⬜️⬜️⬜️:1
⬛️⬜️⬜️⬜️⬜️:2
⬛️⬛️⬜️⬛️⬜️:3
⬛️⬛️⬛️⬜️⬜️:4
0年目 - 生き残りは、9です。約36%です。
現在の世界を表示します
|0|1|2|3|4|
⬜️⬜️⬜️⬜️⬜️:0
🟥⬜️⬜️⬜️🟥:1
⬜️🟨⬜️🟨⬜️:2
🟥⬜️⬜️⬜️🟥:3
⬜️⬜️⬜️⬜️⬜️:4
10年目 - 生き残りは、6です。約24%です。
```

##nextLife 年次経過
nextLifeを実装します。行っていることは前回のnextLifeとほぼ同様です。
**マップの年数を経過させます。**

大まかな作業手順及び、追加コード
1. 過密度をマップ(lifeKamitudo)に起こします
2. マップ端の過密度を、接続性(mapEdge)に基づき、接続側に加算します
3. 過密度に基づき、生き残るセルを決定します。
4. マップの経過年数とセル毎生存年数(lifeCellLiveYear)を加算する。
・ 複数回実行したいときのために、回数(count)を要求して複数回実行するコードも用意する。

lifeDataが内部化されているので、返値がなくなっています。直接インスタンスプロパティにアクセスできるので不要になりました。
map端の処理は、過密度を対象方向に加算する実装になっています。
ここでは、生存年数(lifeCellLiveYear)は、登場しません。すでにclass宣言の際に自動計算化されています。
生存年数は,lifeDataが更新された際に自動で計算されるようになっています。値変更の自動計算は``willSet``と``didSet``で行えます。
>**プロパティオブザーバー　willSetとdidSet**
willSet
値が変更する前に呼び出される。newValueで更新後の値が呼び出せる
didSet 
値が変更された後に呼び出される。oldValueで更新前の値が呼び出せる。 

プロパティオブザーバーを利用すると、特定の変数と連動して他の値を変えることができます。
今回で言えば、lifeDataが更新されるとlifeCellLiveYearが変更されるようになっています。
注意点として、初期化の際の値変更には適応されません。初期化の際は、直接値を与えるか、初期値を設定して置いて下さい。

nextLife(count:Int)について
nextLifeをcountの回数実行するコードです。nextLifeと名前が同じことに注目して下さい。
同じ名前で、引数ラベルや引数、返値が違うものを実装することを、``オーバーロード(overload)``と言います。
同じ名称で実装することで、使いやすく理解しやすくするための機能です。機能が違ったり、引数や返値の型が違う定義が可能です。
ただし、返値の型については、出来れば変更せずに利用して下さい。トラブルが多いです。

```nextLife.swift
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
                    //xcodeのエラー抑止　*defaultに何も設定しないと警告が出ます。
                    {}()
                }
            }
        }
        lifeData = nextWorld
        //年数を一年進める。
        yearCount += 1
    }
    
    ///nextLifeを複数回実行する 最大1000まで nextLifeをオーバーロード　中身は規定数nextLifeを呼んでいるだけ
    func nextLife(count c :Int = 1)  {
        var cTemp = c
        if c > 1000 || c <= 0 {
            cTemp = 1000
        }
        for _ in 1...cTemp{
            nextLife()
        }
    }
    
}

```

実行していきます。実行結果も同時に表示しています。
nextLife(Count:_)は、実行結果が長くなるので、結果を省略しています。

```nextLifeRun.swift
print("nextLifeを実行しています")
gameStart.lifeView()
//通常のnextLifeの呼び出し
gameStart.nextLife()
gameStart.lifeView()
//nextLifeをオーバーロードして、countを呼び出している
gameStart.nextLife(count: 5)
gameStart.lifeView()

///実行結果///
nextLifeを実行しています
現在の世界を表示します
|0|1|2|3|4|
⬛️⬛️⬛️⬛️⬜️:0
⬛️⬜️⬜️⬛️⬛️:1
⬜️⬛️⬛️⬜️⬛️:2
⬛️⬜️⬜️⬜️⬜️:3
⬛️⬛️⬜️⬛️⬜️:4
0年目 - 生き残りは、14です。約56%です。
現在の世界を表示します
|0|1|2|3|4|
⬜️⬜️⬜️⬜️⬜️:0
⬜️⬜️⬜️⬜️⬜️:1
⬜️⬛️⬛️⬜️⬜️:2
⬜️⬜️⬜️⬛️⬜️:3
⬜️⬜️⬜️⬛️⬜️:4
1年目 - 生き残りは、4です。約16%です。
```

##kamiNoTe マップを操作する
セルを直接操作します。前記事とほぼ変わっていません。
**指定されたセルに、与えられた作用を実行します。**

作用は、CellMakerを受け取るように改良します。
セル生存年数(lifeMapLiveYear)が、セル変更の際に自動計算されてしまうので、自動計算を止めるフラグを立てます。フラグは、class.swiftで下記のように宣言しました。
> var usedLifeMapLiveYear = true

フラグの使用に際して、一度立てるとそのままのタイプのフラグだと、折り忘れがあるので、今回は一度判定されると、自動で折られるようになっています。
>//年数経過をとめる
guard usedLifeMapLiveYear else {
   usedLifeMapLiveYear = true
   return
}

**guard文**について
guard文は、条件が真で無い場合、else内部が実行され、そのコードが終了されるコードです。returnかbreakがプログラム内に必須です。下記のように使います
>guard 条件式　else { プログラム　returnまたはbreak }

コードの安全を確保するために使用する文法です。条件部分は、プロパティの代入(let 定数名 =　実引数)(代入できなかったら偽)、パターンマッチ(範囲内に含まれるかどうか)など、様々な条件を設定する事が出来ます。elseプログラム内部には、構文から抜けるコード(return または break)が``必須``です。使い方は、引数が正しいかどうかの判定に用いることが多いです。今回の場合は、フラグによって実行すかどうかを判定しています。

```kamiNote.swift
extension LifeGameEngine {
    ///特定のマスを指示してデータを操作する関数 worldは現在の状態、pointは編集する場所(X軸,Y軸)、sayouは、セルに行う操作　デフォルトは、反転
    func kamiNoTe(point p :(Int,Int),sayou s:CellMaker = .reverse ) {
        let sTemp = s.maker()
        //生存年数が計算されないように止める。
        usedLifeMapLiveYear = false
        lifeData[p.0][p.1] = sTemp(lifeData[p.0][p.1])
    }
}
```

実行していきます。マップの
0行目を生存に
1行目を反転
2行目を死亡
3行目をストライプに変えます。

```kamiNoTerun.swift
print("神の手を実行します。")
gameStart.lifeView()
for i in 0..<gameStart.cellXY.x{
    gameStart.kamiNoTe(point: (i,0), sayou: CellMaker.live)
    gameStart.kamiNoTe(point: (i,1), sayou: .reverse)
    gameStart.kamiNoTe(point: (i,2), sayou: .dathe)
    gameStart.kamiNoTe(point: (i,3), sayou: .stripes)
}
gameStart.lifeView()

///実行結果///
神の手を実行します。
現在の世界を表示します
|0|1|2|3|4|
⬜️⬛️⬜️⬛️⬜️:0
⬜️⬜️⬛️⬛️⬛️:1
⬜️⬛️⬛️⬜️⬛️:2
⬜️⬜️⬜️⬛️⬜️:3
⬜️⬜️⬛️⬜️⬜️:4
0年目 - 生き残りは、10です。約40%です。
現在の世界を表示します
|0|1|2|3|4|
⬛️⬛️⬛️⬛️⬛️:0
⬛️⬛️⬜️⬜️⬜️:1
⬜️⬜️⬜️⬜️⬜️:2
⬛️⬜️⬛️⬜️⬛️:3
⬜️⬜️⬛️⬜️⬜️:4
0年目 - 生き残りは、11です。約44%です。
``` 

##gameMode コンソールで遊ぶ
**lifeGameをコンソールで操作し遊べるようにします。**
呼び出し方が変わった程度で、前回と変わらないので畳んでおきます。


<details><summary>gameMode.swift</summary><div>

```gameMode.swift
extension LifeGameEngine{
    /**コマンドラインで遊ぶゲームモードを起動します
     ゲームモードと言う以上個別起動できたほうがいいので、class関数かします
 */
    class func gameMode(){
        print("/////////ゲームモードを開始します/////////")
        ///世界の大きさ
        var ookisa:Int = 0
        ///ゲームモードのインスタンス
        let gameData:LifeGameEngine
        ///端の接続性
        var haji = (true,true)
        repeat {
            print("数字を入力してください1~50まで")
            //readLineで入力を受け付ける
            let readOokisa = readLine() ?? "0"
            ookisa = Int(readOokisa) ?? 0
        }while ookisa == 0 || ookisa > 50
        
        var readLineTemp = ""
        repeat{
        print("X端の接続性を選択して下さい。trueまたは,false")
            readLineTemp = readLine() ?? ""
        }while !(readLineTemp == "false" || readLineTemp == "true")
        haji.0 = Bool(readLineTemp)!
        repeat{
        print("Y端の接続性を選択して下さい。trueまたは,false")
            readLineTemp = readLine() ?? ""
        }while !(readLineTemp == "false" || readLineTemp == "true")
        haji.1 = Bool(readLineTemp)!
        
        print("サイズ\(ookisa),端接続\(haji)受け取りました。マップを製造します")
        gameData = LifeGameEngine(Size: (x: ookisa, y: ookisa), seisei: CellMaker.live33, Edge: haji)
        gameData.lifeView()
        //操作するループ　next change changeAll view exti
        //文字入力用文字列
        var readString = ""
        repeat{
            print("操作を半角英数字で入力して下さい。\n next:次の時代に進みます \n change:対象のマスを変更します \n changeAll:すべてを変更します　\n view:現在の状態を表示します　即時実行されます　\n exit:終了します")
            readString = readLine() ?? ""
            //switch文で条件分岐
            switch readString {
            case "next":
                var readKaisuu = ""
                var nextkaisuu = 0
                repeat {
                    print("どれくらい進めますか？1回以上")
                    readKaisuu = readLine() ?? "0"
                    nextkaisuu = Int(readKaisuu) ?? 0
                }while nextkaisuu == 0
                for _ in 0..<nextkaisuu{
                    gameData.nextLife()
                }
            case "change":
                //x軸
                let xMax = gameData.cellXY.x
                //入力間違えてもエラーになるようにエラー値を入れている
                var xjiku:Int = xMax
                repeat {
                    print("x軸を入力して下さい。最大値は\(xMax - 1)です")
                    let readX = readLine() ?? ""
                    xjiku = Int(readX) ?? xjiku
                }while xjiku >= xMax || xjiku <= 0
                //y軸
                let yMax = gameData.cellXY.y
                //入力間違えてもエラーになるようにエラー値を入れているい
                var yjiku:Int = yMax
                repeat {
                    print("y軸を入力して下さい。最大値は\(yMax - 1)です")
                    let ready = readLine() ?? ""
                    yjiku = Int(ready) ?? yjiku
                }while yjiku >= yMax || yjiku <= 0
                //操作部
                print("x:\(xjiku) y:\(yjiku)を、反転させます")
                gameData.kamiNoTe(point: (xjiku,yjiku))
            case "changeAll":
                print("世界を再構成します")
                //新たにマップを作って上書きする。
                gameData.lifeData = mapCreate(Xjiku: ookisa, Yjiku: ookisa)
                gameData.lifeMapLiveYearReset()
            case "view":
                gameData.lifeView()
            case "exit":
                print("終了します")
            default:
                print("指示を理解できません")
            }
            //exitが入力されない限り繰り返す
        }while readString != "exit"

    }

}
```

</div></details>

実行の際には、main.swiftで、下記のように呼び出して下さい。
>LifeGameEngine.gameMode()

この呼び出しは、クラスメソッドの呼び方です。
``クラス名.クラスメソッド名``になっています。
クラスメソッドは、実体を生成せずに、呼び出すこととのできるメソッドで型に関する手続きや実態を用いずに、実行したいときに使います。メソッドだけではなく、プロパティも設定可能です。プロパティの場合、変更の影響が、同一クラスすべてに及ぶので、注意して下さい。

実行結果

```gameModeRun.swift
LifeGameEngine.gameMode()


///実行結果///

/////////ゲームモードを開始します/////////
マップの大きさをを、半角数字で入力してください1~50まで
5
X端の接続性を選択して下さい。trueまたは,false
true
Y端の接続性を選択して下さい。trueまたは,false
true
サイズ5,端接続(true, true)受け取りました。マップを製造します
現在の世界を表示します
操作を半角英数字で入力して下さい。
 next:次の時代に進みます 
 change:対象のマスを変更します 
 changeAll:すべてを変更します　
 view:現在の状態を表示します　即時実行されます　
 exit:終了します
view
現在の世界を表示します
|0|1|2|3|4|
⬛️⬜️⬜️⬜️⬜️:0
⬛️⬛️⬜️⬜️⬛️:1
⬛️⬛️⬜️⬛️⬜️:2
⬜️⬛️⬜️⬛️⬛️:3
⬜️⬜️⬛️⬜️⬛️:4
0年目 - 生き残りは、12です。約48%です。
view
現在の世界を表示します
|0|1|2|3|4|
⬛️⬛️⬜️⬛️⬜️:0
⬜️⬛️🟨⬜️⬜️:1
⬜️⬜️⬛️⬜️⬜️:2
⬜️⬜️⬜️⬜️⬜️:3
⬜️⬜️⬛️⬜️⬜️:4
10年目 - 生き残りは、7です。約28%です。
```

##終わりにクラス化
[前回](https://qiita.com/hikiko/items/e1f31acfb3a293525db6)導入されていた機能のクラス化が終了しました。クラス化することによって、main.swfitにプログラムをコピペするのではなく、ファイルを移せば使えるようになります。
[gitHub](https://github.com/Hikiko-Kanamaru/Conway-s-Game-of-Life-simpleclass)で落として、LifeGameEngine.swiftを移せば即時利用可能です。

クラス化は、オブジェクト指向の基本です。前回の記事と比較して読んで見て下さい。
main関数(起動時に読み込まれるプログラム)が、だいぶ簡略化されています。
<details><summary>今回のmain.swift</summary><div>


```main.swift
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
```

</div></details>

前回に比べて読みやすく、書きやすくバグが起きづらいと思います。
オブジェクト指向において、名前が重要だと言われます。呼び出していく過程が、読める文章になっていると使いやすいからです。もちろん名前が適当に付けられてしまうと解りづらくなります。それと、私の名前付けは、あまり良くないので、私にあまり影響を受けずに、解りやすい名前付けを目指して下さい。

それと次回から記事一つ一つを小さくする予定です。
