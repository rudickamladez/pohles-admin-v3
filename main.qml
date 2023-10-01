import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Pohles

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("PohLes administration v3")
    minimumWidth: 640
    minimumHeight: 480

    footer: Label {
        text: "DEBUG"
        visible: root.debug
    }

    Component.onCompleted: {
        root.getTime()
        root.getTicket()
    }

    property bool debug: false

    TicketModel {
        id: ticketModel
    }

    Shortcut {
        sequence: "Ctrl+D"
        onActivated: root.debug = !root.debug
    }

    function getTime() {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                var text = request.responseText;
                if (root.debug) {
                    console.log(text);
                }
                const timeArray = JSON.parse(text)
                timeModel.clear()
                for (let i = 0; i < timeArray.length; ++i) {
                    timeArray[i]["occupiedPositions"] = 0
                    timeArray[i]["freePositions"] = 0
                    timeModel.append(timeArray[i])
                    root.getTimeAvailableId(timeArray[i]["id"])
                }
            }
        }
        request.open("GET", "https://api-dev.pohles.rudickamladez.cz/time", true);
        request.send();
    }

    function getTimeAvailableId(id) {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                var text = request.responseText;
                if (root.debug) {
                    console.log(text);
                }
                let obj = JSON.parse(text)
                for (let i = 0; i < timeModel.rowCount(); ++i) {
                    if (timeModel.get(i)["id"] === obj["_id"]) {
                        timeModel.setProperty(i, "occupiedPositions", obj["occupiedPositions"])
                        timeModel.setProperty(i, "freePositions", obj["freePositions"])
                        break
                    }
                }
            }
        }
        request.open("GET", "https://api-dev.pohles.rudickamladez.cz/time/available/"+id, true);
        request.send();
    }

    function getTicket() {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                var text = request.responseText;
                if (root.debug) {
                    console.log(text);
                }
                ticketModel.loadFromJson(text)
            }
        }
        request.open("GET", "https://api-dev.pohles.rudickamladez.cz/ticket", true);
        request.send();
    }

    ListModel {
        id: timeModel
    }

    ItemSelectionModel {
        id: timeSelectionModel
        model: timeModel
    }

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: false
            Layout.fillHeight: true

            Button {
                text: "Rezervace"
                onClicked: root.getTicket()
            }
            Item {
                Layout.fillHeight: true
            }
        }

        ListView {
            id: ticketView
            clip: true
            model: ticketModel
            Layout.fillWidth: true
            Layout.fillHeight: true
            delegate: ItemDelegate {
                width: ListView.view.width
                text: firstNameRole+" "+lastNameRole+" "+emailRole
            }
        }
    }

//    ColumnLayout {
//        anchors.left: parent.left
//        anchors.right: parent.horizontalCenter
//        anchors.top: parent.top
//        anchors.bottom: parent.bottom
//        spacing: 0

//        RowLayout {
//            Layout.fillWidth: true

//            ToolButton {
//                icon.source: "qrc:/icons/refresh.svg"
//                onClicked: root.getTime()
//            }
//            ToolButton {
//                icon.source: "qrc:/icons/add.svg"
//            }
//            ToolButton {
//                icon.source: "qrc:/icons/delete.svg"
//                enabled: timeSelectionModel.hasSelection
//            }
//        }

//        ListView {
//            id: timeView
//            model: timeModel
//            clip: true
//            Layout.fillWidth: true
//            Layout.fillHeight: true
//            delegate: ItemDelegate {
//                width: ListView.view.width
//                text: name+" "+occupiedPositions+"/"+maxCountOfTickets
//                onClicked: {
//                    root.getTimeAvailableId(id)
//                    timeSelectionModel.select(timeModel.index(index,0), ItemSelectionModel.ClearAndSelect)
//                }
//                Component.onCompleted: {
//                    highlighted = timeSelectionModel.isSelected(timeModel.index(index,0))
//                }
//                TapHandler {
//                    acceptedButtons: Qt.RightButton
//                    onTapped: (eventPoint) => {
//                                  root.getTimeAvailableId(id)
//                                  timeSelectionModel.select(timeModel.index(index,0), ItemSelectionModel.ClearAndSelect)
//                                  let p = mapToItem(Overlay.overlay, eventPoint.position)
//                                  timeContextMenuLoader.active = true
//                                  timeContextMenuLoader.item.x = p.x
//                                  timeContextMenuLoader.item.y = p.y
//                                  timeContextMenuLoader.item.open()
//                              }
//                }

//                Connections {
//                    target: timeSelectionModel
//                    function onSelectionChanged(selected, deselected) {
//                        highlighted = timeSelectionModel.isSelected(timeModel.index(index,0))
//                    }
//                }
//                Rectangle {
//                    anchors.left: parent.left
//                    anchors.top: parent.top
//                    anchors.bottom: parent.bottom
//                    color: pickColor(occupiedPositions, maxCountOfTickets)
//                    width: occupiedPositions > 0 ? (occupiedPositions/maxCountOfTickets)*parent.width : 0

//                    function pickColor(occupiedPositions, maxCountOfTickets) {
//                        if (maxCountOfTickets === 0) {
//                            return "transparent"
//                        } else if (occupiedPositions/maxCountOfTickets < 0.5) {
//                            return "green"
//                        } else if (occupiedPositions === maxCountOfTickets) {
//                            return "crimson"
//                        } else {
//                            return "goldenrod"
//                        }
//                    }
//                }
//                Component {
//                    id: timeContextMenu

//                    Menu {
//                        parent: Overlay.overlay
//                        MenuItem {
//                            text: "Upravit"
//                            icon.source: "qrc:/icons/edit.svg"
//                        }
//                        MenuItem {
//                            text: "Smazat"
//                            icon.source: "qrc:/icons/delete.svg"
//                        }
//                    }
//                }

//                Loader {
//                    id: timeContextMenuLoader
//                    active: false
//                    sourceComponent: timeContextMenu
//                }
//            }
//            add: Transition {
//                NumberAnimation {
//                    property: "opacity"
//                    from: 0.0
//                    to: 1.0
//                    duration: 200
//                }
//            }
//            Label {
//                anchors.fill: parent
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                wrapMode: Text.WordWrap
//                visible: parent.count === 0
//                text: "Žádné časy k zobrazení"
//            }
//        }
//    }

//    ColumnLayout {
//        anchors.left: parent.horizontalCenter
//        anchors.right: parent.right
//        anchors.top: parent.top
//        anchors.bottom: parent.bottom
//        spacing: 0

//        RowLayout {
//            Layout.fillWidth: true

//            ToolButton {
//                icon.source: "qrc:/icons/add.svg"
//            }
//            ToolButton {
//                icon.source: "qrc:/icons/delete.svg"
//            }
//        }

//        ListView {
//            Layout.fillWidth: true
//            Layout.fillHeight: true
//            clip: true
//            add: Transition {
//                NumberAnimation {
//                    property: "opacity"
//                    from: 0.0
//                    to: 1.0
//                    duration: 200
//                }
//            }
//            Label {
//                anchors.fill: parent
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                wrapMode: Text.WordWrap
//                visible: parent.count === 0
//                text: "Žádné rezervace k zobrazení"
//            }
//        }
//    }
}
