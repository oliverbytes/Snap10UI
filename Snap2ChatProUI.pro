APP_NAME = Snap2ChatProUI

CONFIG 		+= qt warn_on cascades10 mobility

QT 			+= network
QT 			+= xml
QT 			+= declarative

MOBILITY 	+= sensors

LIBS += -lQtLocationSubset
LIBS += -lbb
LIBS += -lbbdata
LIBS += -lbbsystem
LIBS += -lbbdevice
LIBS += -lbps 
LIBS += -lcamapi
LIBS += -lbbmultimedia
LIBS += -lbbplatform
LIBS += -lbbplatformbbm
LIBS += -lbbcascadespickers
LIBS += -lGLESv1_CM
LIBS += -lscreen
LIBS += -lbbcascadesmultimedia
LIBS += -lexif
LIBS += -lcrypto
LIBS += -lcurl 
LIBS += -lpackageinfo 
LIBS += -lhuapi

RESOURCES += qrc-assets.qrc
DEPENDPATH += assets

include(config.pri)
