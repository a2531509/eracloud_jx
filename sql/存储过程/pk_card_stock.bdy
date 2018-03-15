CREATE OR REPLACE PACKAGE BODY PK_CARD_STOCK AS
  --��Ա����˻�����
  --����˵����
  --1�������/������ ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� ����
  --4�ն˲�����ˮ ѡ��
  --5��������Ա�������� ����
  --6��������Ա��� ����
  --7����������� ѡ�� ��ֵʱ,���еĿ�����Ͷ����ֱ��˻�
  --8�����������״̬ ѡ�� ��ֵʱ,һ��������͵�����״̬�����˻�
  --9��ע
  PROCEDURE P_STOCKACC_OPEN(AV_IN  IN VARCHAR2,
                            AV_RES OUT VARCHAR2,
                            AV_MSG OUT VARCHAR2) IS
    LV_IN                PK_PUBLIC.MYARRAY;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG       BASE_CO_ORG%ROWTYPE;
    LV_OPENACC_USER      SYS_USERS%ROWTYPE;
    LV_STOCK_TYPE        STOCK_TYPE%ROWTYPE;
    LV_STOCK_TYPE_STRING VARCHAR2(200) := 'select * from stock_type where stk_code_state = ''0'' ';
    LV_SYS_CODE          SYS_CODE%ROWTYPE;
    LV_SYS_CODE_STRING   VARCHAR2(200) := 'select * from sys_code where code_state = ''0'' and code_type = ''GOODS_STATE'' ';
    LV_SYS_USER_STRING   VARCHAR2(200) := 'select * from sys_users where 1 = 1 ';
    TYPE MYRECORDTYPE IS TABLE OF SYS_USERS%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE MYSTOCK_TYPE IS TABLE OF STOCK_TYPE%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE GOODS_TYPES IS TABLE OF SYS_CODE%ROWTYPE INDEX BY BINARY_INTEGER;
    LV_ALL_SYS_USERS   MYRECORDTYPE;
    LV_ALL_STOCK_TYPES MYSTOCK_TYPE;
    LV_GOODS_STATES    GOODS_TYPES;
  BEGIN
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             4,
                             9,
                             'pk_card_Stock.p_stockacc_open',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���Ϊ�գ�';
      RETURN;
    END IF;
    IF LV_IN(1) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ų���Ϊ�գ�';
      RETURN;
    END IF;
    IF LV_IN(3) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '����Ա�����ն˱�Ų���Ϊ�գ�';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '����˻�������Ա�������㲻��Ϊ�գ�';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      --av_res := pk_public.cs_res_paravalueerr;
      --av_msg := '����˻�������Ա��Ų���Ϊ�գ�';
      --return;
      NULL;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),
                                      LV_IN(2),
                                      LV_IN(3),
                                      LV_USERS,
                                      LV_BASE_CO_ORG,
                                      AV_RES,
                                      AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NOT NULL THEN
      LV_SYS_USER_STRING := LV_SYS_USER_STRING || 'and brch_id = ''' ||
                            LV_IN(5) || ''' ';
    END IF;
    IF LV_IN(6) IS NOT NULL THEN
      LV_SYS_USER_STRING := LV_SYS_USER_STRING || 'and user_id = ''' ||
                            LV_IN(6) || '''';
    END IF;
    EXECUTE IMMEDIATE LV_SYS_USER_STRING BULK COLLECT
      INTO LV_ALL_SYS_USERS;
    IF LV_ALL_SYS_USERS.COUNT = 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := 'δ�ҵ���Ҫ�����Ĺ�Ա��Ϣ';
      RETURN;
    END IF;
    IF LV_IN(7) IS NOT NULL THEN
      LV_STOCK_TYPE_STRING := LV_STOCK_TYPE_STRING || ' and stk_code = ''' ||
                              LV_IN(7) || '''';
    END IF;
    EXECUTE IMMEDIATE LV_STOCK_TYPE_STRING BULK COLLECT
      INTO LV_ALL_STOCK_TYPES;
    IF LV_ALL_STOCK_TYPES.COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := 'δ�ҵ���Ҫ�����Ŀ������';
      RETURN;
    END IF;
    IF LV_IN(8) IS NOT NULL THEN
      LV_SYS_CODE_STRING := LV_SYS_CODE_STRING || ' and code_value = ''' ||
                            LV_IN(8) || '''';
    END IF;
    EXECUTE IMMEDIATE LV_SYS_CODE_STRING BULK COLLECT
      INTO LV_GOODS_STATES;
    IF LV_GOODS_STATES.COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := 'δ�ҵ�����˻�״̬������Ϣ';
      RETURN;
    END IF;
    FOR TEMP_USER_INDEX IN LV_ALL_SYS_USERS.FIRST .. LV_ALL_SYS_USERS.LAST LOOP
      LV_OPENACC_USER := LV_ALL_SYS_USERS(TEMP_USER_INDEX);
      FOR TEMP_STOCK_TYPE_INDEX IN LV_ALL_STOCK_TYPES.FIRST .. LV_ALL_STOCK_TYPES.LAST LOOP
        LV_STOCK_TYPE := LV_ALL_STOCK_TYPES(TEMP_STOCK_TYPE_INDEX);
        FOR TEMP_STATE_INDEX IN LV_GOODS_STATES.FIRST .. LV_GOODS_STATES.LAST LOOP
          LV_SYS_CODE := LV_GOODS_STATES(TEMP_STATE_INDEX);
          MERGE INTO STOCK_ACC A
          USING (SELECT LV_OPENACC_USER.BRCH_ID BRCH_ID,
                        LV_OPENACC_USER.USER_ID USER_ID,
                        LV_STOCK_TYPE.STK_CODE  STK_CODE,
                        LV_SYS_CODE.CODE_VALUE  CODE_VALUE
                   FROM DUAL) B
          ON (A.BRCH_ID = B.BRCH_ID AND A.USER_ID = B.USER_ID AND A.STK_CODE = B.STK_CODE AND A.GOODS_STATE = B.CODE_VALUE)
          WHEN MATCHED THEN
            UPDATE
               SET A.ACC_STATE   = '0',
                   A.CLS_DATE    = '',
                   A.CLS_USER_ID = '',
                   A.ACC_NAME    = LV_OPENACC_USER.USER_ID || '_' ||
                                   LV_STOCK_TYPE.STK_NAME || '_' ||
                                   LV_SYS_CODE.CODE_NAME
          WHEN NOT MATCHED THEN
            INSERT
            VALUES
              (LV_OPENACC_USER.ORG_ID,
               LV_OPENACC_USER.BRCH_ID,
               LV_OPENACC_USER.USER_ID,
               LV_OPENACC_USER.NAME || '_' || LV_STOCK_TYPE.STK_NAME || '_' ||
               LV_SYS_CODE.CODE_NAME,
               LV_STOCK_TYPE.STK_CODE,
               LV_SYS_CODE.CODE_VALUE,
               0,
               0,
               SYSDATE,
               LV_USERS.USER_ID,
               NULL,
               NULL,
               NULL,
               '0',
               LV_IN(9));
        END LOOP;
      END LOOP;
    END LOOP;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_STOCKACC_OPEN;
  --�����Ʒ����
  --����˵����
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7������� stk_code ����
  --8������out_brch_id ����
  --9����Աout_user_id ����
  --10����Ʒ״̬out_goods_state  ����
  --11������in_brch_id ����
  --12�չ�Աin_user_id ����
  --13����Ʒ״̬in_goods_state  ����
  --14��潻����ʽ deliveryWay = 1ʱ��������deliveryWay = 2ʱ���տ��Ŷ� ��Ϊ"1"ʱ 15���� ��Ϊ"2"ʱ 16��17����
  --15������ taskIds
  --16��ʼ��Ʒ���� begin_googds_no
  --17������Ʒ���� end_goods_no
  --18��Ʒ���������� ����
  --19note��ע
  PROCEDURE P_STOCK_DELIVERY(AV_IN  VARCHAR2,
                             AV_RES OUT VARCHAR2,
                             AV_MSG OUT VARCHAR2) IS
    LV_IN                        PK_PUBLIC.MYARRAY;
    LV_STOCK_ACC_OUT             STOCK_ACC%ROWTYPE;
    LV_STOCK_ACC_IN              STOCK_ACC%ROWTYPE;
    LV_BASE_CO_ORG               BASE_CO_ORG%ROWTYPE;
    LV_CLR_DATE                  PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_TASK_IDS                  PK_PUBLIC.MYARRAY;
    LV_USERS                     SYS_USERS%ROWTYPE;
    LV_SYS_USERS_OUT             SYS_USERS%ROWTYPE;
    LV_SYS_USERS_IN              SYS_USERS%ROWTYPE;
    LV_LIMIT_SQL                 VARCHAR2(2000);
    LV_COUNT                     NUMBER := 0;
    LV_BRCH_ID                   CARD_APPLY_TASK.BRCH_ID%TYPE;
    LV_CARD_APPLY_TASK_TASKSTATE CARD_APPLY_TASK.TASK_STATE%TYPE;
    LV_CARD_APPLY_TASK           CARD_APPLY_TASK%ROWTYPE;
    LV_STK_CODE                  STOCK_ACC.STK_CODE%TYPE;
    LV_STK_SER_NO                STOCK_REC.STK_SER_NO%TYPE;
  BEGIN
    --1.���������ж�
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             16,
                             19,
                             'PK_CARD_STOCK.P_STOCK_DELIVERY',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    --2.����Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '����Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.������Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(8),
                                     LV_IN(9),
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --4.�շ���Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(11),
                                     LV_IN(12),
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '�շ���Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�շ���Ա״̬������';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ա���շ���Ա������ͬһ����Ա';
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.ORG_ID <> LV_SYS_USERS_OUT.ORG_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������ͱ�����ͬһ������Ա֮���������';
      RETURN;
    END IF;
    --5.���ݿ�潻�����ͣ��жϱ������
    IF LV_IN(14) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������ͷ�ʽ����Ϊ�գ�';
      RETURN;
    ELSIF LV_IN(14) = '1' THEN
      IF LV_IN(15) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '������ͷ�ʽ��ѡ��������ʽ�������Ų���Ϊ��';
        RETURN;
      ELSE
        LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(15), ',', LV_TASK_IDS);
        IF LV_COUNT <= 0 THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '������ͷ�ʽ��ѡ��������ʽ�������Ų���Ϊ��';
          RETURN;
        END IF;
      END IF;
    ELSIF LV_IN(14) = '2' THEN
      IF LV_IN(16) IS NULL OR LV_IN(17) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '������ͷ�ʽ��ѡ���տ��Σ���ֹ���Ų���Ϊ��';
        RETURN;
      ELSE
        LV_LIMIT_SQL := ' GOODS_NO BETWEEN ' || LV_IN(16) || ' AND ' ||
                        LV_IN(17) || ' ';
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := 'ѡ��Ŀ�����ͷ�ʽ����ȷ';
      RETURN;
    END IF;
    --6.ѭ������ÿһ����������
    IF LV_IN(14) = '1' THEN
      FOR LV_ROW_INDEX IN LV_TASK_IDS.FIRST .. LV_TASK_IDS.LAST LOOP
        BEGIN
          SELECT *
            INTO LV_CARD_APPLY_TASK
            FROM CARD_APPLY_TASK
           WHERE TASK_ID = LV_TASK_IDS(LV_ROW_INDEX);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����������' || LV_TASK_IDS(LV_ROW_INDEX) || '�Ҳ���������Ϣ';
            RETURN;
          WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����������' || LV_TASK_IDS(LV_ROW_INDEX) ||
                      '��ȡ������Ϣ����������Ϣ' || SQLERRM;
            RETURN;
        END;
        IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YZK THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ��������š�' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '����Ϊ�����ƿ���״̬,������ͱ����ǡ����ƿ���״̬������';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.CARD_TYPE = PK_PUBLIC.CARD_TYPE_SMZK THEN
          IF LV_CARD_APPLY_TASK.BRCH_ID <> LV_SYS_USERS_IN.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�����š�' || LV_TASK_IDS(LV_ROW_INDEX) ||
                      '����������������ͽ������㲻��ͬһ���㣬���͵���������ܵ����޷����з���';
            RETURN;
          END IF;
        END IF;
        LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE; --ע�⣺�˴�������͵����ɹ���
        SELECT COUNT(1)
          INTO LV_COUNT
          FROM STOCK_LIST
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID
           AND ORG_ID = LV_SYS_USERS_OUT.ORG_ID
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND OWN_TYPE = '0'
           AND STK_IS_SURE = '0'
           AND GOODS_STATE = LV_IN(10)
           AND STK_CODE = LV_STK_CODE;
        IF LV_COUNT <> LV_CARD_APPLY_TASK.TASK_SUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ��������š�' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '���Ŀ����ϸ����������������һ��,������ϸ���ڵ�ǰ��Ա����';
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETSTOCK_ACC(LV_IN(8),
                                     LV_IN(9),
                                     LV_STK_CODE,
                                     LV_IN(10),
                                     LV_STOCK_ACC_OUT,
                                     AV_RES,
                                     AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          AV_MSG := '��ȡ��������˻���������,' || AV_MSG;
          RETURN;
        END IF;
        IF LV_STOCK_ACC_OUT.TOT_NUM < LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '��������˻�����';
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETSTOCK_ACC(LV_IN(11),
                                     LV_IN(12),
                                     LV_STK_CODE,
                                     LV_IN(13),
                                     LV_STOCK_ACC_IN,
                                     AV_RES,
                                     AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          AV_MSG := '��ȡ�շ�����˻���������,' || AV_MSG;
          RETURN;
        END IF;
        SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STK_SER_NO FROM DUAL;
        EXECUTE IMMEDIATE 'INSERT INTO STOCK_REC(STK_SER_NO,DEAL_CODE,STK_CODE,BATCH_ID,TASK_ID,IN_ORG_ID,
IN_BRCH_ID,IN_USER_ID,IN_GOODS_STATE,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,
OUT_GOODS_STATE,GOODS_ID,GOODS_NO,GOODS_NUMS,IN_OUT_FLAG,TR_DATE,ORG_ID,
BRCH_ID,USER_ID,AUTH_OPER_ID,BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,IS_SURE,START_NO,END_NO
)(SELECT ' || LV_STK_SER_NO ||
                          ',:1,:2,MAX(BATCH_ID),TASK_ID,''' ||
                          LV_SYS_USERS_IN.ORG_ID || ''',''' ||
                          LV_SYS_USERS_IN.BRCH_ID || ''',''' ||
                          LV_SYS_USERS_IN.USER_ID || ''',:3,''' ||
                          LV_SYS_USERS_OUT.ORG_ID || ''',''' ||
                          LV_SYS_USERS_OUT.BRCH_ID || ''',''' ||
                          LV_SYS_USERS_OUT.USER_ID ||
                          ''',:4,NULL,NULL,
COUNT(1),''3'',to_date(''' || LV_IN(6) ||
                          ''',''yyyy-mm-dd hh24:mi:ss''),''' ||
                          LV_USERS.ORG_ID || ''',''' || LV_USERS.BRCH_ID ||
                          ''',''' || LV_USERS.USER_ID || ''',NULL,''0'',''' ||
                          LV_CLR_DATE || ''',:5,:6,''1'',
MIN(GOODS_NO),MAX(GOODS_NO)
FROM STOCK_LIST WHERE TASK_ID = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID ||
                          ''' and BRCH_ID = ''' || LV_SYS_USERS_OUT.BRCH_ID ||
                          ''' AND USER_ID = ''' || LV_SYS_USERS_OUT.USER_ID ||
                          ''' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''' ||
                          LV_IN(10) ||
                          ''' AND STK_IS_SURE = ''0'' AND STK_CODE = ''' ||
                          LV_STK_CODE || ''' GROUP BY TASK_ID ' || ')'
          USING LV_IN(5), LV_STK_CODE, LV_IN(13), LV_IN(10), LV_IN(4), LV_IN(19);
        EXECUTE IMMEDIATE 'INSERT INTO STOCK_INOUT_DETAIL (STK_INOUT_NO,STK_TYPE,STK_CODE,IN_GOODS_STATE,OUT_GOODS_STATE,ORG_ID,
