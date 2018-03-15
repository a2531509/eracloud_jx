CREATE OR REPLACE PACKAGE BODY PK_SMK_TO_YKT IS

  /*
  truncate table ACC_ADJUST_INFO
  truncate table ACC_INOUT_DETAIL;
  truncate table BASE_END_OUT;
  truncate table BASE_GRADE;
  truncate table BASE_MERCHANT_LIMIT;
  truncate table BASE_PROVIDER;
  truncate table CARD_APPLY_TEMP;
  truncate table CARD_APP_BIND;
  truncate table CARD_APP_BIND_CONF;
  truncate table CARD_NO_HIS;
  truncate table CARD_RECHARGE;
  truncate table CARD_SALE_BOOK;
  truncate table CARD_TASK_IMP;
  truncate table CARD_TYPE_LIM;
  truncate table CARD_UPDATE;
  truncate table PAY_CARD_ALM_ERR;
  truncate table PAY_CARD_DEAL_REC;
  truncate table PAY_DIVIDE_ORG;
  truncate table PAY_DIVIDE_RATE;
  truncate table PAY_DIVIDE_RATE_DETAIL;
  truncate table PAY_MERCHANT_KEY;
  truncate table PAY_OFFLINE;
  truncate table PAY_RECONC_FILE;
  truncate table PAY_RECONC_LIST;
  truncate table PAY_SP_DEAL_RANGE;
  truncate table PAY_TRANSFOR_IMPORT;
  ;
  truncate table POS_MAK_VER;
  truncate table STL_DEAL_LIST;
  truncate table STL_DEAL_LIST_DIV;
  truncate table STL_DEAL_SUM;
  truncate table STL_RECEIPT_REG;
  truncate table SYS_BRANCH_AGENT_LIMIT
  truncate table SYS_NOTE;
  truncate table SYS_RULES_RISK
  truncate table SYS_SMESSAGES
  truncate table TR_SERV_REC
  truncate table SYS_ERR_LOG
  truncate table SYS_ACTION_LOG
  truncate table STOCK_ACC
  truncate table STOCK_LIST
  truncate table STOCK_REC
  truncate table BASE_PHOTO
  truncate table POS_SERVERLOG;
  truncate table PAY_ACCTYPE_SQN;
  truncate table PAY_CARD_DEAL_REC;
  truncate table PAY_CLR_SUM;
  
  truncate table PAY_FEE_RATE;
  
  truncate table PAY_MERCHANT_ACCTYPE;
  truncate table PAY_MERCHANT_LIM;
  truncate table PAY_OFFLINE_BLACK;
  truncate table PAY_OFFLINE_FILENAME;
  truncate table PAY_OFFLINE_LIST;
  truncate table CARD_SALE_LIST;
  truncate table CARD_SALE_REC;
  truncate table CARD_TASK_LIST;
  truncate table STAT_CARD_PAY;
  truncate table STAT_CASH;
  truncate table CASH_BOX_REC;
  
  truncate table ACC_INOUT_DETAIL;
  truncate table CARD_BLACK;
  truncate table CARD_BLACK_REC;
  truncate table CARD_APPLY;
  truncate table CARD_APPLY_TASK;
  truncate table ACC_ACCOUNT_GEN;
  truncate table ACC_ACCOUNT_SUB;
  truncate table BASE_MERCHANT;
  truncate table BASE_TAG_END;
  truncate table CARD_BASEINFO;
  truncate table BASE_PASM;
  truncate table SYS_REPORT;
  truncate table BASE_MERCHANT_MODE;
  truncate table BASE_MERCHANT_TYPE;
  truncate table BASE_BANK;
  truncate table BASE_CITY;
  truncate table BASE_COMM;
  truncate table BASE_CORP;
  truncate table BASE_PERSONAL;
  truncate table CASH_BOX;
  truncate table BASE_TOWN��*/
  --��ȡDealCodeֵ
  FUNCTION F_GET_TASK_STATE(TASK_STATE IN VARCHAR2) RETURN VARCHAR2 IS
    TASKSTATE VARCHAR2(2);
  BEGIN
    --����״̬(0����������,1�ƿ���,2���ƿ�,3������,4�ѽ���,5����������9�������)
    IF TASK_STATE = '0' THEN
      --00����������,01�ѷ���ί��02��ί����ˣ�03�����У�04��������ˣ�10�ƿ���,20���ƿ�,30������,40�ѽ���,50�����У�90�������
      TASKSTATE := '00';
    elsIF TASK_STATE = '1' THEN
      TASKSTATE := '10';
    
    elsIF TASK_STATE = '2' THEN
      TASKSTATE := '20';
    
    elsIF TASK_STATE = '3' THEN
      TASKSTATE := '30';
    
    elsIF TASK_STATE = '4' THEN
      TASKSTATE := '40';
    
    elsIF TASK_STATE = '5' THEN
      TASKSTATE := '50';
    
    elsIF TASK_STATE = '6' THEN
      TASKSTATE := '60';
    
    elsIF TASK_STATE = '7' THEN
      TASKSTATE := '70';
    
    elsIF TASK_STATE = '8' THEN
      TASKSTATE := '80';
    
    elsIF TASK_STATE = '9' THEN
      TASKSTATE := '90';
    END IF;
    RETURN TASKSTATE;
  END F_GET_TASK_STATE;
  --�˻�����
  FUNCTION F_GET_ACC_KIND(ACC_KIND IN VARCHAR2) RETURN VARCHAR2 IS
    ACCKIND VARCHAR2(2);
  BEGIN
    IF ACC_KIND = '0' THEN
      -- �˻����ࣨ00��ͨ�˻�01Ǯ���˻�02�ʽ��˻�03�����˻�04����ȯ�˻�05���������˻�06����ר���ʽ��˻�07��ֵ���˻�08�Ż�ȯ�˻���
      ACCKIND := '00';
    elsIF ACC_KIND = '1' THEN
      ACCKIND := '01';
    elsIF ACC_KIND = '2' THEN
      ACCKIND := '02';
    elsIF ACC_KIND = '3' THEN
      ACCKIND := '03';
    elsIF ACC_KIND = '4' THEN
      ACCKIND := '04';
    
    elsIF ACC_KIND = '5' THEN
      ACCKIND := '05';
    
    elsIF ACC_KIND = '6' THEN
      ACCKIND := '06';
    
    elsIF ACC_KIND = '7' THEN
      ACCKIND := '07';
    
    elsIF ACC_KIND = '8' THEN
      ACCKIND := '08';
    
    elsIF ACC_KIND = '9' THEN
      ACCKIND := '09';
    END IF;
  
    RETURN ACCKIND;
  END F_GET_ACC_KIND;

  --��ȡ����״ֵ̬
  FUNCTION F_GET_APPLY_STATE(APPLY_STATE IN VARCHAR2) RETURN VARCHAR2 IS
    APPLYSTATE VARCHAR2(2);
  BEGIN
    --����״̬0-������,1-���������� 2-�ƿ��� 3-���ƿ� 4-������ 5-�ѽ���  6-�ѷ��� 7-���˿� 9ע��
    IF APPLY_STATE = '0' THEN
      --����״̬00-������,10-���������ɣ�11-�ѷ�����ί��12-����ί��˲�ͨ��13-����ίͨ����14-�ѷ����У�15-���в�ͨ����16-������ͨ���� 20-�ƿ��У� 30-���ƿ� 40-������ 50-�ѽ���  60-�ѷ��� 70-���˿���80-�ѻ��� 90ע��)
      APPLYSTATE := '00';
    elsIF APPLY_STATE = '1' THEN
      APPLYSTATE := '01';
    elsIF APPLY_STATE = '2' THEN
      APPLYSTATE := '20';
    elsIF APPLY_STATE = '3' THEN
      APPLYSTATE := '30';
    elsIF APPLY_STATE = '4' THEN
      APPLYSTATE := '40';
    elsIF APPLY_STATE = '5' THEN
      APPLYSTATE := '50';
    elsIF APPLY_STATE = '6' THEN
      APPLYSTATE := '60';
    elsIF APPLY_STATE = '7' THEN
      APPLYSTATE := '70';
    elsIF APPLY_STATE = '9' THEN
      APPLYSTATE := '90';
    end if;
    RETURN APPLYSTATE;
  END F_GET_APPLY_STATE;
  --��ȡDealCodeֵ
  FUNCTION F_GETDEALCODE(TR_CODE IN VARCHAR2) RETURN NUMBER IS
    DEALCODE NUMBER;
  BEGIN
    --1120  ��������
    --1130  ��ģ����
    --1210  ��Ϣά��
    --1410  ʵ���ƿ����Ƿ���
    --1420  �����ƿ���ģ����
  
    --1340  ��Ʒ����������
    --1315  �ֻ���ͳһ֧��
    --1121  �������쳷��
    --1650  Ȧ����Ϣά��
    --1160  ���п�������
    --1840  ��λ/�̻�������������
    --1314  2.4G����ͨ
  
    --1510  Ԥ��ʧ
    --1520  ��ʧ
    --1530  ���
    --1540  ����
    --1560  ����
    --1570  ������ת��
    --1580  ����Ϣ��д�ָ�
    --1610  ע��
    --1620  ����
    --1710  �ۺϷ��������޸�
    --1720  �ۺϷ�����������
  
    --1760  ����֧����������
    --1780  �����˻����������޸�
    --1790  �����˻�������������
    --2110  �ѻ��˻��ֽ��ֵ
    --2130  �ѻ��˻�ת�˳�ֵ
    --2150  �����˻��ֽ��ֵ
  
    --5510  ��λת��λ
    --5520  ��λת����
    --5530  ����ת����
    --3140  �����˻���������
    --2722  �����˻����п�Ȧ��
    --2723  ���ĳ�ֵ
    --2111  �������
  
    --2178  �ѻ��˻�ת�����˻�
    --2270  ������
    --2280  ����ȡ��
    --2726  (����)�����˻�ת�ѻ��ʻ�
    --2820  �ѻ�����
    --2830  ��������
    --2834  �����˻�
    --3620  �̻�֧��
  
    --50101010  �����˻�����
    --50101020  �༭�˻�����
    --50101031  ɾ���˻�����
    --50201010  �����˻�����
    --50201021  �����˻�����
    --20401090  ���˷��ų���
    --20401060  ��ģ����
    --20401050  ���˷���
    --20403010  ����������
    --20403020  ����������
    --20403030  �������������
    --20401030  ��������
    --20401031  ��������Ԥ��
    --20401032  ��������Ԥ������
    --20401010  ��������
    --20402010  ���Ʒ������
    --20401020  �����֤����
    --20401040  ��������
    --20401070  �����ѯ
    --20401080  �������
    --10301010  ������������
    --10301020  ���������༭
    --10301030  �����������ͨ��
    --10301040  ����������˲�ͨ��
    --10301050  ��������ע��
    --10301060  ������������
    --10502010  �������
    --10502020  �������ȷ��
    --10502021  �������ȡ��
    --10502040  ��Ա�Ͻ�
    --40101010  �̻��ѻ�����
    --60101010  ��Ա����
    --60101020  ��������
  
    --40101022  �̻��ѻ����ѳ���
    --40101031  �̻������ѻ����ѳ���
    --40101042  �̻������ѻ����ѳ�������
    --40101051  �̻��ѻ������˻�
    --40101062  �̻��ѻ������˻�����
    --40101090  �̻��ѻ����ݶ���
  
    --40102010  ���������ѻ�����
    --40102022  ���������ѻ����ѳ���
    --40102031  ���������ѻ����ѳ���
    --40102042  ���������ѻ����ѳ�������
    --40102051  �������������˻�
    --40102062  �������������˻�����
    --40102090  ���������ѻ����ݶ���
  
    --40201010  �̻���������
    --40201022  �̻��������ѳ���
    --40201031  �̻��������ѳ���
    --40201042  �̻��������ѳ�������
    --40201051  �̻����������˻�
    --40201062  �̻����������˻�����
    --40201070  �̻��������ݶ���
  
    --40202010  ����������������
    --40202022  ���������������ѳ���
    --40202031  ���������������ѳ���
    --40202042  ���������������ѳ�������
    --40202051  �����������������˻�
    --40202062  �����������������˻�����
    --40202070  ���������������ݶ���
  
    --30101010  Ǯ���˻��ֽ��ֵ
    --30101011  Ǯ���˻���ֵ����
    --30101020  �ʽ����ֽ��ֵ
    --30101021  �ʽ��˻��ֽ��ֵ����
    --30101030  �ʽ��˻�ת�ʽ��˻�
    --30101040  �ʽ��˻�ת�ѻ��˻�
    --30901010  �Ҽ�¼ȷ��
    --30901011  �Ҽ�¼����
    --60601060  �Ҽ�¼ȷ��
    --60601061  �Ҽ�¼ȡ��
    --50501040  �˻�����
    --50501051  �˻��ⶳ
    --10101010  ��Ա������Ϣ����
    --10101020  ��Ա������Ϣ�༭
    --20501010  ����
    --20501020  ����
    --20501030  �Ǽ���������
    --20501040  ��ʧ
    --20501050  Ԥ��ʧ
    --20501060  ���
    --20501070  ע��
    --20501080  ����
    --20501090  ��ƬӦ������
    --20501100  ��ƬӦ�ý���
    --20502010  ������������
    --20502020  ���������޸�
    --20502030  ������������
    --20502040  ���������޸�
    --50801010  ��Ա����
    --50801020  ������
    --50801030  ������ȷ��
    --50301010  �����˻�״̬�ͽ�ֹ��������й���
    --50301020  �༭�˻�״̬�ͽ�ֹ��������й���
    --50301031  ɾ���˻�״̬�ͽ�ֹ��������й���
    --50301040  �����˻�״̬�ͽ�ֹ��������й���
    --50301051  �����˻�״̬�ͽ�ֹ��������й���
    --20201050  ����ɾ��
    --20201030  ��������
    --20201040  �����ѯ
    --30101070  ����תǮ��
    --20501140  ��ֵ�����۳���
    --20501130  ��ֵ����������
    --20501120  ��ֵ����������
    --20501110  ��ֵ����������
    --20501150  ��ֵ�����ۻؿ�
    --50501070  ��λ����
  
    --30601010  ��λ�˻���ֵ
    --30601020  ��λ������ֵ
    --50401010  �����˻������޶���Ϣ
    --50401020  �༭�˻������޶���Ϣ
    --50401031  ɾ���˻������޶���Ϣ
    --50401040  �����˻������޶���Ϣ
    --50401051  �����˻������޶���Ϣ
    --50501011  �˻�����
    --50501020  �˻�����
    --50501030  �˻�����
    --30301010  �����������п�������
    --30301020  �����������п���Ǯ��
    --30301012  �����������п�����������
    --30301022  �����������п����ѻ�����
  
    IF TR_CODE IS NULL THEN
      DEALCODE := 0;
    elsIF TR_CODE = '1120' THEN
      --��������
      DEALCODE := 20401010;
    elsIF TR_CODE = '1130' THEN
      -- ��ģ����
      DEALCODE := 20401030;
    elsIF TR_CODE = '1210' THEN
      -- ��Ϣά��
      DEALCODE := 10101010;
    elsIF TR_CODE = '1410' THEN
      -- ʵ���ƿ����Ƿ���
      DEALCODE := 20401050;
    elsIF TR_CODE = '1420' THEN
      --�����ƿ���ģ����
      DEALCODE := 20401060;
    elsIF TR_CODE = '1510' THEN
      -- 1510  Ԥ��ʧ
      DEALCODE := 20501050;
    elsIF TR_CODE = '1520' THEN
      -- 1520  ��ʧ
      DEALCODE := 20501040;
    elsIF TR_CODE = '1530' THEN
      -- 1530  ���
      DEALCODE := 20501060;
    elsIF TR_CODE = '1540' THEN
      -- 1540  ����
      DEALCODE := 20501020;
    elsIF TR_CODE = '1560' THEN
      -- 1560  ����
      DEALCODE := 20501010;
    elsIF TR_CODE = '1570' THEN
      -- 1570  ������ת��
      DEALCODE := 30101070;
    elsIF TR_CODE = '1580' THEN
      -- 1580  ����Ϣ��д�ָ�
      DEALCODE := 90409090;
    elsIF TR_CODE = '1610' THEN
      -- 1610  ע��
      DEALCODE := 20501070;
    elsIF TR_CODE = '1620' THEN
      -- 1620  ����
      DEALCODE := 20501080;
    elsIF TR_CODE = '1710' THEN
      -- 1710  �ۺϷ��������޸�
      DEALCODE := 20502020;
    elsIF TR_CODE = '1720' THEN
      -- 1720  �ۺϷ�����������
      DEALCODE := 20502010;
    elsIF TR_CODE = '1110' THEN
      -- 1760  ����֧����������
      DEALCODE := 20502030;
    elsIF TR_CODE = '1780' THEN
      -- 1780  �����˻����������޸�
      DEALCODE := 20502040;
    elsIF TR_CODE = '1790' THEN
      -- 1790  �����˻�������������
      DEALCODE := 20502030;
    elsIF TR_CODE = '2110' THEN
      -- 2110  �ѻ��˻��ֽ��ֵ
      DEALCODE := 30101010;
    elsIF TR_CODE = '2130' THEN
      -- 2130  �ѻ��˻�ת�˳�ֵ
      DEALCODE := 30101040;
    elsIF TR_CODE = '2150' THEN
      -- 2150  �����˻��ֽ��ֵ
      DEALCODE := 30101020;
    elsIF TR_CODE = '5510' THEN
      -- 5510  ��λת��λ
      DEALCODE := 30601010;
    elsIF TR_CODE = '5520' THEN
      -- 5520  ��λת����
      DEALCODE := 30106020;
    elsIF TR_CODE = '5530' THEN
      -- 5530  ����ת����
      DEALCODE := 30101030;
    elsIF TR_CODE = '1160' THEN
      -- 1160  ���п�������
      DEALCODE := 20901010;
    elsIF TR_CODE = '1840' THEN
      -- 1840  ��λ/�̻�������������
      DEALCODE := 20502060;
    elsIF TR_CODE = '1314' THEN
      -- 1314  2.4G����ͨ
      DEALCODE := 20901020;
    elsIF TR_CODE = '3140' THEN
      -- 3140  �����˻���������
      DEALCODE := 50201010;
    elsIF TR_CODE = '1340' THEN
      -- 1340  ��Ʒ����������
      DEALCODE := 20501130;
    elsIF TR_CODE = '1315' THEN
      -- 1315  �ֻ���ͳһ֧��
      DEALCODE := 20901030;
    elsIF TR_CODE = '1121' THEN
      -- 1121  �������쳷��
      DEALCODE := 20401080;
    elsIF TR_CODE = '1650' THEN
      -- 1650  Ȧ����Ϣά��
      DEALCODE := 20901040;
    elsIF TR_CODE = '2722' THEN
      -- 2722  �����˻����п�Ȧ��
      DEALCODE := 30302020;
    elsIF TR_CODE = '2723' THEN
      -- 2723  ���ĳ�ֵ
      DEALCODE := 90409040;
    elsIF TR_CODE = '2178' THEN
      -- 2178  �ѻ��˻�ת�����˻�
      DEALCODE := 30101050;
    elsIF TR_CODE = '2270' THEN
      -- 2270  ������
      DEALCODE := 50801020;
    elsIF TR_CODE = '2280' THEN
      -- 2280  ����ȡ��
      DEALCODE := 50801030;
    elsIF TR_CODE = '2726' THEN
      -- 2726  (����)�����˻�ת�ѻ��ʻ�
      DEALCODE := 30101040;
    elsIF TR_CODE = '2820' THEN
      -- 2820  �ѻ�����
      DEALCODE := 40101010;
    elsIF TR_CODE = '2830' THEN
      -- 2830  ��������
      DEALCODE := 40201010;
    elsIF TR_CODE = '2834' THEN
      -- 2834  �����˻�
      DEALCODE := 40201051;
    elsIF TR_CODE = '3620' THEN
      -- 3620  �̻�֧��
      DEALCODE := 60301020;
    END IF;
    RETURN DEALCODE;
  
  END F_GETDEALCODE;

  -- Author  : gecc
  -- Created : 2015/11/192 19:41:21
  -- Purpose : ȡ�������ݵ�һ��ͨϵͳ
  PROCEDURE P_GET_BASEINFO IS
    DEALTIME VARCHAR2(10); --����ʱ��
    PC       VARCHAR2(2000);
    V_SQLERR VARCHAR2(1000);
  BEGIN
    DEALTIME := TO_CHAR(SYSDATE - 1, 'yyyy-MM-dd');
    BEGIN
      PC := '��1����ɻ������ݴ�����ǰʱ�䣺' ||
            TO_CHAR(SYSDATE, 'YYYY-MM-DD hh24:mi:ss');
    
      --1��������Ϣ
    
      INSERT INTO BASE_COMM
        (COMM_ID, COMM_NAME, TOWN_ID, COMM_STATE)
        SELECT T1.COMM_ID, T1.COMM_NAME, T1.TOWN_ID, T1.COMM_STATE
          FROM ONECARD_JX.BS_COMM@ONECARD_DB1 T1;
    
      --2��������Ϣ
    
      INSERT INTO BASE_TOWN
        (TOWN_ID, TOWN_NAME, REGION_ID, TOWN_STATE)
        SELECT T2.TOWN_ID, T2.TOWN_NAME, T2.REGION_ID, T2.TOWN_STATE
          FROM ONECARD_JX.BS_TOWN@ONECARD_DB1 T2;
      --3��������Ϣ
      INSERT INTO BASE_REGION
        (REGION_ID,
         REGION_NAME,
         CITY_ID,
         REGION_STATE,
         CARD_FLAG,
         REGION_CODE,
         NOTE)
        SELECT REGION_ID,
               REGION_NAME,
               CITY_ID,
               REGION_STATE,
               CARD_FLAG,
               REGION_CODE,
               NOTE
          FROM ONECARD_JX.BS_REGION@ONECARD_DB1 T3;
      --4��������Ϣ
      INSERT INTO BASE_CITY
        (CITY_ID, CITY_NAME, CITY_TYPE, PCITY_ID, CITY_DESC)
        SELECT CITY_ID, CITY_NAME, CITY_TYPE, PCITY_ID, CITY_DESC
          FROM ONECARD_JX.BS_CITY@ONECARD_DB1 T4;
      --5����λ��Ϣ
      INSERT INTO BASE_CORP
        (CUSTOMER_ID,
         CORP_NAME,
         ABBR_NAME,
         CORP_TYPE,
         ADDRESS,
         POST_CODE,
         CONTACT,
         CON_PHONE,
         CEO_NAME,
         CEO_PHONE,
         LEG_NAME,
         CERT_TYPE,
         CERT_NO,
         LEG_PHONE,
         FAX_NO,
         EMAIL,
         PROV_CODE,
         CITY_CODE,
         SERV_PWD,
         SERV_PWD_ERR_NUM,
         NET_PWD,
         NET_PWD_ERR_NUM,
         OPEN_DATE,
         OPEN_USER_ID,
         CLS_USER_ID,
         CLS_DATE,
         LICENSE_NO,
         REGION_ID,
         AREA_CODE,
         P_CUSTOMER_ID,
         COMPANYID,
         CARREF_FLAG,
         CHK_FLAG,
         CHK_DATE,
         CHK_USER_ID,
         NOTE,
         CORP_STATE)
      
        SELECT T5.CLIENT_ID,
               T5.EMP_NAME,
               ABBR_NAME,
               T5.EMP_TYPE,
               ADDRESS,
               POST_CODE,
               CONTACT,
               T5.C_TEL_NO,
               CEO_NAME,
               T5.CEO_TEL_NO,
               LEG_NAME,
               CERT_TYPE,
               CERT_NO,
               T5.LEG_TEL_NO,
               FAX_NO,
               EMAIL,
               PROV_CODE,
               CITY_CODE,
               SERV_PWD,
               0,
               '',
               0,
               OPEN_DATE,
               CLS_OPER_ID,
               T5.CLS_OPER_ID,
               CLS_DATE,
               '',
               REGION_ID,
               T5.CITY_CODE,
               T5.MNG_OPER_ID,
               COMPANYID,
               '1',
               decode(t5.emp_state, '0', '0', '1'),
               sysdate,
               T5.CLS_OPER_ID,
               NOTE,
               T5.EMP_STATE
          FROM ONECARD_JX.BS_EMPLOYER@ONECARD_DB1 T5
         WHERE 1 = 1
           AND NOT EXISTS
         (SELECT 1 FROM BASE_CORP P WHERE P.CUSTOMER_ID = T5.CLIENT_ID);
      commit;
      --���µ�λ����
      update BASE_CORP p
         set p.serv_pwd         = encrypt_des_oracle(decode(p.serv_pwd,
                                                      '',
                                                      '123456'),
                                               p.customer_id),
             p.serv_pwd_err_num = 0;
      commit;
      --6���ն���Ϣ
    
      INSERT INTO BASE_TAG_END
        (END_ID,
         END_NAME,
         END_TYPE,
         USAGE,
         END_SRC,
         MODEL,
         DEV_NO,
         PSAM_NO,
         SIM_NO,
         ORG_ID, --10
         ACPT_TYPE,
         OWN_ID,
         LOGIN_FLAG,
         USER_ID,
         LOGIN_TIME,
         LAST_TIME,
         ROLE_ID,
         MNG_USER_ID,
         PRODUCER,
         STANDBY_DATE, --20
         CONTRACT_NO,
         BUY_DATE,
         PRICE,
         CLS_DATE,
         NOTE)
      
        SELECT T6.TERM_ID,
               T6.TERM_ID,
               T6.TERM_TYPE,
               '1',
               '1',
               T6.TERM_MODEL,
               DEV_NO,
               PSAM_NO,
               ORG_ID,
               ORG_ID, --10
               ACPT_TYPE,
               OWN_ID,
               LOGIN_FLAG,
               OPER_ID,
               LOGIN_TIME,
               T6.Login_Time,
               ROLE_ID,
               T6.MNG_OPER_ID,
               PRODUCER,
               STANDBY_DATE,
               T6.CONTACT_NO,
               BUY_DATE,
               PRICE,
               CLS_DATE,
               NOTE
        
          FROM ONECARD_JX.BS_TERMINAL@ONECARD_DB1 T6
         WHERE 1 = 1
           AND NOT EXISTS
         (SELECT 1 FROM BASE_TAG_END D WHERE D.END_ID = T6.TERM_ID);
      --COMMIT;
      INSERT INTO BASE_MERCHANT
        (CUSTOMER_ID,
         ORG_ID,
         MERCHANT_ID,
         MERCHANT_NAME,
         ABBR_NAME,
         MERCHANT_TYPE,
         TOP_MERCHANT_ID,
         INDUS_CODE,
         ADDRESS,
         POST_CODE,
         CONTACT,
         CON_PHONE,
         CON_CERT_TYPE,
         CON_CERT_NO,
         LEG_NAME,
         LEG_PHONE,
         LEG_CERT_TYPE,
         LEG_CERT_NO,
         PHONE_NO,
         FAX_NUM,
         EMAIL,
         HOTLINE,
         TAX_REG_NO,
         BIZ_REG_NO,
         BANK_ID,
         BANK_BRCH,
         BANK_ACC_NAME,
         BANK_ACC_NO,
         PROV_CODE,
         CITY_CODE,
         SIGN_DATE,
         SIGN_USER_ID,
         CONTACT_NO,
         CONTACT_TYPE,
         BILL_ADDR,
         BILL_ADDR_POSTCODE,
         STL_TYPE,
         P_KEY,
         DIV_ID,
         SERV_PWD,
         SERV_PWD_ERR_NUM,
         NET_PWD,
         NET_PWD_ERR_NUM,
         MERCHANT_STATE,
         NOTE)
        SELECT TM.CLIENT_ID,
               TM.ORG_ID,
               TM.BIZ_ID,
               TM.BIZ_NAME,
               TM.BIZ_NAME,
               TM.BIZ_TYPE,
               TM.TOP_BIZ_ID,
               TM.INDUS_CODE,
               ADDRESS,
               POST_CODE,
               CONTACT,
               C_TEL_NO,
               '',
               CEO_TEL_NO,
               LEG_NAME,
               '',
               '',
               '',
               '',
               FAX_NUM,
               EMAIL,
               '',
               TM.TAX_REG_NO,
               TM.BIZ_REG_NO,
               F_GETBANK_NO(TM.BANK_ID),
               TM.BANK_BRCH,
               TM.ACC_NAME,
               TM.ACC_NO,
               TM.PROV_CODE,
               TM.CITY_CODE,
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               TM.SERV_PWD,
               0,
               '',
               0,
               TM.BIZ_STATE,
               NOTE
          FROM ONECARD_JX.BS_MERCHANT@ONECARD_DB1 TM;
      COMMIT;
      --�����̻�����
    
      update BASE_MERCHANT mt
         set mt.serv_pwd         = encrypt_des_oracle(decode(mt.serv_pwd,
                                                       '',
                                                       '123456',
                                                       mt.serv_pwd),
                                                mt.customer_id),
             mt.serv_pwd_err_num = 0;
      commit;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PC := SUBSTR('���쳣:' || V_SQLERR || '��' || PC, 1, 255);
        INSERT INTO SYS_ERR_LOG
          (ERR_NO, USER_ID, MESSAGE, ERR_TIME, IP, ERR_TYPE)
        VALUES
          (SEQ_ERR_NO.NEXTVAL, 'admin', PC, DEALTIME, 'localhost', 1);
        COMMIT;
      
    END;
  END P_GET_BASEINFO;

  --CM_CARD ����
  PROCEDURE P_CARD_INFO IS
    LN_COUNT NUMBER;
    LN_NUM   NUMBER;
  BEGIN
    LN_NUM := 0;
    /*    FOR CC IN (SELECT *
                 FROM ONECARD_JX.CM_CARD@ONECARD_DB1 CC
                WHERE NOT EXISTS (SELECT 1
                         FROM CARD_BASEINFO C
                        WHERE C.CARD_NO = CC.CARD_NO)) LOOP
      SELECT COUNT(*)
        INTO LN_COUNT
        FROM CARD_BASEINFO CB
       WHERE CARD_NO = CC.CARD_NO;
      IF LN_COUNT = 0 THEN
        INSERT \*+ APPEND *\
        INTO CARD_BASEINFO
          (CARD_ID,
           CARD_NO,
           CUSTOMER_ID,
           CARD_TYPE,
           ISSUE_ORG_ID,
           VERSION,
           INIT_ORG_ID,
           CITY_CODE,
           INDUS_CODE,
           ISSUE_DATE,
           START_DATE,
           VALID_DATE,
           APP1_VALID_DATE,
           APP2_VALID_DATE,
           PAY_PWD,
           PAY_PWD_ERR_NUM,
           NET_PAY_PWD,
           NET_PAY_PWD_ERR_NUM,
           CARD_STATE,
           LAST_MODIFY_DATE,
           COST_FEE,
           FOREGIFT,
           FOREGIFT_BAL,
           RENT_FOREGIFT,
           SUB_CARD_ID,
           SUB_CARD_NO,
           SUB_CARD_TYPE,
           BANK_ID,
           BANK_CARD_NO,
           BAR_CODE,
           CANCEL_DATE,
           CANCEL_REASON,
           NOTE,
           FOREGIFT_DATE,
           ATR,
           RFATR,
           MOBILE_PHONE,
           MAIN_FLAG,
           MAIN_CARD_NO,
           BUS_TYPE,
           BUS_USE_FLAG,
           MONTH_TYPE,
           MONTH_CHARGE_MODE,
           PRO_ORG_CODE,
           PRO_MEDIA_TYPE,
           PRO_VERSION,
           PRO_INIT_DATE,
           RECOVER_FLAG,
           VIP_CLASS)
        VALUES
          (CC.CARD_ID,
           CC.CARD_NO,
           CC.CLIENT_ID,
           CC.CARD_TYPE,
           '',
           CC.VERSION,
           CC.ORG_CODE,
           CC.CITY_CODE,
           CC.IND_CODE,
           CC.ISSUE_DATE,
           CC.START_DATE,
           CC.VALID_DATE,
           CC.APP1_VALID_DATE,
           CC.APP2_VALID_DATE,
           '',
           0,
           '',
           0,
           CC.CARD_STATE,
           CC.LAST_MODI_DATE,
           CC.COST_FEE,
           CC.FOREGIFT,
           CC.FOREGIFT_BAL,
           CC.RENT_FOREGIFT,
           CC.SUB_CARD_ID,
           CC.SUB_CARD_NO,
           CC.SUB_CARD_TYPE,
           CC.BANK_ID,
           CC.BANK_CARD_NO,
           CC.BAR_CODE,
           CC.CANCEL_DATE,
           CC.CANCEL_REASON,
           CC.NOTE,
           CC.FOREGIFT_DATE,
           CC.ATR,
           CC.RFATR,
           CC.TEL_NO,
           CC.ISPARENT,
           CC.PARENT_CARD_NO,
           CC.BUS_TYPE,
           CC.BUS_USE_FLAG,
           CC.MONTH_TYPE,
           CC.MONTH_CHARGE_MODE,
           CC.PRO_ORG_CODE,
           CC.PRO_MEDIA_TYPE,
           CC.PRO_VERSION,
           CC.PRO_INIT_DATE,
           '0',
           '0');
        LN_NUM := LN_NUM + 1;
      END IF;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;*/
  
    -- COMMIT;
    --����֧������
    /*UPDATE   CARD_BASEINFO D SET D.PAY_PWD=(SELECT P.PWD FROM ONECARD_JX.CM_PWD P WHERE P.PWD_NO=D.CARD_NO) WHERE D.CARD_NO*/
  
    FOR bc IN (SELECT * FROM ONECARD_JX.Cm_Card_Bank_Ok@ONECARD_DB1 bc) LOOP
      insert into card_bind_bankcard
        (customer_id,
         name,
         cert_no,
         sub_card_no,
         bank_id,
         bank_card_no,
         bank_card_type,
         state,
         mobile_num,
         region_id,
         city_id,
         town_id,
         address,
         user_id,
         brch_id,
         bank_org,
         activate_date,
         modify_date,
         line_no,
         sub_card_id,
         bind_date,
         bank_activate_state)
      values
        (bc.client_id,
         bc.name,
         bc.cert_no,
         bc.sub_card_no,
         bc.bank_id,
         bc.bank_card_no,
         bc.bank_card_type,
         bc.bd_state,
         bc.mobile_no,
         bc.province,
         bc.city,
         bc.town,
         bc.address,
         bc.oper_id,
         bc.brch_id,
         bc.bank_org,
         bc.jh_date,
         bc.zjxg_date,
         bc.line_no,
         bc.sub_card_id,
         bc.bd_date,
         '00');
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    commit;
    --���п������Ϣ
    /*insert into card_unbind_bankcard
      (name,
       cert_no,
       sub_card_id,
       sub_card_no,
       bank_id,
       bank_card_no,
       bank_card_type,
       oper_id,
       unbind_date,
       receipt,
       line_no)
      select jb.name,
             jb.cert_no,
             jb.sub_card_id,
             jb.sub_card_no,
             jb.bank_id,
             jb.bank_card_no,
             jb.bank_card_type,
             jb.oper_id,
             jb.jb_date,
             jb.huiz,
             jb.line_no
        from onecard_jx.cm_card_bank_jb@ONECARD_DB1 jb;*\
    commit;*/
  END P_CARD_INFO;
  ----------------��ȡ��Ա��Ϣ----------------
  PROCEDURE P_PERSON_INFO IS
    LN_COUNT NUMBER;
    LN_NUM   NUMBER;
  BEGIN
    LN_NUM := 0;
    FOR S IN (SELECT *  FROM TR_CONSUME_HIS S  WHERE S.CLR_DATE >= '2015-01-01') LOOP
      INSERT INTO PAY_OFFLINE_LIST_HIS
  (END_DEAL_NO,
   ACPT_ID,
   END_ID,
   CARD_NO,
   CARD_IN_TYPE,
   CARD_IN_SUBTYPE,
   CARD_VALID_DATE,
   CARD_START_DATE,
   APP_VALID_DATE,
   CARD_DEAL_COUNT,
   PSAM_DEAL_NO,
   ACC_BAL,
   DEAL_AMT,
   DEAL_DATE,
   DEAL_KIND,
   PSAM_NO,
   TAC,
   ASH_FLAG,
   CREDIT_LIMIT,
   DEAL_BATCH_NO,
   SEND_FILE_NAME,
   FILE_LINE_NO,
   SEND_DATE,
   DEAL_NO,
   DEAL_CODE,
   DEAL_STATE,
   CLR_DATE,
   REFUSE_REASON,
   ORG_ID,
   CANCEL_DEAL_BATCH_ID,
   CANCEL_END_DEAL_NO,
   POINTS)
  VALUES(S.TR_SER_NO,
         S.ACPT_ID,
         S.TERM_ID,
         S.CARD_NO,
         S.CARD_IN_TYPE,
         S.CARD_IN_SUBTYPE,
         S.CARD_VALID_DATE,
         S.CARD_START_DATE,
         S.APP_VALID_DATE,
         S.CARD_TR_COUNT,
         S.PSAM_TR_NO,
         S.ACC_BAL,
         S.TR_AMT,
         S.TR_DATE,
         S.TR_KIND,
         S.PSAM_NO,
         S.TAC,
         S.REC_TYPE,
         0,
         S.TR_BATCH_NO,
         S.SEND_FILE_NAME,
         S.FILE_LINE_NO,
         S.SEND_DATE,
         S.ACTION_NO,
         '40101010',
         S.REC_TYPE,
         S.CLR_DATE,
         S.REFUSE_REASON,
         S.ORG_ID,
         S.CANCEL_TR_BATCH_ID,
         S.CANCEL_TERM_SER_NO,
         '');

