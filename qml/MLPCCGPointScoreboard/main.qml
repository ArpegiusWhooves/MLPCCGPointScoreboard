import QtQuick 2.0
//import Ubuntu.Components 1.1
import QtQuick.Controls 1.1

import QtQuick.LocalStorage 2.0

Rectangle {
    id: root
    width: 500
    height: 800

    property int turn: 0
    property int firstplayer: 0
    property int player: 0

    property int apperturn: appofscore()

    property var db


    Component.onCompleted:  {
        root.state= "start";

        root.db = LocalStorage.openDatabaseSync("MLPCCGHistory", "1.0", "The Example QML SQL!", 1000000);

        root.db.transaction( function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS History( name text, data text)');

                // Show all added greetings
                var rs = tx.executeSql('SELECT name,data FROM History WHERE name = "curent"');

                if(rs.rows.length === 0) {
                    continue1.visible=false;
                    tx.executeSql('INSERT INTO History VALUES("curent","")');
                    return;
                }

                var o= JSON.parse(rs.rows.item(0).data);
                if( o === undefined || o == null ) return;

                textField1.text= o.players[0].name;
                textField2.text= o.players[1].name;

                continue1.visible= o.state == "player1turn" || o.state == "player2turn";

//                if(continue1.visible)
//                    console.log( "Deserialized: " + JSON.stringify(o));

        } );
    }

    function load() {
        root.db.transaction( function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS History( name text, data text)');

                // Show all added greetings
                var rs = tx.executeSql('SELECT name,data FROM History WHERE name = "curent"');

                if(rs.rows.length === 0) {
                    continue1.visible=false;
                    return;
                }
                var o= JSON.parse(rs.rows.item(0).data);
//                console.log( "Deserialized: " + JSON.stringify(o));
                root.deserialize(o);
        } );
    }

    function getHistory(){
        var t=[];
        for( var i= 0; i < actionList.count; ++i ){
            t.push( actionList.get(i) );
        }
        return t;
    }

    function serialize() {
        return {
            state: root.state,
            turn: root.turn,
            firstPlayer: root.firstplayer,
            players: [boardPlayer1.serialize(), boardPlayer2.serialize()],
            history: getHistory(),
            player: root.player
        };
    }

    function deserialize(o) {
        root.firstplayer= o.firstPlayer;
        root.turn=o.turn;
        actionList.clear();
        for( var i= 0; i < o.history.length; ++i ){
            actionList.append( o.history[i] );
        }
        boardPlayer1.deserialize(o.players[0]);
        boardPlayer2.deserialize(o.players[1]);
        root.player= o.player;
    }

    function save() {
        root.db.transaction( function(tx) {
            var s = JSON.stringify( root.serialize() );
            tx.executeSql('UPDATE History SET data=? WHERE name="curent"',[JSON.stringify(root.serialize())]);
//            console.log( s );
        } );
    }

    function appofscore() {
        var max= Math.max( boardPlayer1.score, boardPlayer2.score );
        if(max < 2) return 2;
        if(max < 6) return 3;
        if(max < 11) return 4;
        return 5;
    }

    FontLoader {
        id: fontCelestiaRedux
        source: "./fonts/CelestiaMediumRedux1.55.ttf"
    }

    ListModel {
        id: actionList
    }

    DailyBackgorund
    {
        anchors.fill: parent
        id: background
        nightEnabled: false
        progtresTop: boardPlayer2.score / 15
        progtresBottom: boardPlayer1.score / 15
    }

    MainLog {
        id: mainLog
        anchors.centerIn: root
        width: Math.min( root.width, root.height/1.3 )
        height: root.height/2.5

        Text {
            id: text1
            text: root.getPlayerName() + " Turn "+ turn
            anchors.top: mainLog.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
            font.family: fontCelestiaRedux.name;
        }

        HistoryView {
            id: listView1
            visible: root.player !== 0
            anchors.fill: mainLog.paper
            anchors.leftMargin: 10
            model:  actionList
        }
    }

    PlayerBoard {
        id: boardPlayer1
        name: "Player 1"
        enabled: false

        height: Math.min( root.height/2, root.width/2.5)

        actionList: actionList
        playerNumber: 1

        startFirst: root.firstplayer == 1

        haveTurn: root.player == 1

        onHaveTurnChanged: {
//            if(haveTurn && playerTurn < root.turn) {
            if(haveTurn) {
                startTurn(root.apperturn,root.turn);
            }
//            playerTurn= root.turn;
            root.save();
        }

        onLeave: {
            root.player=0;
            root.state= "player2win";
            root.save();
        }

        onPass: {
            if(root.firstplayer == 1) {
                root.turn += 1;
            }
            root.player=2;
        }

        onUndoTurn: {
            if(root.firstplayer == 2) {
                root.turn -= 1;
            }
            root.player=2;
        }

        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onScoreChanged: {
            if(score >= 15){
                root.player=0;
                root.state= "player1win";
            }
        }


        property alias name: textField1.text

    }

    PlayerBoard {
        id: boardPlayer2
        name: "Player 2"
        enabled: false

        height: Math.min( root.height/2, root.width/2.5)

        actionList: actionList
        playerNumber: 2

        haveTurn: root.player==2
        startFirst: root.firstplayer == 2

        onHaveTurnChanged: {
            if(haveTurn) {
                startTurn(root.apperturn,root.turn);
            }
        }

        onLeave: {
            root.player=0;
            root.state= "player1win";
        }

        onPass: {
            if(root.firstplayer == 2) {
                root.turn += 1;
            }
             root.player=1;
        }

        onUndoTurn: {
            if(root.firstplayer == 1) {
                root.turn -= 1;
            }
            root.player=1;
        }

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        rotation: 180

        onScoreChanged: {
            if(score >= 15){
                root.player=0;
                root.state= "player2win";
            }
        }

        property alias name: textField2.text

    }

    Column {
        visible: root.player == 0
        anchors.centerIn: parent
        spacing: root.height / 20
        TextField {
            id: textField2
            y: 0
            readOnly: root.player!=0
            font.pointSize: 18
            text: qsTr("Player 2")
            placeholderText: qsTr("Player 2")
            font.family: fontCelestiaRedux.name;
            rotation: textField2.focus?0:180;
            Behavior on rotation {
                SmoothedAnimation{
                    duration:1000
                }
            }
        }
        TextField {
            id: textField1
            y: 0
            readOnly: root.player!=0
            font.pointSize: 18
            text: qsTr("Player 1")
            placeholderText: qsTr("Player 1")
            font.family: fontCelestiaRedux.name;

        }
    }

    function getPlayerName() {
        if(root.player == 1)return textField1.text;
        if(root.player == 2)return textField2.text;
    }

    function beforeStartGame() {
        if( textField1.text == "" ) textField1.text = "Player 1";
        if( textField2.text == "" ) textField1.text = "Player 2";
        boardPlayer1.turn=0;
        boardPlayer2.turn=0;
        boardPlayer1.playerTurn=0;
        boardPlayer2.playerTurn=0;
        boardPlayer1.clear();
        boardPlayer2.clear();
        readyPlayer1.checked=false;
        readyPlayer2.checked=false;
        root.turn=1;
    }

    function startGameFirstPlayer1() {
        beforeStartGame();
        root.firstplayer=1;
        root.player=2;
        save();
    }

    function startGameFirstPlayer2() {
        beforeStartGame();
        root.firstplayer=2;
        root.player=1;
        save();
    }

    Button {
        id: buttonStartPlayer1
        text: qsTr("  Start as First Player ")
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0
        anchors.bottom: mainLog.top
        rotation: 180
        enabled:false
        onClicked: root.startGameFirstPlayer1();
    }

    Button {
        id: buttonStartPlayer2
        text: qsTr("  Start as First Player ")
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0
        anchors.top: mainLog.bottom
        enabled:false
        onClicked: root.startGameFirstPlayer2();
    }

    function startRandom() {
        if(!readyPlayer1.checked) return;
        if(!readyPlayer2.checked) return;
        var v = Math.random();
//        console.log("Random value: "+v);
        if(v > 0.5){
            root.startGameFirstPlayer1();
        }
        else
        {
            root.startGameFirstPlayer2();
        }
    }

    CheckBox {
        id: readyPlayer1
        x: 167
        y: 543
        text: qsTr("I am ready for random choose")
        opacity: 0
        rotation: 180
        anchors.verticalCenter: mainLog.top
        anchors.horizontalCenter: parent.horizontalCenter
        onCheckedChanged: root.startRandom()
    }

    CheckBox {
        id: readyPlayer2
        x: 173
        text: qsTr("I am ready for random choose")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: mainLog.bottom
        opacity: 0
        onCheckedChanged: root.startRandom()
    }

    Button {
        id: button3
        x: 602
        y: 366
        text: qsTr("Save to pastebin")
        enabled: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
        onClicked: {
            var req= new XMLHttpRequest();
            req.onreadystatechange = function() {
                                if (req.readyState === XMLHttpRequest.DONE) {
                                    button3.text = req.responseText;
                                    Qt.openUrlExternally(req.responseText);
                                }
                            }
            var text= "";

            for( var i= 0; i < actionList.count; ++i ){
                var o = actionList.get(i);
                text += "["+Qt.formatDateTime(new Date(o.date),"yyyy.MM.dd hh:mm:ss")+"] "+o.info+"\n";
            }

            var title= "MLP CCG " + boardPlayer1.name +" vs "+ boardPlayer2.name;
            var params= "api_option=paste&api_dev_key=ea5baa4b6d8023fd305d9f75cce3b788&api_paste_private=1&api_paste_name="+encodeURIComponent(title)+"&api_paste_code="+encodeURIComponent(text);
            req.open("POST", "http://pastebin.com/api/api_post.php");
            req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            req.setRequestHeader("Content-length", params.length);
            //req.setRequestHeader("Connection", "close");
            req.send(params);
        }
    }

    Button {
        id: continue1
        text: qsTr("Continue game")
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        rotation: 90
        opacity: 0
        onClicked: {
            root.load();
        }
    }


    states: [
        State {
            name: "start"

            PropertyChanges {
                target: mainLog
                anchors.verticalCenterOffset: 1
            }

            PropertyChanges {
                target: buttonStartPlayer2
                opacity: 1
                enabled:true
            }
            PropertyChanges {
                target: buttonStartPlayer1
                y: 190
                opacity: 1
                enabled:true
            }
            PropertyChanges {
                target: boardPlayer1
                anchors.bottomMargin: -64
            }

            PropertyChanges {
                target: boardPlayer2
                anchors.topMargin: -76
            }

            PropertyChanges {
                target: continue1
                opacity: 1.0
            }

            PropertyChanges {
                target: text1
                text: qsTr("Select first player")
            }

            PropertyChanges {
                target: readyPlayer2
                x: 159
                y: 544
                opacity: 1
            }

            PropertyChanges {
                target: readyPlayer1
                opacity: 1
            }
        },
        State {
            name: "player1turn"
            when: root.player==1
            PropertyChanges {
                target: mainLog
                anchors.verticalCenterOffset: 0
                rotation: 0
            }
            PropertyChanges {
                target: buttonStartPlayer2
                enabled:false
                opacity: 0
            }
            PropertyChanges {
                target: buttonStartPlayer1
                enabled:false
                opacity: 0
            }

            PropertyChanges {
                target: boardPlayer2
                enabled: true
            }

            PropertyChanges {
                target: boardPlayer1
                enabled: true
            }

            PropertyChanges {
                target: background
                nightEnabled: true
            }
        },
        State {
            name: "player2turn"
            when: root.player==2
            PropertyChanges {
                target: mainLog
                anchors.verticalCenterOffset: 0
                rotation: 180
            }
            PropertyChanges {
                target: buttonStartPlayer2
                enabled:false
                opacity: 0
            }
            PropertyChanges {
                target: buttonStartPlayer1
                enabled:false
                opacity: 0
            }

            PropertyChanges {
                target: background
                nightEnabled: true
                rotation: 180
            }

            PropertyChanges {
                target: boardPlayer1
                enabled: true
            }

            PropertyChanges {
                target: boardPlayer2
                enabled: true
            }
        },
        State {
            name: "player1win"
            when: boardPlayer1.score >= 15

            PropertyChanges {
                target: boardPlayer1
                anchors.bottomMargin: -64
            }

            PropertyChanges {
                target: boardPlayer2
                anchors.topMargin: -76
            }
            PropertyChanges {
                target: buttonStartPlayer2
                enabled:true
                opacity: 1
            }
            PropertyChanges {
                target: buttonStartPlayer1
                enabled:true
                opacity: 1
            }

            PropertyChanges {
                target: button3
                enabled: true
                anchors.verticalCenterOffset: 0
                opacity: 1
            }

            PropertyChanges {
                target: text1
                text: boardPlayer1.name + qsTr(" wins!")
            }

            PropertyChanges {
                target: readyPlayer2
                opacity: 1
            }

            PropertyChanges {
                target: readyPlayer1
                opacity: 1
            }
        },
        State {
            name: "player2win"
            when: boardPlayer2.score >= 15

            PropertyChanges {
                target: boardPlayer1
                anchors.bottomMargin: -64
            }

            PropertyChanges {
                target: boardPlayer2
                anchors.topMargin: -76
            }
            PropertyChanges {
                target: buttonStartPlayer2
                enabled:true
                opacity: 1
            }
            PropertyChanges {
                target: buttonStartPlayer1
                enabled:true
                opacity: 1
            }

            PropertyChanges {
                target: button3
                enabled: true
                rotation: 180
                opacity: 1
            }

            PropertyChanges {
                target: mainLog
                rotation: 180
            }

            PropertyChanges {
                target: text1
                text: boardPlayer2.name + qsTr(" wins!")
            }

            PropertyChanges {
                target: readyPlayer2
                opacity: 1
            }

            PropertyChanges {
                target: readyPlayer1
                opacity: 1
                anchors.topMargin: 539
            }
        },
        State {
            name: "State1"
        },
        State {
            name: "State2"
        }
    ]

    transitions: [
        Transition {
            SpringAnimation {
                properties: "rotation,x,y"
                spring: 2
                damping: 0.2
            }
            NumberAnimation {
                properties: "opacity,anchors.topMargin,anchors.bottomMargin"
                duration: 300
            }

        }

    ]
}
