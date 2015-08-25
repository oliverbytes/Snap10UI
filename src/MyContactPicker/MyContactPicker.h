
#ifndef MYCONTACTPICKER_H_
#define MYCONTACTPICKER_H_

#include <QtCore/QObject>

namespace bb
{
    namespace cascades
    {
        namespace system
		{

		}
    }
}

class MyContactPicker : public QObject
{
    Q_OBJECT

public:
    MyContactPicker(QObject* parent = 0);

    Q_INVOKABLE void open();

Q_SIGNALS:
    void complete(QList<int> contactIds);

private Q_SLOTS:
	void onContactsSelected(const QList<int> &contactIds);

private:

};

#endif