/*      INSERT INTO BASE_PERSONAL
        (CUSTOMER_ID,
         NAME,
         CERT_TYPE,
         CERT_NO,
         BIRTHDAY,
         GENDER,
         NATION,
         COUNTRY,
         RESIDE_TYPE,
         CITY_ID,
         REGION_ID,
         TOWN_ID,
         COMM_ID,
         RESIDE_ADDR,
         LETTER_ADDR,
         POST_CODE,
         PHONE_NO,
         MOBILE_NO,
         EMAIL,
         CORP_CUSTOMER_ID,
         EDUCATION,
         MARR_STATE,
         CAREER,
         INCOME,
         CUSTOMER_STATE,
         SERV_PWD,
         SERV_PWD_ERR_NUM,
         NET_PWD,
         NET_PWD_ERR_NUM,
         OPEN_USER_ID,
         OPEN_DATE,
         CLS_USER_ID,
         CLS_DATE,
         DATA_SRC,
         SURE_FLAG,
         MNG_USER_ID,
         DEPARTMENT,
         CLASSID,
         DATACENTER_ID,
         SMS_FLAG)
      VALUES
        (TP.CLIENT_ID,
         TP.NAME,
         TP.CERT_TYPE,
         TP.CERT_NO,
         TP.BIRTHDAY,
         TP.SEX,
         TP.NATION,
         TP.COUNTRY,
         TP.RESIDE_TYPE,
         TP.CITY_ID,
         TP.REGION_ID,
         TP.TOWN_ID,
         TP. COMM_ID,
         TP.RESIDE_ADDR,
         TP.LETTER_ADDR,
         TP.POST_CODE,
         TP.TEL_NO,
         TP.MOBILE_NO,
         TP.EMAIL,
         TP.EMP_CLIENT_ID,
         TP.EDUCATION,
         TP.MARR_STATE,
         TP.CAREER,
         TP.INCOME,
         TP.CLIENT_STATE,
         '',
         0,
         '',
         0,
         TP.CLS_OPER_ID,
         TP.OPEN_DATE,
         '',
         '',
         '0',
         '0',
         TP.CLS_OPER_ID,
         '',
         '',
         TP.JHZXGRBH,
         '1');*/
    
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    COMMIT;
    /*  LN_NUM := 0;
    -----�����籣��Ϣ------------------------
    FOR S IN (SELECT *
                FROM ONECARD_JX.EX_SIINFO@ONECARD_DB1 E
               WHERE 1 = 1
                 AND NOT EXISTS
               (SELECT 1
                        FROM BASE_SIINFO F
                       WHERE F.CUSTOMER_ID = E.CLIENT_ID
                         AND F.PERSONAL_ID = E.PERSONAL_ID)) LOOP
      ---_273056 *\
      -----�����籣��Ϣ------------------------
    
      SELECT COUNT(*)
        INTO LN_COUNT
        FROM BASE_SIINFO
       WHERE CERT_NO = S.CERT_NO;
      IF LN_COUNT = 0 THEN
      
        INSERT INTO BASE_SIINFO
          (PERSONAL_ID,
           COMPANY_ID,
           CUSTOMER_ID,
           NAME,
           CERT_TYPE,
           CERT_NO,
           BIRTHDAY,
           ENDOW_STATE,
           MED_STATE,
           INJURY_STATE,
           BEAR_STATE,
           UNEMP_STATE,
           MED_CERT_NO,
           MED_WHOLE_NO,
           RESERVE_1,
           RESERVE_2,
           RESERVE_3,
           RESERVE_4,
           RESERVE_5,
           RESERVE_6,
           RESERVE_7,
           RESERVE_8,
           RESERVE_9,
           RESERVE_10,
           RESERVE_11,
           RESERVE_12,
           RESERVE_13,
           RESERVE_14,
           RESERVE_15,
           RESERVE_16,
           RESERVE_17,
           RESERVE_18,
           RESERVE_19,
           RESERVE_20)
        VALUES
          (S.PERSONAL_ID,
           S.COMPANY_ID,
           S.CLIENT_ID,
           S.NAME,
           S.CERT_TYPE,
           S.CERT_NO,
           S.BIRTHDAY,
           S.ENDOW_STATE,
           S.MED_STATE,
           S.INJURY_STATE,
           S.BEAR_STATE,
           S.UNEMP_STATE,
           S.MED_CERT_NO,
           S.MED_WHOLE_NO,
           S.RESERVE_1,
           S.RESERVE_2,
           S.RESERVE_3,
           S.RESERVE_4,
           S.RESERVE_5,
           S.RESERVE_6,
           S.RESERVE_7,
           S.RESERVE_8,
           S.RESERVE_9,
           S.RESERVE_10,
           S.RESERVE_11,
           S.RESERVE_12,
           S.RESERVE_13,
           S.RESERVE_14,
           S.RESERVE_15,
           S.RESERVE_16,
           S.RESERVE_17,
           S.RESERVE_18,
           S.RESERVE_19,
           S.RESERVE_20);
        LN_NUM := LN_NUM + 1;
      END IF;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    COMMIT;*/
    --������Ա��������
  
   /* for i in 1 .. 100 loop
      update base_personal l
         set l.serv_pwd         = encrypt_des_oracle(decode(l.serv_pwd,
                                                      '',
                                                      '123456',
                                                      l.serv_pwd),
                                               l.cert_no),
             l.serv_pwd_err_num = 0
       where rownum <= 50000
         and l.serv_pwd is null;
      COMMIT;
      update base_personal ll
         set ll.pinying = fn_getpy(ll.name, 1)
       where rownum <= 50000
         and ll.pinying is null;
      COMMIT;
    end loop;*/
  
    /*    ------------��Ƭ��Ϣ-------------
       FOR TP IN (SELECT TP.CLIENT_ID  FROM ONECARD_JX.EX_PHOTO@ONECARD_DB1 TP where 1=1 and  not exists (select o.customer_id from base_PHOTO o where o.customer_id=tp.client_id) order by tp.client_id ASC ) LOOP
         select count(*) INTO LN_COUNT from base_PHOTO b where b.customer_id=tp.client_id;
         if LN_COUNT=0 then
          INSERT INTO base_PHOTO
            (customer_id, PHOTO, PHOTO_STATE)
             select x.CLIENT_ID, x.PHOTO, x.PHOTO_STATE from EX_PHOTO  x where x.client_id=tp.client_id;
           end if;
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 500 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    
    COMMIT;*/
  
  END P_PERSON_INFO;

  ----��ȡҵ������
  PROCEDURE P_TR_SERV_REC IS
    LN_NUM NUMBER;
  BEGIN
    FOR LV IN (SELECT *
                 FROM ONECARD_JX.TR_SERV_REC@ONECARD_DB1 LV
                WHERE 1 = 1
                  AND NOT EXISTS
                (SELECT 1
                         FROM TR_SERV_REC R
                        WHERE R.DEAL_NO = LV.ACTION_NO)) LOOP
      INSERT INTO TR_SERV_REC
        (DEAL_NO,
         DEAL_CODE,
         CUSTOMER_ID,
         CARD_ID,
         CARD_NO,
         CARD_TYPE,
         CARD_AMT,
         ACC_NO,
         SUB_ACC_NO,
         CUSTOMER_NAME, --10
         CERT_TYPE,
         CERT_NO,
         TEL_NO,
         AGT_NAME,
         AGT_TEL_NO,
         AGT_CERT_TYPE,
         AGT_CERT_NO,
         BIZ_TIME,
         BRCH_ID,
         USER_ID, --20
         GRT_USER_ID,
         GRT_USER_NAME,
         CANCEL_REASON,
         RTN_FGFT,
         CHG_CARD_REASON,
         OLD_CARD_ID,
         OLD_CARD_NO,
         BAL_RTN_WAY,
         BAL_RTN_AMT,
         IN_CARD_NO, --30
         IN_ACC_NO,
         IN_ACC_SUB_NO,
         OLD_PWD,
         NEW_PWD,
         CLR_DATE,
         DEAL_STATE,
         NOTE,
         URGENT_FEE,
         COST_FEE,
         RSV_ONE, --40
         RSV_TWO,
         RSV_THREE,
         RSV_FOUR,
         RSV_FIVE)
      VALUES
        (LV.ACTION_NO,
         F_GETDEALCODE(LV.TR_CODE),
         LV.CLIENT_ID,
         LV.CARD_ID,
         LV.CARD_NO,
         LV.CARD_TYPE,
         LV.CARD_AMT,
         LV.ACC_NO,
         LV.SUB_ACC_NO,
         LV.CLIENT_NAME, --10
         LV.CERT_TYPE,
         LV.CERT_NO,
         LV.TEL_NO,
         LV.AGT_NAME,
         LV.AGT_TEL_NO,
         LV.AGT_CERT_TYPE,
         LV.AGT_CERT_NO,
         LV.BIZ_TIME,
         LV.BRCH_ID,
         LV.OPER_ID, --20
         LV.GRT_OPER_ID,
         LV.GRT_OPER_NAME,
         LV.CANCEL_REASON,
         LV.RTN_FGFT,
         LV.CHG_CARD_REASON,
         LV.OLD_CARD_ID,
         LV.OLD_CARD_NO,
         LV.BAL_RTN_WAY,
         LV.BAL_RTN_AMT,
         LV.IN_CARD_NO, --30
         LV.IN_ACC_NO,
         LV.IN_ACC_SUB_NO,
         LV.OLD_PWD,
         LV.NEW_PWD,
         LV.CLR_DATE,
         LV.TR_STATE,
         LV.NOTE,
         LV.URGENT_FEE,
         LV.COST_FEE,
         LV.RSV_ONE, --40
         LV.RSV_TWO,
         LV.RSV_THREE,
         LV.RSV_FOUR,
         LV.RSV_FIVE);
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    COMMIT;
    /* --��־��Ϣ
    INSERT INTO SYS_ACTION_LOG
      (DEAL_NO,
       DEAL_CODE,
       USER_ID,
       DEAL_TIME,
       LOG_TYPE,
       FUNC_URL,
       FUNC_NAME,
       MESSAGE,
       IP,
       IN_OUT_DATA,
       CAN_ROLL,
       ROLL_FLAG,
       OTHER,
       NOTE)
      SELECT ACTION_NO,
             F_GETDEALCODE(TR_CODE),
             OPER_ID,
             G.OPER_TIME,
             LOG_TYPE,
             FUNC_URL,
             FUNC_NAME,
             MESSAGE,
             IP,
             G.IN_OUT_DATA,
             CAN_ROLL,
             ROLL_FLAG,
             OTHER,
             NOTE
      
        FROM ONECARD_JX.SYS_ACTION_LOG@ONECARD_DB1 G
       WHERE 1 = 1
         AND NOT EXISTS
       (SELECT 1 FROM SYS_ACTION_LOG A WHERE G.ACTION_NO = A.DEAL_NO)
         AND TO_CHAR(G.OPER_TIME, 'YYYY-MM') >= '2016-01';
    commit;*/
  
  END P_TR_SERV_REC;

  ----��ȡ�˻���ˮҵ������--starttime 201001,endtime--201612��ʽ
  PROCEDURE P_ACC_DAYBOOK(starttime in varchar2, endtime in varchar2) IS
    LN_NUM     NUMBER;
    countnum   NUMBER;
    monthsstr  varchar2(6);
    monthS     varchar2(15);
    date1      varchar2(35);
    date2      varchar2(35);
    lv_sysdate DATE;
    inertSQL   varchar2(2000);
    rechageSQL varchar2(2000);
    consumeSQL varchar2(2000);
  BEGIN
    LN_NUM     := 0;
    inertSQL   := '';
    rechageSQL := ''; ---��ֵ��SQL
    consumeSQL := ''; ---���ѵ�SQL  
    lv_sysdate := nvl(to_date(to_char(starttime), 'yyyy-MM'), SYSDATE);
    -------������ڵ�֮���·ݸ���
    select abs(months_between(to_date(starttime || '01', 'yyyymmdd'),
                              to_date(endtime || '01', 'yyyymmdd'))) as months
      into countnum
      from dual;
    --�·�ѭ��
    FOR i IN 0 .. countnum - 1 LOOP
      monthsstr := to_char(add_months(trunc(lv_sysdate, 'mm'), i), 'yyyymm');
      monthS    := to_char(add_months(trunc(lv_sysdate, 'mm'), i),
                           'yyyy-mm');
      date1     := monthS || '-01';
      date2     := monthS || '-31';
    
      FOR T1 IN (SELECT *
                   FROM ONECARD_JX.ACC_DAYBOOK_HIS@ONECARD_DB1 TT
                  WHERE TT.CLR_DATE BETWEEN date1 AND date2) LOOP
        inertSQL := '';
        inertSQL := ' INSERT INTO ACC_INOUT_DETAIL_' || monthsstr;
        inertSQL := inertSQL ||
                    '(ACC_INOUT_NO,DEAL_CODE,CARD_ORG_ID,ACPT_ORG_ID,ACPT_ID,  USER_ID,  DEAL_DATE, REV_TIME,   DB_ITEM_ID, DB_ACC_NO,  DB_CARD_NO,  DB_ACC_BAL,   DB_AMT, DB_CARD_BAL,  CR_ACC_NO,  CR_CARD_NO, CR_ACC_BAL, CR_AMT,  DEAL_STATE, DEAL_NO, INSERT_TIME,  NOTE,  CLR_DATE,  CR_ITEM_ID) VALUES';
        inertSQL := inertSQL || '(' || seq_acc_book_no.nextval || ',' ||
                    F_GETDEALCODE(T1.TR_CODE) || ',''' || T1.ORG_ID ||
                    ''',''' || T1.ACPT_ID || ''',''' || T1.ACPT_ID ||
                    ''',''' || T1.OPER_ID || ''',';
        inertSQL := inertSQL || ' TO_DATE(''' || T1.TR_DATE || ' ' ||
                    T1.TR_TIME || ''',''yyyy-MM-dd hh24:mi:ss'')';
        inertSQL := inertSQL || ',''' || T1.REV_TIME || ''',''' ||
                    T1.DB_ITEM_NO || ''',' || T1.DB_ACC_NO || ',''' ||
                    T1.DB_CARD_NO || ''',' || nvl(T1.DB_ACC_BAL, 0) || ',' ||
                    nvl(T1.DB_AMT, 0) || ',''' || T1.CR_ITEM_NO || ''',' ||
                    T1.CR_ACC_NO || ',''' || T1.CR_CARD_NO || ''',''' ||
                    T1.CR_ACC_BAL || ''',' || T1.CR_AMT || ',''' ||
                    T1.TR_STATE || ''',' || T1.ACTION_NO || ',''' ||
                    T1.BATCH_PROC_DATE;
        inertSQL := inertSQL || ''',''' || T1.NOTE || ''',''' ||
                    trim(T1.CLR_DATE) || ''',''' || T1.CR_ITEM_NO || ''')';
        -- inertSQL := inertSQL || ';';
        DBMS_OUTPUT.put_line(inertSQL);
        execute immediate inertSQL;
      
        LN_NUM := LN_NUM + 1;
        IF LN_NUM = 5000 THEN
          LN_NUM := 0;
          COMMIT;
        END IF;
      END LOOP;
      LN_NUM := 0;
      COMMIT;
      date1 := ' trim(''' || date1 || ''') ';
      date2 := ' trim(''' || date2 || ''') ';
      --���½������ֵ
      inertSQL := '';
      inertSQL := ' update ACC_INOUT_DETAIL_' || monthsstr ||
                  ' a1  set a1.db_amt = -db_amt where a1.deal_no in (select action_no';
      inertSQL := inertSQL ||
                  ' from onecard_jx.tr_consume_his@ONECARD_DB1 h1 where h1.clr_date BETWEEN ' ||
                  date1 || ' AND ' || date2 || ')';
      -- inertSQL := inertSQL || ';';
      --DBMS_OUTPUT.put_line(inertSQL);
      execute immediate inertSQL;
      COMMIT;
      /*  rechageSQL := '';
      rechageSQL := 'INSERT INTO PAY_CARD_DEAL_REC_' || monthsstr ||
                    '(ID,ACC_INOUT_NO, DEAL_CODE,ORG_ID, ACPT_TYPE,ACPT_ID, USER_ID, DEAL_BATCH_NO,END_DEAL_NO,DEAL_DATE,CUSTOMER_ID, ACC_NO,CARD_NO,CARD_TYPE,ACC_BAL, AMT,CARD_BAL,CARD_COUNTER,DEAL_STATE,  DEAL_NO, INSERT_TIME, CLR_DATE, NOTE, CO_ORG_ID,  POSP_PROC_STATE)';
      rechageSQL := rechageSQL ||  ' SELECT SEQ_TR_CARD_ID.NEXTVAL,T.ACTION_NO,F_GET_DEAL_CODE(T.TR_CODE),T.ORG_ID, T.ACPT_TYPE,T.ACPT_ID,T.OPER_ID, T.TR_BATCH_NO, T.TERM_TR_NO, T.RECHG_DATE, T.CLIENT_ID, T.ACC_NO, T.CARD_NO,T.CARD_TYPE,T.ACC_BAL, T.RECHG_AMT, T.CARD_ACC_BAL,T.CARD_TR_COUNT,T.RECHG_STATE,T.ACTION_NO, SYSDATE,T.CLR_DATE,T.NOTE,T.ORG_ID, T.POSP_PROC_STATE ';
      rechageSQL := rechageSQL ||  ' FROM (SELECT * FROM ONECARD_JX.TR_RECHG_BLACK@ONECARD_DB1  T1  UNION ALL  SELECT * FROM ONECARD_JX.TR_RECHG_HIS@ONECARD_DB1 T2 WHERE T2.CLR_DATE BETWEEN ' ||
                    date1 || ' AND ' || date2 || ' UNION ALL SELECT * FROM ONECARD_JX.TR_RECHG_REC@ONECARD_DB1 T3  UNION ALL SELECT * FROM ONECARD_JX.TR_RECHG_TEMP@ONECARD_DB1 T4) T ';
      execute immediate rechageSQL;
      COMMIT;
      consumeSQL := '';
      consumeSQL := ' INSERT INTO PAY_CARD_DEAL_REC_' || monthsstr ||
                    '(ID,ACC_INOUT_NO,DEAL_CODE, ORG_ID,ACPT_TYPE,ACPT_ID,USER_ID,DEAL_BATCH_NO,END_DEAL_NO,DEAL_DATE,ACC_NO,CARD_NO,CARD_TYPE,  ACC_BAL,  AMT, CARD_BAL, CARD_COUNTER,  DEAL_STATE,  DEAL_NO, INSERT_TIME, CLR_DATE,  NOTE, CO_ORG_ID, POSP_PROC_STATE)';
      consumeSQL := consumeSQL || ' SELECT SEQ_TR_CARD_ID.NEXTVAL,TT.ACTION_NO,F_GET_DEAL_CODE(tt.TR_CODE),TT.ORG_ID, TT.ACPT_TYPE,TT.ACPT_ID,TT.OPER_ID, TT.TR_BATCH_NO,TT.TR_SER_NO,TT.TR_DATE,TT.ACC_NO,TT.CARD_NO,TT.CARD_IN_TYPE, TT.ACC_BAL,TT.TR_AMT, TT.ACC_BAL,TT.CARD_TR_COUNT,TT.REC_TYPE,TT.ACTION_NO, SYSDATE,TT.CLR_DATE,TT.NOTE,  TT.ORG_ID, TT.POSP_PROC_STATE  from (SELECT * FROM ONECARD_JX.TR_CONSUME_HIS@ONECARD_DB1 TT1 ';
      consumeSQL := consumeSQL || ' WHERE TT1.CLR_DATE BETWEEN ' || date1 ||
                    ' AND ' || date2 ||  ' UNION ALL SELECT * FROM ONECARD_JX.TR_CONSUME_REC@ONECARD_DB1 TT2) TT ';
      execute immediate consumeSQL;
      COMMIT;*/
    end loop;
  
  END P_ACC_DAYBOOK;

  ----��ȡ�ֻ��ˣ����ˣ���Ŀ������
  PROCEDURE P_ACC_SUB_LEDGER IS
    LN_NUM NUMBER;
  BEGIN
    LN_NUM := 0;
    --����ֻ�����Ϣ
    /*    FOR L IN (SELECT *
              FROM ONECARD_JX.ACC_SUB_LEDGER@ONECARD_DB1 L
             WHERE 1 = 1
               AND NOT EXISTS (SELECT 1
                      FROM ACC_ACCOUNT_SUB B
                     WHERE B.ACC_NO = L.SUB_ACC_NO) ) LOOP
    INSERT INTO ACC_ACCOUNT_SUB
      (ACC_NO,
       CUSTOMER_ID,
       CUSTOMER_TYPE,
       card_type,
       CARD_NO,
       ACC_NAME,
       BAL,
       BAL_CRYPT,
       ITEM_ID,
       BAL_TYPE,
       ACC_KIND, --10
       FRZ_AMT,
       LSS_DATE,
       FRZ_FLAG,
       FRZ_DATE,
       ORG_ID,
       OPEN_BRCH_ID,
       OPEN_USER_ID,
       OPEN_DATE, ----18
       CLS_DATE,
       CLS_USER_ID,
       ACC_STATE,
       WALLET_NO)
    VALUES
      (L.SUB_ACC_NO,
       L.CLIENT_ID,
       L.CLIENT_TYPE,
       '100',
       L.CARD_NO,
       L.ACC_NAME,
       L.BALANCE,
       L.BALANCE_ENCRYPT,
       L.ITEM_NO,
       L.BAL_ATTR,
       decode(l.acc_kind,'0','00','1','01','2','02',''), --10
       L.FRZ_AMT,
       L.LSS_DATE,
       L.FRZ_FLAG,
       L.FRZ_DATE,
       L.ORG_ID,
       L.OPEN_BRCH_ID,
       L.OPEN_OPER_ID,
       L.OPEN_DATE, --18
       L.CLS_DATE,
       L.CLS_OPER_ID,
       L.ACC_STATE,
       L.WALLET_ID);*/
  
    for la in (select la.acc_no,
                      la.customer_id,
                      la.card_no,
                      la.bal,
                      la.bal_crypt
                 from acc_account_sub la
                where la.acc_kind = '02') loop
      --���룬���ת��
      insert into acc_account_sub_temp
        (acc_no, customer_id, card_no, bal, bal_crypt, acc_kind, state)
      values
        (la.acc_no,
         la.customer_id,
         la.card_no,
         la.bal,
         la.bal_crypt,
         '02',
         '9');
      --update ACC_ACCOUNT_SUB_TEMP t  set t.pay_pwd = (select pwd  from onecard_jx.cm_pwd@JXSBRZDB p where p.PWD_NO = t.card_no) where  t.card_no=l.card_no;
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 10000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    LN_NUM := 0;
    COMMIT;
  
    /* for d in (
    select PWD_NO, PWD_TYPE, PWD
      from onecard_jx.CM_PWD@onecard_db1 d
     where 1 = 1
       and not exists (select 1 from BASE_PWD p where p.pwd_no=d.pwd_no) and d.pwd_type='1') loop 
       insert into BASE_PWD
    (PWD_NO, PWD_TYPE, PWD)values(d.PWD_NO, d.PWD_TYPE, d.PWD);
    
      LN_NUM := LN_NUM + 1;
        IF LN_NUM = 10000 THEN
          LN_NUM := 0;
          COMMIT;
        END IF;
    end loop;
    LN_NUM := 0;
      COMMIT;*/
  
    /*    --�����·ֻ����еĿ�����
    update acc_account_sub t
       set t.card_type =
           (select card_type
              from card_baseinfo c
             where c.card_no = t.card_no
               and c.card_type <> '100')
     where 1 = 1
       and exists (select 1
              from card_baseinfo cc
             where cc.card_no = t.card_no
               and cc.card_type <> '100');*/
    /*--������
    FOR R IN (SELECT *
                FROM ONECARD_JX.ACC_GEN_LEDGER@ONECARD_DB1 R
               WHERE 1 = 1
                 AND NOT EXISTS (SELECT 1
                        FROM ACC_ACCOUNT_GEN N
                       WHERE N.CLR_DATE = R.CLR_DATE
                         AND N.ITEM_ID = R.ITEM_NO)) LOOP
    
      INSERT INTO ACC_ACCOUNT_GEN
        (CLR_DATE,
         ORG_ID,
         BRCH_ID,
         ITEM_ID,
         ITEM_LVL,
         TOP_ITEM_ID,
         PRV_BAL,
         DB_NUM,
         DB_AMT,
         CR_NUM,
         CR_AMT,
         CUR_BAL,
         BAL_TYPE,
         ACC_NUM,
         ACC_AMT,
         CHK_FLAG,
         GEN_SUB)
      ---���˱�
      VALUES
        (R.CLR_DATE,
         R.ORG_ID,
         R.BRCH_ID,
         R.ITEM_NO,
         R.ITEM_LVL,
         R.TOP_ITEM_NO,
         R.PRV_BAL,
         R.CA_DB_NUM,
         R.CA_DB_AMT,
         R.TR_CR_NUM,
         R.TR_DB_AMT,
         R.CUR_BAL,
         R.BAL_ATTR,
         R.ACC_NUM,
         R.ACC_AMT,
         R.CHK_FLAG,
         R.GEN_SUB);
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    LN_NUM := 0;
    COMMIT;*/
    /*    insert into Acc_Account_Sub_Temp
      (Acc_No, Customer_Id, Card_No, Bal, Bal_Crypt, Acc_Kind, State)
      select Acc_No, Customer_Id, Card_No, Bal, Bal_Crypt, '02', '9'
        from ACC_ACCOUNT_SUB t
       where t.customer_type = '1'
         and t.acc_kind = '02';
    commit;*/
    --�����ֽ�β��
    /* INSERT INTO CASH_BOX
      (ORG_ID,
       BRCH_ID,
       USER_ID,
       COIN_KIND,
       YD_BLC,
       TD_IN_NUM,
       TD_IN_AMT,
       TD_OUT_NUM,
       TD_OUT_AMT,
       TD_BLC,
       FRZ_AMT)
      SELECT '',
             BRCH_ID,
             OPER_ID,
             COIN_KIND,
             YD_BLC,
             TD_IN_NUM,
             TD_IN_AMT,
             TD_OUT_NUM,
             TD_OUT_AMT,
             TD_BLC,
             0
        FROM ONECARD_JX.CS_CASH_BOX@ONECARD_DB1 B
       WHERE 1 = 1
         AND NOT EXISTS
       (SELECT 1 FROM CASH_BOX X WHERE X.USER_ID = B.OPER_ID);
    
    COMMIT;*/
    --�����ֽ���ˮ
    INSERT INTO CASH_BOX_REC
      (CASH_SER_NO,
       USER_ID,
       BRCH_ID,
       COIN_KIND,
       SUMMARY,
       IN_OUT_DATE,
       AMT,
       IN_OUT_FLAG,
       CS_BAL,
       DEAL_CODE,
       DEAL_NO,
       CLR_DATE)
      SELECT CASH_SER_NO,
             OPER_ID,
             BRCH_ID,
             COIN_KIND,
             SUMMARY,
             IN_OUT_DATE,
             K.IN_OUT_AMT,
             IN_OUT_FLAG,
             CS_BAL,
             F_GETDEALCODE(TR_CODE),
             ACTION_NO,
             CLR_DATE
        FROM ONECARD_JX.CS_CASH_BOOK@ONECARD_DB1 K
       WHERE 1 = 1
         AND NOT EXISTS (SELECT 1
                FROM CASH_BOX_REC C
               WHERE C.CASH_SER_NO = K.CASH_SER_NO);
  
    COMMIT;
  
  END P_ACC_SUB_LEDGER;

  ---��ȡ��������
  PROCEDURE P_APPLY_TASK IS
    LN_NUM NUMBER;
  BEGIN
    FOR Y IN (SELECT *
                FROM ONECARD_JX.CM_CARD_APPLY@ONECARD_DB1 Y
               WHERE 1 = 1
                 AND NOT EXISTS (SELECT 1
                        FROM CARD_APPLY A
                       WHERE A.APPLY_ID = Y.APPLY_ID)) LOOP
      INSERT INTO CARD_APPLY
        (APPLY_ID,
         BAR_CODE,
         CUSTOMER_ID,
         CARD_NO,
         CARD_TYPE,
         SUB_CARD_NO,
         SUB_CARD_TYPE,
         BANK_ID,
         BANK_CARD_NO,
         VERSION,
         ORG_CODE,
         CITY_CODE,
         INDUS_CODE,
         APPLY_WAY,
         APPLY_TYPE,
         MAKE_TYPE,
         APPLY_BRCH_ID,
         CORP_ID,
         COMM_ID,
         APPLY_STATE,
         APPLY_USER_ID,
         APPLY_DATE,
         COST_FEE,
         FOREGIFT,
         IS_URGENT,
         IS_PHOTO,
         RECV_BRCH_ID,
         RECV_CERT_TYPE,
         RECV_CERT_NO,
         RECV_NAME,
         RELS_BRCH_ID,
         RELS_USER_ID,
         RELS_DATE,
         AGT_CERT_TYPE,
         AGT_CERT_NO,
         AGT_NAME,
         DEAL_NO,
         NOTE,
         BUS_TYPE,
         OLD_CARD_NO,
         OLD_SUB_CARD_NO,
         MESSAGE_FLAG,
         MOBILE_PHONE,
         MAIN_FLAG,
         MAIN_CARD_NO,
         OTHER_FEE,
         WALLET_USE_FLAG,
         MONTH_TYPE,
         MONTH_CHARGE_MODE,
         TASK_ID)
      VALUES
      
        (Y.APPLY_ID,
         Y.BAR_CODE,
         Y.CLIENT_ID,
         Y.CARD_NO,
         Y.CARD_TYPE,
         Y.SUB_CARD_NO,
         Y.SUB_CARD_TYPE,
         Y.BANK_ID,
         Y.BANK_CARD_NO,
         Y.VERSION,
         Y.ORG_CODE,
         Y.CITY_CODE,
         Y.INDUS_CODE,
         Y.APPLY_WAY,
         Y.APPLY_TYPE,
         Y.MAKE_TYPE,
         Y.APPLY_BRCH_ID,
         Y.EMP_ID,
         Y.COMM_ID,
         F_GET_APPLY_STATE(Y.APPLY_STATE),
         Y.APPLY_OPER_ID,
         Y.APPLY_DATE,
         Y.COST_FEE,
         Y.FOREGIFT,
         Y.IS_URGENT,
         Y.IS_PHOTO,
         Y.RECV_BRCH_ID,
         Y.RECV_CERT_TYPE,
         Y.RECV_CERT_NO,
         Y.RECV_NAME,
         Y.RELS_BRCH_ID,
         Y.RELS_OPER_ID,
         Y.RELS_DATE,
         Y.AGT_CERT_TYPE,
         Y.AGT_CERT_NO,
         Y.AGT_NAME,
         Y.ACTION_NO,
         Y.NOTE,
         Y.BUS_TYPE,
         Y.OLD_CARD_NO,
         Y.OLD_SUB_CARD_NO,
         Y.SENDMESSAGE,
         Y.TEL_NO,
         Y.ISPARENT,
         Y.PARENT_CARD_NO,
         Y.OTHER_FEE,
         Y.BUS_USE_FLAG,
         Y.MONTH_TYPE,
         Y.MONTH_CHARGE_MODE,
         Y.TASK_ID);
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    LN_NUM := 0;
    COMMIT;
  
    ----���������
    INSERT INTO CARD_APPLY_TASK
      (TASK_ID,
       MAKE_BATCH_ID,
       DEAL_CODE,
       TASK_NAME,
       TASK_SUM,
       TASK_SRC,
       TASK_DATE,
       TASK_OPER_ID,
       CARD_TYPE,
       BANK_ID,
       BRCH_ID,
       CORP_ID,
       REGION_ID,
       TOWN_ID,
       COMM_ID,
       IS_PHOTO,
       START_CARD_NO,
       END_CARD_NO,
       IS_LIST,
       DEAL_NO,
       TASK_WAY,
       IS_URGENT,
       TASK_STATE,
       NOTE)
      SELECT TASK_ID,
             MAKE_BATCH_ID,
             F_GETDEALCODE(T.TR_CODE),
             TASK_NAME,
             TASK_SUM,
             TASK_SRC,
             TASK_DATE,
             TASK_OPER_ID,
             CARD_TYPE,
             BANK_ID,
             BRCH_ID,
             T.EMP_ID,
             REGION_ID,
             TOWN_ID,
             COMM_ID,
             IS_PHOTO,
             START_CARD_NO,
             END_CARD_NO,
             IS_LIST,
             ACTION_NO,
             DECODE(T.TASK_WAY, '2', '1', '1', '2', T.TASK_WAY),
             IS_URGENT,
             F_GET_TASK_STATE(TASK_STATE),
             NOTE
        FROM ONECARD_JX.CM_CARD_TASK@ONECARD_DB1 T
       WHERE 1 = 1
         AND NOT EXISTS
       (SELECT 1 FROM CARD_APPLY_TASK A WHERE A.TASK_ID = T.TASK_ID);
    COMMIT;
    FOR L IN (SELECT *
                FROM ONECARD_JX.CM_CARDTASK_LIST@ONECARD_DB1 L
               WHERE 1 = 1
                 AND NOT EXISTS
               (SELECT 1
                        FROM CARD_TASK_LIST LT
                       WHERE LT.DATA_SEQ = L.DATA_SEQ)) LOOP
      --����������ϸ
      INSERT INTO CARD_TASK_LIST
        (DATA_SEQ,
         TASK_ID,
         CUSTOMER_ID,
         NAME,
         SEX,
         NATION,
         BIRTHPLACE,
         BIRTHDAY,
         RESIDE_TYPE,
         RESIDE_ADDR,
         LETTER_ADDR,
         POST_CODE,
         MOBILE_NO,
         EDUCATION,
         MARR_STATE,
         CERT_TYPE,
         CERT_NO,
         CARD_NO,
         STRUCT_MAIN_TYPE,
         STRUCT_CHILD_TYPE,
         CARDISSUEDATE,
         VALIDITYDATE,
         BURSESTARTDATE,
         BURSEVALIDDATE,
         MONTHSTARTDATE,
         MONTHVALIDDATE,
         FACE_VAL,
         PWD,
         BAR_CODE,
         COMM_ID,
         CARD_TYPE,
         VERSION,
         INIT_ORG_ID,
         CITY_CODE,
         INDUS_CODE,
         BURSEBALANCE,
         MONTHBALANCE,
         BANK_ID,
         BANKCARDNO,
         BANKSECTION2,
         BANKSECTION3,
         DEPARTMENT,
         CLASSID,
         PHOTOFILENAME,
         APPLY_ID,
         USEFLAG,
         CERT_TYPED,
         BUS_USE_FLAG,
         BURSE_VALIDDATE,
         MONTH_START_DATE,
         MONTH_VALIDDATE,
         MONTH_TYPE,
         DF01EF0729,
         BURSE_BALANCE,
         MONTH_BALANCE,
         SUB_CARD_NO,
         TOUCH_STARTDATE,
         TOUCH_VALIDDATE)
      VALUES
        (L.DATA_SEQ,
         L.TASK_ID,
         L.CLIENT_ID,
         L.NAME,
         L.SEX,
         L.NATION,
         L.BIRTHPLACE,
         L.BIRTHDAY,
         L.RESIDE_TYPE,
         L.RESIDE_ADDR,
         L.LETTER_ADDR,
         L.POST_CODE,
         L.MOBILE_NO,
         L.EDUCATION,
         L.MARR_STATE,
         L.CERT_TYPE,
         L.CERT_NO,
         L.CARD_NO,
         L.STRUCT_MAIN_TYPE,
         L.STRUCT_CHILD_TYPE,
         L.CARDISSUEDATE,
         L.VALIDITYDATE,
         L.BURSESTARTDATE,
         L.BURSEVALIDDATE,
         L.MONTHSTARTDATE,
         L.MONTHVALIDDATE,
         L.FACE_VAL,
         L.PWD,
         L.BAR_CODE,
         L.COMM_ID,
         L.CARD_TYPE,
         L.VERSION,
         L.ORG_CODE,
         L.CITY_CODE,
         L.IND_CODE,
         L.BURSEBALANCE,
         L.MONTHBALANCE,
         L.BANK_ID,
         L.BANKCARDNO,
         L.BANKSECTION2,
         L.BANKSECTION3,
         L.DEPARTMENT,
         L.CLASSID,
         L.PHOTOFILENAME,
         L.APPLY_ID,
         L.USEFLAG,
         L.CERT_TYPED,
         L.BUS_USE_FLAG,
         L.BURSE_VALIDDATE,
         L.MONTH_START_DATE,
         L.MONTH_VALIDDATE,
         L.MONTH_TYPE,
         L.DF01EF0729,
         L.BURSE_BALANCE,
         L.MONTH_BALANCE,
         L.SSSEEF0507,
         L.CARDISSUEDATE,
         L.SSSEEF0506);
    
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    LN_NUM := 0;
    COMMIT;
    --
  END P_APPLY_TASK;
  ---------------��ȡ�������----------------
  PROCEDURE P_STK_STOCK IS
    LN_NUM NUMBER;
  BEGIN
    FOR C IN (SELECT *
                FROM ONECARD_JX.STK_BIZ_REC@ONECARD_DB1 C
               WHERE 1 = 1
                 AND NOT EXISTS
               (SELECT 1
                        FROM STOCK_REC A
                       WHERE A.STK_SER_NO = STK_SER_NO)) LOOP
      INSERT INTO STOCK_REC
        (STK_SER_NO,
         DEAL_CODE,
         STK_CODE,
         BATCH_ID,
         TASK_ID,
         IN_ORG_ID,
         IN_BRCH_ID,
         IN_USER_ID,
         IN_GOODS_STATE,
         OUT_ORG_ID,
         OUT_BRCH_ID,
         OUT_USER_ID,
         OUT_GOODS_STATE,
         GOODS_NUMS,
         IN_OUT_FLAG,
         TR_DATE,
         ORG_ID,
         BRCH_ID,
         USER_ID,
         AUTH_OPER_ID,
         BOOK_STATE,
         CLR_DATE,
         DEAL_NO,
         IS_SURE,
         START_NO,
         END_NO)
      VALUES
        (C.ACTION_NO,
         F_GET_DEAL_CODE(C.TR_CODE),
         C.STK_CODE,
         C.BRCH_ID,
         C.TASK_ID,
         C.IN_ORG_ID,
         C.IN_BRCH_ID,
         C.IN_OPER_ID,
         C.IN_GOODS_STATE,
         C.OUT_ORG_ID,
         C.OUT_BRCH_ID,
         C.OUT_OPER_ID,
         C.OUT_GOODS_STATE,
         C.TOT_NUM,
         C.IN_OUT_FLAG,
         C.TR_DATE,
         C.ORG_ID,
         C.BRCH_ID,
         C.OPER_ID,
         C.AUTH_OPER_ID,
         C.TR_STATE,
         C.CLR_DATE,
         C.ACTION_NO,
         C.IS_SURE,
         C.START_NO,
         C.END_NO);
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    LN_NUM := 0;
    COMMIT;
    --������ֻ���
    INSERT INTO STOCK_ACC
      (ORG_ID,
       BRCH_ID,
       USER_ID,
       ACC_NAME,
       STK_CODE,
       GOODS_STATE,
       TOT_NUM,
       TOT_FACE_VAL,
       OPEN_DATE,
       AUTH_USER_ID,
       CLS_DATE,
       CLS_USER_ID,
       LAST_DEAL_DATE,
       ACC_STATE,
       NOTE)
      SELECT ORG_ID,
             BRCH_ID,
             R.OPER_ID,
             R.LEDGER_NAME,
             STK_CODE,
             GOODS_STATE,
             TOT_NUM,
             TOT_FACE_VAL,
             OPEN_DATE,
             AUTH_OPER_ID,
             CLS_DATE,
             CLS_OPER_ID,
             R.LAST_TR_DATE,
             R.GOODS_STATE,
             NOTE
        FROM ONECARD_JX.STK_SUB_LEDGER@ONECARD_DB1 R
       WHERE 1 = 1
         AND NOT EXISTS (SELECT 1
                FROM STOCK_ACC A
               WHERE A.USER_ID = R.OPER_ID
                 AND A.STK_CODE = R.STK_CODE
                 AND A.GOODS_STATE = GOODS_STATE);
    COMMIT;
    --��������ϸ
    FOR L IN (SELECT *
                FROM ONECARD_JX.STK_STOCK_LIST@ONECARD_DB1 L
               WHERE 1 = 1
                 AND NOT EXISTS
               (SELECT 1
                        FROM STOCK_LIST A
                       WHERE A.GOODS_ID = L.GOODS_ALIAS_NO
                         AND A.STK_CODE = L.STK_CODE
                         AND A.GOODS_STATE = L.GOODS_STATE)) LOOP
      INSERT INTO STOCK_LIST
        (STK_CODE,
         GOODS_ID,
         GOODS_NO,
         GOODS_STATE,
         BATCH_ID,
         TASK_ID,
         STK_IS_SURE,
         IN_DATE,
         IN_USER_ID,
         IN_DEAL_NO,
         OUT_DATE,
         OUT_USER_ID,
         OUT_DEAL_NO,
         OWN_TYPE,
         ORG_ID,
         BRCH_ID,
         USER_ID,
         customer_id,
         NOTE)
      VALUES
        (L.STK_CODE,
         L.GOODS_ALIAS_NO,
         L.GOODS_ALIAS_NO,
         L.GOODS_STATE,
         L.BRCH_ID,
         L.TASK_ID,
         '0',
         L.IN_DATE,
         L.IN_OPER_ID,
         L.IN_ACTION_NO,
         L.OUT_DATE,
         L.OUT_OPER_ID,
         L.OUT_ACTION_NO,
         L.OWN_TYPE,
         L.ORG_ID,
         L.BRCH_ID,
         L.OPER_ID,
         l.oper_id,
         L.NOTE);
      LN_NUM := LN_NUM + 1;
      IF LN_NUM = 5000 THEN
        LN_NUM := 0;
        COMMIT;
      END IF;
    END LOOP;
    LN_NUM := 0;
    COMMIT;
  
  END P_STK_STOCK;
  ---��ȡϵͳ��������-----------
  PROCEDURE P_SYS_INTO IS
  
  BEGIN
    INSERT INTO SYS_USERS
      (MYID,
       USER_ID,
       ACCOUNT,
       NAME,
       BRCH_ID,
       PASSWORD,
       ISEMPLOYEE,
       STATUS,
       IP,
       DESCRIPTION,
       ORG_ID,
       CREATED,
       LASTMOD,
       CREATER,
       TEL,
       LOGIN_COUNT,
       PASSWORD_VALIDITY,
       duty_id)
    
      SELECT SEQ_SB_ID.NEXTVAL,
             O.OPER_ID,
             O.OPER_ID,
             O.OPER_NAME,
             O.BRCH_ID,
             O.PWD,
             O.DAY_BAL_FLAG,
             DECODE(O.OPER_STATE, '0', 'A', '1', 'I', 'I'),
             LOGIN_IP,
             O.NOTE,
             ORG_ID,
             O.CLS_DATE,
             O.CHECK_DATE,
             O.OPEN_OPER_ID,
             O.TELE_NO,
             O.PWD_ERR_NUM,
             '180',
             O.OPER_LEVEL
        FROM ONECARD_JX.SYS_OPERATOR@ONECARD_DB1 O
       WHERE 1 = 1
         AND NOT EXISTS
       (SELECT 1 FROM SYS_USERS U WHERE U.USER_ID = O.OPER_ID);
    COMMIT;
    update SYS_USERS t
       set t.created        = sysdate,
           t.login_count    = 0,
           t.lastmod        = sysdate,
           t.first_visit    = sysdate,
           t.previous_visit = sysdate,
           t.last_visits    = sysdate;
    --
    insert into CASH_BOX
      (ORG_ID,
       BRCH_ID,
       USER_ID,
       COIN_KIND,
       YD_BLC,
       TD_IN_NUM,
       TD_IN_AMT,
       TD_OUT_NUM,
       TD_OUT_AMT,
       TD_BLC,
       FRZ_AMT)
      select '1001', r.brch_id, r.user_id, '1', 0, 0, 0, 0, 0, 0, 0
        from sys_users r;
  
    update SYS_USERS t
       set t.brch_name =
           (select c.full_name from sys_branch c where c.brch_id = t.brch_id)
     where exists (select 1 from sys_branch b where b.brch_id = t.brch_id);
  
    /*INSERT INTO SYS_REPORT
      (DEAL_NO,
       RP_TITILE,
       PDF_CONTENT,
       FORMAT,
       FILENAME,
       RETURN_URL,
       USER_ID,
       DEAL_DATE)
      SELECT NVL(R.ID, 0),
             R.RP_TITILE,
             R.CONTENT,
             DECODE(R.FORMAT, 'PDF', 1, ''),
             R.FILENAME,
             R.URL,
             R.OPER_ID,
             R.OPER_DATE
        FROM ONECARD_JX.SYS_REPORT R;
    COMMIT;*/
    --����
    /* INSERT INTO SYS_SMESSAGES
      (SMS_NO,
       SMS_TYPE,
       CUSTOMER_ID,
       CARD_NO,
       MOBILE_NO,
       CONTENT,
       RTN_STATE,
       SMS_STATE,
       SEND_TIME,
       OPER_ID,
       DEAL_CODE,
       DEAL_NO,
       CREATE_TIME,
       MID,
       NOTE)
      SELECT SMS_NO,
             SMS_TYPE,
             CLIENT_ID,
             CARD_NO,
             MOBILE_NO,
             CONTENT,
             RTN_STATE,
             SMS_STATE,
             SEND_TIME,
             OPER_ID,
             TR_CODE,
             ACTION_NO,
             TIME,
             MID,
             NOTE
        FROM ONECARD_JX.SYS_SMESSAGES;
    COMMIT;*/
    --������Ϣ
    INSERT INTO SYS_BRANCH
      (SYSBRANCH_ID,
       ORG_ID,
       BRCH_ID,
       PID,
       FULL_NAME,
       ASSISTANT_MANAGER,
       BRCH_TYPE,
       STATUS,
       TEL,
       FAX,
       DESCRIPTION,
       CREATER,
       MODIFYER,
       IS_DAY_FLAG,
       REGION_ID,
       state)
      SELECT SEQ_SYS_BRACH_NO.NEXTVAL,
             B.ORG_ID,
             B.BRCH_ID,
             B.PARENT_BRCH_ID,
             B.BRCH_NAME,
             b.BRCH_LEVEL,
             B.BRCH_TYPE,
             decode(B.BRCH_STATE, '0', 'A', '1', 'I', 'A'),
             B.TEL_NO,
             B.FAX_NO,
             B.NOTE,
             B.OPEN_OPER_ID,
             B.CLS_OPER_ID,
             B.DAY_BAL_FLAG,
             B.REGION_ID,
             'closed'
      
        FROM ONECARD_JX.SYS_BRANCH@ONECARD_DB1 B;
    COMMIT;
    UPDATE SYS_BRANCH a
       SET a.pid =
           (SELECT b.sysbranch_id FROM Sys_Branch b WHERE b.brch_id = a.pid);
    update sys_branch h
       set h.state             = 'closed',
           h.brch_type         = '1',
           h.short_name        = h.full_name,
           h.assistant_manager = decode(h.assistant_manager,
                                        '10',
                                        '0',
                                        '11',
                                        '1',
                                        '12',
                                        '2',
                                        '13',
                                        '3',
                                        '14',
                                        '4',
                                        '');
    commit;
  END P_SYS_INTO;

  --------------------------
  ---��ȡ���������
  PROCEDURE P_STL_AND_CLR IS
    LN_NUM NUMBER;
  BEGIN
  
    /*     ---����ģʽ
    insert into stl_mode
      (merchant_id,
       valid_date,
       stl_mode,
       stl_way,
       stl_days,
       stl_lim,
       stl_way_ret,
       stl_days_ret,
       stl_lim_ret,
       stl_way_fee,
       stl_days_fee,
       stl_lim_fee)
      select mer.biz_id,
             sysdate,
             '2',
             mer.stl_way,
             mer.stl_days,
             mer.stl_limit,
             '01',
             '1',
             0,
             '01',
             '1',
             0
        from onecard_jx.bs_merchant@ONECARD_DB1 mer;
    COMMIT; --*/
    insert into pay_fee_rate
      (fee_rate_id,
       merchant_id,
       deal_code,
       begindate,
       fee_type,
       fee_rate,
       fee_state,
       fee_max,
       fee_min,
       have_section,
       in_out,
       insert_date,
       chk_state,
       note)
      select r.fee_rate_id,
             r.biz_org_id,
             decode(f_getdealcode(r.tr_code),
                    null,
                    0,
                    f_getdealcode(r.tr_code)),
             r.fee_start_date,
             r.fee_type,
             r.fee_rate,
             r.fee_state,
             r.fee_max,
             r.fee_min,
             '1',
             r.in_out,
             sysdate,
             '0',
             r.note
        from onecard_jx.clr_fee_rate@ONECARD_DB1 r;
    commit;
    INSERT INTO STL_DEAL_LIST
      (LIST_NO,
       STL_SUM_NO,
       DEAL_CODE,
       CARD_TYPE,
       ACC_KIND,
       DEAL_NUM,
       DEAL_AMT,
       FEE_AMT,
       FEE_RATE_ID,
       OTH_FEE,
       IN_OUT)
      SELECT LIST_NO,
             STL_SUM_NO,
             F_GETDEALCODE(LT.TR_CODE),
             CARD_TYPE,
             decode(F_GET_ACC_KIND(ACC_KIND),
                    '',
                    '-1',
                    F_GET_ACC_KIND(ACC_KIND)),
             LT.TR_NUM,
             LT.TR_AMT,
             FEE_AMT,
             FEE_RATE_ID,
             OTH_FEE,
             IN_OUT
        FROM ONECARD_JX.STL_TRADE_LIST@ONECARD_DB1 LT;
    COMMIT;
  
    ---�����ܽ�������
    INSERT INTO STL_DEAL_SUM
      (STL_SUM_NO,
       MERCHANT_ID,
       MERCHANT_NAME,
       BEGIN_DATE,
       END_DATE,
       STL_DAYS,
       CARD_TYPE,
       ACC_KIND,
       TOT_DEAL_NUM,
       TOT_DEAL_AMT,
       DEAL_NUM,
       DEAL_AMT,
       TH_AMT,
       DEAL_FEE,
       STL_DATE,
       STL_AMT,
       USER_ID,
       OPER_DATE,
       VRF_DATE,
       VRF_USER_ID,
       STL_STATE,
       NOTE)
      SELECT STL_SUM_NO,
             M.BIZ_ID,
             M.BIZ_NAME,
             M.BEGIN_DATE,
             M.END_DATE,
             M.STL_DAYS,
             M.CARD_TYPE,
             decode(F_GET_ACC_KIND(ACC_KIND),
                    '',
                    '-1',
                    F_GET_ACC_KIND(ACC_KIND)),
             M.TR_NUM,
             M.TR_AMT + M.TH_AMT,
             M.TR_NUM,
             M.TR_AMT,
             M.TH_AMT,
             M.TR_FEE,
             M.STL_DATE,
             M.STL_AMT,
             M.OPER_ID,
             M.OPER_DATE,
             M.VRF_DATE,
             M.VRF_OPER_ID,
             M.STL_STATE,
             M.NOTE
        FROM ONECARD_JX.STL_TRADE_SUM@ONECARD_DB1 M;
    COMMIT;
    ----
  
    INSERT INTO STL_DEAL_LIST_DIV
      (STL_SUM_NO,
       LIST_NO,
       MERCHANT_ID,
       DEAL_CODE,
       CARD_TYPE,
       ACC_KIND,
       FEE_AMT,
       FEE_STL_DATE,
       OPER_DATE,
       ORG_ID,
       DIV_ID,
       DIV_TYPE,
       CLR_FIXED,
       CLR_PERCENT,
       DIV_FEE)
    
      SELECT STL_SUM_NO,
             LIST_NO,
             T.BIZ_ID,
             F_GETDEALCODE(T.TR_CODE),
             CARD_TYPE,
             decode(F_GET_ACC_KIND(ACC_KIND),
                    '',
                    '-1',
                    F_GET_ACC_KIND(ACC_KIND)),
             FEE_AMT,
             FEE_STL_DATE,
             OPER_DATE,
             ORG_ID,
             DIV_ID,
             DIV_TYPE,
             CLR_FIXED,
             CLR_PERCENT,
             DIV_FEE
        FROM ONECARD_JX.STL_DIVFEE_LIST@ONECARD_DB1 T;
    COMMIT;
    ---�������
    INSERT INTO PAY_CLR_SUM
      (CLR_NO,
       CLR_DATE,
       MERCHANT_ID,
       DEAL_CODE,
       CARD_TYPE,
       ACC_KIND,
       DEAL_NUM,
       DEAL_AMT,
       STL_SUM_NO,
       STL_DATE,
       STL_FLAG,
       FEE_STL_FLAG)
      SELECT SEQ_CLR_NO.NEXTVAL,
             CLR_DATE,
             C.BIZ_ID,
             decode(F_GETDEALCODE(C.TR_CODE),
                    '',
                    '0',
                    F_GETDEALCODE(C.TR_CODE)),
             CARD_TYPE,
             decode(F_GET_ACC_KIND(ACC_KIND),
                    '',
                    '-1',
                    F_GET_ACC_KIND(ACC_KIND)),
             C.TR_NUM,
             C.TR_AMT,
             C.BIZ_STL_NO,
             C.BIZ_STL_DATE,
             C.BIZ_STL_FLAG,
             ''
        FROM ONECARD_JX.CLR_TRADE_SUM@ONECARD_DB1 C;
    COMMIT;
    --INSERT INTO pay_card_deal_rec
  
  END P_STL_AND_CLR;
  ---��ȡ����������
  PROCEDURE P_BLACK_REC IS
  
  BEGIN
    --������
    INSERT INTO CARD_BLACK
      (CARD_ID, CARD_NO, ORG_ID, BLK_TYPE, BLK_STATE, LAST_DATE, VERSION)
      SELECT CARD_ID, P.CARD_ID, '', BLK_TYPE, BLK_STATE, NULL, P.VERSON
        FROM ONECARD_JX.CM_BLACK_LIST@ONECARD_DB1 P;
    --������ҵ���¼��
    INSERT INTO CARD_BLACK_REC
      (DEAL_NO, CARD_ID, CARD_NO, VERSION)
      SELECT R.ACTION_NO, NULL, NULL, NULL
        FROM ONECARD_JX.CM_BLACK_REC@ONECARD_DB1 R;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END P_BLACK_REC;
  --
  ---��ȡ��ֵ��������
  PROCEDURE P_RECHAGE_CONSUME IS
    LN_NUM NUMBER;
  BEGIN
    /* INSERT INTO PAY_OFFLINE
      (END_DEAL_NO,
       ACPT_ID,
       END_ID,
       CARD_NO,
       CARD_IN_TYPE,
       CARD_IN_SUBTYPE,
       CARD_VALID_DATE,
       CARD_START_DATE,
       APP_VALID_DATE,
       CARD_DEAL_COUNT,
       PSAM_DEAL_NO,
       ACC_BAL,
       DEAL_AMT,
       DEAL_DATE,
       DEAL_KIND,
       PSAM_NO,
       TAC,
       CREDIT_LIMIT,
       DEAL_BATCH_NO,
       SEND_FILE_NAME,
       FILE_LINE_NO,
       SEND_DATE,
       DEAL_NO,
       DEAL_CODE,
       DEAL_STATE,
       CLR_DATE,
       REFUSE_REASON,
       ORG_ID)
      SELECT P.TR_SER_NO,
             ACPT_ID,
             P.TERM_ID,
             CARD_NO,
             CARD_IN_TYPE,
             CARD_IN_SUBTYPE,
             CARD_VALID_DATE,
             CARD_START_DATE,
             APP_VALID_DATE,
             CARD_TR_COUNT,
             P.PSAM_TR_NO,
             ACC_BAL,
             P.TR_AMT,
             TO_CHAR(P.TR_DATE, 'yyyyMMddHHddss'),
             P.TR_KIND,
             PSAM_NO,
             TAC,
             0,
             P.BATCH_PROC_NO,
             SEND_FILE_NAME,
             FILE_LINE_NO,
             SEND_DATE,
             P.ACTION_NO,
             F_GETDEALCODE(P.TR_CODE),
             P.REC_TYPE,
             CLR_DATE,
             REFUSE_REASON,
             P.ORG_ID
      
        FROM ONECARD_JX.TR_CONSUME_TEMP P;
    COMMIT;*/
  
    INSERT INTO PAY_OFFLINE_BLACK
      (END_DEAL_NO,
       ACPT_ID,
       END_ID,
       CARD_NO,
       CARD_IN_TYPE,
       CARD_IN_SUBTYPE,
       CARD_VALID_DATE,
       CARD_START_DATE,
       APP_VALID_DATE,
       CARD_DEAL_COUNT,
       PSAM_DEAL_NO,
       ACC_BAL,
       DEAL_AMT,
       DEAL_DATE,
       DEAL_KIND,
       PSAM_NO,
       TAC,
       CREDIT_LIMIT,
       DEAL_BATCH_NO,
       SEND_FILE_NAME,
       FILE_LINE_NO,
       SEND_DATE,
       DEAL_NO,
       DEAL_CODE,
       DEAL_STATE,
       CLR_DATE,
       REFUSE_REASON,
       ORG_ID)
      SELECT TR.TR_SER_NO,
             ACPT_ID,
             TR.TERM_ID,
             CARD_NO,
             CARD_IN_TYPE,
             CARD_IN_SUBTYPE,
             CARD_VALID_DATE,
             CARD_START_DATE,
             APP_VALID_DATE,
             CARD_TR_COUNT,
             TR.PSAM_TR_NO,
             ACC_BAL,
             TR.TR_AMT,
             TO_CHAR(TR.TR_DATE, 'yyyyMMddHHddss'),
             TR.TR_KIND,
             PSAM_NO,
             TAC,
             0,
             TR.BATCH_PROC_NO,
             SEND_FILE_NAME,
             FILE_LINE_NO,
             SEND_DATE,
             TR.ACTION_NO,
             F_GETDEALCODE(TR.TR_CODE),
             TR.REC_TYPE,
             CLR_DATE,
             REFUSE_REASON,
             TR.ORG_ID
        FROM ONECARD_JX.TR_CONSUME_BLACK@ONECARD_DB1 TR;
    COMMIT;
  
    /*    INSERT INTO PAY_OFFLINE_FILENAME
    (SEND_FILE_NAME,
     FILE_TYPE,
     SEND_DATE,
     MERCHANT_ID,
     DEAL_BATCH_NO,
     STATE,
     CONFIRM_NUM,
     CONFIRM_AMT,
     REFUSE_NUM,
     REFUSE_AMT,
     ADJUST_NUM,
     ADJUST_AMT)
    SELECT SEND_FILE_NAME,
           FILE_TYPE,
           SEND_DATE,
           MERCHANT_ID,
           DEAL_BATCH_NO,
           STATE,
           CONFIRM_NUM,
           CONFIRM_AMT,
           REFUSE_NUM,
           REFUSE_AMT,
           ADJUST_NUM,
           f.
      FROM ONECARD_JX.TR_CHECK_BILL_FILE F;*/
  
    COMMIT;
  
  END P_RECHAGE_CONSUME;

  ---��ȡ�������Ի�ҵ������
  PROCEDURE P_OTHER_INTO IS
  
  BEGIN
  
    /*    INSERT INTO POS_MAK_VER
    (BIZ_ID,
     TERM_ID,
     PIK,
     PIK_ZMK,
     MAK,
     MAK_ZMK,
     PINK,
     PINK_ZMK,
     MOK,
     MAK_CHK,
     PIK_CHK)
    SELECT P.ZMK,
           P.VERSION,
           PIK,
           PIK_ZMK,
           MAK,
           MAK_ZMK,
           PINK,
           PINK_ZMK,
           MOK,
           MAK_CHK,
           PIK_CHK
      FROM ONECARD_JX.POS_MAK_VER P;*/
    COMMIT;
    --
    INSERT INTO CARD_SALE_LIST
      (SALE_LIST_ID,
       DEAL_NO,
       CARD_TYPE,
       CARD_NO,
       FACE_VAL,
       SALE_AMT,
       FOREGIFT,
       OTHER_FEE,
       COST_FEE)
      SELECT SEQ_TR_SALE_LIST.NEXTVAL,
             L.BUY_SER_NO,
             CARD_TYPE,
             L.START_CARD_NO,
             FACE_VAL,
             SALE_AMT,
             0,
             OTHER_FEE,
             0
        FROM ONECARD_JX.TR_SALE_LIST@ONECARD_DB1 L;
  
    /*INSERT INTO CARD_SALE_BOOK
    (DEAL_NO,
     ORG_ID,
     BRCH_ID,
     SALE_DATE,
     USER_ID,
     CUSTOMER_ID,
     TOT_NUM,
     TOT_AMT,
     DRW_FLAG,
     SND_FLAG,
     PAY_WAY,
     PAY_FLAG,
     PAY_BAT_ID,
     INV_FLAG,
     INV_BAT_NO,
     VRF_FLAG,
     MNG_OPER_ID,
     SALE_STATE,
     CLR_DATE,
     FOREGIFT_AMT,
     DEAL_CODE)
    SELECT K.ACTION_NO,
           ORG_ID,
           BRCH_ID,
           SALE_DATE,
           K.OPER_ID,
           K.CLIENT_ID,
           TOT_NUM,
           TOT_AMT,
           DRW_FLAG,
           SND_FLAG,
           K.PAY_FLAG,
           PAY_FLAG,
           PAY_BAT_ID,
           INV_FLAG,
           INV_BAT_NO,
           VRF_FLAG,
           MNG_OPER_ID,
           SALE_STATE,
           CLR_DATE,
           FOREGIFT_AMT,
           F_GETDEALCODE(K.TR_CODE),
           OTHER_FEE
      FROM ONECARD_JX.TR_SALE_BOOK K;*/
    INSERT INTO CARD_APPLY_SB
      (COMPANYID,
       EMP_ID,
       EMP_NAME,
       CERT_NO,
       NAME,
       APPLY_DATE,
       APPLY_NAME,
       RECV_BRCH_ID,
       APPLY_PICI,
       SB_APPLY_STATE,
       SB_APPLY_ID)
      SELECT A.COMPANYID,
             A.EMP_ID,
             A.EMP_NAME,
             A.CERT_NO,
             A.NAME,
             A.APPLY_DATE,
             A.APPLY_NAME,
             A.RECV_BRCH_ID,
             A.APPLY_PICI,
             A.SB_APPLY_STATE,
             A.SB_APPLY_ID
        FROM ONECARD_JX.SB_APPLY@ONECARD_DB1 A
       WHERE 1 = 1;
  
  END P_OTHER_INTO;

  ---�̻������㿪����Ϣ------------
  PROCEDURE P_create_accout IS
    LV_IN         varchar2(2000);
    lv_action_log sys_action_log%ROWTYPE; -- ������־��
    --lv_serv_rec        tr_serv_rec%Rowtype; -- �ۺ�ҵ����־��
    av_res VARCHAR2(2000); --������������
    av_msg VARCHAR2(2000); --��������������Ϣ
  BEGIN
    av_res := '';
    av_msg := '';
    select seq_action_no.nextval into lv_action_log.deal_no from dual;
    lv_action_log.deal_code := 50501080;
    lv_action_log.org_id    := '1001';
    lv_action_log.brch_id   := '10010001';
    lv_action_log.user_id   := 'admin';
    lv_action_log.deal_time := to_date(to_char(sysdate,
                                               'yyyy-mm-dd hh24:mi:ss'),
                                       'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type  := 0;
    --���㿪��
    FOR b IN (SELECT * FROM sys_branch h order by h.brch_id desc) LOOP
    
      LV_IN := lv_action_log.deal_no || '|' || 50501080 || '|' || 'admin' || '|' ||
               to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss') || '|' || '0|1' || '|' ||
               b.brch_id || '||';
      PK_BUSINESS.P_CREATEACCOUNT(LV_IN, av_res, av_msg);
    END LOOP;
    select seq_action_no.nextval into lv_action_log.deal_no from dual;
    --�̻�����
    FOR mt IN (SELECT * FROM BASE_MERCHANT mt order by mt.customer_id desc) LOOP
    
      LV_IN := lv_action_log.deal_no || '|' || 50501060 || '|' || 'admin' || '|' ||
               to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss') || '|' || '3|1' || '|' ||
               mt.customer_id || '||';
      PK_BUSINESS.P_CREATEACCOUNT(LV_IN, av_res, av_msg);
    END LOOP;
    select seq_action_no.nextval into lv_action_log.deal_no from dual;
    --������������
    FOR g IN (SELECT * FROM Base_Co_Org g order by g.customer_id desc) LOOP
    
      LV_IN := lv_action_log.deal_no || '|' || 50501070 || '|' || 'admin' || '|' ||
               to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss') || '|' || '5|1' || '|' ||
               g.customer_id || '||';
      PK_BUSINESS.P_CREATEACCOUNT(LV_IN, av_res, av_msg);
    END LOOP;
    --��Ա��濪��
    for us in (select * from sys_users us order by us.user_id) loop
      LV_IN := '10010001' || '|' || '1' || '|' || 'admin' || '|' ||
               lv_action_log.deal_no || '|' || us.brch_id || '|' ||
               us.user_id || '|||';
      pk_card_Stock.p_stockacc_open(LV_IN, av_res, av_msg);
    end LOOP;
  END P_create_accout;

END PK_SMK_TO_YKT;
/

