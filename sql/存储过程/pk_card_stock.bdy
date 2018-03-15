CREATE OR REPLACE PACKAGE BODY PK_CARD_STOCK AS
  --柜员库存账户开户
  --参数说明：
  --1受理点编号/网点编号 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 必填
  --4终端操作流水 选填
  --5待开户柜员所属网点 必填
  --6待开户柜员编号 必填
  --7开户库存类型 选填 空值时,所有的库存类型都将分别建账户
  --8开户库存类型状态 选填 空值时,一个库存类型的所有状态都建账户
  --9备注
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
      AV_MSG := '受理点类型不能为空！';
      RETURN;
    END IF;
    IF LV_IN(1) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '受理点编号不能为空！';
      RETURN;
    END IF;
    IF LV_IN(3) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '操作员或是终端编号不能为空！';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存账户开户柜员所属网点不能为空！';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      --av_res := pk_public.cs_res_paravalueerr;
      --av_msg := '库存账户开户柜员编号不能为空！';
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
      AV_MSG := '未找到需要开户的柜员信息';
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
      AV_MSG := '未找到需要开户的库存类型';
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
      AV_MSG := '未找到库存账户状态参数信息';
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
  --库存物品配送
  --参数说明：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7库存类型 stk_code 必填
  --8出网点out_brch_id 必填
  --9出柜员out_user_id 必填
  --10出物品状态out_goods_state  必填
  --11收网点in_brch_id 必填
  --12收柜员in_user_id 必填
  --13收物品状态in_goods_state  必填
  --14库存交换方式 deliveryWay = 1时按照任务，deliveryWay = 2时按照卡号段 当为"1"时 15必填 当为"2"时 16、17必填
  --15任务编号 taskIds
  --16起始物品号码 begin_googds_no
  --17结束物品号码 end_goods_no
  --18物品数量总数量 必填
  --19note备注
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
    --1.基本参数判断
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
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    --2.操作员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '操作员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.付方柜员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(8),
                                     LV_IN(9),
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '付方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --4.收方柜员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(11),
                                     LV_IN(12),
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '收方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '收方柜员状态不正常';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '付方柜员和收方柜员不能是同一个柜员';
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.ORG_ID <> LV_SYS_USERS_OUT.ORG_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存配送必须在同一机构柜员之间进行配送';
      RETURN;
    END IF;
    --5.根据库存交换类型，判断必填参数
    IF LV_IN(14) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存配送方式不能为空！';
      RETURN;
    ELSIF LV_IN(14) = '1' THEN
      IF LV_IN(15) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '库存配送方式已选择按照任务方式，任务编号不能为空';
        RETURN;
      ELSE
        LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(15), ',', LV_TASK_IDS);
        IF LV_COUNT <= 0 THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '库存配送方式已选择按照任务方式，任务编号不能为空';
          RETURN;
        END IF;
      END IF;
    ELSIF LV_IN(14) = '2' THEN
      IF LV_IN(16) IS NULL OR LV_IN(17) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '库存配送方式已选择按照卡段，起止卡号不能为空';
        RETURN;
      ELSE
        LV_LIMIT_SQL := ' GOODS_NO BETWEEN ' || LV_IN(16) || ' AND ' ||
                        LV_IN(17) || ' ';
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '选择的库存配送方式不正确';
      RETURN;
    END IF;
    --6.循环处理每一个配送任务
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
            AV_MSG := '根据任务编号' || LV_TASK_IDS(LV_ROW_INDEX) || '找不到任务信息';
            RETURN;
          WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '根据任务编号' || LV_TASK_IDS(LV_ROW_INDEX) ||
                      '获取任务信息发生错误信息' || SQLERRM;
            RETURN;
        END;
        IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YZK THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '选择的任务编号【' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '】不为【已制卡】状态,库存配送必须是【已制卡】状态的任务';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.CARD_TYPE = PK_PUBLIC.CARD_TYPE_SMZK THEN
          IF LV_CARD_APPLY_TASK.BRCH_ID <> LV_SYS_USERS_IN.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '任务编号【' || LV_TASK_IDS(LV_ROW_INDEX) ||
                      '】的所属网点和配送接收网点不是同一网点，配送到该网点可能导致无法进行发放';
            RETURN;
          END IF;
        END IF;
        LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE; --注意：此处库存类型的生成规则
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
          AV_MSG := '选择的任务编号【' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '】的库存明细数量和任务数量不一致,或库存明细不在当前柜员名下';
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
          AV_MSG := '获取付方库存账户发生错误,' || AV_MSG;
          RETURN;
        END IF;
        IF LV_STOCK_ACC_OUT.TOT_NUM < LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '付方库存账户不足';
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
          AV_MSG := '获取收方库存账户发生错误,' || AV_MSG;
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
          AV_MSG := '记录库存出入库流水信息出现错误，出库数量小于制卡明细数量不一致';
          RETURN;
        END IF;
        IF SQL%ROWCOUNT <> LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '记录库存入库流水信息出现错误待记录' || LV_COUNT || '条，实际记录' ||
                    SQL%ROWCOUNT || '条';
          RETURN;
        END IF;
        --将付方库存物品明细更新为收方的
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
          AV_MSG := '选择任务编号' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '付方库存明细物品数量与任务数量不一致，无法进行配送';
          RETURN;
        END IF;
        --12更新申领记录和任务状态到已配送
        EXECUTE IMMEDIATE 'UPDATE CARD_APPLY_TASK SET TASK_STATE = ''30'' WHERE TASK_ID = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID || '''';
        EXECUTE IMMEDIATE 'UPDATE CARD_APPLY SET APPLY_STATE = ''40'' WHERE TASK_ID = ''' ||
                          LV_CARD_APPLY_TASK.TASK_ID || '''';
        --13.更新付方库存账户
        UPDATE STOCK_ACC
           SET TOT_NUM        = NVL(TOT_NUM, 0) -
                                LV_CARD_APPLY_TASK.TASK_SUM,
               LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'YYYY-MM-DD HH24:MI:SS')
         WHERE GOODS_STATE = LV_IN(10)
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND STK_CODE = LV_STK_CODE;
        --14.更新收方库存账户
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
          AV_MSG := '更新收方库存账户失败,收方库存账户不存在';
          RETURN;
        END IF;
      END LOOP;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '库存配送暂不支持按照卡段方式进行配送';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_STOCK_DELIVERY;
  --库存配送确认
  --请求参数：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 选填
  --5任务编号dealnos待确认流水号多个流水号逗号隔开如 1,2,3,4,5,6 必填
  --返回参数：
  --av_res 处理结果代码
  --av_msg 处理结果说明
  --av_out 成功处理任务的个数
  PROCEDURE P_STOCK_DELIVERY_CONFIRM(AV_IN  VARCHAR2,
                                     AV_RES OUT VARCHAR2,
                                     AV_MSG OUT VARCHAR2,
                                     AV_OUT OUT NUMBER) IS
    LV_IN                PK_PUBLIC.MYARRAY; --传入参数数组
    LV_STOCK_REC_DEALNOS PK_PUBLIC.MYARRAY;
    LV_CLR_DATE          PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_USERS             SYS_USERS%ROWTYPE;
    LV_COUNT             NUMBER;
    LV_STOCK_REC         STOCK_REC%ROWTYPE;
    LV_CARD_APPLY_TASK   CARD_APPLY_TASK%ROWTYPE;
    LV_TR_SERV_REC       TR_SERV_REC%ROWTYPE;
    LV_SYS_ACTION_LOG    SYS_ACTION_LOG%ROWTYPE;
  BEGIN
    --1.基本参数判断
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,
                             4,
                             5,
                             'PK_CARD_STOCK.P_STOCK_DELIVERY_CONFIRM',
                             LV_IN, --转换成参数数组
                             AV_RES, --传出参数代码
                             AV_MSG --传出参数错误信息
                             );
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '待确认库存配送流水不能为空';
      RETURN;
    END IF;
    --2.确认操作员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '操作柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(5), ',', LV_STOCK_REC_DEALNOS);
    IF LV_COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '待确认库存配送流水不能为空';
      RETURN;
    END IF;
    --3.初始化操作日志,业务日志信息
    LV_SYS_ACTION_LOG.DEAL_CODE   := '10502020'; --配送确认交易码
    LV_SYS_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
    LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
    LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
    LV_SYS_ACTION_LOG.LOG_TYPE    := '0';
    LV_TR_SERV_REC.DEAL_CODE      := LV_SYS_ACTION_LOG.DEAL_CODE; --配送确认交易码
    LV_TR_SERV_REC.ORG_ID         := LV_SYS_ACTION_LOG.ORG_ID;
    LV_TR_SERV_REC.BRCH_ID        := LV_SYS_ACTION_LOG.BRCH_ID;
    LV_TR_SERV_REC.USER_ID        := LV_SYS_ACTION_LOG.USER_ID;
    LV_TR_SERV_REC.BIZ_TIME       := LV_SYS_ACTION_LOG.DEAL_TIME;
    LV_TR_SERV_REC.DEAL_STATE     := '0';
    LV_TR_SERV_REC.CLR_DATE       := LV_CLR_DATE;
    AV_OUT                        := NVL(AV_OUT, 0);
    --4.循环进行库存配送流水确认
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
          AV_MSG := '当前柜员名下根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '未找到【待确认】状态的库存配送信息';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '获取配送记录出现错误' || SQLERRM;
          RETURN;
      END;
      IF LV_STOCK_REC.IS_SURE <> '1' THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '不是【未确认】状态，不能进行库存配送确认';
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
            AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                      '未找到对应配送任务信息';
            RETURN;
          WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                      '获取对应配送任务信息发生错误' || SQLERRM;
            RETURN;
        END;
        IF LV_CARD_APPLY_TASK.TASK_SUM <> LV_COUNT THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '对应的物品数量和任务数量不一致';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YPS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '对应的任务不是【已配送】状态，不能进行确认';
          RETURN;
        END IF;
        SELECT SEQ_ACTION_NO.NEXTVAL
          INTO LV_SYS_ACTION_LOG.DEAL_NO
          FROM DUAL;
        LV_SYS_ACTION_LOG.MESSAGE := '库存配送确认,库存流水' ||
                                     LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                                     ',任务编号' || LV_CARD_APPLY_TASK.TASK_ID;
        INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
        LV_TR_SERV_REC.CARD_TYPE := SUBSTR(LV_STOCK_REC.STK_CODE, 2);
        LV_TR_SERV_REC.CARD_AMT  := LV_STOCK_REC.GOODS_NUMS;
        LV_TR_SERV_REC.NUM       := LV_STOCK_REC.GOODS_NUMS;
        LV_TR_SERV_REC.DEAL_NO   := LV_SYS_ACTION_LOG.DEAL_NO;
        LV_TR_SERV_REC.NOTE      := LV_SYS_ACTION_LOG.MESSAGE;
        --更新库存配送流水到已确认状态
        UPDATE STOCK_REC
           SET IS_SURE = '0'
         WHERE STK_SER_NO = LV_STOCK_REC_DEALNOS(LV_ROW_INDEX)
           AND IN_BRCH_ID = LV_USERS.BRCH_ID
           AND IN_USER_ID = LV_USERS.USER_ID;
        --更新任务状态到已确认状态
        UPDATE CARD_APPLY_TASK
           SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_YJS
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
        --更新申领状态到已确认状态
        UPDATE CARD_APPLY
           SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS
         WHERE TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
        --更新库存物品确认状态
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
          AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '对应的库存明细数量和任务数量不一致';
          RETURN;
        END IF;
        AV_OUT := NVL(AV_OUT, 0) + 1; --成功个数
        INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
        COMMIT;
      ELSE
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '未找到对应配送任务信息';
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
  --库存配送取消 配送、配送确认、配送取消必须按照任务方式进行
  --请求参数：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 选填
  --5库存流水dealnos待确认流水号多个流水号逗号隔开如 1,2,3,4,5,6 必填
  --6交易码deal_code
  --7交易时间 deal_time
  --8备注 note
  --返回参数：
  --av_res 处理结果代码
  --av_msg 处理结果说明
  --av_out成功处理任务的个数
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
    --1.基本参数判断
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN, --传入参数
                             8, --参数最少个数
                             8, --参数最多个数
                             'PK_CARD_STOCK.P_STOCK_DELIVERY_CANCEL', --调用的函数名
                             LV_IN, --转换成参数数组
                             AV_RES, --传出参数代码
                             AV_MSG --传出参数错误信息
                             );
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL OR LV_IN(2) <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '待取消库存配送流水不能为空';
      RETURN;
    END IF;
    --2.获取操作员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '操作员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.分拆库存流水
    LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(5), ',', LV_STOCK_REC_DEALNOS);
    IF LV_COUNT <= 0 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '待取消库存配送流水不能为空';
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
          AV_MSG := '当前柜员名下根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '未找到【待确认】状态的库存配送信息';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '获取配送记录出现错误' || SQLERRM;
          RETURN;
      END;
      IF LV_STOCK_REC.IS_SURE <> '1' THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '不是【未确认】状态,无法进行配送取消';
        RETURN;
      END IF;
      --原始流水的入方柜员是现在的出方柜员
      PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_REC.IN_BRCH_ID,
                                       LV_STOCK_REC.IN_USER_ID,
                                       LV_SYS_USERS_OUT,
                                       AV_RES,
                                       AV_MSG,
                                       '出库柜员信息');
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      --原始流水的付方柜员是现在的入方柜员
      PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_REC.OUT_BRCH_ID,
                                       LV_STOCK_REC.OUT_USER_ID,
                                       LV_SYS_USERS_IN,
                                       AV_RES,
                                       AV_MSG,
                                       '入库柜员信息');
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '出库柜员和入库柜员不能相同';
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
        AV_MSG := '获取付方库存账户发生错误,' || AV_MSG;
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
        AV_MSG := '获取收方库存账户发生错误,' || AV_MSG;
        RETURN;
      END IF;
      IF LV_STOCK_REC.TASK_ID IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                  '对应的任务编号为空，无法进行库存配送取消';
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
          AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '未找到配送任务编号信息';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) ||
                    '获取配送任务编号信息发生错误' || SQLERRM;
          RETURN;
      END;
      --WHAT KIND OF TASK STATE CAN BE CANCELED
      IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YPS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '库存流水' || LV_STOCK_REC_DEALNOS(LV_ROW_INDEX) || '对应的任务' ||
                  LV_CARD_APPLY_TASK.TASK_ID || '不是【已配送】状态无法进行配送取消';
        RETURN;
      END IF;
      IF LV_STOCK_ACC_OUT.TOT_NUM < LV_STOCK_REC.GOODS_NUMS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '付方库存账户不足';
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
        AV_MSG := '记录库存出入库流数量和库存配送的数量不一致';
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
        AV_MSG := '付方库存明细数量和库存流水数量不一致';
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
      --更新收方库存账户
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) + LV_STOCK_REC.GOODS_NUMS,
             LAST_DEAL_DATE = TO_DATE(LV_IN(7), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_STOCK_REC.OUT_GOODS_STATE
         AND USER_ID = LV_STOCK_REC.OUT_USER_ID
         AND BRCH_ID = LV_STOCK_REC.OUT_BRCH_ID
         AND STK_CODE = LV_STOCK_REC.STK_CODE;
      --更新付方库存账户
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) - LV_STOCK_REC.GOODS_NUMS,
             LAST_DEAL_DATE = TO_DATE(LV_IN(7), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_STOCK_REC.IN_GOODS_STATE
         AND USER_ID = LV_STOCK_REC.IN_USER_ID
         AND BRCH_ID = LV_STOCK_REC.IN_BRCH_ID
         AND STK_CODE = LV_STOCK_REC.STK_CODE;
      --插入库存流水
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
  --柜员之间库存交换 领用
  --参数说明：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7库存类型 stk_code 必填
  --8库存物品状态goods_state
  --9出网点out_brch_id 必填
  --10出柜员out_user_id 必填
  --11收网点in_brch_id 必填
  --12收柜员in_user_id 必填
  --13库存交换方式 deliveryWay = 1时按照任务，deliveryWay = 2时按照卡号段 当为"1"时 14必填 当为"2"时 15、16必填
  --14任务编号 taskIds
  --15起始物品号码 begin_googds_no
  --16结束物品号码 end_goods_no
  --17物品数量总数量 必填
  --18note备注
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
    --1.基本参数判断
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
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    --2.操作员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '操作柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.付方柜员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(9),
                                     LV_IN(10),
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '付方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --4.收方柜员信息
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(11),
                                     LV_IN(12),
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '收方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --5.判断收方柜员是否符合要求
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '收方柜员状态不正常';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '付方柜员和收方柜员不能是同一柜员';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.ORG_ID <> LV_SYS_USERS_IN.ORG_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '必须在同一机构柜员之间进行操作';
      RETURN;
    END IF;
    --6.判断交换的库存类型信息
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_IN(7), LV_STOCK_TYPE, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --7.根据交换类型判断参数
    IF LV_IN(13) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存交换方式不能为空';
      RETURN;
    ELSIF LV_IN(13) = '1' THEN
      IF LV_IN(14) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '库存交换方式已选择按照任务方式，任务编号不能为空';
        RETURN;
      END IF;
      LV_COUNT := PK_PUBLIC.F_SPLITSTR(LV_IN(14), ',', LV_TASK_IDS);
      IF LV_COUNT <= 0 THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '任务编号不能为空';
        RETURN;
      END IF;
    ELSIF LV_IN(13) = '2' THEN
      IF LV_IN(15) IS NULL OR LV_IN(16) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '库存交换方式已选择按照号段方式，起止编号不能为空';
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
          AV_MSG := '卡段之间的库存明细数量和传入的数量不一致';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.TASK_STATE < PK_PUBLIC.KG_CARD_TASK_YJS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '号段' || LV_IN(15) || ' - ' || LV_IN(16) || '所属任务未被接收确认';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.CARD_TYPE <> PK_PUBLIC.CARD_TYPE_SMZK THEN
          IF LV_SYS_USERS_IN.BRCH_ID <> LV_CARD_APPLY_TASK.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段' || LV_IN(15) || ' - ' || LV_IN(16) ||
                      '不属于当前接收网点，交换到该网点可能导致无法进行发放';
            RETURN;
          END IF;
        END IF;
        LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE;
        IF LV_STK_CODE <> NVL(LV_IN(7), -1) THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '号段' || LV_IN(15) || ' - ' || LV_IN(16) ||
                    '不属于当前选定的库存类型';
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
          AV_MSG := '号段' || LV_IN(15) || ' - ' || LV_IN(16) || '之间找不到【' ||
                    LV_STOCK_TYPE.STK_NAME || '】库存明细信息';
          RETURN;
        END IF;
        FOR LV_TEMP_INDEX IN LV_STOCK_LIST_ARRAY.FIRST .. LV_STOCK_LIST_ARRAY.LAST LOOP
          LV_STOCK_LIST := LV_STOCK_LIST_ARRAY(LV_TEMP_INDEX);
          IF LV_STOCK_LIST.STK_CODE <> LV_STOCK_TYPE.STK_CODE THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段之间编号为【' || LV_STOCK_LIST.GOODS_NO ||
                      '】的物品不属于当前选定的库存类型';
            RETURN;
          END IF;
          IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段之间编号为【' || LV_STOCK_LIST.GOODS_NO ||
                      '】的物品当前不在柜员名下';
            RETURN;
          END IF;
          IF LV_STOCK_LIST.BRCH_ID <> LV_SYS_USERS_OUT.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段之间编号为【' || LV_STOCK_LIST.GOODS_NO || '】的物品不属于付方网点';
            RETURN;
          END IF;
          IF LV_STOCK_LIST.USER_ID <> LV_SYS_USERS_OUT.USER_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段之间编号为【' || LV_STOCK_LIST.GOODS_NO || '】的物品不属于付方柜员';
            RETURN;
          END IF;
          IF NVL(LV_STOCK_LIST.GOODS_STATE, -1) <> LV_IN(8) THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段之间编号为【' || LV_STOCK_LIST.GOODS_NO ||
                      '】的物品不属于传入的物品状态';
            RETURN;
          END IF;
          IF NVL(LV_STOCK_LIST.STK_IS_SURE, -1) <> '0' THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '号段之间编号为【' || LV_STOCK_LIST.GOODS_NO || '】的物品未被确认接收';
            RETURN;
          END IF;
        END LOOP;
        IF LV_STOCK_LIST_ARRAY.COUNT < NVL(LV_IN(17), -1) THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '号段' || LV_IN(15) || ' - ' || LV_IN(16) || '之间【' ||
                    LV_STOCK_TYPE.STK_NAME || '】库存明细数量和传入数量不一致';
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
          AV_MSG := '当前付方' || LV_STOCK_TYPE.STK_NAME || '的库存明细状态不唯一';
          RETURN;
        END IF;
        LV_LIMIT_SQL := ' goods_no >= ''' || LV_IN(15) ||
                        ''' and goods_no <= ''' || LV_IN(16) || ''' ';
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存交换方式不正确';
      RETURN;
    END IF;
    --7.如果交换类型是按照任务方式,循环处理每个任务
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
            AV_MSG := '根据任务编号' || LV_TASK_IDS(LV_ROW_INDEX) || '找不到任务信息';
            RETURN;
          WHEN OTHERS THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '根据任务编号' || LV_TASK_IDS(LV_ROW_INDEX) || '获取任务信息发生错误' ||
                      SQLERRM;
            RETURN;
        END;
        IF LV_CARD_APPLY_TASK.TASK_STATE < PK_PUBLIC.KG_CARD_TASK_YJS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '选择的任务' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '不是接收确认状态，不能进行领用';
          RETURN;
        END IF;
        IF LV_CARD_APPLY_TASK.CARD_TYPE = PK_PUBLIC.CARD_TYPE_SMZK THEN
          IF LV_CARD_APPLY_TASK.BRCH_ID <> LV_SYS_USERS_IN.BRCH_ID THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '任务编号【' || LV_TASK_IDS(LV_ROW_INDEX) ||
                      '】的所属网点和领用网点不是同一网点，配送到该网点可能导致无法进行发放';
            RETURN;
          END IF;
        END IF;
        LV_STK_CODE := '1' || LV_CARD_APPLY_TASK.CARD_TYPE; --注意：此处库存类型的生成规则
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
          AV_MSG := '选择的任务编号【' || LV_TASK_IDS(LV_ROW_INDEX) ||
                    '】的库存明细数量和任务数量不一致，或任务库存明细不在当前柜员名下';
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
          AV_MSG := '付方' || LV_STOCK_TYPE.STK_NAME || '库存账户不足';
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
          AV_MSG := '选择的任务' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '在记录库存账户操作日志时出现错误';
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
          AV_MSG := '选择的任务' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '在记录账户流水信息出现错误，更新' || SQL%ROWCOUNT || '条记录';
          RETURN;
        END IF;
        --将付方库存物品明细更新为收方的
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
          AV_MSG := '选择的任务编号' || LV_CARD_APPLY_TASK.TASK_ID ||
                    '付方库存明细物品数量与任务数量不一致，无法进行库存交换';
          RETURN;
        END IF;
        --13.更新付方库存账户
        UPDATE STOCK_ACC
           SET TOT_NUM        = NVL(TOT_NUM, 0) -
                                LV_CARD_APPLY_TASK.TASK_SUM,
               LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
         WHERE GOODS_STATE = LV_IN(8)
           AND USER_ID = LV_SYS_USERS_OUT.USER_ID
           AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
           AND STK_CODE = LV_STK_CODE;
        --14.更新收方库存账户
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
        AV_MSG := '付方' || LV_STOCK_TYPE.STK_NAME || '库存账户不足';
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
        AV_MSG := '记录卡段' || LV_IN(15) || ' - ' || LV_IN(16) || '日志信息出现错误';
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
        AV_MSG := '记录卡段' || LV_IN(15) || ' - ' || LV_IN(16) || '账户流水信息出现错误';
        RETURN;
      END IF;
      --将付方库存物品明细更新为收方的
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
        AV_MSG := '选择的卡段' || LV_IN(15) || ' - ' || LV_IN(16) ||
                  '付方库存明细物品数量与传入数量不一致，无法进行库存交换';
        RETURN;
      END IF;
      --13.更新付方库存账户
      UPDATE STOCK_ACC
         SET TOT_NUM        = NVL(TOT_NUM, 0) - LV_IN(17),
             LAST_DEAL_DATE = TO_DATE(LV_IN(6), 'yyyy-mm-dd hh24:mi:ss')
       WHERE GOODS_STATE = LV_IN(8)
         AND USER_ID = LV_SYS_USERS_OUT.USER_ID
         AND BRCH_ID = LV_SYS_USERS_OUT.BRCH_ID
         AND STK_CODE = LV_STK_CODE;
      --14.更新收方库存账户
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
  --根据库存流水进行库存交换
  --av_rec 库存流水
  --av_change_type库存交换方式 1 按照任务方式 2 按照号段进行
  --av_res 交换结果代码
  --av_msg 交换结果说明
  PROCEDURE P_STOCK_INCHANGE(AV_REC         STOCK_REC%ROWTYPE,
                             AV_CHANGE_TYPE VARCHAR2,
                             AV_RES         OUT VARCHAR2,
                             AV_MSG         OUT VARCHAR2) IS
    LV_SYS_USERS_OUT SYS_USERS%ROWTYPE; --付方柜员
    LV_STOCK_ACC_OUT STOCK_ACC%ROWTYPE; --付方库存账户
    LV_SYS_USERS_IN  SYS_USERS%ROWTYPE; --入房柜员
    LV_STOCK_ACC_IN  STOCK_ACC%ROWTYPE; --入房库存账户
    LV_LIMIT_SQL     VARCHAR2(500) := '';
    LV_STK_SER_NO    STOCK_REC.STK_SER_NO%TYPE;
  BEGIN
    --1.付方柜员，库存账户判断
    PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_REC.OUT_BRCH_ID,
                                     AV_REC.OUT_USER_ID,
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '付方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '付方柜员状态不正常';
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
      AV_MSG := '获取付方库存账户发生错误,' || AV_MSG;
      RETURN;
    END IF;
    IF NVL(LV_STOCK_ACC_OUT.TOT_NUM, 0) < NVL(AV_REC.GOODS_NUMS, 0) THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '付方库存账户不足';
      RETURN;
    END IF;
    --2.收方柜员，库存账户判断
    PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_REC.IN_BRCH_ID,
                                     AV_REC.IN_USER_ID,
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '收方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '收方柜员状态不正常';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '库存交换不能是同一个柜员';
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
      AV_MSG := '获取收方库存账户发生错误,' || AV_MSG;
      RETURN;
    END IF;
    --3.根据库存交换类型判断必填参数
    IF AV_CHANGE_TYPE IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '库存交换类型不能为空';
      RETURN;
    ELSIF AV_CHANGE_TYPE = '1' THEN
      IF AV_REC.TASK_ID IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '库存交换类型已选定【按任务方式】进行交换，任务编号不能为空';
        RETURN;
      ELSE
        LV_LIMIT_SQL := ' task_id =''' || AV_REC.TASK_ID || ''' ';
      END IF;
    ELSIF AV_CHANGE_TYPE = '2' THEN
      IF AV_REC.START_NO IS NULL OR AV_REC.END_NO IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '库存交换类型已选定【按号段方式】进行交换，起止物品编号不能为空';
        RETURN;
      ELSE
        LV_LIMIT_SQL := ' goods_no between ''' || AV_REC.START_NO ||
                        ''' and ''' || AV_REC.END_NO || ''' ';
      END IF;
    END IF;
    --4.更新库存明细
    EXECUTE IMMEDIATE 'UPDATE stock_list set org_id = :1,brch_id = :2,user_id = :3 ' ||
                      'WHERE b.stk_is_sure = ''0'' and b.own_type = ''0'' AND ' ||
                      LV_LIMIT_SQL ||
                      'AND org_id = :4 AND brch_id = :5 AND user_id = :6 and stk_code = :7 and goods_state = :8'
      USING AV_REC.IN_ORG_ID, AV_REC.IN_BRCH_ID, AV_REC.USER_ID, AV_REC.OUT_ORG_ID, AV_REC.OUT_BRCH_ID, AV_REC.USER_ID, AV_REC.STK_CODE, AV_REC.OUT_GOODS_STATE;
    IF SQL%ROWCOUNT <> AV_REC.GOODS_NUMS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '付方库存明细数量不足';
      RETURN;
    END IF;
    --5.更新付方库存账户
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) - NVL(AV_REC.GOODS_NUMS, 0),
           LAST_DEAL_DATE = AV_REC.TR_DATE
     WHERE GOODS_STATE = AV_REC.OUT_GOODS_STATE
       AND USER_ID = AV_REC.OUT_USER_ID
       AND BRCH_ID = AV_REC.OUT_BRCH_ID
       AND STK_CODE = AV_REC.STK_CODE;
    --6.更新收方库存账户
    UPDATE STOCK_ACC
       SET TOT_NUM        = NVL(TOT_NUM, 0) + NVL(AV_REC.GOODS_NUMS, 0),
           LAST_DEAL_DATE = AV_REC.TR_DATE
     WHERE GOODS_STATE = AV_REC.IN_GOODS_STATE
       AND USER_ID = AV_REC.IN_USER_ID
       AND BRCH_ID = AV_REC.IN_BRCH_ID
       AND STK_CODE = AV_REC.STK_CODE;
    --7.插入库存流水
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
  --CardBaseinfo发放,个人发放,规模发放
  --参数说明：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7卡号card_no
  --8任务编号task_id
  --9备注note
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
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL AND LV_IN(8) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '卡号和任务编号不能都为空';
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
        AV_MSG := '库存明细不存在';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := SQLERRM;
    END;
    IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存明细归属类型不属于柜员';
      RETURN;
    END IF;
    IF LV_STOCK_LIST.BRCH_ID <> LV_USERS.BRCH_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '库存明细不属于当前网点';
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
      AV_MSG := '库存明细不属于当前柜员';
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
                                     '付方柜员信息');
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
        AV_MSG := '根据任务编号' || LV_IN(8) || '未找到任务信息';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '根据任务编号' || LV_IN(8) || '获取任务信息发生错误' || SQLERRM;
    END;
    IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_YJS AND
       LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_FKZ THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据任务编号' || LV_IN(8) || '获取到的任务信息不是【已接收】或【发卡中】状态';
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
      AV_MSG := '付方库存账户不足';
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
      AV_MSG := '记录库存操作日志出现错误-' || SQL%ROWCOUNT || '条';
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
      AV_MSG := '记录库存出入库流水信息出现错误，付方库存明细不足';
      RETURN;
    END IF;
    IF SQL%ROWCOUNT <> LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '记录库存出入库流水信息出现错误待记录' || LV_COUNT || '条，实际记录' ||
                SQL%ROWCOUNT || '条';
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
      AV_MSG := '更新付方库存明细出库数量不正确，付方库存明细物品数量不足';
      RETURN;
    ELSIF SQL%ROWCOUNT > LV_COUNT THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '更新付方库存明细出库数量不正确，待更新' || LV_COUNT || '实际更新' || SQL%ROWCOUNT || '条';
      RETURN;
    END IF;
    /**
    EXECUTE IMMEDIATE 'update card_apply set apply_state = ''' || pk_public.kg_card_apply_yff || ''',RELS_BRCH_ID = ''' || lv_users.brch_id
    || ''',RELS_USER_ID = ''' || lv_users.user_id || ''',RELS_DATE = to_date(''' || lv_in(6) || ''',''yyyy-mm-dd hh24:mi:ss''),ISSUSE_DEAL_NO = ' || lv_in(4)
    || ' where ' || REPLACE(lv_limit_sql,'goods_no','card_no') || ' and apply_state = ''' || pk_public.kg_card_apply_yjs || '''';
    IF SQL%ROWCOUNT <> lv_count THEN
    av_res := pk_public.cs_res_unknownerr;
    av_msg := '更新申领状态数量不正确，待更新' || lv_count || '实际更新' || SQL%ROWCOUNT || '条';
    RETURN;
    END IF;
    IF lv_card_apply_task.task_sum = (lv_count + lv_totnum) THEN
    UPDATE card_apply_task SET task_state = pk_public.kg_card_task_yff WHERE task_id = lv_card_apply_task.task_id;
    ELSE
    UPDATE card_apply_task SET task_state = pk_public.kg_card_task_fkz WHERE task_id = lv_card_apply_task.task_id;
    END IF;
    IF SQL%ROWCOUNT <> 1 THEN
    av_res := pk_public.cs_res_unknownerr;
    av_msg := '更新任务状态不正确，实际更新' || SQL%ROWCOUNT || '条';
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
      AV_MSG := '更新付方库存账户不正确，请确认付方库存账户是否存在';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_CARD_RELEASE;
  --库存物品入库
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7库存类型STK_CODE
  --8物品编号id GOODS_ID
  --9物品编号GOODS_NO
  --10物品状态GOODS_STATE
  --11所属批次BATCH_ID
  --12所属任务TASK_ID
  --13是否确认STK_IS_SURE
  --14入库网点IN_BRCH_ID
  --15入库柜员IN_USER_ID
  --16归属类型OWN_TYPE
  --17归属机构ORG_ID
  --18归属网点BRCH_ID
  --19归属柜员USER_ID
  --20归属客户编号
  --21归属客户名称
  --22备注NOTE
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
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),
                                     LV_IN(3),
                                     LV_USERS,
                                     AV_RES,
                                     AV_MSG,
                                     '操作柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '物品入库，库存代码不能为空';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETSTOCK_TYPE(LV_IN(7), LV_STOCK_TYPE, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_STOCK_LIST.STK_CODE := LV_STOCK_TYPE.STK_CODE;
    IF LV_IN(9) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '物品入库，物品编号不能为空';
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
      AV_MSG := '相同物品编号已经存在，请不要重复进行入库';
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
      AV_MSG := '物品状态不正确';
      RETURN;
    END IF;
    LV_STOCK_LIST.GOODS_STATE := LV_IN(10);
    IF LV_IN(16) = '0' THEN
      IF LV_IN(17) IS NULL OR LV_IN(18) IS NULL OR LV_IN(19) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '当前物品归属类型是柜员，柜员信息不能为空';
        RETURN;
      ELSE
        LV_STOCK_LIST.ORG_ID  := LV_IN(17);
        LV_STOCK_LIST.BRCH_ID := LV_IN(18);
        LV_STOCK_LIST.USER_ID := LV_IN(19);
      END IF;
    ELSIF LV_IN(16) = '1' THEN
      IF LV_IN(20) IS NULL OR LV_IN(21) IS NULL THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '当前物品归属类型是客户，客户信息不能为空';
        RETURN;
      ELSE
        LV_STOCK_LIST.CUSTOMER_ID   := LV_IN(20);
        LV_STOCK_LIST.CUSTOMER_NAME := LV_IN(21);
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '归属类型只能是0或1';
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
      AV_MSG := '库存明细是否确认标志只能是0或是1';
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
               av_msg := '更新库存账户不正确';
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
  --补换卡
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7旧物品编号Old_GOODS_NO
  --8新物品编号NEW_GOODS_NO
  --9老卡目标库存状态 默认 2 坏卡
  --10备注NOTE
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
      AV_MSG := '交易代码不能都为空';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '操作时间不能都为空';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL AND LV_IN(8) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '老卡号和新卡号不能都为空';
      RETURN;
    END IF;
    IF LV_IN(8) IS NOT NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '暂不支持';
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
      AV_MSG := '老卡库存明细状态不正常';
      RETURN;
    END IF;
    IF LV_STOCK_LIST_OLD.OWN_TYPE <> '1' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '老卡库存明细归属类型不属于客户';
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
      AV_MSG := '老卡库存明细归属客户和卡片信息持有人不一致';
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
      AV_MSG := '库存明细不存在';
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
      AV_MSG := '柜员库存账户不存在';
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
      AV_MSG := '新卡库存明细不存在,' || AV_MSG;
      RETURN;
    END IF;
    IF LV_STOCK_LIST_NEW.GOODS_STATE <> PK_CARD_STOCK.GOODS_STATE_ZC THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '新卡库存明细不正常';
      RETURN;
    END IF;
    IF LV_STOCK_LIST_NEW.OWN_TYPE <> '0' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '新卡库存明细归属类型不属于柜员';
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
      AV_MSG := '新卡库存明细不属于当前柜员';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST_NEW.BRCH_ID,
                                     LV_STOCK_LIST_NEW.USER_ID,
                                     LV_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '付方柜员信息');
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
      AV_MSG := '新卡付方库存账户不足';
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
      AV_MSG := '更新新卡的库存明细不正确';
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
      AV_MSG := '更新新卡的库存账户不正确';
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
  --卡回收登记   收回卡
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7物品编号/卡号
  --8回收目标库存状态 默认 1 回收代处理
  --9备注NOTE
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
      AV_MSG := '交易代码不能都为空';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '操作时间不能都为空';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '回收的卡号不能为空';
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
      AV_MSG := '库存明细状态不正常';
      RETURN;
    END IF;
    IF LV_STOCK_LIST_OLD.OWN_TYPE <> '1' THEN
      PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST_OLD.BRCH_ID,
                                       LV_STOCK_LIST_OLD.USER_ID,
                                       LV_USERS_OUT,
                                       AV_RES,
                                       AV_MSG,
                                       '付方柜员');
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
        AV_MSG := '付方库存账户不足';
        RETURN;
      END IF;
    END IF;
    /*pk_card_stock.p_getcardbaseinfo(lv_stock_list_old.goods_no,lv_card_baseinfo_old,av_res,av_msg);
    if av_res <> pk_public.cs_res_ok then
    return;
    end if;
    if lv_card_baseinfo_old.customer_id <> lv_stock_list_old.customer_id then
    av_res := pk_public.cs_res_paravalueerr;
    av_msg := '老卡库存明细归属客户和卡片信息持有人不一致';
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
      AV_MSG := '记录库存出入库流水信息出现错误，付方库存明细不足';
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
      AV_MSG := '库存明细不存在';
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
        AV_MSG := '付方柜员库存账户不存在';
        RETURN;
      END IF;
      IF LV_COUNT < 0 THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '付方柜员库存账户不足';
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
      AV_MSG := '收方柜员库存账户不存在';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_HSDJ;
  --物品出库
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7物品编号/卡号
  --8目标库存状态 默认不修改原库存明细状态 出库后需要将库存明细修改到什么状态
  -- 一般不需要传入，但是如补换卡撤销时需要传入0 正常，因为补换卡操作后库存明细变为质量问题状态，撤销时需要回复到正常状态
  --9是否校验所属人信息  默认是否卡操作
  --10备注note
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
      AV_MSG := '交易代码不能都为空';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '操作时间不能都为空';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '出库物品编号不能为空';
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
      AV_MSG := '是否校验所属人标志只能是0或1';
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
      AV_MSG := '库存明细归属类型不属于柜，没有操作权限';
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
      AV_MSG := '库存明细不属于当前柜员，没有操作权限';
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST_OLD.BRCH_ID,
                                     LV_STOCK_LIST_OLD.USER_ID,
                                     LV_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '付方柜员');
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
      AV_MSG := '付方库存账户不足';
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
      AV_MSG := '记录库存出入库流水信息出现错误，付方库存明细不足';
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
      AV_MSG := '库存明细不存在';
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
      AV_MSG := '付方柜员库存账户不存在';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
  END P_OUT_STOCK;
  --柜员交接
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码
  --6交易时间
  --7出网点
  --8出柜员
  --9收网点
  --10收柜员
  --11库存类型
  --12库存状态
  --13备注
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
      AV_MSG := '库存类型不能为空';
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
                                     '操作柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(7),
                                     LV_IN(8),
                                     LV_SYS_USERS_OUT,
                                     AV_RES,
                                     AV_MSG,
                                     '付方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(9),
                                     LV_IN(10),
                                     LV_SYS_USERS_IN,
                                     AV_RES,
                                     AV_MSG,
                                     '收方柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_SYS_USERS_IN.STATUS <> 'A' THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '收方柜员状态不正常';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.USER_ID = LV_SYS_USERS_IN.USER_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '付方柜员和收方柜员不能是同一柜员';
      RETURN;
    END IF;
    IF LV_SYS_USERS_OUT.ORG_ID <> LV_SYS_USERS_IN.ORG_ID THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '必须在同一机构柜员之间进行操作';
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
      AV_MSG := '付方柜员不存在库存账户';
      RETURN;
    END IF;
    FOR TEMP_ACC_INDEX IN LV_CUR.FIRST .. LV_CUR.LAST LOOP
      LV_STOCK_LIST_SQL := '';
      LV_STOCK_ACC_SQL  := '';
      LV_TIP_STR        := '';
      LV_TIP_STR        := '【' || LV_STOCK_TYPE.STK_NAME || '-' ||
                           F_GET_GOODS_STATE_NAME(LV_CUR(TEMP_ACC_INDEX)
                                                  .GOODS_STATE) || '】';
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
        AV_MSG := '付方' || LV_TIP_STR || '库存账户数量和库存明细数量不一致';
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
        AV_MSG := '更新付方库存账户不正确';
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
      LV_TIP_STR := '【' || LV_STOCK_TYPE.STK_NAME || '-' ||
                    F_GET_GOODS_STATE_NAME(LV_CUR(TEMP_ACC_INDEX)
                                           .GOODS_STATE) || '】';
      IF SQL%ROWCOUNT <> 1 THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '收方柜员不存在' || LV_TIP_STR || '账户';
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
  --根据物品编号获取物品信息
  --av_goods_no 物品编号
  --av_stock_list 物品信息
  --av_res 处理结果代码
  --av_res 处理结果说明
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
      AV_MSG := '根据物品编号' || AV_GOODS_NO || '未找到库存明细信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据物品编号' || AV_GOODS_NO || '获取库存明细信息出现错误' || SQLERRM;
  END P_GETSTOCKLISTBYGOODSNO;
  --根据卡号获取卡信息
  --av_goods_no 物品编号
  --av_stock_list 物品信息
  --av_res 处理结果代码
  --av_res 处理结果说明
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
      AV_MSG := '根据卡号' || AV_CARD_NO || '未找到卡片信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据卡号' || AV_CARD_NO || '获取卡片信息出现错误' || SQLERRM;
  END P_GETCARDBASEINFO;
  --根据任务编号获取任务信息
  --av_task_id 任务编号
  --av_card_apply_task 任务信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
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
      AV_MSG := '根据任务编号' || AV_TASK_ID || '找不到任务信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据任务编号' || AV_TASK_ID || '获取任务信息出现错误' || SQLERRM;
      RETURN;
  END;
  --根据柜员编号、库存类型、物品状态获取库存账户
  --av_stk_code 库存代码
  --av_stk_goods_state物品状态
  --av_stock_acc 库存账户信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE P_GETSTOCK_ACC(AV_BRCH_ID         VARCHAR2,
                           AV_USER_ID         VARCHAR2, --柜员user_id
                           AV_STK_CODE        VARCHAR2, --库存代码
                           AV_STK_GOODS_STATE VARCHAR2, --物品状态
                           AV_STOCK_ACC       OUT STOCK_ACC%ROWTYPE,
                           AV_RES             OUT VARCHAR2, --返回代码
                           AV_MSG             OUT VARCHAR2) --返回信息
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
      AV_MSG := '根据柜员编号' || AV_USER_ID || '，库存代码' || AV_STK_CODE || '，物品状态' ||
                AV_STK_GOODS_STATE || '，未找到对应库存账户信息';
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据柜员编号' || AV_USER_ID || '，库存代码' || AV_STK_CODE || '，物品状态' ||
                AV_STK_GOODS_STATE || '，获取库存账户出现错误' || SQLERRM;
  END P_GETSTOCK_ACC;
  --获取库存代码获取库存类型信息
  --lv_stk_code 库存代码
  --lv_stock_type 库存类型信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE P_GETSTOCK_TYPE(LV_STK_CODE   STOCK_TYPE.STK_CODE%TYPE,
                            LV_STOCK_TYPE OUT STOCK_TYPE%ROWTYPE,
                            AV_RES        OUT VARCHAR2,
                            AV_MSG        OUT VARCHAR2) IS
  BEGIN
    IF LV_STK_CODE IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '获取库存类型信息，库存类型编码不能为空';
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
      AV_MSG := '根据库存类型编码' || LV_STK_CODE || '找不到库存类型信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据库存类型编码' || LV_STK_CODE || '获取库存类型信息出现错误' || SQLERRM;
  END;
  --根据网点编号，柜员编号获取柜员信息
  --av_brch_id 网点编号
  --av_user_id 柜员编号
  --av_users   柜员信息
  --av_res     处理结果编号
  --av_msg     处理结果说明
  --av_init_msg初始化信息
  PROCEDURE P_GETUSERSBYUSERID(AV_BRCH_ID  VARCHAR2, -- 所属网点
                               AV_USER_ID  VARCHAR2, --柜员编号
                               AV_USERS    OUT SYS_USERS%ROWTYPE,
                               AV_RES      OUT VARCHAR2, --处理结果编号
                               AV_MSG      OUT VARCHAR2, --处理结果说明
                               AV_INIT_MSG VARCHAR --初始化语句
                               ) IS
    LV_MSG VARCHAR2(500) := '柜员信息';
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
      AV_MSG := '根据网点编号' || AV_BRCH_ID || '柜员编号' || AV_USER_ID || '未找到' ||
                LV_MSG;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_OPERATORERR;
      AV_MSG := '根据网点编号' || AV_BRCH_ID || '柜员编号' || AV_USER_ID || '获取' ||
                LV_MSG || '出现错误' || SQLERRM;
  END P_GETUSERSBYUSERID;
  --判断卡段是否是同属一个任务且号段是否连续
  --av_user_id 所属柜员
  --av_begin_goods_no 起始卡号
  --av_end_goods_no 截止卡号
  --av_card_apply_task 所属任务
  --av_res 处理结果代码
  --av_msg 处理结果说明
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
    --1.基本条件判断
    IF AV_BEGIN_GOODS_NO IS NULL OR AV_END_GOODS_NO IS NULL THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '判断卡号段起止卡号不能为空';
      RETURN - 1;
    END IF;
    IF SUBSTR(AV_BEGIN_GOODS_NO, 9, 8) > SUBSTR(AV_END_GOODS_NO, 9, 8) THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '起始卡号不能大于截止卡号';
      RETURN - 1;
    END IF;
    IF SUBSTR(AV_BEGIN_GOODS_NO, 1, 9) <> SUBSTR(AV_END_GOODS_NO, 1, 9) THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '起止卡号不属于同一个区域或是同一种库存类型';
      RETURN - 1;
    END IF;
    --2.判断卡段是否是同一个任务,同一个库存类型
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
      AV_MSG := '在号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                '之间找不到有效的库存明细信息或卡段不属于柜员';
      RETURN - 1;
    END IF;
    IF LV_COUNT > 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                '属于多个不同的任务,或是不同种库存类型';
      RETURN - 1;
    END IF;
    --3.判断卡段分属几个柜员
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
      AV_MSG := '号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                '属于多个不同的柜员';
      RETURN - 1;
    END IF;
    --4.获取卡段所属的柜员和任务编号
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
        AV_MSG := '号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '不属于柜员' || AV_USER_ID;
        RETURN - 1;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '找不到号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '所属柜员和任务编号信息';
        RETURN - 1;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '获取号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '所属柜员和任务编号信息时发生错误' || SQLERRM;
        RETURN - 1;
    END;
    --5号段所属任务信息
    BEGIN
      SELECT *
        INTO AV_CARD_APPLY_TASK
        FROM CARD_APPLY_TASK
       WHERE TASK_ID = LV_TASK_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '根据号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '所属任务编号' || LV_TASK_ID || '找不到任务信息';
        RETURN - 1;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '根据号段' || AV_BEGIN_GOODS_NO || ' - ' || AV_END_GOODS_NO ||
                  '所属任务编号' || LV_TASK_ID || '获取任务信息发生错误' || SQLERRM;
        RETURN - 1;
    END;
    --6.判断卡段连续性
    SELECT GOODS_NO BULK COLLECT
      INTO LV_CARD_NOS
      FROM STOCK_LIST
     WHERE GOODS_NO >= AV_BEGIN_GOODS_NO
       AND GOODS_NO <= AV_END_GOODS_NO;
    IF LV_CARD_NOS(1) <> AV_BEGIN_GOODS_NO THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '起始卡号不存在';
      RETURN - 1;
    END IF;
    IF LV_CARD_NOS(LV_CARD_NOS.LAST) <> AV_END_GOODS_NO THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '截止卡号不存在';
      RETURN - 1;
    END IF;
    FOR LV_CARD_NO_INDEX IN LV_CARD_NOS.FIRST .. (LV_CARD_NOS.LAST - 1) LOOP
      IF (SUBSTR(LV_CARD_NOS(LV_CARD_NO_INDEX), 9, 8) + 1) <>
         SUBSTR(LV_CARD_NOS(LV_CARD_NO_INDEX + 1), 9, 8) THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '号段在' || LV_CARD_NOS(LV_CARD_NO_INDEX) || '处不连续，下一个卡号' ||
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
  --制卡数据导入
  --av_in
  --1acpt_id受理点编号
  --2acpt_type受理点类型
  --3user_id操作员
  --4deal_no操作流水
  --5dr_batch_id导入批次
  --处理结果
  --av_res 处理结果代码
  --av_msg 处理结果代码
  --av_out 输出参数
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
    --1.参数解析
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
      AV_MSG := '导入数据的临时批次号不能为空';
      RETURN;
    END IF;
    LV_CITY_CODE := PK_PUBLIC.F_GETSYSPARA('CITY_CODE');
    IF LV_CITY_CODE = '0' OR LV_CITY_CODE = '-1' THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '城市代码配置不正确';
      RETURN;
    END IF;
    --2.受理点判断
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
      AV_MSG := '根据导入数据的临时批次号找不到任务信息';
      RETURN;
    END IF;
    LV_CITY_CODE := PK_PUBLIC.F_GETSYSPARA('CITY_CODE');
    IF LV_CITY_CODE IN ('0', '-1') THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '城市代码配置不正确';
      RETURN;
    END IF;
    --3.操作日志
    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYS_ACTION_LOG.DEAL_NO FROM DUAL;
    LV_SYS_ACTION_LOG.DEAL_CODE   := '10502060';
    LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
    LV_SYS_ACTION_LOG.ORG_ID      := LV_USERS.ORG_ID;
    LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYS_ACTION_LOG.MESSAGE     := '实名制卡批量导入';
    LV_SYS_ACTION_LOG.CAN_ROLL    := '1';
    LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
    LV_SYS_ACTION_LOG.LOG_TYPE    := '0';
    LV_SYS_ACTION_LOG.ROLL_FLAG   := '1';
    LV_SYS_ACTION_LOG.NOTE        := LV_SYS_ACTION_LOG.MESSAGE;
    INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
    --4.各个任务分别入库
    FOR TASK_INDEX IN LV_TASK_IDS.FIRST .. LV_TASK_IDS.LAST LOOP
      SELECT *
        INTO LV_CARD_APPLY_TASK
        FROM CARD_APPLY_TASK
       WHERE TASK_ID = LV_TASK_IDS(TASK_INDEX);
      IF LV_CARD_APPLY_TASK.TASK_STATE <> PK_PUBLIC.KG_CARD_TASK_ZKZ THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '任务编号为【' + LV_TASK_IDS(TASK_INDEX) ||
                  '】的任务，制卡任务状态不为【制卡中】';
        RETURN;
      END IF;
      SELECT COUNT(1)
        INTO LV_COUNT
        FROM CARD_TASK_IMP_TMP
       WHERE TASK_ID = LV_TASK_IDS(TASK_INDEX)
         AND DR_BATCH_ID = LV_IN(5);
      IF LV_COUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '任务编号为【' + LV_TASK_IDS(TASK_INDEX) ||
                  '】的任务，实际制卡明细数量和任务导入数量不一致';
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
               '实名制卡批量导入',
               LV_USERS.BRCH_ID,
               NULL
          FROM CARD_TASK_IMP_TMP T
         WHERE T.DR_BATCH_ID = LV_IN(5)
           AND T.TASK_ID = LV_CARD_APPLY_TASK.TASK_ID;
      IF SQL%ROWCOUNT <> LV_CARD_APPLY_TASK.YH_NUM THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '任务编号为【' + LV_TASK_IDS(TASK_INDEX) ||
                  '】的任务，实际入库数量和任务数量不一致';
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
                '实名制卡批量导入',
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
        AV_MSG := '任务编号为【' + LV_TASK_IDS(TASK_INDEX) ||
                  '】的任务，入卡信息表和任务数量不一致';
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
        AV_MSG := '任务编号为【' + LV_TASK_IDS(TASK_INDEX) ||
                  '】的任务，更新申领数量和任务导入数量不一致';
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
          AV_MSG := '任务编号为【' + LV_TASK_IDS(TASK_INDEX) ||
                    '】的任务，入银行卡绑定信息表和任务数量不一致';
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
        AV_MSG := '记录库存操作日志出现错误-' || SQL%ROWCOUNT || '条';
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
        AV_MSG := '记录库存出入库流水信息出现错误，入库数量小于制卡明细数量不一致';
        RETURN;
      END IF;
      IF SQL%ROWCOUNT <> LV_COUNT THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '记录库存入库流水信息出现错误待记录' || LV_COUNT || '条，实际记录' ||
                  SQL%ROWCOUNT || '条';
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
  --更换库存
  PROCEDURE P_UPDATECARDSTOCK(P_CARDNO  IN VARCHAR2, --新卡号
                              P_CARDNO2 IN VARCHAR2, --老卡号
                              P_DEALNO  IN INTEGER, --处理流水号
                              AS_OUTMSG OUT VARCHAR2, --错误代码
                              AS_RES    OUT VARCHAR2 ----错误描述
                              ) IS
    AS_CARD      CARD_BASEINFO%ROWTYPE; --新卡信息
    AS_CARD2     CARD_BASEINFO%ROWTYPE; --老卡信息
    AS_ACTIONLOG SYS_ACTION_LOG%ROWTYPE; --日志
    AS_SYSUSERS  SYS_USERS%ROWTYPE; --操作员
    AS_STOCKTYPE STOCK_TYPE%ROWTYPE; --库存类型
    AS_STOCKREC  STOCK_REC%ROWTYPE; --库存业务
    AS_STOCKACC  STOCK_ACC%ROWTYPE; --库存账户
    --as_StockList  Stock_List%rowtype; --库存明细
    AS_CARDCONFIG CARD_CONFIG%ROWTYPE; --卡参数信息表
    ROWNCOUNT     INTEGER;
    ROWNCOUNT1    INTEGER;
    AS_CLR_DATE   VARCHAR2(10);
  BEGIN
    IF P_CARDNO IS NULL AND P_CARDNO2 IS NULL THEN
      AS_OUTMSG := '新卡号和老卡号不能都为空';
      AS_RES    := PK_PUBLIC.CS_RES_OK;
      RETURN;
    END IF;
    SELECT P.CLR_DATE INTO AS_CLR_DATE FROM PAY_CLR_PARA P; --清分日期
    SELECT * INTO AS_CARD FROM CARD_BASEINFO T WHERE T.CARD_NO = P_CARDNO; --新卡号
    SELECT *
      INTO AS_CARD2
      FROM CARD_BASEINFO TT
     WHERE TT.CARD_NO = P_CARDNO2; --老卡号
    ------系统日志-------
    SELECT *
      INTO AS_ACTIONLOG
      FROM SYS_ACTION_LOG L
     WHERE L.DEAL_NO = P_DEALNO; --系统日志
    SELECT *
      INTO AS_SYSUSERS
      FROM SYS_USERS O
     WHERE O.USER_ID = AS_ACTIONLOG.USER_ID; --操作员
    SELECT *
      INTO AS_CARDCONFIG
      FROM CARD_CONFIG T
     WHERE T.CARD_TYPE = AS_CARD.CARD_TYPE; --根据卡类型找到相关的卡信息
    SELECT *
      INTO AS_STOCKTYPE
      FROM STOCK_TYPE ST
     WHERE ST.STK_CODE = AS_CARDCONFIG.STK_CODE; --库存类型
    AS_STOCKREC.DEAL_NO   := P_DEALNO; --//业务流水号
    AS_STOCKREC.DEAL_CODE := AS_ACTIONLOG.DEAL_CODE; --//交易代码
    AS_STOCKREC.STK_CODE  := AS_STOCKTYPE.STK_CODE; --//库存代码
    -- as_StockRec.Stk_Type  := as_StockType.Stk_Type; --//库存种类
    AS_STOCKREC.GOODS_NUMS := 1;
    SELECT COUNT(*)
      INTO ROWNCOUNT
      FROM CARD_BASEINFO C
     WHERE C.CARD_NO = P_CARDNO2; --老卡的信息
    IF ROWNCOUNT > 0 THEN
      AS_STOCKREC.IN_GOODS_STATE := '2'; --//收方物品状态
      AS_STOCKREC.IN_USER_ID     := AS_SYSUSERS.USER_ID; --收方柜员编号
      AS_STOCKREC.IN_BRCH_ID     := AS_SYSUSERS.BRCH_ID; --//收方网点编号
      AS_STOCKREC.IN_ORG_ID      := AS_SYSUSERS.ORG_ID; --//收方机构编号
      AS_STOCKREC.IN_OUT_FLAG    := '1'; --//收付标志-收
      AS_STOCKREC.START_NO       := P_CARDNO2; --卡号
      AS_STOCKREC.END_NO         := P_CARDNO2;
    END IF;
    SELECT COUNT(*)
      INTO ROWNCOUNT1
      FROM CARD_BASEINFO C
     WHERE C.CARD_NO = P_CARDNO; --新卡的信息
    IF ROWNCOUNT > 0 THEN
      AS_STOCKREC.GOODS_NUMS      := 2;
      AS_STOCKREC.OUT_GOODS_STATE := '0'; --//收方物品状态
      AS_STOCKREC.OUT_USER_ID     := AS_SYSUSERS.USER_ID; --收方柜员编号
      AS_STOCKREC.OUT_BRCH_ID     := AS_SYSUSERS.BRCH_ID; --//收方网点编号
      AS_STOCKREC.OUT_ORG_ID      := AS_SYSUSERS.ORG_ID; --//收方机构编号
      AS_STOCKREC.IN_OUT_FLAG     := '2'; --//收付标志-收
    END IF;
    IF ROWNCOUNT1 > 0 AND ROWNCOUNT > 0 THEN
      AS_STOCKREC.IN_OUT_FLAG := '3'; --//收付标志-收付
      AS_STOCKREC.GOODS_NUMS  := 2;
    END IF;
    AS_STOCKREC.GOODS_NUMS := 0; --//金额
    AS_STOCKREC.TR_DATE    := AS_ACTIONLOG.DEAL_TIME; --//交易时间
    AS_STOCKREC.USER_ID    := AS_SYSUSERS.USER_ID; --柜员编号
    AS_STOCKREC.BRCH_ID    := AS_SYSUSERS.BRCH_ID; --//柜员网点编号
    AS_STOCKREC.ORG_ID     := AS_SYSUSERS.ORG_ID; --//柜员机构编号
    AS_STOCKREC.BOOK_STATE := '0'; --//业务状态-正常
    AS_STOCKREC.CLR_DATE   := AS_CLR_DATE; --//清分日期
    AS_STOCKREC.IS_SURE    := '1'; --//库存配送状态，默认为未确认
    INSERT INTO STOCK_REC VALUES AS_STOCKREC; --插入
    ---------------老卡号信息--------------------
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
        AS_OUTMSG := '库存分户账不存在';
        RETURN;
      END IF;
      --更新库存明细
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
      --更新库分户账
      UPDATE STOCK_ACC CC
         SET TOT_NUM          =
             (TOT_NUM + 1),
             CC.LAST_DEAL_DATE = SYSDATE
       WHERE CC.USER_ID = AS_SYSUSERS.USER_ID
         AND CC.STK_CODE = AS_STOCKREC.STK_CODE
         AND CC.GOODS_STATE = AS_STOCKREC.IN_GOODS_STATE;
    END IF;
    ---------------新卡号信息--------------------
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
        AS_OUTMSG := '库存明细不存在';
        RETURN;
      END IF;
      --更新库存明细
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
      ---新卡的库存账户
      SELECT COUNT(*)
        INTO ROWNCOUNT
        FROM STOCK_ACC S
       WHERE S.STK_CODE = AS_STOCKREC.STK_CODE
         AND S.GOODS_STATE = '0'
         AND S.USER_ID = AS_STOCKREC.USER_ID; --付方账户
      IF ROWNCOUNT = 0 THEN
        AS_RES    := PK_PUBLIC.CS_RES_DBERR;
        AS_OUTMSG := '库存分户账不存在';
        RETURN;
      END IF;
      ----新卡的库存账户(实体对象)
      SELECT *
        INTO AS_STOCKACC
        FROM STOCK_ACC SA
       WHERE SA.STK_CODE = AS_STOCKREC.STK_CODE
         AND SA.GOODS_STATE = '0'
         AND SA.USER_ID = AS_STOCKREC.USER_ID; --付方账户
      IF AS_STOCKACC.TOT_NUM < 1 THEN
        AS_RES    := PK_PUBLIC.CS_RES_KC1;
        AS_OUTMSG := '库存数量不足';
        RETURN;
      END IF;
      --更新新卡的库存账户
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
      AS_OUTMSG := '系统错误';
      ROLLBACK;
      RAISE_APPLICATION_ERROR('-20001', SQLERRM);
  END P_UPDATECARDSTOCK;
END PK_CARD_STOCK;
/

