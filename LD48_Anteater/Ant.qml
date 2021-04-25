import QtQuick 2.0

Item {
    width: 20
    height: 20
    property var initialPoint:Qt.point(x,y)
    property var position:0
    property int moveInterval: 100
    property bool isCarryingDirt: false
    property var path:[]
    property real feromone: 0.1
    Rectangle{
        width: (gameWindow.width/gameWindow.mapCols)/2
        height: width
        color: "#656521"
        visible: isCarryingDirt
    }
    Behavior on x{
        NumberAnimation{}
    }
    Behavior on y{
        NumberAnimation{}
    }

    function move(){
        if(gameWindow.anteaterPath.indexOf(position)>=0){
            gameWindow.antsEaten+=1
            destroy()
        }
        if(path.length>0){
            position = path.shift()
            let nextPoint=gameWindow.centerPointsMap[position]
            x=nextPoint.x-width/2
            y=nextPoint.y-height/2
            gameWindow.addFeromone(position,feromone)
        }
        else{
            isCarryingDirt=gameWindow.initialMap[position]===1
            if(isCarryingDirt){
                gameWindow.getDirt(position)
            }
            if(isCarryingDirt){
                path=gameWindow.aStar(position,gameWindow.initialMap.indexOf(3),gameWindow.initialMap)
            }else{
                //ACO
                let iO=gameWindow.initialMap.indexOf(1)
                let p1=gameWindow.aStar(position,iO)
                iO=gameWindow.initialMap.indexOf(1,iO+1)
                let p2=gameWindow.aStar(position,iO)
                iO=gameWindow.initialMap.indexOf(1,iO+1)
                let p3=gameWindow.aStar(position,iO)

                let p1F=0
                let p2F=0
                let p3F=0

                p1.forEach(function(i){p1F+=gameWindow.feromoneMap[i]})
                p2.forEach(function(i){p2F+=gameWindow.feromoneMap[i]})
                p3.forEach(function(i){p3F+=gameWindow.feromoneMap[i]})

                let sum=p1F+p2F+p3F
                let v=[{"path":0,"l":p1F/sum},{"path":1,"l":p2F/sum},{"path":2,"l":p3F/sum}]
                v.sort(function(a,b){return b.l-a.l})
                let r=Math.random()
                if(r<v[0].l) path=p1
                else if(r<(v[0].l+v[1].l)) path=p2
                else path=p3
            }
            feromone=1/path.length
        }
    }

    Timer{
        interval: moveInterval
        repeat: true
        running: true
        onTriggered: move()
    }
    Image {
        anchors.fill: parent
        source: "http://ldjam46.000webhostapp.com/LD48/ant.png"
    }
}

