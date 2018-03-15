CREATE OR REPLACE PACKAGE BODY PK_CARD_APPLY_ISSUSE AS
    ------------��������Ϣ------------------
    --AS_CITY_CODE      VARCHAR2(6) := PK_PUBLIC.F_GETSYSPARA('CITY_CODE'); --���д���
    AS_MONTH_TYPE VARCHAR2(6) := PK_PUBLIC.F_GETSYSPARA('month_type'); --��Ʊ��־
    --AS_SERVPWD_RULE   VARCHAR2(32) := PK_PUBLIC.F_GETSYSPARA('servpwd_rule'); --�������   1�������;0Ĭ�Ϲ̶�����
    AS_INIT_SERVPWD VARCHAR2(32) := PK_PUBLIC.F_GETSYSPARA('init_servpwd'); --����ǹ̶�����,���ȡ�̶��ĳ�ʼ����
    --AS_ORG_CODE       VARCHAR2(32) := PK_PUBLIC.F_GETSYSPARA('org_code'); --��������
    --AS_ZEROENCRYPTION VARCHAR2(32) := PK_PUBLIC.F_GETSYSPARA('zeroencryption'); --���0������
    --AS_INITPWD        VARCHAR2(32) := PK_PUBLIC.F_GETSYSPARA('initpwd'); --CUP����ʼ��������
    AS_USEFLAG        VARCHAR2(2) := PK_PUBLIC.F_GETSYSPARA('useflag'); --CUP����ʼ��������
    TRADE_PWD_DEFAULT VARCHAR2(32) := PK_PUBLIC.F_GETSYSPARA('TRADE_PWD_DEFAULT'); --CUP����ʼ��������
    /*=======================================================================================*/
    --���˷���
    /*=======================================================================================*/
    PROCEDURE P_ONECARD_ISSUSE(AS_CARD_NO VARCHAR2, --���ŵĿ���
                               AS_DEAL_NO INTEGER, --���Ľ�����ˮ��
                               AS_BANK_NO VARCHAR2, --���п���
                               AS_STOCK_FLAG VARCHAR2, --�Ƿ���¿ⷿ��0�У�1û��
                               AS_SYNCH2CARDUPATE VARCHAR2, --�Ƿ�ͬ��������ƽ̨��0ͬ����1��ͬ��
                               AS_ACPT_TYPE VARCHAR2, --���������-1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳� ---- ����
                               AV_RES OUT VARCHAR2, --������������
                               AV_MSG OUT VARCHAR2 --��������������Ϣ
                               ) IS
        LV_CARD_TASK_LIST  CARD_TASK_LIST%ROWTYPE; -- ������ϸ��Ϣ
        LV_CARD_APPLY      CARD_APPLY%ROWTYPE; -- ������Ϣ
        LV_CARD_APPLY_TASK CARD_APPLY_TASK%ROWTYPE; -- ������Ϣ
        LV_CARD_BASEINFO   CARD_BASEINFO%ROWTYPE; -- ��������Ϣ
        LV_CARD_BASEINFO2  CARD_BASEINFO%ROWTYPE; -- �Ͽ�������Ϣ
        LV_ACCACCOUNTSUB2  ACC_ACCOUNT_SUB%ROWTYPE; -- �Ͽ��˻���Ϣ
        LV_ACTION_LOG      SYS_ACTION_LOG%ROWTYPE; -- ������־��
        LV_SERV_REC        TR_SERV_REC%ROWTYPE; -- �ۺ�ҵ����־��
        LV_CARD_CONFIG     CARD_CONFIG%ROWTYPE; -- ���������ñ�
        LV_BASE_PERSONAL   BASE_PERSONAL%ROWTYPE; -- ��Ա������Ϣ
        LV_CARD_NO         CARD_NO%ROWTYPE; --��Ԥ����Ϣ
        LV_SYS_PARA        SYS_PARA%ROWTYPE; --ϵͳ������
        LV_ACCFREEZEREC    ACC_FREEZE_REC%ROWTYPE; --ϵͳ�����
        LV_PAYCLRPARA      PAY_CLR_PARA%ROWTYPE; --ϵͳ��ֲ�����
        LV_OPERATOR        SYS_USERS%ROWTYPE; --����Ա��Ϣ��
        LV_ACCINOUTDETAIL  ACC_INOUT_DETAIL%ROWTYPE; --�˻���ˮ�˻���Ϣ��
        LV_COUNT           NUMBER;
        LV_IN              VARCHAR2(500); --�������˻��������
        LV_FIRM_IN         VARCHAR2(500); --ת��ȷ�ϵ����
        LV_TRANS_IN        VARCHAR2(500); --ת�˵����
        LV_DEAL_NO         INTEGER;
    BEGIN
        --1.����������Ϣ�ж�
        SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
        IF AS_CARD_NO IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���Ų�������Ϊ��';
            RETURN;
        END IF;
        --2.���ݿ��Ż�ȡ�����¼
        PK_CARD_APPLY_ISSUSE.P_GETCARDAPPLYBYCARDNO(AS_CARD_NO, LV_CARD_APPLY, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --3.����������Ϣ���������Ż�ȡ������Ϣ
        PK_CARD_STOCK.P_GETCARDAPPLYTASKBYTASKID(LV_CARD_APPLY.TASK_ID, LV_CARD_APPLY_TASK, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --4.����������Ϣ�пͻ���Ż�ȡ��Ա��Ϣ
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_APPLY.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --5.���ݿ����ͻ�ȡ������������Ϣ
        PK_CARD_APPLY_ISSUSE.P_GETCARDCONFIGBYCARDTYPE(LV_CARD_APPLY.CARD_TYPE, LV_CARD_CONFIG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        LV_ACTION_LOG.DEAL_CODE := 20403020;
        ---��־Ϊ��������־��Ϣ
        IF AS_DEAL_NO = 0 OR AS_DEAL_NO IS NULL THEN
            ---��������־��Ϣ
            SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_DEAL_NO FROM DUAL;
            LV_ACTION_LOG.DEAL_NO   := LV_DEAL_NO;
            LV_ACTION_LOG.DEAL_CODE := 20401050; ---���˷���
            IF LV_CARD_APPLY.APPLY_TYPE = '2' THEN
                LV_ACTION_LOG.DEAL_CODE := 20501010;
                LV_ACTION_LOG.MESSAGE   := '������' || LV_OPERATOR.BRCH_ID;
                LV_ACTION_LOG.NOTE      := '������' || LV_OPERATOR.BRCH_ID;
                --LV_ACTION_LOG.LV_CANCEL_REASON        := '3'; --����
                -- LV_APPLY_TYPE           := '2';
            ELSE
                IF LV_CARD_APPLY.APPLY_TYPE = '1' THEN
                    LV_ACTION_LOG.DEAL_CODE := 20501020;
                    LV_ACTION_LOG.MESSAGE   := '������' || LV_OPERATOR.BRCH_ID;
                    LV_ACTION_LOG.NOTE      := '������' || LV_OPERATOR.BRCH_ID;
                    --LV_CANCEL_REASON        := '4'; --����
                    -- LV_APPLY_TYPE           := '1'
                END IF;
            END IF;
            LV_ACTION_LOG.ORG_ID    := '1001';
            LV_ACTION_LOG.BRCH_ID   := '10010001';
            LV_ACTION_LOG.USER_ID   := 'admin';
            LV_ACTION_LOG.DEAL_TIME := SYSDATE;
            LV_ACTION_LOG.LOG_TYPE  := 0;
            --LV_ACTION_LOG.IN_OUT_DATA := AV_IN;
            INSERT INTO SYS_ACTION_LOG VALUES LV_ACTION_LOG;
        ELSE
            --ϵͳ��־��Ϣ
            SELECT * INTO LV_ACTION_LOG FROM SYS_ACTION_LOG G WHERE G.DEAL_NO = AS_DEAL_NO;
        END IF;
        ---����Ա��Ϣ
        SELECT * INTO LV_OPERATOR FROM SYS_USERS U WHERE U.USER_ID = LV_ACTION_LOG.USER_ID;
        --���ҿ�������Ϣ
        SELECT COUNT(*) INTO LV_COUNT FROM CARD_BASEINFO C WHERE C.CARD_NO = AS_CARD_NO;
        IF LV_COUNT > 0 THEN
            SELECT * INTO LV_CARD_BASEINFO FROM CARD_BASEINFO C WHERE C.CARD_NO = AS_CARD_NO;
        ELSE
            --���뿨��Ϣ
            INSERT INTO CARD_BASEINFO
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
                 BUS_USE_FLAG)
            VALUES
                (LV_CARD_BASEINFO.CARD_ID,
                 LV_CARD_TASK_LIST.CARD_NO,
                 LV_BASE_PERSONAL.CUSTOMER_ID,
                 LV_CARD_TASK_LIST.CARD_TYPE,
                 LV_OPERATOR.ORG_ID,
                 '1.0',
                 NULL,
                 LV_CARD_TASK_LIST.CITY_CODE,
                 NULL,
                 TO_CHAR(SYSDATE, 'yyyymmdd'),
                 LV_CARD_TASK_LIST.CARDISSUEDATE,
                 LV_CARD_TASK_LIST.VALIDITYDATE,
                 LV_CARD_TASK_LIST.VALIDITYDATE,
                 NULL,
                 NULL, --��������
                 0,
                 '000000',
                 0,
                 '1',
                 SYSDATE,
                 0,
                 0,
                 0,
                 0,
                 LV_CARD_TASK_LIST.BANK_ID,
                 LV_CARD_TASK_LIST.BANK_ID,
                 '',
                 LV_CARD_TASK_LIST.CARD_TYPE,
                 '',
                 LV_CARD_TASK_LIST.BAR_CODE,
                 '',
                 '',
                 '0',
                 '',
                 LV_CARD_TASK_LIST.BANK_ID,
                 LV_CARD_BASEINFO.CARD_ID,
                 LV_BASE_PERSONAL.MOBILE_NO,
                 0,
                 NULL,
                 '01',
                 '01');
            SELECT * INTO LV_CARD_BASEINFO FROM CARD_BASEINFO C WHERE C.CARD_NO = AS_CARD_NO;
        END IF;
        --ȡ����Ԥ������Ϣ
        SELECT * INTO LV_CARD_NO FROM CARD_NO N WHERE N.CARD_NO = AS_CARD_NO;
        --�����˻����
        LV_IN := LV_ACTION_LOG.DEAL_NO || '|' || LV_ACTION_LOG.DEAL_CODE || '|' ||
                 LV_ACTION_LOG.USER_ID || '|' ||
                 TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-MM-dd HH:mm:ss') || '|' || 1 || '|' ||
                 LV_CARD_APPLY.CARD_TYPE || '|' || LV_CARD_APPLY.CARD_NO || '|' ||
                 TRADE_PWD_DEFAULT || '|' || LV_CARD_NO.BAL_CRYPT;
        --���˻�
        --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5OBJ_TYPE|SUB_TYPE|7OBJ_ID|8PWD|9ENCRYPT      ���˻��������(�������ʱ��֮����,�ָ� ENCRYPT1,ENCRYPT2)
        PK_BUSINESS.P_CREATEACCOUNT(LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            ROLLBACK;
            RETURN;
        END IF;
        UPDATE CARD_APPLY A
           SET A.RELS_DATE = LV_ACTION_LOG.DEAL_TIME, A.APPLY_STATE = '60'
         WHERE A.APPLY_ID = LV_CARD_APPLY.APPLY_ID;
        --�Ƿ�Ϊ����������0�������죬1������2����
        IF LV_CARD_APPLY.APPLY_TYPE = '1' OR LV_CARD_APPLY.APPLY_TYPE = '2' THEN
            --���·���ʱ������¼�¼---ͨ��������Ϣ���Ͽ���ȥ�Ҷ�����Ϣ
            --�Ͽ��˻���Ϣ
            SELECT COUNT(1)
              INTO LV_COUNT
              FROM ACC_ACCOUNT_SUB AAS
             WHERE AAS.CARD_NO = LV_CARD_APPLY.OLD_CARD_NO
               AND AAS.ACC_KIND = '02';
            IF LV_COUNT > 0 THEN
                SELECT *
                  INTO LV_ACCACCOUNTSUB2
                  FROM ACC_ACCOUNT_SUB AAS
                 WHERE AAS.CARD_NO = LV_CARD_APPLY.OLD_CARD_NO
                   AND AAS.ACC_KIND = '02';
            END IF;
            ---ͨ��������Ϣ���Ͽ���ȥ�Ҷ�����Ϣ
            FOR LREC_ACC_FREEZE_REC IN (SELECT *
                                          FROM ACC_FREEZE_REC AFR
                                         WHERE AFR.CARD_NO = LV_CARD_APPLY.OLD_CARD_NO
                                           AND AFR.REC_TYPE = '0'
                                           AND AFR.DEAL_CODE = 50601010) LOOP
                LV_ACCFREEZEREC := LREC_ACC_FREEZE_REC;
                SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_ACCFREEZEREC.DEAL_NO FROM DUAL;
                --LV_ACCFREEZEREC.DEAL_NO   := SEQ_ACTION_NO.NEXTVAL;
                LV_ACCFREEZEREC.DEAL_CODE := 50601010; --���᣺50601010--�ⶳ50601021
                LV_ACCFREEZEREC.CARD_NO   := LV_CARD_APPLY.CARD_NO;
                INSERT INTO ACC_FREEZE_REC VALUES LV_ACCFREEZEREC;
                --�����Ͽ��Ķ�����Ϊ�ⶳ״̬
                UPDATE ACC_FREEZE_REC R
                   SET R.REC_TYPE = '1', R.CARD_NO = LV_CARD_APPLY.CARD_NO
                 WHERE R.DEAL_NO = LREC_ACC_FREEZE_REC.DEAL_NO;
            END LOOP;
        END IF; --����������
        --ͬ�����¿��
        IF AS_STOCK_FLAG = '0' THEN
            IF LV_CARD_CONFIG.IS_STOCK = '0' THEN
                PK_CARD_STOCK.P_UPDATECARDSTOCK(AS_CARD_NO, '', AS_DEAL_NO, AV_MSG, AV_RES);
                IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                    ROLLBACK;
                    RETURN;
                END IF;
            END IF;
        END IF;
        --ͬ��������ƽ̨
        IF AS_SYNCH2CARDUPATE = '0' THEN
            P_SYNCH2CARD_UPATE(LV_CARD_APPLY.TASK_ID, LV_BASE_PERSONAL.CERT_NO, LV_CARD_APPLY.CARD_NO, LV_CARD_APPLY.OLD_CARD_NO, AS_DEAL_NO, LV_CARD_APPLY.APPLY_TYPE, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                ROLLBACK;
                RETURN;
            END IF;
        END IF;
        --��������״̬
        UPDATE CARD_APPLY_TASK A
           SET A.TASK_STATE = '50'
         WHERE A.TASK_ID = LV_CARD_APPLY.TASK_ID
           AND (TASK_STATE = '20' OR TASK_STATE = '40');
        SELECT COUNT(*)
          INTO LV_COUNT
          FROM CARD_APPLY CA
         WHERE CA.TASK_ID = LV_CARD_APPLY.TASK_ID
           AND (CA.APPLY_STATE <> '60' OR CA.APPLY_STATE <> '90');
        IF LV_COUNT = 0 THEN
            --�������
            UPDATE CARD_APPLY_TASK A
               SET A.TASK_STATE = '60'
             WHERE A.TASK_ID = LV_CARD_APPLY.TASK_ID
               AND TASK_STATE = '50';
        END IF;
        --����ҵ����Ϣ
        LV_SERV_REC.DEAL_NO       := LV_ACTION_LOG.DEAL_NO; --//ҵ����ˮ��
        LV_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID; --//������
        LV_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO; --//���񿨿���
        LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID; --//�ͻ����
        LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME; --//�ͻ�����
        LV_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE; --//֤������
        LV_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO; --//֤������
        LV_SERV_REC.DEAL_CODE     := LV_ACTION_LOG.DEAL_CODE; --//���״���
        LV_SERV_REC.CARD_TYPE     := LV_CARD_APPLY.CARD_TYPE; --//������
        LV_SERV_REC.CARD_AMT      := 1; --//��������
        LV_SERV_REC.BIZ_TIME      := LV_ACTION_LOG.DEAL_TIME; --//ҵ�����ʱ��
        LV_SERV_REC.USER_ID       := LV_ACTION_LOG.USER_ID; --//�������Ա���
        LV_SERV_REC.BRCH_ID       := LV_CARD_APPLY.APPLY_BRCH_ID;
        LV_SERV_REC.DEAL_STATE    := '0'; --//ҵ��״̬(0����1����)
        LV_SERV_REC.CLR_DATE      := LV_PAYCLRPARA.CLR_DATE; --//�������(YYYY-MM-DD)
        LV_SERV_REC.RTN_FGFT      := 0; --// Ѻ�������ͷ������ô��ֶΣ�������ʱ������Ѻ��
        INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
        --���¿������޸�ʱ�估�Ŀ�״̬
        UPDATE CARD_BASEINFO C
           SET C.LAST_MODIFY_DATE = SYSDATE, C.CARD_STATE = '1', C.BANK_CARD_NO = AS_BANK_NO
         WHERE C.CARD_NO = AS_CARD_NO;
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := NVL(SQLERRM, SQLERRM);
            ROLLBACK;
            UPDATE SYS_ACTION_LOG
               SET IN_OUT_DATA = IN_OUT_DATA || '------����ʧ�ܣ�������Ϣ��{' || AV_RES || ',' ||
                                  REPLACE(AV_MSG, '''', '��') || '}'
             WHERE DEAL_NO = AS_DEAL_NO;
    END P_ONECARD_ISSUSE;
    /*=======================================================================================*/
    --��ģ���Ž����ֻ���
    /*=======================================================================================*/
    PROCEDURE P_BATCH_ISSUSE(AS_DEAL_CODE IN ACC_INOUT_DETAIL.DEAL_CODE%TYPE, --���״���
                             AS_TASKID IN CARD_APPLY.TASK_ID%TYPE, --�����
                             AS_CARD_TYPE IN CARD_BASEINFO.CARD_TYPE%TYPE, --������
                             AS_DEAL_NO IN INTEGER, --ҵ����ˮ��
                             AV_MSG OUT VARCHAR2, --��������
                             AV_RES OUT VARCHAR2) IS
        LV_DBSUBLEDGER     ACC_ACCOUNT_SUB%ROWTYPE; --�跽�ֻ���
        LV_CRSUBLEDGER     ACC_ACCOUNT_SUB%ROWTYPE; --���ֻ���
        LV_BOOK            ACC_INOUT_DETAIL%ROWTYPE; --�˻���ˮ
        LV_CARDCONFIG      CARD_CONFIG%ROWTYPE; --��ҵ�������
        LV_OPERATOR        SYS_USERS%ROWTYPE; --��Ա��Ϣ
        LV_PAYCLRPARA      PAY_CLR_PARA%ROWTYPE; --��������Ʋ���
        LV_CARD_APPLY_TASK CARD_APPLY_TASK%ROWTYPE; -- ������Ϣ
        LV_CARD_BASEINFO   CARD_BASEINFO%ROWTYPE; -- ��������Ϣ
        LV_CARD_BASEINFO2  CARD_BASEINFO%ROWTYPE; -- �Ͽ�������Ϣ
        LV_ACCACCOUNTSUB2  ACC_ACCOUNT_SUB%ROWTYPE; -- �Ͽ��˻���Ϣ
        LV_ACTION_LOG      SYS_ACTION_LOG%ROWTYPE; -- ������־��
        LV_BASEPERSONAL    BASE_PERSONAL%ROWTYPE; -- ��Ա����
        LV_CARDAPPLY       CARD_APPLY%ROWTYPE; -- ������Ϣ
        LV_COUNT           INTEGER;
        LV_IN              VARCHAR2(500); --�������˻��������
        LV_CARD_NO         CARD_NO%ROWTYPE; --��Ԥ����Ϣ
        LV_SYS_PARA        SYS_PARA%ROWTYPE; --ϵͳ������
    BEGIN
        AV_MSG := '';
        --��ֲ�����Ϣ
        SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA;
        --��������Ϣ
        SELECT * INTO LV_CARDCONFIG FROM CARD_CONFIG CC WHERE CC.CARD_TYPE = AS_CARD_TYPE;
        --������Ϣ
        SELECT COUNT(*)
          INTO LV_COUNT
          FROM CARD_APPLY C
         WHERE C.TASK_ID = AS_TASKID
           AND C.APPLY_STATE = '50';
        IF LV_COUNT = 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_APPLY1;
            AV_MSG := '�޷��ҵ�������Ϣ';
            RETURN;
        END IF;
        --����������Ϣ
        SELECT COUNT(*)
          INTO LV_COUNT
          FROM CARD_APPLY_TASK K
         WHERE 1 = 1
           AND K.TASK_ID = AS_TASKID;
        IF LV_COUNT = 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_APPLY1;
            AV_MSG := '�޷��ҵ��ƿ�������Ϣ';
            RETURN;
        ELSE
            --������Ϣ
            /* SELECT *
            INTO LV_CARDAPPLY
            FROM CARD_APPLY K
            WHERE K.APPLY_STATE = '50'
            AND K.TASK_ID = AS_TASKID;*/
            --������Ϣ
            SELECT *
              INTO LV_CARD_APPLY_TASK
              FROM CARD_APPLY_TASK K
             WHERE K.TASK_STATE = '40'
               AND K.TASK_ID = AS_TASKID;
        END IF;
        --��־��Ϣ
        SELECT COUNT(*) INTO LV_COUNT FROM SYS_ACTION_LOG L WHERE L.DEAL_NO = AS_DEAL_NO;
        IF LV_COUNT = 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_APPLY1;
            AV_MSG := '�޷��ҵ���־��Ϣ';
            RETURN;
        ELSE
            --��־��Ϣ
            SELECT * INTO LV_ACTION_LOG FROM SYS_ACTION_LOG L WHERE L.DEAL_NO = AS_DEAL_NO;
        END IF;
        ---����Ա��Ϣ
        SELECT * INTO LV_OPERATOR FROM SYS_USERS U WHERE U.USER_ID = LV_ACTION_LOG.USER_ID;
        /*    SELECT *
        INTO LV_CARD_NO
        FROM CARD_NO C
        WHERE C.CARD_NO = LV_CARDAPPLY.CARD_NO;*/
        --��������Ϣ
        SELECT * INTO LV_CARDCONFIG FROM CARD_CONFIG G WHERE G.CARD_TYPE = AS_CARD_TYPE;
        --ѭ�������˻���Ϣ
        FOR LREC_CARD IN (SELECT C.CARD_ID, A.CUSTOMER_ID, C.CARD_NO, A.CARD_TYPE, A.MAIN_FLAG
                            FROM CARD_APPLY A, CARD_BASEINFO C
                           WHERE A.CARD_TYPE = C.CARD_TYPE
                             AND A.CARD_NO = C.CARD_NO
                             AND A.TASK_ID = AS_TASKID) LOOP
            --��Ա������Ϣ
            SELECT *
              INTO LV_BASEPERSONAL
              FROM BASE_PERSONAL B
             WHERE B.CUSTOMER_ID = LREC_CARD.CUSTOMER_ID;
            --��ѯ�������
            SELECT O.BAL_CRYPT
              INTO LV_CARD_NO.BAL_CRYPT
              FROM CARD_NO O
             WHERE O.CARD_NO = LREC_CARD.CARD_NO;
            --�����˻����
            LV_IN := LV_ACTION_LOG.DEAL_NO || '|' || LV_ACTION_LOG.DEAL_CODE || '|' ||
                     LV_ACTION_LOG.USER_ID || '|' ||
                     TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-MM-dd HH:mm:ss') || '|' || 1 || '|' ||
                     LREC_CARD.CARD_TYPE || '|' || LREC_CARD.CARD_NO || '|' || TRADE_PWD_DEFAULT || '|' ||
                     LV_CARD_NO.BAL_CRYPT;
            --���˻�
            --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5OBJ_TYPE|SUB_TYPE|7OBJ_ID|8PWD|9ENCRYPT      ���˻��������(�������ʱ��֮����,�ָ� ENCRYPT1,ENCRYPT2)
            PK_BUSINESS.P_CREATEACCOUNT(LV_IN, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                ROLLBACK;
                RETURN;
            END IF;
        END LOOP;
        --���÷��ؽ��
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_BATCH_ISSUSE;
    /*=======================================================================================*/
    --ͬ�����籣 TASKID,BS_PERSON PERSON,CM_CARD CARD,CM_CARD OLDCARD,SYS_ACTION_LOG LOG,STRING APPLYTYPE,LONG COUNT
    --ע�⣺���ڹ��������֧�ֹ�ģ�����еĸ��˷��ţ�����ڹ�ģ���ŵ��ñ��ӿ�ʱ�����ڸ�������״̬ǰ���ñ��ӿڣ�
    --��ȷ�����η�����Ҫͬ���Ĳα���Ϣ�������ظ�ͬ���α���Ϣ
    --1�·���2����3����4��ʧ5���6ע��
    /*=======================================================================================*/
    PROCEDURE P_SYNCH2CARD_UPATE(AS_TASKID VARCHAR2, --������ ��ģ���ŵ�ʱ��ʹ��
                                 AS_CERT_NO VARCHAR2, --֤������
                                 AS_CARD_NO1 VARCHAR2, --�¿�����
                                 AS_CARD_NO2 VARCHAR2, --�ɿ�����
                                 AS_DEAL_NO INTEGER, --������ˮ
                                 AS_APPLYTYPE VARCHAR2, --��������
                                 AV_RES OUT VARCHAR2, --������������
                                 AV_MSG OUT VARCHAR2 --��������������Ϣ
                                 ) IS
        LV_CARD_BASEINFO  CARD_BASEINFO%ROWTYPE; -- ��������Ϣ
        LV_CARD_BASEINFO2 CARD_BASEINFO%ROWTYPE; -- �Ͽ�������Ϣ
        LV_ACTION_LOG     SYS_ACTION_LOG%ROWTYPE; -- ������־��
        LV_BASE_PERSONAL  BASE_PERSONAL%ROWTYPE; -- ��Ա������Ϣ
        LV_COUNT          NUMBER;
        LV_BIZ_TYPE       VARCHAR2(1) := '1'; --����ҵ������
        LV_CARD_APPLY     CARD_APPLY%ROWTYPE;
    BEGIN
        IF AS_DEAL_NO IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := 'ͬ���籣��Ϣ���ִ���ҵ����ˮ��Ų���Ϊ��';
            RETURN;
        END IF;
        BEGIN
            SELECT * INTO LV_ACTION_LOG FROM SYS_ACTION_LOG L WHERE L.DEAL_NO = AS_DEAL_NO;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := 'ͬ���籣��Ϣ���ִ��󣬸�����ˮ���' || AS_DEAL_NO || '�Ҳ���������־��Ϣ';
                RETURN;
            WHEN TOO_MANY_ROWS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := 'ͬ���籣��Ϣ���ִ��󣬸�����ˮ���' || AS_DEAL_NO || '�ҵ�����������־��Ϣ';
                RETURN;
            WHEN OTHERS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := 'ͬ���籣��Ϣ���ִ��󣬸�����ˮ���' || AS_DEAL_NO || '��ȡ������־��Ϣ���ִ���' || SQLERRM;
                RETURN;
        END;
        PK_PUBLIC.P_INSERTRZCLLOG('pk_card_apply_issuse.p_synch2card_upate:' || AS_TASKID || '|' ||
                                  AS_CERT_NO || '|' || AS_CARD_NO1 || '|' || AS_CARD_NO2 ||
                                  AS_DEAL_NO || '|' || AS_APPLYTYPE || '|', LV_ACTION_LOG.DEAL_NO);
        IF LV_ACTION_LOG.DEAL_CODE = 20401060 THEN
            LV_BIZ_TYPE := '1';
            SELECT COUNT(*) INTO LV_COUNT FROM CARD_TASK_LIST L WHERE L.TASK_ID = AS_TASKID;
            IF LV_COUNT = 0 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := 'ͬ���籣��Ϣ���ִ��󣬸���������' || AS_TASKID || '�Ҳ���������ϸ��Ϣ';
                RETURN;
            END IF;
            INSERT INTO CARD_UPDATE
                (CARDUPDATESEQ,
                 CLIENTID,
                 SUB_CARDID,
                 SUB_CARDNUMBER,
                 NAME,
                 CERTTYPE,
                 CERTNUMBER,
                 SEX,
                 CARDBIZTYPE,
                 OLD_SUBCARDID,
                 OLD_SUBCARDNUMBER,
                 PERSONALID,
                 SWITCHNODE,
                 UPDATETIME,
                 ACTIONNO,
                 CARD_TYPE,
                 VERSION,
                 ORG_CODE,
                 ISSUE_DATE,
                 VALID_DATE,
                 NATION,
                 BIRTHDAY,
                 RESIDE_ADDR,
                 MED_WHOLE_NO,
                 PRO_ORG_CODE,
                 PRO_MEDIA_TYPE,
                 PRO_VERSION,
                 PRO_INIT_DATE,
                 CLBZ,
                 CLSJ,
                 STCLSJ,
                 NOTE)
                SELECT SEQ_CARD_UPDATE_XH.NEXTVAL, B.CUSTOMER_ID, D.SUB_CARD_ID, D.SUB_CARD_NO, B.NAME, B.CERT_TYPE, B.CERT_NO, B.GENDER, LV_BIZ_TYPE, P.OLD_SUB_CARD_ID, P.OLD_SUB_CARD_NO, S.PERSONAL_ID, '04', SYSDATE, AS_DEAL_NO, D.CARD_TYPE, D.VERSION, D.INIT_ORG_ID, D.ISSUE_DATE, D.VALID_DATE, B.NATION, B.BIRTHDAY, B.LETTER_ADDR, S.MED_WHOLE_NO, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL
                  FROM CARD_TASK_LIST L, CARD_BASEINFO D, BASE_PERSONAL B, BASE_SIINFO S, CARD_APPLY P
                 WHERE L.CARD_NO = D.CARD_NO
                   AND D.CUSTOMER_ID = B.CUSTOMER_ID
                   AND B.CERT_NO = S.CERT_NO
                   AND L.APPLY_ID = P.APPLY_ID
                   AND P.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS
                   AND L.TASK_ID = AS_TASKID
                   AND S.RESERVE_7 <> '1';
        ELSE
            PK_PUBLIC.P_GETBASEPERSONALBYCERTNO(AS_CERT_NO, LV_BASE_PERSONAL, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                AV_MSG := 'ͬ���籣��Ϣ���ִ���' || AV_MSG;
                RETURN;
            END IF;
            IF LV_ACTION_LOG.DEAL_CODE IN ('20501040', '20501050') THEN
                --��ʧ,��ͷ��ʧ
                LV_BIZ_TYPE := '4';
            ELSIF LV_ACTION_LOG.DEAL_CODE = '20501060' THEN
                --���
                LV_BIZ_TYPE := '5';
            ELSIF LV_ACTION_LOG.DEAL_CODE IN ('20501070','20501010','20501020') THEN
                --ע��
                LV_BIZ_TYPE := '6';
            ELSIF LV_ACTION_LOG.DEAL_CODE = '20401050' THEN
                --���˷���
                IF LV_BIZ_TYPE IS NULL OR AS_APPLYTYPE NOT IN ('0', '1', '2') THEN
                    AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
                    AV_MSG := 'ͬ���籣��Ϣ���ִ����������Ͳ���ȷ';
                    RETURN;
                END IF;
                PK_CARD_APPLY_ISSUSE.P_GETCARDAPPLYBYCARDNO(AS_CARD_NO1, LV_CARD_APPLY, AV_RES, AV_MSG);
                IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                    AV_MSG := 'ͬ���籣��Ϣ���ִ���' || AV_MSG;
                    RETURN;
                END IF;
                IF AS_APPLYTYPE = '1' THEN
                    --����
                    LV_BIZ_TYPE := '3';
                ELSIF AS_APPLYTYPE = '2' THEN
                    --����
                    LV_BIZ_TYPE := '2';
                END IF;
            END IF;
            INSERT INTO CARD_UPDATE
                (CARDUPDATESEQ,
                 CLIENTID,
                 SUB_CARDID,
                 SUB_CARDNUMBER,
                 NAME,
                 CERTTYPE,
                 CERTNUMBER,
                 SEX,
                 CARDBIZTYPE,
                 OLD_SUBCARDID,
                 OLD_SUBCARDNUMBER,
                 PERSONALID,
                 SWITCHNODE,
                 UPDATETIME,
                 ACTIONNO,
                 CARD_TYPE,
                 VERSION,
                 ORG_CODE,
                 ISSUE_DATE,
                 VALID_DATE,
                 NATION,
                 BIRTHDAY,
                 RESIDE_ADDR,
                 MED_WHOLE_NO,
                 PRO_ORG_CODE,
                 PRO_MEDIA_TYPE,
                 PRO_VERSION,
                 PRO_INIT_DATE,
                 CLBZ,
                 CLSJ,
                 STCLSJ,
                 NOTE)
                SELECT SEQ_CARD_UPDATE_XH.NEXTVAL, B.CUSTOMER_ID, D.SUB_CARD_ID, D.SUB_CARD_NO, B.NAME, B.CERT_TYPE, B.CERT_NO, B.GENDER, LV_BIZ_TYPE, LV_CARD_APPLY.OLD_SUB_CARD_ID, LV_CARD_APPLY.OLD_SUB_CARD_NO, S.PERSONAL_ID, '04', SYSDATE, AS_DEAL_NO, D.CARD_TYPE, D.VERSION, D.INIT_ORG_ID, D.ISSUE_DATE, D.VALID_DATE, B.NATION, B.BIRTHDAY, B.LETTER_ADDR, S.MED_WHOLE_NO, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL
                  FROM CARD_BASEINFO D, BASE_PERSONAL B, BASE_SIINFO S
                 WHERE D.CUSTOMER_ID = B.CUSTOMER_ID
                   AND B.CERT_NO = S.CERT_NO
                   AND D.CARD_NO = AS_CARD_NO1
                   AND B.CERT_NO = AS_CERT_NO
                   AND S.RESERVE_7 <> '1';
            /* IF SQL%ROWCOUNT < 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := 'ͬ���籣��Ϣ���ִ���ͬ��0����������Ϣ�����α���Ϣ������';
            END IF;*/
        END IF;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
            ROLLBACK;
            RETURN;
    END P_SYNCH2CARD_UPATE;
    /*=======================================================================================*/
    --����������ϸ
    /*=======================================================================================*/
    PROCEDURE P_INSERTCARDTASKLIST(AV_TASKID IN VARCHAR2, --�����
                                   AV_DEBUG IN VARCHAR2, --����0�ǣ�1��
                                   AV_RES OUT VARCHAR2, --������������
                                   AV_MSG OUT VARCHAR2 --��������������Ϣ
                                   ) IS
        LV_CARDAPPLYTASK CARD_APPLY_TASK%ROWTYPE; -- ������ϸ��Ϣ
        LV_ACTION_LOG    SYS_ACTION_LOG%ROWTYPE; -- ������־��
        LV_SERV_REC      TR_SERV_REC%ROWTYPE; -- �ۺ�ҵ����־��
        LV_CARDCONFIG    CARD_CONFIG%ROWTYPE; -- ������
        LV_DEAL_NO       SYS_ACTION_LOG.DEAL_NO%TYPE; -- ��ˮ��
        LV_COUNT         NUMBER;
        LV_SYSPARA       SYS_PARA%ROWTYPE; -- ������
        AS_NDATE         VARCHAR2(10);
        AS_LSDATE        VARCHAR2(10);
    BEGIN
        AS_USEFLAG := '01';
        --//1.��ȡָ����������صĲ�����Ϣ
        SELECT * INTO LV_CARDAPPLYTASK FROM CARD_APPLY_TASK C WHERE C.TASK_ID = AV_TASKID;
        SELECT COUNT(*)
          INTO LV_COUNT
          FROM CARD_CONFIG CC
         WHERE CC.CARD_TYPE = LV_CARDAPPLYTASK.CARD_TYPE;
        IF LV_COUNT = 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�ÿ����Ͳ���������Ϣ������';
            RETURN;
        END IF;
        SELECT *
          INTO LV_CARDCONFIG
          FROM CARD_CONFIG CC
         WHERE CC.CARD_TYPE = LV_CARDAPPLYTASK.CARD_TYPE;
        IF LV_CARDCONFIG.CARD_VALIDITY_PERIOD IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�ÿ����Ϳ�Ƭ��Ч��������Ϣδ����';
            RETURN;
        END IF;
        AS_NDATE  := TO_CHAR(LV_CARDAPPLYTASK.TASK_DATE, 'yyyy-MM-dd'); --��ǰ����
        AS_LSDATE := ADD_MONTHS(LV_CARDAPPLYTASK.TASK_DATE, LV_CARDCONFIG.CARD_VALIDITY_PERIOD * 12); --��Ч����
        --//2.�����ƿ���ϸ
        INSERT INTO CARD_TASK_LIST
            (DATA_SEQ,
             TASK_ID,
             CUSTOMER_ID,
             NAME,
             SEX,
             CERT_TYPE,
             CERT_NO,
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
             CARD_TYPE,
             CARD_NO,
             VERSION,
             INIT_ORG_ID,
             CITY_CODE,
             INDUS_CODE,
             CARDISSUEDATE,
             VALIDITYDATE,
             BURSESTARTDATE,
             BURSEVALIDDATE,
             MONTHSTARTDATE,
             MONTHVALIDDATE,
             STRUCT_MAIN_TYPE,
             STRUCT_CHILD_TYPE,
             FACE_VAL,
             PWD,
             BAR_CODE,
             COMM_ID,
             BURSEBALANCE,
             MONTHBALANCE,
             BANK_ID,
             BANKCARDNO,
             BANKSECTION2,
             BANKSECTION3,
             PHOTOFILENAME,
             USEFLAG,
             DEPARTMENT,
             CLASSID,
             APPLY_ID,
             MONTH_TYPE,
             HLHT_FLAG,
             SUB_CARD_NO,
             TOUCH_STARTDATE,
             TOUCH_VALIDDATE)
            (SELECT SEQ_DATA_SEQ.NEXTVAL, A.TASK_ID, B.CUSTOMER_ID, B.NAME, B.GENDER, B.CERT_TYPE, B.CERT_NO, B.NATION, '', SUBSTR(B.CERT_NO, 7, 8), B.RESIDE_TYPE, B.RESIDE_ADDR, B.LETTER_ADDR, B.POST_CODE, B.MOBILE_NO, B.EDUCATION, B.MARR_STATE, A.CARD_TYPE, A.CARD_NO, A.VERSION, A.ORG_CODE, A.CITY_CODE, A.INDUS_CODE, AS_NDATE, AS_LSDATE, AS_NDATE, AS_LSDATE, AS_NDATE, AS_NDATE, A.BUS_TYPE, '', '0', AS_INIT_SERVPWD, A.BAR_CODE, B.COMM_ID, '0000000000', '0000000000', A.BANK_ID, A.BANK_CARD_NO, '', '', B.CERT_NO ||
                     '.jpg', AS_USEFLAG, B.DEPARTMENT, B.CLASSID, A.APPLY_ID, AS_MONTH_TYPE, '7500', A.SUB_CARD_NO, AS_NDATE, AS_LSDATE
               FROM CARD_APPLY A, BASE_PERSONAL B
              WHERE B.CUSTOMER_ID = A.CUSTOMER_ID
                AND A.APPLY_STATE = '1'
                AND A.TASK_ID = LV_CARDAPPLYTASK.TASK_ID);
        --//3.����֤�����͡�����״��
        UPDATE CARD_TASK_LIST C
           SET C.MARR_STATE =
                (DECODE(C.MARR_STATE, '10', '1', '20', '2', '21', '2', '22', '2', '23', '2', '30', '3', '40', '4', '10'))
         WHERE C.TASK_ID = LV_CARDAPPLYTASK.TASK_ID;
        --//4.����ѧ���������Ͽ���Ӧ������  //ѧ������Ǯ��Ӧ����Ч����Ϊ18��ֹ//TO_DATE(BIRTHDAY,'yyyyMMdd')
        UPDATE CARD_TASK_LIST C
           SET BURSEVALIDDATE = TO_CHAR(ADD_MONTHS(TO_DATE(BURSESTARTDATE, 'yyyymmdd'), (18 * 12 -
                                                     MONTHS_BETWEEN(SYSDATE, TO_DATE(C.BIRTHDAY, 'yyyymmdd')))), 'yyyymmdd'), TOUCH_VALIDDATE = TO_CHAR(ADD_MONTHS(TO_DATE(BURSESTARTDATE, 'yyyymmdd'), (18 * 12 -
                                                      MONTHS_BETWEEN(SYSDATE, TO_DATE(C.BIRTHDAY, 'yyyymmdd')))), 'yyyymmdd')
         WHERE C.STRUCT_MAIN_TYPE = '10'
           AND C.TASK_ID = LV_CARDAPPLYTASK.TASK_ID;
        -- //���°�������˿���Ǯ��Ӧ����Ч����Ϊ70��ֹ
        UPDATE CARD_TASK_LIST C
           SET BURSEVALIDDATE = TO_CHAR(ADD_MONTHS(TO_DATE(BURSESTARTDATE, 'yyyymmdd'), (70 * 12 -
                                                     MONTHS_BETWEEN(SYSDATE, TO_DATE(C.BIRTHDAY, 'yyyymmdd')))), 'yyyymmdd'), TOUCH_VALIDDATE = TO_CHAR(ADD_MONTHS(TO_DATE(BURSESTARTDATE, 'yyyymmdd'), (70 * 12 -
                                                      MONTHS_BETWEEN(SYSDATE, TO_DATE(C.BIRTHDAY, 'yyyymmdd')))), 'yyyymmdd')
         WHERE C.STRUCT_MAIN_TYPE = '11'
           AND C.TASK_ID = LV_CARDAPPLYTASK.TASK_ID;
        ----��ѯ����
        SELECT COUNT(*) INTO LV_COUNT FROM CARD_TASK_LIST L WHERE L.TASK_ID = AV_TASKID;
        IF LV_COUNT <> LV_CARDAPPLYTASK.TASK_SUM THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�����ƿ���ϸ�������ƿ������ж����������һ��';
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := NVL(SQLERRM, SQLERRM);
            ROLLBACK;
            UPDATE SYS_ACTION_LOG
               SET IN_OUT_DATA = IN_OUT_DATA || '------����ʧ�ܣ�������Ϣ��{' || AV_RES || ',' ||
                                  REPLACE(AV_MSG, '''', '��') || '}'
             WHERE DEAL_NO = LV_DEAL_NO;
            COMMIT;
    END P_INSERTCARDTASKLIST;
    /*=======================================================================================*/
    --�����ƿ�
    -- AV_IN:
    -- 1�������
    -- 2���������
    -- 3����Ա
    -- 4������ˮ
    -- 5����
    -- 6�Ա�
    -- 7֤������
    -- 8֤������
    -- 9������
    -- 10���񿨿���
    -- 11����
    -- 12�������� 0 ���� 1 ���
    -- 13�������ڳ���
    -- 14�����������򣨽ֵ���
    -- 15�������ڴ壨������
    -- 16��ס��ַ
    -- 17��ϵ��ַ
    -- 18��������
    -- 19�̶��绰
    -- 20�ֻ�����
    -- 21�����ʼ�
    -- 22��λ�ͻ�����
    -- 23��ע
    -- 24������--��λ����
    -- 25�Ӽ���--��λ����
    -- 26������֤������
    -- 27������֤������
    -- 28����������
    -- 29��������ϵ�绰
    -- 30�Ƿ��ж�����Ƭ
    -- 31�Ƿ��жϲα�
    -- 32�ƿ���ʽ
    -- 33��������
    -- 34���б��
    -- 35���п���
    -- 36ͳ��������
    -- 37��ע
    -- AV_OUT��1 ҵ����ˮ
    /*=======================================================================================*/
    PROCEDURE P_APPLYCARD(AV_IN IN VARCHAR2, AV_DEBUG IN VARCHAR2, AV_OUT OUT VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
        LV_COUNT           NUMBER;
        LV_IN              PK_PUBLIC.MYARRAY; --�����������
        LV_USERS           SYS_USERS%ROWTYPE;
        LV_BASE_PERSONAL   BASE_PERSONAL%ROWTYPE; --��Ա������Ϣ
        LV_BASE_REGION     BASE_REGION%ROWTYPE;
        LV_BASE_CORP       BASE_CORP%ROWTYPE; --��λ������Ϣ
        LV_BASE_CO_ORG     BASE_CO_ORG%ROWTYPE; --��������
        LV_CLRDATE         PAY_CLR_PARA.CLR_DATE%TYPE; --�������
        LV_CARD_APPLY      CARD_APPLY%ROWTYPE; --���������Ϣ
        LV_CARD_APPLY_TASK CARD_APPLY_TASK%ROWTYPE; -- ������Ϣ
        LV_CARD_TASK_LIST  CARD_TASK_LIST%ROWTYPE; -- ������ϸ��Ϣ
        LV_ACTION_LOG      SYS_ACTION_LOG%ROWTYPE; -- ������־��
        LV_SERV_REC        TR_SERV_REC%ROWTYPE; -- �ۺ�ҵ����־��
        LV_BASE_CITY       BASE_CITY%ROWTYPE; -- ����������
        LV_CITY_CODE       SYS_PARA.PARA_VALUE%TYPE; --���д���
        LV_DEAL_NO         SYS_ACTION_LOG.DEAL_NO%TYPE; -- ��ˮ��
        LV_SELFMANAGEMENT  SYS_PARA.PARA_VALUE%TYPE;
        LV_IN_PARA         VARCHAR2(200); --���
        LV_APPLY_STATE     CARD_APPLY.APPLY_STATE%TYPE; --����״̬
        LV_APPLY_ID        CARD_APPLY.APPLY_ID%TYPE;
        LV_CARD_FLAG       VARCHAR2(1);
    BEGIN
        --1.������Ϣ����
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 34, 37, 'PK_CARD_APPLY_ISSUSE.P_APPLYCARD', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --2.������ж�
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(30) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�Ƿ��ж���Ƭ��������Ϊ��';
            RETURN;
        ELSIF LV_IN(30) <> '0' AND LV_IN(30) <> '1' THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�Ƿ��ж���Ƭ����ֵֻ����0��1';
            RETURN;
        END IF;
        IF LV_IN(31) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�Ƿ��жϲα���Ϣ��������Ϊ��';
            RETURN;
        ELSIF LV_IN(31) <> '0' AND LV_IN(31) <> '1' THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�Ƿ��жϲα���Ϣ����ֵֻ����0��1';
            RETURN;
        END IF;
        IF LV_IN(32) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�ƿ���ʽ����Ϊ��';
            RETURN;
        ELSIF LV_IN(32) <> '0' AND LV_IN(32) <> '1' THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�ƿ���ʽ����ֵֻ����0��1';
            RETURN;
        END IF;
        IF LV_IN(33) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�������Ͳ���Ϊ��';
            RETURN;
        END IF;
        IF LV_IN(36) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := 'ͳ��������Ϊ��';
            RETURN;
        END IF;
        LV_CITY_CODE := PK_PUBLIC.F_GETSYSPARA('CITY_CODE');
        IF LV_CITY_CODE = '0' THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '���д�����Ϣδ����';
            RETURN;
        ELSIF LV_CITY_CODE IN ('-1', '0') THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '��ȡ���д�����ִ���';
            RETURN;
        END IF;
        BEGIN
            SELECT MAX(CARD_FLAG) INTO LV_CARD_FLAG FROM BASE_REGION WHERE CITY_ID = LV_IN(36);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��������Ŀ�ǰ׺���ò���ȷ';
                RETURN;
        END;
        IF LV_CARD_FLAG IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '��������Ŀ�ǰ׺���ò���ȷ';
            RETURN;
        END IF;
        IF LV_IN(8) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '֤�����벻��Ϊ��';
            RETURN;
        END IF;
        PK_PUBLIC.P_GETBASEPERSONALBYCERTNO(LV_IN(8), LV_BASE_PERSONAL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(30) = '0' THEN
            SELECT COUNT(1)
              INTO LV_COUNT
              FROM BASE_PHOTO
             WHERE CUSTOMER_ID = LV_BASE_PERSONAL.CUSTOMER_ID
               AND LENGTHB(PHOTO) > 0
               AND PHOTO_STATE = '0';
            IF LV_COUNT <= 0 THEN
                AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
                AV_MSG := '�ͻ���' || LV_BASE_PERSONAL.NAME || '������Ƭ��Ϣ������';
                RETURN;
            END IF;
        END IF;
        IF LV_IN(31) = '0' THEN
            SELECT COUNT(1)
              INTO LV_COUNT
              FROM BASE_SIINFO
             WHERE CERT_NO = LV_IN(8)
               AND MED_STATE = '0'
               AND MED_WHOLE_NO = LV_IN(36);
            IF LV_COUNT <= 0 THEN
                AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
                AV_MSG := '�ͻ���' || LV_BASE_PERSONAL.NAME || '���Ĳα���Ϣ�����ڻ�α���Ϣ�����ڱ�����';
                RETURN;
            END IF;
        END IF;
        SELECT COUNT(1)
          INTO LV_COUNT
          FROM CARD_APPLY
         WHERE CUSTOMER_ID = LV_BASE_PERSONAL.CUSTOMER_ID --AND CARD_TYPE = LV_IN(9)
           AND (APPLY_STATE < PK_PUBLIC.KG_CARD_APPLY_YZX AND
               APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_WJWSHBTG AND
               APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_YHSHBTG AND
               APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_STSHBTG);
        IF LV_COUNT > 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
            AV_MSG := '�ͻ���' || LV_BASE_PERSONAL.NAME || '���Ѵ��ڿ�Ƭ�������ظ���������';
            RETURN;
        END IF;
        --4.������Ϣ�ж�
        IF LV_IN(13) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '����������Ϊ��';
            RETURN;
        ELSE
            BEGIN
                SELECT *
                  INTO LV_BASE_REGION
                  FROM BASE_REGION
                 WHERE REGION_ID = LV_BASE_PERSONAL.REGION_ID;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
                    AV_MSG := '����������' || LV_IN(13) || '�Ҳ���������Ϣ';
                    RETURN;
                WHEN OTHERS THEN
                    AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
                    AV_MSG := '����������' || LV_IN(13) || '��ȡ������Ϣ���ִ���' || SQLERRM;
                    RETURN;
            END;
        END IF;
        IF LV_IN(10) IS NULL AND LV_IN(2) <> '1' THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '���Ų���Ϊ��';
            RETURN;
        END IF;
        LV_SELFMANAGEMENT := PK_PUBLIC.F_GETSYSPARA('SELFMANAGEMENTCARD');
        IF LV_SELFMANAGEMENT = '0' OR LV_SELFMANAGEMENT = '-1' THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '�Ƿ��Թܿ��������ô���';
            RETURN;
        END IF;
        --5.�����Ϣ
        IF LV_IN(2) <> '1' THEN
            LV_APPLY_STATE := '50';
            SELECT COUNT(*) INTO LV_COUNT FROM CARD_TASK_LIST T2 WHERE T2.CARD_NO = LV_IN(10);
            IF LV_COUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
                AV_MSG := '��������ϸ��Ϣ������!';
                RETURN;
            END IF;
            SELECT * INTO LV_CARD_TASK_LIST FROM CARD_TASK_LIST L WHERE L.CARD_NO = LV_IN(5);
            SELECT COUNT(*) INTO LV_COUNT FROM CARD_APPLY T2 WHERE T2.CARD_NO = LV_IN(5);
            IF LV_COUNT <> 0 THEN
                AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
                AV_MSG := '�������Ѵ��ڣ������ظ�����!';
                RETURN;
            END IF;
        ELSE
            LV_APPLY_STATE := PK_PUBLIC.KG_CARD_APPLY_YSQ;
        END IF;
        --6.�������ж�
        IF LV_IN(2) = '2' THEN
            LV_ACTION_LOG.MESSAGE   := '�����ƿ�:����:' || LV_USERS.BRCH_ID || ',֤������ ' ||
                                       LV_BASE_PERSONAL.CERT_NO || LV_IN(37);
            LV_ACTION_LOG.DEAL_CODE := 20401010;
        END IF;
        --7.�жϸÿͻ��Ƿ����δע���Ŀ�
        SELECT COUNT(*)
          INTO LV_COUNT
          FROM CARD_BASEINFO T4
         WHERE T4.CARD_TYPE = LV_IN(9)
           AND T4.CUSTOMER_ID = LV_BASE_PERSONAL.CUSTOMER_ID
           AND T4.CARD_STATE <> '9';
        IF LV_COUNT > 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIS_ERR;
            AV_MSG := '�ÿͻ��Ѵ���δע���Ŀ�Ƭ��Ϣ�������ظ���������';
            RETURN;
        END IF;
        --8.�����ۺ�ҵ����־�Ͳ�����־
        SELECT T.CLR_DATE INTO LV_CLRDATE FROM PAY_CLR_PARA T;
        IF LV_IN(2) = '2' THEN
            SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_DEAL_NO FROM DUAL;
            LV_ACTION_LOG.DEAL_NO     := LV_DEAL_NO;
            LV_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
            LV_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
            LV_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
            LV_ACTION_LOG.DEAL_TIME   := SYSDATE;
            LV_ACTION_LOG.LOG_TYPE    := 0;
            LV_ACTION_LOG.IN_OUT_DATA := AV_IN;
            LV_ACTION_LOG.NOTE        := LV_ACTION_LOG.MESSAGE;
            IF LV_IN(2) = '2' THEN
                LV_ACTION_LOG.CO_ORG_ID := LV_IN(1);
            END IF;
            INSERT INTO SYS_ACTION_LOG VALUES LV_ACTION_LOG;
        ELSIF LV_IN(2) = '1' THEN
            BEGIN
                SELECT * INTO LV_ACTION_LOG FROM SYS_ACTION_LOG WHERE DEAL_NO = LV_IN(4);
            EXCEPTION
                WHEN OTHERS THEN
                    AV_RES := PK_PUBLIC.CS_RES_CARDIS_ERR;
                    AV_MSG := '��¼������ˮ���ִ��󣬸�����ˮ' || LV_IN(4) || '�Ҳ���������־��Ϣ';
                    RETURN;
            END;
        END IF;
        --10.���������
        SELECT SEQ_APPLY_ID.NEXTVAL INTO LV_APPLY_ID FROM DUAL;
        INSERT INTO CARD_APPLY
            (APPLY_ID,
             BAR_CODE,
             CUSTOMER_ID,
             CARD_NO,
             SUB_CARD_NO,
             CARD_TYPE,
             TASK_ID,
             BUY_PLAN_ID,
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
             DEAL_NO,
             BUS_TYPE,
             OTHER_FEE,
             WALLET_USE_FLAG,
             TOWN_ID,
             AGT_CERT_TYPE,
             AGT_CERT_NO,
             AGT_NAME,
             AGT_PHONE,
             ORG_ID,
             CO_ORG_ID,
             BANK_ID,
             BANK_CARD_NO,
             RECV_BRCH_ID,
             MED_WHOLE_NO)
        VALUES
            (LV_APPLY_ID,
             LPAD(SEQ_BAR_CODE.NEXTVAL, 9, '0'),
             LV_BASE_PERSONAL.CUSTOMER_ID,
             NVL(LV_IN(10), ''),
             PK_PUBLIC.CREATESUBCARDNO(LV_CARD_FLAG, LPAD(SEQ_SUB_CARD_NO.NEXTVAL, 7, '0')),
             LV_IN(9),
             LV_CARD_TASK_LIST.TASK_ID,
             LV_CARD_APPLY_TASK.MAKE_BATCH_ID,
             '1.00',
             '91560000023304003304002A',
             LV_CITY_CODE,
             '0000',
             '0',
             '0',
             '0',
             LV_USERS.BRCH_ID,
             LV_BASE_PERSONAL.CORP_CUSTOMER_ID,
             LV_BASE_PERSONAL.COMM_ID,
             LV_APPLY_STATE,
             LV_USERS.USER_ID,
             LV_ACTION_LOG.DEAL_TIME,
             NVL(LV_IN(24), '0'),
             0,
             LV_IN(32),
             LV_IN(30),
             LV_ACTION_LOG.DEAL_NO,
             LV_IN(33),
             0,
             '01',
             LV_BASE_PERSONAL.TOWN_ID,
             LV_IN(26),
             LV_IN(27),
             LV_IN(28),
             LV_IN(29),
             LV_USERS.ORG_ID,
             LV_BASE_CO_ORG.CO_ORG_ID,
             NVL(LV_IN(34), ''),
             NVL(LV_IN(35), ''),
             LV_USERS.BRCH_ID,
             NVL(LV_IN(36), ''));
        --RETURNING SUB_CARD_NO INTO LV_CARD_APPLY.SUB_CARD_NO;
        --UPDATE BASE_PERSONAL SET SERV_PWD = ENCRYPT_3DES(SUBSTR(LV_CARD_APPLY.SUB_CARD_NO,2),LV_BASE_PERSONAL.CERT_NO,NULL,NULL)
        --WHERE CUSTOMER_ID = LV_BASE_PERSONAL.CUSTOMER_ID;
        --11.���Ѵ���0
        IF NVL(LV_IN(24), 0) > 0 THEN
            LV_IN_PARA := '';
            LV_IN_PARA := LV_ACTION_LOG.DEAL_NO || '|' || LV_ACTION_LOG.DEAL_CODE || '|' ||
                          LV_ACTION_LOG.USER_ID || '|';
            LV_IN_PARA := LV_IN_PARA || TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss') || '|' ||
                          '702101';
            LV_IN_PARA := LV_IN_PARA || '|' || LV_IN(24) || '|' || '������' || '|' || LV_IN(2) || '|' || '0' || '|';
            --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5ITEM_NO|6AMT|7NOTE|8ACPT_TYPE|9PAY_SOURCE(0�ֽ�1ת��)
            PK_BUSINESS.P_COST(LV_IN_PARA, '0', AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        --12.����мӼ���
        IF NVL(LV_IN(25), 0) > 0 THEN
            LV_IN_PARA := '';
            LV_IN_PARA := LV_IN_PARA || LV_ACTION_LOG.DEAL_NO || '|' || LV_ACTION_LOG.DEAL_CODE || '|' ||
                          LV_ACTION_LOG.USER_ID || '|';
            LV_IN_PARA := LV_IN_PARA || TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss') || '|' ||
                          '709999' || '|';
            LV_IN_PARA := LV_IN_PARA || LV_IN(25) || '|' || '�Ӽ���' || '|' || LV_IN(2) || '|' || '0' || '|';
            --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5ITEM_NO|6AMT|7NOTE|8ACPT_TYPE|9PAY_SOURCE(0�ֽ�1ת��)
            PK_BUSINESS.P_COST(LV_IN_PARA, '0', AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        --9.����ҵ����־��Ϣ
        LV_SERV_REC.DEAL_NO       := LV_ACTION_LOG.DEAL_NO;
        LV_SERV_REC.DEAL_CODE     := LV_ACTION_LOG.DEAL_CODE;
        LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
        LV_SERV_REC.CARD_NO       := NVL(LV_IN(10), '');
        LV_SERV_REC.CARD_TYPE     := LV_IN(9);
        LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
        LV_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
        LV_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
        LV_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
        LV_SERV_REC.USER_ID       := LV_USERS.USER_ID;
        LV_SERV_REC.ORG_ID        := LV_USERS.ORG_ID;
        LV_SERV_REC.NOTE          := LV_ACTION_LOG.MESSAGE;
        LV_SERV_REC.BIZ_TIME      := LV_ACTION_LOG.DEAL_TIME;
        LV_SERV_REC.AGT_CERT_TYPE := LV_IN(26); --������֤������
        LV_SERV_REC.AGT_CERT_NO   := LV_IN(27); --������֤�����
        LV_SERV_REC.AGT_NAME      := LV_IN(28); --����������
        LV_SERV_REC.AGT_TEL_NO    := LV_IN(29); --�������ֻ���
        LV_SERV_REC.NUM           := 1;
        LV_SERV_REC.DEAL_STATE    := '0';
        LV_SERV_REC.COST_FEE      := NVL(LV_IN(24), 0);
        LV_SERV_REC.URGENT_FEE    := NVL(LV_IN(25), 0);
        LV_SERV_REC.CLR_DATE      := LV_CLRDATE;
        LV_SERV_REC.AMT           := NVL(LV_IN(24), 0) + NVL(LV_IN(25), 0);
        IF LV_IN(2) = '2' THEN
            LV_SERV_REC.END_DEAL_NO := LV_IN(4); --�ն���ˮ��
            LV_SERV_REC.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID; --��������
        END IF;
        INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
        SELECT LV_ACTION_LOG.DEAL_NO INTO AV_OUT FROM DUAL;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_APPLYCARD;
    /*=======================================================================================*/
    --�����ƿ�
    --       1�������/������ BRCH_ID/ACPT_ID ����
    --       2��������� ACPT_TYPE ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
    --       3�ն˱��/��Ա��� USER_ID/END_ID ����
    --       4�ն˲�����ˮ/ҵ����ˮ DEAL_NO/END_DEAL_NO ����
    --       5֤������----����
    --       6���񿨿���-----����
    --       7������
    --       8��������
    --       9����
    --       10�쿨����
    --       8������--��λ����
    --       9�Ӽ���--��λ����
    --       10������֤������
    --       11������֤������
    --       12����������
    --       13��������ϵ�绰
    --       14��ע
    -- AV_OUT��
    PROCEDURE P_PERSONAL_APPLY(AV_IN IN VARCHAR2, --�������
                               AV_DEBUG IN VARCHAR2, --1����
                               AV_OUT OUT VARCHAR2, --������Ϣ
                               AV_RES OUT VARCHAR2, --��������
                               AV_MSG OUT VARCHAR2 --����������Ϣ
                               ) IS
        LV_IN          PK_PUBLIC.MYARRAY;
        LV_USERS       SYS_USERS%ROWTYPE;
        LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
        LV_PAYCLRPARA  PAY_CLR_PARA%ROWTYPE;
    BEGIN
        --1.��������
        SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 8, 13, 'pk_card_apply_issuse.p_personal_apply', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --2.������ж�
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
    END P_PERSONAL_APPLY;
    /*=======================================================================================*/
    --������
    --AV_IN: 1����
    --       2֤������
    --       3֤������
    --       4����
    --       5��������
    --       6��������
    --       7������
    --       8�ܿ����ı�ʶ��
    --       9��Ա��
    --       10��ע
    --       11 �Ƿ����Ͽ� 0 �� 1 ��
    --       12 �Ͽ�����
    /*=======================================================================================*/
    PROCEDURE P_OPENACCANDCARD(AV_IN IN VARCHAR2, --�������
                               AV_DEBUG IN VARCHAR2, --1����
                               AV_RES OUT VARCHAR2, --��������
                               AV_MSG OUT VARCHAR2 --����������Ϣ
                               ) IS
        LV_COUNT             NUMBER;
        LV_ACTION_NO         SYS_ACTION_LOG.DEAL_NO%TYPE; -- ��ˮ��
        LV_CLRDATE           PAY_CLR_PARA.CLR_DATE%TYPE; --�������
        LV_IN                PK_PUBLIC.MYARRAY; --�����������
        LV_BASE_PERSONAL     BASE_PERSONAL%ROWTYPE; --��Ա������Ϣ
        LV_CARD_TASK_LIST    CARD_TASK_LIST%ROWTYPE; -- ������ϸ��Ϣ
        LV_OPERATOR          SYS_USERS%ROWTYPE; --����Ա
        LV_ACTION_LOG        SYS_ACTION_LOG%ROWTYPE; -- ������־��
        LV_SERV_REC          TR_SERV_REC%ROWTYPE; -- �ۺ�ҵ����־��
        LV_OLD_CARD          CARD_BASEINFO%ROWTYPE; --�Ͽ�����Ϣ
        LREC_ACC_ACCOUNT_SUB ACC_ACCOUNT_SUB%ROWTYPE; --�˻���Ϣ
        LV_ACC_IN            VARCHAR2(500);
        LV_TRANS_IN          VARCHAR2(500);
    BEGIN
        --�ֽ����
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, --�������
                                 12, --�������ٸ���
                                 12, --����������
                                 'pk_transfer.p_transfer', --���õĺ�����
                                 LV_IN, --ת���ɲ�������
                                 AV_RES, --������������
                                 AV_MSG --��������������Ϣ
                                 );
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        AV_RES      := PK_PUBLIC.CS_RES_OK;
        AV_MSG      := '';
        LV_ACC_IN   := '';
        LV_TRANS_IN := '';
        --�жϽ������Ϣ�Ƿ���ȷ
        SELECT * INTO LV_OPERATOR FROM SYS_USERS T1 WHERE T1.USER_ID = LV_IN(18);
        IF LV_OPERATOR.USER_ID IS NULL OR LV_OPERATOR.BRCH_ID <> LV_IN(17) THEN
            AV_RES := PK_PUBLIC.CS_RES_USER_ERR;
            AV_MSG := '�ܿ��������֤ʧ��';
            RETURN;
        END IF;
        --�жϿ�����Ϣ�Ƿ���ȷ���Ƿ�������Ԥ���ɵĿ��ţ�
        SELECT COUNT(1) INTO LV_COUNT FROM CARD_TASK_LIST T2 WHERE T2.CARD_NO = LV_IN(5);
        IF LV_COUNT <> 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
            AV_MSG := '������֤ʧ��';
            RETURN;
        END IF;
        SELECT * INTO LV_CARD_TASK_LIST FROM CARD_TASK_LIST WHERE CARD_NO = LV_IN(1);
        --����ҵ����־�Ͳ�����־
        -- �����ۺ�ҵ����־�Ͳ�����־
        SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_ACTION_NO FROM DUAL;
        SELECT T.CLR_DATE INTO LV_CLRDATE FROM PAY_CLR_PARA T;
        LV_ACTION_LOG.DEAL_NO     := LV_ACTION_NO;
        LV_ACTION_LOG.DEAL_CODE   := '150111';
        LV_ACTION_LOG.ORG_ID      := LV_OPERATOR.ORG_ID;
        LV_ACTION_LOG.BRCH_ID     := LV_OPERATOR.BRCH_ID;
        LV_ACTION_LOG.USER_ID     := LV_OPERATOR.USER_ID;
        LV_ACTION_LOG.DEAL_TIME   := SYSDATE;
        LV_ACTION_LOG.LOG_TYPE    := 0;
        LV_ACTION_LOG.MESSAGE     := '�����ţ�' + LV_OPERATOR.BRCH_ID;
        LV_ACTION_LOG.IN_OUT_DATA := AV_IN;
        LV_ACTION_LOG.NOTE        := AV_IN + '�����ţ�' + LV_OPERATOR.BRCH_ID;
        INSERT INTO SYS_ACTION_LOG VALUES LV_ACTION_LOG;
        LV_SERV_REC.DEAL_NO       := LV_ACTION_NO;
        LV_SERV_REC.DEAL_CODE     := '150112';
        LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
        LV_SERV_REC.CARD_ID       := LV_IN(5);
        LV_SERV_REC.CARD_NO       := LV_IN(5);
        LV_SERV_REC.CARD_TYPE     := LV_IN(20);
        LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
        LV_SERV_REC.CERT_TYPE     := LV_IN(3);
        LV_SERV_REC.CERT_NO       := LV_IN(4);
        LV_SERV_REC.BRCH_ID       := LV_OPERATOR.BRCH_ID;
        LV_SERV_REC.USER_ID       := LV_OPERATOR.USER_ID;
        LV_SERV_REC.ORG_ID        := LV_OPERATOR.ORG_ID;
        LV_SERV_REC.NOTE          := AV_IN + '������';
        LV_SERV_REC.BIZ_TIME      := LV_ACTION_LOG.DEAL_TIME;
        INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
        --���뿨��Ϣ
        INSERT INTO CARD_BASEINFO
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
            (LV_IN(1),
             LV_IN(1),
             LV_BASE_PERSONAL.CUSTOMER_ID,
             NVL(LV_IN(7), '100'),
             LV_OPERATOR.ORG_ID,
             '1.0',
             NULL,
             '7500',
             NULL,
             TO_CHAR(SYSDATE, 'yyyymmdd'),
             LV_CARD_TASK_LIST.CARDISSUEDATE,
             LV_CARD_TASK_LIST.VALIDITYDATE,
             LV_CARD_TASK_LIST.VALIDITYDATE,
             NULL,
             NULL, --��������
             0,
             '000000',
             0,
             '1',
             SYSDATE,
             0,
             0,
             0,
             0,
             LV_IN(6),
             LV_IN(6),
             NULL,
             LV_IN(5),
             NULL,
             LV_CARD_TASK_LIST.BAR_CODE,
             NULL,
             NULL,
             LV_IN(10),
             NULL,
             LV_IN(6),
             LV_IN(1),
             LV_BASE_PERSONAL.MOBILE_NO,
             0,
             NULL,
             '01',
             '01',
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL);
        --���ÿ����洢����
        --���˻�
        --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
        --5OBJ_TYPE     ���ͣ����˻���������һ�£�0-����1-����/�� 2-��λ 3-�̻�4-������
        --6SUB_TYPE     ������(���ô���)
        --7OBJ_ID       �˻����������ǿ�ʱ�����뿨�ţ�(�������ʱ������֮����,�ָ� CARDNO1,CARDNO2)
        --                             ��������CLIENT_ID��
        --8PWD          ����
        --9ENCRYPT      ���˻��������(�������ʱ��֮����,�ָ� ENCRYPT1,ENCRYPT2)
        SELECT LV_ACTION_LOG.DEAL_NO || '|' || '150112' || '|' || LV_OPERATOR.USER_ID || '|' ||
                LV_ACTION_LOG.DEAL_TIME || '|' || '1' || '|' || '100' || '|' || LV_IN(1) || '|' || '|' || ''
          INTO LV_ACC_IN
          FROM DUAL; ---����Ҫ�޸�0������
        PK_BUSINESS.P_CREATEACCOUNT(LV_ACC_IN, AV_RES, AV_MSG);
        --�ж��Ƿ����Ͽ������Ͽ����Ͽ��������˻�ת���¿������˻���
        IF LV_IN(12) = '0' THEN
            BEGIN
                --�п����Ͽ�����Ϊ�� CS_RES_OLDCARDNULL_ERR
                IF LV_IN(12) IS NULL THEN
                    AV_RES := PK_PUBLIC.CS_RES_OLDCARDNULL_ERR;
                    AV_MSG := '�Ͽ����Ų���Ϊ��';
                    RETURN;
                END IF;
                SELECT *
                  INTO LV_OLD_CARD
                  FROM CARD_BASEINFO
                 WHERE CARD_NO = LV_IN(12)
                   AND CARD_TYPE = '100';
                --ת�ƽ��
                SELECT *
                  INTO LREC_ACC_ACCOUNT_SUB
                  FROM ACC_ACCOUNT_SUB
                 WHERE CARD_NO = LV_OLD_CARD.CARD_NO
                   AND ACC_KIND = '02';
                IF LREC_ACC_ACCOUNT_SUB.BAL > 0 THEN
                    LV_TRANS_IN := LV_TRANS_IN || LV_ACTION_LOG.DEAL_NO || '|'; --1ACTION_NO
                    LV_TRANS_IN := LV_TRANS_IN || '800359' || '|'; --2TR_CODE
                    LV_TRANS_IN := LV_TRANS_IN || LV_OPERATOR.USER_ID || '|'; --3OPER_ID
                    LV_TRANS_IN := LV_TRANS_IN || LV_ACTION_LOG.DEAL_TIME || '|'; --4OPER_TIME
                    LV_TRANS_IN := LV_TRANS_IN || LV_OPERATOR.BRCH_ID || '|'; --5ACPT_ID        �������(����Ż��̻����)
                    LV_TRANS_IN := LV_TRANS_IN || TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyymmdd') || '|'; --6TR_BATCH_NO    ���κ�
                    LV_TRANS_IN := LV_TRANS_IN || TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'hh24:mi:ss') || '|'; --7TERM_TR_NO     �ն˽�����ˮ��
                    LV_TRANS_IN := LV_TRANS_IN || LV_IN(12) || '|'; --8CARD_NO1       ת������
                    LV_TRANS_IN := LV_TRANS_IN || '|'; --9CARD_TR_COUNT1 ת�������׼�����
                    LV_TRANS_IN := LV_TRANS_IN || '|'; --10CARD_BAL1     ת����Ǯ������ǰ���
                    LV_TRANS_IN := LV_TRANS_IN || '02' || '|'; --11ACC_KIND1     ת�����˻�����
                    LV_TRANS_IN := LV_TRANS_IN || '00' || '|'; --12WALLET_ID1    ת����Ǯ����� Ĭ��00
                    LV_TRANS_IN := LV_TRANS_IN || LV_IN(1) || '|'; --13CARD_NO2      ת�뿨��
                    LV_TRANS_IN := LV_TRANS_IN || '|'; --14CARD_TR_COUNT2ת�뿨���׼�����
                    LV_TRANS_IN := LV_TRANS_IN || '|'; --15CARD_BAL2     ת�뿨Ǯ������ǰ���
                    LV_TRANS_IN := LV_TRANS_IN || '02' || '|'; --16ACC_KIND2     ת�뿨�˻�����
                    LV_TRANS_IN := LV_TRANS_IN || '00' || '|'; --17WALLET_ID2    ת�뿨Ǯ����� Ĭ��00
                    LV_TRANS_IN := LV_TRANS_IN || '|'; --18TR_AMT        ת�˽��  NULLʱת�����н��
                    LV_TRANS_IN := LV_TRANS_IN || LV_OLD_CARD.PAY_PWD || '|'; --19PWD           ת������
                    LV_TRANS_IN := LV_TRANS_IN || '������ת��' || '|'; --20NOTE          ��ע
                    LV_TRANS_IN := LV_TRANS_IN || '0' || '|'; --21ENCRYPT1      ת����ת�˺������� 0 �����ģ���ʱ��֪��
                    LV_TRANS_IN := LV_TRANS_IN || LREC_ACC_ACCOUNT_SUB.BAL_CRYPT || '|'; --22ENCRYPT2      ת�뿨ת�˺�������
                    LV_TRANS_IN := LV_TRANS_IN || '0' || '|'; --23TR_STATE      9д�Ҽ�¼0ֱ��д������¼
                    LV_TRANS_IN := LV_TRANS_IN || '1' || '|'; --24ACPT_TYPE     ��������
                    LV_TRANS_IN := LV_TRANS_IN || LREC_ACC_ACCOUNT_SUB.BAL || '|'; --25ACC_BAL1      ת�����˻�����ǰ���
                    LV_TRANS_IN := LV_TRANS_IN || 0 || '|'; --26ACC_BAL2      ת�뿨�˻�����ǰ���
                    PK_TRANSFER.P_TRANSFER(LV_TRANS_IN, '1', AV_RES, AV_MSG);
                END IF;
                IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                    RAISE_APPLICATION_ERROR(-20000, AV_MSG);
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    AV_RES := PK_PUBLIC.CS_RES_OLDCARDNOTEXIST_ERR;
                    AV_MSG := 'ԭ���˻���Ϣ������';
                    RAISE_APPLICATION_ERROR(-20000, AV_MSG);
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := NVL(SQLERRM, SQLERRM);
            ROLLBACK;
            UPDATE SYS_ACTION_LOG
               SET IN_OUT_DATA = IN_OUT_DATA || '------����ʧ�ܣ�������Ϣ��{' || AV_RES || ',' ||
                                  REPLACE(AV_MSG, '''', '��') || '}'
             WHERE DEAL_NO = LV_ACTION_NO;
            COMMIT;
    END P_OPENACCANDCARD;
    --���˷���
    --����˵����
    --1�������/������ BRCH_ID/ACPT_ID ����
    --2��������� ACPT_TYPE ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
    --3�ն˱��/��Ա��� USER_ID/END_ID ����
    --4�ն˲�����ˮ/ҵ����ˮ DEAL_NO/END_DEAL_NO ����
    --5�����ŵĿ���
    --6���Ű󶨵����п���
    --7�Ƿ���¿��
    --8�Ƿ�ͬ�����ݽ���
    --9������֤������
    --10������֤������
    --11����������
    --12��������ϵ�绰
    --13��ע
    PROCEDURE P_SMZ_KFF(AV_IN VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2, AV_OUT OUT VARCHAR2) IS
        LV_IN                   PK_PUBLIC.MYARRAY;
        LV_USERS                SYS_USERS%ROWTYPE;
        LV_BASE_CO_ORG          BASE_CO_ORG%ROWTYPE;
        LV_CARD_TASK_LIST       CARD_TASK_LIST%ROWTYPE;
        LV_CARD_APPLY           CARD_APPLY%ROWTYPE;
        LV_CARD_APPLY_TASK      CARD_APPLY_TASK%ROWTYPE;
        LV_CARD_BASEINFO        CARD_BASEINFO%ROWTYPE;
        LV_ACC_ACCOUNT_SUB_OLD  ACC_ACCOUNT_SUB%ROWTYPE;
        LV_ACC_ACCOUNT_SUB_NEW  ACC_ACCOUNT_SUB%ROWTYPE;
        LV_CARD_CONFIG          CARD_CONFIG%ROWTYPE;
        LV_SERV_REC             TR_SERV_REC%ROWTYPE;
        LV_ACTION_LOG           SYS_ACTION_LOG%ROWTYPE;
        LV_BASE_PERSONAL        BASE_PERSONAL%ROWTYPE;
        LV_CARD_NO              CARD_NO%ROWTYPE;
        LV_ACCFREEZEREC         ACC_FREEZE_REC%ROWTYPE;
        LV_ACC_UNFREEZE_REC     ACC_FREEZE_REC%ROWTYPE;
        LV_ACC_FREEZE_REC_OLD   ACC_FREEZE_REC%ROWTYPE;
        LV_PAYCLRPARA           PAY_CLR_PARA%ROWTYPE;
        LV_CREATE_COUNT_SQL     VARCHAR2(500) := '';
        LV_COUNT                NUMBER;
        LV_DEAL_NO              INTEGER;
        LV_UPDATE_STOCK_SQL     VARCHAR2(500) := '';
        LV_FREEZE_FLAG          VARCHAR2(1);
        LV_NUMBER               NUMBER := 0;
        LV_CARD_RECOVER_REGINFO CARD_RECOVER_REGINFO%ROWTYPE;
        --LV_CARD_APPLY_YH       CARD_APPLY_YH%ROWTYPE;
    BEGIN
        SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 8, 13, 'PK_CARD_APPLY_ISSUSE.P_SMZ_KFF', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(5) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���Ų���Ϊ��';
            RETURN;
        END IF;
        PK_PUBLIC.P_GETCARDBYCARDNO(LV_IN(5), LV_CARD_BASEINFO, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETCARDAPPLYBYCARDNO(LV_IN(5), LV_CARD_APPLY, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_CARD_APPLY.APPLY_STATE NOT IN
           (PK_PUBLIC.KG_CARD_APPLY_YJS, PK_PUBLIC.KG_CARD_APPLY_YHS) THEN
            AV_RES := PK_PUBLIC.CS_RES_CARD_APPLY_NOYJS;
            AV_MSG := '���ݿ���' || LV_IN(5) || '��ȡ����������Ϣ���ǡ��ѽ��ա����ѻ��ա�״̬�����ܽ��з���';
            RETURN;
        END IF;
        PK_CARD_STOCK.P_GETCARDAPPLYTASKBYTASKID(LV_CARD_APPLY.TASK_ID, LV_CARD_APPLY_TASK, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_CARD_APPLY.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS THEN
            IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YJS AND
               LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_FKZ THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�����¼���������ǡ��ѽ��ա��򡾷����С�״̬�����ܽ��з���';
                RETURN;
            END IF;
        ELSE
            IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YJS AND
               LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_FKZ AND
               LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YFF THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�����¼��������״̬�����������ܽ��з���';
                RETURN;
            END IF;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_APPLY.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETCARDCONFIGBYCARDTYPE(LV_CARD_APPLY.CARD_TYPE, LV_CARD_CONFIG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        BEGIN
            SELECT * INTO LV_CARD_NO FROM CARD_NO WHERE CARD_NO = LV_CARD_APPLY.CARD_NO;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '����' || LV_CARD_APPLY.CARD_NO || '�ڿ��ű����Ҳ���������Ϣ';
                RETURN;
                null;
            WHEN OTHERS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '����' || LV_CARD_APPLY.CARD_NO || '�ڿ��ű��л�ȡ������Ϣ���ִ���' || SQLERRM;
                RETURN;
        END;
        BEGIN
            select *
              into lv_card_task_list
              from card_task_list
             where apply_id = lv_card_apply.apply_id
               and task_id = lv_card_apply.task_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���ݿ���' || LV_CARD_APPLY.CARD_NO || '�Ҳ����ƿ���ϸ��Ϣ';
                RETURN;
            WHEN OTHERS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���ݿ���' || LV_CARD_APPLY.CARD_NO || '��ȡ�ƿ���ϸ��Ϣ���ִ���' || SQLERRM;
                RETURN;
        END;
        SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_DEAL_NO FROM DUAL;
        LV_ACTION_LOG.DEAL_NO := LV_DEAL_NO;
        IF LV_CARD_APPLY.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YHS THEN
            LV_ACTION_LOG.DEAL_CODE := 2040110; --���տ�����
            BEGIN
                SELECT *
                  INTO LV_CARD_RECOVER_REGINFO
                  FROM CARD_RECOVER_REGINFO
                 WHERE CARD_NO = LV_CARD_BASEINFO.CARD_NO;
                IF LV_CARD_RECOVER_REGINFO.STATUS = '1' THEN
                    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                    AV_MSG := '����Ϊ' || LV_CARD_APPLY.CARD_NO || '�Ŀ�Ƭ��Ϣ�ѷ��ţ������ظ����з���';
                    RETURN;
                END IF;
                IF LV_CARD_RECOVER_REGINFO.STATUS <> '0' THEN
                    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                    AV_MSG := '����Ϊ' || LV_CARD_APPLY.CARD_NO || '�Ŀ�Ƭ����״̬������';
                    RETURN;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                    AV_MSG := '���ݿ���' || LV_CARD_APPLY.CARD_NO || 'δ�ҵ������ռ�¼��Ϣ';
                    RETURN;
                WHEN OTHERS THEN
                    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                    AV_MSG := '���ݿ���' || LV_CARD_APPLY.CARD_NO || '��ȡ�����յǼ���Ϣ���ִ���' || SQLERRM;
                    RETURN;
            END;
        ELSE
            LV_ACTION_LOG.DEAL_CODE := 20401050; --���˷���
        END IF;
        LV_ACTION_LOG.MESSAGE     := LV_IN(13);
        LV_ACTION_LOG.NOTE        := LV_IN(13);
        LV_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
        LV_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
        LV_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
        LV_ACTION_LOG.DEAL_TIME   := SYSDATE;
        LV_ACTION_LOG.LOG_TYPE    := 0;
        LV_ACTION_LOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
        LV_ACTION_LOG.IN_OUT_DATA := AV_IN;
        INSERT INTO SYS_ACTION_LOG VALUES LV_ACTION_LOG;
        LV_CREATE_COUNT_SQL := LV_CREATE_COUNT_SQL || LV_DEAL_NO || '|' || LV_ACTION_LOG.DEAL_CODE || '|';
        LV_CREATE_COUNT_SQL := LV_CREATE_COUNT_SQL || LV_USERS.USER_ID || '|';
        LV_CREATE_COUNT_SQL := LV_CREATE_COUNT_SQL ||
                               TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss') || '|';
        LV_CREATE_COUNT_SQL := LV_CREATE_COUNT_SQL || '1' || '|' || LV_CARD_APPLY.CARD_TYPE || '|';
        LV_CREATE_COUNT_SQL := LV_CREATE_COUNT_SQL || LV_CARD_APPLY.CARD_NO || '|' ||
                               LV_CARD_NO.PWD || '|' || LV_CARD_NO.BAL_CRYPT || '|';
        --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5OBJ_TYPE|SUB_TYPE|7OBJ_ID|8PWD|9ENCRYPT���˻��������(�������ʱ��֮����,�ָ� ENCRYPT1,ENCRYPT2)
        PK_BUSINESS.P_CREATEACCOUNT(LV_CREATE_COUNT_SQL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            ROLLBACK;
            RETURN;
        END IF;
        --15.���¿�״̬
        UPDATE CARD_BASEINFO
           SET LAST_MODIFY_DATE = LV_ACTION_LOG.DEAL_TIME, CARD_STATE = '1', PAY_PWD_ERR_NUM = 0 --,
        -- PAY_PWD            = LV_CARD_NO.PWD_CRYPT
         WHERE CARD_NO = LV_CARD_APPLY.CARD_NO;
        IF SQL%ROWCOUNT <> 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���¿�״̬����ȷ,ʵ�ʸ���' || SQL%ROWCOUNT || '��';
            RETURN;
        END IF;
        UPDATE acc_account_sub t
           SET t.open_date = LV_ACTION_LOG.DEAL_TIME, t.open_brch_id = LV_USERS.Brch_Id, t.open_user_id = LV_USERS.User_Id, t.org_id = LV_USERS.Org_Id, t.acc_STATE = '1'
        -- PAY_PWD            = LV_CARD_NO.PWD_CRYPT
         WHERE t.CARD_NO = LV_CARD_APPLY.CARD_NO;
        UPDATE BASE_PERSONAL
           SET SERV_PWD = ENCRYPT_DES_ORACLE(SUBSTR(NVL(LV_CARD_APPLY.SUB_CARD_NO, '0123456'), 2, 6), LV_BASE_PERSONAL.CERT_NO)
         WHERE CUSTOMER_ID = LV_BASE_PERSONAL.CUSTOMER_ID;
        --return;
        IF LV_CARD_APPLY.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS THEN
            PK_CARD_APPLY_ISSUSE.P_SYNCH2CARD_UPATE(LV_CARD_APPLY.TASK_ID, LV_BASE_PERSONAL.CERT_NO, LV_CARD_APPLY.CARD_NO, LV_CARD_APPLY.OLD_CARD_NO, LV_ACTION_LOG.DEAL_NO, LV_CARD_APPLY.APPLY_TYPE, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        --10.���������¼
        UPDATE CARD_APPLY
           SET RELS_DATE = LV_ACTION_LOG.DEAL_TIME, ISSUSE_DEAL_NO = LV_ACTION_LOG.DEAL_NO, APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YFF, RELS_BRCH_ID = LV_USERS.BRCH_ID, RELS_USER_ID = LV_USERS.USER_ID, RECV_CERT_TYPE = NVL(LV_IN(9), RECV_CERT_TYPE), RECV_CERT_NO = NVL(LV_IN(10), RECV_CERT_NO), RECV_NAME = NVL(LV_IN(11), RECV_NAME), RECV_PHONE = NVL(LV_IN(12), RECV_PHONE)
         WHERE APPLY_ID = LV_CARD_APPLY.APPLY_ID
           AND APPLY_STATE IN (PK_PUBLIC.KG_CARD_APPLY_YJS, PK_PUBLIC.KG_CARD_APPLY_YHS);
        IF SQL%ROWCOUNT <> 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '��������״̬��������ȷ�������� 1 ��ʵ�ʸ��� ' || SQL%ROWCOUNT || ' ��';
            RETURN;
        END IF;
        /*IF LV_CARD_APPLY.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS THEN
        LV_CARD_APPLY_YH.DATA_SEQ         := LV_CARD_TASK_LIST.DATA_SEQ;
        LV_CARD_APPLY_YH.APPLY_ID         := LV_CARD_APPLY.APPLY_ID;
        LV_CARD_APPLY_YH.DEAL_NO          := LV_ACTION_LOG.DEAL_NO;
        LV_CARD_APPLY_YH.DEAL_CODE        := LV_ACTION_LOG.DEAL_CODE;
        LV_CARD_APPLY_YH.NAME             := LV_BASE_PERSONAL.NAME;
        LV_CARD_APPLY_YH.SEX              := LV_BASE_PERSONAL.GENDER;
        LV_CARD_APPLY_YH.CERT_TYPE        := LV_BASE_PERSONAL.CERT_TYPE;
        LV_CARD_APPLY_YH.CERT_NO          := LV_BASE_PERSONAL.CERT_NO;
        LV_CARD_APPLY_YH.BANK_ID          := LV_CARD_APPLY.BANK_ID;
        LV_CARD_APPLY_YH.BANK_CARD_NO     := LV_CARD_APPLY.BANK_CARD_NO;
        LV_CARD_APPLY_YH.CARD_NO          := LV_CARD_BASEINFO.CARD_NO;
        LV_CARD_APPLY_YH.MAKE_TYPE        := LV_CARD_APPLY.APPLY_TYPE;
        LV_CARD_APPLY_YH.BHK_TYPE         := LV_CARD_APPLY.BHK_TYPE;
        LV_CARD_APPLY_YH.ISSUE_DATE       := LV_CARD_TASK_LIST.CARDISSUEDATE;
        LV_CARD_APPLY_YH.START_DATE       := LV_CARD_TASK_LIST.CARDISSUEDATE;
        LV_CARD_APPLY_YH.VALID_DATE       := LV_CARD_TASK_LIST.VALIDITYDATE;
        LV_CARD_APPLY_YH.CORP_CUSTOMER_ID := LV_BASE_PERSONAL.CORP_CUSTOMER_ID;
        LV_CARD_APPLY_YH.EMAIL            := LV_BASE_PERSONAL.EMAIL;
        LV_CARD_APPLY_YH.INSERT_DATE      := LV_ACTION_LOG.DEAL_TIME;
        LV_CARD_APPLY_YH.LETTER_ADDR      := LV_BASE_PERSONAL.LETTER_ADDR;
        LV_CARD_APPLY_YH.MOBILE_NO        := LV_BASE_PERSONAL.MOBILE_NO;
        LV_CARD_APPLY_YH.OLD_CARD_ID      := LV_CARD_APPLY.OLD_CARD_ID;
        LV_CARD_APPLY_YH.OLD_CARD_NO      := LV_CARD_APPLY.OLD_CARD_NO;
        LV_CARD_APPLY_YH.PROVINCE_NO      := LV_BASE_PERSONAL.PROVINCE_NO;
        LV_CARD_APPLY_YH.STATE            := '0';
        LV_CARD_APPLY_YH.TEL_NO           := LV_BASE_PERSONAL.PHONE_NO;
        LV_CARD_APPLY_YH.BRCH_ID          := LV_USERS.BRCH_ID;
        LV_CARD_APPLY_YH.USER_ID          := LV_USERS.USER_ID;
        LV_CARD_APPLY_YH.CLR_DATE         := LV_PAYCLRPARA.CLR_DATE;
        LV_CARD_APPLY_YH.APPLY_DATE       := LV_CARD_APPLY.APPLY_DATE;
        INSERT INTO CARD_APPLY_YH VALUES LV_CARD_APPLY_YH;
        END IF;*/
        --11.�ж��Ͽ��Ƿ��ж����¼
        IF LV_CARD_APPLY.APPLY_TYPE <> '1' AND LV_CARD_APPLY.APPLY_TYPE <> '2' THEN
            GOTO BK_AND_HK;
        END IF;
        FOR LREC_ACC_FREEZE_REC IN (SELECT *
                                      FROM ACC_FREEZE_REC
                                     WHERE CARD_NO = LV_CARD_APPLY.OLD_CARD_NO
                                       AND REC_TYPE = '0'
                                       AND DEAL_CODE = '50601010'
                                     ORDER BY DEAL_DATE ASC) LOOP
            PK_PUBLIC.P_GETSUBLEDGERBYCARDNO(LREC_ACC_FREEZE_REC.CARD_NO, LREC_ACC_FREEZE_REC.ACC_KIND, PK_PUBLIC.CS_DEFAULTWALLETID, LV_ACC_ACCOUNT_SUB_OLD, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            IF LV_NUMBER = 0 THEN
                LV_FREEZE_FLAG := LV_ACC_ACCOUNT_SUB_OLD.FRZ_FLAG;
            ELSE
                LV_NUMBER := LV_NUMBER + 1;
            END IF;
            PK_PUBLIC.P_GETSUBLEDGERBYCARDNO(LV_CARD_APPLY.CARD_NO, LREC_ACC_FREEZE_REC.ACC_KIND, PK_PUBLIC.CS_DEFAULTWALLETID, LV_ACC_ACCOUNT_SUB_NEW, AV_RES, AV_MSG);
            IF AV_RES = PK_PUBLIC.CS_RES_OK AND
               LV_ACC_ACCOUNT_SUB_OLD.BAL >= LREC_ACC_FREEZE_REC.FRZ_AMT THEN
                IF LV_ACC_ACCOUNT_SUB_OLD.BAL >= LREC_ACC_FREEZE_REC.FRZ_AMT THEN
                    LV_ACC_FREEZE_REC_OLD                      := LREC_ACC_FREEZE_REC;
                    LV_ACC_FREEZE_REC_OLD.REC_TYPE             := '1';
                    LV_ACC_FREEZE_REC_OLD.CANCEL_DEAL_BATCH_NO := LV_PAYCLRPARA.CLR_DATE;
                    IF LV_IN(2) = '2' THEN
                        LV_ACC_FREEZE_REC_OLD.CANCEL_END_DEAL_NO := LV_IN(4);
                    END IF;
                    LV_ACC_FREEZE_REC_OLD.CANCEL_REASON := '���������ţ��Ͽ��ⶳת�¿�����';
                    INSERT INTO ACC_FREEZE_HIS VALUES LV_ACC_FREEZE_REC_OLD;
                    LV_ACC_UNFREEZE_REC := LREC_ACC_FREEZE_REC;
                    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_ACC_UNFREEZE_REC.DEAL_NO FROM DUAL;
                    --LV_ACC_UNFREEZE_REC.DEAL_NO       := SEQ_ACTION_NO.NEXTVAL; --����ˮ
                    LV_ACC_UNFREEZE_REC.OLD_DEAL_NO   := LV_ACCFREEZEREC.DEAL_NO; --ԭʼ��ˮ
                    LV_ACC_UNFREEZE_REC.REC_TYPE      := '0'; --�ⶳ��¼״̬
                    LV_ACC_UNFREEZE_REC.ACPT_ID       := LV_USERS.BRCH_ID;
                    LV_ACC_UNFREEZE_REC.USER_ID       := LV_USERS.USER_ID;
                    LV_ACC_UNFREEZE_REC.DEAL_DATE     := LV_ACTION_LOG.DEAL_TIME;
                    LV_ACC_UNFREEZE_REC.DEAL_BATCH_NO := ''; --���κ�
                    LV_ACC_UNFREEZE_REC.END_DEAL_NO   := LV_IN(4);
                    LV_ACC_UNFREEZE_REC.END_ID        := LV_IN(3);
                    LV_ACC_UNFREEZE_REC.NOTE          := LV_IN(13);
                    LV_ACC_UNFREEZE_REC.CLR_DATE      := LV_PAYCLRPARA.CLR_DATE;
                    LV_ACC_UNFREEZE_REC.INSERT_DATE   := LV_ACTION_LOG.DEAL_TIME;
                    LV_ACC_UNFREEZE_REC.DEAL_CODE     := '50601021';
                    INSERT INTO ACC_FREEZE_HIS VALUES LV_ACC_UNFREEZE_REC;
                    DELETE FROM ACC_FREEZE_REC WHERE DEAL_NO = LREC_ACC_FREEZE_REC.DEAL_NO;
                    --�¿�����
                    LV_ACCFREEZEREC := LREC_ACC_FREEZE_REC;
                    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_ACCFREEZEREC.DEAL_NO FROM DUAL;
                    --LV_ACCFREEZEREC.DEAL_NO     := SEQ_ACTION_NO.NEXTVAL;
                    LV_ACCFREEZEREC.ACPT_ID     := LV_USERS.BRCH_ID;
                    LV_ACCFREEZEREC.DEAL_CODE   := 50601010; --���᣺50601010--�ⶳ50601021
                    LV_ACCFREEZEREC.CARD_NO     := LV_CARD_APPLY.CARD_NO;
                    LV_ACCFREEZEREC.END_ID      := LV_IN(3);
                    LV_ACCFREEZEREC.END_DEAL_NO := LV_IN(4);
                    LV_ACCFREEZEREC.USER_ID     := LV_USERS.USER_ID;
                    LV_ACCFREEZEREC.CLR_DATE    := LV_PAYCLRPARA.CLR_DATE;
                    LV_ACCFREEZEREC.DEAL_DATE   := LV_ACTION_LOG.DEAL_TIME;
                    LV_ACCFREEZEREC.ACC_NO      := LV_ACC_ACCOUNT_SUB_NEW.ACC_NO;
                    LV_ACCFREEZEREC.ACC_BAL     := LV_ACC_ACCOUNT_SUB_NEW.BAL;
                    LV_ACCFREEZEREC.INSERT_DATE := LV_ACTION_LOG.DEAL_TIME;
                    LV_ACCFREEZEREC.OLD_DEAL_NO := LREC_ACC_FREEZE_REC.DEAL_NO;
                    LV_ACCFREEZEREC.NOTE        := '�����������Ͽ�ת�¿�����,�����˻�����' || LV_CARD_APPLY.CARD_NO ||
                                                   ',�˻�����' || LREC_ACC_FREEZE_REC.ACC_KIND || ',���' ||
                                                   LREC_ACC_FREEZE_REC.FRZ_AMT || 'ԭ����' ||
                                                   LV_CARD_APPLY.OLD_CARD_NO || ',ԭ��ˮ' ||
                                                   LREC_ACC_FREEZE_REC.DEAL_NO;
                    INSERT INTO ACC_FREEZE_REC VALUES LV_ACCFREEZEREC;
                    UPDATE ACC_ACCOUNT_SUB
                       SET FRZ_AMT = NVL(FRZ_AMT, 0) + LREC_ACC_FREEZE_REC.FRZ_AMT, FRZ_FLAG = LV_FREEZE_FLAG, FRZ_DATE = LV_ACTION_LOG.DEAL_TIME
                     WHERE CARD_NO = LV_CARD_APPLY.CARD_NO
                       AND ACC_KIND = LREC_ACC_FREEZE_REC.ACC_KIND;
                    UPDATE ACC_ACCOUNT_SUB
                       SET FRZ_AMT = NVL(FRZ_AMT, 0) - LREC_ACC_FREEZE_REC.FRZ_AMT, FRZ_FLAG = '0', FRZ_DATE = NULL
                     WHERE CARD_NO = LREC_ACC_FREEZE_REC.CARD_NO
                       AND ACC_KIND = LREC_ACC_FREEZE_REC.ACC_KIND;
                END IF;
            END IF;
        END LOOP;
        <<BK_AND_HK>>
    --12.���¿��
        IF NVL(LV_CARD_CONFIG.IS_STOCK, 0) = '0' THEN
            LV_UPDATE_STOCK_SQL := LV_UPDATE_STOCK_SQL || LV_USERS.BRCH_ID || '|' || '1' || '|';
            LV_UPDATE_STOCK_SQL := LV_UPDATE_STOCK_SQL || LV_USERS.USER_ID || '|' ||
                                   LV_ACTION_LOG.DEAL_NO || '|';
            LV_UPDATE_STOCK_SQL := LV_UPDATE_STOCK_SQL || LV_ACTION_LOG.DEAL_CODE || '|' ||
                                   TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss') || '|';
            IF LV_CARD_APPLY.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS THEN
                LV_UPDATE_STOCK_SQL := LV_UPDATE_STOCK_SQL || LV_CARD_APPLY.CARD_NO || '|' || '|' ||
                                       LV_ACTION_LOG.NOTE || '|';
                PK_CARD_STOCK.P_CARD_RELEASE(LV_UPDATE_STOCK_SQL, AV_RES, AV_MSG);
            ELSE
                LV_UPDATE_STOCK_SQL := LV_UPDATE_STOCK_SQL || LV_CARD_APPLY.CARD_NO || '|' ||
                                       PK_CARD_STOCK.GOODS_STATE_ZC || '|' || '0' ||
                                       LV_ACTION_LOG.NOTE || '|';
                PK_CARD_STOCK.P_OUT_STOCK(LV_UPDATE_STOCK_SQL, AV_RES, AV_MSG);
            END IF;
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                ROLLBACK;
                RETURN;
            END IF;
        END IF;
        --13.��������״̬
        IF LV_CARD_APPLY.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS THEN
            SELECT COUNT(*)
              INTO LV_COUNT
              FROM CARD_APPLY
             WHERE TASK_ID = LV_CARD_APPLY.TASK_ID
               AND APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS;
            IF LV_COUNT = 0 THEN
                UPDATE CARD_APPLY_TASK
                   SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_YFF, ISSUSE_NUM = NVL(ISSUSE_NUM, 0) + 1
                 WHERE TASK_ID = LV_CARD_APPLY.TASK_ID;
            ELSE
                UPDATE CARD_APPLY_TASK
                   SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_FKZ, ISSUSE_NUM = NVL(ISSUSE_NUM, 0) + 1
                 WHERE TASK_ID = LV_CARD_APPLY.TASK_ID;
            END IF;
        ELSE
            UPDATE CARD_RECOVER_REGINFO
               SET STATUS = '1', FF_BRCH_ID = LV_USERS.BRCH_ID, FF_USER_ID = LV_USERS.USER_ID, FF_DATE = LV_ACTION_LOG.DEAL_TIME, FF_DEAL_NO = LV_ACTION_LOG.DEAL_NO, NOTE = NOTE ||
                           '_�ѷ���'
             WHERE CARD_NO = LV_CARD_BASEINFO.CARD_NO;
            IF SQL%ROWCOUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���¿�������Ϣ����ȷ�������½��в���';
                RETURN;
            END IF;
        END IF;
        --14.��¼ҵ����־
        LV_SERV_REC.Acpt_Type     := lv_in(2);
        LV_SERV_REC.DEAL_NO       := LV_ACTION_LOG.DEAL_NO;
        LV_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
        LV_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
        LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
        LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
        LV_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
        LV_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
        LV_SERV_REC.DEAL_CODE     := LV_ACTION_LOG.DEAL_CODE;
        LV_SERV_REC.CARD_TYPE     := LV_CARD_APPLY.CARD_TYPE;
        LV_SERV_REC.CARD_AMT      := 1;
        LV_SERV_REC.BIZ_TIME      := LV_ACTION_LOG.DEAL_TIME;
        LV_SERV_REC.USER_ID       := LV_ACTION_LOG.USER_ID;
        LV_SERV_REC.BRCH_ID       := LV_CARD_APPLY.APPLY_BRCH_ID;
        LV_SERV_REC.DEAL_STATE    := '0';
        LV_SERV_REC.CLR_DATE      := LV_PAYCLRPARA.CLR_DATE;
        LV_SERV_REC.RTN_FGFT      := 0;
        LV_SERV_REC.NOTE          := LV_ACTION_LOG.MESSAGE;
        LV_SERV_REC.CARD_AMT      := 1;
        LV_SERV_REC.AGT_CERT_TYPE := NVL(LV_IN(9), '');
        LV_SERV_REC.AGT_CERT_NO   := NVL(LV_IN(10), '');
        LV_SERV_REC.AGT_NAME      := NVL(LV_IN(11), '');
        LV_SERV_REC.AGT_TEL_NO    := NVL(LV_IN(12), '');
        LV_SERV_REC.RSV_ONE       := '0';
        IF LV_IN(2) = 2 THEN
            LV_SERV_REC.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
            LV_SERV_REC.END_DEAL_NO := LV_IN(4);
            LV_SERV_REC.TERM_ID     := LV_IN(3);
        END IF;
        INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
        AV_OUT := LV_SERV_REC.DEAL_NO;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_SMZ_KFF;
    --��ģ����
--����˵����
--1�������/������ BRCH_ID/ACPT_ID ����
--2��������� ACPT_TYPE ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
--3�ն˱��/��Ա��� USER_ID/END_ID ����
--4�ն˲�����ˮ/ҵ����ˮ DEAL_NO/END_DEAL_NO ����
--5ҵ����ˮ
--6�����
--7�Ƿ���¿��
--8�Ƿ�ͬ��ǰ��
--9������֤������
--10������֤������
--11����������
--12��������ϵ��ʽ
--13��ע
  PROCEDURE P_BATCH_KFF(AV_IN IN VARCHAR2, 
                          AV_RES OUT VARCHAR2, 
                          AV_MSG OUT VARCHAR2) IS
        LV_IN                 PK_PUBLIC.MYARRAY;
        LV_USERS              SYS_USERS%ROWTYPE;
        LV_BASE_CO_ORG        BASE_CO_ORG%ROWTYPE;
        LV_CARD_APPLY_TASK    CARD_APPLY_TASK%ROWTYPE;
        LV_CREATE_ACCOUNT_SQL VARCHAR2(500) := '';
        LV_ACTION_LOG         SYS_ACTION_LOG%ROWTYPE;
        LV_BASEPERSONAL       BASE_PERSONAL%ROWTYPE;
        LV_COUNT              INTEGER := 0;
        LV_TOTNUM             INTEGER := 0;
        LV_OUT                VARCHAR2(100);
    BEGIN
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 7, 13, 'PK_CARD_APPLY_ISSUSE.P_BATCH_KFF', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(5) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '��ˮ��Ų���Ϊ��';
            RETURN;
        END IF;
        IF LV_IN(6) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�����Ų���Ϊ��';
            RETURN;
        END IF;
        SELECT COUNT(*)
          INTO LV_COUNT
          FROM CARD_APPLY
         WHERE TASK_ID = LV_IN(6)
           AND APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS;
        IF LV_COUNT = 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_APPLY1;
            AV_MSG := '����������' || LV_IN(6) || 'δ�ҵ���Ҫ���з��ŵ������¼��Ϣ';
            RETURN;
        END IF;
        PK_CARD_STOCK.P_GETCARDAPPLYTASKBYTASKID(LV_IN(6), LV_CARD_APPLY_TASK, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YJS AND
           LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_FKZ THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '������' || LV_IN(6) || '���ǡ��ѽ��ա��򡾷����С�״̬';
            RETURN;
        END IF;
        BEGIN
            SELECT * INTO LV_ACTION_LOG FROM SYS_ACTION_LOG WHERE DEAL_NO = LV_IN(5);
        EXCEPTION
            WHEN OTHERS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '������ˮ' || LV_IN(5) || '�Ҳ�����־��Ϣ';
                RETURN;
        END;
        FOR LREC_CARD IN (SELECT C.CARD_ID, A.CUSTOMER_ID, C.CARD_NO, A.CARD_TYPE, A.MAIN_FLAG, A.SUB_CARD_NO
                            FROM CARD_APPLY A, CARD_BASEINFO C
                           WHERE A.CARD_TYPE = C.CARD_TYPE
                             AND A.CARD_NO = C.CARD_NO
                             AND A.TASK_ID = LV_IN(6)
                             AND A.APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS) LOOP
            LV_CREATE_ACCOUNT_SQL := LV_CREATE_ACCOUNT_SQL || LV_IN(1) || '|' || LV_IN(2) || '|' ||
                                     LV_IN(3) || '|' || LV_IN(4) || '|';
            LV_CREATE_ACCOUNT_SQL := LV_CREATE_ACCOUNT_SQL || LREC_CARD.CARD_NO || '|' || '' || '|' || '0' || '|' || '0' || '|';
            LV_CREATE_ACCOUNT_SQL := LV_CREATE_ACCOUNT_SQL || LV_IN(9) || '|' || LV_IN(10) || '|' ||
                                     LV_IN(11) || '|' || LV_IN(12) || '|' || '��������,task_id=' || lv_in(6)  || '|';
            PK_CARD_APPLY_ISSUSE.P_SMZ_KFF(LV_CREATE_ACCOUNT_SQL, AV_RES, AV_MSG, LV_OUT);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            LV_TOTNUM             := LV_TOTNUM + 1;
            LV_CREATE_ACCOUNT_SQL := '';
        END LOOP;
        IF LV_TOTNUM = 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '������' || LV_CARD_APPLY_TASK.TASK_ID || '��,' || '��Ƭ��Ϣ������';
            RETURN;
        ELSIF LV_TOTNUM <> LV_COUNT THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '������' || LV_CARD_APPLY_TASK.TASK_ID || '��,' || '��Ƭ��Ϣ�����ʹ����������¼������һ��';
            RETURN;
        END IF;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_BATCH_KFF;
    --���˷��ų���
    --����˵����
    --1�������/������ BRCH_ID/ACPT_ID ����
    --2��������� ACPT_TYPE ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
    --3�ն˱��/��Ա��� USER_ID/END_ID ����
    --4�ն˲�����ˮ/ҵ����ˮ DEAL_NO/END_DEAL_NO ����
    --5ԭ������ˮ
    --6�Ƿ���¿��
    --7�Ƿ�ͬ��
    --8������֤������
    --9������֤������
    --10����������
    --11��������ϵ�绰
    --12��ע
    PROCEDURE P_UNDO_SMZ_KFF(AV_IN VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2, AV_OUT OUT VARCHAR2) IS
        LV_IN                        PK_PUBLIC.MYARRAY;
        LV_USERS                     SYS_USERS%ROWTYPE;
        LV_BASE_CO_ORG               BASE_CO_ORG%ROWTYPE;
        LV_CARD_APPLY_TASK           CARD_APPLY_TASK%ROWTYPE;
        LV_BASE_PERSONAL             BASE_PERSONAL%ROWTYPE;
        LV_TR_SERV_REC               TR_SERV_REC%ROWTYPE;
        LV_COUNT                     NUMBER := 0;
        LV_CLR_DATE                  PAY_CLR_PARA.CLR_DATE%TYPE;
        LV_ACTION_LOG                SYS_ACTION_LOG%ROWTYPE;
        LV_CREATE_ACCOUNT_CANCEL_SQL VARCHAR2(500);
        LV_CARD_BASEINFO             CARD_BASEINFO%ROWTYPE;
        LV_CARD_APPLY                CARD_APPLY%ROWTYPE;
        LV_STOCK_LIST                STOCK_LIST%ROWTYPE;
        LV_STOCK_ACC_IN              STOCK_ACC%ROWTYPE;
        LV_CARD_CONFIG               CARD_CONFIG%ROWTYPE;
        LV_SYS_USERS_IN              SYS_USERS%ROWTYPE;
    BEGIN
        SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 6, 12, 'PK_CARD_APPLY_ISSUSE.P_UNDO_SMZ_KFF', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(5) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := 'ԭʼ������ˮ����Ϊ��';
            RETURN;
        END IF;
        BEGIN
            SELECT * INTO LV_TR_SERV_REC FROM TR_SERV_REC WHERE DEAL_NO = LV_IN(5);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '����ԭʼ������ˮ' || LV_IN(5) || 'δ�ҵ�����ҵ����־��Ϣ';
                RETURN;
            WHEN OTHERS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '����ԭʼ������ˮ' || LV_IN(5) || '��ȡ����ҵ����־��Ϣ���ִ���' || SQLERRM;
                RETURN;
        END;
        PK_CARD_APPLY_ISSUSE.P_GETCARDCONFIGBYCARDTYPE(LV_TR_SERV_REC.CARD_TYPE, LV_CARD_CONFIG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_TR_SERV_REC.DEAL_CODE <> '20401050' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '��ˮ' || LV_IN(5) || '��Ӧ��ҵ����־���ǡ����˷��š�ҵ���޷����г���';
            RETURN;
        END IF;
        IF LV_TR_SERV_REC.CARD_NO IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '��ˮ' || LV_IN(5) || '��Ӧ��ҵ����־���Ų����ڣ��޷����г���';
            RETURN;
        END IF;
        EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM TR_SERV_REC WHERE CARD_NO = :1 AND (DEAL_CODE <> :2 AND DEAL_CODE <> :3 AND DEAL_CODE <> :4 AND DEAL_CODE <> :5 AND DEAL_CODE <> :6 AND DEAL_CODE <> :7 AND DEAL_CODE <> :8)'
            INTO LV_COUNT
            USING LV_TR_SERV_REC.CARD_NO, '20401010', '20401020', '20401050', '20401090','10502070','10502080','10502090';
        IF LV_COUNT > 0 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�ÿ�Ƭ�ѽ��й�����ҵ���޷����г���';
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETCARDAPPLYBYCARDNO(LV_TR_SERV_REC.CARD_NO, LV_CARD_APPLY, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_CARD_APPLY.APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_YFF THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�ÿ��������¼���ǡ��ѷ��š�״̬���޷����г���';
            RETURN;
        END IF;
        PK_PUBLIC.P_GETCARDBYCARDNO(LV_CARD_APPLY.CARD_NO, LV_CARD_BASEINFO, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_CARD_BASEINFO.CARD_STATE <> '1' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�ÿ��Ŀ�״̬���������޷����г���';
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_APPLY.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --5.�����³�����־
        SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_ACTION_LOG.DEAL_NO FROM DUAL;
        LV_ACTION_LOG.DEAL_CODE   := '20401090';
        LV_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
        LV_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
        LV_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
        LV_ACTION_LOG.DEAL_TIME   := SYSDATE;
        LV_ACTION_LOG.LOG_TYPE    := '0';
        LV_ACTION_LOG.IN_OUT_DATA := AV_IN;
        LV_ACTION_LOG.CAN_ROLL    := '1';
        LV_ACTION_LOG.ROLL_FLAG   := '0';
        LV_ACTION_LOG.MESSAGE     := NVL(LV_IN(12), '���ų���,ԭ��ˮ' || LV_IN(5));
        INSERT INTO SYS_ACTION_LOG VALUES LV_ACTION_LOG;
        LV_CREATE_ACCOUNT_CANCEL_SQL := LV_ACTION_LOG.DEAL_NO || '|' || LV_ACTION_LOG.DEAL_CODE || '|' ||
                                        LV_ACTION_LOG.USER_ID || '|' ||
                                        TO_CHAR(LV_ACTION_LOG.DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss') || '|' || '1' || '|' || '|' ||
                                        LV_TR_SERV_REC.CARD_NO;
        PK_BUSINESS.P_CREATEACCOUNTCANCEL(LV_CREATE_ACCOUNT_CANCEL_SQL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            null;
            -- RETURN;
        END IF;
        UPDATE CARD_APPLY
           SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS,
               --RECV_BRCH_ID   = NULL,
               RECV_CERT_TYPE = NULL, RECV_CERT_NO = NULL, RECV_NAME = NULL, RECV_PHONE = NULL, RELS_BRCH_ID = NULL, RELS_USER_ID = NULL, RELS_DATE = NULL, ISSUSE_DEAL_NO = NULL
         WHERE APPLY_ID = LV_CARD_APPLY.APPLY_ID;
        IF SQL%ROWCOUNT <> 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���������¼��������ȷ';
            RETURN;
        END IF;
        UPDATE CARD_BASEINFO
           SET CARD_STATE = '0', LAST_MODIFY_DATE = LV_ACTION_LOG.DEAL_TIME
         WHERE CARD_NO = LV_CARD_APPLY.CARD_NO;
        IF SQL%ROWCOUNT <> 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���¿�Ƭ��Ϣ��������ȷ';
            RETURN;
        END IF;
        UPDATE ACC_ACCOUNT_SUB SET ACC_STATE = '0' WHERE CARD_NO = LV_CARD_APPLY.CARD_NO;
        SELECT COUNT(1)
          INTO LV_COUNT
          FROM CARD_APPLY
         WHERE TASK_ID = LV_CARD_APPLY.TASK_ID
           AND APPLY_STATE >= PK_PUBLIC.KG_CARD_APPLY_YFF;
        IF LV_COUNT > 0 THEN
            UPDATE CARD_APPLY_TASK
               SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_FKZ, ISSUSE_NUM = NVL(ISSUSE_NUM, 0) - 1
             WHERE TASK_ID = LV_CARD_APPLY.TASK_ID;
        ELSE
            UPDATE CARD_APPLY_TASK
               SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_YJS, ISSUSE_NUM = NVL(ISSUSE_NUM, 0) - 1
             WHERE TASK_ID = LV_CARD_APPLY.TASK_ID;
        END IF;
        IF SQL%ROWCOUNT <> 1 THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���¿�Ƭ�����ƿ�������ȷ';
            RETURN;
        END IF;
        IF NVL(LV_CARD_CONFIG.IS_STOCK, '0') = '0' THEN
            PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_CARD_APPLY.CARD_NO, LV_STOCK_LIST, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            IF LV_STOCK_LIST.GOODS_STATE <> '0' THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�����ϸ��Ʒ״̬������';
                RETURN;
            END IF;
            IF LV_STOCK_LIST.OWN_TYPE <> '1' THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�����ϸ�������Ͳ����ڿͻ�';
                RETURN;
            END IF;
            IF LV_STOCK_LIST.CUSTOMER_ID <> LV_CARD_APPLY.CUSTOMER_ID THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�����ϸ�����ͻ���������Ϣ��һ��';
                RETURN;
            END IF;
            PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST.OUT_BRCH_ID, LV_STOCK_LIST.OUT_USER_ID, LV_SYS_USERS_IN, AV_RES, AV_MSG, 'ԭʼ�����Ա');
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_LIST.OUT_BRCH_ID, LV_STOCK_LIST.OUT_USER_ID, '1' ||
                                          LV_CARD_APPLY.CARD_TYPE, '0', LV_STOCK_ACC_IN, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                AV_MSG := AV_MSG || ',��ȡԭʼ�����Ա����˻����ִ���';
                RETURN;
            END IF;
            EXECUTE IMMEDIATE 'INSERT INTO STOCK_REC(STK_SER_NO,DEAL_CODE,STK_CODE,BATCH_ID,TASK_ID,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,IN_GOODS_STATE,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,OUT_GOODS_STATE,
GOODS_ID,GOODS_NO,GOODS_NUMS,IN_OUT_FLAG,TR_DATE,ORG_ID,BRCH_ID,USER_ID,AUTH_OPER_ID,
BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,IS_SURE,START_NO,END_NO
)VALUES(SEQ_STK_SER_NO.NEXTVAL,:1,:2,:3,:4,:5,:6,:7,''0'',NULL,NULL,NULL,''0'',' ||
                              ':8,:9,''1'',''1'',:10,' || LV_USERS.ORG_ID || ',' ||
                              LV_USERS.BRCH_ID || ',''' || LV_USERS.USER_ID || ''',NULL,' ||
                              '''0'',:11,:12,:13,''0'',:4,:15) '
                USING LV_ACTION_LOG.DEAL_CODE, LV_STOCK_ACC_IN.STK_CODE, LV_CARD_APPLY.BUY_PLAN_ID, LV_CARD_APPLY.TASK_ID, LV_SYS_USERS_IN.ORG_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_STOCK_LIST.GOODS_ID, LV_STOCK_LIST.GOODS_NO, LV_ACTION_LOG.DEAL_TIME, LV_CLR_DATE, LV_ACTION_LOG.DEAL_NO, LV_ACTION_LOG.MESSAGE, LV_CARD_APPLY.CARD_NO, LV_CARD_APPLY.CARD_NO;
            IF SQL%ROWCOUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��¼��������־���ִ���-' || SQL%ROWCOUNT || '��';
                RETURN;
            END IF;
            EXECUTE IMMEDIATE 'INSERT INTO STOCK_INOUT_DETAIL (STK_INOUT_NO,STK_TYPE,STK_CODE,IN_GOODS_STATE,OUT_GOODS_STATE,ORG_ID,
BRCH_ID,USER_ID,AUTH_USER_ID,DEAL_CODE,DEAL_DATE,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,BATCH_ID,TASK_ID,GOODS_NO,
GOODS_ID,TOT_NUM,TOT_AMT,IN_OUT_FLAG,BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,REV_DATE
)' || '(SELECT SEQ_STK_INOUT_NO.NEXTVAL,SUBSTR(' ||
                              LV_STOCK_ACC_IN.STK_CODE ||
                              ',1,1),STK_CODE,GOODS_STATE,NULL,:1,:2,:3,NULL,' ||
                              ':4,:5,:6,:7,:8,NULL,NULL,NULL,BATCH_ID,TASK_ID,GOODS_NO,GOODS_ID,''1'',' ||
                              '''0'',''1'',''0'',:9,:10,:11,NULL ' ||
                              'FROM STOCK_LIST WHERE STK_IS_SURE = ''0'' AND OWN_TYPE = ''1'' AND GOODS_STATE = ''0'' AND ' ||
                              'STK_CODE = ''' || LV_STOCK_ACC_IN.STK_CODE || ''' AND GOODS_NO = ''' ||
                              LV_CARD_APPLY.CARD_NO || ''')'
                USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_ACTION_LOG.DEAL_CODE, LV_ACTION_LOG.DEAL_TIME, LV_SYS_USERS_IN.ORG_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_CLR_DATE, LV_ACTION_LOG.DEAL_NO, LV_ACTION_LOG.MESSAGE;
            IF SQL%ROWCOUNT < 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��¼���������ˮ��Ϣ���ִ��󣬸��������ϸ����';
                RETURN;
            END IF;
            IF SQL%ROWCOUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��¼���������ˮ��Ϣ���ִ������¼' || '1' || '����ʵ�ʼ�¼' || SQL%ROWCOUNT || '��';
                RETURN;
            END IF;
            EXECUTE IMMEDIATE 'UPDATE STOCK_LIST SET OWN_TYPE = ''0'',BRCH_ID = :1,IN_DEAL_NO = ''' ||
                              LV_ACTION_LOG.DEAL_NO || '''' ||
                              ',USER_ID = :2,ORG_ID = :3,CUSTOMER_ID = NULL,CUSTOMER_NAME = NULL,' ||
                              'IN_DATE = :4 ' || 'WHERE OWN_TYPE = ''1'' AND GOODS_STATE = ''0'' ' ||
                              'AND STK_IS_SURE = ''0'' AND STK_CODE = ''' ||
                              LV_STOCK_ACC_IN.STK_CODE || ''' and GOODS_NO = ''' ||
                              LV_STOCK_LIST.GOODS_NO || ''''
                USING LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_SYS_USERS_IN.ORG_ID, LV_ACTION_LOG.DEAL_TIME;
            IF SQL%ROWCOUNT < 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���¸��������ϸ������������ȷ�����������ϸ��Ʒ��������';
                RETURN;
            ELSIF SQL%ROWCOUNT > 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���¸��������ϸ������������ȷ��������1����ʵ�ʸ���' || SQL%ROWCOUNT || '��';
                RETURN;
            END IF;
            UPDATE STOCK_ACC
               SET TOT_NUM = NVL(TOT_NUM, 0) + 1, LAST_DEAL_DATE = LV_ACTION_LOG.DEAL_TIME
             WHERE GOODS_STATE = '0'
               AND USER_ID = LV_SYS_USERS_IN.USER_ID
               AND BRCH_ID = LV_SYS_USERS_IN.BRCH_ID
               AND STK_CODE = LV_STOCK_ACC_IN.STK_CODE;
            IF SQL%ROWCOUNT <> '1' THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := 'ԭʼ�����Ա����˻�������';
                RETURN;
            END IF;
        END IF;
        IF LV_IN(7) = '0' THEN
            PK_CARD_APPLY_ISSUSE.P_SYNCH2CARD_UPATE(NULL, LV_BASE_PERSONAL.CERT_NO, LV_CARD_BASEINFO.CARD_NO, NULL, LV_ACTION_LOG.DEAL_NO, '1', AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        UPDATE TR_SERV_REC SET RSV_ONE = '1' WHERE DEAL_NO = LV_IN(5);
        LV_TR_SERV_REC.Acpt_Type     := lv_in(2);
        LV_TR_SERV_REC.DEAL_NO       := LV_ACTION_LOG.DEAL_NO;
        LV_TR_SERV_REC.DEAL_CODE     := LV_ACTION_LOG.DEAL_CODE;
        LV_TR_SERV_REC.BIZ_TIME      := LV_ACTION_LOG.DEAL_TIME;
        LV_TR_SERV_REC.BRCH_ID       := LV_ACTION_LOG.BRCH_ID;
        LV_TR_SERV_REC.USER_ID       := LV_ACTION_LOG.USER_ID;
        LV_TR_SERV_REC.ORG_ID        := LV_ACTION_LOG.ORG_ID;
        LV_TR_SERV_REC.DEAL_STATE    := '0';
        LV_TR_SERV_REC.CLR_DATE      := LV_CLR_DATE;
        LV_TR_SERV_REC.CUSTOMER_ID   := LV_CARD_APPLY.CUSTOMER_ID;
        LV_TR_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
        LV_TR_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
        LV_TR_SERV_REC.CARD_AMT      := 1;
        LV_TR_SERV_REC.CARD_TYPE     := LV_CARD_BASEINFO.CARD_TYPE;
        LV_TR_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
        LV_TR_SERV_REC.AGT_CERT_TYPE := NVL(LV_IN(8), '');
        LV_TR_SERV_REC.AGT_CERT_NO   := NVL(LV_IN(9), '');
        LV_TR_SERV_REC.AGT_NAME      := NVL(LV_IN(10), '');
        LV_TR_SERV_REC.AGT_TEL_NO    := NVL(LV_IN(11), '');
        LV_TR_SERV_REC.NOTE          := NVL(LV_ACTION_LOG.MESSAGE, '');
        INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
        AV_OUT := LV_ACTION_LOG.DEAL_NO;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_UNDO_SMZ_KFF;
    --�ж����������
    --AV_ACPT_ID �������
    --AV_ACPT_TYPE���������
    --AV_OPER_ID ����Ա���
    --AV_SYS_USERS ����Ա��Ϣ
    --AV_BASE_CO_ORG ����������Ϣ
    --AV_RES ����������
    --AV_MSG ������˵��
    PROCEDURE P_JUDGE_ACPT(AV_ACPT_ID VARCHAR2, AV_ACPT_TYPE VARCHAR2, AV_OPER_ID VARCHAR2, AV_SYS_USERS OUT SYS_USERS%ROWTYPE, AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        IF AV_ACPT_ID IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '������Ų���ȷ';
            RETURN;
        END IF;
        IF AV_ACPT_TYPE IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '��������Ͳ���ȷ';
            RETURN;
        END IF;
        IF AV_ACPT_TYPE = '1' THEN
            IF AV_OPER_ID IS NULL THEN
                AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
                AV_MSG := '��Ա��Ų���Ϊ��';
                RETURN;
            END IF;
            PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_ACPT_ID, AV_OPER_ID, AV_SYS_USERS, AV_RES, AV_MSG, '��Ա��Ϣ');
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        ELSIF AV_ACPT_TYPE = '2' THEN
            BEGIN
                SELECT * INTO AV_BASE_CO_ORG FROM BASE_CO_ORG WHERE CO_ORG_ID = AV_ACPT_ID;
                PK_PUBLIC.P_GETORGOPERATOR(AV_ACPT_ID, AV_SYS_USERS, AV_RES, AV_MSG);
                IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                    RETURN;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
                    AV_MSG := '���ݺ����������' || AV_ACPT_ID || '�Ҳ�������������Ϣ';
                    RETURN;
                WHEN OTHERS THEN
                    AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
                    AV_MSG := '���ݺ����������' || AV_ACPT_ID || '��ȡ����������Ϣ���ִ���' || SQLERRM;
                    RETURN;
            END;
        ELSE
            AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
            AV_MSG := '��������Ͳ���ȷ';
            RETURN;
        END IF;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_JUDGE_ACPT;
    --���ݿ��Ż�ȡ�����¼��Ϣ
    --AV_CARD_NO ����
    --AV_CARD_APPLY ������Ϣ
    --AV_RES ����������
    --AV_MSG ������˵��
    PROCEDURE P_GETCARDAPPLYBYCARDNO(AV_CARD_NO CARD_APPLY.CARD_NO%TYPE, AV_CARD_APPLY OUT CARD_APPLY%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        IF AV_CARD_NO IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_CARD_APPLY_NOEXIST;
            AV_MSG := '���ݿ��Ż�ȡ������Ϣ�����Ų���Ϊ��';
            RETURN;
        END IF;
        SELECT * INTO AV_CARD_APPLY FROM CARD_APPLY WHERE CARD_NO = AV_CARD_NO;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_CARD_APPLY_NOEXIST;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '�Ҳ��������¼��Ϣ';
            RETURN;
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '��ȡ�����¼��Ϣ���ִ���' || SQLERRM;
    END P_GETCARDAPPLYBYCARDNO;
    --���ݿ��Ż�ȡ����Ϣ
    PROCEDURE P_GET_CARD_BASEINFO(AV_CARD_NO CARD_BASEINFO.CARD_NO%TYPE, AV_CARD_BASEINFO OUT CARD_BASEINFO%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        IF AV_CARD_NO IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
            AV_MSG := '���Ų���Ϊ��';
        END IF;
        IF LENGTH(AV_CARD_NO) >= 15 THEN
            SELECT * INTO AV_CARD_BASEINFO FROM CARD_BASEINFO WHERE CARD_NO = AV_CARD_NO;
        ELSE
            SELECT *
              INTO AV_CARD_BASEINFO
              FROM CARD_BASEINFO
             WHERE CARD_NO =
                   (SELECT CARD_NO
                      FROM CARD_APPLY
                     WHERE SUB_CARD_NO = AV_CARD_NO
                       AND APPLY_DATE =
                           (SELECT MAX(APPLY_DATE) FROM CARD_APPLY WHERE SUB_CARD_NO = AV_CARD_NO))
               AND SUB_CARD_NO = AV_CARD_NO;
        END IF;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '�Ҳ�������Ϣ' || SQLERRM;
            RETURN;
        WHEN TOO_MANY_ROWS THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '�ҵ���������Ϣ' || SQLERRM;
            RETURN;
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '��ȡ����Ϣ���ִ���' || SQLERRM;
    END P_GET_CARD_BASEINFO;
    --��ȡ�����п���Ϣ
    PROCEDURE P_GET_BIND_BANKCARD(AV_CARD_NO CARD_BASEINFO.SUB_CARD_NO%TYPE, AV_CARD_BIND_BANKCARD OUT CARD_BIND_BANKCARD%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        SELECT * INTO AV_CARD_BIND_BANKCARD FROM CARD_BIND_BANKCARD WHERE SUB_CARD_NO = AV_CARD_NO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || 'δ�ҵ����п�����Ϣ';
            RETURN;
        WHEN TOO_MANY_ROWS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '�ҵ��������п�����Ϣ';
            RETURN;
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ���' || AV_CARD_NO || '��ȡ���п�����Ϣ���ִ���' || SQLERRM;
    END P_GET_BIND_BANKCARD;
    --����֤�������ȡ��Ա��Ϣ
    --AV_CERT_NO �ͻ����
    --AV_BASE_PERSONAL ��Ա��Ϣ
    --AV_RES ����������
    --AV_MSG ������˵��
    PROCEDURE P_GET_BASE_PERSONAL(AV_CERT_NO BASE_PERSONAL.CERT_NO%TYPE, AV_BASE_PERSONAL OUT BASE_PERSONAL%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        IF AV_CERT_NO IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����֤�������ȡ��Ա��Ϣ��֤�����벻��Ϊ��';
            RETURN;
        END IF;
        SELECT * INTO AV_BASE_PERSONAL FROM BASE_PERSONAL WHERE CERT_NO = AV_CERT_NO;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����֤������' || AV_CERT_NO || '�Ҳ�����Ա��Ϣ';
            RETURN;
        WHEN TOO_MANY_ROWS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����֤������' || AV_CERT_NO || '�ҵ�����������Ϣ' || SQLERRM;
            RETURN;
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����֤������' || AV_CERT_NO || '��ȡ��Ա��Ϣ���ִ���';
            RETURN;
    END P_GET_BASE_PERSONAL;
    --���ݿͻ���Ż�ȡ��Ա��Ϣ
    --AV_CUSTOMER_ID �ͻ����
    --AV_BASE_PERSONAL ��Ա��Ϣ
    --AV_RES ����������
    --AV_MSG ������˵��
    PROCEDURE P_GETBASEPERSONALBYCUSTOMERID(AV_CUSTOMER_ID BASE_PERSONAL.CUSTOMER_ID%TYPE, AV_BASE_PERSONAL OUT BASE_PERSONAL%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        IF AV_CUSTOMER_ID IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿͻ���Ż�ȡ��Ա��Ϣ���ͻ���Ų���Ϊ��';
            RETURN;
        END IF;
        SELECT * INTO AV_BASE_PERSONAL FROM BASE_PERSONAL WHERE CUSTOMER_ID = AV_CUSTOMER_ID;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿͻ����' || AV_CUSTOMER_ID || '�Ҳ�����Ա��Ϣ';
            RETURN;
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿͻ����' || AV_CUSTOMER_ID || '��ȡ��Ա��Ϣ���ִ���';
    END P_GETBASEPERSONALBYCUSTOMERID;
    --���ݿ����ͻ�ȡ������������Ϣ
    --AV_CARD_TYPE ������
    --AV_CARD_CONFIG ������������Ϣ
    --AV_RES ����������
    --AV_MSG ������˵��
    PROCEDURE P_GETCARDCONFIGBYCARDTYPE(AV_CARD_TYPE CARD_CONFIG.CARD_TYPE%TYPE, AV_CARD_CONFIG OUT CARD_CONFIG%ROWTYPE, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    BEGIN
        IF AV_CARD_TYPE IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ����ͻ�ȡ��������Ϣ�������Ͳ���Ϊ��';
            RETURN;
        END IF;
        SELECT * INTO AV_CARD_CONFIG FROM CARD_CONFIG WHERE CARD_TYPE = AV_CARD_TYPE;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ�����' || AV_CARD_TYPE || '�Ҳ�����������Ϣ';
            RETURN;
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ�����' || AV_CARD_TYPE || '��ȡ��������Ϣ���ִ���';
    END P_GETCARDCONFIGBYCARDTYPE;
    --�������е���˷����ļ�
    --AV_IN
    -- BATCH_ID ���κ�
    PROCEDURE P_APPLY_BANK_SH(AV_IN VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
        LV_IN      PK_PUBLIC.MYARRAY;
        LV_SUC_NUM NUMBER := 0;
        LV_ERR_NUM NUMBER := 0;
    BEGIN
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 1, 1, 'pk_card_apply_issuse.p_apply_bank_sh', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(1) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���κŲ���Ϊ��';
            RETURN;
        END IF;
        FOR TEMP_TASK IN (SELECT *
                            FROM CARD_APPLY_TASK
                           WHERE MAKE_BATCH_ID = TRIM(LV_IN(1))
                             AND TASK_STATE = '03') LOOP
            FOR TEMP_REC_YHSH IN (SELECT *
                                    FROM CARD_APPLY_BANK_RH
                                   WHERE TASK_ID = TEMP_TASK.TASK_ID
                                     AND BATCH_ID = TEMP_TASK.MAKE_BATCH_ID) LOOP
                --����״̬00-������,10-���������ɣ�11-�ѷ�����ί��12-����ί��˲�ͨ��13-����ίͨ����14-�ѷ����У�15-���в�ͨ����16-������ͨ����
                --20-�ƿ��У� 30-���ƿ� 40-������ 50-�ѽ���  60-�ѷ��� 70-���˿���80-�ѻ��� 90ע��)
                IF TRIM(TEMP_REC_YHSH.RES_FLAG) = '1' THEN
                    LV_SUC_NUM := LV_SUC_NUM + 1;
                    UPDATE CARD_APPLY
                       SET APPLY_STATE = '16'
                     WHERE APPLY_ID = (SELECT APPLY_ID
                                         FROM CARD_TASK_LIST
                                        WHERE DATA_SEQ = TRIM(TEMP_REC_YHSH.DATA_SEQ)
                                          AND TASK_ID = TRIM(TEMP_REC_YHSH.TASK_ID));
                ELSIF TRIM(TEMP_REC_YHSH.RES_FLAG) = '0' THEN
                    LV_ERR_NUM := LV_ERR_NUM + 1;
                    UPDATE CARD_APPLY
                       SET APPLY_STATE = '15'
                     WHERE APPLY_ID = (SELECT APPLY_ID
                                         FROM CARD_TASK_LIST
                                        WHERE DATA_SEQ = TRIM(TEMP_REC_YHSH.DATA_SEQ)
                                          AND TASK_ID = TRIM(TEMP_REC_YHSH.TASK_ID));
                ELSE
                    LV_ERR_NUM := LV_ERR_NUM + 1;
                    UPDATE CARD_APPLY
                       SET APPLY_STATE = '15'
                     WHERE APPLY_ID = (SELECT APPLY_ID
                                         FROM CARD_TASK_LIST
                                        WHERE DATA_SEQ = TRIM(TEMP_REC_YHSH.DATA_SEQ)
                                          AND TASK_ID = TRIM(TEMP_REC_YHSH.TASK_ID));
                END IF;
                UPDATE CARD_APPLY_BANK_RH
                   SET STATE = '0'
                 WHERE DATA_SEQ = TEMP_REC_YHSH.DATA_SEQ
                   AND TASK_ID = TEMP_REC_YHSH.TASK_ID;
            END LOOP;
            IF (LV_SUC_NUM + LV_ERR_NUM) <> TEMP_TASK.TASK_SUM THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��������' || TEMP_TASK.TASK_ID || 'ʱ�����ص���˽����ϸ����������������һ��';
                RETURN;
            END IF;
            UPDATE CARD_APPLY_TASK
               SET TASK_STATE = '04', YH_NUM = LV_SUC_NUM, END_NUM = LV_SUC_NUM
             WHERE TASK_ID = TEMP_TASK.TASK_ID;
            LV_SUC_NUM := 0;
            LV_ERR_NUM := 0;
        END LOOP;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '��������' || LV_IN(1) || 'ʱ�����ִ���' || SQLERRM;
    END P_APPLY_BANK_SH;
    --���쳷��
    --AV_IN
    --1.�������
    --2.���������
    --3.����Ա
    --4.������ˮ
    --5.���쵥��
    --6.������֤������
    --7.������֤������
    --8.����������
    --9.�����˵绰
    --10.��ע
    --ALL_OUT
    --1.AV_RES ����������
    --2.AV_MSG ������˵��
    --3.AV_OUT ������� DEAL_NO|....|...|     |�߷ָ���ַ���
    PROCEDURE P_APPLY_CANCEL(AV_IN VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2, AV_OUT OUT VARCHAR2) IS
        LV_IN             PK_PUBLIC.MYARRAY;
        LV_USERS          SYS_USERS%ROWTYPE;
        LV_USERS_OUT      SYS_USERS%ROWTYPE;
        LV_BASE_CO_ORG    BASE_CO_ORG%ROWTYPE;
        LV_CARD_APPLY     CARD_APPLY%ROWTYPE;
        LV_SYS_ACTION_LOG SYS_ACTION_LOG%ROWTYPE;
        LV_TR_SERV_REC    TR_SERV_REC%ROWTYPE;
        LV_BASE_PERSONAL  BASE_PERSONAL%ROWTYPE;
        LV_IN_PARA        VARCHAR2(200);
        LV_PAYCLRPARA     PAY_CLR_PARA%ROWTYPE;
        LV_CARD_STATE     CARD_BASEINFO.CARD_STATE%TYPE;
        LV_CARD_CONFIG    CARD_CONFIG%ROWTYPE;
        LV_STOCK_ACC_OUT  STOCK_ACC%ROWTYPE;
        LV_STOCK_LIST     STOCK_LIST%ROWTYPE;
        LV_CARD_BASEINFO  CARD_BASEINFO%ROWTYPE;
    BEGIN
        --1.��������
        SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 4, 10, 'PK_CARD_APPLY_ISSUSE.P_APPLY_CANCEL', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(5) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�����Ų���Ϊ��';
            RETURN;
        END IF;
        --2.������ж�
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --3.���������ж�
        BEGIN
            SELECT * INTO LV_CARD_APPLY FROM CARD_APPLY WHERE APPLY_ID = LV_IN(5);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '����������' || LV_IN(5) || '�Ҳ��������¼��Ϣ';
                RETURN;
            WHEN OTHERS THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '����������' || LV_IN(5) || '��ȡ������Ϣʱ���ִ���' || SQLERRM;
                RETURN;
        END;
        IF NVL(LV_CARD_APPLY.APPLY_STATE, '-1') <> PK_PUBLIC.KG_CARD_APPLY_YSQ THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '������Ϊ' || LV_IN(5) || '�������¼״̬���ǡ������롿���޷����г���';
            RETURN;
        END IF;
        IF NVL(LV_CARD_APPLY.APPLY_WAY, '-1') <> '0' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '������Ϊ' || LV_IN(5) || '�������¼���ǡ��������졿���޷����г���';
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_APPLY.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        --4.��¼������־
        SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYS_ACTION_LOG.DEAL_NO FROM DUAL;
        IF NVL(LV_CARD_APPLY.APPLY_TYPE, -1) = 0 THEN
            LV_SYS_ACTION_LOG.DEAL_CODE := '20401080';
            LV_SYS_ACTION_LOG.MESSAGE   := '���쳷��,���쵥��' || LV_IN(5) || ',֤������:' ||
                                           LV_BASE_PERSONAL.CERT_NO || ',����:' ||
                                           LV_BASE_PERSONAL.NAME || NVL(LV_IN(10), '');
        ELSIF NVL(LV_CARD_APPLY.APPLY_TYPE, -1) = 1 THEN
            LV_SYS_ACTION_LOG.DEAL_CODE := '20501181';
            LV_SYS_ACTION_LOG.MESSAGE   := '�������쳷��,���쵥��' || LV_IN(5) || ',֤������:' ||
                                           LV_BASE_PERSONAL.CERT_NO || ',����:' ||
                                           LV_BASE_PERSONAL.NAME || NVL(LV_IN(10), '');
        ELSIF NVL(LV_CARD_APPLY.APPLY_TYPE, -1) = 2 THEN
            LV_SYS_ACTION_LOG.DEAL_CODE := '20501171';
            LV_SYS_ACTION_LOG.MESSAGE   := '�������쳷��,���쵥��' || LV_IN(5) || ',֤������:' ||
                                           LV_BASE_PERSONAL.CERT_NO || ',����:' ||
                                           LV_BASE_PERSONAL.NAME || NVL(LV_IN(10), '');
        ELSE
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�������Ͳ���ȷ���޷����г���';
            RETURN;
        END IF;
        LV_SYS_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
        LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
        LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
        LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
        LV_SYS_ACTION_LOG.LOG_TYPE    := '1';
        LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
        LV_SYS_ACTION_LOG.CAN_ROLL    := '0';
        LV_SYS_ACTION_LOG.ROLL_FLAG   := '0';
        LV_SYS_ACTION_LOG.NOTE        := LV_SYS_ACTION_LOG.MESSAGE;
        IF LV_IN(2) = '2' THEN
            LV_SYS_ACTION_LOG.ORG_ID    := LV_BASE_CO_ORG.ORG_ID;
            LV_SYS_ACTION_LOG.CO_ORG_ID := LV_BASE_CO_ORG.CO_ORG_ID;
        END IF;
        INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
        --5.�˻������ѼӼ���
        IF NVL(LV_CARD_APPLY.COST_FEE, 0) > 0 AND LV_IN(2) = '1' THEN
            LV_IN_PARA := LV_SYS_ACTION_LOG.DEAL_NO || '|' || LV_SYS_ACTION_LOG.DEAL_CODE || '|' ||
                          LV_SYS_ACTION_LOG.USER_ID || '|' ||
                          TO_CHAR(LV_SYS_ACTION_LOG.DEAL_TIME, 'YYYY-MM-DD HH24:MI:SS') || '|' ||
                          '702101' || '|' || '-' || LV_CARD_APPLY.COST_FEE || '|' ||
                          LV_SYS_ACTION_LOG.MESSAGE || ',�˻�������|' || LV_IN(2) || '|' || '0' || '|';
            PK_BUSINESS.P_COST(LV_IN_PARA, '1', AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        IF NVL(LV_CARD_APPLY.URGENT_FEE, 0) > 0 AND LV_IN(2) = '1' THEN
            LV_IN_PARA := '';
            LV_IN_PARA := LV_SYS_ACTION_LOG.DEAL_NO || '|' || LV_SYS_ACTION_LOG.DEAL_CODE || '|' ||
                          LV_SYS_ACTION_LOG.USER_ID || '|' ||
                          TO_CHAR(LV_SYS_ACTION_LOG.DEAL_TIME, 'YYYY-MM-DD HH24:MI:SS') || '|' ||
                          '702101' || '|' || '-' || LV_CARD_APPLY.URGENT_FEE || '|' ||
                          LV_SYS_ACTION_LOG.MESSAGE || ',�˻��Ӽ���|' || LV_IN(2) || '|' || '0' || '|';
            PK_BUSINESS.P_COST(LV_IN_PARA, '1', AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        --6.����ǲ���������,��ԭ�Ͽ���״̬
        IF LV_CARD_APPLY.APPLY_TYPE = '1' THEN
            LV_CARD_STATE := '1';
        ELSIF LV_CARD_APPLY.APPLY_TYPE = '2' THEN
            LV_CARD_STATE := '3';
        END IF;
        IF LV_CARD_APPLY.APPLY_TYPE = '1' OR LV_CARD_APPLY.APPLY_TYPE = '2' THEN
            IF LV_CARD_APPLY.OLD_CARD_NO IS NOT NULL THEN
                PK_CARD_APPLY_ISSUSE.P_GET_CARD_BASEINFO(LV_CARD_APPLY.OLD_CARD_NO, LV_CARD_BASEINFO, AV_RES, AV_MSG);
                IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                    RETURN;
                END IF;
                UPDATE CARD_BASEINFO
                   SET CARD_STATE = LV_CARD_STATE, LAST_MODIFY_DATE = LV_SYS_ACTION_LOG.DEAL_TIME, CANCEL_DATE = NULL, CANCEL_REASON = NULL
                 WHERE CARD_NO = LV_CARD_APPLY.OLD_CARD_NO
                   AND CUSTOMER_ID = LV_CARD_APPLY.CUSTOMER_ID;
                IF SQL%ROWCOUNT <> 1 THEN
                    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                    AV_MSG := '�����Ͽ���״̬ʱ����' || SQL%ROWCOUNT || '��';
                    RETURN;
                END IF;
                UPDATE ACC_ACCOUNT_SUB
                   SET ACC_STATE = LV_CARD_STATE, CLS_DATE = NULL, CLS_USER_ID = NULL, LSS_DATE = NULL
                 WHERE CARD_NO = LV_CARD_APPLY.OLD_CARD_NO
                   AND CUSTOMER_ID = LV_CARD_APPLY.CUSTOMER_ID;
                IF SQL%ROWCOUNT <= 0 THEN
                    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                    AV_MSG := '�����Ͽ����˻�ʱ����' || SQL%ROWCOUNT || '��';
                    RETURN;
                END IF;
                UPDATE CARD_APPLY
                   SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YFF
                 WHERE CARD_NO = LV_CARD_APPLY.OLD_CARD_NO;
            END IF;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETCARDCONFIGBYCARDTYPE(LV_CARD_APPLY.CARD_TYPE, LV_CARD_CONFIG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF NVL(LV_CARD_CONFIG.IS_STOCK, '0') = '0' AND LV_CARD_APPLY.OLD_CARD_NO IS NOT NULL AND
           LV_CARD_BASEINFO.RECOVER_FLAG = '0' THEN
            PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_CARD_APPLY.OLD_CARD_NO, LV_STOCK_LIST, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�Ͽ������ϸ�������Ͳ����ڹ�Ա';
                RETURN;
            END IF;
            IF LV_STOCK_LIST.CUSTOMER_ID <> LV_CARD_APPLY.CUSTOMER_ID THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '�Ͽ������ϸ�����ͻ���������Ϣ��һ��';
                RETURN;
            END IF;
            PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST.BRCH_ID, LV_STOCK_LIST.USER_ID, LV_USERS_OUT, AV_RES, AV_MSG, '�Ͽ�������Ա��Ϣ');
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_LIST.BRCH_ID, LV_STOCK_LIST.USER_ID, LV_STOCK_LIST.STK_CODE, LV_STOCK_LIST.GOODS_STATE, --�����˻�,������ �Ͽ�ת��Ŀ���˻�
                                         LV_STOCK_ACC_OUT, AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
            IF LV_STOCK_ACC_OUT.TOT_NUM < 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��������˻�����';
                RETURN;
            END IF;
            EXECUTE IMMEDIATE 'INSERT INTO STOCK_REC(STK_SER_NO,DEAL_CODE,STK_CODE,BATCH_ID,TASK_ID,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,IN_GOODS_STATE,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,OUT_GOODS_STATE,
GOODS_ID,GOODS_NO,GOODS_NUMS,IN_OUT_FLAG,TR_DATE,ORG_ID,BRCH_ID,USER_ID,AUTH_OPER_ID,
BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,IS_SURE,START_NO,END_NO
)VALUES(SEQ_STK_SER_NO.NEXTVAL,:1,:2,NULL,NULL,NULL,NULL,NULL,NULL,:3,:4,:5,:6,' ||
                              ':7,:8,''1'',''2'',:9,' || LV_USERS.ORG_ID || ',' || LV_USERS.BRCH_ID ||
                              ',''' || LV_USERS.USER_ID || ''',NULL,' ||
                              '''0'',:10,:11,:12,''0'',:13,:14) '
                USING LV_SYS_ACTION_LOG.DEAL_NO, LV_STOCK_ACC_OUT.STK_CODE, LV_USERS_OUT.ORG_ID, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_STOCK_LIST.GOODS_STATE, LV_STOCK_LIST.GOODS_ID, LV_STOCK_LIST.GOODS_NO, LV_SYS_ACTION_LOG.DEAL_TIME, LV_PAYCLRPARA.CLR_DATE, LV_SYS_ACTION_LOG.DEAL_NO, LV_SYS_ACTION_LOG.MESSAGE, LV_CARD_APPLY.OLD_CARD_NO, LV_CARD_APPLY.OLD_CARD_NO;
            IF SQL%ROWCOUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��¼��������־���ִ���-' || SQL%ROWCOUNT || '��';
                RETURN;
            END IF;
            EXECUTE IMMEDIATE 'INSERT INTO STOCK_INOUT_DETAIL (STK_INOUT_NO,STK_TYPE,STK_CODE,IN_GOODS_STATE,OUT_GOODS_STATE,ORG_ID,
BRCH_ID,USER_ID,AUTH_USER_ID,DEAL_CODE,DEAL_DATE,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,BATCH_ID,TASK_ID,GOODS_NO,
GOODS_ID,TOT_NUM,TOT_AMT,IN_OUT_FLAG,BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,REV_DATE
)' || '(SELECT SEQ_STK_INOUT_NO.NEXTVAL,SUBSTR(' ||
                              LV_STOCK_ACC_OUT.STK_CODE ||
                              ',1,1),STK_CODE,NULL,GOODS_STATE,:1,:2,:3,NULL,' ||
                              ':4,:5,NULL,NULL,NULL,:6,:7,:8,BATCH_ID,TASK_ID,GOODS_NO,GOODS_ID,''1'',' ||
                              '''0'',''2'',''0'',:9,:10,:11,NULL ' ||
                              'FROM STOCK_LIST WHERE OWN_TYPE = ''0'' AND GOODS_STATE = :12 AND ' ||
                              'STK_CODE = ''' || LV_STOCK_ACC_OUT.STK_CODE ||
                              ''' AND GOODS_NO = ''' || LV_CARD_APPLY.OLD_CARD_NO || ''')'
                USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_SYS_ACTION_LOG.DEAL_CODE, LV_SYS_ACTION_LOG.DEAL_TIME, LV_USERS_OUT.ORG_ID, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_PAYCLRPARA.CLR_DATE, LV_SYS_ACTION_LOG.DEAL_NO, LV_SYS_ACTION_LOG.MESSAGE, LV_STOCK_LIST.GOODS_STATE;
            IF SQL%ROWCOUNT < 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��¼���������ˮ��Ϣ���ִ��󣬿����ϸ������';
                RETURN;
            END IF;
            IF SQL%ROWCOUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '��¼���������ˮ��Ϣ���ִ������¼' || '1' || '����ʵ�ʼ�¼' || SQL%ROWCOUNT || '��';
                RETURN;
            END IF;
            EXECUTE IMMEDIATE 'UPDATE STOCK_LIST SET GOODS_STATE = ''0'',OWN_TYPE = ''1'',BRCH_ID = NULL,' ||
                              'USER_ID = NULL,ORG_ID = NULL,CUSTOMER_ID = :1,CUSTOMER_NAME = :2,OUT_BRCH_ID = :3,OUT_USER_ID = :4,OUT_DATE = :5,OUT_DEAL_NO = :6' ||
                              'WHERE OWN_TYPE = ''0'' AND STK_CODE = ''' ||
                              LV_STOCK_ACC_OUT.STK_CODE || ''' AND GOODS_NO = ''' ||
                              LV_STOCK_LIST.GOODS_NO || ''''
                USING LV_BASE_PERSONAL.CUSTOMER_ID, LV_BASE_PERSONAL.NAME, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_SYS_ACTION_LOG.DEAL_TIME, LV_SYS_ACTION_LOG.DEAL_NO;
            IF SQL%ROWCOUNT < 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���¸��������ϸ������������ȷ�����������ϸ��Ʒ��������';
                RETURN;
            ELSIF SQL%ROWCOUNT > 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���¸��������ϸ������������ȷ��������1����ʵ�ʸ���' || SQL%ROWCOUNT || '��';
                RETURN;
            END IF;
            UPDATE STOCK_ACC
               SET TOT_NUM = NVL(TOT_NUM, 0) - 1, LAST_DEAL_DATE = LV_SYS_ACTION_LOG.DEAL_TIME
             WHERE GOODS_STATE = LV_STOCK_ACC_OUT.GOODS_STATE
               AND USER_ID = LV_USERS_OUT.USER_ID
               AND BRCH_ID = LV_USERS_OUT.BRCH_ID
               AND STK_CODE = LV_STOCK_ACC_OUT.STK_CODE
               AND ORG_ID = LV_USERS_OUT.ORG_ID;
            IF SQL%ROWCOUNT <> 1 THEN
                AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
                AV_MSG := '���¿���˻�����ȷ����������˻�������';
                RETURN;
            END IF;
        END IF;
        --8.����ǻ��������¼�������ȥ������,����ǲ����򲻼�ȥ������
        IF LV_CARD_APPLY.APPLY_TYPE = '1' AND LV_CARD_APPLY.OLD_CARD_NO IS NOT NULL THEN
            PK_SERVICE_OUTER.P_CARD_BLACK(LV_SYS_ACTION_LOG.DEAL_NO, LV_CARD_APPLY.OLD_CARD_NO, '1', '', TO_CHAR(LV_SYS_ACTION_LOG.DEAL_TIME, 'YYYY-MM-DD HH24:MI:SS'), AV_RES, AV_MSG);
            IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
                RETURN;
            END IF;
        END IF;
        DELETE FROM CARD_APPLY WHERE APPLY_ID = LV_CARD_APPLY.APPLY_ID;
        LV_TR_SERV_REC.Acpt_Type     := lv_in(2);
        LV_TR_SERV_REC.DEAL_NO       := LV_SYS_ACTION_LOG.DEAL_NO;
        LV_TR_SERV_REC.DEAL_CODE     := LV_SYS_ACTION_LOG.DEAL_CODE;
        LV_TR_SERV_REC.BIZ_TIME      := LV_SYS_ACTION_LOG.DEAL_TIME;
        LV_TR_SERV_REC.CARD_NO       := LV_CARD_APPLY.OLD_CARD_NO;
        LV_TR_SERV_REC.CARD_AMT      := 1;
        LV_TR_SERV_REC.CARD_TYPE     := LV_CARD_APPLY.CARD_TYPE;
        LV_TR_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
        LV_TR_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
        LV_TR_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
        LV_TR_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
        LV_TR_SERV_REC.AGT_NAME      := LV_IN(8);
        LV_TR_SERV_REC.AGT_CERT_NO   := LV_IN(7);
        LV_TR_SERV_REC.AGT_CERT_TYPE := LV_IN(6);
        LV_TR_SERV_REC.AGT_TEL_NO    := LV_IN(9);
        LV_TR_SERV_REC.CLR_DATE      := LV_PAYCLRPARA.CLR_DATE;
        LV_TR_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
        LV_TR_SERV_REC.USER_ID       := LV_USERS.USER_ID;
        LV_TR_SERV_REC.DEAL_STATE    := '0';
        LV_TR_SERV_REC.COST_FEE      := NVL(LV_CARD_APPLY.COST_FEE, 0);
        LV_TR_SERV_REC.URGENT_FEE    := NVL(LV_CARD_APPLY.URGENT_FEE, 0);
        LV_TR_SERV_REC.NUM           := '1';
        LV_TR_SERV_REC.AMT           := -(NVL(LV_CARD_APPLY.COST_FEE, 0) +
                                        NVL(LV_CARD_APPLY.URGENT_FEE, 0));
        LV_TR_SERV_REC.NOTE          := LV_SYS_ACTION_LOG.MESSAGE;
        INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
        SELECT LV_SYS_ACTION_LOG.DEAL_NO INTO AV_OUT FROM DUAL;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_APPLY_CANCEL;
    --��Ƭ����
    --1.�������
    --2.���������
    --3.����Ա
    --4.������ˮ
    --5.����
    --6.�к�
    --7.˳���  �ɿ�
    --8.�Ƿ�ת���
    --9.��ע
    PROCEDURE P_CARD_RECOVERY(AV_IN VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2, AV_OUT OUT VARCHAR2) IS
        LV_IN                   PK_PUBLIC.MYARRAY;
        LV_USERS                SYS_USERS%ROWTYPE;
        LV_BASE_CO_ORG          BASE_CO_ORG%ROWTYPE;
        LV_CARD_APPLY           CARD_APPLY%ROWTYPE;
        LV_SYS_ACTION_LOG       SYS_ACTION_LOG%ROWTYPE;
        LV_TR_SERV_REC          TR_SERV_REC%ROWTYPE;
        LV_BASE_PERSONAL        BASE_PERSONAL%ROWTYPE;
        LV_PAYCLRPARA           PAY_CLR_PARA%ROWTYPE;
        LV_CARD_BASEINFO        CARD_BASEINFO%ROWTYPE;
        LV_CARD_RECOVER_REGINFO CARD_RECOVER_REGINFO%ROWTYPE;
        LV_OPER_STOCK_SQL       VARCHAR2(1000);
    BEGIN
        SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
        PK_PUBLIC.P_GETINPUTPARA(AV_IN, 6, 9, 'pk_card_apply_issuse.p_card_recovery', LV_IN, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_IN(5) IS NULL THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���տ��Ų���Ϊ��';
            RETURN;
        END IF;
        IF LV_IN(6) IS NULL THEN
            -- AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            --AV_MSG := '�кŲ���Ϊ��';
            --RETURN;
            NULL;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GET_CARD_BASEINFO(LV_IN(5), LV_CARD_BASEINFO, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETCARDAPPLYBYCARDNO(LV_CARD_BASEINFO.CARD_NO, LV_CARD_APPLY, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        IF LV_CARD_APPLY.APPLY_STATE NOT IN
           (PK_PUBLIC.KG_CARD_APPLY_YJS, PK_PUBLIC.KG_CARD_APPLY_YFF) THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����״̬����ȷ��ֻ���ѽ��ջ��ѷ��ŵĿ����ܽ��л���';
            RETURN;
        END IF;
        IF LV_CARD_BASEINFO.CUSTOMER_ID <> LV_CARD_APPLY.CUSTOMER_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����Ϊ' || LV_CARD_BASEINFO.CARD_NO || '�ĳֿ�����Ϣ��������Ϣ��һ��';
            RETURN;
        END IF;
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYS_ACTION_LOG.DEAL_NO FROM DUAL;
        LV_SYS_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
        LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
        LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
        LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
        LV_SYS_ACTION_LOG.LOG_TYPE    := '1';
        LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
        LV_SYS_ACTION_LOG.CAN_ROLL    := '0';
        LV_SYS_ACTION_LOG.ROLL_FLAG   := '0';
        LV_SYS_ACTION_LOG.MESSAGE     := '��Ƭ����,����:' || LV_CARD_BASEINFO.CARD_NO || LV_IN(9);
        LV_SYS_ACTION_LOG.DEAL_CODE   := '2040100';
        LV_SYS_ACTION_LOG.NOTE        := LV_SYS_ACTION_LOG.MESSAGE;
        INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
        INSERT INTO CARD_RECOVER_REGINFO
            (ID,
             CARD_NO,
             CERT_NO,
             NAME,
             APP_WAY,
             APP_TYPE,
             APP_DATE,
             APP_ADDR,
             STATUS,
             IS_DEAD,
             ORDER_NO,
             BOX_NO,
             BRCH_ID,
             USER_ID,
             REC_TIME,
             DEAL_NO,
             FF_BRCH_ID,
             FF_USER_ID,
             FF_DATE,
             FF_DEAL_NO,
             INITIAL_STATUS)
        VALUES
            (SEQ_CARD_RECOVER_REGINFO_ID.NEXTVAL,
             LV_CARD_BASEINFO.CARD_NO,
             LV_BASE_PERSONAL.CERT_NO,
             LV_BASE_PERSONAL.NAME,
             LV_CARD_APPLY.APPLY_WAY,
             LV_CARD_APPLY.APPLY_TYPE,
             LV_CARD_APPLY.APPLY_DATE,
             LV_BASE_PERSONAL.LETTER_ADDR,
             '0',
             '1',
             NVL(LV_IN(7), ''),
             LV_IN(6),
             LV_USERS.BRCH_ID,
             LV_USERS.USER_ID,
             LV_SYS_ACTION_LOG.DEAL_TIME,
             LV_SYS_ACTION_LOG.DEAL_NO,
             NULL,
             NULL,
             NULL,
             NULL,
             LV_CARD_APPLY.APPLY_STATE);
        LV_OPER_STOCK_SQL := LV_IN(1) || '|' || LV_IN(2) || '|' || LV_IN(3) || '|' ||
                             LV_SYS_ACTION_LOG.DEAL_NO || '|' || LV_SYS_ACTION_LOG.DEAL_CODE || '|' ||
                             TO_CHAR(LV_SYS_ACTION_LOG.DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss') || '|' ||
                             LV_CARD_BASEINFO.CARD_NO || '|' || PK_CARD_STOCK.GOODS_STATE_HS || '|' ||
                             LV_SYS_ACTION_LOG.MESSAGE || '|';
        PK_CARD_STOCK.P_HSDJ(LV_OPER_STOCK_SQL, AV_RES, AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
        END IF;
        LV_TR_SERV_REC.Acpt_Type     := lv_in(2);
        LV_TR_SERV_REC.DEAL_NO       := LV_SYS_ACTION_LOG.DEAL_NO;
        LV_TR_SERV_REC.BIZ_TIME      := LV_SYS_ACTION_LOG.DEAL_TIME;
        LV_TR_SERV_REC.BRCH_ID       := LV_SYS_ACTION_LOG.BRCH_ID;
        LV_TR_SERV_REC.USER_ID       := LV_SYS_ACTION_LOG.USER_ID;
        LV_TR_SERV_REC.CLR_DATE      := LV_PAYCLRPARA.CLR_DATE;
        LV_TR_SERV_REC.DEAL_STATE    := '0';
        LV_TR_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
        LV_TR_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
        LV_TR_SERV_REC.CARD_TYPE     := LV_CARD_BASEINFO.CARD_TYPE;
        LV_TR_SERV_REC.CARD_AMT      := 1;
        LV_TR_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
        LV_TR_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
        LV_TR_SERV_REC.NUM           := 1;
        LV_TR_SERV_REC.AMT           := 0;
        LV_TR_SERV_REC.DEAL_CODE     := LV_SYS_ACTION_LOG.DEAL_CODE;
        LV_TR_SERV_REC.NOTE          := LV_SYS_ACTION_LOG.MESSAGE;
        INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
        AV_OUT := LV_TR_SERV_REC.DEAL_NO;
        AV_RES := PK_PUBLIC.CS_RES_OK;
        AV_MSG := '';
    EXCEPTION
        WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := SQLERRM;
    END P_CARD_RECOVERY;
END PK_CARD_APPLY_ISSUSE;
/