BRCH_ID,USER_ID,AUTH_USER_ID,DEAL_CODE,DEAL_DATE,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,BATCH_ID,TASK_ID,GOODS_NO,
GOODS_ID,TOT_NUM,TOT_AMT,IN_OUT_FLAG,BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,REV_DATE
)' ||
                          '(SELECT SEQ_STK_INOUT_NO.NEXTVAL,''1'',STK_CODE,GOODS_STATE,GOODS_STATE,:1,:2,:3,NULL,' ||
                          ':4,:5,:6,:7,:8,:9,:10,:11,BATCH_ID,TASK_ID,GOODS_NO,GOODS_ID,:9,' ||
                          '''0'',''2'',''0'',:10,:11,:12,NULL ' ||
                          'FROM STOCK_LIST WHERE STK_IS_SURE = ''0'' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''0'' AND ' ||
                          'ORG_ID = ''' || LV_USERS.ORG_ID ||
                          ''' AND BRCH_ID = ''' || LV_USERS.BRCH_ID ||
                          ''' AND USER_ID = ''' || LV_USERS.USER_ID ||
                          ''' AND STK_CODE = ' || LV_STK_CODE ||
                          ' and TASK_ID = ''' || LV_CARD_APPLY_TASK.TASK_ID || '''' || ')'
          USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_IN(5), TO_DATE(LV_IN(6), 'YYYY-MM-DD HH24:MI:SS'), LV_SYS_USERS_IN.ORG_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_SYS_USERS_OUT.ORG_ID, LV_SYS_USERS_OUT.BRCH_ID, LV_SYS_USERS_OUT.USER_ID, '1', LV_CLR_DATE, LV_IN(4), LV_IN(19);
        IF SQL%ROWCOUNT < LV_CARD_APPLY_TASK.YH_NUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '��¼���������ˮ��Ϣ���ִ��󣬳�������С���ƿ���ϸ������һ��';
          RETURN;
        END IF;
        IF SQL%ROWCOUNT <> LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '��¼��������ˮ��Ϣ���ִ������¼' || LV_COUNT || '����ʵ�ʼ�¼' ||
                    SQL%ROWCOUNT || '��';
          RETURN;
        END IF;
        --�����������Ʒ��ϸ����Ϊ�շ���
        EXECUTE IMMEDIATE 'UPDATE STOCK_LIST SET STK_IS_SURE = ''1'',BRCH_ID = ''' ||
                          LV_SYS_USERS_IN.BRCH_ID || ''',OUT_DEAL_NO = ''' ||
                          LV_IN(4) || '''' || ',USER_ID = ''' ||
                          LV_SYS_USERS_IN.USER_ID || ''',ORG_ID = ''' ||
                          LV_SYS_USERS_IN.ORG_ID || ''',OUT_DATE = ' ||
                          'TO_DATE(''' || LV_IN(6) ||
                          ''',''YYYY-MM-DD HH24:MI:SS''),OUT_BRCH_ID = ''' ||
                          LV_SYS_USERS_OUT.BRCH_ID || ''',OUT_USER_ID = ''' ||
                          LV_SYS_USERS_OUT.USER_ID || ''' ' ||
                          'WHERE TASK_ID = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID ||
                          ''' and ORG_ID = ''' || LV_SYS_USERS_OUT.ORG_ID ||
                          ''' AND BRCH_ID = ''' || LV_SYS_USERS_OUT.BRCH_ID ||
                          ''' AND USER_ID = ''' || LV_SYS_USERS_OUT.USER_ID ||
                          ''' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''' ||
                          LV_IN(10) ||
                          ''' AND STK_IS_SURE = ''0'' AND STK_CODE = ''' ||
                          LV_STK_CODE || '''';
        IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.TASK_SUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ��������' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '���������ϸ��Ʒ����������������һ�£��޷���������';
          RETURN;
        END IF;
        --12���������¼������״̬��������
        EXECUTE IMMEDIATE 'UPDATE CARD_APPLY_TASK SET TASK_STATE = ''30'' WHERE TASK_ID = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID || '''';
        EXECUTE IMMEDIATE 'UPDATE CARD_APPLY SET APPLY_STATE = ''40'' WHERE TASK_ID = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID || '''';
        --13.���¸�������˻�
        UPDATE STOCK_ACC
           SET TOT_NUM        = NVL(TOT_NUM, 0) -
                                LV_CARD_APPLY_TASK.TASK_SUM,
               LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'YYYY-MM-DD HH24:MI:SS')
         WHERE GOODS_STATE = LV_IN(10)
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND STK_CODE = LV_STK_CODE;
        --14.�����շ�����˻�
        UPDATE STOCK_ACC
           SET TOT_NUM        = NVL(TOT_NUM, 0) +
                                LV_CARD_APPLY_TASK.TASK_SUM,
               LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'YYYY-MM-DD HH24:MI:SS')
         WHERE GOODS_STATE = LV_IN(13)
           AND USER_ID = LV_SYS_USERS_IN.USER_ID
           AND BRCH_ID = LV_SYS_USERS_IN.BRCH_ID
           AND STK_CODE = LV_STK_CODE;
        IF SQL%ROWCOUNT <> '1' THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�����շ�����˻�ʧ��,�շ�����˻�������';
          RETURN;
        END IF;
      END LOOP;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��������ݲ�֧�ְ��տ��η�ʽ��������';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_STOCK_DELIVERY;
  --�������ȷ��
  --���������
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ѡ��
  --5������dealnos��ȷ����ˮ�Ŷ����ˮ�Ŷ��Ÿ����� 1,2,3,4,5,6 ����
  --���ز�����
  --av_res ����������
  --av_msg ������˵��
  --av_out �ɹ���������ĸ���
  PROCEDURE P_STOCK_DELIVERY_CONFIRM(AV_IN  VARCHAR2,
                                     AV_RES OUT VARCHAR2,
                                     AV_MSG OUT VARCHAR2,
                                     AV_OUT OUT NUMBER) IS
    LV_IN                PK_PUBLIC.MYARRAY; --�����������
    LV_STOCK_REC_DEALNOS PK_PUBLIC.MYARRAY;
    LV_CLR_DATE          PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_COUNT             NUMBER;
    LV_STOCK_REC         STOCK_REC%ROWTYPE;
    LV_CARD_APPLY_TASK   CARD_APPLY_TASK%ROWTYPE;
    LV_TR_SERV_REC       TR_SERV_REC%ROWTYPE;
    LV_SYS_ACTION_LOG    SYS_ACTION_LOG%ROWTYPE;
  BEGIN
    --1.���������ж�
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             4,
                             5,
                             'PK_CARD_STOCK.P_STOCK_DELIVERY_CONFIRM',
                             LV_IN, --ת���ɲ�������
                             AV_RES, --������������
                             AV_MSG --��������������Ϣ
                             );
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��ȷ�Ͽ��������ˮ����Ϊ��';
      RETURN;
    END IF;
    --2.ȷ�ϲ���Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(5), ',', LV_STOCK_REC_DEALNOS);
    IF LV_COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ȷ�Ͽ��������ˮ����Ϊ��';
      RETURN;
    END IF;
    --3.��ʼ��������־,ҵ����־��Ϣ
    LV_SYS_ACTION_LOG.DEAL_CODE   := '10502020'; --����ȷ�Ͻ�����
    LV_SYS_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
    LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
    LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
    LV_SYS_ACTION_LOG.LOG_TYPE    := '0';
    LV_TR_SERV_REC.DEAL_CODE      := LV_SYS_ACTION_LOG.DEAL_CODE; --����ȷ�Ͻ�����
    LV_TR_SERV_REC.ORG_ID         := LV_SYS_ACTION_LOG.ORG_ID;
    LV_TR_SERV_REC.BRCH_ID        := LV_SYS_ACTION_LOG.BRCH_ID;
    LV_TR_SERV_REC.USER_ID        := LV_SYS_ACTION_LOG.USER_ID;
    LV_TR_SERV_REC.BIZ_TIME       := LV_SYS_ACTION_LOG.DEAL_TIME;
    LV_TR_SERV_REC.DEAL_STATE     := '0';
    LV_TR_SERV_REC.CLR_DATE       := LV_CLR_DATE;
    AV_OUT                        := NVL(AV_OUT, 0);
    --4.ѭ�����п��������ˮȷ��
    FOR LV_ROW_INDEX IN LV_STOCK_REC_DEALNOS.FIRST .. LV_STOCK_REC_DEALNOS.LAST LOOP
      LV_COUNT := 0;
      BEGIN
        SELECT *
          INTO LV_STOCK_REC
          FROM STOCK_REC
         WHERE STK_SER_NO = LV_STOCK_REC_DEALNOS(LV_ROW_INDEX)
           AND IS_SURE = '1'
           AND IN_BRCH_ID = LV_USERS.BRCH_ID
           AND IN_USER_ID = LV_USERS.USER_ID
           AND IN_BRCH_ID = LV_USERS.BRCH_ID
           AND IN_USER_ID = LV_USERS.USER_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '��ǰ��Ա���¸��ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    'δ�ҵ�����ȷ�ϡ�״̬�Ŀ��������Ϣ';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '��ȡ���ͼ�¼���ִ���' || SQLERRM;
          RETURN;
      END;
      IF LV_STOCK_REC.IS_SURE <> '1' THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '���ǡ�δȷ�ϡ�״̬�����ܽ��п������ȷ��';
        RETURN;
      END IF;
      SELECT SUM(GOODS_NUMS)
        INTO LV_COUNT
        FROM STOCK_REC
       WHERE STK_SER_NO = LV_STOCK_REC_DEALNOS(LV_ROW_INDEX);
      IF LV_STOCK_REC.TASK_ID IS NOT NULL THEN
        BEGIN
          SELECT *
            INTO LV_CARD_APPLY_TASK
            FROM CARD_APPLY_TASK
           WHERE TASK_ID = LV_STOCK_REC.TASK_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                      'δ�ҵ���Ӧ����������Ϣ';
            RETURN;
          WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                      '��ȡ��Ӧ����������Ϣ��������' || SQLERRM;
            RETURN;
        END;
        IF LV_CARD_APPLY_TASK.TASK_SUM <> LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '��Ӧ����Ʒ����������������һ��';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YPS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '��Ӧ�������ǡ������͡�״̬�����ܽ���ȷ��';
          RETURN;
        END IF;
        SELECT SEQ_ACTION_NO.NEXTVAL
          INTO LV_SYS_ACTION_LOG.DEAL_NO
          FROM DUAL;
        LV_SYS_ACTION_LOG.MESSAGE := '�������ȷ��,�����ˮ' ||
                                     LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                                     ',������' || LV_CARD_APPLY_TASK.TASK_ID;
        INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
        LV_TR_SERV_REC.CARD_TYPE := SUBSTR(LV_STOCK_REC.STK_CODE, 2);
        LV_TR_SERV_REC.CARD_AMT  := LV_STOCK_REC.GOODS_NUMS;
        LV_TR_SERV_REC.NUM       := LV_STOCK_REC.GOODS_NUMS;
        LV_TR_SERV_REC.DEAL_NO   := LV_SYS_ACTION_LOG.DEAL_NO;
        LV_TR_SERV_REC.NOTE      := LV_SYS_ACTION_LOG.MESSAGE;
        --���¿��������ˮ����ȷ��״̬
        UPDATE STOCK_REC
           SET IS_SURE = '0'
         WHERE STK_SER_NO = LV_STOCK_REC_DEALNOS(LV_ROW_INDEX)
           AND IN_BRCH_ID = LV_USERS.BRCH_ID
           AND IN_USER_ID = LV_USERS.USER_ID;
        --��������״̬����ȷ��״̬
        UPDATE CARD_APPLY_TASK
           SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_YJS
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
        --��������״̬����ȷ��״̬
        UPDATE CARD_APPLY
           SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
        --���¿����Ʒȷ��״̬
        UPDATE STOCK_LIST
           SET STK_IS_SURE = '0'
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID
           AND OWN_TYPE = '0'
           AND BRCH_ID = LV_USERS.BRCH_ID
           AND USER_ID = LV_USERS.USER_ID
           AND STK_CODE = LV_STOCK_REC.STK_CODE
           AND GOODS_STATE = LV_STOCK_REC.IN_GOODS_STATE
           AND STK_IS_SURE = '1';
        IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.TASK_SUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '��Ӧ�Ŀ����ϸ����������������һ��';
          RETURN;
        END IF;
        AV_OUT := NVL(AV_OUT, 0) + 1; --�ɹ�����
        INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
        COMMIT;
      ELSE
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  'δ�ҵ���Ӧ����������Ϣ';
        RETURN;
      END IF;
    END LOOP;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := SQLERRM;
      RETURN;
  END P_STOCK_DELIVERY_CONFIRM;
  --�������ȡ�� ���͡�����ȷ�ϡ�����ȡ�����밴������ʽ����
  --���������
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ѡ��
  --5�����ˮdealnos��ȷ����ˮ�Ŷ����ˮ�Ŷ��Ÿ����� 1,2,3,4,5,6 ����
  --6������deal_code
  --7����ʱ�� deal_time
  --8��ע note
  --���ز�����
  --av_res ����������
  --av_msg ������˵��
  --av_out�ɹ���������ĸ���
  PROCEDURE P_STOCK_DELIVERY_CANCEL(AV_IN  VARCHAR2,
                                    AV_RES OUT VARCHAR2,
                                    AV_MSG OUT VARCHAR2,
                                    AV_OUT OUT NUMBER) IS
    LV_IN                PK_PUBLIC.MYARRAY;
    LV_STOCK_REC_DEALNOS PK_PUBLIC.MYARRAY;
    LV_STOCK_REC         STOCK_REC%ROWTYPE;
    LV_CARD_APPLY_TASK   CARD_APPLY_TASK%ROWTYPE;
    LV_STOCK_ACC_OUT     STOCK_ACC%ROWTYPE;
    LV_STOCK_ACC_IN      STOCK_ACC%ROWTYPE;
    LV_CLR_DATE          PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_SYS_USERS_OUT     SYS_USERS%ROWTYPE;
    LV_SYS_USERS_IN      SYS_USERS%ROWTYPE;
    LV_COUNT             NUMBER := 0;
  BEGIN
    --1.���������ж�
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN, --�������
                             8, --�������ٸ���
                             8, --����������
                             'PK_CARD_STOCK.P_STOCK_DELIVERY_CANCEL', --���õĺ�����
                             LV_IN, --ת���ɲ�������
                             AV_RES, --������������
                             AV_MSG --��������������Ϣ
                             );
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��ȡ�����������ˮ����Ϊ��';
      RETURN;
    END IF;
    --2.��ȡ����Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '����Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.�ֲ�����ˮ
    LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(5), ',', LV_STOCK_REC_DEALNOS);
    IF LV_COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ȡ�����������ˮ����Ϊ��';
      RETURN;
    END IF;
    FOR LV_ROW_INDEX IN LV_STOCK_REC_DEALNOS.FIRST .. LV_STOCK_REC_DEALNOS.LAST LOOP
      BEGIN
        SELECT *
          INTO LV_STOCK_REC
          FROM STOCK_REC
         WHERE STK_SER_NO = LV_STOCK_REC_DEALNOS(LV_ROW_INDEX)
           AND OUT_BRCH_ID = LV_USERS.BRCH_ID
           AND OUT_USER_ID = LV_USERS.USER_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '��ǰ��Ա���¸��ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    'δ�ҵ�����ȷ�ϡ�״̬�Ŀ��������Ϣ';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '��ȡ���ͼ�¼���ִ���' || SQLERRM;
          RETURN;
      END;
      IF LV_STOCK_REC.IS_SURE <> '1' THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '���ǡ�δȷ�ϡ�״̬,�޷���������ȡ��';
        RETURN;
      END IF;
      --ԭʼ��ˮ���뷽��Ա�����ڵĳ�����Ա
      PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_REC.IN_BRCH_ID,
                                       LV_STOCK_REC.IN_USER_ID,
                                       LV_SYS_USERS_OUT,
                                       AV_RES,
                                       AV_MSG,
                                       '�����Ա��Ϣ');
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      --ԭʼ��ˮ�ĸ�����Ա�����ڵ��뷽��Ա
      PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_REC.OUT_BRCH_ID,
                                       LV_STOCK_REC.OUT_USER_ID,
                                       LV_SYS_USERS_IN,
                                       AV_RES,
                                       AV_MSG,
                                       '����Ա��Ϣ');
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '�����Ա������Ա������ͬ';
        RETURN;
      END IF;
      PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_REC.IN_BRCH_ID,
                                   LV_STOCK_REC.IN_USER_ID,
                                   LV_STOCK_REC.STK_CODE,
                                   LV_STOCK_REC.IN_GOODS_STATE,
                                   LV_STOCK_ACC_OUT,
                                   AV_RES,
                                   AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG := '��ȡ��������˻���������,' || AV_MSG;
        RETURN;
      END IF;
      PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_REC.OUT_BRCH_ID,
                                   LV_STOCK_REC.OUT_USER_ID,
                                   LV_STOCK_REC.STK_CODE,
                                   LV_STOCK_REC.OUT_GOODS_STATE,
                                   LV_STOCK_ACC_IN,
                                   AV_RES,
                                   AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG := '��ȡ�շ�����˻���������,' || AV_MSG;
        RETURN;
      END IF;
      IF LV_STOCK_REC.TASK_ID IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '��Ӧ��������Ϊ�գ��޷����п������ȡ��';
        RETURN;
      END IF;
      BEGIN
        SELECT *
          INTO LV_CARD_APPLY_TASK
          FROM CARD_APPLY_TASK
         WHERE TASK_ID = LV_STOCK_REC.TASK_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    'δ�ҵ�������������Ϣ';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿ����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '��ȡ������������Ϣ��������' || SQLERRM;
          RETURN;
      END;
      --WHAT KIND OF TASK STATE CAN BE CANCELED
      IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YPS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�����ˮ' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) || '��Ӧ������' ||
                  LV_CARD_APPLY_TASK.TASK_ID || '���ǡ������͡�״̬�޷���������ȡ��';
        RETURN;
      END IF;
      IF LV_STOCK_ACC_OUT.TOT_NUM < LV_STOCK_REC.GOODS_NUMS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��������˻�����';
        RETURN;
      END IF;
      EXECUTE IMMEDIATE 'INSERT INTO STOCK_INOUT_DETAIL (STK_INOUT_NO,STK_TYPE,STK_CODE,IN_GOODS_STATE,OUT_GOODS_STATE,ORG_ID,
