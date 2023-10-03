import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import Pohles

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("PohLes administration v3")
    minimumWidth: 640
    minimumHeight: 480

    property string apiUrl: "https://api-dev.pohles.rudickamladez.cz/"

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

    TicketFilterModel {
        id: ticketFilterModel
        sourceModel: ticketModel
        query: searchField.text
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
        request.open("GET", root.apiUrl+"time/available/"+id, true);
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
        request.open("GET", root.apiUrl+"ticket", true);
        request.send();
    }

    function postTicketId(ticketObject) {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                root.getTicket()
            }
        }
        request.open("PATCH", root.apiUrl+"ticket/"+ticketObject.id, true);
        request.setRequestHeader("accept", "application/json")
        request.setRequestHeader("Content-Type", "application/json")
        request.send(JSON.stringify(ticketObject));
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
                onClicked: {
                    stack.currentIndex = 0
                    root.getTicket()
                }
            }

            Button {
                text: "Časy"
                onClicked: {
                    stack.currentIndex = 1
                    root.getTime()
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        StackLayout {
            id: stack

            ColumnLayout {
                Item {
                    Layout.fillHeight: true
                    Layout.maximumHeight: 10
                }

                TextField {
                    id: searchField
                    placeholderText: "vyhledávání..."
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                }

                ListView {
                    id: ticketView
                    clip: true
                    model: ticketFilterModel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        text: timeRole+" "+firstNameRole+" "+lastNameRole+" "+emailRole
                        onDoubleClicked: {
                            ticketEditLoader.active = true
                            ticketEditLoader.item.open()
                        }

                        Component {
                            id: ticketDialog

                            Dialog {
                                parent: Overlay.overlay
                                width: parent.width*0.8
                                height: ticketGrid.preferredHeight
                                x: (Overlay.overlay.width-width)/2
                                y: (Overlay.overlay.height-height)/2
                                standardButtons: Dialog.Cancel | Dialog.Ok
                                GridLayout {
                                    id: ticketGrid
                                    columns: 2
                                    anchors.fill: parent
                                    Label {
                                        text: "Upravit"
                                    }
                                    Switch {
                                        id: editSwitch
                                        checked: false
                                    }
                                    Label {
                                        text: "Jméno"
                                    }
                                    TextField {
                                        id: firstNameField
                                        text: firstNameRole
                                        enabled: editSwitch.checked
                                        Layout.fillWidth: true
                                    }
                                    Label {
                                        text: "Příjmení"
                                    }
                                    TextField {
                                        id: lastNameField
                                        text: lastNameRole
                                        enabled: editSwitch.checked
                                        Layout.fillWidth: true
                                    }
                                    Label {
                                        text: "Email"
                                    }
                                    TextField {
                                        id: emailField
                                        text: emailRole
                                        enabled: editSwitch.checked
                                        Layout.fillWidth: true
                                    }
                                    Label {
                                        text: "Čas"
                                    }
                                    ComboBox {
                                        id: timeComboBox
                                        enabled: editSwitch.checked
                                        model: timeModel
                                        valueRole: "id"
                                        textRole: "name"
                                        Component.onCompleted: {
                                            timeComboBox.currentIndex = timeComboBox.indexOfValue(timeIdRole)
                                        }
                                    }
                                }
                                onClosed: {
                                    ticketEditLoader.active = false
                                }
                                onAccepted: {
                                    let object = {
                                        id: idRole,
                                        //"status":"unpaid",
                                        //"statusChanges":[],
                                        name: {
                                            first: firstNameField.text,
                                            last: lastNameField.text
                                        },
                                        email: emailField.text,
                                        //"year":{"id":"650ab8aa62b3202698aa34b9","name":"2023","status":"active","times":["63374a511f76f1184328c2ee","63381bf41f76f1184328c310","63381c081f76f1184328c312","63381c6f1f76f1184328c314","63381c771f76f1184328c316","63381c7d1f76f1184328c318","63381c821f76f1184328c31a","63381c871f76f1184328c31c","63381c8c1f76f1184328c31e","63381c911f76f1184328c320","6346e08e072bc135f6c85383","63381ca01f76f1184328c322","63381ca51f76f1184328c324","63381cac1f76f1184328c326","6346e080072bc135f6c85381","63381cbe1f76f1184328c328","63381cc31f76f1184328c32c","63381cc81f76f1184328c32e","63381cce1f76f1184328c330","63381cd51f76f1184328c332","63381cda1f76f1184328c334","63381ce31f76f1184328c336"],"endOfReservations":"2023-10-20T18:10:20.230Z"},
                                        time: timeComboBox.currentValue
                                    }
                                    root.postTicketId(object)
                                }
                            }
                        }

                        Loader {
                            id: ticketEditLoader
                            active: false
                            sourceComponent: ticketDialog
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

            ListView {
                id: timeView
                model: timeModel
                clip: true
                delegate: ItemDelegate {
                    width: ListView.view.width
                    text: name+" "+occupiedPositions+"/"+maxCountOfTickets
                    onClicked: {
                        root.getTimeAvailableId(id)
                        timeSelectionModel.select(timeModel.index(index,0), ItemSelectionModel.ClearAndSelect)
                    }
                    Component.onCompleted: {
                        highlighted = timeSelectionModel.isSelected(timeModel.index(index,0))
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: (eventPoint) => {
                                      root.getTimeAvailableId(id)
                                      timeSelectionModel.select(timeModel.index(index,0), ItemSelectionModel.ClearAndSelect)
                                      let p = mapToItem(Overlay.overlay, eventPoint.position)
                                      timeContextMenuLoader.active = true
                                      timeContextMenuLoader.item.x = p.x
                                      timeContextMenuLoader.item.y = p.y
                                      timeContextMenuLoader.item.open()
                                  }
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
                    Component {
                        id: timeContextMenu

                        Menu {
                            parent: Overlay.overlay
                            MenuItem {
                                text: "Upravit"
                                icon.source: "qrc:/icons/edit.svg"
                            }
                            MenuItem {
                                text: "Smazat"
                                icon.source: "qrc:/icons/delete.svg"
                            }
                        }
                    }

                    Loader {
                        id: timeContextMenuLoader
                        active: false
                        sourceComponent: timeContextMenu
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
                Label {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    visible: parent.count === 0
                    text: "Žádné časy k zobrazení"
                }
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
