#include <QDebug>

#include "AESParams.hpp"

AESParams::AESParams(GlobalContext & g, QString encryptionMode) :
		Crypto("AESParams"), _globalContext(g), _aesParams(NULL)
{
	int rc;

	if(encryptionMode == "ECB")
	{
		rc = hu_AESParamsCreate(SB_AES_ECB, SB_AES_128_BLOCK_BITS, NULL, NULL, &_aesParams, _globalContext.ctx());
	}
	else if(encryptionMode == "CBC")
	{
		rc = hu_AESParamsCreate(SB_AES_CBC, SB_AES_128_BLOCK_BITS, NULL, NULL, &_aesParams, _globalContext.ctx());
	}

	maybeLog("AESParamsCreate", rc);
}

AESParams::~AESParams()
{
	if (_aesParams != NULL)
	{
		int rc = hu_AESParamsDestroy(&_aesParams, _globalContext.ctx());
		maybeLog("AESParamsDestroy", rc);
		_aesParams = NULL;
	}
}

