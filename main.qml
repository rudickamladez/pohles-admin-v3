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
    property string keycloak_url: ""
    property string keycloak_client_id: ""
    property string keycloak_client_secret: ""
    property string username: ""
    property string password: ""
    property var session

    footer: Label {
        text: "DEBUG"
        visible: root.debug
    }

    Component.onCompleted: {
        root.getAuthTokens()
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

    onSessionChanged: {
        if (root.session.access_token === undefined || root.session.refresh_token === undefined) {
            console.log("cannot retrieve authentication tokens")
            return
        }
        root.getTime()
        root.getTicket()
    }

    function getAuthTokens() {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                root.session = JSON.parse(request.responseText)
            }
        }
        request.open("POST", root.keycloak_url+"realms/pohles/protocol/openid-connect/token", true)
        request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        request.send("client_id="+root.keycloak_client_id+"&client_secret="+root.keycloak_client_secret+"&grant_type=password&username="+root.username+"&password="+root.password)
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
        request.open("GET", root.apiUrl+"time", true);
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
//                    console.log(text);
                }
                ticketModel.loadFromJson(text)
            }
        }
        request.open("GET", root.apiUrl+"ticket", true);
        request.setRequestHeader("Content-Type", "application/json")
        request.setRequestHeader("Authorization", "Bearer "+root.session.access_token)
        request.send();
    }

    function patchTicketId(ticketObject) {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                console.log(request.responseText)
                root.getTicket()
            }
        }
        request.open("PATCH", root.apiUrl+"ticket/"+ticketObject.id, true);
        request.setRequestHeader("accept", "application/json")
        request.setRequestHeader("Content-Type", "application/json")
        request.setRequestHeader("Authorization", "Bearer "+root.session.access_token)
        request.send(JSON.stringify(ticketObject));
    }

    function deleteTicketId(ticketID) {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                if (root.debug) {
                    console.log(request.responseText)
                }
                root.getTicket()
            }
        }
        request.open("DELETE", root.apiUrl+"ticket/"+ticketID, true)
        request.setRequestHeader("accept", "application/json")
        request.setRequestHeader("Authorization", "Bearer "+root.session.access_token)
        request.send()
    }

    function postTicketEasy(newTicket) {
        let request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === 4) {
                if (root.debug) {
                    console.log(request.responseText)
                }
                root.getTicket()
            }
        }
        request.open("POST", root.apiUrl+"ticket/easy", true)
        request.setRequestHeader("accept", "application/json")
        request.setRequestHeader("Content-Type", "application/json")
        request.setRequestHeader("Authorization", "Bearer "+root.session.access_token)
        request.send(JSON.stringify(newTicket))
    }

    ListModel {
        id: timeModel
    }

    ItemSelectionModel {
        id: timeSelectionModel
        model: timeModel
    }

    ItemSelectionModel {
        id: ticketSelectionModel
        model: ticketFilterModel
    }

    Component {
        id: addTicketComponent

        Popup {
            parent: Overlay.overlay
            modal: true
            width: parent.width*0.8
            height: parent.height*0.8
            x: (Overlay.overlay.width-width)/2
            y: (Overlay.overlay.height-height)/2

            GridLayout {
                id: addTicketGrid
                columns: 2
                anchors.fill: parent
                Label {
                    text: "Vytvořit rezervaci"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                }
                Label {
                    text: "Jméno"
                }
                TextField {
                    id: addFirstName
                    Layout.fillWidth: true
                }
                Label {
                    text: "Příjmení"
                }
                TextField {
                    id: addlastName
                    Layout.fillWidth: true
                }
                Label {
                    text: "Email"
                }
                TextField {
                    id: addEmail
                    Layout.fillWidth: true
                }
                Label {
                    text: "Čas"
                }
                ComboBox {
                    id: addTime
                    model: timeModel
                    valueRole: "id"
                    textRole: "name"
                }
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Item {
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "Přidat"
                        enabled: addFirstName.text != "" &&
                                 addlastName.text != "" &&
                                 addEmail.text != "" &&
                                 addTime.currentValue !== ""
                        onClicked: {
                            let object = {
                                name: {
                                    first: addFirstName.text,
                                    last: addlastName.text
                                },
                                email: addEmail.text,
                                time: addTime.currentValue
                            }
                            root.postTicketEasy(object)
                            addTicketLoader.item.close()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
            onClosed: {
                addTicketLoader.active = false
            }
        }
    }

    Loader {
        id: addTicketLoader
        active: false
        sourceComponent: addTicketComponent
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

                RowLayout {
                    Button {
                        text: "Přidat..."
                        icon.source: "qrc:/icons/add.svg"
                        onClicked: {
                            addTicketLoader.active = true
                            addTicketLoader.item.open()
                        }
                    }

                    TextField {
                        id: searchField
                        placeholderText: "vyhledávání..."
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                    }
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
                        onClicked: {
                            ticketSelectionModel.select(ticketFilterModel.index(index,0), ItemSelectionModel.ClearAndSelect)
                        }
                        onDoubleClicked: {
                            ticketEditLoader.active = true
                            ticketEditLoader.item.open()
                        }

                        Component.onCompleted: {
                            highlighted = ticketSelectionModel.isSelected(ticketFilterModel.index(index,0))
                        }

                        Connections {
                            target: ticketSelectionModel
                            function onSelectionChanged(selected, deselected) {
                                highlighted = ticketSelectionModel.isSelected(ticketFilterModel.index(index,0))
                            }
                        }

                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: (eventPoint) => {
                                          ticketSelectionModel.select(ticketFilterModel.index(index,0), ItemSelectionModel.ClearAndSelect)
                                          let p = mapToItem(Overlay.overlay, eventPoint.position)
                                          ticketContextMenuLoader.active = true
                                          ticketContextMenuLoader.item.x = p.x
                                          ticketContextMenuLoader.item.y = p.y
                                          ticketContextMenuLoader.item.open()
                                      }
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
                                    RowLayout {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        Item {Layout.fillWidth: true}
                                        Switch {
                                            id: editSwitch
                                            text: "Upravit"
                                            checked: false
                                        }
                                        Item {Layout.fillWidth: true}
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
                                        name: {
                                            first: firstNameField.text,
                                            last: lastNameField.text
                                        },
                                        email: emailField.text,
                                        time: timeComboBox.currentValue
                                    }
                                    root.patchTicketId(object)
                                }
                            }
                        }

                        Loader {
                            id: ticketEditLoader
                            active: false
                            sourceComponent: ticketDialog
                        }

                        Component {
                            id: ticketContextMenu

                            Menu {
                                parent: Overlay.overlay

                                MenuItem {
                                    text: "Upravit"
                                    icon.source: "qrc:/icons/edit.svg"
                                    onClicked: {
                                        ticketEditLoader.active = true
                                        ticketEditLoader.item.open()
                                    }
                                }
                                MenuItem {
                                    text: "Smazat"
                                    icon.source: "qrc:/icons/delete.svg"
                                    onClicked: {
                                        root.deleteTicketId(idRole)
                                    }
                                }
                                onClosed: {
                                    ticketContextMenuLoader.active = false
                                }
                            }
                        }

                        Loader {
                            id: ticketContextMenuLoader
                            active: false
                            sourceComponent: ticketContextMenu
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
//        }
//    }
}
