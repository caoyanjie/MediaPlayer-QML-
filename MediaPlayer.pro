TEMPLATE = app

QT += quick av avwidgets xml
CONFIG += c++11

# x86 and x64 specific macros defines
CONFIG += debug_and_release
contains(QT_ARCH, i386) {
    DEFINES += ARCH_X86
    CONFIG(debug, debug|release){
        DESTDIR = $$PWD/Bin/x86/Debug
    }else{
        DESTDIR = $$PWD/Bin/x86/Release
    }
}
else{
    DEFINES += ARCH_X64
    CONFIG(debug, debug|release){
        DESTDIR = $$PWD/Bin/x64/Debug
    }else{
        DESTDIR = $$PWD/Bin/x64/Release
    }
}

# temp files dir
OBJECTS_DIR += $$PWD/../Temp
RCC_DIR += $$PWD/../Temp
MOC_DIR += $$PWD/../Temp

# icon
RC_ICONS = Images/logo.ico

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    Application.h \
    MusicPlaylistModel.h \
    Network.h \
    LrcViewer.h \
    XmlProcess.h

SOURCES += main.cpp \
    Application.cpp \
    MusicPlaylistModel.cpp \
    Network.cpp \
    LrcViewer.cpp \
    XmlProcess.cpp

RESOURCES += qml.qrc
