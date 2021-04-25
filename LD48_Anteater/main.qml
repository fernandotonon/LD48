import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id:gameWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    property int antsEaten:0
    property bool canEat: true
    property var antComponent: Qt.createComponent("Ant.qml")
    property int mapCols: 30
    property var initialMap:   [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,2,2,0,2,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,1,0,0,2,2,0,2,2,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,2,1,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property var feromoneMap:[]
    property var centerPointsMap:[]
    Rectangle{
        anchors.fill: parent
        color: "green"
        Column{
            Text {
                color: "white"
                text: "Ants Eaten: "+antsEaten
            }
            Text {
                color: "white"
                text: "Able to eat: "+(canEat?"yes":"no")
            }
        }
    }

    function createAnt(){
        let obj=antComponent.createObject(this)
        obj.x=initialMap.indexOf(3)*width/mapCols+(width/mapCols)/2-obj.width/2
        obj.y=height/4
        obj.position=initialMap.indexOf(3)
    }
    function calculateCenterPoints(){
        for(let i =0;i< initialMap.length;i++){
            let x=i%mapCols*width/mapCols+(width/mapCols)/2
            let y=height/4+Math.floor(i/mapCols)*width/mapCols+(width/mapCols)/2

            centerPointsMap[i]=Qt.point(x,y);
            feromoneMap[i]=0
        }
    }

    function reconstructPath(node,cameFrom){
        let finalPath=[node.index]
        for(let i = cameFrom.length-1;i>0;--i){
            finalPath.unshift(cameFrom[i].index)
        }
        return finalPath
    }

    function distance(i1,i2){
        let x1=i1%mapCols
        let y1=Math.floor(i1/mapCols)
        let x2=i2%mapCols
        let y2=Math.floor(i2/mapCols)
        return Math.abs(x1-x2+y1-y2)
    }

    function getNeighborList(current,map,fMap){
        let list=[]

        let up=current.index-(current.index-mapCols>=0?mapCols:0)
        let down=current.index+(current.index+mapCols<initialMap.length?mapCols:0)
        let left=current.index-(current.index%mapCols===0?0:1)
        let right=current.index+((current.index+1)%mapCols===0?0:1)

        if(up!==current.index&&map[up]>0) list.push({"index":up,"g":current.g+1,"f":current.g+1-fMap[up]+distance(current.index,up)})
        if(down!==current.index&&map[down]>0) list.push({"index":down,"g":current.g+1,"f":current.g+1-fMap[down]+distance(current.index,down)})
        if(left!==current.index&&map[left]>0) list.push({"index":left,"g":current.g+1,"f":current.g+1-fMap[left]+distance(current.index,left)})
        if(right!==current.index&&map[right]>0) list.push({"index":right,"g":current.g+1,"f":current.g+1-fMap[right]+distance(current.index,right)})

        return list
    }

    function getDirt(index){
        initialMap[index]=2
        let up=index-(index-mapCols>=0?mapCols:0)
        let down=index+(index+mapCols<initialMap.length?mapCols:0)
        let left=index-(index%mapCols===0?0:1)
        let right=index+((index+1)%mapCols===0?0:1)
        let vIn=[]
        if(initialMap[up]===0) vIn.push(up)
        if(initialMap[down]===0) vIn.push(down)
        if(initialMap[left]===0) vIn.push(left)
        if(initialMap[right]===0) vIn.push(right)
        let r=Math.floor(Math.random()*vIn.length)
        initialMap[vIn[r]]=1


        if(initialMap.filter(function(a){return a===1}).length<3) initialMap[initialMap.lastIndexOf(2)]=1
    }

    function aStar(start, end){
        let openList = []
        let closedList = []
        let cameFrom = []
        let fMap=feromoneMap.slice()

        openList.push({"index":start,"g":0,"f":0})
        cameFrom[start]=[]

        let count=0
        while(openList.length>0&&count<initialMap.length){
            openList.sort(function (n1,n2){ return n1.f-n2.f})
            let current = openList.shift()

            if(current.index === end)
                return reconstructPath(current,cameFrom[current.index])

            getNeighborList(current,initialMap,fMap).forEach(function (node){
                let cost=0
                if(cameFrom.indexOf(node.index)>=0)
                    cameFrom[node.index].forEach(function (n){cost+=n.f})

                if(cost===0||current.f<=cost){
                    cameFrom[node.index]=cameFrom[current.index].slice()
                    cameFrom[node.index].push(current)
                }
                let a=false
                openList.forEach(function (n){if(n.index===node.index) a = true})
                closedList.forEach(function (n){if(n.index===node.index) a = true})
                if(!a){
                    openList.push(node)
                }
            })
            //closedList.push(current)
            count++
        }
        return [start]

    }

    Component.onCompleted: {
        createAnt()
        calculateCenterPoints()
    }
    onWidthChanged: calculateCenterPoints()
    onHeightChanged: calculateCenterPoints()

    Timer{
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            createAnt()
            feromoneMap.forEach(function(value,index){feromoneMap[index]=value-0.1>0?value-0.1:0})
        }
    }

    function verifyColor(index){

        if(anteaterPath.indexOf(index)>=0) return "red"

        let up=index-mapCols
        let down=index+mapCols
        let left=index-(index%mapCols===0?0:1)
        let right=index+((index+1)%mapCols===0?0:1)
        if(initialMap[index]===3) return "grey"
        else if(initialMap[index]===2) return "white"
        else if(initialMap[index]===1) return "#656521"
        else if(initialMap[index]===0)
        {
            if((up>0&&initialMap[up]>1)||
                    (down<initialMap.length-1&&initialMap[down]>1)||
                    (initialMap[left]>1)||
                    (initialMap[right]>1))
                return "brown"
        }
        return "black"
    }
    function verifyColorValues(index){
        let up=index-mapCols
        let down=index+mapCols
        let left=index-(index%mapCols==0?0:1)
        let right=index+((index+1)%mapCols===0?0:1)

        return index+"\n"+up+":"+down+"\n"+left+":"+right+":"
    }
    function addFeromone(index,amount=0.1){
        if(initialMap[index]>0){
            feromoneMap[index]=feromoneMap[index]+amount
            feromoneMap[index]=feromoneMap[index]>1?1:feromoneMap[index]
        }
    }

    GridView{
        id:gView
        width: parent.width
        height: parent.height*3/4
        y:parent.height/4
        cellWidth: width/mapCols
        cellHeight: cellWidth
        model: initialMap
        delegate: Rectangle{
            width: gView.cellWidth
            height: gView.cellHeight
            color: verifyColor(index)
            Timer{
                interval: 10
                repeat: true
                running: true
                onTriggered: color= verifyColor(index)
            }
            Text{
                text: verifyColorValues(index)
                font.pointSize:6
                color: "pink"
                visible: false
            }
            MouseArea{
                anchors.fill: parent
                onClicked: antEater(index)//addFeromone(index,0.5)
                preventStealing: true
            }
            Rectangle{
                id:fVisual
                anchors.fill: parent
                anchors.margins: parent.width/10
                opacity: feromoneMap[index]!==undefined?feromoneMap[index]:0
                color: "green"
                Timer{
                    interval: 10
                    repeat: true
                    running: true
                    onTriggered: fVisual.opacity=feromoneMap[index]
                }
            }
        }
    }
    property var anteaterPath: []
    function antEater(index){
        if(canEat){
            anteaterPath=aStar(initialMap.indexOf(3),index)
            tT.start()
            canEat=false
        }
    }

    Timer{
        interval: 5000
        repeat: true
        running: true
        onTriggered: canEat=true
    }

    Timer{
        id:tT
        interval: 100
        onTriggered: anteaterPath=[]
    }
    Image{
        fillMode: Image.PreserveAspectFit
        height: parent.height/4
        x:parent.width/2
        y:height/8
        source: "http://ldjam46.000webhostapp.com/LD48/anteater.png"
    }
}
