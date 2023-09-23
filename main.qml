import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("PohLes administration v3")

    footer: Label {
        text: "DEBUG"
        visible: root.debug
    }

    property bool debug: false

    property var timeArray: []

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
                        root.timeArray = JSON.parse(text)
                    }
                }
        request.open("GET", "https://api-dev.pohles.rudickamladez.cz/time", true);
        request.send();
    }

    onTimeArrayChanged: {
        timeModel.clear()
        for (let i = 0; i < timeArray.length; ++i) {
            timeArray[i]["occupiedPositions"] = 0
            timeArray[i]["freePositions"] = 0
            timeModel.append(timeArray[i])
            root.getTimeAvailableId(timeArray[i]["id"])
        }
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

    ListModel {
        id: timeModel
    }

    ItemSelectionModel {
        id: timeSelectionModel
        model: timeModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            Layout.fillWidth: true

            TabButton {
                text: "Times"
                onClicked: {
                    stack.currentIndex = 0
                    root.getTime()
                }
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true

                    ToolButton {
                        icon.source: "qrc:/icons/add.svg"
                    }

                    ToolButton {
                        icon.source: "qrc:/icons/delete.svg"
                        enabled: timeSelectionModel.hasSelection
                    }
                }

                ListView {
                    id: timeView
                    model: timeModel
                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        text: id+" "+name+" "+occupiedPositions+"/"+maxCountOfTickets
                        onClicked: {
                            root.getTimeAvailableId(id)
                            timeSelectionModel.select(timeModel.index(index,0), ItemSelectionModel.ClearAndSelect)
                        }
                        Component.onCompleted: {
                            highlighted = timeSelectionModel.isSelected(timeModel.index(index,0))
                        }
                        Connections {
                            target: timeSelectionModel
                            function onSelectionChanged(selected, deselected) {
                                highlighted = timeSelectionModel.isSelected(timeModel.index(index,0))
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            color: pickColor(occupiedPositions, maxCountOfTickets)
                            width: occupiedPositions > 0 ? (occupiedPositions/maxCountOfTickets)*parent.width : 0

                            function pickColor(occupiedPositions, maxCountOfTickets) {
                                if (maxCountOfTickets === 0) {
                                    return "transparent"
                                } else if (occupiedPositions/maxCountOfTickets < 0.5) {
                                    return "green"
                                } else if (occupiedPositions === maxCountOfTickets) {
                                    return "crimson"
                                } else {
                                    return "goldenrod"
                                }
                            }
                        }
                    }
                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 200
                        }
                    }
                }
            }
        }
    }
}
