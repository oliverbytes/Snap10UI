#ifndef VIRTUALKEYBOARDHANDLER_HPP_
#define VIRTUALKEYBOARDHANDLER_HPP_

#include <QObject>
#include <bb/AbstractBpsEventHandler>
#include <bps/event.h>

class VirtualKeyboardHandler : public QObject, public bb::AbstractBpsEventHandler {
    Q_OBJECT

    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool isPhysicalKeyboardDevice READ isPhysicalKeyboardDevice)

public:
    VirtualKeyboardHandler();
    virtual ~VirtualKeyboardHandler();
    virtual void event(bps_event_t *event);

    Q_INVOKABLE void setVisible(bool visibleState);

    Q_INVOKABLE void setVisibility(bool visibility);

public Q_SLOTS:
    void toggleVisibility();

private:
    int pHeight;
    int height();
    bool pVisible;
    bool visible();
    bool pIsPhysicalKeyboardDevice;
    bool isPhysicalKeyboardDevice();
    void virtualKeyboardVisible(bool command);

Q_SIGNALS:
    void keyboardShown();
    void keyboardHidden();
    void heightChanged();
    void visibleChanged();
};

#endif /* VIRTUALKEYBOARDHANDLER_HPP_ */
