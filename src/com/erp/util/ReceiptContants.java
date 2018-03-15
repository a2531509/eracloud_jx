package com.erp.util;

/**
 * 业务凭证工具。
 *
 * @author 钱佳明。
 * @version 1.0。
 * @date 2016-2-25。
 */
public final class ReceiptContants {

	/**
	 * 业务凭证标题。
	 */
	public static final String TITLE = "嘉兴社会保障市民卡业务办理凭证";

	/**
	 * 业务凭证类型。
	 */
	public static final class TYPE {

		/**
		 * 普通业务凭证类型。 适用于个人申领、个人发放、补卡、换卡、挂失、解挂。
		 */
		public static final String COMMON = "/reportfiles/CommonReceipt.jasper";

		/**
		 * 现金充值业务凭证类型。 适用于现金充值市民卡账户、现金充值市民卡钱包。
		 */
		public static final String CASH_RECHARGE = "/reportfiles/CashRechargeReceipt.jasper";

		/**
		 * 转账业务凭证类型。适用于市民卡账户转市民卡钱包、市民卡账户互转、市民卡钱包转市民卡账户、换卡转账、充值卡充值。
		 */
		public static final String TRANSFER_ACCOUNTS = "/reportfiles/TransferAccountsReceipt.jasper";

		/**
		 * 单位充值业务凭证类型。
		 */
		public static final String COMPANY_RECHARGE = "/reportfiles/CompanyRechargeReceipt.jasper";

		/**
		 * 单位转个人业务凭证类型。
		 */
		public static final String COMPANY_TRANSFER_PERSOANL = "/reportfiles/CompanyTransferPersonalReceipt.jasper";

		/**
		 * 规模发放业务凭证类型。
		 */
		public static final String BATCH_ISSUSE = "/reportfiles/BatchIssuseReceipt.jasper";

		/**
		 * 卡片注销业务凭证类型。
		 */
		public static final String CARD_CANCEL = "/reportfiles/CardCancelReceipt.jasper";

		/**
		 * 卡片注销余额返现业务凭证类型。
		 */
		public static final String CARD_CANCEL_BALANCE_RETURN = "/reportfiles/CardCancelBalanceReturnReceipt.jasper";

	}

	/**
	 * 业务凭证字段。
	 */
	public static final class FIELD {

		/**
		 * 标题。
		 */
		public static final String TITLE = "p_Title";

		/**
		 * 交易流水号。
		 */
		public static final String DEAL_NO = "p_Deal_No";

		/**
		 * 交易类型。
		 */
		public static final String DEAL_TYPE = "p_Deal_Type";

		/**
		 * 交易费用。
		 */
		public static final String DEAL_FEE = "p_Deal_Fee";

        /**
         * 交易费用类型。
         */
        public static final String DEAL_FEE_TYPE = "p_Deal_Fee_Type";

		/**
		 * 交易人数。
		 */
		public static final String DEAL_PERSON_COUNT = "p_Deal_Person_Count";

		/**
		 * 受理时间。
		 */
		public static final String ACCEPT_TIME = "p_Accept_Time";

		/**
		 * 批次号。
		 */
		public static final String MAKE_BATCH_ID = "p_Make_Batch_Id";

		/**
		 * 任务号。
		 */
		public static final String TASK_ID = "p_Task_Id";

		/**
		 * 任务数量。
		 */
		public static final String TASK_COUNT = "p_Task_Count";

		/**
		 * 卡号（芯片号）。
		 */
		public static final String CARD_NO = "p_Card_No";

        public static final String CARD_TYPE = "p_Card_Type";

		/**
		 * 卡状态。
		 */
		public static final String CARD_STATUS = "p_Card_Status";

		/**
		 * 转入卡号。
		 */
		public static final String IN_CARD_NO = "p_In_Card_No";

		/**
		 * 转出卡号。
		 */
		public static final String OUT_CARD_NO = "p_Out_Card_No";