BRCH_ID,USER_ID,AUTH_USER_ID,DEAL_CODE,DEAL_DATE,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,BATCH_ID,TASK_ID,GOODS_NO,
GOODS_ID,TOT_NUM,TOT_AMT,IN_OUT_FLAG,BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,REV_DATE
)' ||
                        '(SELECT SEQ_STK_INOUT_NO.NEXTVAL,''1'',STK_CODE,GOODS_STATE,NULL,:1,:2,:3,NULL,' ||
                        ':4,:5,:6,:7,:8,:9,:10,:11,BATCH_ID,TASK_ID,GOODS_NO,GOODS_ID,:9,' ||
                        '''0'',''1'',''0'',:10,:11,:12,NULL ' ||
                        'FROM STOCK_LIST WHERE STK_IS_SURE = ''1'' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''0'' AND ' ||
                        'ORG_ID = ''' || LV_SYS_USERS_OUT.ORG_ID ||
                        ''' AND BRCH_ID = ''' || LV_SYS_USERS_OUT.BRCH_ID ||
                        ''' AND USER_ID = ''' || LV_SYS_USERS_OUT.USER_ID ||
                        ''' AND STK_CODE = ' || LV_STOCK_REC.STK_CODE ||
                        ' AND TASK_ID = ''' || LV_CARD_APPLY_TASK.TASK_ID || '''' || ')'
        USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_IN(6), TO_DATE(LV_IN(7), 'YYYY-MM-DD HH24:MI:SS'), LV_SYS_USERS_IN.ORG_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_SYS_USERS_OUT.ORG_ID, LV_SYS_USERS_OUT.BRCH_ID, LV_SYS_USERS_OUT.USER_ID, '1', LV_CLR_DATE, LV_IN(4), LV_IN(8);
      IF SQL%ROWCOUNT <> LV_STOCK_REC.GOODS_NUMS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��¼��������������Ϳ�����͵�������һ��';
        RETURN;
      END IF;
      EXECUTE IMMEDIATE 'UPDATE STOCK_LIST SET OUT_DATE = NULL,OUT_BRCH_ID = NULL,OUT_USER_ID = NULL,OUT_DEAL_NO = NULL,' ||
                        'STK_IS_SURE = ''0'',BRCH_ID = ''' ||
                        LV_STOCK_REC.OUT_BRCH_ID || '''' || ',USER_ID = ''' ||
                        LV_STOCK_REC.OUT_USER_ID || '''' || ',ORG_ID = ''' ||
                        LV_STOCK_REC.OUT_ORG_ID || ''' ' ||
                        'WHERE TASK_ID = ''' || LV_STOCK_REC.TASK_ID ||
                        ''' AND BRCH_ID = ''' || LV_STOCK_REC.IN_BRCH_ID ||
                        ''' AND USER_ID = ''' || LV_STOCK_REC.IN_USER_ID ||
                        ''' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''0' ||
                        ''' AND STK_IS_SURE = ''1'' AND STK_CODE = ''' ||
                        LV_STOCK_REC.STK_CODE || '''';
      IF SQL%ROWCOUNT <> LV_STOCK_REC.GOODS_NUMS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '���������ϸ�����Ϳ����ˮ������һ��';
        RETURN;
      END IF;
      UPDATE STOCK_REC
         SET IS_SURE = '2'
       WHERE STK_SER_NO = LV_STOCK_REC_DEALNOS(LV_ROW_INDEX)
         AND OUT_BRCH_ID = LV_USERS.BRCH_ID
         AND OUT_USER_ID = LV_USERS.USER_ID;
      UPDATE CARD_APPLY_TASK
         SET TASK_STATE = '20'
       WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
      UPDATE CARD_APPLY
         SET APPLY_STATE = '30'
       WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
      --�����շ�����˻�
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) + LV_STOCK_REC.GOODS_NUMS,
             LAST_DEAL_DATE = TO_DATE(LV_IN(7), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_STOCK_REC.OUT_GOODS_STATE
         AND USER_ID = LV_STOCK_REC.OUT_USER_ID
         AND BRCH_ID = LV_STOCK_REC.OUT_BRCH_ID
         AND STK_CODE = LV_STOCK_REC.STK_CODE;
      --���¸�������˻�
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) - LV_STOCK_REC.GOODS_NUMS,
             LAST_DEAL_DATE = TO_DATE(LV_IN(7), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_STOCK_REC.IN_GOODS_STATE
         AND USER_ID = LV_STOCK_REC.IN_USER_ID
         AND BRCH_ID = LV_STOCK_REC.IN_BRCH_ID
         AND STK_CODE = LV_STOCK_REC.STK_CODE;
      --��������ˮ
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
         GOODS_ID,
         GOODS_NO,
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
         NOTE,
         IS_SURE,
         START_NO,
         END_NO)
      VALUES
        (SEQ_STK_SER_NO.NEXTVAL,
         LV_IN(6),
         LV_STOCK_REC.STK_CODE,
         LV_CARD_APPLY_TASK.MAKE_BATCH_ID,
         LV_CARD_APPLY_TASK.TASK_ID,
         LV_SYS_USERS_IN.ORG_ID,
         LV_SYS_USERS_IN.BRCH_ID,
         LV_SYS_USERS_IN.USER_ID,
         LV_STOCK_REC.OUT_GOODS_STATE,
         LV_SYS_USERS_OUT.ORG_ID,
         LV_SYS_USERS_OUT.BRCH_ID,
         LV_SYS_USERS_OUT.USER_ID,
         LV_STOCK_REC.IN_GOODS_STATE,
         NULL,
         NULL,
         LV_STOCK_REC.GOODS_NUMS,
         '3',
         TO_DATE(LV_IN(7), 'YYYY-MM-DD HH24:MI:SS'),
         LV_USERS.ORG_ID,
         LV_USERS.BRCH_ID,
         LV_USERS.USER_ID,
         NULL,
         '0',
         LV_CLR_DATE,
         LV_IN(4),
         LV_IN(8),
         '0',
         LV_CARD_APPLY_TASK.START_CARD_NO,
         LV_CARD_APPLY_TASK.END_CARD_NO);
    END LOOP;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_STOCK_DELIVERY_CANCEL;
  --��Ա֮���潻�� ����
  --����˵����
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7������� stk_code ����
  --8�����Ʒ״̬goods_state
  --9������out_brch_id ����
  --10����Աout_user_id ����
  --11������in_brch_id ����
  --12�չ�Աin_user_id ����
  --13��潻����ʽ deliveryWay = 1ʱ��������deliveryWay = 2ʱ���տ��Ŷ� ��Ϊ"1"ʱ 14���� ��Ϊ"2"ʱ 15��16����
  --14������ taskIds
  --15��ʼ��Ʒ���� begin_googds_no
  --16������Ʒ���� end_goods_no
  --17��Ʒ���������� ����
  --18note��ע
  PROCEDURE P_STOCK_EXCHANGE(AV_IN  VARCHAR2,
                             AV_RES OUT VARCHAR2,
                             AV_MSG OUT VARCHAR2) IS
    LV_IN    PK_PUBLIC.MYARRAY;
    LV_USERS SYS_USERS%ROWTYPE;
    TYPE LV_CUS_TYPE IS TABLE OF STOCK_LIST%ROWTYPE INDEX BY BINARY_INTEGER;
    LV_STOCK_LIST_ARRAY LV_CUS_TYPE;
    LV_STOCK_LIST       STOCK_LIST%ROWTYPE;
    LV_SYS_USERS_OUT    SYS_USERS%ROWTYPE;
    LV_STOCK_ACC_OUT    STOCK_ACC%ROWTYPE;
    LV_SYS_USERS_IN     SYS_USERS%ROWTYPE;
    LV_STOCK_ACC_IN     STOCK_ACC%ROWTYPE;
    LV_CLR_DATE         PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_TASK_IDS         PK_PUBLIC.MYARRAY;
    LV_LIMIT_SQL        VARCHAR2(2000);
    LV_COUNT            NUMBER := 0;
    LV_BRCH_ID          CARD_APPLY_TASK.BRCH_ID%TYPE;
    LV_CARD_APPLY_TASK  CARD_APPLY_TASK%ROWTYPE;
    LV_STK_CODE         STOCK_ACC.STK_CODE%TYPE;
    LV_STOCK_TYPE       STOCK_TYPE%ROWTYPE;
    LV_TEMP_USER_ID     STOCK_LIST.USER_ID%TYPE;
    LV_STK_SER_NO       STOCK_REC.STK_SER_NO%TYPE;
  BEGIN
    --1.���������ж�
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             15,
                             18,
                             'pk_card_Stock.p_stock_exchange',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    --2.����Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.������Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(9),
                                     LV_IN(10),
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --4.�շ���Ա��Ϣ
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(11),
                                     LV_IN(12),
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '�շ���Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --5.�ж��շ���Ա�Ƿ����Ҫ��
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�շ���Ա״̬������';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ա���շ���Ա������ͬһ��Ա';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.ORG_ID <> LV_SYS_USERS_IN.ORG_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������ͬһ������Ա֮����в���';
      RETURN;
    END IF;
    --6.�жϽ����Ŀ��������Ϣ
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_IN(7), LV_STOCK_TYPE, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --7.���ݽ��������жϲ���
    IF LV_IN(13) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��潻����ʽ����Ϊ��';
      RETURN;
    ELSIF LV_IN(13) = '1' THEN
      IF LV_IN(14) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '��潻����ʽ��ѡ��������ʽ�������Ų���Ϊ��';
        RETURN;
      END IF;
      LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(14), ',', LV_TASK_IDS);
      IF LV_COUNT <= 0 THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�����Ų���Ϊ��';
        RETURN;
      END IF;
    ELSIF LV_IN(13) = '2' THEN
      IF LV_IN(15) IS NULL OR LV_IN(16) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '��潻����ʽ��ѡ���պŶη�ʽ����ֹ��Ų���Ϊ��';
        RETURN;
      END IF;
      IF SUBSTR(LV_IN(7), 1, 1) = '1' THEN
        LV_COUNT := PK_CARD_STOCK.F_JUDGECARDRANGE(LV_SYS_USERS_OUT.USER_ID,
                                                   LV_IN(15),
                                                   LV_IN(16),
                                                   LV_CARD_APPLY_TASK,
                                                   AV_RES,
                                                   AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        IF LV_COUNT <> NVL(LV_IN(17), -1) THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '����֮��Ŀ����ϸ�����ʹ����������һ��';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.TASK_STATE < PK_PUBLIC.KG_CARD_TASK_YJS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�Ŷ�' || LV_IN(15) || ' - ' || LV_IN(16) || '��������δ������ȷ��';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.CARD_TYPE <> PK_PUBLIC.CARD_TYPE_SMZK THEN
          IF LV_SYS_USERS_IN.BRCH_ID <> LV_CARD_APPLY_TASK.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�' || LV_IN(15) || ' - ' || LV_IN(16) ||
                      '�����ڵ�ǰ�������㣬��������������ܵ����޷����з���';
            RETURN;
          END IF;
        END IF;
        LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE;
        IF LV_STK_CODE <> NVL(LV_IN(7), -1) THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�Ŷ�' || LV_IN(15) || ' - ' || LV_IN(16) ||
                    '�����ڵ�ǰѡ���Ŀ������';
          RETURN;
        END IF;
        LV_LIMIT_SQL := ' goods_no >= ''' || LV_IN(15) ||
                        ''' and goods_no <= ''' || LV_IN(16) || ''' ';
      ELSE
        SELECT * BULK COLLECT
          INTO LV_STOCK_LIST_ARRAY
          FROM STOCK_LIST
         WHERE GOODS_NO >= LV_IN(15)
           AND GOODS_NO <= LV_IN(16);
        IF LV_STOCK_LIST_ARRAY.COUNT = 0 THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�Ŷ�' || LV_IN(15) || ' - ' || LV_IN(16) || '֮���Ҳ�����' ||
                    LV_STOCK_TYPE.STK_NAME || '�������ϸ��Ϣ';
          RETURN;
        END IF;
        FOR LV_TEMP_INDEX IN LV_STOCK_LIST_ARRAY.FIRST .. LV_STOCK_LIST_ARRAY.LAST LOOP
          LV_STOCK_LIST := LV_STOCK_LIST_ARRAY(LV_TEMP_INDEX);
          IF LV_STOCK_LIST.STK_CODE <> LV_STOCK_TYPE.STK_CODE THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�֮����Ϊ��' || LV_STOCK_LIST.GOODS_NO ||
                      '������Ʒ�����ڵ�ǰѡ���Ŀ������';
            RETURN;
          END IF;
          IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�֮����Ϊ��' || LV_STOCK_LIST.GOODS_NO ||
                      '������Ʒ��ǰ���ڹ�Ա����';
            RETURN;
          END IF;
          IF LV_STOCK_LIST.BRCH_ID <> LV_SYS_USERS_OUT.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�֮����Ϊ��' || LV_STOCK_LIST.GOODS_NO || '������Ʒ�����ڸ�������';
            RETURN;
          END IF;
          IF LV_STOCK_LIST.USER_ID <> LV_SYS_USERS_OUT.USER_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�֮����Ϊ��' || LV_STOCK_LIST.GOODS_NO || '������Ʒ�����ڸ�����Ա';
            RETURN;
          END IF;
          IF NVL(LV_STOCK_LIST.GOODS_STATE, -1) <> LV_IN(8) THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�֮����Ϊ��' || LV_STOCK_LIST.GOODS_NO ||
                      '������Ʒ�����ڴ������Ʒ״̬';
            RETURN;
          END IF;
          IF NVL(LV_STOCK_LIST.STK_IS_SURE, -1) <> '0' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�Ŷ�֮����Ϊ��' || LV_STOCK_LIST.GOODS_NO || '������Ʒδ��ȷ�Ͻ���';
            RETURN;
          END IF;
        END LOOP;
        IF LV_STOCK_LIST_ARRAY.COUNT < NVL(LV_IN(17), -1) THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '�Ŷ�' || LV_IN(15) || ' - ' || LV_IN(16) || '֮�䡾' ||
                    LV_STOCK_TYPE.STK_NAME || '�������ϸ�����ʹ���������һ��';
          RETURN;
        END IF;
        LV_STK_CODE := LV_STOCK_TYPE.STK_CODE;
        SELECT COUNT(1)
          INTO LV_COUNT
          FROM STOCK_LIST
         WHERE OWN_TYPE = '0'
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND GOODS_STATE = LV_IN(8)
           AND STK_CODE = LV_STK_CODE
           AND GOODS_NO <= LV_IN(16)
           AND GOODS_NO >= LV_IN(15);
        IF LV_COUNT <> LV_IN(17) THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '��ǰ����' || LV_STOCK_TYPE.STK_NAME || '�Ŀ����ϸ״̬��Ψһ';
          RETURN;
        END IF;
        LV_LIMIT_SQL := ' goods_no >= ''' || LV_IN(15) ||
                        ''' and goods_no <= ''' || LV_IN(16) || ''' ';
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��潻����ʽ����ȷ';
      RETURN;
    END IF;
    --7.������������ǰ�������ʽ,ѭ������ÿ������
    IF LV_IN(13) = '1' THEN
      FOR LV_ROW_INDEX IN LV_TASK_IDS.FIRST .. LV_TASK_IDS.LAST LOOP
        BEGIN
          SELECT *
            INTO LV_CARD_APPLY_TASK
            FROM CARD_APPLY_TASK
           WHERE TASK_ID = LV_TASK_IDS(LV_ROW_INDEX);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����������' || LV_TASK_IDS(LV_ROW_INDEX) || '�Ҳ���������Ϣ';
            RETURN;
          WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '����������' || LV_TASK_IDS(LV_ROW_INDEX) || '��ȡ������Ϣ��������' ||
                      SQLERRM;
            RETURN;
        END;
        IF LV_CARD_APPLY_TASK.TASK_STATE < PK_PUBLIC.KG_CARD_TASK_YJS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ�������' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '���ǽ���ȷ��״̬�����ܽ�������';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.CARD_TYPE = PK_PUBLIC.CARD_TYPE_SMZK THEN
          IF LV_CARD_APPLY_TASK.BRCH_ID <> LV_SYS_USERS_IN.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '�����š�' || LV_TASK_IDS(LV_ROW_INDEX) ||
                      '��������������������㲻��ͬһ���㣬���͵���������ܵ����޷����з���';
            RETURN;
          END IF;
        END IF;
        LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE; --ע�⣺�˴�������͵����ɹ���
        SELECT COUNT(1)
          INTO LV_COUNT
          FROM STOCK_LIST
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID
           AND ORG_ID = LV_SYS_USERS_OUT.ORG_ID
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND OWN_TYPE = '0'
           AND STK_IS_SURE = '0'
           AND GOODS_STATE = LV_IN(8)
           AND STK_CODE = LV_STK_CODE;
        IF LV_COUNT <> LV_CARD_APPLY_TASK.TASK_SUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ��������š�' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '���Ŀ����ϸ����������������һ�£�����������ϸ���ڵ�ǰ��Ա����';
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETSTOCK_ACC(LV_IN(9),
                                     LV_IN(10),
                                     LV_STK_CODE,
                                     LV_IN(8),
                                     LV_STOCK_ACC_OUT,
                                     AV_RES,
                                     AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        IF LV_STOCK_ACC_OUT.TOT_NUM < LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '����' || LV_STOCK_TYPE.STK_NAME || '����˻�����';
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETSTOCK_ACC(LV_IN(11),
                                     LV_IN(12),
                                     LV_STK_CODE,
                                     LV_IN(8),
                                     LV_STOCK_ACC_IN,
                                     AV_RES,
                                     AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STK_SER_NO FROM DUAL;
        EXECUTE IMMEDIATE 'INSERT INTO stock_rec(STK_SER_NO,DEAL_CODE,STK_CODE,batch_id,task_id,in_org_id,
in_brch_id,in_user_id,in_goods_state,out_org_id,out_brch_id,out_user_id,
out_goods_state,goods_id,goods_no,goods_nums,in_out_flag,tr_date,org_id,
brch_id,user_id,auth_oper_id,book_state,clr_date,deal_no,note,is_sure,start_no,end_no
)(SELECT ' || LV_STK_SER_NO ||
                          ',:1,:2,max(batch_id),task_id,''' ||
                          LV_SYS_USERS_IN.ORG_ID || ''',''' ||
                          LV_SYS_USERS_IN.BRCH_ID || ''',''' ||
                          LV_SYS_USERS_IN.USER_ID || ''',:3,''' ||
                          LV_SYS_USERS_OUT.ORG_ID || ''',''' ||
                          LV_SYS_USERS_OUT.BRCH_ID || ''',''' ||
                          LV_SYS_USERS_OUT.USER_ID ||
                          ''',
:4, NULL,NULL,count(1),''3'', to_date(''' ||
                          LV_IN(6) || ''',''yyyy-mm-dd hh24:mi:ss''),''' ||
                          LV_USERS.ORG_ID || ''',''' || LV_USERS.BRCH_ID ||
                          ''',''' || LV_USERS.USER_ID || ''',NULL,
''0'',''' || LV_CLR_DATE ||
                          ''',:5,:6,''0'',min(goods_no),max(goods_no)
FROM stock_list WHERE task_id = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID ||
                          ''' and brch_id = ''' || LV_SYS_USERS_OUT.BRCH_ID ||
                          ''' and user_id = ''' || LV_SYS_USERS_OUT.USER_ID ||
                          ''' and own_type = ''0'' and goods_state = ''' ||
                          LV_IN(8) ||
                          ''' and stk_is_sure = ''0'' and stk_code = ''' ||
                          LV_STK_CODE || ''' group by task_id ' || ')'
          USING LV_IN(5), LV_STK_CODE, LV_IN(8), LV_IN(8), LV_IN(4), LV_IN(18);
        IF SQL%ROWCOUNT <> 1 THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ�������' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '�ڼ�¼����˻�������־ʱ���ִ���';
          RETURN;
        END IF;
        INSERT INTO STOCK_INOUT_DETAIL
          (STK_INOUT_NO,
           STK_TYPE,
           STK_CODE,
           IN_GOODS_STATE,
           OUT_GOODS_STATE,
           ORG_ID,
           BRCH_ID,
           USER_ID,
           AUTH_USER_ID,
           DEAL_CODE,
           DEAL_DATE,
           IN_ORG_ID,
           IN_BRCH_ID,
           IN_USER_ID,
           OUT_ORG_ID,
           OUT_BRCH_ID,
           OUT_USER_ID,
           BATCH_ID,
           TASK_ID,
           GOODS_NO,
           GOODS_ID,
           TOT_NUM,
           TOT_AMT,
           IN_OUT_FLAG,
           BOOK_STATE,
           CLR_DATE,
           DEAL_NO,
           NOTE,
           REV_DATE)
          (SELECT SEQ_STK_INOUT_NO.NEXTVAL,
                  SUBSTR(LV_STK_CODE, 1, 1),
                  STK_CODE,
                  LV_IN(8),
                  LV_IN(8),
                  LV_USERS.ORG_ID,
                  LV_USERS.BRCH_ID,
                  LV_USERS.USER_ID,
                  NULL,
                  LV_IN(5),
                  TO_DATE(LV_IN(6), 'YYYY-MM-DD HH24:MI:SS'),
                  LV_SYS_USERS_IN.ORG_ID,
                  LV_SYS_USERS_IN.BRCH_ID,
                  LV_SYS_USERS_IN.USER_ID,
                  LV_SYS_USERS_OUT.ORG_ID,
                  LV_SYS_USERS_OUT.BRCH_ID,
                  LV_SYS_USERS_OUT.USER_ID,
                  BATCH_ID,
                  TASK_ID,
                  GOODS_NO,
                  GOODS_ID,
                  '1',
                  '0',
                  '3',
                  '0',
                  LV_CLR_DATE,
                  LV_IN(4),
                  LV_IN(18),
                  NULL
             FROM STOCK_LIST
            WHERE STK_IS_SURE = '0'
              AND OWN_TYPE = '0'
              AND GOODS_STATE = LV_IN(8)
              AND ORG_ID = LV_SYS_USERS_OUT.ORG_ID
              AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
              AND USER_ID = LV_SYS_USERS_OUT.USER_ID
              AND STK_CODE = LV_STK_CODE
              AND TASK_ID = LV_CARD_APPLY_TASK.TASK_ID);
        IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.TASK_SUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ�������' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '�ڼ�¼�˻���ˮ��Ϣ���ִ��󣬸���' || SQL%ROWCOUNT || '����¼';
          RETURN;
        END IF;
        --�����������Ʒ��ϸ����Ϊ�շ���
        EXECUTE IMMEDIATE 'update stock_list set brch_id = ''' ||
                          LV_SYS_USERS_IN.BRCH_ID || ''',out_deal_no = ''' ||
                          LV_IN(4) || '''' || ',user_id = ''' ||
                          LV_SYS_USERS_IN.USER_ID || ''',org_id = ''' ||
                          LV_SYS_USERS_IN.ORG_ID || ''',out_date = ' ||
                          'to_date(''' || LV_IN(6) ||
                          ''',''yyyy-mm-dd hh24:mi:ss''),out_brch_id = ''' ||
                          LV_SYS_USERS_OUT.BRCH_ID || ''',out_user_id = ''' ||
                          LV_SYS_USERS_OUT.USER_ID || ''' ' ||
                          'where task_id = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID ||
                          ''' and org_id = ''' || LV_SYS_USERS_OUT.ORG_ID ||
                          ''' and brch_id = ''' || LV_SYS_USERS_OUT.BRCH_ID ||
                          ''' and user_id = ''' || LV_SYS_USERS_OUT.USER_ID ||
                          ''' and own_type = ''0'' and goods_state = ''' ||
                          LV_IN(8) ||
                          ''' and stk_is_sure = ''0'' and stk_code = ''' ||
                          LV_STK_CODE || '''';
        IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.TASK_SUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := 'ѡ���������' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '���������ϸ��Ʒ����������������һ�£��޷����п�潻��';
          RETURN;
        END IF;
        --13.���¸�������˻�
        UPDATE STOCK_ACC
           SET TOT_NUM        = NVL(TOT_NUM, 0) -
                                LV_CARD_APPLY_TASK.TASK_SUM,
               LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
         WHERE GOODS_STATE = LV_IN(8)
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND STK_CODE = LV_STK_CODE;
        --14.�����շ�����˻�
        UPDATE STOCK_ACC
           SET TOT_NUM        = NVL(TOT_NUM, 0) +
                                LV_CARD_APPLY_TASK.TASK_SUM,
               LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
         WHERE GOODS_STATE = LV_IN(8)
           AND USER_ID = LV_SYS_USERS_IN.USER_ID
           AND BRCH_ID = LV_SYS_USERS_IN.BRCH_ID
           AND STK_CODE = LV_STK_CODE;
      END LOOP;
    ELSE
      PK_CARD_STOCK.P_GETSTOCK_ACC(LV_IN(9),
                                   LV_IN(10),
                                   LV_STK_CODE,
                                   LV_IN(8),
                                   LV_STOCK_ACC_OUT,
                                   AV_RES,
                                   AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      IF LV_STOCK_ACC_OUT.TOT_NUM < NVL(LV_IN(17), 0) THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '����' || LV_STOCK_TYPE.STK_NAME || '����˻�����';
        RETURN;
      END IF;
      PK_CARD_STOCK.P_GETSTOCK_ACC(LV_IN(11),
                                   LV_IN(12),
                                   LV_STK_CODE,
                                   LV_IN(8),
                                   LV_STOCK_ACC_IN,
                                   AV_RES,
                                   AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      EXECUTE IMMEDIATE 'INSERT INTO stock_rec(
STK_SER_NO,
DEAL_CODE,
STK_CODE,
batch_id,task_id,in_org_id,in_brch_id,in_user_id,in_goods_state,out_org_id,
out_brch_id,out_user_id,out_goods_state,goods_id,
goods_no,goods_nums,in_out_flag,tr_date,org_id,brch_id,user_id,auth_oper_id,
book_state,clr_date,deal_no,note,is_sure,start_no,end_no
) values (
SEQ_STK_SER_NO.Nextval,
:1,
:2,
null,
null,''' || LV_SYS_USERS_IN.ORG_ID || ''',''' ||
                        LV_SYS_USERS_IN.BRCH_ID || ''',''' ||
                        LV_SYS_USERS_IN.USER_ID || ''',
:3,''' || LV_SYS_USERS_OUT.ORG_ID || ''',''' ||
                        LV_SYS_USERS_OUT.BRCH_ID || ''',''' ||
                        LV_SYS_USERS_OUT.USER_ID || ''',
:4,
null,
null,
:5,
''3'',
to_date(''' || LV_IN(6) ||
                        ''',''yyyy-mm-dd hh24:mi:ss''), ''' ||
                        LV_USERS.ORG_ID || ''',''' || LV_USERS.BRCH_ID ||
                        ''',''' || LV_USERS.USER_ID || ''',
null,
''0'',''' || LV_CLR_DATE || ''',
:6,
:7,
''0'',
:8,
:9' || ')'
        USING LV_IN(5), LV_STK_CODE, LV_IN(8), LV_IN(8), LV_IN(17), LV_IN(4), LV_IN(18), LV_IN(15), LV_IN(16);
      IF SQL%ROWCOUNT <> 1 THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��¼����' || LV_IN(15) || ' - ' || LV_IN(16) || '��־��Ϣ���ִ���';
        RETURN;
      END IF;
      INSERT INTO STOCK_INOUT_DETAIL
        (STK_INOUT_NO,
         STK_TYPE,
         STK_CODE,
         IN_GOODS_STATE,
         OUT_GOODS_STATE,
         ORG_ID,
         BRCH_ID,
         USER_ID,
         AUTH_USER_ID,
         DEAL_CODE,
         DEAL_DATE,
         IN_ORG_ID,
         IN_BRCH_ID,
         IN_USER_ID,
         OUT_ORG_ID,
         OUT_BRCH_ID,
         OUT_USER_ID,
         BATCH_ID,
         TASK_ID,
         GOODS_NO,
         GOODS_ID,
         TOT_NUM,
         TOT_AMT,
         IN_OUT_FLAG,
         BOOK_STATE,
         CLR_DATE,
         DEAL_NO,
         NOTE,
         REV_DATE)
        (SELECT SEQ_STK_INOUT_NO.NEXTVAL,
                SUBSTR(LV_STK_CODE, 1, 1),
                STK_CODE,
                LV_IN(8),
                LV_IN(8),
                LV_USERS.ORG_ID,
                LV_USERS.BRCH_ID,
                LV_USERS.USER_ID,
                NULL,
                LV_IN(5),
                TO_DATE(LV_IN(6), 'YYYY-MM-DD HH24:MI:SS'),
                LV_SYS_USERS_IN.ORG_ID,
                LV_SYS_USERS_IN.BRCH_ID,
                LV_SYS_USERS_IN.USER_ID,
                LV_SYS_USERS_OUT.ORG_ID,
                LV_SYS_USERS_OUT.BRCH_ID,
                LV_SYS_USERS_OUT.USER_ID,
                BATCH_ID,
                TASK_ID,
                GOODS_NO,
                GOODS_ID,
                '1',
                '0',
                '3',
                '0',
                LV_CLR_DATE,
                LV_IN(4),
                LV_IN(18),
                NULL
           FROM STOCK_LIST
          WHERE STK_IS_SURE = '0'
            AND OWN_TYPE = '0'
            AND GOODS_STATE = LV_IN(8)
            AND ORG_ID = LV_SYS_USERS_OUT.ORG_ID
            AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
            AND USER_ID = LV_SYS_USERS_OUT.USER_ID
            AND STK_CODE = LV_STK_CODE
            AND GOODS_NO >= LV_IN(15)
            AND GOODS_NO <= LV_IN(16));
      IF SQL%ROWCOUNT <> LV_IN(17) THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��¼����' || LV_IN(15) || ' - ' || LV_IN(16) || '�˻���ˮ��Ϣ���ִ���';
        RETURN;
      END IF;
      --�����������Ʒ��ϸ����Ϊ�շ���
      EXECUTE IMMEDIATE 'update stock_list set brch_id = ''' ||
                        LV_SYS_USERS_IN.BRCH_ID || ''',out_deal_no = ''' ||
                        LV_IN(4) || '''' || ',user_id = ''' ||
                        LV_SYS_USERS_IN.USER_ID || ''',org_id = ''' ||
                        LV_SYS_USERS_IN.ORG_ID || ''',out_date = ' ||
                        'to_date(''' || LV_IN(6) ||
                        ''',''yyyy-mm-dd hh24:mi:ss''),out_brch_id = ''' ||
                        LV_SYS_USERS_OUT.BRCH_ID || ''',out_user_id = ''' ||
                        LV_SYS_USERS_OUT.USER_ID || ''' ' || 'where ' ||
                        LV_LIMIT_SQL || ' and org_id = ''' ||
                        LV_SYS_USERS_OUT.ORG_ID || ''' and brch_id = ''' ||
                        LV_SYS_USERS_OUT.BRCH_ID || ''' and user_id = ''' ||
                        LV_SYS_USERS_OUT.USER_ID ||
                        ''' and own_type = ''0'' and goods_state = ''' ||
                        LV_IN(8) ||
                        ''' and stk_is_sure = ''0'' and stk_code = ''' ||
                        LV_STK_CODE || '''';
      IF SQL%ROWCOUNT <> LV_IN(17) THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := 'ѡ��Ŀ���' || LV_IN(15) || ' - ' || LV_IN(16) ||
                  '���������ϸ��Ʒ�����봫��������һ�£��޷����п�潻��';
        RETURN;
      END IF;
      --13.���¸�������˻�
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) - LV_IN(17),
             LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_IN(8)
         AND USER_ID = LV_SYS_USERS_OUT.USER_ID
         AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
         AND STK_CODE = LV_STK_CODE;
      --14.�����շ�����˻�
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) + LV_IN(17),
             LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_IN(8)
         AND USER_ID = LV_SYS_USERS_IN.USER_ID
         AND BRCH_ID = LV_SYS_USERS_IN.BRCH_ID
         AND STK_CODE = LV_STK_CODE;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_STOCK_EXCHANGE;
  --���ݿ����ˮ���п�潻��
  --av_rec �����ˮ
  --av_change_type��潻����ʽ 1 ��������ʽ 2 ���պŶν���
  --av_res �����������
  --av_msg �������˵��
  PROCEDURE P_STOCK_INCHANGE(AV_REC         STOCK_REC%ROWTYPE,
                             AV_CHANGE_TYPE VARCHAR2,
                             AV_RES         OUT VARCHAR2,
                             AV_MSG         OUT VARCHAR2) IS
    LV_SYS_USERS_OUT SYS_USERS%ROWTYPE; --������Ա
    LV_STOCK_ACC_OUT STOCK_ACC%ROWTYPE; --��������˻�
    LV_SYS_USERS_IN  SYS_USERS%ROWTYPE; --�뷿��Ա
    LV_STOCK_ACC_IN  STOCK_ACC%ROWTYPE; --�뷿����˻�
    LV_LIMIT_SQL     VARCHAR2(500) := '';
    LV_STK_SER_NO    STOCK_REC.STK_SER_NO%TYPE;
  BEGIN
    --1.������Ա������˻��ж�
    PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_REC.OUT_BRCH_ID,
                                     AV_REC.OUT_USER_ID,
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '������Ա״̬������';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_ACC(AV_REC.OUT_BRCH_ID,
                                 AV_REC.OUT_USER_ID,
                                 AV_REC.STK_CODE,
                                 AV_REC.OUT_GOODS_STATE,
                                 LV_STOCK_ACC_OUT,
                                 AV_RES,
                                 AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      AV_MSG := '��ȡ��������˻���������,' || AV_MSG;
      RETURN;
    END IF;
    IF NVL(LV_STOCK_ACC_OUT.TOT_NUM, 0) < NVL(AV_REC.GOODS_NUMS, 0) THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��������˻�����';
      RETURN;
    END IF;
    --2.�շ���Ա������˻��ж�
    PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_REC.IN_BRCH_ID,
                                     AV_REC.IN_USER_ID,
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '�շ���Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�շ���Ա״̬������';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��潻��������ͬһ����Ա';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_ACC(AV_REC.IN_BRCH_ID,
                                 AV_REC.IN_USER_ID,
                                 AV_REC.STK_CODE,
                                 AV_REC.IN_GOODS_STATE,
                                 LV_STOCK_ACC_IN,
                                 AV_RES,
                                 AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      AV_MSG := '��ȡ�շ�����˻���������,' || AV_MSG;
      RETURN;
    END IF;
    --3.���ݿ�潻�������жϱ������
    IF AV_CHANGE_TYPE IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��潻�����Ͳ���Ϊ��';
      RETURN;
    ELSIF AV_CHANGE_TYPE = '1' THEN
      IF AV_REC.TASK_ID IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��潻��������ѡ����������ʽ�����н����������Ų���Ϊ��';
        RETURN;
      ELSE
        LV_LIMIT_SQL := ' task_id =''' || AV_REC.TASK_ID || ''' ';
      END IF;
    ELSIF AV_CHANGE_TYPE = '2' THEN
      IF AV_REC.START_NO IS NULL OR AV_REC.END_NO IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��潻��������ѡ�������Ŷη�ʽ�����н�������ֹ��Ʒ��Ų���Ϊ��';
        RETURN;
      ELSE
        LV_LIMIT_SQL := ' goods_no between ''' || AV_REC.START_NO ||
                        ''' and ''' || AV_REC.END_NO || ''' ';
      END IF;
    END IF;
    --4.���¿����ϸ
    EXECUTE IMMEDIATE 'UPDATE stock_list set org_id = :1,brch_id = :2,user_id = :3 ' ||
                      'WHERE b.stk_is_sure = ''0'' and b.own_type = ''0'' AND ' ||
                      LV_LIMIT_SQL ||
                      'AND org_id = :4 AND brch_id = :5 AND user_id = :6 and stk_code = :7 and goods_state = :8'
      USING AV_REC.IN_ORG_ID, AV_REC.IN_BRCH_ID, AV_REC.USER_ID, AV_REC.OUT_ORG_ID, AV_REC.OUT_BRCH_ID, AV_REC.USER_ID, AV_REC.STK_CODE, AV_REC.OUT_GOODS_STATE;
    IF SQL%ROWCOUNT <> AV_REC.GOODS_NUMS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���������ϸ��������';
      RETURN;
    END IF;
    --5.���¸�������˻�
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) - NVL(AV_REC.GOODS_NUMS, 0),
           LAST_DEAL_DATE = AV_REC.TR_DATE
     WHERE GOODS_STATE = AV_REC.OUT_GOODS_STATE
       AND USER_ID = AV_REC.OUT_USER_ID
       AND BRCH_ID = AV_REC.OUT_BRCH_ID
       AND STK_CODE = AV_REC.STK_CODE;
    --6.�����շ�����˻�
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) + NVL(AV_REC.GOODS_NUMS, 0),
           LAST_DEAL_DATE = AV_REC.TR_DATE
     WHERE GOODS_STATE = AV_REC.IN_GOODS_STATE
       AND USER_ID = AV_REC.IN_USER_ID
       AND BRCH_ID = AV_REC.IN_BRCH_ID
       AND STK_CODE = AV_REC.STK_CODE;
    --7.��������ˮ
    IF AV_REC.STK_SER_NO IS NULL THEN
      SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STK_SER_NO FROM DUAL;
    END IF;
    --av_rec.stk_ser_no := lv_stk_ser_no;
    INSERT INTO STOCK_REC VALUES AV_REC;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_STOCK_INCHANGE;
  --CardBaseinfo����,���˷���,��ģ����
  --����˵����
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7����card_no
  --8������task_id
  --9��עnote
  PROCEDURE P_CARD_RELEASE(AV_IN  VARCHAR2,
                           AV_RES OUT VARCHAR2,
                           AV_MSG OUT VARCHAR2) IS
    LV_IN              PK_PUBLIC.MYARRAY;
    LV_USERS           SYS_USERS%ROWTYPE;
    LV_SYS_USERS_OUT   SYS_USERS%ROWTYPE;
    LV_STOCK_LIST      STOCK_LIST%ROWTYPE;
    LV_STOCK_TYPE      STOCK_TYPE%ROWTYPE;
    LV_CLR_DATE        PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_STOCK_ACC_OUT   STOCK_ACC%ROWTYPE;
    LV_CARD_APPLY_TASK CARD_APPLY_TASK%ROWTYPE;
    LV_COUNT           NUMBER := 0;
    LV_TOTNUM          NUMBER := 0;
    LV_STK_CODE        STOCK_LIST.STK_CODE%TYPE;
    LV_LIMIT_SQL       VARCHAR2(1000);
    LV_OUT_USER_ID     STOCK_LIST.USER_ID%TYPE;
    LV_OUT_BRCH_ID     STOCK_LIST.BRCH_ID%TYPE;
    LV_OUT_ORG_ID      STOCK_LIST.ORG_ID%TYPE;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             9,
                             9,
                             'pk_card_Stock.p_card_release',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '��Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL AND LV_IN(8) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '���ź������Ų��ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7) IS NOT NULL THEN
      LV_COUNT  := 1;
      LV_TOTNUM := 0;
    ELSE
      GOTO ONE_TASK_ID;
    END IF;
    <<ONE_CARD_NO>>
    BEGIN
      SELECT *
        INTO LV_STOCK_LIST
        FROM STOCK_LIST
       WHERE GOODS_NO = LV_IN(7);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�����ϸ������';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := SQLERRM;
    END;
    IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ�������Ͳ����ڹ�Ա';
      RETURN;
    END IF;
    IF LV_STOCK_LIST.BRCH_ID <> LV_USERS.BRCH_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ�����ڵ�ǰ����';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_STOCK_LIST.STK_CODE,
                                  LV_STOCK_TYPE,
                                  AV_RES,
                                  AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF NVL(LV_STOCK_TYPE.OUT_FLAG, 0) = '0' AND
       LV_STOCK_LIST.USER_ID <> LV_USERS.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ�����ڵ�ǰ��Ա';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETCARDAPPLYTASKBYTASKID(LV_STOCK_LIST.TASK_ID,
                                             LV_CARD_APPLY_TASK,
                                             AV_RES,
                                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST.BRCH_ID,
                                     LV_STOCK_LIST.USER_ID,
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    SELECT COUNT(1)
      INTO LV_TOTNUM
      FROM CARD_APPLY
     WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID
       AND APPLY_STATE >= PK_PUBLIC.KG_CARD_APPLY_YFF;
    LV_OUT_ORG_ID                    := LV_SYS_USERS_OUT.ORG_ID;
    LV_OUT_BRCH_ID                   := LV_SYS_USERS_OUT.BRCH_ID;
    LV_OUT_USER_ID                   := LV_SYS_USERS_OUT.USER_ID;
    LV_LIMIT_SQL                     := ' goods_no = ''' ||
                                        LV_STOCK_LIST.GOODS_NO || ''' ';
    LV_CARD_APPLY_TASK.START_CARD_NO := '';
    LV_CARD_APPLY_TASK.END_CARD_NO   := '';
    GOTO GOTO_UPDDATE_ACC;
    <<ONE_TASK_ID>>
    BEGIN
      SELECT *
        INTO LV_CARD_APPLY_TASK
        FROM CARD_APPLY_TASK
       WHERE TASK_ID = LV_IN(8);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '����������' || LV_IN(8) || 'δ�ҵ�������Ϣ';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '����������' || LV_IN(8) || '��ȡ������Ϣ��������' || SQLERRM;
    END;
    IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YJS AND
       LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_FKZ THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '����������' || LV_IN(8) || '��ȡ����������Ϣ���ǡ��ѽ��ա��򡾷����С�״̬';
      RETURN;
    END IF;
    LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_STK_CODE,
                                  LV_STOCK_TYPE,
                                  AV_RES,
                                  AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_OUT_ORG_ID  := LV_USERS.ORG_ID;
    LV_OUT_BRCH_ID := LV_USERS.BRCH_ID;
    LV_OUT_USER_ID := LV_USERS.USER_ID;
    LV_LIMIT_SQL   := ' task_id = ''' || LV_CARD_APPLY_TASK.TASK_ID ||
                      ''' ';
    SELECT COUNT(1)
      INTO LV_TOTNUM
      FROM CARD_APPLY
     WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID
       AND APPLY_STATE >= PK_PUBLIC.KG_CARD_APPLY_YFF;
    LV_COUNT := LV_CARD_APPLY_TASK.TASK_SUM - LV_TOTNUM;
    <<GOTO_UPDDATE_ACC>>
    PK_CARD_STOCK.P_GETSTOCK_ACC(LV_OUT_BRCH_ID,
                                 LV_OUT_USER_ID,
                                 LV_STOCK_TYPE.STK_CODE,
                                 '0',
                                 LV_STOCK_ACC_OUT,
                                 AV_RES,
                                 AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_STOCK_ACC_OUT.TOT_NUM < LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��������˻�����';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'INSERT INTO STOCK_REC(STK_SER_NO,DEAL_CODE,STK_CODE,batch_id,task_id,in_org_id,in_brch_id,
in_user_id,in_goods_state,out_org_id,out_brch_id,out_user_id,out_goods_state,
goods_id,goods_no,goods_nums,in_out_flag,tr_date,org_id,brch_id,user_id,auth_oper_id,
book_state,clr_date,deal_no,note,is_sure,start_no,end_no
)values(SEQ_STK_SER_NO.Nextval,:1,:2,:3,:4,NULL,NULL,NULL,NULL,' ||
                      LV_OUT_ORG_ID || ',' || LV_OUT_BRCH_ID || ',''' ||
                      LV_OUT_USER_ID || ''',''0'',' || ':5,:6,' || LV_COUNT ||
                      ',''2'',to_date(''' || LV_IN(6) ||
                      ''',''yyyy-mm-dd hh24:mi:ss''),' || LV_USERS.ORG_ID || ',' ||
                      LV_USERS.BRCH_ID || ',''' || LV_USERS.USER_ID ||
                      ''',NULL,' || '''0'',:7,:8,:9,''0'',:10,:11) '
      USING LV_IN(5), LV_STOCK_TYPE.STK_CODE, LV_CARD_APPLY_TASK.MAKE_BATCH_ID, LV_CARD_APPLY_TASK.TASK_ID, LV_STOCK_LIST.GOODS_ID, LV_STOCK_LIST.GOODS_NO, LV_CLR_DATE, LV_IN(4), LV_IN(9), LV_CARD_APPLY_TASK.START_CARD_NO, LV_CARD_APPLY_TASK.END_CARD_NO;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��¼��������־���ִ���-' || SQL%ROWCOUNT || '��';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'INSERT INTO STOCK_INOUT_DETAIL (stk_inout_no,stk_type,stk_code,in_goods_state,out_goods_state,org_id,
brch_id,user_id,auth_user_id,deal_code,deal_date,in_org_id,in_brch_id,
in_user_id,out_org_id,out_brch_id,out_user_id,batch_id,task_id,goods_no,
goods_id,tot_num,tot_amt,in_out_flag,book_state,clr_date,deal_no,note,rev_date
)' || '(SELECT SEQ_STK_INOUT_NO.NEXTVAL,SUBSTR(' ||
                      LV_STOCK_TYPE.STK_CODE ||
                      ',1,1),STK_CODE,NULL,GOODS_STATE,:1,:2,:3,NULL,' ||
                      ':4,TO_DATE(''' || LV_IN(6) ||
                      ''',''YYYY-MM-DD HH24:MI:SS''),NULL,NULL,NULL,:5,:6,:7,BATCH_ID,TASK_ID,GOODS_NO,GOODS_ID,''1'',' ||
                      '''0'',''2'',''0'',:8,:9,:10,NULL ' ||
                      'FROM STOCK_LIST WHERE STK_IS_SURE = ''0'' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''0'' AND ' ||
                      'ORG_ID = ''' || LV_OUT_ORG_ID ||
                      ''' AND BRCH_ID = ''' || LV_OUT_BRCH_ID ||
                      ''' AND USER_ID = ''' || LV_OUT_USER_ID ||
                      ''' AND STK_CODE = ''' || LV_STOCK_TYPE.STK_CODE ||
                      ''' AND ' || LV_LIMIT_SQL || ')'
      USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_IN(5), LV_OUT_ORG_ID, LV_OUT_BRCH_ID, LV_OUT_USER_ID, LV_CLR_DATE, LV_IN(4), LV_IN(9);
    IF SQL%ROWCOUNT < LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��¼���������ˮ��Ϣ���ִ��󣬸��������ϸ����';
      RETURN;
    END IF;
    IF SQL%ROWCOUNT <> LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��¼���������ˮ��Ϣ���ִ������¼' || LV_COUNT || '����ʵ�ʼ�¼' ||
                SQL%ROWCOUNT || '��';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'update stock_list set own_type = ''1'',brch_id = null,out_deal_no = ''' ||
                      LV_IN(4) || '''' ||
                      ',user_id = null,org_id = null,customer_id=(select customer_id from card_baseinfo where card_no = goods_no),customer_name = (select name from card_baseinfo t1,base_personal t2 where ' ||
                      't1.customer_id = t2.customer_id(+) and t1.card_no = goods_no),' ||
                      'out_date = to_date(''' || LV_IN(6) ||
                      ''',''yyyy-mm-dd hh24:mi:ss''),out_brch_id = ''' ||
                      LV_OUT_BRCH_ID || ''',out_user_id = ''' ||
                      LV_OUT_USER_ID || ''' ' || 'where org_id = ''' ||
                      LV_OUT_ORG_ID || ''' and brch_id = ''' ||
                      LV_OUT_BRCH_ID || ''' and user_id = ''' ||
                      LV_OUT_USER_ID ||
                      ''' and own_type = ''0'' and goods_state = ''0'' ' ||
                      'and stk_is_sure = ''0'' and stk_code = ''' ||
                      LV_STOCK_TYPE.STK_CODE || ''' and ' || LV_LIMIT_SQL;
    IF SQL%ROWCOUNT < LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���¸��������ϸ������������ȷ�����������ϸ��Ʒ��������';
      RETURN;
    ELSIF SQL%ROWCOUNT > LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���¸��������ϸ������������ȷ��������' || LV_COUNT || 'ʵ�ʸ���' || SQL%ROWCOUNT || '��';
      RETURN;
    END IF;
    /**
    EXECUTE IMMEDIATE 'update card_apply set apply_state = ''' || pk_public.kg_card_apply_yff || ''',RELS_BRCH_ID = ''' || lv_users.brch_id
    || ''',RELS_USER_ID = ''' || lv_users.user_id || ''',RELS_DATE = to_date(''' || lv_in(6) || ''',''yyyy-mm-dd hh24:mi:ss''),ISSUSE_DEAL_NO = ' || lv_in(4)
    || ' where ' || REPLACE(lv_limit_sql,'goods_no','card_no') || ' and apply_state = ''' || pk_public.kg_card_apply_yjs || '''';
    IF SQL%ROWCOUNT <> lv_count THEN
    av_res := pk_public.cs_res_unknownerr;
    av_msg := '��������״̬��������ȷ��������' || lv_count || 'ʵ�ʸ���' || SQL%ROWCOUNT || '��';
    RETURN;
    END IF;
    IF lv_card_apply_task.task_sum = (lv_count + lv_totnum) THEN
    UPDATE card_apply_task SET task_state = pk_public.kg_card_task_yff WHERE task_id = lv_card_apply_task.task_id;
    ELSE
    UPDATE card_apply_task SET task_state = pk_public.kg_card_task_fkz WHERE task_id = lv_card_apply_task.task_id;
    END IF;
    IF SQL%ROWCOUNT <> 1 THEN
    av_res := pk_public.cs_res_unknownerr;
    av_msg := '��������״̬����ȷ��ʵ�ʸ���' || SQL%ROWCOUNT || '��';
    RETURN;
    END IF;**/
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) - LV_COUNT,
           LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
     WHERE GOODS_STATE = '0'
       AND USER_ID = LV_OUT_USER_ID
       AND BRCH_ID = LV_OUT_BRCH_ID
       AND STK_CODE = LV_STOCK_TYPE.STK_CODE;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���¸�������˻�����ȷ����ȷ�ϸ�������˻��Ƿ����';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_CARD_RELEASE;
  --�����Ʒ���
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7�������STK_CODE
  --8��Ʒ���id GOODS_ID
  --9��Ʒ���GOODS_NO
  --10��Ʒ״̬GOODS_STATE
  --11��������BATCH_ID
  --12��������TASK_ID
  --13�Ƿ�ȷ��STK_IS_SURE
  --14�������IN_BRCH_ID
  --15����ԱIN_USER_ID
  --16��������OWN_TYPE
  --17��������ORG_ID
  --18��������BRCH_ID
  --19������ԱUSER_ID
  --20�����ͻ����
  --21�����ͻ�����
  --22��עNOTE
  PROCEDURE P_IN_STOCK(AV_IN  VARCHAR2,
                       AV_RES OUT VARCHAR2,
                       AV_MSG OUT VARCHAR2) IS
    LV_IN                 PK_PUBLIC.MYARRAY;
    LV_CLR_DATE           PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_STOCK_LIST         STOCK_LIST%ROWTYPE;
    LV_STOCK_REC          STOCK_REC%ROWTYPE;
    LV_STOCK_INOUT_DETAIL STOCK_INOUT_DETAIL%ROWTYPE;
    LV_STOCK_TYPE         STOCK_TYPE%ROWTYPE;
    LV_USERS              SYS_USERS%ROWTYPE;
    LV_COUNT              NUMBER;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             9,
                             23,
                             'pk_card_Stock.p_in_stock',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��Ʒ��⣬�����벻��Ϊ��';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_IN(7), LV_STOCK_TYPE, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_STOCK_LIST.STK_CODE := LV_STOCK_TYPE.STK_CODE;
    IF LV_IN(9) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��Ʒ��⣬��Ʒ��Ų���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      LV_STOCK_LIST.GOODS_ID := LV_IN(9);
    ELSE
      LV_STOCK_LIST.GOODS_ID := LV_IN(8);
    END IF;
    SELECT COUNT(1)
      INTO LV_COUNT
      FROM STOCK_LIST
     WHERE GOODS_NO = LV_IN(9)
        OR GOODS_ID = LV_STOCK_LIST.GOODS_ID;
    IF LV_COUNT > 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��ͬ��Ʒ����Ѿ����ڣ��벻Ҫ�ظ��������';
      RETURN;
    END IF;
    LV_STOCK_LIST.GOODS_NO := LV_IN(9);
    IF LV_IN(10) IS NULL THEN
      LV_IN(10) := '0';
    END IF;
    SELECT COUNT(1)
      INTO LV_COUNT
      FROM SYS_CODE
     WHERE CODE_TYPE = 'GOODS_STATE'
       AND CODE_VALUE = LV_IN(10);
    IF LV_COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��Ʒ״̬����ȷ';
      RETURN;
    END IF;
    LV_STOCK_LIST.GOODS_STATE := LV_IN(10);
    IF LV_IN(16) = '0' THEN
      IF LV_IN(17) IS NULL OR LV_IN(18) IS NULL OR LV_IN(19) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '��ǰ��Ʒ���������ǹ�Ա����Ա��Ϣ����Ϊ��';
        RETURN;
      ELSE
        LV_STOCK_LIST.ORG_ID  := LV_IN(17);
        LV_STOCK_LIST.BRCH_ID := LV_IN(18);
        LV_STOCK_LIST.USER_ID := LV_IN(19);
      END IF;
    ELSIF LV_IN(16) = '1' THEN
      IF LV_IN(20) IS NULL OR LV_IN(21) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '��ǰ��Ʒ���������ǿͻ����ͻ���Ϣ����Ϊ��';
        RETURN;
      ELSE
        LV_STOCK_LIST.CUSTOMER_ID   := LV_IN(20);
        LV_STOCK_LIST.CUSTOMER_NAME := LV_IN(21);
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������ֻ����0��1';
      RETURN;
    END IF;
    LV_STOCK_LIST.OWN_TYPE := LV_IN(16);
    IF LV_IN(14) IS NULL THEN
      LV_STOCK_LIST.IN_BRCH_ID := LV_USERS.BRCH_ID;
    ELSE
      LV_STOCK_LIST.IN_BRCH_ID := LV_IN(14);
    END IF;
    IF LV_IN(15) IS NULL THEN
      LV_STOCK_LIST.IN_USER_ID := LV_USERS.USER_ID;
    ELSE
      LV_STOCK_LIST.IN_USER_ID := LV_IN(15);
    END IF;
    LV_STOCK_LIST.IN_DEAL_NO := LV_IN(4);
    IF LV_IN(13) <> '0' AND LV_IN(13) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ�Ƿ�ȷ�ϱ�־ֻ����0����1';
      RETURN;
    ELSE
      LV_STOCK_LIST.STK_IS_SURE := LV_IN(13);
    END IF;
    LV_STOCK_LIST.IN_DATE  := TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss');
    LV_STOCK_LIST.BATCH_ID := NVL(LV_IN(11), '');
    LV_STOCK_LIST.TASK_ID  := NVL(LV_IN(12), '');
    INSERT INTO STOCK_LIST VALUES LV_STOCK_LIST;
     if lv_in(16) = '0' then
           update stock_acc set tot_num = nvl(tot_num,0) + 1
           where brch_id = lv_stock_list.brch_id and user_id = lv_stock_list.user_id
           and stk_code = lv_stock_type.stk_code and goods_state = lv_stock_list.goods_state;
           if sql%rowcount <> 1 then
               av_res := pk_public.cs_res_unknownerr;
               av_msg := '���¿���˻�����ȷ';
               return;
           end if;
       end if;
    SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STOCK_REC.STK_SER_NO FROM DUAL;
    LV_STOCK_REC.DEAL_CODE   := LV_IN(5);
    LV_STOCK_REC.STK_CODE    := LV_STOCK_LIST.STK_CODE;
    LV_STOCK_REC.BATCH_ID    := LV_IN(11);
    LV_STOCK_REC.TASK_ID     := LV_IN(12);
    LV_STOCK_REC.GOODS_ID    := LV_STOCK_LIST.GOODS_ID;
    LV_STOCK_REC.GOODS_NO    := LV_STOCK_LIST.GOODS_NO;
    LV_STOCK_REC.GOODS_NUMS  := 1;
    LV_STOCK_REC.IN_OUT_FLAG := '0';
    LV_STOCK_REC.TR_DATE     := TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss');
    LV_STOCK_REC.ORG_ID      := LV_USERS.ORG_ID;
    LV_STOCK_REC.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_STOCK_REC.USER_ID     := LV_USERS.USER_ID;
    LV_STOCK_REC.BOOK_STATE  := '0';
    LV_STOCK_REC.CLR_DATE    := LV_CLR_DATE;
    LV_STOCK_REC.DEAL_NO     := LV_IN(4);
    LV_STOCK_REC.IS_SURE     := '0';
    LV_STOCK_REC.NOTE        := LV_IN(22);
    INSERT INTO STOCK_REC VALUES LV_STOCK_REC;
    SELECT SEQ_STK_INOUT_NO.NEXTVAL
      INTO LV_STOCK_INOUT_DETAIL.STK_INOUT_NO
      FROM DUAL;
    LV_STOCK_INOUT_DETAIL.STK_TYPE    := SUBSTR(LV_STOCK_REC.STK_CODE, 1, 1);
    LV_STOCK_INOUT_DETAIL.STK_CODE    := LV_STOCK_REC.STK_CODE;
    LV_STOCK_INOUT_DETAIL.ORG_ID      := LV_USERS.ORG_ID;
    LV_STOCK_INOUT_DETAIL.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_STOCK_INOUT_DETAIL.USER_ID     := LV_USERS.USER_ID;
    LV_STOCK_INOUT_DETAIL.DEAL_CODE   := LV_STOCK_REC.DEAL_CODE;
    LV_STOCK_INOUT_DETAIL.DEAL_DATE   := LV_STOCK_REC.TR_DATE;
    LV_STOCK_INOUT_DETAIL.BATCH_ID    := LV_STOCK_REC.BATCH_ID;
    LV_STOCK_INOUT_DETAIL.TASK_ID     := LV_STOCK_REC.TASK_ID;
    LV_STOCK_INOUT_DETAIL.GOODS_NO    := LV_STOCK_LIST.GOODS_NO;
    LV_STOCK_INOUT_DETAIL.TOT_NUM     := 1;
    LV_STOCK_INOUT_DETAIL.TOT_AMT     := 0;
    LV_STOCK_INOUT_DETAIL.IN_OUT_FLAG := '0';
    LV_STOCK_INOUT_DETAIL.BOOK_STATE  := '0';
    LV_STOCK_INOUT_DETAIL.CLR_DATE    := LV_STOCK_REC.CLR_DATE;
    LV_STOCK_INOUT_DETAIL.DEAL_NO     := LV_STOCK_REC.DEAL_NO;
    LV_STOCK_INOUT_DETAIL.NOTE        := LV_STOCK_REC.NOTE;
    LV_STOCK_INOUT_DETAIL.GOODS_ID    := LV_STOCK_REC.GOODS_ID;
    INSERT INTO STOCK_INOUT_DETAIL VALUES LV_STOCK_INOUT_DETAIL;
    AV_RES := pk_public.cs_res_ok;
    av_msg := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_OK;
      AV_MSG := SQLERRM;
  END P_IN_STOCK;
  --������
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7����Ʒ���Old_GOODS_NO
  --8����Ʒ���NEW_GOODS_NO
  --9�Ͽ�Ŀ����״̬ Ĭ�� 2 ����
  --10��עNOTE
  PROCEDURE P_BHK(AV_IN VARCHAR2, AV_RES OUT VARCHAR2, AV_MSG OUT VARCHAR2) IS
    LV_IN                PK_PUBLIC.MYARRAY;
    LV_CLR_DATE          PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_STOCK_LIST_OLD    STOCK_LIST%ROWTYPE;
    LV_CARD_BASEINFO_OLD CARD_BASEINFO%ROWTYPE;
    LV_STOCK_LIST_NEW    STOCK_LIST%ROWTYPE;
    LV_CARD_BASEINFO_NEW CARD_BASEINFO%ROWTYPE;
    LV_STOCK_REC         STOCK_REC%ROWTYPE;
    LV_STOCK_ACC_OUT     STOCK_ACC%ROWTYPE;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_USERS_OUT         SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG       BASE_CO_ORG%ROWTYPE;
    LV_STOCK_TYPE        STOCK_TYPE%ROWTYPE;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             7,
                             10,
                             'pk_card_stock.p_bhk',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),
                                      LV_IN(2),
                                      LV_IN(3),
                                      LV_USERS,
                                      LV_BASE_CO_ORG,
                                      AV_RES,
                                      AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '���״��벻�ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '����ʱ�䲻�ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL AND LV_IN(8) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�Ͽ��ź��¿��Ų��ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(8) IS NOT NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�ݲ�֧��';
      RETURN;
    END IF;
    IF LV_IN(9) IS NULL THEN
      LV_IN(9) := PK_CARD_STOCK.GOODS_STATE_ZLWT;
    END IF;
    PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_IN(7),
                                          LV_STOCK_LIST_OLD,
                                          AV_RES,
                                          AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_STOCK_LIST_OLD.GOODS_STATE <> PK_CARD_STOCK.GOODS_STATE_ZC THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�Ͽ������ϸ״̬������';
      RETURN;
    END IF;
    IF LV_STOCK_LIST_OLD.OWN_TYPE <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�Ͽ������ϸ�������Ͳ����ڿͻ�';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETCARDBASEINFO(LV_STOCK_LIST_OLD.GOODS_NO,
                                    LV_CARD_BASEINFO_OLD,
                                    AV_RES,
                                    AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_CARD_BASEINFO_OLD.CUSTOMER_ID <> LV_STOCK_LIST_OLD.CUSTOMER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�Ͽ������ϸ�����ͻ��Ϳ�Ƭ��Ϣ�����˲�һ��';
      RETURN;
    END IF;
    SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STOCK_REC.STK_SER_NO FROM DUAL;
    LV_STOCK_REC.DEAL_CODE      := LV_IN(5);
    LV_STOCK_REC.STK_CODE       := '1' || LV_CARD_BASEINFO_OLD.CARD_TYPE;
    LV_STOCK_REC.IN_ORG_ID      := LV_USERS.ORG_ID;
    LV_STOCK_REC.IN_BRCH_ID     := LV_USERS.BRCH_ID;
    LV_STOCK_REC.IN_USER_ID     := LV_USERS.USER_ID;
    LV_STOCK_REC.IN_GOODS_STATE := LV_IN(9);
    LV_STOCK_REC.BATCH_ID       := LV_STOCK_LIST_OLD.BATCH_ID;
    LV_STOCK_REC.TASK_ID        := LV_STOCK_LIST_OLD.TASK_ID;
    LV_STOCK_REC.GOODS_ID       := LV_STOCK_LIST_OLD.GOODS_ID;
    LV_STOCK_REC.GOODS_NO       := LV_STOCK_LIST_OLD.GOODS_NO;
    LV_STOCK_REC.GOODS_NUMS     := 1;
    LV_STOCK_REC.IN_OUT_FLAG    := '1';
    LV_STOCK_REC.TR_DATE        := TO_DATE(LV_IN(6),
                                           'yyyy-mm-dd hh24:mi:ss');
    LV_STOCK_REC.ORG_ID         := LV_USERS.ORG_ID;
    LV_STOCK_REC.BRCH_ID        := LV_USERS.BRCH_ID;
    LV_STOCK_REC.USER_ID        := LV_USERS.USER_ID;
    LV_STOCK_REC.BOOK_STATE     := '0';
    LV_STOCK_REC.CLR_DATE       := LV_CLR_DATE;
    LV_STOCK_REC.DEAL_NO        := LV_IN(4);
    LV_STOCK_REC.NOTE           := LV_IN(10);
    LV_STOCK_REC.IS_SURE        := '0';
    LV_STOCK_REC.START_NO       := LV_IN(7);
    LV_STOCK_REC.END_NO         := LV_IN(7);
    INSERT INTO STOCK_REC VALUES LV_STOCK_REC;
    INSERT INTO STOCK_INOUT_DETAIL T
      (T.STK_INOUT_NO,
       T.STK_TYPE,
       T.STK_CODE,
       T.IN_GOODS_STATE,
       T.OUT_GOODS_STATE,
       T.ORG_ID,
       T.BRCH_ID,
       T.USER_ID,
       T.AUTH_USER_ID,
       T.DEAL_CODE,
       T.DEAL_DATE,
       T.IN_ORG_ID,
       T.IN_BRCH_ID,
       T.IN_USER_ID,
       T.OUT_ORG_ID,
       T.OUT_BRCH_ID,
       T.OUT_USER_ID,
       T.BATCH_ID,
       T.TASK_ID,
       T.GOODS_NO,
       T.TOT_NUM,
       T.TOT_AMT,
       T.IN_OUT_FLAG,
       T.BOOK_STATE,
       T.CLR_DATE,
       T.DEAL_NO,
       T.NOTE,
       T.REV_DATE,
       T.GOODS_ID)
    VALUES
      (SEQ_STK_INOUT_NO.NEXTVAL,
       SUBSTR(LV_STOCK_LIST_OLD.STK_CODE, 1, 1),
       LV_STOCK_LIST_OLD.STK_CODE,
       LV_IN(9),
       NULL,
       LV_USERS.ORG_ID,
       LV_USERS.BRCH_ID,
       LV_USERS.USER_ID,
       NULL,
       LV_IN(5),
       LV_STOCK_REC.TR_DATE,
       LV_USERS.ORG_ID,
       LV_USERS.BRCH_ID,
       LV_USERS.USER_ID,
       NULL,
       NULL,
       NULL,
       LV_STOCK_LIST_OLD.BATCH_ID,
       LV_STOCK_LIST_OLD.TASK_ID,
       LV_STOCK_LIST_OLD.GOODS_NO,
       1,
       0,
       1,
       '0',
       LV_CLR_DATE,
       LV_STOCK_REC.DEAL_NO,
       LV_STOCK_REC.NOTE,
       NULL,
       LV_STOCK_LIST_OLD.GOODS_ID);
    UPDATE STOCK_LIST C
       SET C.GOODS_STATE   = LV_IN(9),
           C.OWN_TYPE      = '0',
           C.CUSTOMER_ID   = NULL,
           C.CUSTOMER_NAME = NULL,
           C.ORG_ID        = LV_USERS.ORG_ID,
           C.BRCH_ID       = LV_USERS.BRCH_ID,
           C.USER_ID       = LV_USERS.USER_ID,
           C.IN_BRCH_ID    = LV_USERS.BRCH_ID,
           C.IN_USER_ID    = LV_USERS.USER_ID,
           C.IN_DATE       = LV_STOCK_REC.TR_DATE,
           C.IN_DEAL_NO    = LV_STOCK_REC.DEAL_NO
     WHERE C.GOODS_NO = LV_STOCK_LIST_OLD.GOODS_NO
       AND C.GOODS_ID = LV_STOCK_LIST_OLD.GOODS_ID;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ������';
      RETURN;
    END IF;
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) + 1,
           LAST_DEAL_DATE = LV_STOCK_REC.TR_DATE
     WHERE BRCH_ID = LV_USERS.BRCH_ID
       AND USER_ID = LV_USERS.USER_ID
       AND STK_CODE = LV_STOCK_LIST_OLD.STK_CODE
       AND GOODS_STATE = LV_IN(9);
    IF SQL%ROWCOUNT <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��Ա����˻�������';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      GOTO NOT_NEW_CARD;
    END IF;
    PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_IN(8),
                                          LV_STOCK_LIST_NEW,
                                          AV_RES,
                                          AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      AV_MSG := '�¿������ϸ������,' || AV_MSG;
      RETURN;
    END IF;
    IF LV_STOCK_LIST_NEW.GOODS_STATE <> PK_CARD_STOCK.GOODS_STATE_ZC THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�¿������ϸ������';
      RETURN;
    END IF;
    IF LV_STOCK_LIST_NEW.OWN_TYPE <> '0' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�¿������ϸ�������Ͳ����ڹ�Ա';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_STOCK_LIST_NEW.STK_CODE,
                                  LV_STOCK_TYPE,
                                  AV_RES,
                                  AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF NVL(LV_STOCK_TYPE.OUT_FLAG, 0) = '0' AND
       LV_STOCK_LIST_NEW.USER_ID <> LV_USERS.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�¿������ϸ�����ڵ�ǰ��Ա';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST_NEW.BRCH_ID,
                                     LV_STOCK_LIST_NEW.USER_ID,
                                     LV_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_LIST_NEW.BRCH_ID,
                                 LV_STOCK_LIST_NEW.USER_ID,
                                 LV_STOCK_LIST_NEW.STK_CODE,
                                 PK_CARD_STOCK.GOODS_STATE_ZC,
                                 LV_STOCK_ACC_OUT,
                                 AV_RES,
                                 AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_STOCK_ACC_OUT.TOT_NUM < 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�¿���������˻�����';
      RETURN;
    END IF;
    SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STOCK_REC.STK_SER_NO FROM DUAL;
    LV_STOCK_REC.DEAL_CODE       := LV_IN(5);
    LV_STOCK_REC.STK_CODE        := LV_STOCK_LIST_NEW.STK_CODE;
    LV_STOCK_REC.OUT_ORG_ID      := LV_STOCK_LIST_NEW.BATCH_ID;
    LV_STOCK_REC.OUT_BRCH_ID     := LV_STOCK_LIST_NEW.BRCH_ID;
    LV_STOCK_REC.OUT_USER_ID     := LV_STOCK_LIST_NEW.USER_ID;
    LV_STOCK_REC.OUT_GOODS_STATE := LV_STOCK_LIST_NEW.GOODS_STATE;
    LV_STOCK_REC.BATCH_ID        := LV_STOCK_LIST_NEW.BATCH_ID;
    LV_STOCK_REC.TASK_ID         := LV_STOCK_LIST_NEW.TASK_ID;
    LV_STOCK_REC.GOODS_ID        := LV_STOCK_LIST_NEW.GOODS_ID;
    LV_STOCK_REC.GOODS_NO        := LV_STOCK_LIST_NEW.GOODS_NO;
    LV_STOCK_REC.GOODS_NUMS      := 1;
    LV_STOCK_REC.IN_OUT_FLAG     := '2';
    LV_STOCK_REC.TR_DATE         := TO_DATE(LV_IN(6),
                                            'YYYY-MM-DD HH24:MI:SS');
    LV_STOCK_REC.ORG_ID          := LV_USERS.ORG_ID;
    LV_STOCK_REC.BRCH_ID         := LV_USERS.BRCH_ID;
    LV_STOCK_REC.USER_ID         := LV_USERS.USER_ID;
    LV_STOCK_REC.BOOK_STATE      := '0';
    LV_STOCK_REC.CLR_DATE        := LV_CLR_DATE;
    LV_STOCK_REC.DEAL_NO         := LV_IN(4);
    LV_STOCK_REC.NOTE            := LV_IN(10);
    LV_STOCK_REC.IS_SURE         := '0';
    LV_STOCK_REC.START_NO        := LV_IN(8);
    LV_STOCK_REC.END_NO          := LV_IN(8);
    INSERT INTO STOCK_REC VALUES LV_STOCK_REC;
    INSERT INTO STOCK_INOUT_DETAIL T
      (T.STK_INOUT_NO,
       T.STK_TYPE,
       T.STK_CODE,
       T.IN_GOODS_STATE,
       T.OUT_GOODS_STATE,
       T.ORG_ID,
       T.BRCH_ID,
       T.USER_ID,
       T.AUTH_USER_ID,
       T.DEAL_CODE,
       T.DEAL_DATE,
       T.IN_ORG_ID,
       T.IN_BRCH_ID,
       T.IN_USER_ID,
       T.OUT_ORG_ID,
       T.OUT_BRCH_ID,
       T.OUT_USER_ID,
       T.BATCH_ID,
       T.TASK_ID,
       T.GOODS_NO,
       T.TOT_NUM,
       T.TOT_AMT,
       T.IN_OUT_FLAG,
       T.BOOK_STATE,
       T.CLR_DATE,
       T.DEAL_NO,
       T.NOTE,
       T.REV_DATE,
       T.GOODS_ID)
    VALUES
      (SEQ_STK_INOUT_NO.NEXTVAL,
       SUBSTR(LV_STOCK_LIST_NEW.STK_CODE, 1, 1),
       LV_STOCK_LIST_NEW.STK_CODE,
       NULL,
       LV_STOCK_LIST_NEW.GOODS_STATE,
       LV_USERS.ORG_ID,
       LV_USERS.BRCH_ID,
       LV_USERS.USER_ID,
       NULL,
       LV_IN(5),
       LV_STOCK_REC.TR_DATE,
       NULL,
       NULL,
       NULL,
       LV_USERS_OUT.ORG_ID,
       LV_USERS_OUT.BRCH_ID,
       LV_USERS_OUT.USER_ID,
       LV_STOCK_LIST_NEW.BATCH_ID,
       LV_STOCK_LIST_NEW.TASK_ID,
       LV_STOCK_LIST_NEW.GOODS_NO,
       1,
       0,
       2,
       '0',
       LV_CLR_DATE,
       LV_STOCK_REC.DEAL_NO,
       LV_STOCK_REC.NOTE,
       NULL,
       LV_STOCK_LIST_NEW.GOODS_ID);
    UPDATE STOCK_LIST C
       SET C.OWN_TYPE      = '1',
           C.CUSTOMER_ID  =
           (SELECT CUSTOMER_ID FROM CARD_BASEINFO WHERE CARD_NO = C.GOODS_NO),
           C.CUSTOMER_NAME =
           (SELECT MAX(NAME)
              FROM CARD_BASEINFO T1, BASE_PERSONAL T2
             WHERE T1.CUSTOMER_ID = T2.CUSTOMER_ID(+)
               AND T1.CARD_NO = C.GOODS_NO),
           C.ORG_ID        = NULL,
           C.BRCH_ID       = NULL,
           C.USER_ID       = NULL,
           C.OUT_BRCH_ID   = LV_USERS.BRCH_ID,
           C.OUT_USER_ID   = LV_USERS.USER_ID,
           C.OUT_DATE      = LV_STOCK_REC.TR_DATE,
           C.OUT_DEAL_NO   = LV_STOCK_REC.DEAL_NO
     WHERE C.GOODS_NO = LV_STOCK_LIST_NEW.GOODS_NO
       AND C.GOODS_ID = LV_STOCK_LIST_NEW.GOODS_ID;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����¿��Ŀ����ϸ����ȷ';
      RETURN;
    END IF;
    UPDATE STOCK_ACC V
       SET V.TOT_NUM        = NVL(V.TOT_NUM, 0) - 1,
           V.LAST_DEAL_DATE = LV_STOCK_REC.TR_DATE
     WHERE V.BRCH_ID = LV_USERS_OUT.BRCH_ID
       AND V.USER_ID = LV_USERS_OUT.USER_ID
       AND V.STK_CODE = LV_STOCK_LIST_NEW.STK_CODE
       AND V.GOODS_STATE = LV_STOCK_LIST_NEW.GOODS_STATE;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����¿��Ŀ���˻�����ȷ';
      RETURN;
    END IF;
    <<NOT_NEW_CARD>>
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_BHK;
  --�����յǼ�   �ջؿ�
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7��Ʒ���/����
  --8����Ŀ����״̬ Ĭ�� 1 ���մ�����
  --9��עNOTE
  PROCEDURE P_HSDJ(AV_IN  VARCHAR2,
                   AV_RES OUT VARCHAR2,
                   AV_MSG OUT VARCHAR2) IS
    LV_IN                PK_PUBLIC.MYARRAY;
    LV_CLR_DATE          PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_STOCK_LIST_OLD    STOCK_LIST%ROWTYPE;
    LV_CARD_BASEINFO_OLD CARD_BASEINFO%ROWTYPE;
    LV_STOCK_LIST_NEW    STOCK_LIST%ROWTYPE;
    LV_CARD_BASEINFO_NEW CARD_BASEINFO%ROWTYPE;
    LV_STOCK_REC         STOCK_REC%ROWTYPE;
    LV_STOCK_ACC_OUT     STOCK_ACC%ROWTYPE;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_USERS_OUT         SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG       BASE_CO_ORG%ROWTYPE;
    LV_STOCK_TYPE        STOCK_TYPE%ROWTYPE;
    LV_STOCK_LIST_SQL    VARCHAR2(2000) := '';
    LV_COUNT             NUMBER;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             7,
                             9,
                             'pk_card_stock.p_hsdj',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),
                                      LV_IN(2),
                                      LV_IN(3),
                                      LV_USERS,
                                      LV_BASE_CO_ORG,
                                      AV_RES,
                                      AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '���״��벻�ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '����ʱ�䲻�ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '���յĿ��Ų���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      --lv_in(8) := pk_card_stock.goods_state_hs;
      NULL;
    END IF;
    PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_IN(7),
                                          LV_STOCK_LIST_OLD,
                                          AV_RES,
                                          AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      LV_IN(8) := LV_STOCK_LIST_OLD.GOODS_STATE;
    END IF;
    IF LV_STOCK_LIST_OLD.GOODS_STATE <> PK_CARD_STOCK.GOODS_STATE_ZC THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ״̬������';
      RETURN;
    END IF;
    IF LV_STOCK_LIST_OLD.OWN_TYPE <> '1' THEN
      PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST_OLD.BRCH_ID,
                                       LV_STOCK_LIST_OLD.USER_ID,
                                       LV_USERS_OUT,
                                       AV_RES,
                                       AV_MSG,
                                       '������Ա');
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      PK_CARD_STOCK.P_GETSTOCK_ACC(LV_USERS_OUT.BRCH_ID,
                                   LV_USERS_OUT.USER_ID,
                                   LV_STOCK_LIST_OLD.STK_CODE,
                                   LV_STOCK_LIST_OLD.GOODS_STATE,
                                   LV_STOCK_ACC_OUT,
                                   AV_RES,
                                   AV_MSG);
      IF LV_STOCK_ACC_OUT.TOT_NUM < 1 THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '��������˻�����';
        RETURN;
      END IF;
    END IF;
    /*pk_card_stock.p_getcardbaseinfo(lv_stock_list_old.goods_no,lv_card_baseinfo_old,av_res,av_msg);
    if av_res <> pk_public.cs_res_ok then
    return;
    end if;
    if lv_card_baseinfo_old.customer_id <> lv_stock_list_old.customer_id then
    av_res := pk_public.cs_res_paravalueerr;
    av_msg := '�Ͽ������ϸ�����ͻ��Ϳ�Ƭ��Ϣ�����˲�һ��';
    return;
    end if;*/
    SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STOCK_REC.STK_SER_NO FROM DUAL;
    LV_STOCK_REC.DEAL_CODE      := LV_IN(5);
    LV_STOCK_REC.STK_CODE       := '1' || LV_CARD_BASEINFO_OLD.CARD_TYPE;
    LV_STOCK_REC.IN_ORG_ID      := LV_USERS.ORG_ID;
    LV_STOCK_REC.IN_BRCH_ID     := LV_USERS.BRCH_ID;
    LV_STOCK_REC.IN_USER_ID     := LV_USERS.USER_ID;
    LV_STOCK_REC.IN_GOODS_STATE := LV_IN(8);
    LV_STOCK_REC.BATCH_ID       := LV_STOCK_LIST_OLD.BATCH_ID;
    LV_STOCK_REC.TASK_ID        := LV_STOCK_LIST_OLD.TASK_ID;
    LV_STOCK_REC.GOODS_ID       := LV_STOCK_LIST_OLD.GOODS_ID;
    LV_STOCK_REC.GOODS_NO       := LV_STOCK_LIST_OLD.GOODS_NO;
    LV_STOCK_REC.GOODS_NUMS     := 1;
    IF LV_USERS_OUT.USER_ID IS NOT NULL THEN
      LV_STOCK_REC.IN_OUT_FLAG := '3';
    ELSE
      LV_STOCK_REC.IN_OUT_FLAG := '1';
    END IF;
    LV_STOCK_REC.TR_DATE         := TO_DATE(LV_IN(6),
                                            'yyyy-mm-dd hh24:mi:ss');
    LV_STOCK_REC.ORG_ID          := LV_USERS.ORG_ID;
    LV_STOCK_REC.BRCH_ID         := LV_USERS.BRCH_ID;
    LV_STOCK_REC.USER_ID         := LV_USERS.USER_ID;
    LV_STOCK_REC.BOOK_STATE      := '0';
    LV_STOCK_REC.CLR_DATE        := LV_CLR_DATE;
    LV_STOCK_REC.DEAL_NO         := LV_IN(4);
    LV_STOCK_REC.NOTE            := LV_IN(9);
    LV_STOCK_REC.IS_SURE         := '0';
    LV_STOCK_REC.START_NO        := LV_IN(7);
    LV_STOCK_REC.END_NO          := LV_IN(7);
    LV_STOCK_REC.OUT_ORG_ID      := LV_USERS_OUT.ORG_ID;
    LV_STOCK_REC.OUT_BRCH_ID     := LV_USERS_OUT.BRCH_ID;
    LV_STOCK_REC.OUT_USER_ID     := LV_USERS_OUT.USER_ID;
    LV_STOCK_REC.OUT_GOODS_STATE := LV_STOCK_LIST_OLD.GOODS_STATE;
    INSERT INTO STOCK_REC VALUES LV_STOCK_REC;
    EXECUTE IMMEDIATE 'insert into stock_inout_detail (stk_inout_no,stk_type,stk_code,in_goods_state,out_goods_state,org_id,
brch_id,user_id,auth_user_id,deal_code,deal_date,in_org_id,in_brch_id,
in_user_id,out_org_id,out_brch_id,out_user_id,batch_id,task_id,goods_no,
goods_id,tot_num,tot_amt,in_out_flag,book_state,clr_date,deal_no,note,rev_date
)' || '(select seq_stk_inout_no.nextval,substr(' ||
                      LV_STOCK_LIST_OLD.STK_CODE ||
                      ',1,1),stk_code,:1,goods_state,:2,:3,:4,null,' ||
                      ':5,to_date(''' || LV_IN(6) ||
                      ''',''yyyy-mm-dd hh24:mi:ss''),:6,:7,:8,:9,:10,:11,batch_id,task_id,goods_no,goods_id,''1'',' ||
                      '''0'',:12,''0'',:13,:14,:15,null ' ||
                      'from stock_list where goods_no = : 16 ' || ')'
      USING LV_IN(8), LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_IN(5), LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_USERS_OUT.ORG_ID, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_STOCK_REC.IN_OUT_FLAG, LV_CLR_DATE, LV_IN(4), LV_IN(9), LV_STOCK_LIST_OLD.GOODS_NO;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��¼���������ˮ��Ϣ���ִ��󣬸��������ϸ����';
      RETURN;
    END IF;
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'update stock_list c set c.goods_state = :1,c.own_type = ''0'',c.customer_id = null,c.customer_name = null,';
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'c.org_id = :2,c.brch_id = :3,c.user_id = :4,';
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'c.in_brch_id = :5,c.in_user_id = :6,c.in_date = :7,c.in_deal_no = :8 ';
    IF LV_USERS_OUT.USER_ID IS NOT NULL THEN
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           ',c.out_brch_id = :9,c.out_user_id = :10,c.out_date = :11,c.out_deal_no = :12 ';
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           'where c.goods_no = :13 and c.goods_id = :14';
      EXECUTE IMMEDIATE LV_STOCK_LIST_SQL
        USING LV_IN(8), LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_STOCK_REC.TR_DATE, LV_STOCK_REC.DEAL_NO, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_STOCK_REC.TR_DATE, LV_STOCK_REC.DEAL_NO, LV_STOCK_LIST_OLD.GOODS_NO, LV_STOCK_LIST_OLD.GOODS_ID;
    ELSE
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           'where c.goods_no = :9 and c.goods_id = :10';
      EXECUTE IMMEDIATE LV_STOCK_LIST_SQL
        USING LV_IN(8), LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_STOCK_REC.TR_DATE, LV_STOCK_REC.DEAL_NO, LV_STOCK_LIST_OLD.GOODS_NO, LV_STOCK_LIST_OLD.GOODS_ID;
    END IF;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ������';
      RETURN;
    END IF;
    IF LV_USERS_OUT.USER_ID IS NOT NULL THEN
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) - 1,
             LAST_DEAL_DATE = LV_STOCK_REC.TR_DATE
       WHERE BRCH_ID = LV_USERS_OUT.BRCH_ID
         AND USER_ID = LV_USERS_OUT.USER_ID
         AND STK_CODE = LV_STOCK_LIST_OLD.STK_CODE
         AND GOODS_STATE = LV_STOCK_REC.OUT_GOODS_STATE
      RETURNING TOT_NUM INTO LV_COUNT;
      IF SQL%ROWCOUNT <> '1' THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '������Ա����˻�������';
        RETURN;
      END IF;
      IF LV_COUNT < 0 THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '������Ա����˻�����';
        RETURN;
      END IF;
    END IF;
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) + 1,
           LAST_DEAL_DATE = LV_STOCK_REC.TR_DATE
     WHERE BRCH_ID = LV_USERS.BRCH_ID
       AND USER_ID = LV_USERS.USER_ID
       AND STK_CODE = LV_STOCK_LIST_OLD.STK_CODE
       AND GOODS_STATE = LV_IN(8);
    IF SQL%ROWCOUNT <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�շ���Ա����˻�������';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_HSDJ;
  --��Ʒ����
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7��Ʒ���/����
  --8Ŀ����״̬ Ĭ�ϲ��޸�ԭ�����ϸ״̬ �������Ҫ�������ϸ�޸ĵ�ʲô״̬
  -- һ�㲻��Ҫ���룬�����粹��������ʱ��Ҫ����0 ��������Ϊ����������������ϸ��Ϊ��������״̬������ʱ��Ҫ�ظ�������״̬
  --9�Ƿ�У����������Ϣ  Ĭ���Ƿ񿨲���
  --10��עnote
  PROCEDURE P_OUT_STOCK(AV_IN  VARCHAR2,
                        AV_RES OUT VARCHAR2,
                        AV_MSG OUT VARCHAR2) IS
    LV_IN                PK_PUBLIC.MYARRAY;
    LV_CLR_DATE          PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_STOCK_LIST_OLD    STOCK_LIST%ROWTYPE;
    LV_CARD_BASEINFO_OLD CARD_BASEINFO%ROWTYPE;
    LV_STOCK_LIST_NEW    STOCK_LIST%ROWTYPE;
    LV_CARD_BASEINFO_NEW CARD_BASEINFO%ROWTYPE;
    LV_STOCK_REC         STOCK_REC%ROWTYPE;
    LV_STOCK_ACC_OUT     STOCK_ACC%ROWTYPE;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_USERS_OUT         SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG       BASE_CO_ORG%ROWTYPE;
    LV_STOCK_TYPE        STOCK_TYPE%ROWTYPE;
    LV_STOCK_LIST_SQL    VARCHAR2(2000) := '';
    LV_BASE_PERSONAL     BASE_PERSONAL%ROWTYPE;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             7,
                             10,
                             'pk_card_stock.p_out_stock',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),
                                      LV_IN(2),
                                      LV_IN(3),
                                      LV_USERS,
                                      LV_BASE_CO_ORG,
                                      AV_RES,
                                      AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '���״��벻�ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '����ʱ�䲻�ܶ�Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ʒ��Ų���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      LV_IN(8) := PK_CARD_STOCK.GOODS_STATE_ZC;
    END IF;
    IF LV_IN(9) IS NULL THEN
      LV_IN(9) := 0;
    END IF;
    IF LV_IN(9) NOT IN ('0', '1') THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�Ƿ�У�������˱�־ֻ����0��1';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_IN(7),
                                          LV_STOCK_LIST_OLD,
                                          AV_RES,
                                          AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_STOCK_LIST_OLD.OWN_TYPE <> '0' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ�������Ͳ����ڹ�û�в���Ȩ��';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_STOCK_LIST_OLD.STK_CODE,
                                  LV_STOCK_TYPE,
                                  AV_RES,
                                  AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF NVL(LV_STOCK_TYPE.OUT_FLAG, 0) = '0' AND
       LV_STOCK_LIST_OLD.USER_ID <> LV_USERS.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ�����ڵ�ǰ��Ա��û�в���Ȩ��';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST_OLD.BRCH_ID,
                                     LV_STOCK_LIST_OLD.USER_ID,
                                     LV_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_ACC(LV_USERS_OUT.BRCH_ID,
                                 LV_USERS_OUT.USER_ID,
                                 LV_STOCK_LIST_OLD.STK_CODE,
                                 LV_STOCK_LIST_OLD.GOODS_STATE,
                                 LV_STOCK_ACC_OUT,
                                 AV_RES,
                                 AV_MSG);
    IF LV_STOCK_ACC_OUT.TOT_NUM < 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '��������˻�����';
      RETURN;
    END IF;
    IF LV_IN(9) = '0' THEN
      PK_CARD_STOCK.P_GETCARDBASEINFO(LV_STOCK_LIST_OLD.GOODS_NO,
                                      LV_CARD_BASEINFO_OLD,
                                      AV_RES,
                                      AV_MSG);
      IF AV_RES = PK_PUBLIC.CS_RES_OK THEN
        IF LV_CARD_BASEINFO_OLD.CUSTOMER_ID IS NOT NULL THEN
          PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO_OLD.CUSTOMER_ID,
                                                             LV_BASE_PERSONAL,
                                                             AV_RES,
                                                             AV_MSG);
          IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
            RETURN;
          END IF;
        END IF;
      ELSE
        RETURN;
      END IF;
    END IF;
    SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STOCK_REC.STK_SER_NO FROM DUAL;
    LV_STOCK_REC.DEAL_CODE := LV_IN(5);
    LV_STOCK_REC.STK_CODE  := '1' || LV_CARD_BASEINFO_OLD.CARD_TYPE;
    /*lv_stock_rec.in_org_id       := lv_users.org_id;
    lv_stock_rec.in_brch_id      := lv_users.brch_id;
    lv_stock_rec.in_user_id      := lv_users.user_id;
    lv_stock_rec.in_goods_state  := lv_in(8);*/
    LV_STOCK_REC.BATCH_ID        := LV_STOCK_LIST_OLD.BATCH_ID;
    LV_STOCK_REC.TASK_ID         := LV_STOCK_LIST_OLD.TASK_ID;
    LV_STOCK_REC.GOODS_ID        := LV_STOCK_LIST_OLD.GOODS_ID;
    LV_STOCK_REC.GOODS_NO        := LV_STOCK_LIST_OLD.GOODS_NO;
    LV_STOCK_REC.GOODS_NUMS      := 1;
    LV_STOCK_REC.IN_OUT_FLAG     := '2';
    LV_STOCK_REC.TR_DATE         := TO_DATE(LV_IN(6),
                                            'yyyy-mm-dd hh24:mi:ss');
    LV_STOCK_REC.ORG_ID          := LV_USERS.ORG_ID;
    LV_STOCK_REC.BRCH_ID         := LV_USERS.BRCH_ID;
    LV_STOCK_REC.USER_ID         := LV_USERS.USER_ID;
    LV_STOCK_REC.BOOK_STATE      := '0';
    LV_STOCK_REC.CLR_DATE        := LV_CLR_DATE;
    LV_STOCK_REC.DEAL_NO         := LV_IN(4);
    LV_STOCK_REC.NOTE            := LV_IN(10);
    LV_STOCK_REC.IS_SURE         := '0';
    LV_STOCK_REC.START_NO        := LV_IN(7);
    LV_STOCK_REC.END_NO          := LV_IN(7);
    LV_STOCK_REC.OUT_ORG_ID      := LV_USERS_OUT.ORG_ID;
    LV_STOCK_REC.OUT_BRCH_ID     := LV_USERS_OUT.BRCH_ID;
    LV_STOCK_REC.OUT_USER_ID     := LV_USERS_OUT.USER_ID;
    LV_STOCK_REC.OUT_GOODS_STATE := LV_STOCK_LIST_OLD.GOODS_STATE;
    INSERT INTO STOCK_REC VALUES LV_STOCK_REC;
    EXECUTE IMMEDIATE 'insert into stock_inout_detail (stk_inout_no,stk_type,stk_code,in_goods_state,out_goods_state,org_id,
