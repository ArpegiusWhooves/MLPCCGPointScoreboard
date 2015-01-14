import QtQuick 2.0
//import Ubuntu.Components 1.1
import QtQuick.Controls 1.1

Item {
    id: item1
    width: 628
    height: 350
    
    property alias name: textField1.text
    property alias readOnlyName: textField1.readOnly

    property int score: 0
    property bool haveTurn: false
    property int playerTurn: 0
    property int playerNumber: -1
    property int actionPoints: 0
    property int seconds: 0

    property ListModel actionList
    property int phase: 1
    property int turn: 0

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
        actionPoints += ap;
        if( myTurn > turn ) {
            turn= myTurn;
            actionList.append({ player:playerNumber, info: "[Player" +  playerNumber +  "] Start turn " +turn+ ", gain "+ap+ " action points.",  prop:"ST", val:ap, colorCode: "green", date: Date.now() });
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
                actionList.append({ player:playerNumber, info:"[Player" +  playerNumber +  "] Score final point!",  prop:"WIN", val:1, colorCode: "red", date: Date.now() })
            else
                actionList.append({ player:playerNumber, info:"[Player" +  playerNumber +  "] Capture in opponents turn final point!",  prop:"WIN", val:1, colorCode: "red", date: Date.now() });
            item1.score+=1;
            return;
        }

        item1.score+=1;

        var last= actionList.get(actionList.count-1);
        var textinfo= "[Player" +  playerNumber +  "] "+ {"SP":"Score ","AS":"Capture in opponents turn "}[button1.mode];
        if(last !== undefined && last.prop === button1.mode)
        {
            actionList.setProperty(actionList.count-1,"info",textinfo + (last.val + 1) + " points!");
            actionList.setProperty(actionList.count-1,"val",last.val + 1);
        } else {
            actionList.append({  player:playerNumber, info:textinfo+"point!",  prop:button1.mode, val:1, colorCode: "yellow", date: Date.now() });
        }
        listView1.positionViewAtEnd()
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
        anchors.left: parent.left
        anchors.leftMargin: 5
        width: item1.width * 0.35
        height: button1.width*1.2
        property string mode: "SP"
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        onClicked: item1.scorePoint()
        value: item1.score
    }
    
    TextField {
        id: textField1
        height: 40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 79
        anchors.right: button5.left
        anchors.rightMargin: 1
        anchors.left: button1.right
        anchors.leftMargin: 1
        readOnly: true
        font.pointSize: 18
        placeholderText: qsTr("Text Field")
    }


    Text {
        id: text3
        text:getElapsedTime()
        anchors.bottom: textField1.top
        anchors.bottomMargin: 50
        anchors.right: button5.left
        anchors.rightMargin: 5

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
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: item1.width / 2
        height: button2.width * 0.229
        opacity: 0

        onClicked: {
            item1.pass();
        }

    }

    Button {
        id: button3
        y: 16
        text: qsTr("Leave")
        anchors.bottom: button4.top
        anchors.bottomMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: 1
        opacity: 0
        onClicked: {
            actionList.append({  player:playerNumber, info:"[Player" +  playerNumber +  "] "+"Player leave the game!",  prop:"LG", colorCode: "red", date: Date.now() });
            listView1.positionViewAtEnd()
            item1.leave();
        }
    }

    Button {
        id: button4
        text: qsTr("Undo")
        anchors.bottom: button1.top
        anchors.bottomMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 1
        opacity: 0
        onClicked: {
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
        }
    }

    function gainActionPoint() {
        item1.actionPoints+=1;
        var last= actionList.get(actionList.count-1);
        var mode= {"true":"GA","false":"CA"}[haveTurn];
        var textinfo= "[Player" +  playerNumber +  "] " + {"true":"Gain ","false":"Gain in opponents turn "}[haveTurn];
        if(last !== undefined && last.prop === mode)
        {
            actionList.setProperty(actionList.count-1,"info",textinfo + (last.val + 1) + " action points!");
            actionList.setProperty(actionList.count-1,"val",last.val + 1);
        } else {
            actionList.append({ player:playerNumber, info:textinfo+" action point!",  prop:mode, val:1, colorCode: "blue", date: Date.now() });
        }
        listView1.positionViewAtEnd()
    }

    ButtonAction {
        id: button5
        width: item1.width * 0.3
        height: button5.width * 1.34
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
                var textinfo= "[Player" +  playerNumber +  "] "+ {"true":"Spend ","false":"Spend in opponents turn "}[haveTurn];
                if(last !== undefined && last.prop === mode)
                {
                    actionList.setProperty(actionList.count-1,"info",textinfo + (last.val + 1) + " action points!");
                    actionList.setProperty(actionList.count-1,"val",last.val + 1);
                } else {
                    actionList.append({ player:playerNumber, info:textinfo+"action point!",  prop:mode, val:1, colorCode: "green", date: Date.now() });
                }
                listView1.positionViewAtEnd()
            }

    states: [
        State {
            name: "noturn"

            when: !item1.haveTurn && readOnlyName

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
        },
        State {
            name: "phase1"

            when: item1.haveTurn && item1.phase == 1

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
        }
    ]
}
