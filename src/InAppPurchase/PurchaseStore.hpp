#ifndef PURCHASESTORE_HPP_
#define PURCHASESTORE_HPP_

#include <QObject>
#include <QSettings>
#include <Qt/qdeclarativedebug.h>

class PurchaseStore: public QObject
{
	Q_OBJECT

public:

	PurchaseStore(QObject* parent = 0);
	virtual ~PurchaseStore();

public Q_SLOTS:

	void deletePurchaseRecords();
	void storePurchase(const QString& digitalGoodSku);
	void retrieveLocalPurchases();

Q_SIGNALS:
    void purchaseRecordsDeleted();
    void purchaseRetrieved(const QString& digitalGoodSku);

private:

	QSettings m_digitalGoodsStore;
};

#endif /* PURCHASESTORE_HPP_ */