brch_id,user_id,auth_user_id,deal_code,deal_date,in_org_id,in_brch_id,
in_user_id,out_org_id,out_brch_id,out_user_id,batch_id,task_id,goods_no,
goods_id,tot_num,tot_amt,in_out_flag,book_state,clr_date,deal_no,note,rev_date
)' || '(select seq_stk_inout_no.nextval,substr(' ||
                      LV_STOCK_LIST_OLD.STK_CODE ||
                      ',1,1),stk_code,null,:1,:2,:3,:4,null,' ||
                      ':5,to_date(''' || LV_IN(6) ||
                      ''',''yyyy-mm-dd hh24:mi:ss''),null,null,null,:6,:7,:8,batch_id,task_id,goods_no,goods_id,''1'',' ||
                      '''0'',''2'',''0'',:12,:13,:14,null ' ||
                      'from stock_list where goods_no = : 15 ' || ')'
      USING LV_STOCK_LIST_OLD.GOODS_STATE, LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_IN(5), LV_USERS_OUT.ORG_ID, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_CLR_DATE, LV_IN(4), LV_IN(10), LV_STOCK_LIST_OLD.GOODS_NO;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��¼���������ˮ��Ϣ���ִ��󣬸��������ϸ����';
      RETURN;
    END IF;
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'update stock_list c set c.goods_state = :1,c.own_type = ''1'',c.customer_id = :2,c.customer_name = :3,';
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'c.org_id = null,c.brch_id = null,c.user_id = null,';
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'c.out_brch_id = :4,c.out_user_id = :5,c.out_date = :6,c.out_deal_no = :7 ';
    LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                         'where c.goods_no = :8 and c.goods_id = :9';
    EXECUTE IMMEDIATE LV_STOCK_LIST_SQL
      USING LV_IN(8), LV_BASE_PERSONAL.CUSTOMER_ID, LV_BASE_PERSONAL.NAME, LV_USERS_OUT.BRCH_ID, LV_USERS_OUT.USER_ID, LV_STOCK_REC.TR_DATE, LV_STOCK_REC.DEAL_NO, LV_STOCK_LIST_OLD.GOODS_NO, LV_STOCK_LIST_OLD.GOODS_ID;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�����ϸ������';
      RETURN;
    END IF;
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) - 1,
           LAST_DEAL_DATE = LV_STOCK_REC.TR_DATE
     WHERE BRCH_ID = LV_USERS_OUT.BRCH_ID
       AND USER_ID = LV_USERS_OUT.USER_ID
       AND STK_CODE = LV_STOCK_LIST_OLD.STK_CODE
       AND GOODS_STATE = LV_STOCK_REC.OUT_GOODS_STATE;
    IF SQL%ROWCOUNT <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ա����˻�������';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_OUT_STOCK;
  --��Ա����
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״���
  --6����ʱ��
  --7������
  --8����Ա
  --9������
  --10�չ�Ա
  --11�������
  --12���״̬
  --13��ע
  PROCEDURE P_TELLER_JJ(AV_IN  VARCHAR2,
                        AV_RES OUT VARCHAR2,
                        AV_MSG OUT VARCHAR2) IS
    LV_IN PK_PUBLIC.MYARRAY;
    TYPE TEMP_T_TYPE IS TABLE OF STOCK_ACC%ROWTYPE INDEX BY BINARY_INTEGER;
    LV_CUR            TEMP_T_TYPE;
    LV_CLR_DATE       PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_USERS          SYS_USERS%ROWTYPE;
    LV_SYS_USERS_IN   SYS_USERS%ROWTYPE;
    LV_SYS_USERS_OUT  SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG    BASE_CO_ORG%ROWTYPE;
    LV_STOCK_TYPE     STOCK_TYPE%ROWTYPE;
    LV_STOCK_ACC_SQL  VARCHAR2(1000) := '';
    LV_TIP_STR        VARCHAR2(200);
    LV_STOCK_LIST_SQL VARCHAR2(2000);
    LV_STOCK_REC      STOCK_REC%ROWTYPE;
    FUNCTION F_GET_GOODS_STATE_NAME(AV_GOODS_STATE VARCHAR2) RETURN VARCHAR2 IS
      LV_TEMP_CODEVALUE VARCHAR2(50);
    BEGIN
      SELECT CODE_NAME
        INTO LV_TEMP_CODEVALUE
        FROM SYS_CODE
       WHERE CODE_TYPE = 'GOODS_STATE'
         AND CODE_VALUE = AV_GOODS_STATE;
      RETURN LV_TEMP_CODEVALUE;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '';
    END F_GET_GOODS_STATE_NAME;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             11,
                             13,
                             'pk_card_stock.p_teller_jj',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(11) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ͳ���Ϊ��';
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),
                                      LV_IN(2),
                                      LV_IN(3),
                                      LV_USERS,
                                      LV_BASE_CO_ORG,
                                      AV_RES,
                                      AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(7),
                                     LV_IN(8),
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '������Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(9),
                                     LV_IN(10),
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '�շ���Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�շ���Ա״̬������';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ա���շ���Ա������ͬһ��Ա';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.ORG_ID <> LV_SYS_USERS_IN.ORG_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������ͬһ������Ա֮����в���';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_IN(11), LV_STOCK_TYPE, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_STOCK_ACC_SQL := LV_STOCK_ACC_SQL ||
                        'select * from stock_acc where brch_id = ''' ||
                        LV_SYS_USERS_OUT.BRCH_ID || ''' ';
    LV_STOCK_ACC_SQL := LV_STOCK_ACC_SQL || 'and user_id = ''' ||
                        LV_SYS_USERS_OUT.USER_ID || ''' and stk_code = ''' ||
                        LV_STOCK_TYPE.STK_CODE || ''' ';
    IF LV_IN(12) IS NOT NULL THEN
      LV_STOCK_ACC_SQL := LV_STOCK_ACC_SQL || ' and goods_state = ''' ||
                          LV_IN(12) || '''';
    END IF;
    EXECUTE IMMEDIATE LV_STOCK_ACC_SQL BULK COLLECT
      INTO LV_CUR;
    IF LV_CUR.COUNT < 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '������Ա�����ڿ���˻�';
      RETURN;
    END IF;
    FOR TEMP_ACC_INDEX IN LV_CUR.FIRST .. LV_CUR.LAST LOOP
      LV_STOCK_LIST_SQL := '';
      LV_STOCK_ACC_SQL  := '';
      LV_TIP_STR        := '';
      LV_TIP_STR        := '��' || LV_STOCK_TYPE.STK_NAME || '-' ||
                           F_GET_GOODS_STATE_NAME(LV_CUR(TEMP_ACC_INDEX)
                                                  .GOODS_STATE) || '��';
      SELECT SEQ_STK_SER_NO.NEXTVAL INTO LV_STOCK_REC.STK_SER_NO FROM DUAL;
      LV_STOCK_REC.DEAL_CODE       := LV_IN(5);
      LV_STOCK_REC.STK_CODE        := LV_STOCK_TYPE.STK_CODE;
      LV_STOCK_REC.IN_ORG_ID       := LV_SYS_USERS_IN.ORG_ID;
      LV_STOCK_REC.IN_BRCH_ID      := LV_SYS_USERS_IN.BRCH_ID;
      LV_STOCK_REC.IN_USER_ID      := LV_SYS_USERS_IN.USER_ID;
      LV_STOCK_REC.IN_GOODS_STATE  := LV_CUR(TEMP_ACC_INDEX).GOODS_STATE;
      LV_STOCK_REC.GOODS_NUMS      := LV_CUR(TEMP_ACC_INDEX).TOT_NUM;
      LV_STOCK_REC.IN_OUT_FLAG     := '3';
      LV_STOCK_REC.TR_DATE         := TO_DATE(LV_IN(6),
                                              'yyyy-mm-dd hh24:mi:ss');
      LV_STOCK_REC.ORG_ID          := LV_USERS.ORG_ID;
      LV_STOCK_REC.BRCH_ID         := LV_USERS.BRCH_ID;
      LV_STOCK_REC.USER_ID         := LV_USERS.USER_ID;
      LV_STOCK_REC.BOOK_STATE      := '0';
      LV_STOCK_REC.CLR_DATE        := LV_CLR_DATE;
      LV_STOCK_REC.DEAL_NO         := LV_IN(4);
      LV_STOCK_REC.NOTE            := LV_IN(13);
      LV_STOCK_REC.IS_SURE         := '0';
      LV_STOCK_REC.OUT_ORG_ID      := LV_SYS_USERS_OUT.ORG_ID;
      LV_STOCK_REC.OUT_BRCH_ID     := LV_SYS_USERS_OUT.BRCH_ID;
      LV_STOCK_REC.OUT_USER_ID     := LV_SYS_USERS_OUT.USER_ID;
      LV_STOCK_REC.OUT_GOODS_STATE := LV_STOCK_REC.IN_GOODS_STATE;
      EXECUTE IMMEDIATE 'insert into stock_inout_detail (stk_inout_no,stk_type,stk_code,in_goods_state,out_goods_state,org_id,
brch_id,user_id,auth_user_id,deal_code,deal_date,in_org_id,in_brch_id,
in_user_id,out_org_id,out_brch_id,out_user_id,batch_id,task_id,goods_no,
goods_id,tot_num,tot_amt,in_out_flag,book_state,clr_date,deal_no,note,rev_date
)' || '(select seq_stk_inout_no.nextval,substr(' ||
                        LV_STOCK_TYPE.STK_CODE ||
                        ',1,1),stk_code,goods_state,goods_state,:1,:2,:3,null,' ||
                        ':4,to_date(''' || LV_IN(6) ||
                        ''',''yyyy-mm-dd hh24:mi:ss''),:5,:6,:7,:8,:9,:10,batch_id,task_id,goods_no,goods_id,''1'',' ||
                        '''0'',''3'',''0'',:11,:12,:13,null ' ||
                        'from stock_list where own_type = ''0'' and org_id = :15 and brch_id = :16 and user_id = :17 ' || ')'
        USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_IN(5), LV_SYS_USERS_IN.ORG_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_SYS_USERS_OUT.ORG_ID, LV_SYS_USERS_OUT.BRCH_ID, LV_SYS_USERS_OUT.USER_ID, LV_CLR_DATE, LV_IN(4), LV_IN(13), LV_SYS_USERS_OUT.ORG_ID, LV_SYS_USERS_OUT.BRCH_ID, LV_SYS_USERS_OUT.USER_ID;
      LV_STOCK_REC.GOODS_NUMS := SQL%ROWCOUNT;
      INSERT INTO STOCK_REC VALUES LV_STOCK_REC;
      IF LV_STOCK_REC.GOODS_NUMS = 0 THEN
        GOTO NEXT_LOOP;
      END IF;
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           'update stock_list c set c.org_id = :1,c.brch_id = :2,c.user_id = :3, ';
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           'c.in_brch_id = :4,c.in_user_id = :5,c.in_date = :6,c.in_deal_no = :7, ';
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           'c.out_brch_id = :8,c.out_user_id = :9,c.out_date = :10,c.out_deal_no = :11 ';
      LV_STOCK_LIST_SQL := LV_STOCK_LIST_SQL ||
                           'where own_type = ''0'' and org_id = :12 and brch_id = :13 and user_id = :14';
      EXECUTE IMMEDIATE LV_STOCK_LIST_SQL
        USING LV_SYS_USERS_IN.ORG_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_SYS_USERS_IN.BRCH_ID, LV_SYS_USERS_IN.USER_ID, LV_STOCK_REC.TR_DATE, LV_STOCK_REC.DEAL_NO, LV_SYS_USERS_OUT.BRCH_ID, LV_SYS_USERS_OUT.USER_ID, LV_STOCK_REC.TR_DATE, LV_STOCK_REC.DEAL_NO, LV_SYS_USERS_OUT.ORG_ID, LV_SYS_USERS_OUT.BRCH_ID, LV_SYS_USERS_OUT.USER_ID;
      IF SQL%ROWCOUNT <> LV_STOCK_REC.GOODS_NUMS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '����' || LV_TIP_STR || '����˻������Ϳ����ϸ������һ��';
        RETURN;
      END IF;
      UPDATE STOCK_ACC
         SET TOT_NUM        = 0,
             TOT_FACE_VAL   = 0,
             LAST_DEAL_DATE = LV_STOCK_REC.TR_DATE
       WHERE BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
         AND USER_ID = LV_SYS_USERS_OUT.USER_ID
         AND STK_CODE = LV_STOCK_REC.STK_CODE
         AND GOODS_STATE = LV_STOCK_REC.OUT_GOODS_STATE;
      IF SQL%ROWCOUNT <> '1' THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '���¸�������˻�����ȷ';
        RETURN;
      END IF;
      UPDATE STOCK_ACC
         SET TOT_NUM      = NVL(TOT_NUM, 0) + LV_STOCK_REC.GOODS_NUMS,
             TOT_FACE_VAL = NVL(TOT_FACE_VAL, 0) + LV_CUR(TEMP_ACC_INDEX)
                           .TOT_FACE_VAL
       WHERE BRCH_ID = LV_SYS_USERS_IN.BRCH_ID
         AND USER_ID = LV_SYS_USERS_IN.USER_ID
         AND STK_CODE = LV_STOCK_TYPE.STK_CODE
         AND GOODS_STATE = LV_CUR(TEMP_ACC_INDEX).GOODS_STATE;
      LV_TIP_STR := '��' || LV_STOCK_TYPE.STK_NAME || '-' ||
                    F_GET_GOODS_STATE_NAME(LV_CUR(TEMP_ACC_INDEX)
                                           .GOODS_STATE) || '��';
      IF SQL%ROWCOUNT <> 1 THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '�շ���Ա������' || LV_TIP_STR || '�˻�';
        RETURN;
      END IF;
      <<NEXT_LOOP>>
      NULL;
    END LOOP;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_TELLER_JJ;
  --������Ʒ��Ż�ȡ��Ʒ��Ϣ
  --av_goods_no ��Ʒ���
  --av_stock_list ��Ʒ��Ϣ
  --av_res ����������
  --av_res ������˵��
  PROCEDURE P_GETSTOCKLISTBYGOODSNO(AV_GOODS_NO   STOCK_LIST.GOODS_NO%TYPE,
                                    AV_STOCK_LIST OUT STOCK_LIST%ROWTYPE,
                                    AV_RES        OUT VARCHAR2,
                                    AV_MSG        OUT VARCHAR2) IS
  BEGIN
    SELECT *
      INTO AV_STOCK_LIST
      FROM STOCK_LIST
     WHERE GOODS_NO = AV_GOODS_NO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '������Ʒ���' || AV_GOODS_NO || 'δ�ҵ������ϸ��Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '������Ʒ���' || AV_GOODS_NO || '��ȡ�����ϸ��Ϣ���ִ���' || SQLERRM;
  END P_GETSTOCKLISTBYGOODSNO;
  --���ݿ��Ż�ȡ����Ϣ
  --av_goods_no ��Ʒ���
  --av_stock_list ��Ʒ��Ϣ
  --av_res ����������
  --av_res ������˵��
  PROCEDURE P_GETCARDBASEINFO(AV_CARD_NO       CARD_BASEINFO.CARD_NO%TYPE,
                              AV_CARD_BASEINFO OUT CARD_BASEINFO%ROWTYPE,
                              AV_RES           OUT VARCHAR2,
                              AV_MSG           OUT VARCHAR2) IS
  BEGIN
    SELECT *
      INTO AV_CARD_BASEINFO
      FROM CARD_BASEINFO
     WHERE CARD_NO = AV_CARD_NO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݿ���' || AV_CARD_NO || 'δ�ҵ���Ƭ��Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݿ���' || AV_CARD_NO || '��ȡ��Ƭ��Ϣ���ִ���' || SQLERRM;
  END P_GETCARDBASEINFO;
  --���������Ż�ȡ������Ϣ
  --av_task_id ������
  --av_card_apply_task ������Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_GETCARDAPPLYTASKBYTASKID(AV_TASK_ID         CARD_APPLY_TASK.TASK_ID%TYPE,
                                       AV_CARD_APPLY_TASK OUT CARD_APPLY_TASK%ROWTYPE,
                                       AV_RES             OUT VARCHAR2,
                                       AV_MSG             OUT VARCHAR2) IS
  BEGIN
    SELECT *
      INTO AV_CARD_APPLY_TASK
      FROM CARD_APPLY_TASK
     WHERE TASK_ID = AV_TASK_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '����������' || AV_TASK_ID || '�Ҳ���������Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '����������' || AV_TASK_ID || '��ȡ������Ϣ���ִ���' || SQLERRM;
      RETURN;
  END;
  --���ݹ�Ա��š�������͡���Ʒ״̬��ȡ����˻�
  --av_stk_code ������
  --av_stk_goods_state��Ʒ״̬
  --av_stock_acc ����˻���Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_GETSTOCK_ACC(AV_BRCH_ID         VARCHAR2,
                           AV_USER_ID         VARCHAR2, --��Աuser_id
                           AV_STK_CODE        VARCHAR2, --������
                           AV_STK_GOODS_STATE VARCHAR2, --��Ʒ״̬
                           AV_STOCK_ACC       OUT STOCK_ACC%ROWTYPE,
                           AV_RES             OUT VARCHAR2, --���ش���
                           AV_MSG             OUT VARCHAR2) --������Ϣ
   IS
    --
  BEGIN
    SELECT *
      INTO AV_STOCK_ACC
      FROM STOCK_ACC
     WHERE USER_ID = AV_USER_ID
       AND STK_CODE = AV_STK_CODE
       AND GOODS_STATE = AV_STK_GOODS_STATE;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_ACCNOTEXIT;
      AV_MSG := '���ݹ�Ա���' || AV_USER_ID || '��������' || AV_STK_CODE || '����Ʒ״̬' ||
                AV_STK_GOODS_STATE || '��δ�ҵ���Ӧ����˻���Ϣ';
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݹ�Ա���' || AV_USER_ID || '��������' || AV_STK_CODE || '����Ʒ״̬' ||
                AV_STK_GOODS_STATE || '����ȡ����˻����ִ���' || SQLERRM;
  END P_GETSTOCK_ACC;
  --��ȡ�������ȡ���������Ϣ
  --lv_stk_code ������
  --lv_stock_type ���������Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_GETSTOCK_TYPE(LV_STK_CODE   STOCK_TYPE.STK_CODE%TYPE,
                            LV_STOCK_TYPE OUT STOCK_TYPE%ROWTYPE,
                            AV_RES        OUT VARCHAR2,
                            AV_MSG        OUT VARCHAR2) IS
  BEGIN
    IF LV_STK_CODE IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ȡ���������Ϣ��������ͱ��벻��Ϊ��';
      RETURN;
    END IF;
    SELECT *
      INTO LV_STOCK_TYPE
      FROM STOCK_TYPE
     WHERE STK_CODE = LV_STK_CODE;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݿ�����ͱ���' || LV_STK_CODE || '�Ҳ������������Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݿ�����ͱ���' || LV_STK_CODE || '��ȡ���������Ϣ���ִ���' || SQLERRM;
  END;
  --���������ţ���Ա��Ż�ȡ��Ա��Ϣ
  --av_brch_id ������
  --av_user_id ��Ա���
  --av_users   ��Ա��Ϣ
  --av_res     ���������
  --av_msg     ������˵��
  --av_init_msg��ʼ����Ϣ
  PROCEDURE P_GETUSERSBYUSERID(AV_BRCH_ID  VARCHAR2, -- ��������
                               AV_USER_ID  VARCHAR2, --��Ա���
                               AV_USERS    OUT SYS_USERS%ROWTYPE,
                               AV_RES      OUT VARCHAR2, --���������
                               AV_MSG      OUT VARCHAR2, --������˵��
                               AV_INIT_MSG VARCHAR --��ʼ�����
                               ) IS
    LV_MSG VARCHAR2(500) := '��Ա��Ϣ';
  BEGIN
    IF NVL(AV_INIT_MSG, '001') <> '001' THEN
      LV_MSG := AV_INIT_MSG;
    END IF;
    SELECT *
      INTO AV_USERS
      FROM SYS_USERS
     WHERE BRCH_ID = AV_BRCH_ID
       AND USER_ID = AV_USER_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_OPERATORERR;
      AV_MSG := '����������' || AV_BRCH_ID || '��Ա���' || AV_USER_ID || 'δ�ҵ�' ||
                LV_MSG;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_OPERATORERR;
      AV_MSG := '����������' || AV_BRCH_ID || '��Ա���' || AV_USER_ID || '��ȡ' ||
                LV_MSG || '���ִ���' || SQLERRM;
  END P_GETUSERSBYUSERID;
  --�жϿ����Ƿ���ͬ��һ�������ҺŶ��Ƿ�����
  --av_user_id ������Ա
  --av_begin_goods_no ��ʼ����
  --av_end_goods_no ��ֹ����
  --av_card_apply_task ��������
  --av_res ����������
  --av_msg ������˵��
  FUNCTION F_JUDGECARDRANGE(AV_USER_ID         STOCK_LIST.USER_ID%TYPE,
                            AV_BEGIN_GOODS_NO  STOCK_LIST.GOODS_NO%TYPE,
                            AV_END_GOODS_NO    STOCK_LIST.GOODS_NO%TYPE,
                            AV_CARD_APPLY_TASK OUT CARD_APPLY_TASK%ROWTYPE,
                            AV_RES             OUT VARCHAR2,
                            AV_MSG             OUT VARCHAR) RETURN NUMBER IS
    LV_COUNT    NUMBER;
    LV_CARD_NOS PK_PUBLIC.MYARRAY;
    LV_USER_ID  STOCK_LIST.USER_ID%TYPE;
    LV_TASK_ID  CARD_APPLY_TASK.TASK_ID%TYPE;
  BEGIN
    --1.���������ж�
    IF AV_BEGIN_GOODS_NO IS NULL OR AV_END_GOODS_NO IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�жϿ��Ŷ���ֹ���Ų���Ϊ��';
      RETURN - 1;
    END IF;
    IF SUBSTR(AV_BEGIN_GOODS_NO, 9, 8) > SUBSTR(AV_END_GOODS_NO, 9, 8) THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ʼ���Ų��ܴ��ڽ�ֹ����';
      RETURN - 1;
    END IF;
    IF SUBSTR(AV_BEGIN_GOODS_NO, 1, 9) <> SUBSTR(AV_END_GOODS_NO, 1, 9) THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ֹ���Ų�����ͬһ���������ͬһ�ֿ������';
      RETURN - 1;
    END IF;
    --2.�жϿ����Ƿ���ͬһ������,ͬһ���������
    SELECT COUNT(1)
      INTO LV_COUNT
      FROM (SELECT TASK_ID, COUNT(1)
              FROM STOCK_LIST
             WHERE GOODS_NO >= AV_BEGIN_GOODS_NO
               AND GOODS_NO <= AV_END_GOODS_NO
               AND STK_IS_SURE = '0'
               AND OWN_TYPE = '0'
             GROUP BY TASK_ID, STK_CODE);
    IF LV_COUNT = 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�ںŶ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                '֮���Ҳ�����Ч�Ŀ����ϸ��Ϣ�򿨶β����ڹ�Ա';
      RETURN - 1;
    END IF;
    IF LV_COUNT > 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�Ŷ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                '���ڶ����ͬ������,���ǲ�ͬ�ֿ������';
      RETURN - 1;
    END IF;
    --3.�жϿ��η���������Ա
    SELECT COUNT(1)
      INTO LV_COUNT
      FROM (SELECT USER_ID, COUNT(1)
              FROM STOCK_LIST
             WHERE GOODS_NO >= AV_BEGIN_GOODS_NO
               AND GOODS_NO <= AV_END_GOODS_NO
               AND STK_IS_SURE = '0'
               AND OWN_TYPE = '0'
             GROUP BY USER_ID);
    IF LV_COUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�Ŷ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                '���ڶ����ͬ�Ĺ�Ա';
      RETURN - 1;
    END IF;
    --4.��ȡ���������Ĺ�Ա��������
    BEGIN
      SELECT USER_ID, TASK_ID
        INTO LV_USER_ID, LV_TASK_ID
        FROM STOCK_LIST
       WHERE GOODS_NO >= AV_BEGIN_GOODS_NO
         AND GOODS_NO <= AV_END_GOODS_NO
         AND STK_IS_SURE = '0'
         AND OWN_TYPE = '0'
       GROUP BY USER_ID, TASK_ID;
      IF LV_USER_ID <> AV_USER_ID THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�Ŷ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '�����ڹ�Ա' || AV_USER_ID;
        RETURN - 1;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�Ҳ����Ŷ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '������Ա����������Ϣ';
        RETURN - 1;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��ȡ�Ŷ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '������Ա����������Ϣʱ��������' || SQLERRM;
        RETURN - 1;
    END;
    --5�Ŷ�����������Ϣ
    BEGIN
      SELECT *
        INTO AV_CARD_APPLY_TASK
        FROM CARD_APPLY_TASK
       WHERE TASK_ID = LV_TASK_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '���ݺŶ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '����������' || LV_TASK_ID || '�Ҳ���������Ϣ';
        RETURN - 1;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '���ݺŶ�' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '����������' || LV_TASK_ID || '��ȡ������Ϣ��������' || SQLERRM;
        RETURN - 1;
    END;
    --6.�жϿ���������
    SELECT GOODS_NO BULK COLLECT
      INTO LV_CARD_NOS
      FROM STOCK_LIST
     WHERE GOODS_NO >= AV_BEGIN_GOODS_NO
       AND GOODS_NO <= AV_END_GOODS_NO;
    IF LV_CARD_NOS(1) <> AV_BEGIN_GOODS_NO THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ʼ���Ų�����';
      RETURN - 1;
    END IF;
    IF LV_CARD_NOS(LV_CARD_NOS.LAST) <> AV_END_GOODS_NO THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ֹ���Ų�����';
      RETURN - 1;
    END IF;
    FOR LV_CARD_NO_INDEX IN LV_CARD_NOS.FIRST .. (LV_CARD_NOS.LAST - 1) LOOP
      IF (SUBSTR(LV_CARD_NOS(LV_CARD_NO_INDEX), 9, 8) + 1) <>
         SUBSTR(LV_CARD_NOS(LV_CARD_NO_INDEX + 1), 9, 8) THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '�Ŷ���' || LV_CARD_NOS(LV_CARD_NO_INDEX) || '������������һ������' ||
                  LV_CARD_NOS(LV_CARD_NO_INDEX + 1);
        RETURN - 1;
      END IF;
    END LOOP;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
    RETURN LV_CARD_NOS.COUNT;
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
      RETURN - 1;
  END F_JUDGECARDRANGE;
  --�ƿ����ݵ���
  --av_in
  --1acpt_id�������
  --2acpt_type���������
  --3user_id����Ա
  --4deal_no������ˮ
  --5dr_batch_id��������
  --������
  --av_res ����������
  --av_msg ����������
  --av_out �������
  PROCEDURE PK_IMPORT_CARDDATA(AV_IN  VARCHAR2,
                               AV_RES OUT VARCHAR2,
                               AV_MSG OUT VARCHAR2,
                               AV_OUT OUT VARCHAR2) IS
    LV_IN              PK_PUBLIC.MYARRAY;
    LV_USERS           SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG     BASE_CO_ORG%ROWTYPE;
    LV_PAYCLRPARA      PAY_CLR_PARA%ROWTYPE;
    LV_TASK_IDS        PK_PUBLIC.MYARRAY;
    LV_CARD_APPLY_TASK CARD_APPLY_TASK%ROWTYPE;
    LV_COUNT           NUMBER;
    LV_SYS_ACTION_LOG  SYS_ACTION_LOG%ROWTYPE;
    LV_TR_SERV_REC     TR_SERV_REC%ROWTYPE;
    LV_CITY_CODE       CARD_BASEINFO.CITY_CODE%TYPE;
    LV_DR_COUNT        TR_SERV_REC.NUM%TYPE := 0;
  BEGIN
    --1.��������
    SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             4,
                             5,
                             'pk_card_Stock.pk_Import_CardData',
                             LV_IN,
                             AV_RES,
                             AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�������ݵ���ʱ���κŲ���Ϊ��';
      RETURN;
    END IF;
    LV_CITY_CODE := PK_PUBLIC.F_GETSYSPARA('CITY_CODE');
    IF LV_CITY_CODE = '0' OR LV_CITY_CODE = '-1' THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���д������ò���ȷ';
      RETURN;
    END IF;
    --2.������ж�
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),
                                      LV_IN(2),
                                      LV_IN(3),
                                      LV_USERS,
                                      LV_BASE_CO_ORG,
                                      AV_RES,
                                      AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    SELECT TASK_ID BULK COLLECT
      INTO LV_TASK_IDS
      FROM CARD_TASK_IMP_TMP
     WHERE DR_BATCH_ID = LV_IN(5)
     GROUP BY TASK_ID;
    IF LV_TASK_IDS.COUNT < 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݵ������ݵ���ʱ���κ��Ҳ���������Ϣ';
      RETURN;
    END IF;
    LV_CITY_CODE := PK_PUBLIC.F_GETSYSPARA('CITY_CODE');
    IF LV_CITY_CODE IN ('0', '-1') THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���д������ò���ȷ';
      RETURN;
    END IF;
    --3.������־
    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYS_ACTION_LOG.DEAL_NO FROM DUAL;
    LV_SYS_ACTION_LOG.DEAL_CODE   := '10502060';
    LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
    LV_SYS_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
    LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYS_ACTION_LOG.MESSAGE     := 'ʵ���ƿ���������';
    LV_SYS_ACTION_LOG.CAN_ROLL    := '1';
    LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
    LV_SYS_ACTION_LOG.LOG_TYPE    := '0';
    LV_SYS_ACTION_LOG.ROLL_FLAG   := '1';
    LV_SYS_ACTION_LOG.NOTE        := LV_SYS_ACTION_LOG.MESSAGE;
    INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
    --4.��������ֱ����
    FOR TASK_INDEX IN LV_TASK_IDS.FIRST .. LV_TASK_IDS.LAST LOOP
      SELECT *
        INTO LV_CARD_APPLY_TASK
        FROM CARD_APPLY_TASK
       WHERE TASK_ID = LV_TASK_IDS(TASK_INDEX);
      IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_ZKZ THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '������Ϊ��' + LV_TASK_IDS(TASK_INDEX) ||
                  '���������ƿ�����״̬��Ϊ���ƿ��С�';
        RETURN;
      END IF;
      SELECT COUNT(1)
        INTO LV_COUNT
        FROM CARD_TASK_IMP_TMP
       WHERE TASK_ID = LV_TASK_IDS(TASK_INDEX)
         AND DR_BATCH_ID = LV_IN(5);
      IF LV_COUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '������Ϊ��' + LV_TASK_IDS(TASK_INDEX) ||
                  '��������ʵ���ƿ���ϸ������������������һ��';
        RETURN;
      END IF;
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
         CUSTOMER_ID,
         CUSTOMER_NAME,
         NOTE,
         IN_BRCH_ID,
         OUT_BRCH_ID)
        SELECT '1' || LV_CARD_APPLY_TASK.CARD_TYPE,
               T.CARD_ID,
               T.CARD_NO,
               '0',
               T.BATCH_ID,
               T.TASK_ID,
               '0',
               LV_SYS_ACTION_LOG.DEAL_TIME,
               T.USER_ID,
               LV_SYS_ACTION_LOG.DEAL_NO,
               NULL,
               NULL,
               NULL,
               '0',
               LV_USERS.ORG_ID,
               LV_USERS.BRCH_ID,
               LV_USERS.USER_ID,
               NULL,
               NULL,
               'ʵ���ƿ���������',
               LV_USERS.BRCH_ID,
               NULL
          FROM CARD_TASK_IMP_TMP T
         WHERE T.DR_BATCH_ID = LV_IN(5)
           AND T.TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
      IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '������Ϊ��' + LV_TASK_IDS(TASK_INDEX) ||
                  '��������ʵ���������������������һ��';
        RETURN;
      END IF;
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
        (SELECT A.RFATR,
                A.CARD_NO,
                L.CUSTOMER_ID,
                L.CARD_TYPE,
                '1001',
                L.VERSION,
                L.INIT_ORG_ID,
                LV_CITY_CODE,
                L.INDUS_CODE,
                L.CARDISSUEDATE,
                L.CARDISSUEDATE,
                L.VALIDITYDATE,
                L.BURSEVALIDDATE,
                NULL,
                NULL,
                0,
                NULL,
                0,
                '0',
                LV_SYS_ACTION_LOG.DEAL_TIME,
                C.COST_FEE,
                0,
                0,
                0,
                A.CARD_ID,
                C.SUB_CARD_NO,
                NULL,
                C.BANK_ID,
                A.BANKCARDNO,
                C.BAR_CODE,
                NULL,
                NULL,
                'ʵ���ƿ���������',
                NULL,
                A.ATR,
                A.RFATR,
                NULL,
                '0',
                NULL,
                L.STRUCT_MAIN_TYPE,
                '01',
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                '0'
           FROM CARD_TASK_IMP_TMP A, CARD_TASK_LIST L, CARD_APPLY C
          WHERE A.TASK_ID = L.TASK_ID
            AND A.DATA_SEQ = L.DATA_SEQ
            AND L.APPLY_ID = C.APPLY_ID
            AND L.TASK_ID = C.TASK_ID
            AND A.TASK_ID = LV_CARD_APPLY_TASK.TASK_ID
            AND A.DR_BATCH_ID = LV_IN(5));
      IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '������Ϊ��' + LV_TASK_IDS(TASK_INDEX) ||
                  '���������뿨��Ϣ�������������һ��';
        RETURN;
      END IF;
      UPDATE CARD_APPLY A
         SET A.APPLY_STATE  = PK_PUBLIC.KG_CARD_APPLY_YZK,
             A.BANK_CARD_NO =
             (SELECT B.BANKCARDNO
                FROM CARD_TASK_IMP_TMP B
               WHERE B.TASK_ID = A.TASK_ID
                 AND B.CUSTOMER_ID = A.CUSTOMER_ID
                 AND B.CARD_NO = A.CARD_NO)
       WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
      IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '������Ϊ��' + LV_TASK_IDS(TASK_INDEX) ||
                  '�������񣬸�������������������������һ��';
        RETURN;
      END IF;
      IF LV_CARD_APPLY_TASK.CARD_TYPE = '120' THEN
        INSERT INTO CARD_BIND_BANKCARD
          (CUSTOMER_ID,
           NAME,
           CERT_NO,
           SUB_CARD_NO,
           BANK_ID,
           BANK_CARD_NO,
           BANK_CARD_TYPE,
           STATE,
           MOBILE_NUM,
           REGION_ID,
           CITY_ID,
           TOWN_ID,
           ADDRESS,
           USER_ID,
           BRCH_ID,
           BANK_ORG,
           ACTIVATE_DATE,
           MODIFY_DATE,
           LINE_NO,
           SUB_CARD_ID,
           BIND_DATE,
           COMM_ID,
           CARD_NO)
          SELECT L.CUSTOMER_ID,
                 L.NAME,
                 L.CERT_NO,
                 Y.SUB_CARD_NO,
                 Y.BANK_ID,
                 C.BANKCARDNO,
                 '',
                 '1',
                 L.MOBILE_NO,
                 '',
                 Y.CITY_CODE,
                 Y.TOWN_ID,
                 '',
                 LV_USERS.USER_ID,
                 LV_USERS.BRCH_ID,
                 '',
                 LV_SYS_ACTION_LOG.DEAL_TIME,
                 NULL,
                 '',
                 Y.SUB_CARD_NO,
                 LV_SYS_ACTION_LOG.DEAL_TIME,
                 Y.COMM_ID,
                 C.CARD_NO
            FROM CARD_TASK_IMP_TMP C, CARD_TASK_LIST L, CARD_APPLY Y
           WHERE C.TASK_ID = L.TASK_ID
             AND C.DATA_SEQ = L.DATA_SEQ
             AND L.TASK_ID = Y.BUY_PLAN_ID
             AND L.APPLY_ID = Y.APPLY_ID
             AND C.DR_BATCH_ID = LV_IN(5);
        IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '������Ϊ��' + LV_TASK_IDS(TASK_INDEX) ||
                    '�������������п�����Ϣ�������������һ��';
          RETURN;
        END IF;
      END IF;
      UPDATE CARD_APPLY_TASK
         SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_YZK
       WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
      EXECUTE IMMEDIATE 'INSERT INTO STOCK_REC(STK_SER_NO,DEAL_CODE,STK_CODE,BATCH_ID,TASK_ID,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,IN_GOODS_STATE,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,OUT_GOODS_STATE,
