package com.erp.service;

public interface PgDataService extends BaseService {
	void reSendCard(String certNo);

	void removeReSendCard(String certNo, String reason);
}
