CREATE OR REPLACE PACKAGE BODY PK_SERVICE_OUTER
IS
  --接入受理点判断,并返回受理点信息
  PROCEDURE P_JUDGE_ACPT(
      AV_ACPT_ID   VARCHAR2, --受理点类型
      AV_ACPT_TYPE VARCHAR2, --受理点编号/网点编号
      AV_USER_ID   VARCHAR2, --终端号/操作员
      AV_SYS_USERS OUT SYS_USERS%ROWTYPE,
      AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE,
      AV_RES OUT VARCHAR2, --传入代码
      AV_MSG OUT VARCHAR2  --传出参数错误信息
    )
  IS
  BEGIN
    IF AV_ACPT_TYPE IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '受理点类型不正确';
      RETURN;
    END IF;
    IF AV_ACPT_ID IS NULL THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '受理点编号不正确';
      RETURN;
    END IF;
    IF AV_ACPT_TYPE  = '1' THEN
      IF AV_USER_ID IS NULL THEN
        AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG      := '柜员编号不能为空';
        RETURN;
      END IF;
      PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_ACPT_ID,AV_USER_ID,AV_SYS_USERS,AV_RES,AV_MSG,'柜员信息');
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
    ELSIF AV_ACPT_TYPE = '2' THEN
      BEGIN
        SELECT * INTO AV_BASE_CO_ORG FROM BASE_CO_ORG WHERE CO_ORG_ID = AV_ACPT_ID;
        PK_PUBLIC.P_GETORGOPERATOR(AV_ACPT_ID,AV_SYS_USERS,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '根据合作机构编号' || AV_ACPT_ID || '找不到合作机构信息';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '根据合作机构编号' || AV_ACPT_ID || '获取合作机构信息出现错误' || SQLERRM;
      END;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '受理点类型不正确';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_JUDGE_ACPT;
--个人登录
  PROCEDURE P_LOGIN_GR(
      AV_CARD_NO VARCHAR2,   --卡号
      AV_CERT_NO VARCHAR2,   --证件号码
      AV_TELNO   VARCHAR2,   --手机号码
      AV_PWD     VARCHAR2,   --登录密码
      AV_CERTNO OUT VARCHAR2,--证件号
      AV_RES OUT VARCHAR2,   --处理结果代码
      AV_MSG OUT VARCHAR2    --处理结果说明
    )
  IS
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE;
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE;
    LV_CARD_APPLY CARD_APPLY%ROWTYPE;
  BEGIN
    IF AV_CARD_NO IS NULL AND AV_CERT_NO IS NULL AND AV_TELNO IS NULL THEN
      AV_RES      := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG      := '登录编号不能为空';
      RETURN;
    END IF;
    IF AV_PWD IS NULL THEN
      AV_RES  := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG  := '登录密码不能为空';
      RETURN;
    END IF;
    IF AV_CARD_NO                IS NOT NULL THEN
      IF LENGTH(AV_CARD_NO)      <= 15 THEN
        LV_CARD_BASEINFO.CARD_NO := PK_SERVICE_OUTER.F_GETCARDNO_BY_SUBCARDNO(AV_CARD_NO, LV_CARD_APPLY);
      ELSE
        LV_CARD_BASEINFO.CARD_NO := AV_CARD_NO;
      END IF;
      IF LV_CARD_BASEINFO.CARD_NO = '0' THEN
        AV_RES                   := PK_PUBLIC.CS_RES_CARDIDERR;
        AV_MSG                   := '卡号信息不存在';
        RETURN;
      ELSIF LV_CARD_BASEINFO.CARD_NO = '-1' THEN
        AV_RES                      := PK_PUBLIC.CS_RES_CARDIDERR;
        AV_MSG                      := '根据卡号获取卡信息出现错误';
        RETURN;
      END IF;
      PK_PUBLIC.P_GETCARDBYCARDNO(LV_CARD_BASEINFO.CARD_NO, LV_CARD_BASEINFO, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG  := REPLACE(AV_MSG, LV_CARD_APPLY.CARD_NO, AV_CARD_NO);
        RETURN;
      END IF;
      IF LV_CARD_BASEINFO.CUSTOMER_ID IS NULL THEN
        AV_RES                        := PK_PUBLIC.CS_RES_PERSONALVIL_ERR;
        AV_MSG                        := '根据卡号找不到持卡人信息';
        RETURN;
      END IF;
      IF LV_CARD_APPLY.CUSTOMER_ID <> LV_CARD_BASEINFO.CUSTOMER_ID THEN
        AV_RES                     := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG                     := '卡号' || LV_CARD_BASEINFO.CARD_NO || '的持有人和申领记录信息不一致';
        RETURN;
      END IF;
      PK_PUBLIC.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_RES  := PK_PUBLIC.CS_RES_PERSONALVIL_ERR;
        AV_MSG  := '根据卡片持有人编号找不到人员信息';
        RETURN;
      END IF;
    ELSIF AV_CERT_NO IS NOT NULL THEN
      PK_PUBLIC.P_GETBASEPERSONALBYCERTNO(AV_CERT_NO, LV_BASE_PERSONAL, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_RES  := PK_PUBLIC.CS_RES_PERSONALVIL_ERR;
        AV_MSG  := '根据证件号码找不到人员信息';
        RETURN;
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG := '登录编号不能为空';
      RETURN;
    END IF;
    IF NVL(LV_BASE_PERSONAL.SERV_PWD_ERR_NUM, 0) >= PK_PUBLIC.CS_SERV_PWD_ERR_NUM THEN
      AV_RES                                     := PK_PUBLIC.CS_RES_PWDERRNUM;
      AV_MSG                                     := '密码输错超过超限';
      RETURN;
    END IF;
    IF NVL(LV_BASE_PERSONAL.SERV_PWD, '-1') = '-1' THEN
      AV_RES                               := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG                               := '密码信息不存在，请先至客户服务中心进行密码重置';
      RETURN;
    END IF;
    IF LV_BASE_PERSONAL.SERV_PWD = encrypt_des_oracle(AV_PWD,LV_BASE_PERSONAL.CERT_NO) THEN
      UPDATE BASE_PERSONAL
      SET SERV_PWD_ERR_NUM = 0
      WHERE CUSTOMER_ID    = LV_BASE_PERSONAL.CUSTOMER_ID;
      COMMIT;
      AV_CERTNO:=LV_BASE_PERSONAL.Cert_No;
      AV_RES   := PK_PUBLIC.CS_RES_OK;
      AV_MSG   := '';
    ELSE
      UPDATE BASE_PERSONAL
      SET SERV_PWD_ERR_NUM = NVL(SERV_PWD_ERR_NUM, 0) + 1
      WHERE CUSTOMER_ID    = LV_BASE_PERSONAL.CUSTOMER_ID;
      COMMIT;
      AV_RES := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG := '密码不正确';
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_LOGIN_GR;
--合作机构登录
  PROCEDURE P_LOGIN_CO_ORG(
      AV_CO_ORG_ID VARCHAR2, --合作机构编号
      AV_PWD       VARCHAR2, --密码
      AV_RES OUT VARCHAR2,   --结果代码
      AV_MSG OUT VARCHAR2)   --结果说明
  IS
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
  BEGIN
    IF AV_CO_ORG_ID IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '合作机构编号不能为空';
      RETURN;
    END IF;
    IF AV_PWD IS NULL THEN
      AV_RES  := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG  := '密码不能为空';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO LV_BASE_CO_ORG FROM BASE_CO_ORG WHERE co_org_id = AV_CO_ORG_ID;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_BASECO_NOFOUNDERR;
      AV_MSG := '根据合作机构编号' || AV_CO_ORG_ID || '找不到合作机构信息';
      RETURN;
    WHEN TOO_MANY_ROWS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '合作机构编号' || AV_CO_ORG_ID || '存在多条记录信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
      RETURN;
    END;
    IF NVL(LV_BASE_CO_ORG.CO_STATE, '-1') <> '0' THEN
      AV_RES                              := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                              := '合作机构状态不正常';
      RETURN;
    END IF;
    IF NVL(LV_BASE_CO_ORG.Serv_Pwd_Err_Num, 0) >= PK_PUBLIC.CS_CO_ORG_SERV_PWD_ERR_NUM THEN
      AV_RES                                  := PK_PUBLIC.CS_RES_PWDERRNUM;
      AV_MSG                                  := '密码输错超过超限';
      RETURN;
    END IF;
    IF NVL(LV_BASE_CO_ORG.Serv_Pwd, '-1') = '-1' THEN
      AV_RES                             := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG                             := '密码信息不存在，请先至客户服务中心进行密码重置';
      RETURN;
    END IF;
    IF LV_BASE_CO_ORG.Serv_Pwd = encrypt_des_oracle(AV_PWD,LV_BASE_CO_ORG.Customer_Id) THEN
      UPDATE BASE_CO_ORG
      SET Serv_Pwd_Err_Num = 0
      WHERE CO_ORG_ID     = LV_BASE_CO_ORG.CO_ORG_ID;
      COMMIT;
      AV_RES := PK_PUBLIC.CS_RES_OK;
      AV_MSG := '';
    ELSE
      UPDATE BASE_CO_ORG
      SET Serv_Pwd_Err_Num = NVL(Serv_Pwd_Err_Num, 0) + 1
      WHERE CO_ORG_ID     = LV_BASE_CO_ORG.CO_ORG_ID;
      COMMIT;
      AV_RES := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG := '密码不正确';
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
    RETURN;
  END P_LOGIN_CO_ORG;
--密码修改
--1acpt_id 受理点编号
--2acpt_type 受理点类型
--3oper_id 操作员
--4trim_no 终端业务流水
--5cert_no 证件号码
--6card_no 卡号
--7pwd_type 密码类型 1服务密码,2交易密码,
--8old_pwd 老密码
--9pwd 新密码
--10agt_cert_type 代理人证件号码
--11agt_cert_no 代理人证件类型
--12agt_name 代理人姓名
--13agt_telno 代理人电话号码  10010001|1|admin|123|412822198605264479||1|111|111|||||
  PROCEDURE P_PWD_MODIFY(
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2)
  IS
    LV_IN PK_PUBLIC.MYARRAY;
    LV_CLR_DATE PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE;
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE;
    LV_CARD_NO CARD_BASEINFO.CARD_NO%TYPE;
    LV_CARD_APPLY CARD_APPLY%ROWTYPE;
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_TR_SERV_REC TR_SERV_REC%ROWTYPE;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,6,13,'PK_SERVICE_OUTER.P_PWD_MODIFY',lv_in,av_res,av_msg);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    PK_SERVICE_OUTER.P_JUDGE_ACPT(LV_IN(1),LV_IN(2),LV_IN(3),LV_USERS,LV_BASE_CO_ORG,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '密码类型不正确';
      RETURN;
    ELSIF LV_IN(7) NOT IN ('1', '2') THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '密码类型不正确';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '原始密码不能为空';
      RETURN;
    END IF;
    IF LV_IN(9) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '新密码不能为空';
      RETURN;
    END IF;
    IF LV_IN(7)    = '1' THEN
      IF LV_IN(5) IS NOT NULL THEN
        PK_PUBLIC.P_GETBASEPERSONALBYCERTNO(LV_IN(5),LV_BASE_PERSONAL,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
      ELSIF lv_in(6)        IS NOT NULL THEN
        IF LENGTH(LV_IN(6)) >= 20 THEN
          LV_CARD_NO        := LV_IN(6);
        ELSE
          LV_CARD_NO := PK_SERVICE_OUTER.F_GETCARDNO_BY_SUBCARDNO(LV_IN(6),LV_CARD_APPLY);
          IF LV_CARD_NO IN ('0','-1') THEN
            AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
            AV_MSG := '根据卡号' || LV_IN(6) || '找不到卡信息';
            RETURN;
          END IF;
        END IF;
        BEGIN
          SELECT T.*
          INTO LV_BASE_PERSONAL
          FROM BASE_PERSONAL T
          WHERE T.CUSTOMER_ID =
            (SELECT C.CUSTOMER_ID FROM CARD_BASEINFO C WHERE C.CARD_NO = LV_IN(6)
            );
        EXCEPTION
        WHEN no_data_found THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据卡号' || LV_IN(6) || '找不到人员信息';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据卡号' || LV_IN(6) || '获取人员信息出现错误:' || SQLERRM;
          RETURN;
        END;
      ELSE
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '服务密码修改，证件号码或卡号不能全部为空';
        RETURN;
      END IF;
      PK_PUBLIC.P_JUDGESERVICEPWD(LV_BASE_PERSONAL.CERT_NO, LV_BASE_PERSONAL.NAME, ENCRYPT_DES_oracle(LV_IN(8),LV_BASE_PERSONAL.CERT_NO), AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      ELSE
        UPDATE BASE_PERSONAL
        SET SERV_PWD       = encrypt_des_oracle(LV_IN(9),LV_BASE_PERSONAL.Cert_No),
          SERV_PWD_ERR_NUM = 0
        WHERE CUSTOMER_ID  = LV_BASE_PERSONAL.CUSTOMER_ID;
      END IF;
    ELSIF LV_IN(7) = '2' THEN
      IF LV_IN(6) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG    := '交易密码修改，卡号不能为空';
        RETURN;
      END IF;
      IF LENGTH(LV_IN(6)) < 20 THEN
        LV_CARD_NO       := PK_SERVICE_OUTER.F_GETCARDNO_BY_SUBCARDNO(LV_IN(6),LV_CARD_APPLY);
        IF LV_CARD_NO IN ('-1', '0') THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据卡号' || LV_IN(6) || '找不到卡信息';
          RETURN;
        END IF;
      ELSE
        LV_CARD_NO := LV_IN(6);
      END IF;
      PK_PUBLIC.P_GETCARDBYCARDNO(LV_CARD_NO,LV_CARD_BASEINFO,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      IF LV_CARD_BASEINFO.CUSTOMER_ID IS NOT NULL THEN
        PK_PUBLIC.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID,LV_BASE_PERSONAL,AV_RES,AV_MSG);
      END IF;
      PK_PUBLIC.P_JUDGEPAYPWD(LV_CARD_NO, LV_IN(8), AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      ELSE
        UPDATE CARD_BASEINFO B SET B.PAY_PWD = LV_IN(9) WHERE CARD_NO = LV_CARD_NO;
      END IF;
    END IF;
    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYSACTIONLOG.DEAL_NO FROM DUAL;
    IF LV_IN(7)                  = '1' THEN
      LV_SYSACTIONLOG.DEAL_CODE := '20502020';
      LV_SYSACTIONLOG.MESSAGE   := '服务密码修改,证件号码:' || lv_in(5) || ',姓名:' || LV_BASE_PERSONAL.NAME;
    ELSE
      LV_SYSACTIONLOG.DEAL_CODE := '20502040';
      LV_SYSACTIONLOG.MESSAGE   := '交易密码修改,卡号:' || lv_in(6);
    END IF;
    LV_SYSACTIONLOG.DEAL_TIME   := SYSDATE;
    LV_SYSACTIONLOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYSACTIONLOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYSACTIONLOG.LOG_TYPE    := 0;
    LV_SYSACTIONLOG.IN_OUT_DATA := AV_IN;
    LV_SYSACTIONLOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
    LV_SYSACTIONLOG.ORG_ID      := LV_USERS.ORG_ID;
    INSERT INTO SYS_ACTION_LOG VALUES LV_SYSACTIONLOG;
    LV_TR_SERV_REC.DEAL_NO       := LV_SYSACTIONLOG.DEAL_NO;
    LV_TR_SERV_REC.Acpt_Type     := lv_in(2);
    LV_TR_SERV_REC.DEAL_CODE     := LV_SYSACTIONLOG.DEAL_CODE;
    LV_TR_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
    LV_TR_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
    LV_TR_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
    LV_TR_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
    LV_TR_SERV_REC.TEL_NO        := LV_BASE_PERSONAL.PHONE_NO;
    IF LV_IN(2)                   = '2' THEN
      LV_TR_SERV_REC.TERM_ID     := NVL(LV_IN(3), '');
      LV_TR_SERV_REC.CO_ORG_ID   := NVL(LV_BASE_CO_ORG.CO_ORG_ID, '');
      LV_TR_SERV_REC.END_DEAL_NO := NVL(LV_IN(4), '');
    END IF;
    LV_TR_SERV_REC.BIZ_TIME      := LV_SYSACTIONLOG.DEAL_TIME;
    LV_TR_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
    LV_TR_SERV_REC.USER_ID       := LV_USERS.USER_ID;
    LV_TR_SERV_REC.CLR_DATE      := LV_CLR_DATE;
    LV_TR_SERV_REC.CARD_AMT      := '1';
    LV_TR_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
    LV_TR_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
    LV_TR_SERV_REC.CARD_TYPE     := LV_CARD_BASEINFO.CARD_TYPE;
    LV_TR_SERV_REC.NOTE          := LV_SYSACTIONLOG.MESSAGE;
    LV_TR_SERV_REC.NUM           := 1;
    LV_TR_SERV_REC.DEAL_STATE    := '0';
    LV_TR_SERV_REC.AGT_CERT_NO   := NVL(LV_IN(10), '');
    LV_TR_SERV_REC.AGT_CERT_TYPE := NVL(LV_IN(11), '');
    LV_TR_SERV_REC.AGT_NAME      := NVL(LV_IN(12), '');
    LV_TR_SERV_REC.AGT_TEL_NO    := NVL(LV_IN(13), '');
    INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
    AV_RES := PK_PUBLIC.cs_res_ok;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_PWD_MODIFY;
--挂失
--1受理点编号/网点编号 brch_id/acpt_id 必填
--2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
--3终端编号/柜员编号 user_id/end_id 必填
--4终端操作流水/业务流水 deal_no/end_deal_no 必填
--5证件号码 cert_no
--6卡号 card_no
--7挂失类型 loss_type  2口挂挂失  3 书面挂失
--8代理人证件类型
--9代理人证件号码
--10代理人姓名
--11代理人联系电话
--12备注note
--返回结果
--av_res 返回结果代码
--av_msg 返回结果说明
--av_out 输出结果
--测试 10011001|1|admin||4128222198605264479||3|||||test|
  PROCEDURE P_CARD_LOSS
    (
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2,
      AV_OUT OUT VARCHAR2
    )
  IS
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE; --个人信息表
    LV_SERV_REC TR_SERV_REC%ROWTYPE;        -- 综合业务日志表
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE; --卡表
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_SQL VARCHAR2(500) := '';
    LV_IN PK_PUBLIC.MYARRAY;
    LV_CUR PK_PUBLIC.T_CUR;
    LV_CLR_DATE VARCHAR2(10);
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_OUT_STR VARCHAR2(500) := '';
    LV_COUNT   NUMBER        := 0;
  BEGIN
    --1.参数解析
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,6,12,'PK_SERVICE_OUTER.P_CARD_LOSS',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --2.受理点判断
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),LV_IN(2),LV_IN(3),LV_USERS,LV_BASE_CO_ORG,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL AND LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '证件号码和卡号不能都为空';
      RETURN;
    END IF;
    LV_SQL      := 'SELECT * FROM CARD_BASEINFO WHERE CARD_STATE IN (''1'',''3'',''2'') ';
    IF LV_IN(5) IS NOT NULL THEN
      LV_SQL    := LV_SQL || 'AND CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM BASE_PERSONAL WHERE CERT_NO = ''' || NVL(LV_IN(5), '') || ''') ';
    END IF;
    IF LV_IN(6)          IS NOT NULL THEN
      IF LENGTH(LV_IN(6)) < 20 THEN
        LV_SQL           := LV_SQL || 'AND SUB_CARD_NO = ''' || LV_IN(6) || '''';
      ELSE
        LV_SQL := LV_SQL || 'AND CARD_NO = ''' || LV_IN(6) || '''';
      END IF;
    END IF;
    IF NVL(LV_IN(7), '0')        = '2' THEN
      LV_SYSACTIONLOG.DEAL_CODE := '20501050';
      LV_SYSACTIONLOG.MESSAGE   := '口头挂失';
    ELSIF NVL(LV_IN(7), '0')     = '3' THEN
      LV_SYSACTIONLOG.DEAL_CODE := '20501040';
      LV_SYSACTIONLOG.MESSAGE   := '书面挂失';
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '挂失类型不正确';
      RETURN;
    END IF;
    IF LV_IN(12)              IS NOT NULL THEN
      LV_SYSACTIONLOG.MESSAGE := LV_SYSACTIONLOG.MESSAGE || ',' || NVL(LV_IN(12), '');
    END IF;
    LV_SYSACTIONLOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYSACTIONLOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYSACTIONLOG.LOG_TYPE    := 0;
    LV_SYSACTIONLOG.IN_OUT_DATA := AV_IN;
    LV_SYSACTIONLOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
    LV_SYSACTIONLOG.DEAL_TIME   := SYSDATE;
    OPEN LV_CUR FOR LV_SQL;
    LOOP
      FETCH LV_CUR INTO LV_CARD_BASEINFO;
      EXIT
    WHEN LV_CUR%NOTFOUND;
      LV_COUNT                      := LV_COUNT + 1;
      IF LV_CARD_BASEINFO.CARD_STATE = '3' THEN
        GOTO GS_END;
      END IF;
      SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYSACTIONLOG.DEAL_NO FROM DUAL;
      LV_SYSACTIONLOG.MESSAGE := LV_SYSACTIONLOG.MESSAGE || ',卡号:' || LV_CARD_BASEINFO.CARD_NO;
      INSERT INTO SYS_ACTION_LOG VALUES LV_SYSACTIONLOG;
      UPDATE CARD_BASEINFO V
      SET V.CARD_STATE     = LV_IN(7),
        V.LAST_MODIFY_DATE = LV_SYSACTIONLOG.DEAL_TIME
      WHERE CARD_NO        = LV_CARD_BASEINFO.CARD_NO;
      UPDATE ACC_ACCOUNT_SUB B
      SET B.LSS_DATE = LV_SYSACTIONLOG.DEAL_TIME,
        B.ACC_STATE  = LV_IN(7)
      WHERE CARD_NO  = LV_CARD_BASEINFO.CARD_NO;
      PK_SERVICE_OUTER.P_CARD_BLACK(LV_SYSACTIONLOG.DEAL_NO,LV_CARD_BASEINFO.CARD_NO,'0','03',TO_CHAR(LV_SYSACTIONLOG.DEAL_TIME,'YYYYMMDDHH24MISS'),AV_RES,AV_MSG);
      --记综合业务
      IF LV_CARD_BASEINFO.CUSTOMER_ID IS NOT NULL THEN
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID,LV_BASE_PERSONAL,AV_RES,AV_MSG);
      END IF;
      IF LV_CARD_BASEINFO.CARD_TYPE IN ('100','120') THEN
        PK_CARD_APPLY_ISSUSE.P_SYNCH2CARD_UPATE(NULL,LV_BASE_PERSONAL.CERT_NO,LV_CARD_BASEINFO.CARD_NO,NULL,LV_SYSACTIONLOG.DEAL_NO,NULL,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
      END IF;
      LV_SERV_REC.DEAL_NO       := LV_SYSACTIONLOG.DEAL_NO;
      LV_SERV_REC.DEAL_CODE     := LV_SYSACTIONLOG.DEAL_CODE;
      LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
      LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
      LV_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
      LV_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
      LV_SERV_REC.TEL_NO        := LV_BASE_PERSONAL.PHONE_NO;
      LV_SERV_REC.Acpt_Type     := lv_in(2);
      IF LV_IN(2)                = '2' THEN
        LV_SERV_REC.TERM_ID     := NVL(LV_IN(3), '');
        LV_SERV_REC.CO_ORG_ID   := NVL(LV_BASE_CO_ORG.CO_ORG_ID, '');
        LV_SERV_REC.END_DEAL_NO := NVL(LV_IN(4), '');
      END IF;
      LV_SERV_REC.BIZ_TIME      := LV_SYSACTIONLOG.DEAL_TIME;
      LV_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
      LV_SERV_REC.USER_ID       := LV_USERS.USER_ID;
      LV_SERV_REC.CLR_DATE      := LV_CLR_DATE;
      LV_SERV_REC.CARD_AMT      := '1';
      LV_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
      LV_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
      LV_SERV_REC.CARD_TYPE     := LV_CARD_BASEINFO.CARD_TYPE;
      LV_SERV_REC.NOTE          := LV_SYSACTIONLOG.MESSAGE;
      LV_SERV_REC.NUM           := 1;
      LV_SERV_REC.Deal_State    := '0';
      LV_SERV_REC.AGT_CERT_TYPE := NVL(LV_IN(8), '');
      LV_SERV_REC.AGT_CERT_NO   := NVL(LV_IN(9), '');
      LV_SERV_REC.AGT_NAME      := NVL(LV_IN(10), '');
      LV_SERV_REC.AGT_TEL_NO    := NVL(LV_IN(11), '');
      INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
      LV_OUT_STR := LV_OUT_STR || LV_SERV_REC.DEAL_NO || '%' || LV_CARD_BASEINFO.CARD_NO || '%' || LV_BASE_PERSONAL.CERT_NO || '%,';
      <<GS_END>>
      NULL;
    END LOOP;
    IF LV_COUNT < 1 THEN
      AV_RES   := PK_PUBLIC.CS_RES_CARDIDERR;
      AV_MSG   := '根据证件号码或卡号找不到卡信息或卡已注销无法进行挂失';
      RETURN;
    END IF;
    AV_OUT := SUBSTR(LV_OUT_STR, 1, LENGTH(LV_OUT_STR) - 1);
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_CARD_LOSS;
-- 解挂
--1受理点编号/网点编号 brch_id/acpt_id 必填
--2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
--3终端编号/柜员编号 user_id/end_id 必填
--4终端操作流水/业务流水 deal_no/end_deal_no 必填
--5证件号码 cert_no
--6卡号 card_no
--7代理人证件类型
--8代理人证件号码
--9代理人姓名
--10代理人联系电话
--11备注note
--返回结果
--av_res 返回结果代码
--av_msg 返回结果说明
--av_out 输出结果
--测试 100102001000018|2||12345|33042519640701482X||1|412822198605264479|yangn|18668112868|test|
  PROCEDURE P_CARD_UNLOCK
    (
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2,
      AV_OUT OUT VARCHAR2
    )
  IS
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE; --个人信息表
    LV_SERV_REC TR_SERV_REC%ROWTYPE;        -- 综合业务日志表
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE; --卡表
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_SQL VARCHAR2(500) := '';
    LV_IN PK_PUBLIC.MYARRAY;
    LV_CUR PK_PUBLIC.T_CUR;
    LV_CLR_DATE VARCHAR2(10);
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_OUT_STR VARCHAR2(500) := '';
    LV_COUNT   NUMBER        := 0;
  BEGIN
    --1.参数解析
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,4,11,'PK_SERVICE_OUTER.P_CARD_UNLOCK',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --2.受理点判断
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),LV_IN(2),LV_IN(3),LV_USERS,LV_BASE_CO_ORG,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL AND LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '证件号码和卡号不能都为空';
      RETURN;
    END IF;
    LV_SQL      := 'SELECT * FROM CARD_BASEINFO WHERE CARD_STATE IN (''2'',''3'',''1'') ';
    IF LV_IN(5) IS NOT NULL THEN
      LV_SQL    := LV_SQL || 'AND CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM BASE_PERSONAL WHERE CERT_NO = ''' || NVL(LV_IN(5), '') || ''') ';
    END IF;
    IF LV_IN(6)          IS NOT NULL THEN
      IF LENGTH(LV_IN(6)) < 20 THEN
        LV_SQL           := LV_SQL || 'AND SUB_CARD_NO = ''' || LV_IN(6) || '''';
      ELSE
        LV_SQL := LV_SQL || 'AND CARD_NO = ''' || LV_IN(6) || '''';
      END IF;
    END IF;
    IF LV_IN(11)              IS NOT NULL THEN
      LV_SYSACTIONLOG.MESSAGE := LV_SYSACTIONLOG.MESSAGE || ',' || NVL(LV_IN(11), '');
    END IF;
    LV_SYSACTIONLOG.DEAL_CODE   := '20501060';
    LV_SYSACTIONLOG.MESSAGE     := '解挂';
    LV_SYSACTIONLOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYSACTIONLOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYSACTIONLOG.LOG_TYPE    := 0;
    LV_SYSACTIONLOG.IN_OUT_DATA := AV_IN;
    LV_SYSACTIONLOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
    LV_SYSACTIONLOG.ORG_ID      := LV_USERS.ORG_ID;
    LV_SYSACTIONLOG.DEAL_TIME   := SYSDATE;
    OPEN LV_CUR FOR LV_SQL;
    LOOP
      FETCH LV_CUR INTO LV_CARD_BASEINFO;
      EXIT
    WHEN LV_CUR%NOTFOUND;
      LV_COUNT                      := LV_COUNT + 1;
      IF LV_CARD_BASEINFO.CARD_STATE = '1' THEN
        GOTO JS_END;
      END IF;
      SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYSACTIONLOG.DEAL_NO FROM DUAL;
      LV_SYSACTIONLOG.MESSAGE := LV_SYSACTIONLOG.MESSAGE || ',卡号:' || LV_CARD_BASEINFO.CARD_NO;
      INSERT INTO SYS_ACTION_LOG VALUES LV_SYSACTIONLOG;
      UPDATE CARD_BASEINFO V
      SET V.CARD_STATE     = '1',
        V.LAST_MODIFY_DATE = LV_SYSACTIONLOG.DEAL_TIME
      WHERE card_no        = lv_card_baseinfo.card_no;
      UPDATE ACC_ACCOUNT_SUB B
      SET B.LSS_DATE = NULL,
        B.ACC_STATE  = '1'
      WHERE CARD_NO  = LV_CARD_BASEINFO.CARD_NO;
      PK_SERVICE_OUTER.P_CARD_BLACK(LV_SYSACTIONLOG.DEAL_NO,LV_CARD_BASEINFO.CARD_NO,'1','',TO_CHAR(LV_SYSACTIONLOG.DEAL_TIME,'yyyymmddhh24miss'),AV_RES,AV_MSG);
      --记综合业务
      IF LV_CARD_BASEINFO.CUSTOMER_ID IS NOT NULL THEN
        PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID,LV_BASE_PERSONAL,AV_RES,AV_MSG);
      END IF;
      IF LV_CARD_BASEINFO.CARD_TYPE IN ('100','120') THEN
        PK_CARD_APPLY_ISSUSE.P_SYNCH2CARD_UPATE(NULL,LV_BASE_PERSONAL.CERT_NO,LV_CARD_BASEINFO.CARD_NO,NULL,LV_SYSACTIONLOG.DEAL_NO,NULL,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
      END IF;
      LV_SERV_REC.Acpt_Type     := lv_in(2);
      LV_SERV_REC.DEAL_NO       := LV_SYSACTIONLOG.DEAL_NO;
      LV_SERV_REC.DEAL_CODE     := LV_SYSACTIONLOG.DEAL_CODE;
      LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
      LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
      LV_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
      LV_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
      LV_SERV_REC.TEL_NO        := LV_BASE_PERSONAL.PHONE_NO;
      IF LV_IN(2)                = '2' THEN
        LV_SERV_REC.TERM_ID     := NVL(LV_IN(3), '');
        LV_SERV_REC.CO_ORG_ID   := NVL(LV_BASE_CO_ORG.CO_ORG_ID, '');
        LV_SERV_REC.END_DEAL_NO := NVL(LV_IN(4), '');
      END IF;
      LV_SERV_REC.BIZ_TIME      := LV_SYSACTIONLOG.DEAL_TIME;
      LV_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
      LV_SERV_REC.USER_ID       := LV_USERS.USER_ID;
      LV_SERV_REC.CLR_DATE      := LV_CLR_DATE;
      LV_SERV_REC.CARD_AMT      := '1';
      LV_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
      LV_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
      LV_SERV_REC.CARD_TYPE     := LV_CARD_BASEINFO.CARD_TYPE;
      LV_SERV_REC.NOTE          := LV_SYSACTIONLOG.MESSAGE;
      LV_SERV_REC.NUM           := 1;
      LV_SERV_REC.Deal_State    := '0';
      LV_SERV_REC.AGT_CERT_TYPE := NVL(LV_IN(7), '');
      LV_SERV_REC.AGT_CERT_NO   := NVL(LV_IN(8), '');
      LV_SERV_REC.AGT_NAME      := NVL(LV_IN(9), '');
      LV_SERV_REC.AGT_TEL_NO    := NVL(LV_IN(10), '');
      INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
      LV_OUT_STR := LV_OUT_STR || LV_SERV_REC.DEAL_NO || '%' || LV_CARD_BASEINFO.CARD_NO || '%' || LV_BASE_PERSONAL.CERT_NO || '%,';
      <<JS_END>>
      NULL;
    END LOOP;
    IF LV_COUNT < 1 THEN
      AV_RES   := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG   := '根据证件号码,卡号找不到卡信息或卡已注销无法进行解挂';
      RETURN;
    END IF;
    AV_OUT := SUBSTR(LV_OUT_STR, 1, LENGTH(LV_OUT_STR) - 1);
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_CARD_UNLOCK;
--补换卡
--av_in:
--1受理点编号/网点编号
--2受理点类型 acpt_type (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
--3终端编号/柜员编号
--4终端操作流水
--5原卡卡号
--6新卡卡号
--7银行卡卡号
--8姓名
--9证件类型
--10证件号码
--11是否好卡 0好卡 坏卡：1
--12卡面金额 根据参数10 如果是0 好卡 则传递卡面金额 如果是 1坏卡 传递0 金额单位：分,如果是好卡则在换卡转钱包时 转账此金额
--13回收状态：回收：0 未回收：1
--14补换卡标志 0 补卡 1 换卡
--15换卡时 传递换卡原因 01换卡原因_质量问题,02换卡原因_损坏,05换卡原因_有效期满,99换卡原因_其他
--16补换卡工本费 金额单位：分
--17代理人证件类型
--18代理人证件号码
--19代理人姓名
--20代理人联系电话
--21备注
--22统筹区域
  PROCEDURE p_cardtrans
    (
      av_in    IN VARCHAR2,
      av_debug IN VARCHAR2,
      av_out OUT VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2
    )
  IS
    lv_count NUMBER;
    lv_in pk_public.myarray;                          --传入参数数组
    lv_deal_no sys_action_log.deal_no%type;           --流水号
    lv_old_card_apply card_apply%rowtype;             --旧卡的申领记录
    lv_old_cardinfo card_baseinfo%rowtype;            --老卡信息
    lv_new_card_apply card_apply%rowtype;             --新申领记录
    lv_clrdate pay_clr_para%rowtype;                  --清分日期
    lv_users sys_users%rowtype;                       --操作员
    lv_base_co_org base_co_org%rowtype;               --合作结构信息
    lv_action_log sys_action_log%rowtype;             --操作日志
    lv_serv_rec tr_serv_rec%rowtype;                  --综合业务日志
    lv_base_personal base_personal%rowtype;           --人员基础信息
    lv_card_task_list card_task_list%rowtype;         --制卡任务明细信息
    lv_card_apply_task card_apply_task%rowtype;       --制卡任务信息
    lv_cancel_reason card_baseinfo.cancel_reason%type;--注销原因
    lv_selfmanagement sys_para.para_value%type;       --是否自管卡标识
    lv_cost_para VARCHAR2(1000) := '';                --工本费扣费组装字符串
    lv_card_config card_config%rowtype;               --卡参数信息
    lv_stock_sql VARCHAR2(200) := '';                 --库存操作组装字符串
    lv_card_no card_apply.card_no%type;               --卡号
    lv_card_bind_bankcard card_bind_bankcard%rowtype; --银行卡绑定记录
    lv_card_task_imp_bcp card_task_imp_bcp%rowtype;   --半成品卡信息
    lv_new_card_apply_task card_apply_task%rowtype;   --新申领任务
    lv_start_date VARCHAR2(8);                        --新申领的发卡日期
    lv_valid_date VARCHAR2(8);                        --新发卡的有效期
    lv_bhk_type card_apply.bhk_type%type;
    lv_base_siinfo base_siinfo%ROWTYPE;
  BEGIN
    lv_selfmanagement   := pk_public.f_getsyspara('SELFMANAGEMENTCARD');
    IF lv_selfmanagement = '0' OR lv_selfmanagement = '-1' THEN
      av_res            := pk_public.cs_res_paravalueerr;
      av_msg            := '是否自管卡参数设置错误';
      RETURN;
    END IF;
    pk_public.p_getinputpara(av_in,12,22,'PK_SERVICE_OUTER.P_CARDTRANS',lv_in,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(2) NOT IN ('1','2') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '受理点类型不正确';
      RETURN;
    END IF;
    IF lv_in(5) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '老卡卡号不能为空';
      RETURN;
    END IF;
    IF lv_in(7) IS NULL AND lv_in(2) <> '1' THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '银行卡卡号不能为空';
      RETURN;
    END IF;
    IF lv_in(11) IS NULL THEN
      av_res     := pk_public.cs_res_paravalueerr;
      av_msg     := '是否好卡参数不能为空';
      RETURN;
    elsif lv_in(11) NOT IN ('0','1') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '是否好卡标识只能是0或1';
      RETURN;
    END IF;
    IF lv_in(13) IS NULL THEN
      av_res     := pk_public.cs_res_paravalueerr;
      av_msg     := '卡片回收状态不能为空';
      RETURN;
    elsif lv_in(13) NOT IN ('0','1') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '卡片回收状态参数只能是0或1';
      RETURN;
    END IF;
    IF lv_in(14) IS NULL THEN
      av_res     := pk_public.cs_res_paravalueerr;
      av_msg     := '补换卡标识不正确';
      RETURN;
    elsif lv_in(14) NOT IN ('0','1') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '补换卡标识只能是0或1';
      RETURN;
    END IF;
    IF lv_in(22) IS NULL THEN 
       av_res := pk_public.cs_res_paravalueerr;
      av_msg := '统筹区域编号不能为空';
      RETURN;
    END IF;
    pk_card_apply_issuse.p_judge_acpt(lv_in(1),lv_in(2),lv_in(3),lv_users,lv_base_co_org,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_card_apply_issuse.p_getcardconfigbycardtype(pk_public.card_type_smzk,lv_card_config,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_card_config.card_validity_period IS NULL THEN
      av_res                               := pk_public.cs_res_not_cardconfig;
      av_msg                               := '卡片有效期参数信息设置不正确';
      RETURN;
    END IF;
    lv_start_date                   := TO_CHAR(sysdate,'YYYYMMDD');
    lv_valid_date                   := TO_CHAR(add_months(sysdate,lv_card_config.card_validity_period * 12),'YYYYMMDD');
    IF lv_selfmanagement             = 'N' THEN
      lv_new_card_apply.apply_state := '50';
      IF lv_in(6)                   IS NULL THEN
        av_res                      := pk_public.cs_res_paravalueerr;
        av_msg                      := '新卡卡号不能为空';
        RETURN;
      END IF;
      lv_count := 0;
      SELECT COUNT(1)
      INTO lv_count
      FROM card_baseinfo
      WHERE card_no  = lv_in(6)
      AND card_state > 0;
      IF lv_count    > 0 THEN
        av_res      := pk_public.cs_res_cardiderr;
        av_msg      := '新卡卡号验证失败，该卡已被使用';
        RETURN;
      END IF;
      BEGIN
        SELECT * INTO lv_card_task_list FROM card_task_list WHERE card_no = lv_in(6);
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_cardiderr;
        av_msg := '新卡卡号验证失败，新卡制卡明细不存在';
        RETURN;
      END;
      BEGIN
        SELECT *
        INTO lv_card_apply_task
        FROM card_apply_task
        WHERE task_id = lv_card_task_list.task_id;
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_cardiderr;
        av_msg := '新卡卡号验证失败，新卡所属任务不存在';
        RETURN;
      END;
    elsif lv_in(2)                   = '2' THEN
      lv_new_card_apply.apply_state := pk_public.kg_card_apply_yhshtg;
      pk_service_outer.p_getbcpcard(lv_in(7),lv_card_task_imp_bcp,av_res,av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      lv_count := 0;
      SELECT COUNT(1)
      INTO lv_count
      FROM card_baseinfo
      WHERE card_no  = lv_card_task_imp_bcp.card_no
      AND card_state > 0;
      IF lv_count    > 0 THEN
        av_res      := pk_public.cs_res_bcp_has_bind;
        av_msg      := '银行卡卡号对应的卡号已经启用';
        RETURN;
      END IF;
      BEGIN
        SELECT *
        INTO lv_card_task_list
        FROM card_task_list
        WHERE card_no                   = lv_card_task_imp_bcp.card_no;
        IF lv_card_task_list.card_type <> '390' THEN
          av_res                       := pk_public.cs_res_bcp_not_madecard;
          av_msg                       := '银行卡卡号对应的卡号不是半成品卡';
          RETURN;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_bcp_notmadecard_list;
        av_msg := '半成品卡采购明细不存在';
        RETURN;
      END;
      BEGIN
        SELECT *
        INTO lv_card_apply_task
        FROM card_apply_task
        WHERE task_id                    = lv_card_task_list.task_id;
        IF lv_card_apply_task.card_type <> '390' THEN
          av_res                        := pk_public.cs_res_bcp_not_madecard;
          av_msg                        := '银行卡卡号对应的卡号不是半成品卡';
          RETURN;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_bcp_notmadecard_task;
        av_msg := '半成品卡采购任务不存在';
        RETURN;
      END;
    ELSE
      lv_new_card_apply.apply_state := pk_public.kg_card_apply_ysq;
    END IF;
    pk_card_apply_issuse.p_get_base_personal(lv_in(10),lv_base_personal,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT COUNT(1)
    INTO lv_count
    FROM card_apply
    WHERE customer_id = lv_base_personal.customer_id
    AND (apply_state  < pk_public.kg_card_apply_yff
    AND apply_state  <> pk_public.kg_card_apply_wjwshbtg
    AND apply_state  <> pk_public.kg_card_apply_yhshbtg
    AND apply_state  <> pk_public.kg_card_apply_stshbtg);
    IF lv_count       > 0 THEN
      av_res         := pk_public.cs_res_unknownerr;
      av_msg         := '该人员已存在新申请制卡记录,不要重复进行补卡或换卡';
      RETURN;
    END IF;
    pk_card_apply_issuse.p_get_card_baseinfo(lv_in(5),lv_old_cardinfo,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_card_apply_issuse.p_get_bind_bankcard(lv_old_cardinfo.sub_card_no,lv_card_bind_bankcard,av_res,av_msg);
    IF lv_card_bind_bankcard.bank_card_no IS NOT NULL THEN
      IF lv_in(14)                         = '0' THEN
        IF lv_old_cardinfo.card_state     <> '3' THEN
          av_res                          := pk_public.cs_res_cardstateiserr;
          av_msg                          := '补卡验证卡信息失败，老卡不是书面挂失状态';
          RETURN;
        END IF;
      elsif lv_in(14)                  = '1' THEN
        IF lv_old_cardinfo.card_state <> '1' THEN
          av_res                      := pk_public.cs_res_cardstateiserr;
          av_msg                      := '补换卡验证卡信息失败，老卡状态不正常';
          RETURN;
        END IF;
      END IF;
    END IF;
    IF NVL(lv_old_cardinfo.customer_id, '1') <> NVL(lv_base_personal.customer_id,'0') THEN
      av_res                                 := pk_public.cs_res_personalvil_err;
      av_msg                                 := '客户信息验证失败，传入客户信息和卡片持有客户信息不一致';
      RETURN;
    END IF;
    pk_card_apply_issuse.p_getcardapplybycardno(lv_old_cardinfo.card_no,lv_old_card_apply,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_old_card_apply.customer_id <> lv_old_cardinfo.customer_id THEN
      av_res                         := pk_public.cs_res_personalvil_err;
      av_msg                         := '根据原卡号查询到的申领记录与原卡片持有人信息不符';
      RETURN;
    END IF;
    IF lv_in(2)    = '2' AND lv_old_card_apply.card_type = '120' AND lv_card_bind_bankcard.bank_card_no IS NOT NULL THEN
      IF lv_in(1) <> lv_old_card_apply.bank_id THEN
        av_res    := pk_public.cs_res_baseco_nofounderr;
        av_msg    := '原卡片所属银行与接入点银行不一致';
        RETURN;
      END IF;
    END IF;
    SELECT seq_action_no.nextval INTO lv_deal_no FROM dual;
    SELECT * INTO lv_clrdate FROM pay_clr_para;
    lv_action_log.deal_no          := lv_deal_no;
    IF lv_in(14)                    = '0' THEN
      lv_action_log.deal_code      := '20501010';
      lv_action_log.message        := '补卡：' || av_in;
      lv_action_log.note           := lv_action_log.message;
      lv_cancel_reason             := '3';
      lv_new_card_apply.apply_type := '2';
      lv_in(13)                    := '1';
    ELSE
      lv_action_log.deal_code      := '20501020';
      lv_action_log.message        := '换卡：' || av_in;
      lv_action_log.note           := lv_action_log.message;
      lv_cancel_reason             := '4';
      lv_new_card_apply.apply_type := '1';
      lv_in(13)                    := '0';
    END IF;
    lv_action_log.org_id      := lv_users.org_id;
    lv_action_log.brch_id     := lv_users.brch_id;
    lv_action_log.user_id     := lv_users.user_id;
    lv_action_log.deal_time   := sysdate;
    lv_action_log.log_type    := 0;
    lv_action_log.in_out_data := av_in;
    lv_action_log.co_org_id   := lv_base_co_org.co_org_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    --7.注销老卡 修改老卡的回收状态和最后修改时间,注销时间注销原因
    IF lv_old_cardinfo.card_state <> 9 THEN
      UPDATE card_baseinfo
      SET card_state     = '9',
        last_modify_date = lv_action_log.deal_time,
        cancel_date      = lv_action_log.deal_time,
        cancel_reason    = lv_cancel_reason,
        recover_flag     = NVL(lv_in(13),1) --默认未回收
      WHERE card_no      = lv_old_cardinfo.card_no;
      IF sql%rowcount   <> 1 THEN
        av_res          := pk_public.cs_res_oldcardnotexist_err;
        av_msg          := '更新老卡的卡状态不正确';
        RETURN;
      END IF;
      UPDATE acc_account_sub
      SET acc_state   = '9',
        cls_date      = lv_action_log.deal_time,
        cls_user_id   = lv_users.user_id,
        lss_date      = lv_action_log.deal_time
      WHERE card_no   = lv_old_cardinfo.card_no;
      IF sql%rowcount < 0 THEN
        av_res       := pk_public.cs_res_oldcardnotexist_err;
        av_msg       := '找不到老卡账户信息';
        RETURN;
      END IF;
    END IF;
    BEGIN
      SELECT * INTO lv_base_siinfo FROM base_siinfo t WHERE t.cert_no = lv_base_personal.cert_no AND t.med_whole_no = lv_in(22);
      IF lv_base_siinfo.med_state <> '0' THEN
          av_res       := pk_public.cs_res_oldcardnotexist_err;
            av_msg       := '该人员参保状态不正常';
            RETURN;
      END IF;
    EXCEPTION 
             WHEN no_data_found THEN 
                av_res       := pk_public.cs_res_oldcardnotexist_err;
              av_msg       := '该人员参保信息不存在，或参保信息不属于本区域';
              RETURN;
              WHEN too_many_rows THEN 
                av_res       := pk_public.cs_res_oldcardnotexist_err;
              av_msg       := '该人员存在多条参保信息记录';
              RETURN;
              WHEN OTHERS THEN 
                av_res       := pk_public.cs_res_oldcardnotexist_err;
              av_msg       := '获取参保信息出现错误' || Sqlerrm;
              RETURN;      
    END;
    --8.生成新申领记录
    SELECT seq_apply_id.nextval
    INTO lv_new_card_apply.apply_id
    FROM dual;
    SELECT lpad(seq_bar_code.nextval,9,'0')
    INTO lv_new_card_apply.bar_code
    FROM dual;
    IF lv_in(2) = '2' THEN
      UPDATE card_task_imp_bcp
      SET state          = '0',
        apply_bank_id    = lv_base_co_org.co_org_id,
        apply_org_id     = lv_users.org_id,
        apply_brch_id    = lv_users.brch_id,
        apply_user_id    = lv_users.user_id,
        apply_date       = lv_action_log.deal_time,
        end_deal_no      = lv_in(4)
      WHERE bank_card_no = lv_in(7);
      IF sql%rowcount   <> 1 THEN
        av_res          := pk_public.cs_res_bcp_updateerr;
        av_msg          := '更新半成品卡的使用状态出现错误';
        RETURN;
      END IF;
      SELECT TO_CHAR(lv_action_log.deal_time,'YYYYMMDD')
        || lpad(seq_cm_card_task.nextval,8,'0')
      INTO lv_new_card_apply.task_id
      FROM dual;
      INSERT
      INTO card_apply_task
        (
          task_id,
          make_batch_id,
          deal_code,
          task_name,
          task_sum,
          task_src,
          task_date,
          task_org_id,
          task_brch_id,
          task_oper_id,
          card_type,
          bank_id,
          brch_id,
          corp_id,
          region_id,
          town_id,
          comm_id,
          is_photo,
          start_card_no,
          end_card_no,
          is_list,
          deal_no,
          task_way,
          is_urgent,
          vendor_id,
          org_id,
          task_state,
          note,
          group_id,
          school_id,
          grade_id,
          classes_id,
          issuse_num,
          ws_num,
          yh_num,
          end_num,
          med_whole_no,
          mk_user_id
        )
        VALUES
        (
          lv_new_card_apply.task_id,
          seq_cm_card_task_batch.nextval,
          lv_action_log.deal_code,
          lv_base_co_org.co_org_name
          || '-'
          || (DECODE(lv_in(14),'0','补卡','1','换卡','其他'))
          || '-'
          || lv_base_personal.name ,
          1,
          '0',
          lv_action_log.deal_time,
          lv_users.org_id,
          lv_users.brch_id,
          lv_users.user_id,
          pk_public.card_type_smzk,
          lv_base_co_org.co_org_id,
          lv_users.brch_id,
          NULL,
          NULL,
          NULL,
          NULL,
          '0',
          lv_card_task_imp_bcp.card_no,
          lv_card_task_imp_bcp.card_no,
          '0',
          lv_action_log.deal_no,
          '0',
          '0',
          '1000',
          NULL,
          pk_public.kg_card_task_yhysh,
          lv_action_log.message,
          NULL,
          NULL,
          NULL,
          NULL,
          0,0,1,1,
          SUBSTR(lv_old_cardinfo.sub_card_id,1,6),
          NULL
        )
      RETURNING make_batch_id
      INTO lv_new_card_apply.buy_plan_id;
      IF sql%rowcount <> 1 THEN
        av_res        := pk_public.cs_res_unknownerr;
        av_msg        := '生成任务信息出现错误';
        RETURN;
      END IF;
      INSERT
      INTO card_task_list
        (
          data_seq,
          task_id,
          customer_id,
          name,
          sex,
          nation,
          birthplace,
          birthday,
          reside_type,
          reside_addr,
          letter_addr,
          post_code,
          mobile_no,
          education,
          marr_state,
          cert_type,
          cert_no,
          card_no,
          struct_main_type,
          struct_child_type,
          cardissuedate,
          validitydate,
          bursestartdate,
          bursevaliddate,
          monthstartdate,
          monthvaliddate,
          face_val,
          pwd,
          bar_code,
          comm_id,
          card_type,
          version,
          init_org_id,
          city_code,
          indus_code,
          bursebalance,
          monthbalance,
          bank_id,
          bankcardno,
          banksection2,
          banksection3,
          department,
          classid,
          photofilename,
          apply_id,
          useflag,
          cert_typed,
          bus_use_flag,
          burse_validdate,
          month_start_date,
          month_validdate,
          month_type,
          df01ef0729,
          burse_balance,
          month_balance,
          hlht_flag,
          sub_card_no,
          touch_startdate,
          touch_validdate,
          group_id,
          bkven_id,
          mk_user_id,
          mk_down_state
        )
        VALUES
        (
          seq_data_seq.nextval,
          lv_new_card_apply.task_id,
          lv_base_personal.customer_id,
          lv_base_personal.name,
          lv_base_personal.gender,
          lv_base_personal.nation,
          NULL,
          REPLACE(lv_base_personal.birthday,'-',''),
          lv_base_personal.reside_type,
          lv_base_personal.reside_addr,
          lv_base_personal.letter_addr,
          lv_base_personal.post_code,
          lv_base_personal.mobile_no,
          lv_base_personal.education,
          lv_base_personal.marr_state,
          lv_base_personal.cert_type,
          lv_base_personal.cert_no,
          lv_card_task_imp_bcp.card_no,
          lv_card_config.struct_main_type,
          lv_card_config.struct_child_type,
          lv_start_date,
          lv_valid_date,
          lv_start_date,
          lv_valid_date,
          lv_start_date,
          lv_start_date,
          0,
          NULL,
          lv_new_card_apply.bar_code,
          lv_base_personal.comm_id,
          '120',
          '1.00',
          '91560000023304003304002A',
          '3140',
          '0000',
          '0000000000',
          '0000000000',
          lv_base_co_org.co_org_id,
          lv_in(7),
          NULL,
          NULL,
          lv_base_personal.department,
          lv_base_personal.classid,
          lv_base_personal.cert_no
          || '.jpg',
          lv_new_card_apply.apply_id,
          '01',
          (DECODE(lv_base_personal.cert_type,'1','00','2','05','3','01','4','02','5','04','6','05','05')),
          '01',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          '3140',
          lv_old_card_apply.sub_card_no,
          lv_start_date,
          lv_valid_date,
          lv_base_personal.group_id,
          '1000',
          NULL,
          NULL
        );
      IF sql%rowcount <> 1 THEN
        av_res        := pk_public.cs_res_unknownerr;
        av_msg        := '生成制卡明细信息出现错误';
        RETURN;
      END IF;
    END IF;
    /* if substr(nvl(lv_old_cardinfo.SUB_CARD_NO,''),1,1) = 'C' then
    lv_bhk_type := '1';
    else
    lv_bhk_type := '0';
    end if;*/
    IF lv_old_cardinfo.card_type = '100' THEN
      lv_bhk_type               := '1';
    ELSE
      lv_bhk_type := '0';
    END IF;
    INSERT
    INTO card_apply
      (
        apply_id,
        bar_code,
        customer_id,
        card_no,
        card_type,
        buy_plan_id,
        version,
        org_code,
        city_code,
        indus_code,
        apply_way,
        apply_type,
        make_type,
        apply_brch_id,
        corp_id,
        comm_id,
        apply_state,
        apply_user_id,
        apply_date,
        cost_fee,
        foregift,
        is_urgent,
        is_photo,
        deal_no,
        bus_type,
        other_fee,
        wallet_use_flag,
        town_id,
        task_id,
        old_card_id,
        old_card_no,
        old_sub_card_id,
        old_sub_card_no,
        co_org_id,
        end_deal_no,
        bank_id,
        bank_card_no,
        sub_card_no,
        agt_cert_type,
        agt_cert_no,
        agt_name,
        agt_phone,
        med_whole_no,
        bhk_type
      )
      VALUES
      (
        lv_new_card_apply.apply_id,
        lv_new_card_apply.bar_code,
        lv_base_personal.customer_id,
        lv_card_task_imp_bcp.card_no,
        '100',--嘉兴老卡补换卡后生成老卡
        lv_new_card_apply.buy_plan_id,
        lv_old_card_apply.version,
        lv_old_card_apply.org_code,
        lv_old_card_apply.city_code,
        lv_old_card_apply.indus_code,
        '0',
        lv_new_card_apply.apply_type,
        '1',
        lv_users.brch_id,
        lv_base_personal.corp_customer_id,
        lv_base_personal.comm_id,
        lv_new_card_apply.apply_state,
        lv_users.user_id,
        lv_action_log.deal_time,
        NVL(lv_in(16), 0),
        0,0,
        lv_old_card_apply.is_photo,
        lv_action_log.deal_no,
        lv_old_cardinfo.bus_type,
        0,
        '01',
        lv_base_personal.town_id,
        lv_new_card_apply.task_id,
        lv_old_cardinfo.card_id,
        lv_old_cardinfo.card_no,
        lv_old_cardinfo.sub_card_id,
        lv_old_cardinfo.sub_card_no,
        lv_base_co_org.co_org_id,
        lv_in(4),
        (
        CASE
          WHEN lv_in(2) = '2'
          THEN lv_in(1)
          ELSE nvl(lv_old_card_apply.bank_id,'')
        END),
        lv_in(7),
        lv_old_cardinfo.sub_card_no,
        NVL(lv_in(17),''),
        NVL(lv_in(18),''),
        NVL(lv_in(19),''),
        NVL(lv_in(20),''),
       -- SUBSTR(lv_old_cardinfo.sub_card_id,1,6),
       lv_base_siinfo.med_whole_no,
        lv_bhk_type
      );
    IF sql%rowcount <> 1 THEN
      av_res        := pk_public.cs_res_unknownerr;
      av_msg        := '生成补换卡记录信息出现错误';
      RETURN;
    END IF;
    --9.更新原始申领记录为注销
    UPDATE card_apply
    SET apply_state  = pk_public.kg_card_apply_yzx
    WHERE apply_id   = lv_old_card_apply.apply_id;
    IF sql%rowcount <> 1 THEN
      av_res        := pk_public.cs_res_oldcardnotexist_err;
      av_msg        := '更新原始申领记录不正确';
      RETURN;
    END IF;
    --13.更新工本费收入账户
    SELECT lv_action_log.deal_no INTO av_out FROM dual;
    IF NVL(lv_in(16), 0) > 0 AND lv_in(2) = '1' THEN
      lv_cost_para      := lv_cost_para || lv_deal_no || '|' || lv_action_log.deal_code || '|' || lv_users.user_id || '|';
      lv_cost_para      := lv_cost_para || TO_CHAR(lv_action_log.deal_time,'YYYY-MM-DD HH24:MI:SS') || '|';
      lv_cost_para      := lv_cost_para || '702101' || '|' || NVL(lv_in(16), 0) || '|' || '补换卡工本费' || '|';
      lv_cost_para      := lv_cost_para || lv_in(2) || '|' || '0' || '|';
      pk_business.p_cost(lv_cost_para, '1', av_res, av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --14.将老卡加入黑名单
    pk_service_outer.p_card_black(lv_action_log.deal_no,lv_old_cardinfo.card_no,'0','99',TO_CHAR(lv_action_log.deal_time,'yyyy-mm-dd hh24:mi:ss'),av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF NVL(lv_card_config.is_stock, '-1') = '0' AND lv_in(13) = '0' THEN
      lv_stock_sql                       := lv_stock_sql || lv_in(1) || '|' || lv_in(2) || '|' || lv_in(3) || '|' || lv_action_log.deal_no || '|';
      lv_stock_sql                       := lv_stock_sql || lv_action_log.deal_code || '|' || TO_CHAR(lv_action_log.deal_time,'YYYY-MM-DD HH24:MI:SS') || '|';
      lv_stock_sql                       := lv_stock_sql || lv_old_cardinfo.card_no || '|' || '' || '|' || pk_card_stock.goods_state_zlwt || '|' || '补换卡|';
      pk_card_stock.p_bhk(lv_stock_sql, av_res, av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --16.插入业务日志,标识是否好卡   是否回收   好卡金额
    lv_serv_rec.deal_no       := lv_deal_no;
    LV_SERV_REC.Acpt_Type     := lv_in(2);
    lv_serv_rec.deal_code     := lv_action_log.deal_code;
    lv_serv_rec.customer_id   := lv_base_personal.customer_id;
    lv_serv_rec.card_id       := lv_old_cardinfo.card_id;
    lv_serv_rec.card_no       := lv_old_cardinfo.card_no;
    lv_serv_rec.card_amt      := 1;
    lv_serv_rec.card_type     := lv_old_cardinfo.card_type;
    lv_serv_rec.customer_name := lv_base_personal.name;
    lv_serv_rec.cert_type     := lv_base_personal.cert_type;
    lv_serv_rec.cert_no       := lv_base_personal.cert_no;
    lv_serv_rec.brch_id       := lv_users.brch_id;
    lv_serv_rec.user_id       := lv_users.user_id;
    lv_serv_rec.deal_state    := '0';
    lv_serv_rec.urgent_fee    := 0;
    lv_serv_rec.num           := 1;
    lv_serv_rec.org_id        := lv_users.org_id;
    lv_serv_rec.cost_fee      := NVL(lv_in(16), 0);       --工本费
    lv_serv_rec.old_card_no   := lv_old_cardinfo.card_no; --不换卡时 放新卡卡号
    lv_serv_rec.clr_date      := lv_clrdate.clr_date;
    IF lv_bhk_type             = '0' THEN
      lv_serv_rec.note        := lv_action_log.message || '新卡补换新卡'; --备注
    elsif lv_bhk_type          = '1' THEN
      lv_serv_rec.note        := lv_action_log.message || '老卡补换新卡'; --备注
    END IF;
    lv_serv_rec.amt             := NVL(lv_in(16), 0); --不换卡工本费
    lv_serv_rec.biz_time        := lv_action_log.deal_time;
    lv_serv_rec.rsv_one         := lv_in(11); --好卡换卡标识  -- 如果是好卡按照卡面金额，如果是坏卡账户返还按照账户
    lv_serv_rec.rsv_two         := lv_in(13); --是否回收标志
    lv_serv_rec.rsv_five        := lv_bhk_type;
    lv_serv_rec.chg_card_reason := lv_in(15);
    lv_serv_rec.cancel_reason   := lv_cancel_reason;
    lv_serv_rec.agt_cert_type   := lv_in(17);
    lv_serv_rec.agt_cert_no     := lv_in(18);
    lv_serv_rec.agt_name        := lv_in(19);
    lv_serv_rec.agt_tel_no      := lv_in(20);
    IF lv_in(2)                  = '2' THEN
      lv_serv_rec.co_org_id     := lv_base_co_org.co_org_id;
      lv_serv_rec.term_id       := lv_in(3);
      lv_serv_rec.end_deal_no   := lv_in(4);
    END IF;
    IF NVL(lv_in(11), '1') = '0' THEN
      lv_serv_rec.prv_bal := NVL(lv_in(12),0); --如果是好卡则需要传递卡面金额
    ELSE
      lv_serv_rec.prv_bal := 0;
    END IF;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    av_res := pk_public.cs_res_unknownerr;
    av_msg := '补换卡发生错误：' || sqlerrm;
  END p_cardtrans;
--本地制卡登记
--1.网点
--2.柜员
--3.非接上电复位信息
--4.非接触卡号
--5.接接触上电复位信息
--6.卡识别码
--7.状态 0 入库  1 废卡登记
--8.制卡流水
--9.备注
  PROCEDURE P_LOCAL_MAKECARD_REG(
      AV_IN IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2
    )
  IS
    LV_IN PK_PUBLIC.MYARRAY;
    LV_USERS SYS_USERS%ROWTYPE;
    LV_USERS_OUT SYS_USERS%ROWTYPE;
    LV_USERS_IN SYS_USERS%ROWTYPE;
    LV_CLR_DATE PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_CARD_TASK_IMP CARD_TASK_IMP_BCP%ROWTYPE;
    LV_STOCK_ACC_IN STOCK_ACC%ROWTYPE;
    LV_CARD_APPLY CARD_APPLY%ROWTYPE;
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE;
    LV_COUNT NUMBER := 0;
    LV_CARD_STATE CARD_BASEINFO.CARD_STATE%TYPE;
    LV_CARD_CONFIG CARD_CONFIG%ROWTYPE;
    LV_SYS_ACTION_LOG SYS_ACTION_LOG%ROWTYPE;
    LV_TR_SERV_REC TR_SERV_REC%ROWTYPE;
    LV_STOCK_LIST STOCK_LIST%ROWTYPE;
    LV_STOCK_ACC_OUT STOCK_ACC%ROWTYPE;
    LV_CARD_TASK_LIST CARD_TASK_LIST%ROWTYPE;
    LV_IMPORT_STOCK_SQL VARCHAR2(1000) := '';
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,6,9,'pk_service_outer.p_useless_card_reg',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(1) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '制卡操作网点不能为空';
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '制卡操作柜员不能为空';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '操作类型标识不能为空';
      RETURN;
    ELSIF LV_IN(7) NOT IN ('0','1') THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '操作类型标识只能是0或1';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '制卡流水编号不能为空';
      RETURN;
    END IF;
    IF LV_IN(7)  = '0' THEN
      IF LV_IN(4) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '非接触卡号不能为空';
        RETURN;
       END IF;
       IF LV_IN(3) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '非接触上电复位信息不能为空';
        RETURN;
      END IF;
      IF LV_IN(5) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '接触式上电复位信息不能为空';
        RETURN;
      END IF;
      IF LV_IN(6) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '卡识别码不能为空';
        RETURN;
      END IF;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),LV_IN(2),LV_USERS,AV_RES,AV_MSG,'制卡柜员信息');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --如果卡号不为空 判断半成品卡信息
    IF lv_in(4)  IS NOT NULL THEN 
    BEGIN
      SELECT *
      INTO LV_CARD_TASK_IMP
      FROM CARD_TASK_IMP_BCP
      WHERE CARD_NO                      = LV_IN(4);
      if LV_CARD_TASK_IMP.State in ('2','9') then 
        AV_RES                        := PK_PUBLIC.CS_RES_ok;
          AV_MSG                        := '已成功导入';
          RETURN;
      end if;
      
      IF LV_CARD_TASK_IMP.APPLY_BANK_ID IS NULL THEN
        IF LV_CARD_TASK_IMP.State       <> '1' THEN
          AV_RES                        := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                        := '该半成品卡不是发送到本地制卡的卡';
          RETURN;
        END IF;
      ELSE
        IF LV_CARD_TASK_IMP.State <> '0' THEN
          AV_RES                  := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                  := '该半成品卡不是未启用状态';
          RETURN;
        END IF;
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_BCP_NOT_EXIST;
      AV_MSG := '根据卡号' || LV_IN(4) || '找不到半成品卡采购信息';
      RETURN;
    WHEN TOO_MANY_ROWS THEN
      AV_RES := PK_PUBLIC.CS_RES_BCP_HAS_MORE;
      AV_MSG := '根据卡号' || LV_IN(4) || '找到多条半成品卡采购信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据卡号' || LV_IN(4) || '获取半成品卡信息出现错误' || SQLERRM;
      RETURN;
    END;
    IF NVL(LV_CARD_TASK_IMP.STATE,'-1') <> '1' THEN
      AV_RES                            := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                            := '该卡不是发送到本地制卡的卡';
      RETURN;
    END IF;
    END IF;
    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYS_ACTION_LOG.DEAL_NO FROM DUAL;
    LV_SYS_ACTION_LOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYS_ACTION_LOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYS_ACTION_LOG.LOG_TYPE    := 0;
    LV_SYS_ACTION_LOG.IN_OUT_DATA := AV_IN;
    LV_SYS_ACTION_LOG.DEAL_TIME   := SYSDATE;
    IF LV_IN(7)                    = '0' THEN
      LV_SYS_ACTION_LOG.MESSAGE   := '本地制卡数据导入:' || LV_IN(4);
      LV_SYS_ACTION_LOG.DEAL_CODE := 10502070;
    ELSE
        if lv_in(4) is null then
            LV_SYS_ACTION_LOG.MESSAGE   := '本地制卡取消制卡' || LV_IN(4);
            LV_SYS_ACTION_LOG.DEAL_CODE := 10502090;
        else
            LV_SYS_ACTION_LOG.MESSAGE   := '本地制卡失败废卡登记:' || LV_IN(4);
            LV_SYS_ACTION_LOG.DEAL_CODE := 10502080;
        end if;
    END IF;
    INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
    IF lv_in(4) IS NOT NULL THEN 
        PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_CARD_TASK_IMP.BRCH_ID,LV_CARD_TASK_IMP.USER_ID,LV_USERS_IN,AV_RES,AV_MSG,'该卡所属柜员');
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
    PK_CARD_STOCK.P_GETSTOCK_ACC(LV_USERS_IN.BRCH_ID,LV_USERS_IN.USER_ID,'1390',PK_CARD_STOCK.GOODS_STATE_ZC,LV_STOCK_ACC_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF NVL(LV_STOCK_ACC_IN.TOT_NUM,'0') < 1 THEN
      AV_RES                           := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                           := '半成品卡所属柜员的库存账户不足';
      RETURN;
    END IF;
    UPDATE STOCK_ACC
    SET TOT_NUM      = NVL(TOT_NUM,0) - 1
    WHERE BRCH_ID    = LV_STOCK_ACC_IN.BRCH_ID
    AND USER_ID      = LV_STOCK_ACC_IN.USER_ID
    AND STK_CODE     = LV_STOCK_ACC_IN.STK_CODE
    AND GOODS_STATE  = LV_STOCK_ACC_IN.GOODS_STATE;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '更新半成品卡的库存账户出现错误';
      RETURN;
    END IF;
    END IF;
    BEGIN
      SELECT * INTO LV_CARD_TASK_LIST FROM CARD_TASK_LIST WHERE DATA_SEQ = LV_IN(8);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据制卡流水' || LV_IN(8) || '找不到制卡信息';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据制卡流水' || LV_IN(8) || '获取制卡信息出现错误' || SQLERRM;
      RETURN;
    END;
    IF LV_IN(7) = '0' THEN
      GOTO MK_CARD_SUC;
    END IF;
    IF lv_in(4) IS NOT NULL THEN 
    UPDATE CARD_TASK_IMP_BCP
    SET STATE        = '9'
    WHERE CARD_NO    = LV_CARD_TASK_IMP.CARD_NO;-- AND STATE = '1';----0 初始导入  1 已申请制卡  2 制卡完成   9 制卡失败
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '更新半成品卡的使用状态出现错误';
      RETURN;
    END IF;
    END IF;
    DELETE FROM CARD_TASK_LIST WHERE DATA_SEQ = LV_CARD_TASK_LIST.DATA_SEQ;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '根据制卡流水编号' || LV_IN(8) || '找不到制卡明细信息';
      RETURN;
    END IF;
    UPDATE CARD_APPLY
    SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YZX,
      NOTE          = LV_SYS_ACTION_LOG.Message
    WHERE APPLY_ID = LV_CARD_TASK_LIST.APPLY_ID RETURNING APPLY_TYPE,
      OLD_CARD_NO
    INTO LV_CARD_APPLY.APPLY_TYPE,
      LV_CARD_APPLY.OLD_CARD_NO;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '根据制卡流水编号' || LV_IN(8) || '找不到制卡申领信息';
      RETURN;
    END IF;
    SELECT COUNT(1)
    INTO LV_COUNT
    FROM CARD_TASK_LIST
    WHERE TASK_ID = LV_CARD_TASK_LIST.TASK_ID;
    IF LV_COUNT   > 0 THEN
      UPDATE CARD_APPLY_TASK
      SET TASK_SUM  = TASK_SUM - 1,
        YH_NUM      = YH_NUM   - 1,
        END_NUM     = END_NUM  - 1
      WHERE TASK_ID = LV_CARD_TASK_LIST.TASK_ID;
    ELSE
      DELETE FROM CARD_APPLY_TASK WHERE TASK_ID = LV_CARD_TASK_LIST.TASK_ID;
    END IF;
    --如果是补换卡且老卡卡号不为空
    IF NVL(LV_CARD_APPLY.APPLY_TYPE,'-1') IN ('1','2') AND LV_CARD_APPLY.OLD_CARD_NO IS NOT NULL THEN
      PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_TASK_LIST.CUSTOMER_ID,LV_BASE_PERSONAL,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      PK_CARD_APPLY_ISSUSE.P_GET_CARD_BASEINFO(LV_CARD_APPLY.OLD_CARD_NO,LV_CARD_BASEINFO,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG  := '登记出现错误，回滚老卡信息失败，' || AV_MSG;
        RETURN;
      END IF;
      PK_CARD_APPLY_ISSUSE.P_GETCARDCONFIGBYCARDTYPE(LV_CARD_BASEINFO.CARD_TYPE,LV_CARD_CONFIG,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG  := '登记出现错误，回滚老卡信息失败，' || AV_MSG;
        RETURN;
      END IF;
      IF LV_CARD_APPLY.APPLY_TYPE    = '1' THEN
        LV_CARD_STATE               := '1';
      ELSIF LV_CARD_APPLY.APPLY_TYPE = '2' THEN
        LV_CARD_STATE               := '3';
      END IF;
      UPDATE CARD_BASEINFO
      SET CARD_STATE     = LV_CARD_STATE,
        LAST_MODIFY_DATE = LV_SYS_ACTION_LOG.DEAL_TIME,
        CANCEL_DATE      = NULL,
        CANCEL_REASON    = NULL
      WHERE CARD_NO      = LV_CARD_APPLY.OLD_CARD_NO
      AND CUSTOMER_ID    = LV_CARD_TASK_LIST.CUSTOMER_ID;
      IF SQL%ROWCOUNT   <> 1 THEN
        AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG          := '登记出现错误，回滚老卡信息失败，更新老卡卡状态时更新' || SQL%ROWCOUNT || '行';
        RETURN;
      END IF;
      UPDATE ACC_ACCOUNT_SUB
      SET ACC_STATE    = LV_CARD_STATE ,
        CLS_DATE       = NULL,
        CLS_USER_ID    = NULL,
        LSS_DATE       = NULL
      WHERE CARD_NO    = LV_CARD_APPLY.OLD_CARD_NO
      AND CUSTOMER_ID  = LV_CARD_TASK_LIST.CUSTOMER_ID;
      IF SQL%ROWCOUNT <= 0 THEN
        AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG        := '登记出现错误，回滚老卡信息失败，更新老卡卡账户时更新' || SQL%ROWCOUNT || '行';
        RETURN;
      END IF;
      UPDATE CARD_APPLY
      SET APPLY_STATE   = PK_PUBLIC.KG_CARD_APPLY_YFF
      WHERE CUSTOMER_ID = LV_CARD_TASK_LIST.CUSTOMER_ID
      AND CARD_NO       = LV_CARD_APPLY.OLD_CARD_NO;
      IF SQL%ROWCOUNT   < 1 THEN
        AV_RES         := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG         := '登记出现错误，回滚老卡信息失败，老卡申领记录不存在';
        RETURN;
      ELSIF SQL%ROWCOUNT > 1 THEN
        AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG          := '登记出现错误，回滚老卡信息失败，老卡申领记录存在多行';
        RETURN;
      END IF;
      IF NVL(LV_CARD_BASEINFO.RECOVER_FLAG,'-1') = '0' AND LV_CARD_CONFIG.IS_STOCK = '0' THEN
        PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_CARD_APPLY.OLD_CARD_NO,LV_STOCK_LIST,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
          AV_RES                  := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                  := '老卡库存明细归属类型不属于柜员';
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST.BRCH_ID,LV_STOCK_LIST.USER_ID,LV_USERS_OUT,AV_RES,AV_MSG,'老卡归属柜员信息');
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_LIST.BRCH_ID,LV_STOCK_LIST.USER_ID,LV_STOCK_LIST.STK_CODE,LV_STOCK_LIST.GOODS_STATE,LV_STOCK_ACC_OUT,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        IF LV_STOCK_ACC_OUT.TOT_NUM < 1 THEN
          AV_RES                   := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                   := '付方库存账户不足';
          RETURN;
        END IF;
        EXECUTE IMMEDIATE 'insert into stock_rec(stk_ser_no,deal_code,stk_code,batch_id,task_id,in_org_id,in_brch_id,                  
in_user_id,in_goods_state,out_org_id,out_brch_id,out_user_id,out_goods_state,                  
goods_id,goods_no,goods_nums,in_out_flag,tr_date,org_id,brch_id,user_id,auth_oper_id,                  
book_state,clr_date,deal_no,note,is_sure,start_no,end_no              
)values(seq_stk_ser_no.nextval,:1,:2,null,null,null,null,null,null,:3,:4,:5,:6,' || ':7,:8,''1'',''2'',:9,' || LV_USERS.ORG_ID || ',' || LV_USERS.BRCH_ID || ',''' || LV_USERS.USER_ID || ''',null,' || '''0'',:10,:11,:12,''0'',:13,:14) ' USING LV_SYS_ACTION_LOG.DEAL_CODE,
        LV_STOCK_ACC_OUT.STK_CODE,
        LV_USERS_OUT.ORG_ID,
        LV_USERS_OUT.BRCH_ID,
        LV_USERS_OUT.USER_ID,
        LV_STOCK_LIST.GOODS_STATE,
        LV_STOCK_LIST.GOODS_ID,
        LV_STOCK_LIST.GOODS_NO,
        LV_SYS_ACTION_LOG.DEAL_TIME,
        LV_CLR_DATE,
        LV_SYS_ACTION_LOG.DEAL_NO,
        '本地制卡失败,回滚老卡',
        LV_CARD_APPLY.OLD_CARD_NO,
        LV_CARD_APPLY.OLD_CARD_NO;
        IF SQL%ROWCOUNT <> 1 THEN
          AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG        := '记录库存操作日志出现错误-' || SQL%ROWCOUNT || '条';
          RETURN;
        END IF;
        EXECUTE IMMEDIATE 'insert into stock_inout_detail (stk_inout_no,stk_type,stk_code,in_goods_state,out_goods_state,org_id,                   
brch_id,user_id,auth_user_id,deal_code,deal_date,in_org_id,in_brch_id,                   
in_user_id,out_org_id,out_brch_id,out_user_id,batch_id,task_id,goods_no,                   
goods_id,tot_num,tot_amt,in_out_flag,book_state,clr_date,deal_no,note,rev_date                   
)' || '(select seq_stk_inout_no.nextval,substr(' || LV_STOCK_ACC_OUT.STK_CODE || ',1,1),stk_code,null,goods_state,:1,:2,:3,null,' || ':4,:5,null,null,null,:6,:7,:8,batch_id,task_id,goods_no,goods_id,''1'',' || '''0'',''2'',''0'',:9,:10,:11,null ' || 'from stock_list where own_type = ''0'' and goods_state = :12 and ' || 'stk_code = ''' || LV_STOCK_ACC_OUT.STK_CODE || ''' and goods_no = ''' || LV_CARD_APPLY.OLD_CARD_NO || ''')' USING LV_USERS.ORG_ID,
        LV_USERS.BRCH_ID,
        LV_USERS.USER_ID,
        LV_SYS_ACTION_LOG.DEAL_CODE,
        LV_SYS_ACTION_LOG.DEAL_TIME,
        LV_USERS_OUT.ORG_ID,
        LV_USERS_OUT.BRCH_ID,
        LV_USERS_OUT.USER_ID,
        LV_CLR_DATE,
        LV_SYS_ACTION_LOG.DEAL_NO,
        '本地制卡失败,回滚老卡',
        LV_STOCK_LIST.GOODS_STATE;
        IF SQL%ROWCOUNT < 1 THEN
          AV_RES       := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG       := '记录库存出入库流水信息出现错误，库存明细不存在';
          RETURN;
        END IF;
        IF SQL%ROWCOUNT <> 1 THEN
          AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG        := '记录库存出入库流水信息出现错误待记录' || '1' || '条，实际记录' || SQL%ROWCOUNT || '条';
          RETURN;
        END IF;
        EXECUTE IMMEDIATE 'update stock_list set goods_state = ''0'',own_type = ''1'',brch_id = null,' || 'user_id = null,org_id = null,customer_id = :1,customer_name = :2,out_brch_id = :3,out_user_id = :4,out_date = :5,out_deal_no = :6' || 'where own_type = ''0'' and stk_code = ''' || LV_STOCK_ACC_OUT.STK_CODE || ''' and goods_no = ''' || LV_STOCK_LIST.GOODS_NO || '''' USING LV_BASE_PERSONAL.CUSTOMER_ID,
        LV_BASE_PERSONAL.NAME,
        LV_USERS_OUT.BRCH_ID,
        LV_USERS_OUT.USER_ID,
        LV_SYS_ACTION_LOG.DEAL_TIME,
        LV_SYS_ACTION_LOG.DEAL_NO;
        IF SQL%ROWCOUNT < 1 THEN
          AV_RES       := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG       := '更新付方库存明细出库数量不正确，付方库存明细物品数量不足';
          RETURN;
        ELSIF SQL%ROWCOUNT > 1 THEN
          AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG          := '更新付方库存明细出库数量不正确，待更新1条，实际更新' || SQL%ROWCOUNT || '条';
          RETURN;
        END IF;
        UPDATE STOCK_ACC
        SET TOT_NUM       = NVL(TOT_NUM, 0) - 1,
          LAST_DEAL_DATE  = LV_SYS_ACTION_LOG.DEAL_TIME
        WHERE GOODS_STATE = LV_STOCK_ACC_OUT.GOODS_STATE
        AND USER_ID       = LV_USERS_OUT.USER_ID
        AND BRCH_ID       = LV_USERS_OUT.BRCH_ID
        AND STK_CODE      = LV_STOCK_ACC_OUT.STK_CODE
        AND ORG_ID        = LV_USERS_OUT.ORG_ID;
        IF SQL%ROWCOUNT  <> 1 THEN
          AV_RES         := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG         := '更新库存账户不正确，付方库存账户不存在';
          RETURN;
        END IF;
      END IF;
    END IF;
    GOTO MK_END;
    <<MK_CARD_SUC>>
    UPDATE CARD_TASK_IMP_BCP
    SET STATE        = '2'
    WHERE CARD_NO    = LV_CARD_TASK_IMP.CARD_NO;----0 初始导入  1 已申请制卡  2 制卡完成   9 制卡失败
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '更新半成品卡的使用状态出现错误';
      RETURN;
    END IF;
    UPDATE CARD_APPLY
    SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YZK,CARD_NO = LV_CARD_TASK_IMP.CARD_NO,bank_card_no = lv_card_task_imp.bank_card_no
    WHERE APPLY_ID  = LV_CARD_TASK_LIST.APPLY_ID RETURNING BUY_PLAN_ID
    INTO LV_CARD_APPLY.BUY_PLAN_ID;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '根据制卡流水编号' || LV_IN(8) || '找不到制卡申领信息';
      RETURN;
    END IF;
    UPDATE CARD_TASK_LIST
       SET CARD_NO = LV_CARD_TASK_IMP.CARD_NO
     WHERE DATA_SEQ = LV_CARD_TASK_LIST.DATA_SEQ;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '根据制卡流水编号' || LV_IN(8) || '更新制卡明细信息不正确';
      RETURN;
    END IF;
    SELECT COUNT(1)
    INTO LV_COUNT
    FROM CARD_APPLY
    WHERE TASK_ID    = LV_CARD_TASK_LIST.TASK_ID
    AND (APPLY_STATE < PK_PUBLIC.KG_CARD_APPLY_YZK
    AND APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_WJWSHBTG
    AND APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_YHSHBTG
    AND APPLY_STATE <> PK_PUBLIC.KG_CARD_APPLY_STSHBTG);
    IF LV_COUNT      = 0 THEN
      UPDATE CARD_APPLY_TASK
      SET TASK_STATE = PK_PUBLIC.KG_CARD_TASK_YJS
      WHERE TASK_ID  = LV_CARD_TASK_LIST.TASK_ID;
      UPDATE CARD_APPLY
        SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YJS
        WHERE task_id = LV_CARD_TASK_LIST.Task_Id  
        AND APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YZK;
    END IF;
    INSERT
    INTO CARD_BASEINFO
      (
        CARD_ID,
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
        VIP_CLASS
      )
      (SELECT LV_IN(3),
          LV_CARD_TASK_IMP.CARD_NO,
          L.CUSTOMER_ID,
          L.CARD_TYPE,
          '1001',
          L.VERSION,
          L.INIT_ORG_ID,
          L.CITY_CODE,
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
          0,0,0,
          LV_IN(6),
          C.SUB_CARD_NO,
          NULL,
          C.BANK_ID,
          LV_CARD_TASK_IMP.BANK_CARD_NO,
          C.BAR_CODE,
          NULL,
          NULL,
          '实名制卡本地制卡导入',
          NULL,
          LV_IN(5),
          LV_IN(3),
          NULL,
          '0',
          NULL,
          C.BUS_TYPE,
          '01',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          '0'
        FROM CARD_TASK_LIST L,
          CARD_APPLY C
        WHERE L.APPLY_ID = C.APPLY_ID
        AND L.TASK_ID    = C.TASK_ID
        AND L.DATA_SEQ   = LV_CARD_TASK_LIST.DATA_SEQ
      );
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '入卡信息表不正确';
    END IF;
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_USERS.BRCH_ID || '|' || '1' || '|' || LV_USERS.USER_ID || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_SYS_ACTION_LOG.DEAL_NO || '|' || LV_SYS_ACTION_LOG.DEAL_CODE || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || TO_CHAR(LV_SYS_ACTION_LOG.DEAL_TIME,'yyyy-mm-dd hh24:mi:ss') || '|' || '1100' || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_IN(3) || '|' || LV_CARD_TASK_IMP.CARD_NO || '|' || PK_CARD_STOCK.GOODS_STATE_ZC || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_CARD_APPLY.BUY_PLAN_ID || '|' || LV_CARD_TASK_LIST.TASK_ID || '|' || '0' || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_USERS.BRCH_ID || '|' || LV_USERS.USER_ID || '|' || '0' || '|' || LV_USERS.ORG_ID || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_USERS.BRCH_ID || '|' || LV_USERS.USER_ID || '|||本地制卡数据导入' || '|';
    PK_CARD_STOCK.P_IN_STOCK(LV_IMPORT_STOCK_SQL,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    <<MK_END>>
    LV_TR_SERV_REC.DEAL_NO       := LV_SYS_ACTION_LOG.DEAL_NO;
    LV_TR_SERV_REC.DEAL_CODE     := LV_SYS_ACTION_LOG.DEAL_CODE;
    LV_TR_SERV_REC.CARD_AMT      := 1;
    LV_TR_SERV_REC.BIZ_TIME      := LV_SYS_ACTION_LOG.DEAL_TIME;
    LV_TR_SERV_REC.BRCH_ID       := LV_SYS_ACTION_LOG.BRCH_ID;
    LV_TR_SERV_REC.USER_ID       := LV_SYS_ACTION_LOG.USER_ID;
    LV_TR_SERV_REC.CLR_DATE      := LV_CLR_DATE;
    LV_TR_SERV_REC.CERT_NO       := nvl(LV_CARD_TASK_LIST.CERT_NO,'');
    LV_TR_SERV_REC.CUSTOMER_ID   := nvl(LV_CARD_TASK_LIST.CUSTOMER_ID,'');
    LV_TR_SERV_REC.CUSTOMER_NAME := nvl(LV_CARD_TASK_LIST.NAME,'');
    LV_TR_SERV_REC.CERT_TYPE     := nvl(LV_CARD_TASK_LIST.CERT_TYPE,'');
    LV_TR_SERV_REC.DEAL_STATE    := '0';
    lv_tr_serv_rec.card_no       := nvl(lv_in(4),'');
    lv_tr_serv_rec.card_id       := nvl(lv_in(3),'');
    lv_tr_serv_rec.card_amt      := 1;
    lv_tr_serv_rec.card_type     := '100';
    lv_tr_serv_rec.amt           := 0;
    lv_tr_serv_rec.num           := 1;
    LV_TR_SERV_REC.NOTE          := LV_SYS_ACTION_LOG.MESSAGE;
    INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
    if sql%rowcount <> 1 then 
        AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG        := '记录业务日志不正确';
        return;
    end if;
    AV_RES := PK_PUBLIC.cs_res_Ok;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_LOCAL_MAKECARD_REG;
--补换卡转钱包 写灰记录
--1.受理点编号/网点编号
--2.受理点类型
--3.受理终端号/操作员
--4.终端交易流水
--5.批次号
--6.新卡卡号
--7.新卡卡面金额
--8.新卡交易序列号
--9.补换卡转账金额 单位：分  为空则全部转
--10.代理人证件类型
--11.代理人证件号码
--12.代理人姓名
--13代理人联系方式
  PROCEDURE p_bhk_zz_tj
    (
      av_in VARCHAR2,
      av_out OUT VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2
    )
  IS
    lv_in pk_public.myarray;                  --传入参数数组
    lv_users sys_users%rowtype;               --操作员
    lv_base_co_org base_co_org%rowtype;       --合作机构
    lv_in_card card_baseinfo%rowtype;         --新卡卡片信息
    lv_in_acc_info acc_account_sub%rowtype;   --新卡账户信息
    lv_in_card_apply card_apply%rowtype;      --新卡卡片申领记录
    lv_old_card card_baseinfo%rowtype;        --老卡卡信息
    lv_old_acc_info acc_account_sub%rowtype;  --老卡账户信息
    lv_sys_action_log Sys_Action_Log%rowtype; --操作日志
    lv_tr_serv_rec tr_serv_rec%rowtype;       --业务日志
    lv_old_tr_serv_rec tr_serv_rec%rowtype;   --原业务日志
    lv_deal_no sys_action_log.deal_no%type;   --流水号
    lv_clr_date pay_clr_para.clr_date%type;   --清分日期
    lv_zz_amt acc_account_sub.bal%type;       --转账金额
    lv_zz_para VARCHAR2(1000);                --转账字符串
    lv_base_personal base_personal%rowtype;
  BEGIN
    SELECT clr_date INTO lv_clr_date FROM pay_clr_para;
    pk_public.p_getinputpara(av_in, --传入参数
    7,                              --参数最少个数
    13,                             --参数最多个数
    'pk_YiendCard.p_bhk_zz_tj',     --调用的函数名
    lv_in,                          --转换成参数数组
    av_res,                         --传出参数代码
    av_msg                          --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(1) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '受理点编号不能为空';
      RETURN;
    END IF;
    IF lv_in(2) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '受理点类型不能为空';
      RETURN;
    END IF;
    IF lv_in(3) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '操作员或终端编号不能为空';
      RETURN;
    END IF;
    IF lv_in(6) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '新卡卡号不能为空';
      RETURN;
    END IF;
    --1.基本条件判断
    BEGIN
      IF lv_in(2) = '1' THEN
        SELECT * INTO lv_users FROM sys_users t1 WHERE t1.user_id = lv_in(3);
        IF lv_users.brch_id <> NVL(lv_in(1), '0') THEN
          av_res            := pk_public.cs_res_user_err;
          av_msg            := '受卡方身份验证失败';
          RETURN;
        END IF;
      elsif lv_in(2) = '2' THEN
        SELECT * INTO lv_base_co_org FROM base_co_org WHERE co_org_id = lv_in(1);
        IF lv_base_co_org.co_state <> '0' THEN
          av_res                   := pk_public.cs_res_co_org_novalidateerr;
          av_msg                   := '受卡方身份验证失败';
          RETURN;
        END IF;
        SELECT * INTO lv_users FROM sys_users WHERE user_id = 'admin';
      ELSE
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '受理点类型错误';
        RETURN;
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      av_res := pk_public.cs_res_baseco_nofounderr;
      av_msg := '受理点信息不存在';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_baseco_nofounderr;
      av_msg := '受卡方身份验证失败';
      RETURN;
    END;
    --2.获取新卡号
    pk_public.p_getcardbycardno(lv_in(6), lv_in_card, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in_card.card_state <> '1' THEN
      av_res                 := pk_public.cs_res_cardstateiserr;
      av_msg                 := '新卡卡状态不正常';
      RETURN;
    END IF;
    pk_public.p_getsubledgerbycardno(lv_in_card.card_no, pk_public.cs_acckind_qb, pk_public.cs_defaultwalletid, lv_in_acc_info, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --3.获取新卡申领记录信息是否补换卡申领记录
    BEGIN
      SELECT * INTO lv_in_card_apply FROM card_apply WHERE card_no = lv_in(6);
      IF lv_in_card_apply.apply_type <> '1' AND lv_in_card_apply.apply_type <> '2' THEN
        av_res                       := pk_public.cs_res_nobhktype_err;
        av_msg                       := '新卡申领记录不是补换卡记录，不能进行换卡转钱包';
        RETURN;
      END IF;
    EXCEPTION
    WHEN no_data_found THEN
      av_res := pk_public.cs_res_oldcardnotexist_err;
      av_msg := '新卡申领记录不存在,找不到对应老卡信息';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := sqlerrm;
      RETURN;
    END;
    IF lv_in_card_apply.old_card_no IS NULL THEN
      av_res                        := pk_public.cs_res_oldcardnotexist_err;
      av_msg                        := '新卡申领记录中不存在对应的老卡卡号';
      RETURN;
    END IF;
    --获取老卡补换卡记录
    BEGIN
      SELECT *
      INTO lv_old_tr_serv_rec
      FROM tr_serv_rec
      WHERE card_no  = lv_in_card_apply.old_card_no
      AND deal_code IN ('20501010', '20501020')
      AND biz_time   =
        (SELECT MAX(biz_time)
        FROM tr_serv_rec
        WHERE card_no  = lv_in_card_apply.old_card_no
        AND deal_code IN ('20501010', '20501020')
        );
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      av_res := pk_public.cs_res_oldcardnotexist_err;
      av_msg := '找不到原始补换卡记录信息';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := sqlerrm;
      RETURN;
    END;
    --4.根据老卡卡号获取老卡卡信息和账户信息
    pk_public.p_getcardbycardno(lv_in_card_apply.old_card_no, lv_old_card, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_getsubledgerbycardno(lv_old_card.card_no, pk_public.cs_acckind_qb, pk_public.cs_defaultwalletid, lv_old_acc_info, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF NVL(lv_old_tr_serv_rec.rsv_one, 1) = '0' THEN
      --以卡面为准
      lv_zz_amt := lv_old_tr_serv_rec.prv_bal;
    ELSE
      --以账户为准
      lv_zz_amt                                             := lv_old_acc_info.bal;
      IF TO_CHAR(lv_old_acc_info.lss_date + 7, 'yyyy-mm-dd') > lv_clr_date THEN
        av_res                                              := pk_public.cs_res_amt_is_zero;
        av_msg                                              := '账户返还日期还未到达';
        RETURN;
      END IF;
    END IF;
    IF lv_in(9) IS NOT NULL THEN
      lv_zz_amt := lv_in(9);
    END IF;
    IF NVL(lv_old_acc_info.bal, 0) = 0 THEN
      av_res                      := pk_public.cs_res_amt_is_zero;
      av_msg                      := '老卡账户余额为0，无需进行转账';
      RETURN;
    END IF;
    IF lv_tr_serv_rec.prv_bal > lv_old_acc_info.bal THEN
      av_res                 := pk_public.cs_res_accinsufbalance;
      av_msg                 := '原始老卡卡面余额大于账户余额，账户余额不足';
      RETURN;
    END IF;
    --5.记录操作日志
    SELECT seq_action_no.nextval INTO lv_deal_no FROM dual;
    lv_sys_action_log.deal_no     := lv_deal_no;
    lv_sys_action_log.deal_code   := 30101070;
    IF lv_in(2)                    = '2' THEN
      lv_sys_action_log.co_org_id := lv_in(1);
      lv_sys_action_log.org_id    := lv_base_co_org.org_id;
    ELSE
      lv_sys_action_log.org_id  := lv_users.org_id;
      lv_sys_action_log.brch_id := lv_users.brch_id;
      lv_sys_action_log.user_id := lv_users.user_id;
    END IF;
    lv_sys_action_log.deal_time   := sysdate;
    lv_sys_action_log.log_type    := 0;
    lv_sys_action_log.in_out_data := av_in;
    lv_sys_action_log.message     := '补换卡转钱包新卡卡号' || lv_in(6);
    INSERT INTO sys_action_log VALUES lv_sys_action_log;
    --构建请求字符串调转账接口
    lv_zz_para := lv_sys_action_log.deal_no || '|' || lv_sys_action_log.deal_code || '|' || lv_in(3) || '|';
    lv_zz_para := lv_zz_para || TO_CHAR(lv_sys_action_log.deal_time, 'yyyy-mm-dd hh24:mi:ss') || '|' || lv_in(1) || '|' || lv_in(5) || '|' || lv_in(4) || '|';
    lv_zz_para := lv_zz_para || lv_old_card.card_no || '|' || '|' || lv_old_tr_serv_rec.prv_bal || '|' || lv_old_acc_info.acc_kind || '|' || '00' || '|';
    lv_zz_para := lv_zz_para || lv_in_card.card_no || '|' || lv_in(8) || '|' || lv_in(7) || '|' || lv_in_acc_info.acc_kind || '|';
    lv_zz_para := lv_zz_para || '|' || lv_zz_amt || '|' || '|' || '补换卡转钱包' || '|' || '|' || '|' || '9' || '|' || lv_in(2) || '|';
    lv_zz_para := lv_zz_para || lv_old_acc_info.bal || '|' || lv_in_acc_info.bal || '|';
    dbms_output.put_line(lv_zz_para);
    pk_transfer.p_transfer(lv_zz_para, '1', av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT *
    INTO lv_base_personal
    FROM base_personal
    WHERE customer_id = lv_in_card.customer_id;
    --记录综合业务日志
    lv_tr_serv_rec.deal_no       := lv_sys_action_log.deal_no;
    lv_tr_serv_rec.deal_code     := lv_sys_action_log.deal_code;
    lv_tr_serv_rec.card_id       := lv_in_card.card_id;
    lv_tr_serv_rec.card_no       := lv_in_card.card_no;
    lv_tr_serv_rec.card_type     := lv_in_card.card_type;
    lv_tr_serv_rec.cert_type     := lv_base_personal.cert_type;
    lv_tr_serv_rec.cert_no       := lv_base_personal.cert_no;
    lv_tr_serv_rec.customer_id   := lv_base_personal.customer_id;
    lv_tr_serv_rec.customer_name := lv_base_personal.name;
    lv_tr_serv_rec.biz_time      := lv_sys_action_log.deal_time;
    lv_tr_serv_rec.num           := 1;
    lv_tr_serv_rec.prv_bal       := lv_in(7);
    lv_tr_serv_rec.card_tr_count := lv_in(8);
    lv_tr_serv_rec.old_card_no   := lv_old_tr_serv_rec.card_no;
    lv_tr_serv_rec.amt           := lv_zz_amt;
    lv_tr_serv_rec.card_amt      := 1;
    lv_tr_serv_rec.deal_state    := '9'; --灰记录
    lv_tr_serv_rec.clr_date      := lv_clr_date;
    IF lv_in(2)                   = '2' THEN
      lv_tr_serv_rec.end_deal_no := lv_in(4); --终端交易流水
      lv_tr_serv_rec.term_id     := lv_in(3); --终端号或是操作员号
      lv_tr_serv_rec.co_org_id   := lv_in(1);
    elsif lv_in(2)                = '1' THEN
      lv_tr_serv_rec.brch_id     := lv_users.brch_id;
      lv_tr_serv_rec.user_id     := lv_users.user_id;
    END IF;
    lv_tr_serv_rec.acc_no   := lv_in_acc_info.acc_no;
    lv_tr_serv_rec.acc_kind := lv_in_acc_info.acc_kind;
    lv_tr_serv_rec.note     := lv_sys_action_log.message;
    INSERT INTO tr_serv_rec VALUES lv_tr_serv_rec;
    SELECT lv_tr_serv_rec.deal_no
      || '|'
      || lv_tr_serv_rec.amt
    INTO av_out
    FROM dual;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    av_res := pk_public.cs_res_unknownerr;
    av_msg := sqlerrm;
    RETURN;
  END p_bhk_zz_tj;
--补换卡转钱包灰记录确认
--1.受理点编号/网点编号
--2.受理点类型   1 柜面  2 代理
--3.受理点终端编号/操作员
--4.终端操作流水 受理点类型为 1的时候可为空
--5.确认流水号
--6.清分日期
  PROCEDURE p_bhk_zz_tj_confirm(
      av_in VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2)
  IS
    lv_in pk_public.myarray;                      --传入参数数组
    lv_cr_acc acc_account_sub%ROWTYPE;            --贷方账户
    lv_db_acc acc_account_sub%ROWTYPE;            --借方账户
    lv_acc_inout_detail acc_inout_detail%ROWTYPE; --待确认账户流水
  BEGIN
    --1.解析参数信息
    pk_public.p_getinputpara(av_in,     --传入参数
    6,                                  --参数最少个数
    6,                                  --参数最多个数
    'pk_YiendCard.p_bhk_zz_tj_confirm', --调用的函数名
    lv_in,                              --转换成参数数组
    av_res,                             --传出参数代码
    av_msg                              --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --2.判断接入点信息
    pk_public.p_judgeacpt(lv_in(2), lv_in(1), lv_in(3), av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(5) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '补换卡转钱包确认流水不能为空';
      RETURN;
    END IF;
    IF lv_in(6) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '补换卡转钱包确认清分日期不能为空';
      RETURN;
    END IF;
    BEGIN
      SELECT *
      INTO lv_acc_inout_detail
      FROM acc_inout_detail
      WHERE deal_no = lv_in(5);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      av_res := pk_public.cs_res_glideinfoerr;
      av_msg := '根据流水' || lv_in(5) || '未找到待确认记录信息';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := Sqlerrm;
      RETURN;
    END;
    --3.取借方账户
    pk_public.p_getsubledgerbycardno(lv_acc_inout_detail.db_card_no, lv_acc_inout_detail.db_acc_kind, pk_public.cs_defaultwalletid, lv_db_acc, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --4.取贷方账户
    pk_public.p_getsubledgerbycardno(lv_acc_inout_detail.cr_card_no, lv_acc_inout_detail.cr_acc_kind, pk_public.cs_defaultwalletid, lv_cr_acc, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --5.确认补换卡转账灰记录
    pk_business.p_ashconfirmbyaccbookno(lv_in(6), --清分日期
    lv_acc_inout_detail.acc_inout_no,             --acc_book_no
    NULL,                                         --借方金额密文
    NULL,                                         --贷方金额密文
    lv_db_acc.bal,                                --借方交易前金额
    lv_cr_acc.bal,                                --贷方交易前金额
    '1',                                          --1写调试日志
    av_res,                                       --传出代码
    av_msg                                        --传出错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --6.修改日志状态为正常
    UPDATE tr_serv_rec
    SET deal_state   = '0',
      clr_date       = lv_in(6)
    WHERE deal_no    = lv_in(5);
    IF SQL%ROWCOUNT <> 1 THEN
      av_res        := pk_public.cs_res_unknownerr;
      av_msg        := '根据流水' || lv_in(5) || '确认转账记录' || SQL%ROWCOUNT || '行';
      RETURN;
    END IF;
    UPDATE acc_account_sub f
    SET f.bal_rslt  = '2'
    WHERE f.card_no = lv_acc_inout_detail.db_card_no
    AND f.acc_kind  = '01';
    av_res         := pk_public.cs_res_ok;
    av_msg         := '';
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    av_res := pk_public.cs_res_unknownerr;
    av_msg := Sqlerrm;
  END p_bhk_zz_tj_confirm;
--补换卡转钱包冲正
--av_deal_no 原流水
  PROCEDURE p_bhkzz_tj_cancel(
      av_deal_no VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2)
  IS
    lv_clrdate pay_clr_para.clr_date%TYPE;
  BEGIN
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    pk_business.p_ashcancel(lv_clrdate, --清分日期
    av_deal_no,                         --业务流水号
    '1',                                --1写调试日志
    av_res,                             --传出代码
    av_msg                              --传出错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    UPDATE tr_serv_rec
    SET deal_state   = '2',
      clr_date       = lv_clrdate
    WHERE deal_no    = av_deal_no;
    IF SQL%ROWCOUNT <> 1 THEN
      av_res        := pk_public.cs_res_unknownerr;
      av_msg        := '根据流水' || av_deal_no || '冲正转账记录' || SQL%ROWCOUNT || '行';
      RETURN;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    av_res := pk_public.cs_res_unknownerr;
    av_msg := SQLERRM;
  END p_bhkzz_tj_cancel;
--卡发放（银行操作）
--av_in
--1.受理点编号
--2.受理点类型
--3.操作员
--4.操作流水
--5.卡号
--6.银行卡卡号
--7.固定电话
--8.手机号码
--9.银行卡激活标志
--10.代理人证件类型
--11.代理人证件号码
--12.代理人姓名
--13.代理人联系电话
--14.备注
  PROCEDURE P_BANK_KFF(
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2,
      AV_OUT OUT VARCHAR2)
  IS
    LV_IN PK_PUBLIC.MYARRAY;
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_PAYCLRPARA PAY_CLR_PARA%ROWTYPE;
    LV_CARD_BIND_BANKCARD CARD_BIND_BANKCARD%ROWTYPE;
    LV_SQL  VARCHAR2(1000) := '';
    LV_EXEC VARCHAR2(2000) := '';
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE;
  BEGIN
    --1.参数解析
    SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,7,14,'PK_SERVICE_OUTER.P_BANK_KFF',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '受理点类型不能为空';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '银行卡卡号不能为空';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL AND LV_IN(8) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '固定电话和手机号码不能全部为空';
      RETURN;
    END IF;
    IF LV_IN(9) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '银行卡激活标志不能为空';
      RETURN;
    ELSIF LV_IN(9) NOT IN ('00','01') THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '银行卡激活标志不正确';
      RETURN;
    END IF;
    --2.受理点判断
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),LV_IN(2),LV_IN(3),LV_USERS,LV_BASE_CO_ORG,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    LV_SQL               := 'SELECT * FROM CARD_BIND_BANKCARD T WHERE 1 = 1 AND BANK_CARD_NO = ''' || LV_IN(6) || ''' ';
    IF LV_IN(5)          IS NOT NULL THEN
      IF LENGTH(LV_IN(5)) < 20 THEN
        LV_SQL           := LV_SQL || 'and SUB_CARD_NO = ''' || LV_IN(5) || ''' ';
      ELSE
        LV_SQL := LV_SQL || 'and CARD_NO = ''' || LV_IN(5) || ''' ';
      END IF;
    END IF;
    EXECUTE IMMEDIATE LV_SQL INTO LV_CARD_BIND_BANKCARD;
    IF LV_CARD_BIND_BANKCARD.CARD_NO IS NULL THEN
      AV_RES                         := PK_PUBLIC.CS_RES_CARDIDERR;
      AV_MSG                         := '根据银行卡卡号' || LV_IN(6) || '找到的绑定记录的卡号为空';
      RETURN;
    END IF;
    IF LV_CARD_BIND_BANKCARD.BANK_ID <> LV_IN(1) THEN
      AV_RES                         := PK_PUBLIC.CS_RES_BIND_BANK_ERR;
      AV_MSG                         := '原卡片所属银行与接入点银行不一致';
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_GET_CARD_BASEINFO(LV_CARD_BIND_BANKCARD.CARD_NO,LV_CARD_BASEINFO,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_CARD_BASEINFO.CARD_STATE = '1' THEN
      UPDATE CARD_BIND_BANKCARD C
      SET C.BANK_ACTIVATE_STATE = LV_IN(9) ,
        C.MOBILE_NUM            = (
        CASE
          WHEN LV_IN(8) IS NOT NULL
          THEN LV_IN(8)
          WHEN LV_IN(7) IS NOT NULL
          THEN LV_IN(7)
          ELSE NULL
        END)
      WHERE C.BANK_CARD_NO = LV_IN(6);
      IF SQL%ROWCOUNT     <> 1 THEN
        AV_RES            := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG            := '更新银行卡激活状态失败';
        RETURN;
      END IF;
      AV_RES := PK_PUBLIC.CS_RES_OK;
      AV_MSG := '';
      RETURN;
    ELSIF LV_CARD_BASEINFO.CARD_STATE <> '0' THEN
      AV_RES                          := PK_PUBLIC.CS_RES_CARDSTATEISERR;
      AV_MSG                          := '卡状态不是未启用状态';
      RETURN;
    END IF;
    LV_EXEC := LV_IN(1) || '|' || LV_IN(2) || '|' || LV_IN(3) || '|' || LV_IN(4) || '|';
    LV_EXEC := LV_EXEC || LV_CARD_BIND_BANKCARD.CARD_NO || '|' || LV_IN(6) || '|' || '0' || '|';
    LV_EXEC := LV_EXEC || '1' || '|' || LV_IN(10) || '|' || LV_IN(11) || '|' || LV_IN(12) || '|';
    LV_EXEC := LV_EXEC || LV_IN(13) || '|' || '银行调发放接口,银行卡卡号' || LV_IN(6) || '激活标志' || LV_IN(9) || '|';
    PK_CARD_APPLY_ISSUSE.P_SMZ_KFF(LV_EXEC,AV_RES,AV_MSG,AV_OUT);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    UPDATE CARD_BIND_BANKCARD C
    SET C.BANK_ACTIVATE_STATE = LV_IN(9) ,
      C.MOBILE_NUM            = (
      CASE
        WHEN LV_IN(8) IS NOT NULL
        THEN LV_IN(8)
        WHEN LV_IN(7) IS NOT NULL
        THEN LV_IN(7)
        ELSE NULL
      END)
    WHERE C.BANK_CARD_NO = LV_IN(6);
    IF SQL%ROWCOUNT     <> 1 THEN
      AV_RES            := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG            := '更新银行卡激活状态失败';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
    AV_MSG := '根据银行卡卡号' || LV_IN(6) || '找不到绑定的卡片信息';
    RETURN;
  WHEN TOO_MANY_ROWS THEN
    AV_RES := PK_PUBLIC.CS_RES_BIND_BANK_MORE;
    AV_MSG := '根据银行卡卡号' || LV_IN(6) || '找到多条绑定卡记录';
    RETURN;
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_BANK_KFF;
--银行卡注销
--av_in
--1.受理点编号
--2.受理点类型
--3.操作员
--4.操作流水
--5.市民卡卡号
--6.银行卡卡号
--7.银行注销时间 YYYY-MM-DD HH24:MI:SS
--8.代理人证件类型
--9.代理人证件号码
--10.代理人姓名
--11.代理人电话
--12.备注
  PROCEDURE P_BANK_ZX(
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2)
  IS
    LV_IN PK_PUBLIC.MYARRAY;
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_PAYCLRPARA PAY_CLR_PARA%ROWTYPE;
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE;
    LV_CARD_APPLY CARD_APPLY%ROWTYPE;
    LV_CARD_BIND_BANKCARD CARD_BIND_BANKCARD%ROWTYPE;
    LV_CARD_UNBIND_BANKCARD CARD_UNBIND_BANKCARD%ROWTYPE;
    LV_SERV_REC TR_SERV_REC%ROWTYPE;
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE;
    LV_COUNT NUMBER;
  BEGIN
    --1.参数解析
    SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,6,12,'PK_SERVICE_OUTER.P_BANK_ZX',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '受理点类型不能为空';
      RETURN;
    END IF;
    IF LV_IN(2) <> '2' THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '本业务只供外围银行调用';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '社保卡卡号不能为空';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '银行卡卡号不能为空';
      RETURN;
    END IF;
    --2.受理点判断
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.根据传入的卡号获取卡信息
    IF LENGTH(LV_IN(5)) <= 18 THEN
      BEGIN
        SELECT *
        INTO LV_CARD_APPLY
        FROM CARD_APPLY
        WHERE SUB_CARD_NO = LV_IN(5)
        AND APPLY_DATE    =
          (SELECT MAX(APPLY_DATE) FROM CARD_APPLY WHERE SUB_CARD_NO = LV_IN(5)
          );
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        AV_RES := PK_PUBLIC.CS_RES_APPLY_MSG_ERR;
        AV_MSG := '根据卡号' || LV_IN(5) || '找不到卡申领信息';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '根据卡号' || LV_IN(5) || '获取申领信息时出现错误' || SQLERRM;
        RETURN;
      END;
      PK_CARD_STOCK.P_GETCARDBASEINFO(LV_CARD_APPLY.CARD_NO, LV_CARD_BASEINFO, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      IF LV_CARD_BASEINFO.SUB_CARD_NO <> LV_IN(5) THEN
        AV_RES                        := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG                        := '根据卡号' || LV_IN(5) || '获取到的卡信息数据不一致';
        RETURN;
      END IF;
    ELSE
      PK_CARD_STOCK.P_GETCARDBASEINFO(LV_IN(5), LV_CARD_BASEINFO, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
    END IF;
    --4.比较卡信息中的绑定信息和传入的解绑信息是否一致
    IF LV_CARD_BASEINFO.BANK_ID IS NULL OR LV_CARD_BASEINFO.BANK_CARD_NO IS NULL THEN
      --AV_RES := PK_PUBLIC.CS_RES_NO_BIND_BANK;
      --AV_MSG := '卡号' || LV_IN(5) || '未绑定银行卡信息';
      AV_RES := PK_PUBLIC.cs_res_ok;
      AV_MSG := '';
      RETURN;
    END IF;
    IF LV_CARD_BASEINFO.BANK_ID <> NVL(LV_IN(1), 0) THEN
      AV_RES                    := PK_PUBLIC.CS_RES_BIND_BANK_ERR;
      AV_MSG                    := '卡号' || LV_IN(5) || '绑定的银行和解绑银行不一致';
      RETURN;
    END IF;
    IF LV_CARD_BASEINFO.BANK_CARD_NO <> NVL(LV_IN(6), 0) THEN
      AV_RES                         := PK_PUBLIC.CS_RES_BIND_BANKNO_ERR;
      AV_MSG                         := '卡号' || LV_IN(5) || '绑定的银行卡卡号和传入的银行卡卡号不一致';
      RETURN;
    END IF;
    --5.获取绑定信息并比较绑定表中绑定信息和解绑信息是否一致
    SELECT COUNT(1)
    INTO LV_COUNT
    FROM CARD_BIND_BANKCARD
    WHERE SUB_CARD_NO = LV_IN(5)
    AND CUSTOMER_ID   = LV_CARD_BASEINFO.CUSTOMER_ID;
    IF LV_COUNT       > 1 THEN
      AV_RES         := PK_PUBLIC.CS_RES_BIND_BANK_MORE;
      AV_MSG         := '根据卡号' || LV_IN(5) || '找到多条绑定记录';
      RETURN;
    ELSIF LV_COUNT < 1 THEN
      AV_RES      := PK_PUBLIC.CS_RES_NO_BIND_BANK;
      AV_MSG      := '根据卡号' || LV_IN(5) || '找不到绑定信息';
      RETURN;
    ELSE
      SELECT *
      INTO LV_CARD_BIND_BANKCARD
      FROM CARD_BIND_BANKCARD
      WHERE SUB_CARD_NO = LV_IN(5);
    END IF;
    IF LV_CARD_BIND_BANKCARD.BANK_ID <> LV_IN(1) THEN
      AV_RES                         := PK_PUBLIC.CS_RES_BIND_BANK_ERR;
      AV_MSG                         := '卡号' || LV_IN(5) || '绑定的银行和解绑银行不一致';
      RETURN;
    END IF;
    IF LV_CARD_BIND_BANKCARD.BANK_CARD_NO <> LV_IN(6) THEN
      AV_RES                              := PK_PUBLIC.CS_RES_BIND_BANKNO_ERR;
      AV_MSG                              := '卡号' || LV_IN(5) || '绑定银行卡卡号和传入的银行卡卡号不一致';
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --6.记录操作日志
    SELECT SEQ_ACTION_NO.NEXTVAL
    INTO LV_SYSACTIONLOG.DEAL_NO
    FROM DUAL;
    LV_SYSACTIONLOG.DEAL_CODE   := '20409062';
    LV_SYSACTIONLOG.Deal_Time   := SYSDATE;
    LV_SYSACTIONLOG.MESSAGE     := '银行解绑,卡号:' || LV_CARD_BASEINFO.CARD_NO || ',社保卡号:' || LV_IN(5) || ',银行编号:' || LV_IN(1) || ',银行卡卡号:' || LV_IN(6) || NVL(LV_IN(12), '');
    LV_SYSACTIONLOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYSACTIONLOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYSACTIONLOG.LOG_TYPE    := 0;
    LV_SYSACTIONLOG.IN_OUT_DATA := AV_IN;
    LV_SYSACTIONLOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
    LV_SYSACTIONLOG.ORG_ID      := LV_USERS.ORG_ID;
    INSERT INTO sys_action_log VALUES LV_SYSACTIONLOG;
    --7.解绑
    LV_CARD_UNBIND_BANKCARD.NAME           := LV_BASE_PERSONAL.NAME;
    LV_CARD_UNBIND_BANKCARD.CERT_NO        := LV_CARD_UNBIND_BANKCARD.CERT_NO;
    LV_CARD_UNBIND_BANKCARD.SUB_CARD_ID    := LV_CARD_BASEinfo.Sub_Card_Id;
    LV_CARD_UNBIND_BANKCARD.SUB_CARD_NO    := LV_CARD_BASEinfo.Sub_Card_No;
    LV_CARD_UNBIND_BANKCARD.BANK_ID        := LV_CARD_BASEinfo.Bank_Id;
    LV_CARD_UNBIND_BANKCARD.BANK_CARD_NO   := LV_CARD_BASEinfo.Bank_Card_No;
    LV_CARD_UNBIND_BANKCARD.BANK_CARD_TYPE := '';
    LV_CARD_UNBIND_BANKCARD.OPER_ID        := lv_users.user_id;
    LV_CARD_UNBIND_BANKCARD.UNBIND_DATE    := LV_SYSACTIONLOG.Deal_Time;
    LV_CARD_UNBIND_BANKCARD.Receipt        := '1';
    INSERT INTO CARD_UNBIND_BANKCARD VALUES LV_CARD_UNBIND_BANKCARD;
    DELETE
    FROM card_bind_bankcard
    WHERE sub_card_no = lv_in(5)
    AND bank_id       = lv_in(1);
    IF SQL%ROWCOUNT   > 1 THEN
      AV_RES         := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG         := '解绑卡号' || LV_IN(5) || '的绑定时，找到多条绑定记录';
      RETURN;
    ELSIF SQL%ROWCOUNT < 1 THEN
      AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG          := '解绑卡号' || LV_IN(5) || '的绑定时，找到0条绑定记录';
      RETURN;
    END IF;
    UPDATE CARD_BASEINFO
    SET BANK_ID     = NULL,
      BANK_CARD_NO  = NULL
    WHERE CARD_NO   = LV_CARD_BASEINFO.CARD_NO;
    IF SQL%ROWCOUNT > 1 THEN
      AV_RES       := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG       := '解绑卡号' || LV_IN(5) || '的绑定时，找到多条绑定记录';
      RETURN;
    ELSIF SQL%ROWCOUNT < 1 THEN
      AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG          := '解绑卡号' || LV_IN(5) || '的绑定时，找到0条绑定记录';
      RETURN;
    END IF;
    /*IF LV_CARD_BASEINFO.CARD_STATE <> '9' THEN
    UPDATE CARD_BASEINFO SET CARD_STATE = '9' WHERE CARD_NO = LV_CARD_BASEINFO.CARD_NO;
    UPDATE CARD_APPLY SET APPLY_STATE = '90'
    WHEN card_no = LV_CARD_BASEINFO.Card_No AND customer_id = LV_CARD_BASEINFO.Customer_Id;
    END IF;*/
    LV_SERV_REC.DEAL_NO       := LV_SYSACTIONLOG.DEAL_NO;
    LV_SERV_REC.Acpt_Type     := lv_in(2);
    LV_SERV_REC.DEAL_CODE     := LV_SYSACTIONLOG.DEAL_CODE;
    LV_SERV_REC.CUSTOMER_ID   := LV_BASE_PERSONAL.CUSTOMER_ID;
    LV_SERV_REC.CUSTOMER_NAME := LV_BASE_PERSONAL.NAME;
    LV_SERV_REC.CERT_TYPE     := LV_BASE_PERSONAL.CERT_TYPE;
    LV_SERV_REC.CERT_NO       := LV_BASE_PERSONAL.CERT_NO;
    LV_SERV_REC.TEL_NO        := LV_BASE_PERSONAL.PHONE_NO;
    IF LV_IN(2)                = '2' THEN
      LV_SERV_REC.TERM_ID     := NVL(LV_IN(3), '');
      LV_SERV_REC.CO_ORG_ID   := NVL(LV_BASE_CO_ORG.CO_ORG_ID, '');
      LV_SERV_REC.END_DEAL_NO := NVL(LV_IN(4), '');
    END IF;
    LV_SERV_REC.BIZ_TIME      := LV_SYSACTIONLOG.DEAL_TIME;
    LV_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
    LV_SERV_REC.USER_ID       := LV_USERS.USER_ID;
    LV_SERV_REC.CLR_DATE      := LV_PAYCLRPARA.CLR_DATE;
    LV_SERV_REC.CARD_AMT      := '1';
    LV_SERV_REC.CARD_NO       := LV_CARD_BASEINFO.CARD_NO;
    LV_SERV_REC.CARD_ID       := LV_CARD_BASEINFO.CARD_ID;
    LV_SERV_REC.CARD_TYPE     := LV_CARD_BASEINFO.CARD_TYPE;
    LV_SERV_REC.NOTE          := LV_SYSACTIONLOG.MESSAGE;
    LV_SERV_REC.NUM           := 1;
    LV_SERV_REC.DEAL_STATE    := '0';
    LV_SERV_REC.AGT_CERT_TYPE := NVL(LV_IN(8), '');
    LV_SERV_REC.AGT_CERT_NO   := NVL(LV_IN(9), '');
    LV_SERV_REC.AGT_NAME      := NVL(LV_IN(10), '');
    LV_SERV_REC.AGT_TEL_NO    := NVL(LV_IN(11), '');
    INSERT INTO TR_SERV_REC VALUES LV_SERV_REC;
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
    RETURN;
  END P_BANK_ZX;
--个人交易信息查询
  PROCEDURE P_CONSUME_RECHARGE_QUERY
    (
      AV_CARD_NO    VARCHAR2,           --卡号
      AV_DEAL_TYPE  VARCHAR2,           --查询交易类型 0 查询所有 1 查询充值  2 查询消费
      AV_ACC_KIND   VARCHAR2,           --账户类型
      AV_START_DATE VARCHAR2,           --查询起始日期  YYYY-MM-DD
      AV_END_DATE   VARCHAR2,           --查询结束日期 YYYY-MM-DD
      AV_PAGE_NO    NUMBER,             --第几页
      AV_PCOUNT     NUMBER,             --每页多少条,
      AV_ORDERBY    VARCHAR2,           --排序字段
      AV_ORDER      VARCHAR2,           --升序 asc 降序  desc
      AV_ALL_SIZE OUT NUMBER,           --总共多少行
      AV_ALL_PAGE OUT NUMBER,           --总共个多少页
      AV_DATA OUT ZPAGE.DEFAULT_CURSOR, --结果数据
      AV_RES OUT VARCHAR2,              --处理结果代码
      AV_MSG OUT VARCHAR2               --处理结果说明
    )
  IS
    LV_TABLE_NAME_ARR PK_PUBLIC.MYARRAY;
    LV_SQL        VARCHAR2(5000) := '';
    LV_TABLENAMES VARCHAR2(3000) := '';
    LV_DEAL_TYPE  VARCHAR2(1)    := 0;
    LV_ORDERBY    VARCHAR(50)    := '';
    LV_ORDER      VARCHAR2(4)    := '';
    LV_MONTH_NUM  NUMBER         := 0;
  BEGIN
    IF AV_CARD_NO IS NULL THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '卡号不能为空';
      RETURN;
    END IF;
    IF AV_DEAL_TYPE IS NULL THEN
      LV_DEAL_TYPE  := '0';
    ELSIF AV_DEAL_TYPE IN ('0', '1', '2') THEN
      LV_DEAL_TYPE := AV_DEAL_TYPE;
    ELSE
      LV_DEAL_TYPE := '0';
    END IF;
    IF AV_START_DATE IS NULL THEN
      AV_RES         := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG         := '查询起始日期不能为空';
      RETURN;
    END IF;
    IF AV_END_DATE IS NULL THEN
      AV_RES       := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG       := '查询结束日期不能为空';
      RETURN;
    END IF;
    IF AV_END_DATE < AV_START_DATE THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '查询起始日期不能大于结束日期';
      RETURN;
    END IF;
    LV_MONTH_NUM        := MONTHS_BETWEEN(TO_DATE(AV_END_DATE, 'yyyy-mm-dd'), TO_DATE(AV_START_DATE, 'yyyy-mm-dd'));
    IF ABS(LV_MONTH_NUM) > 3 THEN
      AV_RES            := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG            := '只供查询相邻3个月内的记录信息';
      RETURN;
    END IF;
    --DBMS_OUTPUT.put_line(LV_MONTH_NUM);
    IF AV_ORDERBY IS NULL THEN
      LV_ORDERBY  := 'DEAL_NO';
    ELSE
      LV_ORDERBY := AV_ORDERBY;
    END IF;
    IF AV_ORDER IS NULL THEN
      LV_ORDER  := 'DESC';
    ELSIF UPPER(AV_ORDER) NOT IN ('ASC', 'DESC') THEN
      LV_ORDER := 'DESC';
    ELSE
      LV_ORDER := AV_ORDER;
    END IF;
    SELECT T.TABLE_NAME BULK COLLECT
    INTO LV_TABLE_NAME_ARR
    FROM USER_TABLES T
    WHERE T.TABLE_NAME BETWEEN 'PAY_CARD_DEAL_REC_'
      || REPLACE(SUBSTR(AV_START_DATE, 1, 7), '-', '')
    AND 'PAY_CARD_DEAL_REC_'
      || REPLACE(SUBSTR(AV_END_DATE, 1, 7), '-', '');
    IF LV_TABLE_NAME_ARR.COUNT < 1 THEN
      AV_RES                  := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                  := '查询日期超过界限';
      RETURN;
    END IF;
    FOR I_INDEX IN LV_TABLE_NAME_ARR.FIRST .. LV_TABLE_NAME_ARR.LAST
    LOOP
      IF I_INDEX       = LV_TABLE_NAME_ARR.LAST THEN
        LV_TABLENAMES := LV_TABLENAMES || 'SELECT * FROM ' || LV_TABLE_NAME_ARR(I_INDEX) || ' ';
      ELSE
        LV_TABLENAMES := LV_TABLENAMES || 'SELECT * FROM ' || LV_TABLE_NAME_ARR(I_INDEX) || ' UNION ';
      END IF;
    END LOOP;
    LV_SQL := LV_SQL || 'SELECT T.DEAL_NO,T.DEAL_BATCH_NO,R.DEAL_CODE_NAME TRNAME,T.DEAL_STATE,T.ACC_KIND,T.DEAL_CODE,';
    --LV_SQL := LV_SQL || (CASE )
    LV_SQL         := LV_SQL || '(CASE WHEN T.ACPT_TYPE = ''1'' THEN (SELECT T1.FULL_NAME FROM SYS_BRANCH T1 WHERE T1.BRCH_ID = T.ACPT_ID) ';
    LV_SQL         := LV_SQL || 'WHEN T.ACPT_TYPE = ''2'' THEN (SELECT T1.CO_ORG_NAME FROM BASE_CO_ORG T1 WHERE T1.CO_ORG_ID = T.ACPT_ID ) ';
    LV_SQL         := LV_SQL || 'WHEN T.ACPT_TYPE = ''0'' THEN (SELECT T2.MERCHANT_NAME FROM BASE_MERCHANT T2 WHERE T2.MERCHANT_ID = T.ACPT_ID) ';
    LV_SQL         := LV_SQL || 'ELSE Z.MERCHANT_NAME END) ACPTNAME,DECODE(T.DEAL_STATE, ''0'', ''正常'', ''1'', ''撤销'', ''2'', ''冲正'', ''其他'') ';
    LV_SQL         := LV_SQL || 'DEALSTATE,TO_CHAR(T.INSERT_TIME,''YYYY-MM-DD HH24:MI:SS'') TRDATE,NVL(T.ACC_BAL,0)/100 BAL,NVL(T.AMT,0)/100 AMT ';
    LV_SQL         := LV_SQL || 'FROM (' || LV_TABLENAMES || ') T,SYS_CODE_TR R,BASE_MERCHANT Z WHERE T.ACPT_ID = Z.MERCHANT_ID(+) ';
    LV_SQL         := LV_SQL || 'AND T.DEAL_CODE = R.DEAL_CODE AND T.CLR_DATE >= ''' || AV_START_DATE || ''' AND T.CLR_DATE <= ''' || AV_END_DATE || '''';
    IF AV_ACC_KIND IS NOT NULL THEN
      LV_SQL       := LV_SQL || ' AND T.ACC_KIND = ''' || AV_ACC_KIND || ''' ';
    END IF;
    LV_SQL            := LV_SQL || ' AND T.CARD_NO = ''' || AV_CARD_NO || ''' ';
    IF LV_DEAL_TYPE    = '1' THEN
      LV_SQL          := LV_SQL || ' AND T.DEAL_CODE LIKE ''30%'' ';
    ELSIF LV_DEAL_TYPE = '2' THEN
      LV_SQL          := LV_SQL || ' AND T.DEAL_CODE LIKE ''40%'' ';
    END IF;
    IF UPPER(LV_ORDERBY) IN ('AMT', 'BAL') THEN
      LV_ORDERBY := 'TO_NUMBER(' || LV_ORDERBY || ') ';
    END IF;
    LV_SQL := LV_SQL || ' ORDER BY ' || LV_ORDERBY || ' ' || LV_ORDER;
    --DBMS_OUTPUT.PUT_LINE(LV_SQL);
    ZPAGE.PAGE(LV_SQL, AV_PAGE_NO, AV_PCOUNT, AV_ALL_SIZE, AV_ALL_PAGE, AV_DATA, AV_RES, AV_MSG);
    AV_RES := PK_PUBLIC.cs_res_ok;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_CONSUME_RECHARGE_QUERY;
--根据9位的社保卡卡号获取20位非接卡号
  FUNCTION F_GETCARDNO_BY_SUBCARDNO(
      AV_SUB_CARD_NO VARCHAR2, --社保卡卡号
      AV_CARD_APPLY OUT CARD_APPLY%ROWTYPE)
    RETURN VARCHAR2
  IS
  BEGIN
    SELECT *
    INTO AV_CARD_APPLY
    FROM CARD_APPLY
    WHERE SUB_CARD_NO = AV_SUB_CARD_NO
    AND APPLY_DATE    =
      (SELECT MAX(APPLY_DATE) FROM CARD_APPLY WHERE SUB_CARD_NO = AV_SUB_CARD_NO
      );
    RETURN AV_CARD_APPLY.CARD_NO;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN '0';
  WHEN OTHERS THEN
    RETURN '-1';
  END F_GETCARDNO_BY_SUBCARDNO;
--根据银行卡卡号获取对应的卡号信息
  PROCEDURE p_getBcpCard(
      av_bank_card_no card_task_imp_bcp.bank_card_no%type,
      lv_card_task_bcp OUT card_task_imp_bcp%rowtype,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2)
  IS
  BEGIN
    SELECT *
    INTO lv_card_task_bcp
    FROM card_task_imp_bcp
    WHERE bank_card_no                   = av_bank_card_no
    AND card_type                        = '390';
    IF NVL(lv_card_task_bcp.STATE,'-1') <> '1' THEN
      av_res                            := pk_public.cs_res_bcp_has_bind;
      av_msg                            := '银行卡卡号' || av_bank_card_no || '对应的半成品已经使用';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
  EXCEPTION
  WHEN no_data_found THEN
    av_res := pk_public.cs_res_bcp_not_exist;
    av_msg := '根据银行卡卡号' || av_bank_card_no || '找不到对应的半成品卡信息';
    RETURN;
  WHEN too_many_rows THEN
    av_res := pk_public.cs_res_bcp_has_more;
    av_msg := '根据银行卡卡号' || av_bank_card_no || '找到多条半成品卡信息';
    RETURN;
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_bcp_has_more;
    av_msg := '根据银行卡卡号' || av_bank_card_no || '获取半成品卡信息出现错误' || SQLERRM;
  END p_getbcpcard;
--黑名单操作
--1卡号
--2操作黑名单状态真 0 增加黑名单  1 减去黑名单
--3当增加黑名单时 需要传递黑名单类型
--4卡所属机构编号
  PROCEDURE P_CARD_BLACK(
      AV_DEAL_NO CARD_BLACK_REC.DEAL_NO%TYPE, --ACTIONNO
      AV_CARD_NO CARD_BASEINFO.CARD_NO%TYPE,  --黑名单操作的卡
      AV_STL_STATE VARCHAR2,                  --操作黑名单状态  0 增加黑名单  1 减去黑名单
      AV_STL_TYPE  VARCHAR2,                  --当AV_STL_STATE = 0 增加黑名单时 需要传递黑名单类型 01 补卡 02 换卡 03挂失 09 注销
      AV_DEAL_TIME VARCHAR2,                  --操作时间  格式：YYYY-MM-DD HH24:MI:SS
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2)
  IS
    LV_CARD CARD_BASEINFO%ROWTYPE;
    LV_CARD_BLACK CARD_BLACK%ROWTYPE;
    LV_CARD_BLACK_REC CARD_BLACK_REC%ROWTYPE;
    LV_COUNT NUMBER;
    LV_VERSION CARD_BLACK.VERSION%TYPE;
  BEGIN
    IF AV_CARD_NO IS NULL THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '操作黑名单卡号不能为空';
      RETURN;
    END IF;
    IF AV_STL_STATE IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '操作黑名单黑名单类型不能为空';
      RETURN;
    ELSIF AV_STL_STATE <> '0' AND AV_STL_STATE <> '1' THEN
      AV_RES           := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG           := '操作黑名单黑名单类型只能是0或1';
      RETURN;
    ELSIF AV_STL_STATE = '0' AND AV_STL_TYPE IS NULL THEN
      AV_RES          := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG          := '增加黑名单黑名单类型不能为空';
      RETURN;
    END IF;
    IF AV_DEAL_TIME IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '操作黑名单操作时间不能为空';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO LV_CARD FROM CARD_BASEINFO WHERE CARD_NO = AV_CARD_NO;
    EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
      AV_MSG := '操作黑名单根据卡号找不到卡信息';
      RETURN;
    END;
    SELECT COUNT(1) INTO LV_COUNT FROM CARD_BLACK WHERE CARD_NO = AV_CARD_NO;
    IF AV_STL_STATE = 0 THEN
      IF LV_COUNT   > 0 THEN
        UPDATE CARD_BLACK B
        SET B.BLK_TYPE  = AV_STL_TYPE,
          B.BLK_STATE   = 0,
          B.LAST_DATE   = TO_DATE(AV_DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss'),
          B.VERSION     = SEQ_BLACK_VISION.NEXTVAL
        WHERE B.CARD_NO = AV_CARD_NO;
      ELSE
        LV_CARD_BLACK.CARD_ID   := LV_CARD.CARD_ID;
        LV_CARD_BLACK.CARD_NO   := LV_CARD.CARD_NO;
        LV_CARD_BLACK.ORG_ID    := SUBSTR(LV_CARD.CARD_NO, 1, 4);
        LV_CARD_BLACK.BLK_STATE := AV_STL_STATE;
        LV_CARD_BLACK.BLK_TYPE  := AV_STL_TYPE;
        LV_CARD_BLACK.LAST_DATE := TO_DATE(AV_DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss');
        --LV_CARD_BLACK.VERSION := SEQ_BLACK_VISION.NEXTVAL;
        SELECT SEQ_BLACK_VISION.NEXTVAL
        INTO LV_CARD_BLACK.VERSION
        FROM DUAL;
        INSERT INTO CARD_BLACK VALUES LV_CARD_BLACK;
      END IF;
    ELSIF AV_STL_STATE = 1 THEN
      IF LV_COUNT      > 0 THEN
        UPDATE CARD_BLACK C
        SET C.BLK_STATE = 1,
          C.LAST_DATE   = TO_DATE(AV_DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss'),
          C.VERSION     = SEQ_BLACK_VISION.NEXTVAL
        WHERE C.CARD_NO = AV_CARD_NO;
      ELSE
        LV_CARD_BLACK.CARD_ID   := LV_CARD.CARD_ID;
        LV_CARD_BLACK.CARD_NO   := LV_CARD.CARD_NO;
        LV_CARD_BLACK.ORG_ID    := SUBSTR(LV_CARD.CARD_NO, 1, 4);
        LV_CARD_BLACK.BLK_STATE := AV_STL_STATE;
        LV_CARD_BLACK.BLK_TYPE  := '00'; --插入无效黑名单
        LV_CARD_BLACK.LAST_DATE := TO_DATE(AV_DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss');
        --LV_CARD_BLACK.VERSION := SEQ_BLACK_VISION.NEXTVAL;
        SELECT SEQ_BLACK_VISION.NEXTVAL
        INTO LV_CARD_BLACK.VERSION
        FROM DUAL;
        INSERT INTO CARD_BLACK VALUES LV_CARD_BLACK;
      END IF;
    END IF;
    -- 操作日志
    SELECT VERSION
    INTO LV_VERSION
    FROM CARD_BLACK
    WHERE CARD_NO              = AV_CARD_NO;
    LV_CARD_BLACK_REC.DEAL_NO := AV_DEAL_NO;
    LV_CARD_BLACK_REC.CARD_ID := LV_CARD.CARD_ID;
    LV_CARD_BLACK_REC.CARD_NO := LV_CARD.CARD_NO;
    LV_CARD_BLACK_REC.VERSION := LV_VERSION;
    IF AV_STL_STATE            = 0 THEN
      LV_CARD_BLACK_REC.NOTES := '增加黑名单';
    ELSE
      LV_CARD_BLACK_REC.NOTES := '减去黑名单';
    END IF;
    INSERT INTO CARD_BLACK_REC VALUES LV_CARD_BLACK_REC;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '操作黑名单成功';
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_CARD_BLACK;
--申请制卡  适用江阴
--av_in: 1姓名
--       2性别
--       3证件类型
--       4证件号码
--       5市民卡卡号
--       6户籍所在城区
--       7户籍所在乡镇（街道）
--       8户籍所在村（社区）
--       9居住地址
--      10联系地址
--      11邮政编码
--      12固定电话
--      13手机号码
--      14电子邮件
--      15单位客户名称
--      16受卡机终端标识码
--      17受卡方的标识码
--      18柜员号
--      19备注
--      20卡类型
--      21名族
--      22户籍类型 0 本地 1 外地
-- av_out：1持卡人姓名
--         2持卡人性别
--         3持卡人证件类型
--         4持卡人证件号码
--         5卡主类型 01
--         6卡子类型 00
--         7卡有效日期
--         8启用标志
--         9公共钱包应用启动日期
--         10公共钱包应用有效日期
  PROCEDURE p_applyCard
    (
      av_in    IN VARCHAR2, --传入参数
      av_debug IN VARCHAR2, --1调试
      av_out OUT VARCHAR2,  --返回信息
      av_res OUT VARCHAR2,  --传出代码
      av_msg OUT VARCHAR2   --传出错误信息
    )
  IS
    lv_count NUMBER;
    lv_in pk_public.myarray;                    --传入参数数组
    lv_base_personal base_personal%ROWTYPE;     --人员基础信息
    lv_base_corp base_corp%ROWTYPE;             --单位基础信息
    lv_operator sys_users%ROWTYPE;              --操作员
    lv_clrdate pay_clr_para.clr_date%TYPE;      --清分日期
    lv_card_apply card_apply%ROWTYPE;           --申领基本信息
    lv_card_apply_task card_apply_task%ROWTYPE; -- 任务信息
    lv_Card_task_list card_task_list%ROWTYPE;   -- 任务明细信息
    lv_card card_baseinfo%ROWTYPE;              --卡基本信息
    lv_action_log sys_action_log%ROWTYPE;       -- 操作日志表
    lv_serv_rec tr_serv_rec%Rowtype;            -- 综合业务日志表
    lv_action_no sys_action_log.deal_no%type;   -- 流水号
  BEGIN
    --分解入参
    pk_public.p_getinputpara(av_in, --传入参数
    22,                             --参数最少个数
    22,                             --参数最多个数
    'pk_transfer.p_transfer',       --调用的函数名
    lv_in,                          --转换成参数数组
    av_res,                         --传出参数代码
    av_msg                          --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    av_out := '';
    --判断接入点信息是否正确
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(18);
    IF lv_operator.user_id IS NULL OR lv_operator.brch_id <> lv_in(17) THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '受卡方身份验证失败';
      RETURN;
    END IF;
    --判断卡号信息是否正确（是否是市民卡预生成的卡号）
    SELECT COUNT(1)
    INTO lv_count
    FROM card_task_list t2
    WHERE t2.card_no = lv_in(5);
    IF lv_count     <> 1 THEN
      av_res        := pk_public.cs_res_cardiderr;
      av_msg        := '卡号验证失败';
      RETURN;
    END IF;
    -- 判断该用户是否只有一张全功能卡
    SELECT *
    INTO lv_base_personal
    FROM base_personal t3
    WHERE t3.cert_no             = lv_in(4);
    IF lv_base_personal.cert_no IS NOT NULL THEN
      SELECT COUNT(1)
      INTO lv_count
      FROM card_baseinfo t4
      WHERE t4.customer_id = lv_base_personal.customer_id
      AND t4.card_state   IN ('1', '0', '2', '3');
      IF lv_count         <> 1 THEN
        av_res            := pk_public.cs_res_cardis_err;
        av_msg            := '该客户存在全功能卡，不可重复申领';
        RETURN;
      END IF;
    END IF;
    -- 取得任务信息
    SELECT *
    INTO lv_Card_task_list
    FROM card_task_list t5
    WHERE t5.card_no = lv_in(5);
    SELECT *
    INTO lv_card_apply_task
    FROM card_apply_task t6
    WHERE t6.task_id = lv_Card_task_list.Task_Id;
    -- 验证完成后开始进行申领操作
    -- 插入综合业务日志和操作日志
    SELECT seq_action_no.nextval
    INTO lv_action_no
    FROM dual;
    SELECT t.clr_date INTO lv_clrdate FROM pay_clr_para t;
    lv_action_log.deal_no     := lv_action_no;
    lv_action_log.deal_code   := '150112';
    lv_action_log.org_id      := lv_operator.org_id;
    lv_action_log.brch_id     := lv_operator.brch_id;
    lv_action_log.user_id     := lv_operator.user_id;
    lv_action_log.deal_time   := to_date(TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type    := 0;
    lv_action_log.message     := '申请制卡：' + lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := '申请制卡：' + lv_operator.brch_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    lv_serv_rec.deal_no       := lv_action_no;
    lv_serv_rec.deal_code     := '150112';
    lv_serv_rec.customer_id   := lv_base_personal.customer_id;
    lv_serv_rec.card_id       := lv_in(5);
    lv_serv_rec.card_no       := lv_in(5);
    lv_serv_rec.card_type     := lv_in(20);
    lv_serv_rec.customer_name := lv_base_personal.name;
    lv_serv_rec.cert_type     := lv_in(3);
    lv_serv_rec.cert_no       := lv_in(4);
    lv_serv_rec.brch_id       := lv_operator.brch_id;
    lv_serv_rec.user_id       := lv_operator.user_id;
    lv_serv_rec.org_id        := lv_operator.org_id;
    lv_serv_rec.note          := av_in + '制卡申领';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --插入单位信息
    IF lv_in(15) IS NOT NULL THEN
      SELECT * INTO lv_base_corp FROM base_corp t7 WHERE t7.corp_name = lv_in(15);
      IF lv_base_corp.customer_id IS NULL THEN
        INSERT
        INTO base_corp
          (
            customer_id,
            corp_name,
            post_code
          )
          VALUES
          (
            seq_client_id.nextval,
            lv_in(15),
            '750000'
          );
      END IF;
    END IF;
    SELECT * INTO lv_base_corp FROM base_corp t7 WHERE t7.corp_name = lv_in(15);
    --插入人员基本信息
    --1 如果存在该人员信息 则修改该人员信息的辅助信息  --》插入申领表  --》 补充完善任务明细表字段
    --2 如果不存在该人员信息  则插入该人员信息 --》 插入申领表  --》 补充完善任务明细表字段
    IF lv_base_personal.cert_no IS NOT NULL THEN
      --1
      UPDATE base_personal bs
      SET bs.gender    = NVL(bs.gender, lv_in(2)),
        bs.region_id   = NVL(bs.region_id, lv_in(6)),
        bs.town_id     = NVL(bs.town_id, lv_in(7)),
        bs.comm_id     = NVL(bs.comm_id, lv_in(8)),
        bs.reside_addr = NVL(lv_in(9), bs.reside_addr),
        bs.letter_addr = NVL(lv_in(10), bs.letter_addr),
        bs.phone_no    = NVL(lv_in(12), bs.phone_no),
        bs.mobile_no   = NVL(lv_in(13), bs.mobile_no),
        bs.email       = NVL(lv_in(14), bs.email)
      WHERE bs.cert_no = lv_in(4);
    ELSE
      INSERT
      INTO base_personal
        (
          customer_id,
          name,
          cert_type,
          cert_no,
          birthday,
          gender,
          nation,
          country,
          reside_type,
          city_id,
          region_id,
          town_id,
          comm_id,
          reside_addr,
          letter_addr,
          post_code,
          phone_no,
          mobile_no,
          email,
          corp_customer_id,
          education,
          marr_state,
          career,
          income,
          customer_state,
          serv_pwd,
          serv_pwd_err_num,
          net_pwd,
          net_pwd_err_num,
          open_user_id,
          open_date,
          data_src,
          note
        )
        VALUES
        (
          seq_client_id.nextval,
          lv_in(1),
          lv_in(3),
          lv_in(4),
          SUBSTR(lv_in(4), 7, 8),
          lv_in(2),
          NVL(lv_in(21), '1'),
          NULL,
          NVL(lv_in(22), '0'),
          '7500',
          lv_in(6),
          lv_in(7),
          lv_in(8),
          lv_in(9),
          lv_in(10),
          NULL,
          lv_in(12),
          lv_in(13),
          lv_in(14),
          lv_base_corp.customer_id,
          NULL,
          NULL,
          NULL,
          NULL,
          '0',
          '000000',
          0,
          '000000',
          0,
          lv_operator.user_id,
          lv_action_log.deal_time,
          '1',
          '申请制卡（零星）'
        );
    END IF;
    --插入申领表
    INSERT
    INTO card_apply
      (
        apply_id,
        bar_code,
        customer_id,
        card_no,
        card_type,
        buy_plan_id,
        version,
        org_code,
        city_code,
        indus_code,
        apply_way,
        apply_type,
        make_type,
        apply_brch_id,
        corp_id,
        comm_id,
        apply_state,
        apply_user_id,
        apply_date,
        cost_fee,
        foregift,
        is_urgent,
        is_photo,
        deal_no,
        bus_type,
        other_fee,
        wallet_use_flag,
        town_id,
        task_id
      )
      VALUES
      (
        seq_apply_id.nextval,
        seq_bar_code.nextval,
        lv_base_personal.customer_id,
        lv_in(5),
        '100',
        lv_card_apply_task.make_batch_id,
        '1.0',
        lv_operator.org_id,
        '7500',
        '0000',
        '0',
        '0',
        '0',
        lv_operator.brch_id,
        lv_base_corp.customer_id,
        lv_in(8),
        '5',
        lv_operator.user_id,
        lv_action_log.deal_time,
        0,
        0,
        0,
        1,
        lv_action_log.deal_no,
        '01',
        0,
        '01',
        lv_in(7),
        lv_Card_task_list.Task_Id
      );
    --修改任务信息
    UPDATE card_task_list t8
    SET t8.customer_id     = lv_base_personal.customer_id,
      t8.cert_type         = lv_base_personal.cert_type,
      t8.cert_no           = lv_base_personal.cert_no,
      t8.sex               = lv_base_personal.gender,
      t8.name              = lv_base_personal.name,
      t8.struct_main_type  = '01',
      t8.struct_child_type = '00',
      t8.cardissuedate     = TO_CHAR(lv_action_log.deal_time, 'yyyymmdd'),
      t8.validitydate      = TO_CHAR(add_months(sysdate, 12 * 20), 'yyyymmdd'),
      t8.bus_use_flag      = '01',
      t8.bursestartdate    = TO_CHAR(lv_action_log.deal_time, 'yyyymmdd'),
      t8.bursevaliddate    = TO_CHAR(add_months(sysdate, 12 * 20), 'yyyymmdd')
    WHERE t8.data_seq      = lv_Card_task_list.Data_Seq
    AND t8.task_id         = lv_Card_task_list.Task_Id;
    --update card_apply_task t9 set t9.task_state = '3' where t9.task_id = lv_Card_task_list.Task_Id;
    SELECT *
    INTO lv_base_personal
    FROM base_personal
    WHERE cert_no = lv_in(4);
    SELECT * INTO lv_Card_task_list FROM card_task_list WHERE card_no = lv_in(5);
    --组装返回参数
    -- av_out：1持卡人姓名
    --         2持卡人性别
    --         3持卡人证件类型
    --         4持卡人证件号码
    --         5卡主类型 01
    --         6卡子类型 00
    --         7卡有效日期
    --         8启用标志
    --         9公共钱包应用启动日期
    --         10公共钱包应用有效日期
    SELECT lv_base_personal.name
      || '|'
      || lv_base_personal.gender
      || '|'
      || DECODE(lv_base_personal.cert_type, 1, '01', 2, '02', 3, '03', '4', 4, '04', 5, '05', 6, '06', '09')
      || '|'
      || lv_base_personal.cert_no
      || '|'
      || '01'
      || '|'
      || '00'
      || '|'
      || lv_Card_task_list.Validitydate
      || '|'
      || '01'
      || '|'
      || lv_Card_task_list.Bursestartdate
      || '|'
      || lv_Card_task_list.Bursevaliddate
      || '|'
    INTO av_out
    FROM dual;
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_Msg := NVL(sqlerrm, sqlerrm);
    ROLLBACK;
    UPDATE sys_action_log
    SET in_out_data = in_out_data
      || '------处理失败，错误信息：{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '‘')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_applyCard;
--1卡号  适用江阴
--2证件类型
--3证件号码
--4姓名
--5开户银行
--6卫生卡号
--7卡类型
--8受卡方的标识码
--9柜员号
--10备注
--11 是否有老卡 0 是 1 否
--12 老卡卡号
  PROCEDURE p_openAccandCard(
      av_in    IN VARCHAR2, --传入参数
      av_debug IN VARCHAR2, --1调试
      av_res OUT VARCHAR2,  --传出代码
      av_msg OUT VARCHAR2   --传出错误信息
    )
  IS
    lv_count NUMBER;
    lv_action_no sys_action_log.deal_no%type;     -- 流水号
    lv_clrdate pay_clr_para.clr_date%TYPE;        --清分日期
    lv_in pk_public.myarray;                      --传入参数数组
    lv_base_personal base_personal%ROWTYPE;       --人员基础信息
    lv_Card_task_list card_task_list%ROWTYPE;     -- 任务明细信息
    lv_operator sys_users%ROWTYPE;                --操作员
    lv_action_log sys_action_log%ROWTYPE;         -- 操作日志表
    lv_serv_rec tr_serv_rec%Rowtype;              -- 综合业务日志表
    lv_old_card card_baseinfo%rowtype;            --老卡卡信息
    lrec_acc_account_sub acc_account_sub%rowtype; --账户信息
    lv_acc_in   VARCHAR2(500);
    lv_trans_in VARCHAR2(500);
  BEGIN
    --分解入参
    pk_public.p_getinputpara(av_in, --传入参数
    12,                             --参数最少个数
    12,                             --参数最多个数
    'pk_transfer.p_transfer',       --调用的函数名
    lv_in,                          --转换成参数数组
    av_res,                         --传出参数代码
    av_msg                          --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res      := pk_public.cs_res_ok;
    av_msg      := '';
    lv_acc_in   := '';
    lv_trans_in := '';
    --判断接入点信息是否正确
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(18);
    IF lv_operator.user_id IS NULL OR lv_operator.brch_id <> lv_in(17) THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '受卡方身份验证失败';
      RETURN;
    END IF;
    --判断卡号信息是否正确（是否是市民卡预生成的卡号）
    SELECT COUNT(1)
    INTO lv_count
    FROM card_task_list t2
    WHERE t2.card_no = lv_in(5);
    IF lv_count     <> 1 THEN
      av_res        := pk_public.cs_res_cardiderr;
      av_msg        := '卡号验证失败';
      RETURN;
    END IF;
    SELECT * INTO lv_Card_task_list FROM card_task_list WHERE card_no = lv_in(1);
    --插入业务日志和操作日志
    -- 插入综合业务日志和操作日志
    SELECT seq_action_no.nextval
    INTO lv_action_no
    FROM dual;
    SELECT t.clr_date INTO lv_clrdate FROM pay_clr_para t;
    lv_action_log.deal_no     := lv_action_no;
    lv_action_log.deal_code   := '150111';
    lv_action_log.org_id      := lv_operator.org_id;
    lv_action_log.brch_id     := lv_operator.brch_id;
    lv_action_log.user_id     := lv_operator.user_id;
    lv_action_log.deal_time   := to_date(TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type    := 0;
    lv_action_log.message     := '卡发放：' + lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := av_in + '卡发放：' + lv_operator.brch_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    lv_serv_rec.deal_no       := lv_action_no;
    lv_serv_rec.deal_code     := '150112';
    lv_serv_rec.customer_id   := lv_base_personal.customer_id;
    lv_serv_rec.card_id       := lv_in(5);
    lv_serv_rec.card_no       := lv_in(5);
    lv_serv_rec.card_type     := lv_in(20);
    lv_serv_rec.customer_name := lv_base_personal.name;
    lv_serv_rec.cert_type     := lv_in(3);
    lv_serv_rec.cert_no       := lv_in(4);
    lv_serv_rec.brch_id       := lv_operator.brch_id;
    lv_serv_rec.user_id       := lv_operator.user_id;
    lv_serv_rec.org_id        := lv_operator.org_id;
    lv_serv_rec.note          := av_in + '卡发放';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --插入卡信息
    INSERT
    INTO card_baseinfo
      (
        card_id,
        card_no,
        customer_id,
        card_type,
        issue_org_id,
        version,
        init_org_id,
        city_code,
        indus_code,
        issue_date,
        start_date,
        valid_date,
        app1_valid_date,
        app2_valid_date,
        pay_pwd,
        pay_pwd_err_num,
        net_pay_pwd,
        net_pay_pwd_err_num,
        card_state,
        last_modify_date,
        cost_fee,
        foregift,
        foregift_bal,
        rent_foregift,
        sub_card_id,
        sub_card_no,
        sub_card_type,
        bank_id,
        bank_card_no,
        bar_code,
        cancel_date,
        cancel_reason,
        note,
        foregift_date,
        atr,
        rfatr,
        mobile_phone,
        main_flag,
        main_card_no,
        bus_type,
        bus_use_flag,
        month_type,
        month_charge_mode,
        pro_org_code,
        pro_media_type,
        pro_version,
        pro_init_date,
        recover_flag,
        vip_class
      )
      VALUES
      (
        lv_in(1),
        lv_in(1),
        lv_base_personal.customer_id,
        NVL(lv_in(7), '100'),
        lv_operator.org_id,
        '1.0',
        NULL,
        '7500',
        NULL,
        TO_CHAR(sysdate, 'yyyymmdd'),
        lv_Card_task_list.Cardissuedate,
        lv_Card_task_list.Validitydate,
        lv_Card_task_list.Validitydate,
        NULL,
        NULL, --交易密码
        0,
        '000000',
        0,
        '1',
        sysdate,
        0,
        0,
        0,
        0,
        lv_in(6),
        lv_in(6),
        NULL,
        lv_in(5),
        NULL,
        lv_Card_task_list.Bar_Code,
        NULL,
        NULL,
        lv_in(10),
        NULL,
        lv_in(6),
        lv_in(1),
        lv_base_personal.mobile_no,
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
        NULL
      );
    --调用开户存储过程
    --建账户
    --av_in: 1action_no|2DEAL_CODE|3oper_id|4oper_time|
    --5obj_type     类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
    --6sub_type     卡类型(不用传入)
    --7obj_id       账户主体类型是卡时，传入卡号，(多个卡号时，卡号之间以,分割 cardno1,cardno2)
    --                             其它传入client_id，
    --8pwd          不用
    --9encrypt      卡账户金额密文(多个卡号时，之间以,分割 encrypt1,encrypt2)
    SELECT lv_action_log.deal_no
      || '|'
      || '150112'
      || '|'
      || lv_operator.user_id
      || '|'
      || lv_action_log.deal_time
      || '|'
      || '1'
      || '|'
      || '100'
      || '|'
      || lv_in(1)
      || '|'
      || '|'
      || ''
    INTO lv_acc_in
    FROM dual; ---这里要修改0的密文
    pk_business.p_createaccount(lv_acc_in, av_res, av_msg);
    --判断是否有老卡；有老卡则将老卡的联机账户转到新卡联机账户上
    IF lv_in(12) = '0' THEN
      BEGIN
        --有卡是老卡不能为空 cs_res_oldcardnull_err
        IF lv_in(12) IS NULL THEN
          av_res     := pk_public.cs_res_oldcardnull_err;
          av_msg     := '老卡卡号不能为空';
          RETURN;
        END IF;
        SELECT *
        INTO lv_old_card
        FROM card_baseinfo
        WHERE card_no = lv_in(12)
        AND card_type = '100';
        --转移金额
        SELECT *
        INTO lrec_acc_account_sub
        FROM acc_account_sub
        WHERE card_no               = lv_old_card.card_no
        AND acc_kind                = '02';
        IF lrec_acc_account_sub.bal > 0 THEN
          lv_trans_in              := lv_trans_in || lv_action_log.deal_no || '|';                          --1action_no
          lv_trans_in              := lv_trans_in || '800359' || '|';                                       --2DEAL_CODE
          lv_trans_in              := lv_trans_in || lv_operator.user_id || '|';                            --3oper_id
          lv_trans_in              := lv_trans_in || lv_action_log.deal_time || '|';                        --4oper_time
          lv_trans_in              := lv_trans_in || lv_operator.brch_id || '|';                            --5acpt_id        受理点编号(网点号或商户编号)
          lv_trans_in              := lv_trans_in || TO_CHAR(lv_action_log.deal_time, 'yyyymmdd') || '|';   --6tr_batch_no    批次号
          lv_trans_in              := lv_trans_in || TO_CHAR(lv_action_log.deal_time, 'hh24:mi:ss') || '|'; --7term_tr_no     终端交易流水号
          lv_trans_in              := lv_trans_in || lv_in(12) || '|';                                      --8card_no1       转出卡号
          lv_trans_in              := lv_trans_in || '|';                                                   --9card_tr_count1 转出卡交易计数器
          lv_trans_in              := lv_trans_in || '|';                                                   --10card_bal1     转出卡钱包交易前金额
          lv_trans_in              := lv_trans_in || '02' || '|';                                           --11acc_kind1     转出卡账户类型
          lv_trans_in              := lv_trans_in || '00' || '|';                                           --12wallet_id1    转出卡钱包编号 默认00
          lv_trans_in              := lv_trans_in || lv_in(1) || '|';                                       --13card_no2      转入卡号
          lv_trans_in              := lv_trans_in || '|';                                                   --14card_tr_count2转入卡交易计数器
          lv_trans_in              := lv_trans_in || '|';                                                   --15card_bal2     转入卡钱包交易前金额
          lv_trans_in              := lv_trans_in || '02' || '|';                                           --16acc_kind2     转入卡账户类型
          lv_trans_in              := lv_trans_in || '00' || '|';                                           --17wallet_id2    转入卡钱包编号 默认00
          lv_trans_in              := lv_trans_in || '|';                                                   --18tr_amt        转账金额  null时转出所有金额
          lv_trans_in              := lv_trans_in || lv_old_card.pay_pwd || '|';                            --19pwd           转账密码
          lv_trans_in              := lv_trans_in || '补换卡转账' || '|';                                        --20note          备注
          lv_trans_in              := lv_trans_in || '0' || '|';                                            --21encrypt1      转出卡转账后金额密文 0 的密文，暂时不知道
          lv_trans_in              := lv_trans_in || lrec_acc_account_sub.bal_crypt || '|';                 --22encrypt2      转入卡转账后金额密文
          lv_trans_in              := lv_trans_in || '0' || '|';                                            --23tr_state      9写灰记录0直接写正常记录
          lv_trans_in              := lv_trans_in || '1' || '|';                                            --24acpt_type     受理点分类
          lv_trans_in              := lv_trans_in || lrec_acc_account_sub.bal || '|';                       --25acc_bal1      转出卡账户交易前金额
          lv_trans_in              := lv_trans_in || 0 || '|';                                              --26acc_bal2      转入卡账户交易前金额
          pk_transfer.p_transfer(lv_trans_in, '1', av_res, av_msg);
        END IF;
        IF av_res <> pk_public.cs_res_ok THEN
          Raise_application_error(-20000, av_msg);
        END IF;
      EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_oldcardnotexist_err;
        av_Msg := '原卡账户信息不存在';
        Raise_application_error(-20000, av_Msg);
      END;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_Msg := NVL(sqlerrm, sqlerrm);
    ROLLBACK;
    UPDATE sys_action_log
    SET in_out_data = in_out_data
      || '------处理失败，错误信息：{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '‘')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_openAccandCard;
--更新个人信息
--av_in: 1证件号码
--       2手机号
--       3家庭住址
--       4家庭联系电话
--       5柜员号
--       6微信号
  PROCEDURE p_updatePersonalInfo(
      av_in    IN VARCHAR2, --传入参数
      av_debug IN VARCHAR2, --1调试
      av_res OUT VARCHAR2,  --传出代码
      av_msg OUT VARCHAR2   --传出错误信息
    )
  IS
    lv_count NUMBER;
    lv_action_no sys_action_log.deal_no%type; -- 流水号
    lv_clrdate pay_clr_para.clr_date%TYPE;    --清分日期
    lv_in pk_public.myarray;                  --传入参数数组
    lv_operator sys_users%ROWTYPE;            --操作员
    lv_action_log sys_action_log%ROWTYPE;     -- 操作日志表
    lv_base_personal base_personal%ROWTYPE;   --人员基础信息
    lv_serv_rec tr_serv_rec%Rowtype;          -- 综合业务日志表
  BEGIN
    --分解入参
    pk_public.p_getinputpara(av_in,          --传入参数
    6,                                       --参数最少个数
    6,                                       --参数最多个数
    'PK_SERVICE_OUTER.p_updatePersonalInfo', --调用的函数名
    lv_in,                                   --转换成参数数组
    av_res,                                  --传出参数代码
    av_msg                                   --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    --判断接入点信息是否正确
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(5);
    IF lv_operator.user_id IS NULL THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '受卡方身份验证失败';
      RETURN;
    END IF;
    SELECT *
    INTO lv_base_personal
    FROM base_personal l
    WHERE l.cert_no                  = lv_in(1);
    IF lv_base_personal.customer_id IS NULL THEN
      av_res                        := pk_public.cs_res_user_err;
      av_msg                        := '身份号验证失败';
      RETURN;
    END IF;
    --操作日志
    SELECT seq_action_no.nextval INTO lv_action_no FROM dual;
    SELECT t.clr_date INTO lv_clrdate FROM pay_clr_para t;
    lv_action_log.deal_no     := lv_action_no;
    lv_action_log.deal_code   := 10101020;
    lv_action_log.org_id      := lv_operator.org_id;
    lv_action_log.brch_id     := lv_operator.brch_id;
    lv_action_log.user_id     := lv_operator.user_id;
    lv_action_log.deal_time   := to_date(TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type    := 0;
    lv_action_log.message     := '修改个人信息：' || lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := av_in || '修改个人信息：' || lv_operator.brch_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    --记录业务日志
    lv_serv_rec.deal_no       := lv_action_log.deal_no;
    lv_serv_rec.deal_code     := lv_action_log.deal_code;
    lv_serv_rec.customer_id   := lv_base_personal.customer_id;
    lv_serv_rec.card_id       := lv_in(1);
    lv_serv_rec.card_no       := lv_in(1);
    lv_serv_rec.card_type     := '';
    lv_serv_rec.customer_name := lv_base_personal.name;
    lv_serv_rec.cert_type     := lv_base_personal.cert_type;
    lv_serv_rec.cert_no       := lv_in(1);
    lv_serv_rec.brch_id       := lv_operator.brch_id;
    lv_serv_rec.user_id       := lv_operator.user_id;
    lv_serv_rec.org_id        := lv_operator.org_id;
    lv_serv_rec.note          := av_in || '修改个人信息';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    lv_serv_rec.rsv_five      :=lv_in(4);--微信编号
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --更新手机号,家庭地址，家庭联系电话
    UPDATE base_personal b
    SET b.mobile_no = lv_in(2),
      b.reside_addr = lv_in(3),
      b.wechat_no   = lv_in(5),
      b.tel_nos     = lv_in(4)
    WHERE b.cert_no = lv_in(1);
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_Msg := NVL(sqlerrm, sqlerrm);
    ROLLBACK;
    UPDATE sys_action_log
    SET in_out_data = in_out_data
      || '------处理失败，错误信息：{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '‘')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_updatePersonalInfo;
-- av_in:1合作机构编号
--       2机构住址
--       3机构联系电话
--       4柜员号
  PROCEDURE p_update_Co_Org(
      av_in    IN VARCHAR2, --传入参数
      av_debug IN VARCHAR2, --1调试
      av_res OUT VARCHAR2,  --传出代码
      av_msg OUT VARCHAR2   --传出错误信息
    )
  IS
    lv_count NUMBER;
    lv_action_no sys_action_log.deal_no%type; -- 流水号
    lv_clrdate pay_clr_para.clr_date%TYPE;    --清分日期
    lv_in pk_public.myarray;                  --传入参数数组
    lv_operator sys_users%ROWTYPE;            --操作员
    lv_action_log sys_action_log%ROWTYPE;     -- 操作日志表
    lv_base_co_org base_co_org%ROWTYPE;       --合作机构信息
    lv_serv_rec tr_serv_rec%Rowtype;          -- 综合业务日志表
  BEGIN
    --分解入参
    pk_public.p_getinputpara(av_in,     --传入参数
    4,                                  --参数最少个数
    4,                                  --参数最多个数
    'PK_SERVICE_OUTER.p_update_Co_Org', --调用的函数名
    lv_in,                              --转换成参数数组
    av_res,                             --传出参数代码
    av_msg                              --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    --判断接入点信息是否正确
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(4);
    IF lv_operator.user_id IS NULL THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '合作机构身份验证失败';
      RETURN;
    END IF;
    SELECT * INTO lv_base_co_org FROM base_co_org g WHERE g.co_org_id = lv_in(1);
    IF lv_base_co_org.customer_id IS NULL THEN
      av_res                      := pk_public.cs_res_user_err;
      av_msg                      := '机构编号验证失败';
      RETURN;
    END IF;
    --操作日志
    SELECT seq_action_no.nextval INTO lv_action_no FROM dual;
    SELECT t.clr_date INTO lv_clrdate FROM pay_clr_para t;
    lv_action_log.deal_no     := lv_action_no;
    lv_action_log.deal_code   := 10101020;
    lv_action_log.org_id      := lv_operator.org_id;
    lv_action_log.brch_id     := lv_operator.brch_id;
    lv_action_log.user_id     := lv_operator.user_id;
    lv_action_log.deal_time   := to_date(TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type    := 0;
    lv_action_log.message     := '修改合作机构信息：' + lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := av_in + '修改合作机构信息：' + lv_operator.brch_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    --记录业务日志
    lv_serv_rec.deal_no       := lv_action_log.deal_no;
    lv_serv_rec.deal_code     := lv_action_log.deal_code;
    lv_serv_rec.customer_id   := lv_base_co_org.customer_id;
    lv_serv_rec.card_id       := lv_in(1);
    lv_serv_rec.card_no       := lv_in(1);
    lv_serv_rec.card_type     := '';
    lv_serv_rec.customer_name := lv_base_co_org.co_org_name;
    lv_serv_rec.cert_type     := lv_base_co_org.co_org_type;
    lv_serv_rec.cert_no       := lv_in(1);
    lv_serv_rec.brch_id       := lv_operator.brch_id;
    lv_serv_rec.user_id       := lv_operator.user_id;
    lv_serv_rec.org_id        := lv_operator.org_id;
    lv_serv_rec.note          := av_in + '修改合作机构信息';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --更新手机号,家庭地址，家庭联系电话
    UPDATE base_co_org b
    SET b.address     = lv_in(2),
      b.contact       = lv_in(3)
    WHERE b.co_org_id = lv_in(1);
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_Msg := NVL(sqlerrm, sqlerrm);
    ROLLBACK;
    UPDATE sys_action_log
    SET in_out_data = in_out_data
      || '------处理失败，错误信息：{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '‘')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_update_Co_Org;
--合作机构服务密码修改
--1：bizid 合作机构号
--2：oper_id 操作员
--3：old_pwd 老密码
--4：new_pwd 新密码
  PROCEDURE P_Update_Co_Org_Pwd(
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2)
  IS
    LV_IN PK_PUBLIC.MYARRAY;
    LV_CLR_DATE PAY_CLR_PARA.CLR_DATE%TYPE;
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_TR_SERV_REC TR_SERV_REC%ROWTYPE;
  BEGIN
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN, 4, 4, 'PK_SERVICE_OUTER.P_Update_Co_Org_Pwd', lv_in, av_res, av_msg);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    SELECT * INTO LV_BASE_CO_ORG FROM BASE_CO_ORG WHERE CO_ORG_ID = LV_IN(1);
    IF LV_BASE_CO_ORG.CUSTOMER_ID IS NULL THEN
      av_res                      := pk_public.cs_res_user_err;
      av_msg                      := '机构编号验证失败';
      RETURN;
    END IF;
    SELECT * INTO LV_USERS FROM sys_users r WHERE r.user_id=LV_IN(2);
    IF LV_USERS.MYID IS NULL THEN
      av_msg         := '操作员验证失败';
      RETURN;
    END IF;
    IF LV_IN(3) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '原始密码不能为空';
      RETURN;
    END IF;
    IF LV_IN(4) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '新密码不能为空';
      RETURN;
    END IF;
    IF LV_BASE_CO_ORG.Serv_Pwd<> encrypt_des_oracle(LV_IN(3),LV_BASE_CO_ORG.Customer_Id) THEN
      av_res                  := pk_public.cs_res_pwderr;
      av_msg                  := '原始密码不正确';
      RETURN;
    END IF;
    IF NVL(LV_BASE_CO_ORG.Serv_Pwd_Err_Num,0)>=pk_public.cs_serv_pwd_err_num THEN
      av_res                                := pk_public.cs_res_pwderrnum ;
      av_msg                                := '密码错误次数超过'||pk_public.cs_serv_pwd_err_num||'次';
      RETURN;
    END IF;
    UPDATE base_co_org o
    SET o.serv_pwd      = encrypt_des_oracle(LV_IN(4),LV_BASE_CO_ORG.Customer_Id),
      o.serv_pwd_err_num=0
    WHERE o.co_org_id   = LV_IN(1) ;
    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYSACTIONLOG.DEAL_NO FROM DUAL;
    LV_SYSACTIONLOG.DEAL_CODE   := 20502020;
    LV_SYSACTIONLOG.MESSAGE     := '合作机构服务密码修改,编号:' || lv_in(1) || ',名称:' || LV_BASE_CO_ORG.CO_ORG_NAME;
    LV_SYSACTIONLOG.DEAL_TIME   := SYSDATE;
    LV_SYSACTIONLOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYSACTIONLOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYSACTIONLOG.LOG_TYPE    := 0;
    LV_SYSACTIONLOG.IN_OUT_DATA := AV_IN;
    LV_SYSACTIONLOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
    LV_SYSACTIONLOG.ORG_ID      := LV_USERS.ORG_ID;
    INSERT INTO SYS_ACTION_LOG VALUES LV_SYSACTIONLOG;
    LV_TR_SERV_REC.DEAL_NO       := LV_SYSACTIONLOG.DEAL_NO;
    LV_TR_SERV_REC.DEAL_CODE     := LV_SYSACTIONLOG.DEAL_CODE;
    LV_TR_SERV_REC.CUSTOMER_ID   := LV_BASE_CO_ORG.CUSTOMER_ID;
    LV_TR_SERV_REC.CUSTOMER_NAME := LV_BASE_CO_ORG.CO_ORG_NAME;
    LV_TR_SERV_REC.CERT_TYPE     := LV_BASE_CO_ORG.CO_ORG_TYPE;
    LV_TR_SERV_REC.CERT_NO       := LV_BASE_CO_ORG.CON_CERT_NO;
    LV_TR_SERV_REC.TEL_NO        := LV_BASE_CO_ORG.CON_PHONE;
    LV_TR_SERV_REC.CO_ORG_ID     := NVL(LV_BASE_CO_ORG.CO_ORG_ID, '');
    LV_TR_SERV_REC.BIZ_TIME      := LV_SYSACTIONLOG.DEAL_TIME;
    LV_TR_SERV_REC.BRCH_ID       := LV_USERS.BRCH_ID;
    LV_TR_SERV_REC.USER_ID       := LV_USERS.USER_ID;
    LV_TR_SERV_REC.CLR_DATE      := LV_CLR_DATE;
    LV_TR_SERV_REC.CARD_AMT      := '1';
    LV_TR_SERV_REC.NOTE          := LV_SYSACTIONLOG.MESSAGE;
    LV_TR_SERV_REC.NUM           := 1;
    LV_TR_SERV_REC.DEAL_STATE    := '0';
    INSERT INTO TR_SERV_REC VALUES LV_TR_SERV_REC;
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_Update_Co_Org_Pwd;
--合作机构交易信息查询
  PROCEDURE P_Co_Org_Query
    (
      AV_CO_ORG_ID  VARCHAR2,           --机构编号
      AV_DEAL_TYPE  VARCHAR2,           --查询交易类型 0 查询所有 1 查询充值  2 查询消费
      AV_ITEM_NO    VARCHAR2,           --科目类型
      AV_START_DATE VARCHAR2,           --查询起始日期  YYYY-MM-DD
      AV_END_DATE   VARCHAR2,           --查询结束日期 YYYY-MM-DD
      AV_PAGE_NO    NUMBER,             --第几页
      AV_PCOUNT     NUMBER,             --每页多少条,
      AV_ORDERBY    VARCHAR2,           --排序字段
      AV_ORDER      VARCHAR2,           --升序 asc 降序  desc
      AV_ALL_SIZE OUT NUMBER,           --总共多少行
      AV_ALL_PAGE OUT NUMBER,           --总共个多少页
      AV_DATA OUT ZPAGE.DEFAULT_CURSOR, --结果数据
      AV_RES OUT VARCHAR2,              --处理结果代码
      AV_MSG OUT VARCHAR2               --处理结果说明
    )
  IS
    LV_TABLE_NAME_ARR PK_PUBLIC.MYARRAY;
    LV_SQL        VARCHAR2(5000) := '';
    LV_TABLENAMES VARCHAR2(3000) := '';
    LV_DEAL_TYPE  VARCHAR2(1)    := 0;
    LV_ORDERBY    VARCHAR(50)    := '';
    LV_ORDER      VARCHAR2(4)    := '';
    LV_MONTH_NUM  NUMBER         := 0;
  BEGIN
    IF AV_CO_ORG_ID IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '机构编号不能为空';
      RETURN;
    END IF;
    IF AV_DEAL_TYPE IS NULL THEN
      LV_DEAL_TYPE  := '0';
    ELSIF AV_DEAL_TYPE IN ('0', '1', '2') THEN
      LV_DEAL_TYPE := AV_DEAL_TYPE;
    ELSE
      LV_DEAL_TYPE := '0';
    END IF;
    IF AV_START_DATE IS NULL THEN
      AV_RES         := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG         := '查询起始日期不能为空';
      RETURN;
    END IF;
    IF AV_END_DATE IS NULL THEN
      AV_RES       := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG       := '查询结束日期不能为空';
      RETURN;
    END IF;
    IF AV_END_DATE < AV_START_DATE THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '查询起始日期不能大于结束日期';
      RETURN;
    END IF;
    LV_MONTH_NUM        := MONTHS_BETWEEN(TO_DATE(AV_END_DATE, 'yyyy-mm-dd'), TO_DATE(AV_START_DATE, 'yyyy-mm-dd'));
    IF ABS(LV_MONTH_NUM) > 3 THEN
      AV_RES            := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG            := '只供查询相邻3个月内的记录信息';
      RETURN;
    END IF;
    --DBMS_OUTPUT.put_line(LV_MONTH_NUM);
    IF AV_ORDERBY IS NULL THEN
      LV_ORDERBY  := 'DEAL_NO';
    ELSE
      LV_ORDERBY := AV_ORDERBY;
    END IF;
    IF AV_ORDER IS NULL THEN
      LV_ORDER  := 'DESC';
    ELSIF UPPER(AV_ORDER) NOT IN ('ASC', 'DESC') THEN
      LV_ORDER := 'DESC';
    ELSE
      LV_ORDER := AV_ORDER;
    END IF;
    SELECT T.TABLE_NAME BULK COLLECT
    INTO LV_TABLE_NAME_ARR
    FROM USER_TABLES T
    WHERE T.TABLE_NAME BETWEEN 'ACC_INOUT_DETAIL_'
      || REPLACE(SUBSTR(AV_START_DATE, 1, 7), '-', '')
    AND 'ACC_INOUT_DETAIL_'
      || REPLACE(SUBSTR(AV_END_DATE, 1, 7), '-', '');
    IF LV_TABLE_NAME_ARR.COUNT < 1 THEN
      AV_RES                  := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                  := '查询日期超过界限';
      RETURN;
    END IF;
    FOR I_INDEX IN LV_TABLE_NAME_ARR.FIRST .. LV_TABLE_NAME_ARR.LAST
    LOOP
      IF I_INDEX       = LV_TABLE_NAME_ARR.LAST THEN
        LV_TABLENAMES := LV_TABLENAMES || 'SELECT * FROM ' || LV_TABLE_NAME_ARR(I_INDEX) || ' ';
      ELSE
        LV_TABLENAMES := LV_TABLENAMES || 'SELECT * FROM ' || LV_TABLE_NAME_ARR(I_INDEX) || ' UNION ';
      END IF;
    END LOOP;
    ---trname:交易名, acptname :受理点名称,accname:户名,actionno:交易流水,bal:交易前余额,amt:交易发生额,trdate:交易时间}
    LV_SQL        := LV_SQL || 'select (select r.deal_code_name from SYS_CODE_TR R where r.deal_code=t.deal_code and rownum=1) trname,(select g.co_org_name from base_co_org g where g.co_org_id=t.acpt_org_id and rownum=1)acptname,(select a.acc_name from acc_account_sub a where a.card_no=t.db_card_no and a.acc_kind=''02''  and rownum=1) acc_name,t.deal_code,t.db_acc_bal bal,t.db_amt amt,TO_CHAR(t.deal_date,''YYYY-MM-DD HH24:MI:SS'') trdate ';
    LV_SQL        := LV_SQL || ',t.deal_no FROM (' || LV_TABLENAMES || ') T where 1=1 ';
    LV_SQL        := LV_SQL || ' AND T.CLR_DATE >= ''' || AV_START_DATE || ''' and t.clr_date <= ''' || AV_END_DATE || '''';
    IF AV_ITEM_NO IS NOT NULL THEN
      LV_SQL      := LV_SQL || ' AND T.db_item_id = ''' || AV_ITEM_NO || ''' ';
    END IF;
    IF AV_CO_ORG_ID IS NOT NULL THEN
      LV_SQL        := LV_SQL || ' AND T.acpt_org_id = ''' || AV_CO_ORG_ID || ''' ';
    END IF;
    --LV_SQL := LV_SQL || ' AND T.CARD_NO = ''' || AV_CARD_NO || ''' ';
    IF LV_DEAL_TYPE    = '1' THEN
      LV_SQL          := LV_SQL || ' AND T.DEAL_CODE LIKE ''30%'' ';
    ELSIF LV_DEAL_TYPE = '2' THEN
      LV_SQL          := LV_SQL || ' AND T.DEAL_CODE LIKE ''40%'' ';
    END IF;
    IF UPPER(LV_ORDERBY) IN ('AMT', 'BAL') THEN
      LV_ORDERBY := 'TO_NUMBER(' || LV_ORDERBY || ') ';
    END IF;
    LV_SQL := LV_SQL || ' ORDER BY ' || LV_ORDERBY || ' ' || LV_ORDER;
    --DBMS_OUTPUT.PUT_LINE(LV_SQL);
    ZPAGE.PAGE(LV_SQL, AV_PAGE_NO, AV_PCOUNT, AV_ALL_SIZE, AV_ALL_PAGE, AV_DATA, AV_RES, AV_MSG);
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_Co_Org_Query;
--录入市民卡保单信息
-- av_in:1合作机构编号
-- 2 保单编号
-- 3 市民卡卡号
-- 4 客户姓名
-- 5 身份证号
-- 6 社会保障号
-- 7 购买时间
-- 8 应用状态(投保状态）<1已购买、未出单>、<2已购买、出单中>、<3已生效>、<4已过期>';
-- 9 保险名称
-- 10 投保金额
-- 11 保单有效期（起止）
-- 12 网点编号
-- 13 操作人员编号
  PROCEDURE p_Entering_Insure(
      av_in IN VARCHAR2,   --传入参数
      av_res OUT VARCHAR2, --传出代码
      av_msg OUT VARCHAR2  --传出错误信息
    )
  IS
    lv_in pk_public.myarray;            --传入参数数组
    lv_operator sys_users%ROWTYPE;      --操作员
    lv_card_app_bx CARD_APP_BX%ROWTYPE; --保险单信息
    lv_base_co_org base_co_org%ROWTYPE; --合作机构信息
  BEGIN
    --分解入参
    pk_public.p_getinputpara(av_in,       --传入参数
    13,                                   --参数最少个数
    13,                                   --参数最多个数
    'PK_SERVICE_OUTER.p_Entering_Insure', --调用的函数名
    lv_in,                                --转换成参数数组
    av_res,                               --传出参数代码
    av_msg                                --传出参数错误信息
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    --判断接入点信息是否正确
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(13);
    IF lv_operator.user_id IS NULL THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '受卡方身份验证失败';
      RETURN;
    END IF;
    SELECT * INTO lv_base_co_org FROM base_co_org g WHERE g.co_org_id = lv_in(1);
    IF lv_base_co_org.customer_id IS NULL THEN
      av_res                      := pk_public.cs_res_user_err;
      av_msg                      := '机构编号验证失败';
      RETURN;
    END IF;
    --操作日志
    SELECT seq_card_app_bx.nextval INTO lv_card_app_bx.bx_app_id FROM dual;
    lv_card_app_bx.oper_time     := sysdate;
    lv_card_app_bx.insure_no     := lv_in(2);
    lv_card_app_bx.card_no       := lv_in(3);
    lv_card_app_bx.customer_name := lv_in(4);
    lv_card_app_bx.cert_no       := lv_in(5);
    lv_card_app_bx.sub_card_no   := lv_in(6);
    lv_card_app_bx.buy_date      := to_date(lv_in(7),'YYYY-MM-DD');
    lv_card_app_bx.insure_state  := lv_in(8);
    lv_card_app_bx.insure_name   := lv_in(9);
    lv_card_app_bx.insure_amt    := NVL(lv_in(10),0);
    lv_card_app_bx.validity_date := lv_in(11);
    lv_card_app_bx.user_id       := lv_operator.user_id;
    lv_card_app_bx.co_org_id     := lv_base_co_org.co_org_id;
    lv_card_app_bx.brch_id       := lv_in(12);
    INSERT INTO card_app_bx VALUES lv_card_app_bx;
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_Msg := NVL(sqlerrm, sqlerrm);
    ROLLBACK;
  END p_Entering_Insure;
--保存短信
--1：AV_CARDBASEINFO --卡信息
--2：AV_BASEPERSON --人员信息
--3：AV_SYSACTIONLOG 日志信息
--4：AV_SMS_TYPE 短信类型 01发放02充值03消费04圈存 99自定义短信
--5:AV_AMT 金额
  PROCEDURE p_Save_Message
    (
      AV_CARDBASEINFO IN card_baseinfo%ROWTYPE,  --卡信息
      AV_BASEPERSON   IN base_personal%ROWTYPE,  --人员信息
      AV_SYSACTIONLOG IN SYS_ACTION_LOG%ROWTYPE, --日志信息
      AV_SMS_TYPE     IN VARCHAR2,               --短信类型 01发放02充值03消费04圈存 99自定义短信
      AV_AMT          IN INTEGER,                --金额
      av_res OUT VARCHAR2,                       --传出代码
      av_msg OUT VARCHAR2
    )
  IS
    SMESSAGE SYS_SMESSAGES%ROWTYPE;              --短信信息
    SYSCODE SYS_CODE_TR%ROWTYPE;                 --参数类型信息
    SYSSMESSAGESPARA SYS_SMESSAGES_PARA%ROWTYPE; --短信参数信息
    ROWNCOUNT INTEGER;
    AS_SMS_NO INTEGER;
  BEGIN
    SELECT SEQ_SYS_SMESSAGES.NEXTVAL INTO AS_SMS_NO FROM DUAL;
    SMESSAGE.SMS_NO      := AS_SMS_NO;
    SMESSAGE.DEAL_NO     := AV_SYSACTIONLOG.DEAL_NO;                   --//业务流水号：关联业务表记录
    SMESSAGE.CARD_NO     := AV_CARDBASEINFO.CARD_NO;                   --//卡号
    SMESSAGE.CUSTOMER_ID := AV_CARDBASEINFO.CUSTOMER_ID;               --//客户编号：关联客户信息
    SMESSAGE.MOBILE_NO   := AV_CARDBASEINFO.Mobile_Phone;              --//电话号码：取自bs_person.MBOPEN_NO手机号码或调用者传入
    SMESSAGE.OPER_ID     := AV_SYSACTIONLOG.USER_ID;                   --//柜员编号
    SMESSAGE.SMS_TYPE    := AV_SMS_TYPE;                               --//短信类型 01发放02充值03消费04圈存 99自定义短信
    SMESSAGE.Create_Time := TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:ss'); --//短信生成时间：默认数据库系统时间
    SMESSAGE.DEAL_CODE   := AV_SYSACTIONLOG.DEAL_CODE;
    SMESSAGE.SMS_STATE   := '0'; --//短信状态 0未发送 1已发送 2发送成功 3发送失败
    --短信参数信息
    SELECT COUNT(*)
    INTO ROWNCOUNT
    FROM SYS_SMESSAGES_PARA S
    WHERE S.DEAL_CODE = AV_SYSACTIONLOG.DEAL_CODE
    AND S.STATE       = '0';
    --参数信息
    SELECT *
    INTO SYSCODE
    FROM SYS_CODE_TR S
    WHERE S.DEAL_CODE=AV_SYSACTIONLOG.DEAL_CODE;
    IF ROWNCOUNT     > 0 THEN
      SELECT *
      INTO SYSSMESSAGESPARA
      FROM SYS_SMESSAGES_PARA S
      WHERE S.DEAL_CODE = AV_SYSACTIONLOG.DEAL_CODE
      AND S.STATE       = '0';
      --现金充值--尊敬的用户，您的{%}联机账户于{%}现金充值{%}元。
      IF AV_SYSACTIONLOG.DEAL_CODE = 30101020 THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '联机账户于' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '现金充值' || SUBSTR(TO_CHAR(AV_AMT), 0, LENGTH(TO_CHAR(AV_AMT)) - 2) || '.' || SUBSTR(TO_CHAR(AV_AMT), LENGTH(TO_CHAR(AV_AMT)) - 1, 2) || '元';
      END IF;
      --银联充值--尊敬的用户，您的{%}联机账户于{%}银联充值{%}元。
      IF AV_SYSACTIONLOG.DEAL_CODE = 30301020 THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '联机账户于' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '银联充值' || SUBSTR(TO_CHAR(AV_AMT), 0, LENGTH(TO_CHAR(AV_AMT)) - 2) || '.' || SUBSTR(TO_CHAR(AV_AMT), LENGTH(TO_CHAR(AV_AMT)) - 1, 2) || '元';
      END IF;
      --预挂失--尊敬的用户，您的{%}在{%}预挂失成功，系统将在48小时后自动解挂，请您及时到市民卡服务中心或合作网点办理书面挂失以确保资金安全。
      IF AV_SYSACTIONLOG.DEAL_CODE = 20501050 THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '在' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '预挂失成功，系统将在48小时后自动解挂，请您及时到市民卡服务中心或合作网点办理书面挂失以确保资金安全。';
      END IF;
      --退健康卡保证金--尊敬的用户，您的{%}联机账户在联网医疗机构于{%}退健康卡保证金{%}元。
      IF AV_SYSACTIONLOG.DEAL_CODE = '2632' THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '联机账户在联网医疗机构于' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '退医疗保证金' || AV_AMT / 100 || '元。';
      END IF;
      --尊敬的用户，您的{%}在{%}解挂成功。
      IF AV_SYSACTIONLOG.DEAL_CODE = 20501060 THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '在' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '解挂成功';
      END IF;
      --尊敬的用户，您的{%}在{%}正式挂失成功
      IF AV_SYSACTIONLOG.DEAL_CODE = 20501040 THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '在' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '正式挂失成功';
      END IF;
      IF AV_SYSACTIONLOG.DEAL_CODE = '2611' THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '在' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '正式挂失成功';
      END IF;
      IF AV_SYSACTIONLOG.DEAL_CODE = 20401050 THEN
        SMESSAGE.CONTENT          := '尊敬的用户，您的' || SYSCODE.DEAL_CODE_NAME || '在' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '开户成功';
      END IF;
      --插入短信记录
      INSERT INTO SYS_SMESSAGES VALUES SMESSAGE;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_msg := '系统错误';
    ROLLBACK;
    RAISE_APPLICATION_ERROR('-20001', SQLERRM);
  END p_Save_Message;
BEGIN
  -- INITIALIZATION
  NULL;
END PK_SERVICE_OUTER;
/