GOODS_ID,GOODS_NO,GOODS_NUMS,IN_OUT_FLAG,TR_DATE,ORG_ID,BRCH_ID,USER_ID,AUTH_OPER_ID,
BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,IS_SURE,START_NO,END_NO
)VALUES(SEQ_STK_SER_NO.NEXTVAL,:1,:2,:3,:4,:5,:6,:7,:8,NULL,NULL,NULL,NULL,NULL,NULL,:9,''1'',' ||
                        ':10,' || LV_USERS.ORG_ID || ',' ||
                        LV_USERS.BRCH_ID || ',''' || LV_USERS.USER_ID ||
                        ''',NULL,' || '''0'',:11,:12,:13,''0'',:14,:15) '
        USING LV_SYS_ACTION_LOG.DEAL_CODE, '1' || LV_CARD_APPLY_TASK.CARD_TYPE, LV_CARD_APPLY_TASK.MAKE_BATCH_ID, LV_CARD_APPLY_TASK.TASK_ID, LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, '0', LV_CARD_APPLY_TASK.YH_NUM, LV_SYS_ACTION_LOG.DEAL_TIME, LV_PAYCLRPARA.CLR_DATE, LV_SYS_ACTION_LOG.DEAL_NO, LV_SYS_ACTION_LOG.MESSAGE, LV_CARD_APPLY_TASK.START_CARD_NO, LV_CARD_APPLY_TASK.END_CARD_NO;
      IF SQL%ROWCOUNT <> 1 THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��¼��������־���ִ���-' || SQL%ROWCOUNT || '��';
        RETURN;
      END IF;
      EXECUTE IMMEDIATE 'INSERT INTO STOCK_INOUT_DETAIL (STK_INOUT_NO,STK_TYPE,STK_CODE,IN_GOODS_STATE,OUT_GOODS_STATE,ORG_ID,