		/**
		 * 社保卡号。
		 */
		public static final String SOCIAL_SECURITY_CARD_NO = "p_Social_Security_Card_No";

		/**
		 * 单位编号。
		 */
		public static final String COMPANY_ID = "p_Company_Id";

		/**
		 * 单位名称。
		 */
		public static final String COMPANY_NAME = "p_Company_Name";

		/**
		 * 客户编号。
		 */
		public static final String CUSTOMER_ID = "p_Customer_Id";

		/**
		 * 客户姓名。
		 */
		public static final String CUSTOMER_NAME = "p_Customer_Name";

		/**
		 * 转入客户姓名。
		 */
		public static final String IN_CUSTOMER_NAME = "p_In_Customer_Name";

		/**
		 * 转出客户姓名。
		 */
		public static final String OUT_CUSTOMER_NAME = "p_Out_Customer_Name";

		/**
		 * 客户证件类型。
		 */
		public static final String CUSTOMER_CERTIFICATE_TYPE = "p_Customer_Certificate_Type";

		/**
		 * 客户证件号码。
		 */
		public static final String CUSTOMER_CERTIFICATE_NO = "p_Customer_Certificate_No";

		/**
		 * 转出客户证件号码。
		 */
		public static final String OUT_CUSTOMER_CERTIFICATE_NO = "p_Out_Customer_Certificate_No";

		/**
		 * 代理人姓名。
		 */
		public static final String AGENT_NAME = "p_Agent_Name";

		/**
		 * 代理人证件类型。
		 */
		public static final String AGENT_CERTIFICATE_TYPE = "p_Agent_Certificate_Type";

		/**
		 * 代理人证件号码。
		 */
		public static final String AGENT_CERTIFICATE_NO = "p_Agent_Certificate_No";

        /**
         * 代理人联系电话。
         */
        public static final String AGENT_PHONE_NO = "p_Agent_Phone_No";

		/**
		 * 银行名称。
		 */
		public static final String BANK_NAME = "p_Bank_Name";

		/**
		 * 银行卡号。
		 */
		public static final String BANK_CARD_NO = "p_Bank_Card_No";

		/**
		 * 账户名称。
		 */
		public static final String ACCOUNT_NAME = "p_Account_Name";

		/**
		 * 账户余额。
		 */
		public static final String ACCOUNT_BALANCE = "p_Account_Balance";

		/**
		 * 联机账户余额。
		 */
		public static final String ONLINE_ACCOUNT_BALANCE = "p_Online_Account_Balance";

		/**
		 * 脱机账户余额。
		 */
		public static final String OFFLINE_ACCOUNT_BALANCE = "p_Offline_Account_Balance";

		/**
		 * 转入账户余额。
		 */
		public static final String IN_ACCOUNT_BALANCE = "p_In_Account_Balance";

		/**
		 * 转出账户余额。
		 */
		public static final String OUT_ACCOUNT_BALANCE = "p_Out_Account_Balance";

		/**
		 * 总账户余额。
		 */
		public static final String TOTAL_BALANCE = "p_Total_Balance";

		/**
		 * 注销原因。
		 */
		public static final String CANCEL_REASON = "p_Cancel_Reason";

		/**
		 * 受理网点名称。
		 */
		public static final String ACCEPT_BRANCH_NAME = "p_Accept_Branch_Name";

        /**
         * 受理网点电话。
         */
        public static final String ACCEPT_BRANCH_TELEPHONE = "p_Accept_Branch_Telephone";

		/**
		 * 受理员工号。
		 */
		public static final String ACCEPT_USER_ID = "p_Accept_User_Id";

		/**
		 * 受理员工姓名。
		 */
		public static final String ACCEPT_USER_NAME = "p_Accept_User_Name";
		
		/**
		 * 卡面金额
		 */
		public static final String READ_CARD_BALANCE = "p_Card_Balance";
	}

}
