import QtQuick 2.0
//import Ubuntu.Components 1.1
import QtQuick.Controls 1.1

Item {
    id: item1

    property int score: 0
    property bool startFirst: false
    property bool haveTurn: false
    property int playerTurn: 0
    property int playerNumber: -1
    property int actionPoints: 0
    property int seconds: 0

    property ListModel actionList
    property int phase: 1
    property int turn: 0

    property bool enabled: true

    function serialize() {
        return {
           name: item1.name,
           score: item1.score,
           startFirst: item1.startFirst,
           haveTurn: item1.haveTurn,
           playerTurn: item1.playerTurn,
           playerNumber: item1.playerNumber,
           actionPoints: item1.actionPoints,
           seconds: item1.seconds,
           phase: item1.phase,
           turn: item1.turn
        };
    }

    function deserialize(o) {
       item1.name=o.name;
       item1.score=o.score;
       item1.playerTurn=o.playerTurn;
//       item1.playerNumber=o.playerNumber;
       item1.actionPoints=o.actionPoints;
       item1.seconds=o.seconds;
       item1.phase=o.phase;
       item1.turn=o.turn;
    }

    function getHistory(){
        var t=[];
        for( var i= 0; i < actionList.count; ++i ){
            t.push( actionList.get(i) );
        }
        return t;
    }

    signal leave
    signal pass
    signal undoTurn

    function startTurn(ap,myTurn) {
        if( myTurn > turn ) {
            actionPoints += ap;
            turn= myTurn;
            actionList.append({ player:playerNumber, info: name + " start turn " +turn+ ", gain "+ap+ " action points.",  prop:"ST", val:ap, colorCode: "green", date: Date.now() });
            root.save();
        };
        listView1.positionViewAtEnd()
    }

    function clear(){
        score=0;
        seconds=0;
        actionPoints=0;
        actionList.clear();
    }

    function scorePoint() {

        if(item1.score==14){
            if(item1.haveTurn)
                actionList.append({ player:playerNumber, info: name + " score final point!",  prop:"WIN", val:1, colorCode: "red", date: Date.now() })
            else
                actionList.append({ player:playerNumber, info: name + " capture in opponents turn final point!",  prop:"WIN", val:1, colorCode: "red", date: Date.now() });
            item1.score+=1;
            return;
        }

        item1.score+=1;

        var last= actionList.get(actionList.count-1);
        var textinfo= name + {"SP":" score ","AS":" capture in opponents turn "}[button1.mode];
        if(last !== undefined && last.prop === button1.mode)
        {
            actionList.setProperty(actionList.count-1,"info",textinfo + (last.val + 1) + " points!");
            actionList.setProperty(actionList.count-1,"val",last.val + 1);
        } else {
            actionList.append({  player:playerNumber, info:textinfo+"point!",  prop:button1.mode, val:1, colorCode: "yellow", date: Date.now() });
        }
        listView1.positionViewAtEnd();
        root.save();
    }

    Image {
        id: image1
        width: height/1.5
        height: parent.height/2
        y: 64
        anchors.bottom: button5.bottom
        opacity: 0
        anchors.right: button5.left
        source: "cloud.svg"
    }

    Timer {
        running: item1.haveTurn
        repeat: true
        onTriggered: {
            item1.seconds += 1;
        }
    }

    onHaveTurnChanged: {
        if(!haveTurn)
        {
            item1.phase= 1;
            //actionList.clear();
        }
    }
    
    ButtonScore {
        id: button1
        enabled: item1.enabled
        anchors.left: parent.left
        anchors.leftMargin: 5
        width: Math.min(item1.width*0.35, item1.height*0.9/1.2)
        height: Math.min(item1.width*0.35*1.2, item1.height*0.9)
        property string mode: "SP"
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        onClicked: item1.scorePoint()
        value: item1.score
    }

    Text {
        id: text3
        text: getElapsedTime()
        anchors.top: image1.top
        anchors.topMargin: image1.height/6
        anchors.horizontalCenter: image1.horizontalCenter
        opacity: 0
//        anchors.bottomMargin: 20

        function getElapsedTime(){
            if( item1.seconds%60 < 10 ){
                return (item1.seconds/60|0) + ":0" + item1.seconds%60;
            } else {
                return (item1.seconds/60|0) + ":" + item1.seconds%60;
            }
        }

        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 15
    }

    ButtonPass {
        id: button2
        enabled: item1.enabled
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min( item1.width / 2, item1.height )
        height: Math.min( item1.width / 2 * 0.229, item1.height* 0.229 )
        opacity: 0

        onClicked: {
            item1.pass();
        }

    }
    Flow {
        anchors.bottom: button2.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: item1.horizontalCenter
        width: item1.width/3.5
        Button {
            id: button3
            enabled: item1.enabled
            text: qsTr("Leave")
            opacity: 0
            onClicked: {
                actionList.append({  player:playerNumber, info:name + " leave the game!",  prop:"LG", colorCode: "red", date: Date.now() });
                listView1.positionViewAtEnd()
                item1.leave();
            }
        }

        Button {
            id: button4
            enabled: item1.enabled
            text: qsTr("Undo")
            opacity: 0
            onClicked: {
                if(actionList.count<2) return;
                var last;
                if( item1.haveTurn )
                {
                    last= actionList.get(actionList.count-1);
                    if( last.prop === "SP" ) {
                        item1.score -= last.val;
                        actionList.remove(actionList.count-1);
                    } else if( last.prop === "GA" ) {
                        item1.actionPoints -= last.val;
                        actionList.remove(actionList.count-1);
                    } else if( last.prop === "SA" ) {
                        item1.actionPoints += last.val;
                        actionList.remove(actionList.count-1);
                    } else if( last.prop === "ST" ) {
                        item1.actionPoints -= last.val;
                        actionList.remove(actionList.count-1);
                        turn--;
                        item1.undoTurn();
                    }
                } else {
                    last= actionList.get(actionList.count-1);
                    if( last.prop === "AS" ) {
                        item1.score -= last.val;
                        actionList.remove(actionList.count-1);
                    } else if( last.prop === "CA" ) {
                        item1.actionPoints -= last.val;
                        actionList.remove(actionList.count-1);
                    } else if( last.prop === "SCA" ) {
                        item1.actionPoints += last.val;
                        actionList.remove(actionList.count-1);
                    }
                }
                root.save();
            }
        }
    }

    function gainActionPoint() {
        item1.actionPoints+=1;
        var last= actionList.get(actionList.count-1);
        var mode= {"true":"GA","false":"CA"}[haveTurn];
        var textinfo= name + {"true":" gain ","false":" gain in opponents turn "}[haveTurn];
        if(last !== undefined && last.prop === mode)
        {
            actionList.setProperty(actionList.count-1,"info",textinfo + (last.val + 1) + " action points!");
            actionList.setProperty(actionList.count-1,"val",last.val + 1);
        } else {
            actionList.append({ player:playerNumber, info:textinfo+" action point!",  prop:mode, val:1, colorCode: "blue", date: Date.now() });
        }
        listView1.positionViewAtEnd();
        root.save();
    }

    ButtonAction {
        id: button5
        enabled: item1.enabled
        width: Math.min( item1.width * 0.3, item1.height * 0.9 / 1.34)
        height: Math.min( item1.width * 0.3 * 1.34, item1.height * 0.9)
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        value: item1.actionPoints
        opacity: 0
        onClickedUp: item1.spendActionPoint()
        onClickedDown: item1.gainActionPoint()
    }


    function spendActionPoint () {
        if(item1.actionPoints<=0) return;
                item1.actionPoints-=1;
                var last= actionList.get(actionList.count-1);
                var mode= {"true":"SA","false":"SCA"}[haveTurn];
                var textinfo= name + {"true":" spend ","false":" spend in opponents turn "}[haveTurn];
                if(last !== undefined && last.prop === mode)
                {
                    actionList.setProperty(actionList.count-1,"info",textinfo + (last.val + 1) + " action points!");
                    actionList.setProperty(actionList.count-1,"val",last.val + 1);
                } else {
                    actionList.append({ player:playerNumber, info:textinfo+"action point!",  prop:mode, val:1, colorCode: "green", date: Date.now() });
                }
                listView1.positionViewAtEnd()
                root.save();
            }

    states: [
        State {
            name: "noturn"

            when: !item1.haveTurn && root.player > 0

            PropertyChanges {
                target: button1
                mode:"AS"
                opacity: 1
            }

            PropertyChanges {
                target: button4
                opacity: 1
            }

            PropertyChanges {
                target: button5
                opacity: 1
            }

            PropertyChanges {
                target: button3
                opacity: 1
            }

            PropertyChanges {
                target: text3
                opacity: 1
            }

            PropertyChanges {
                target: image1
                opacity: 1
            }
        },
        State {
            name: "phase1"

            when: item1.haveTurn

            PropertyChanges {
                target: button1
                mode:"SP"
                opacity: 1
            }

            PropertyChanges {
                target: button2
                opacity: 1
            }

            PropertyChanges {
                target: button3
                opacity: 1
            }

            PropertyChanges {
                target: button4
                opacity: 1
            }

            PropertyChanges {
                target: button5
                opacity: 1
            }

            PropertyChanges {
                target: text3
                opacity: 1
            }

            PropertyChanges {
                target: image1
                opacity: 1
            }
        }
    ]
}