BRCH_ID,USER_ID,AUTH_USER_ID,DEAL_CODE,DEAL_DATE,IN_ORG_ID,IN_BRCH_ID,
IN_USER_ID,OUT_ORG_ID,OUT_BRCH_ID,OUT_USER_ID,BATCH_ID,TASK_ID,GOODS_NO,
GOODS_ID,TOT_NUM,TOT_AMT,IN_OUT_FLAG,BOOK_STATE,CLR_DATE,DEAL_NO,NOTE,REV_DATE
)' ||
                        '(SELECT SEQ_STK_INOUT_NO.NEXTVAL,''1'',STK_CODE,''0'',NULL,:1,:2,:3,NULL,' ||
                        ':4,:5,:6,:7,:8,NULL,NULL,NULL,BATCH_ID,TASK_ID,GOODS_NO,GOODS_ID,:9,' ||
                        '''0'',''1'',''0'',:10,:11,:12,NULL ' ||
                        'FROM STOCK_LIST WHERE STK_IS_SURE = ''0'' AND OWN_TYPE = ''0'' AND GOODS_STATE = ''0'' AND ' ||
                        'ORG_ID = ''' || LV_USERS.ORG_ID ||
                        ''' AND BRCH_ID = ''' || LV_USERS.BRCH_ID ||
                        ''' AND USER_ID = ''' || LV_USERS.USER_ID ||
                        ''' AND STK_CODE = ''1' ||
                        LV_CARD_APPLY_TASK.CARD_TYPE ||
                        ''' and TASK_ID = ''' || LV_CARD_APPLY_TASK.TASK_ID || '''' || ')'
        USING LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_SYS_ACTION_LOG.DEAL_CODE, LV_SYS_ACTION_LOG.DEAL_TIME, LV_USERS.ORG_ID, LV_USERS.BRCH_ID, LV_USERS.USER_ID, LV_CARD_APPLY_TASK.YH_NUM, LV_PAYCLRPARA.CLR_DATE, LV_SYS_ACTION_LOG.DEAL_NO, LV_SYS_ACTION_LOG.MESSAGE;
      IF SQL%ROWCOUNT < LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��¼���������ˮ��Ϣ���ִ����������С���ƿ���ϸ������һ��';
        RETURN;
      END IF;
      IF SQL%ROWCOUNT <> LV_COUNT THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '��¼��������ˮ��Ϣ���ִ������¼' || LV_COUNT || '����ʵ�ʼ�¼' ||
                  SQL%ROWCOUNT || '��';
        RETURN;
      END IF;
      LV_DR_COUNT := LV_DR_COUNT + LV_CARD_APPLY_TASK.YH_NUM;
    END LOOP;
    LV_TR_SERV_REC.DEAL_NO   := LV_SYS_ACTION_LOG.DEAL_NO;
    LV_TR_SERV_REC.DEAL_CODE := LV_SYS_ACTION_LOG.DEAL_CODE;
    --LV_TR_SERV_REC.CARD_TYPE  := '100';
    LV_TR_SERV_REC.BIZ_TIME   := LV_SYS_ACTION_LOG.DEAL_TIME;
    LV_TR_SERV_REC.BRCH_ID    := LV_SYS_ACTION_LOG.BRCH_ID;
    LV_TR_SERV_REC.USER_ID    := LV_SYS_ACTION_LOG.USER_ID;
    LV_TR_SERV_REC.CLR_DATE   := LV_PAYCLRPARA.CLR_DATE;
    LV_TR_SERV_REC.ORG_ID     := LV_SYS_ACTION_LOG.ORG_ID;
    LV_TR_SERV_REC.NOTE       := LV_SYS_ACTION_LOG.MESSAGE;
    LV_TR_SERV_REC.NUM        := LV_DR_COUNT;
    LV_TR_SERV_REC.AMT        := 0;
    LV_TR_SERV_REC.DEAL_STATE := '0';
    INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
    AV_OUT := LV_SYS_ACTION_LOG.DEAL_NO;
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END PK_IMPORT_CARDDATA;
  --�������
  PROCEDURE P_UPDATECARDSTOCK(P_CARDNO  IN VARCHAR2, --�¿���
                              P_CARDNO2 IN VARCHAR2, --�Ͽ���
                              P_DEALNO  IN INTEGER, --������ˮ��
                              AS_OUTMSG OUT VARCHAR2, --�������
                              AS_RES    OUT VARCHAR2 ----��������
                              ) IS
    AS_CARD      CARD_BASEINFO%ROWTYPE; --�¿���Ϣ
    AS_CARD2     CARD_BASEINFO%ROWTYPE; --�Ͽ���Ϣ
    AS_ACTIONLOG SYS_ACTION_LOG%ROWTYPE; --��־
    AS_SYSUSERS  SYS_USERS%ROWTYPE; --����Ա
    AS_STOCKTYPE STOCK_TYPE%ROWTYPE; --�������
    AS_STOCKREC  STOCK_REC%ROWTYPE; --���ҵ��
    AS_STOCKACC  STOCK_ACC%ROWTYPE; --����˻�
    --as_StockList  Stock_List%rowtype; --�����ϸ
    AS_CARDCONFIG CARD_CONFIG%ROWTYPE; --��������Ϣ��
    ROWNCOUNT     INTEGER;
    ROWNCOUNT1    INTEGER;
    AS_CLR_DATE   VARCHAR2(10);
  BEGIN
    IF P_CARDNO IS NULL AND P_CARDNO2 IS NULL THEN
      AS_OUTMSG := '�¿��ź��Ͽ��Ų��ܶ�Ϊ��';
      AS_RES    := PK_PUBLIC.CS_RES_OK;
      RETURN;
    END IF;
    SELECT P.CLR_DATE INTO AS_CLR_DATE FROM PAY_CLR_PARA P; --�������
    SELECT * INTO AS_CARD FROM CARD_BASEINFO T WHERE T.CARD_NO = P_CARDNO; --�¿���
    SELECT *
      INTO AS_CARD2
      FROM CARD_BASEINFO TT
     WHERE TT.CARD_NO = P_CARDNO2; --�Ͽ���
    ------ϵͳ��־-------
    SELECT *
      INTO AS_ACTIONLOG
      FROM SYS_ACTION_LOG L
     WHERE L.DEAL_NO = P_DEALNO; --ϵͳ��־
    SELECT *
      INTO AS_SYSUSERS
      FROM SYS_USERS O
     WHERE O.USER_ID = AS_ACTIONLOG.USER_ID; --����Ա
    SELECT *
      INTO AS_CARDCONFIG
      FROM CARD_CONFIG T
     WHERE T.CARD_TYPE = AS_CARD.CARD_TYPE; --���ݿ������ҵ���صĿ���Ϣ
    SELECT *
      INTO AS_STOCKTYPE
      FROM STOCK_TYPE ST
     WHERE ST.STK_CODE = AS_CARDCONFIG.STK_CODE; --�������
    AS_STOCKREC.DEAL_NO   := P_DEALNO; --//ҵ����ˮ��
    AS_STOCKREC.DEAL_CODE := AS_ACTIONLOG.DEAL_CODE; --//���״���
    AS_STOCKREC.STK_CODE  := AS_STOCKTYPE.STK_CODE; --//������
    -- as_StockRec.Stk_Type  := as_StockType.Stk_Type; --//�������
    AS_STOCKREC.GOODS_NUMS := 1;
    SELECT COUNT(*)
      INTO ROWNCOUNT
      FROM CARD_BASEINFO C
     WHERE C.CARD_NO = P_CARDNO2; --�Ͽ�����Ϣ
    IF ROWNCOUNT > 0 THEN
      AS_STOCKREC.IN_GOODS_STATE := '2'; --//�շ���Ʒ״̬
      AS_STOCKREC.IN_USER_ID     := AS_SYSUSERS.USER_ID; --�շ���Ա���
      AS_STOCKREC.IN_BRCH_ID     := AS_SYSUSERS.BRCH_ID; --//�շ�������
      AS_STOCKREC.IN_ORG_ID      := AS_SYSUSERS.ORG_ID; --//�շ��������
      AS_STOCKREC.IN_OUT_FLAG    := '1'; --//�ո���־-��
      AS_STOCKREC.START_NO       := P_CARDNO2; --����
      AS_STOCKREC.END_NO         := P_CARDNO2;
    END IF;
    SELECT COUNT(*)
      INTO ROWNCOUNT1
      FROM CARD_BASEINFO C
     WHERE C.CARD_NO = P_CARDNO; --�¿�����Ϣ
    IF ROWNCOUNT > 0 THEN
      AS_STOCKREC.GOODS_NUMS      := 2;
      AS_STOCKREC.OUT_GOODS_STATE := '0'; --//�շ���Ʒ״̬
      AS_STOCKREC.OUT_USER_ID     := AS_SYSUSERS.USER_ID; --�շ���Ա���
      AS_STOCKREC.OUT_BRCH_ID     := AS_SYSUSERS.BRCH_ID; --//�շ�������
      AS_STOCKREC.OUT_ORG_ID      := AS_SYSUSERS.ORG_ID; --//�շ��������
      AS_STOCKREC.IN_OUT_FLAG     := '2'; --//�ո���־-��
    END IF;
    IF ROWNCOUNT1 > 0 AND ROWNCOUNT > 0 THEN
      AS_STOCKREC.IN_OUT_FLAG := '3'; --//�ո���־-�ո�
      AS_STOCKREC.GOODS_NUMS  := 2;
    END IF;
    AS_STOCKREC.GOODS_NUMS := 0; --//���
    AS_STOCKREC.TR_DATE    := AS_ACTIONLOG.DEAL_TIME; --//����ʱ��
    AS_STOCKREC.USER_ID    := AS_SYSUSERS.USER_ID; --��Ա���
    AS_STOCKREC.BRCH_ID    := AS_SYSUSERS.BRCH_ID; --//��Ա������
    AS_STOCKREC.ORG_ID     := AS_SYSUSERS.ORG_ID; --//��Ա�������
    AS_STOCKREC.BOOK_STATE := '0'; --//ҵ��״̬-����
    AS_STOCKREC.CLR_DATE   := AS_CLR_DATE; --//�������
    AS_STOCKREC.IS_SURE    := '1'; --//�������״̬��Ĭ��Ϊδȷ��
    INSERT INTO STOCK_REC VALUES AS_STOCKREC; --����
    ---------------�Ͽ�����Ϣ--------------------
    SELECT COUNT(*)
      INTO ROWNCOUNT
      FROM CARD_BASEINFO C
     WHERE C.CARD_NO = P_CARDNO2;
    IF ROWNCOUNT > 0 THEN
      SELECT COUNT(*)
        INTO ROWNCOUNT
        FROM STOCK_LIST S
       WHERE S.GOODS_STATE = '0'
         AND S.OWN_TYPE = '1'
         AND S.STK_CODE = AS_STOCKREC.STK_CODE
         AND S.GOODS_NO = P_CARDNO2;
      IF ROWNCOUNT = 0 THEN
        AS_RES    := PK_PUBLIC.CS_RES_DBERR;
        AS_OUTMSG := '���ֻ��˲�����';
        RETURN;
      END IF;
      --���¿����ϸ
      UPDATE STOCK_LIST S
         SET S.OWN_TYPE  = '0',
             S.USER_ID   = AS_SYSUSERS.USER_ID,
             S.BRCH_ID   = AS_SYSUSERS.BRCH_ID,
             S.ORG_ID    = AS_SYSUSERS.ORG_ID,
             GOODS_STATE = AS_STOCKREC.IN_GOODS_STATE
       WHERE S.GOODS_STATE = '0'
         AND S.OWN_TYPE = '1'
         AND S.STK_CODE = AS_STOCKREC.STK_CODE
         AND S.GOODS_NO = P_CARDNO2;
      --���¿�ֻ���
      UPDATE STOCK_ACC CC
         SET TOT_NUM          =
             (TOT_NUM + 1),
             CC.LAST_DEAL_DATE = SYSDATE
       WHERE CC.USER_ID = AS_SYSUSERS.USER_ID
         AND CC.STK_CODE = AS_STOCKREC.STK_CODE
         AND CC.GOODS_STATE = AS_STOCKREC.IN_GOODS_STATE;
    END IF;
    ---------------�¿�����Ϣ--------------------
    SELECT COUNT(*)
      INTO ROWNCOUNT
      FROM CARD_BASEINFO C
     WHERE C.CARD_NO = P_CARDNO;
    IF ROWNCOUNT > 0 THEN
      SELECT COUNT(*)
        INTO ROWNCOUNT
        FROM STOCK_LIST SS
       WHERE SS.GOODS_STATE = '0'
         AND SS.OWN_TYPE = '1'
         AND SS.STK_CODE = AS_STOCKREC.STK_CODE
         AND SS.GOODS_NO = P_CARDNO;
      IF ROWNCOUNT = 0 THEN
        AS_RES    := PK_PUBLIC.CS_RES_DBERR;
        AS_OUTMSG := '�����ϸ������';
        RETURN;
      END IF;
      --���¿����ϸ
      UPDATE STOCK_LIST S
         SET S.OWN_TYPE  = '0',
             S.USER_ID   = AS_SYSUSERS.USER_ID,
             S.BRCH_ID   = AS_SYSUSERS.BRCH_ID,
             S.ORG_ID    = AS_SYSUSERS.ORG_ID,
             GOODS_STATE = AS_STOCKREC.IN_GOODS_STATE
       WHERE S.GOODS_STATE = '0'
         AND S.OWN_TYPE = '1'
         AND S.STK_CODE = AS_STOCKREC.STK_CODE
         AND S.GOODS_NO = P_CARDNO;
      ---�¿��Ŀ���˻�
      SELECT COUNT(*)
        INTO ROWNCOUNT
        FROM STOCK_ACC S
       WHERE S.STK_CODE = AS_STOCKREC.STK_CODE
         AND S.GOODS_STATE = '0'
         AND S.USER_ID = AS_STOCKREC.USER_ID; --�����˻�
      IF ROWNCOUNT = 0 THEN
        AS_RES    := PK_PUBLIC.CS_RES_DBERR;
        AS_OUTMSG := '���ֻ��˲�����';
        RETURN;
      END IF;
      ----�¿��Ŀ���˻�(ʵ�����)
      SELECT *
        INTO AS_STOCKACC
        FROM STOCK_ACC SA
       WHERE SA.STK_CODE = AS_STOCKREC.STK_CODE
         AND SA.GOODS_STATE = '0'
         AND SA.USER_ID = AS_STOCKREC.USER_ID; --�����˻�
      IF AS_STOCKACC.TOT_NUM < 1 THEN
        AS_RES    := PK_PUBLIC.CS_RES_KC1;
        AS_OUTMSG := '�����������';
        RETURN;
      END IF;
      --�����¿��Ŀ���˻�
      UPDATE STOCK_ACC L
         SET TOT_NUM       =
             (TOT_NUM - 1),
             LAST_DEAL_DATE = SYSDATE ---to_date(sysdate, 'yyyy-MM-dd HH24:mi:ss')
       WHERE USER_ID = AS_SYSUSERS.USER_ID
         AND L.STK_CODE = AS_STOCKREC.STK_CODE
         AND L.GOODS_STATE = '0';
    END IF;
    --commit;
  EXCEPTION
    WHEN OTHERS THEN
      AS_RES    := PK_PUBLIC.CS_RES_KC2;
      AS_OUTMSG := 'ϵͳ����';
      ROLLBACK;
      RAISE_APPLICATION_ERROR('-20001', SQLERRM);
  END P_UPDATECARDSTOCK;
END PK_CARD_STOCK;
/

