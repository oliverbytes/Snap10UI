#include "MyContactPicker.h"

#include <QDebug>
#include <bb/cascades/pickers/ContactPicker>
#include <bb/cascades/pickers/ContactSelectionMode>

using bb::cascades::pickers::ContactPicker;
using bb::cascades::pickers::ContactSelectionMode;

MyContactPicker::MyContactPicker(QObject* parent)
    : QObject(parent)
{

}

void MyContactPicker::open()
{
	ContactPicker *contactPicker = new ContactPicker();
	contactPicker->setMode(ContactSelectionMode::Multiple);
	contactPicker->setKindFilters(QSet<bb::pim::contacts::AttributeKind::Type>() << bb::pim::contacts::AttributeKind::Phone);

	bool success = QObject::connect(contactPicker, SIGNAL(contactsSelected(QList<int>)), this, SLOT(onContactsSelected(QList<int>)));

	if (success)
	{
		contactPicker->open();
	}
	else
	{
		qDebug() << "Didn't connect the picker signal";
	}
}

void MyContactPicker::onContactsSelected(const QList<int> &contactIds)
{
	qDebug() << "contacts" << contactIds;
	emit complete(contactIds);
}
