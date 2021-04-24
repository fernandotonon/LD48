import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    property var antComponent: Qt.createComponent("Ant.qml")
    Rectangle{
        anchors.fill: parent
        color: "green"
    }
    property int mapCols: 20
    property var initialMap:   [0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,2,0,2,2,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,2,0,2,0,2,2,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,1,0,0,0,2,0,2,2,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,1,0,0,2,1,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    function verifyColor(index){
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
            Text{
                text: verifyColorValues(index)
                font.pointSize:6
                color: "pink"
                visible: false
            }
        }
    }
    function createAnt(){
        let obj=antComponent.createObject(this)
        obj.x=initialMap.indexOf(3)*width/mapCols+(width/mapCols)/2-obj.width/2
        obj.y=height/4
    }
    Component.onCompleted: createAnt()

    Timer{
        interval: 500
        repeat: true
        onTriggered: createAnt()
    }
}
