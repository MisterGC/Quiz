include (clayapp)

clay_app( quiz
    VERSION 1.0
    LINK_LIBS
        Qt::Core
        Qt::Qml
        Qt::Quick
    QML_FILES
        Main.qml
        Game.qml
        PresentationView.qml
        ModeratorView.qml
        PlayerView.qml
        SoundTodo.qml
        QuestionData.js
)
