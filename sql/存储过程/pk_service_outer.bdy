CREATE OR REPLACE PACKAGE BODY PK_SERVICE_OUTER
IS
  --����������ж�,�������������Ϣ
  PROCEDURE P_JUDGE_ACPT(
      AV_ACPT_ID   VARCHAR2, --���������
      AV_ACPT_TYPE VARCHAR2, --�������/������
      AV_USER_ID   VARCHAR2, --�ն˺�/����Ա
      AV_SYS_USERS OUT SYS_USERS%ROWTYPE,
      AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE,
      AV_RES OUT VARCHAR2, --�������
      AV_MSG OUT VARCHAR2  --��������������Ϣ
    )
  IS
  BEGIN
    IF AV_ACPT_TYPE IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    IF AV_ACPT_ID IS NULL THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '������Ų���ȷ';
      RETURN;
    END IF;
    IF AV_ACPT_TYPE  = '1' THEN
      IF AV_USER_ID IS NULL THEN
        AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG      := '��Ա��Ų���Ϊ��';
        RETURN;
      END IF;
      PK_CARD_STOCK.P_GETUSERSBYUSERID(AV_ACPT_ID,AV_USER_ID,AV_SYS_USERS,AV_RES,AV_MSG,'��Ա��Ϣ');
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
        AV_MSG := '���ݺ����������' || AV_ACPT_ID || '�Ҳ�������������Ϣ';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '���ݺ����������' || AV_ACPT_ID || '��ȡ����������Ϣ���ִ���' || SQLERRM;
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
--���˵�¼
  PROCEDURE P_LOGIN_GR(
      AV_CARD_NO VARCHAR2,   --����
      AV_CERT_NO VARCHAR2,   --֤������
      AV_TELNO   VARCHAR2,   --�ֻ�����
      AV_PWD     VARCHAR2,   --��¼����
      AV_CERTNO OUT VARCHAR2,--֤����
      AV_RES OUT VARCHAR2,   --����������
      AV_MSG OUT VARCHAR2    --������˵��
    )
  IS
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE;
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE;
    LV_CARD_APPLY CARD_APPLY%ROWTYPE;
  BEGIN
    IF AV_CARD_NO IS NULL AND AV_CERT_NO IS NULL AND AV_TELNO IS NULL THEN
      AV_RES      := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG      := '��¼��Ų���Ϊ��';
      RETURN;
    END IF;
    IF AV_PWD IS NULL THEN
      AV_RES  := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG  := '��¼���벻��Ϊ��';
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
        AV_MSG                   := '������Ϣ������';
        RETURN;
      ELSIF LV_CARD_BASEINFO.CARD_NO = '-1' THEN
        AV_RES                      := PK_PUBLIC.CS_RES_CARDIDERR;
        AV_MSG                      := '���ݿ��Ż�ȡ����Ϣ���ִ���';
        RETURN;
      END IF;
      PK_PUBLIC.P_GETCARDBYCARDNO(LV_CARD_BASEINFO.CARD_NO, LV_CARD_BASEINFO, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG  := REPLACE(AV_MSG, LV_CARD_APPLY.CARD_NO, AV_CARD_NO);
        RETURN;
      END IF;
      IF LV_CARD_BASEINFO.CUSTOMER_ID IS NULL THEN
        AV_RES                        := PK_PUBLIC.CS_RES_PERSONALVIL_ERR;
        AV_MSG                        := '���ݿ����Ҳ����ֿ�����Ϣ';
        RETURN;
      END IF;
      IF LV_CARD_APPLY.CUSTOMER_ID <> LV_CARD_BASEINFO.CUSTOMER_ID THEN
        AV_RES                     := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG                     := '����' || LV_CARD_BASEINFO.CARD_NO || '�ĳ����˺������¼��Ϣ��һ��';
        RETURN;
      END IF;
      PK_PUBLIC.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_RES  := PK_PUBLIC.CS_RES_PERSONALVIL_ERR;
        AV_MSG  := '���ݿ�Ƭ�����˱���Ҳ�����Ա��Ϣ';
        RETURN;
      END IF;
    ELSIF AV_CERT_NO IS NOT NULL THEN
      PK_PUBLIC.P_GETBASEPERSONALBYCERTNO(AV_CERT_NO, LV_BASE_PERSONAL, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_RES  := PK_PUBLIC.CS_RES_PERSONALVIL_ERR;
        AV_MSG  := '����֤�������Ҳ�����Ա��Ϣ';
        RETURN;
      END IF;
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG := '��¼��Ų���Ϊ��';
      RETURN;
    END IF;
    IF NVL(LV_BASE_PERSONAL.SERV_PWD_ERR_NUM, 0) >= PK_PUBLIC.CS_SERV_PWD_ERR_NUM THEN
      AV_RES                                     := PK_PUBLIC.CS_RES_PWDERRNUM;
      AV_MSG                                     := '�������������';
      RETURN;
    END IF;
    IF NVL(LV_BASE_PERSONAL.SERV_PWD, '-1') = '-1' THEN
      AV_RES                               := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG                               := '������Ϣ�����ڣ��������ͻ��������Ľ�����������';
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
      AV_MSG := '���벻��ȷ';
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_LOGIN_GR;
--����������¼
  PROCEDURE P_LOGIN_CO_ORG(
      AV_CO_ORG_ID VARCHAR2, --�����������
      AV_PWD       VARCHAR2, --����
      AV_RES OUT VARCHAR2,   --�������
      AV_MSG OUT VARCHAR2)   --���˵��
  IS
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
  BEGIN
    IF AV_CO_ORG_ID IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '����������Ų���Ϊ��';
      RETURN;
    END IF;
    IF AV_PWD IS NULL THEN
      AV_RES  := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG  := '���벻��Ϊ��';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO LV_BASE_CO_ORG FROM BASE_CO_ORG WHERE co_org_id = AV_CO_ORG_ID;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_BASECO_NOFOUNDERR;
      AV_MSG := '���ݺ����������' || AV_CO_ORG_ID || '�Ҳ�������������Ϣ';
      RETURN;
    WHEN TOO_MANY_ROWS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�����������' || AV_CO_ORG_ID || '���ڶ�����¼��Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := SQLERRM;
      RETURN;
    END;
    IF NVL(LV_BASE_CO_ORG.CO_STATE, '-1') <> '0' THEN
      AV_RES                              := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                              := '��������״̬������';
      RETURN;
    END IF;
    IF NVL(LV_BASE_CO_ORG.Serv_Pwd_Err_Num, 0) >= PK_PUBLIC.CS_CO_ORG_SERV_PWD_ERR_NUM THEN
      AV_RES                                  := PK_PUBLIC.CS_RES_PWDERRNUM;
      AV_MSG                                  := '�������������';
      RETURN;
    END IF;
    IF NVL(LV_BASE_CO_ORG.Serv_Pwd, '-1') = '-1' THEN
      AV_RES                             := PK_PUBLIC.CS_RES_PWDERR;
      AV_MSG                             := '������Ϣ�����ڣ��������ͻ��������Ľ�����������';
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
      AV_MSG := '���벻��ȷ';
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
    RETURN;
  END P_LOGIN_CO_ORG;
--�����޸�
--1acpt_id �������
--2acpt_type ���������
--3oper_id ����Ա
--4trim_no �ն�ҵ����ˮ
--5cert_no ֤������
--6card_no ����
--7pwd_type �������� 1��������,2��������,
--8old_pwd ������
--9pwd ������
--10agt_cert_type ������֤������
--11agt_cert_no ������֤������
--12agt_name ����������
--13agt_telno �����˵绰����  10010001|1|admin|123|412822198605264479||1|111|111|||||
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
      AV_MSG    := '�������Ͳ���ȷ';
      RETURN;
    ELSIF LV_IN(7) NOT IN ('1', '2') THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '�������Ͳ���ȷ';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := 'ԭʼ���벻��Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(9) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '�����벻��Ϊ��';
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
            AV_MSG := '���ݿ���' || LV_IN(6) || '�Ҳ�������Ϣ';
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
          AV_MSG := '���ݿ���' || LV_IN(6) || '�Ҳ�����Ա��Ϣ';
          RETURN;
        WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿ���' || LV_IN(6) || '��ȡ��Ա��Ϣ���ִ���:' || SQLERRM;
          RETURN;
        END;
      ELSE
        AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
        AV_MSG := '���������޸ģ�֤������򿨺Ų���ȫ��Ϊ��';
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
        AV_MSG    := '���������޸ģ����Ų���Ϊ��';
        RETURN;
      END IF;
      IF LENGTH(LV_IN(6)) < 20 THEN
        LV_CARD_NO       := PK_SERVICE_OUTER.F_GETCARDNO_BY_SUBCARDNO(LV_IN(6),LV_CARD_APPLY);
        IF LV_CARD_NO IN ('-1', '0') THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿ���' || LV_IN(6) || '�Ҳ�������Ϣ';
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
      LV_SYSACTIONLOG.MESSAGE   := '���������޸�,֤������:' || lv_in(5) || ',����:' || LV_BASE_PERSONAL.NAME;
    ELSE
      LV_SYSACTIONLOG.DEAL_CODE := '20502040';
      LV_SYSACTIONLOG.MESSAGE   := '���������޸�,����:' || lv_in(6);
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
--��ʧ
--1�������/������ brch_id/acpt_id ����
--2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
--3�ն˱��/��Ա��� user_id/end_id ����
--4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
--5֤������ cert_no
--6���� card_no
--7��ʧ���� loss_type  2�ڹҹ�ʧ  3 �����ʧ
--8������֤������
--9������֤������
--10����������
--11��������ϵ�绰
--12��עnote
--���ؽ��
--av_res ���ؽ������
--av_msg ���ؽ��˵��
--av_out ������
--���� 10011001|1|admin||4128222198605264479||3|||||test|
  PROCEDURE P_CARD_LOSS
    (
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2,
      AV_OUT OUT VARCHAR2
    )
  IS
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE; --������Ϣ��
    LV_SERV_REC TR_SERV_REC%ROWTYPE;        -- �ۺ�ҵ����־��
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE; --����
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_SQL VARCHAR2(500) := '';
    LV_IN PK_PUBLIC.MYARRAY;
    LV_CUR PK_PUBLIC.T_CUR;
    LV_CLR_DATE VARCHAR2(10);
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_OUT_STR VARCHAR2(500) := '';
    LV_COUNT   NUMBER        := 0;
  BEGIN
    --1.��������
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,6,12,'PK_SERVICE_OUTER.P_CARD_LOSS',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --2.������ж�
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),LV_IN(2),LV_IN(3),LV_USERS,LV_BASE_CO_ORG,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL AND LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '֤������Ϳ��Ų��ܶ�Ϊ��';
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
      LV_SYSACTIONLOG.MESSAGE   := '��ͷ��ʧ';
    ELSIF NVL(LV_IN(7), '0')     = '3' THEN
      LV_SYSACTIONLOG.DEAL_CODE := '20501040';
      LV_SYSACTIONLOG.MESSAGE   := '�����ʧ';
    ELSE
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '��ʧ���Ͳ���ȷ';
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
      LV_SYSACTIONLOG.MESSAGE := LV_SYSACTIONLOG.MESSAGE || ',����:' || LV_CARD_BASEINFO.CARD_NO;
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
      --���ۺ�ҵ��
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
      AV_MSG   := '����֤������򿨺��Ҳ�������Ϣ����ע���޷����й�ʧ';
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
-- ���
--1�������/������ brch_id/acpt_id ����
--2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
--3�ն˱��/��Ա��� user_id/end_id ����
--4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
--5֤������ cert_no
--6���� card_no
--7������֤������
--8������֤������
--9����������
--10��������ϵ�绰
--11��עnote
--���ؽ��
--av_res ���ؽ������
--av_msg ���ؽ��˵��
--av_out ������
--���� 100102001000018|2||12345|33042519640701482X||1|412822198605264479|yangn|18668112868|test|
  PROCEDURE P_CARD_UNLOCK
    (
      AV_IN VARCHAR2,
      AV_RES OUT VARCHAR2,
      AV_MSG OUT VARCHAR2,
      AV_OUT OUT VARCHAR2
    )
  IS
    LV_USERS SYS_USERS%ROWTYPE;
    LV_BASE_PERSONAL BASE_PERSONAL%ROWTYPE; --������Ϣ��
    LV_SERV_REC TR_SERV_REC%ROWTYPE;        -- �ۺ�ҵ����־��
    LV_CARD_BASEINFO CARD_BASEINFO%ROWTYPE; --����
    LV_BASE_CO_ORG BASE_CO_ORG%ROWTYPE;
    LV_SQL VARCHAR2(500) := '';
    LV_IN PK_PUBLIC.MYARRAY;
    LV_CUR PK_PUBLIC.T_CUR;
    LV_CLR_DATE VARCHAR2(10);
    LV_SYSACTIONLOG SYS_ACTION_LOG%ROWTYPE;
    LV_OUT_STR VARCHAR2(500) := '';
    LV_COUNT   NUMBER        := 0;
  BEGIN
    --1.��������
    SELECT CLR_DATE INTO LV_CLR_DATE FROM PAY_CLR_PARA;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,4,11,'PK_SERVICE_OUTER.P_CARD_UNLOCK',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --2.������ж�
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1),LV_IN(2),LV_IN(3),LV_USERS,LV_BASE_CO_ORG,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL AND LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '֤������Ϳ��Ų��ܶ�Ϊ��';
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
    LV_SYSACTIONLOG.MESSAGE     := '���';
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
      LV_SYSACTIONLOG.MESSAGE := LV_SYSACTIONLOG.MESSAGE || ',����:' || LV_CARD_BASEINFO.CARD_NO;
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
      --���ۺ�ҵ��
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
      AV_MSG   := '����֤������,�����Ҳ�������Ϣ����ע���޷����н��';
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
--������
--av_in:
--1�������/������
--2��������� acpt_type (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
--3�ն˱��/��Ա���
--4�ն˲�����ˮ
--5ԭ������
--6�¿�����
--7���п�����
--8����
--9֤������
--10֤������
--11�Ƿ�ÿ� 0�ÿ� ������1
--12������ ���ݲ���10 �����0 �ÿ� �򴫵ݿ����� ����� 1���� ����0 ��λ����,����Ǻÿ����ڻ���תǮ��ʱ ת�˴˽��
--13����״̬�����գ�0 δ���գ�1
--14��������־ 0 ���� 1 ����
--15����ʱ ���ݻ���ԭ�� 01����ԭ��_��������,02����ԭ��_��,05����ԭ��_��Ч����,99����ԭ��_����
--16������������ ��λ����
--17������֤������
--18������֤������
--19����������
--20��������ϵ�绰
--21��ע
--22ͳ������
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
    lv_in pk_public.myarray;                          --�����������
    lv_deal_no sys_action_log.deal_no%type;           --��ˮ��
    lv_old_card_apply card_apply%rowtype;             --�ɿ��������¼
    lv_old_cardinfo card_baseinfo%rowtype;            --�Ͽ���Ϣ
    lv_new_card_apply card_apply%rowtype;             --�������¼
    lv_clrdate pay_clr_para%rowtype;                  --�������
    lv_users sys_users%rowtype;                       --����Ա
    lv_base_co_org base_co_org%rowtype;               --�����ṹ��Ϣ
    lv_action_log sys_action_log%rowtype;             --������־
    lv_serv_rec tr_serv_rec%rowtype;                  --�ۺ�ҵ����־
    lv_base_personal base_personal%rowtype;           --��Ա������Ϣ
    lv_card_task_list card_task_list%rowtype;         --�ƿ�������ϸ��Ϣ
    lv_card_apply_task card_apply_task%rowtype;       --�ƿ�������Ϣ
    lv_cancel_reason card_baseinfo.cancel_reason%type;--ע��ԭ��
    lv_selfmanagement sys_para.para_value%type;       --�Ƿ��Թܿ���ʶ
    lv_cost_para VARCHAR2(1000) := '';                --�����ѿ۷���װ�ַ���
    lv_card_config card_config%rowtype;               --��������Ϣ
    lv_stock_sql VARCHAR2(200) := '';                 --��������װ�ַ���
    lv_card_no card_apply.card_no%type;               --����
    lv_card_bind_bankcard card_bind_bankcard%rowtype; --���п��󶨼�¼
    lv_card_task_imp_bcp card_task_imp_bcp%rowtype;   --���Ʒ����Ϣ
    lv_new_card_apply_task card_apply_task%rowtype;   --����������
    lv_start_date VARCHAR2(8);                        --������ķ�������
    lv_valid_date VARCHAR2(8);                        --�·�������Ч��
    lv_bhk_type card_apply.bhk_type%type;
    lv_base_siinfo base_siinfo%ROWTYPE;
  BEGIN
    lv_selfmanagement   := pk_public.f_getsyspara('SELFMANAGEMENTCARD');
    IF lv_selfmanagement = '0' OR lv_selfmanagement = '-1' THEN
      av_res            := pk_public.cs_res_paravalueerr;
      av_msg            := '�Ƿ��Թܿ��������ô���';
      RETURN;
    END IF;
    pk_public.p_getinputpara(av_in,12,22,'PK_SERVICE_OUTER.P_CARDTRANS',lv_in,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(2) NOT IN ('1','2') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ͳ���ȷ';
      RETURN;
    END IF;
    IF lv_in(5) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '�Ͽ����Ų���Ϊ��';
      RETURN;
    END IF;
    IF lv_in(7) IS NULL AND lv_in(2) <> '1' THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '���п����Ų���Ϊ��';
      RETURN;
    END IF;
    IF lv_in(11) IS NULL THEN
      av_res     := pk_public.cs_res_paravalueerr;
      av_msg     := '�Ƿ�ÿ���������Ϊ��';
      RETURN;
    elsif lv_in(11) NOT IN ('0','1') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�Ƿ�ÿ���ʶֻ����0��1';
      RETURN;
    END IF;
    IF lv_in(13) IS NULL THEN
      av_res     := pk_public.cs_res_paravalueerr;
      av_msg     := '��Ƭ����״̬����Ϊ��';
      RETURN;
    elsif lv_in(13) NOT IN ('0','1') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��Ƭ����״̬����ֻ����0��1';
      RETURN;
    END IF;
    IF lv_in(14) IS NULL THEN
      av_res     := pk_public.cs_res_paravalueerr;
      av_msg     := '��������ʶ����ȷ';
      RETURN;
    elsif lv_in(14) NOT IN ('0','1') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������ʶֻ����0��1';
      RETURN;
    END IF;
    IF lv_in(22) IS NULL THEN 
       av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'ͳ�������Ų���Ϊ��';
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
      av_msg                               := '��Ƭ��Ч�ڲ�����Ϣ���ò���ȷ';
      RETURN;
    END IF;
    lv_start_date                   := TO_CHAR(sysdate,'YYYYMMDD');
    lv_valid_date                   := TO_CHAR(add_months(sysdate,lv_card_config.card_validity_period * 12),'YYYYMMDD');
    IF lv_selfmanagement             = 'N' THEN
      lv_new_card_apply.apply_state := '50';
      IF lv_in(6)                   IS NULL THEN
        av_res                      := pk_public.cs_res_paravalueerr;
        av_msg                      := '�¿����Ų���Ϊ��';
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
        av_msg      := '�¿�������֤ʧ�ܣ��ÿ��ѱ�ʹ��';
        RETURN;
      END IF;
      BEGIN
        SELECT * INTO lv_card_task_list FROM card_task_list WHERE card_no = lv_in(6);
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_cardiderr;
        av_msg := '�¿�������֤ʧ�ܣ��¿��ƿ���ϸ������';
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
        av_msg := '�¿�������֤ʧ�ܣ��¿��������񲻴���';
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
        av_msg      := '���п����Ŷ�Ӧ�Ŀ����Ѿ�����';
        RETURN;
      END IF;
      BEGIN
        SELECT *
        INTO lv_card_task_list
        FROM card_task_list
        WHERE card_no                   = lv_card_task_imp_bcp.card_no;
        IF lv_card_task_list.card_type <> '390' THEN
          av_res                       := pk_public.cs_res_bcp_not_madecard;
          av_msg                       := '���п����Ŷ�Ӧ�Ŀ��Ų��ǰ��Ʒ��';
          RETURN;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_bcp_notmadecard_list;
        av_msg := '���Ʒ���ɹ���ϸ������';
        RETURN;
      END;
      BEGIN
        SELECT *
        INTO lv_card_apply_task
        FROM card_apply_task
        WHERE task_id                    = lv_card_task_list.task_id;
        IF lv_card_apply_task.card_type <> '390' THEN
          av_res                        := pk_public.cs_res_bcp_not_madecard;
          av_msg                        := '���п����Ŷ�Ӧ�Ŀ��Ų��ǰ��Ʒ��';
          RETURN;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        av_res := pk_public.cs_res_bcp_notmadecard_task;
        av_msg := '���Ʒ���ɹ����񲻴���';
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
      av_msg         := '����Ա�Ѵ����������ƿ���¼,��Ҫ�ظ����в����򻻿�';
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
          av_msg                          := '������֤����Ϣʧ�ܣ��Ͽ����������ʧ״̬';
          RETURN;
        END IF;
      elsif lv_in(14)                  = '1' THEN
        IF lv_old_cardinfo.card_state <> '1' THEN
          av_res                      := pk_public.cs_res_cardstateiserr;
          av_msg                      := '��������֤����Ϣʧ�ܣ��Ͽ�״̬������';
          RETURN;
        END IF;
      END IF;
    END IF;
    IF NVL(lv_old_cardinfo.customer_id, '1') <> NVL(lv_base_personal.customer_id,'0') THEN
      av_res                                 := pk_public.cs_res_personalvil_err;
      av_msg                                 := '�ͻ���Ϣ��֤ʧ�ܣ�����ͻ���Ϣ�Ϳ�Ƭ���пͻ���Ϣ��һ��';
      RETURN;
    END IF;
    pk_card_apply_issuse.p_getcardapplybycardno(lv_old_cardinfo.card_no,lv_old_card_apply,av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_old_card_apply.customer_id <> lv_old_cardinfo.customer_id THEN
      av_res                         := pk_public.cs_res_personalvil_err;
      av_msg                         := '����ԭ���Ų�ѯ���������¼��ԭ��Ƭ��������Ϣ����';
      RETURN;
    END IF;
    IF lv_in(2)    = '2' AND lv_old_card_apply.card_type = '120' AND lv_card_bind_bankcard.bank_card_no IS NOT NULL THEN
      IF lv_in(1) <> lv_old_card_apply.bank_id THEN
        av_res    := pk_public.cs_res_baseco_nofounderr;
        av_msg    := 'ԭ��Ƭ�����������������в�һ��';
        RETURN;
      END IF;
    END IF;
    SELECT seq_action_no.nextval INTO lv_deal_no FROM dual;
    SELECT * INTO lv_clrdate FROM pay_clr_para;
    lv_action_log.deal_no          := lv_deal_no;
    IF lv_in(14)                    = '0' THEN
      lv_action_log.deal_code      := '20501010';
      lv_action_log.message        := '������' || av_in;
      lv_action_log.note           := lv_action_log.message;
      lv_cancel_reason             := '3';
      lv_new_card_apply.apply_type := '2';
      lv_in(13)                    := '1';
    ELSE
      lv_action_log.deal_code      := '20501020';
      lv_action_log.message        := '������' || av_in;
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
    --7.ע���Ͽ� �޸��Ͽ��Ļ���״̬������޸�ʱ��,ע��ʱ��ע��ԭ��
    IF lv_old_cardinfo.card_state <> 9 THEN
      UPDATE card_baseinfo
      SET card_state     = '9',
        last_modify_date = lv_action_log.deal_time,
        cancel_date      = lv_action_log.deal_time,
        cancel_reason    = lv_cancel_reason,
        recover_flag     = NVL(lv_in(13),1) --Ĭ��δ����
      WHERE card_no      = lv_old_cardinfo.card_no;
      IF sql%rowcount   <> 1 THEN
        av_res          := pk_public.cs_res_oldcardnotexist_err;
        av_msg          := '�����Ͽ��Ŀ�״̬����ȷ';
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
        av_msg       := '�Ҳ����Ͽ��˻���Ϣ';
        RETURN;
      END IF;
    END IF;
    BEGIN
      SELECT * INTO lv_base_siinfo FROM base_siinfo t WHERE t.cert_no = lv_base_personal.cert_no AND t.med_whole_no = lv_in(22);
      IF lv_base_siinfo.med_state <> '0' THEN
          av_res       := pk_public.cs_res_oldcardnotexist_err;
            av_msg       := '����Ա�α�״̬������';
            RETURN;
      END IF;
    EXCEPTION 
             WHEN no_data_found THEN 
                av_res       := pk_public.cs_res_oldcardnotexist_err;
              av_msg       := '����Ա�α���Ϣ�����ڣ���α���Ϣ�����ڱ�����';
              RETURN;
              WHEN too_many_rows THEN 
                av_res       := pk_public.cs_res_oldcardnotexist_err;
              av_msg       := '����Ա���ڶ����α���Ϣ��¼';
              RETURN;
              WHEN OTHERS THEN 
                av_res       := pk_public.cs_res_oldcardnotexist_err;
              av_msg       := '��ȡ�α���Ϣ���ִ���' || Sqlerrm;
              RETURN;      
    END;
    --8.�����������¼
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
        av_msg          := '���°��Ʒ����ʹ��״̬���ִ���';
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
          || (DECODE(lv_in(14),'0','����','1','����','����'))
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
        av_msg        := '����������Ϣ���ִ���';
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
        av_msg        := '�����ƿ���ϸ��Ϣ���ִ���';
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
        '100',--�����Ͽ��������������Ͽ�
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
      av_msg        := '���ɲ�������¼��Ϣ���ִ���';
      RETURN;
    END IF;
    --9.����ԭʼ�����¼Ϊע��
    UPDATE card_apply
    SET apply_state  = pk_public.kg_card_apply_yzx
    WHERE apply_id   = lv_old_card_apply.apply_id;
    IF sql%rowcount <> 1 THEN
      av_res        := pk_public.cs_res_oldcardnotexist_err;
      av_msg        := '����ԭʼ�����¼����ȷ';
      RETURN;
    END IF;
    --13.���¹����������˻�
    SELECT lv_action_log.deal_no INTO av_out FROM dual;
    IF NVL(lv_in(16), 0) > 0 AND lv_in(2) = '1' THEN
      lv_cost_para      := lv_cost_para || lv_deal_no || '|' || lv_action_log.deal_code || '|' || lv_users.user_id || '|';
      lv_cost_para      := lv_cost_para || TO_CHAR(lv_action_log.deal_time,'YYYY-MM-DD HH24:MI:SS') || '|';
      lv_cost_para      := lv_cost_para || '702101' || '|' || NVL(lv_in(16), 0) || '|' || '������������' || '|';
      lv_cost_para      := lv_cost_para || lv_in(2) || '|' || '0' || '|';
      pk_business.p_cost(lv_cost_para, '1', av_res, av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --14.���Ͽ����������
    pk_service_outer.p_card_black(lv_action_log.deal_no,lv_old_cardinfo.card_no,'0','99',TO_CHAR(lv_action_log.deal_time,'yyyy-mm-dd hh24:mi:ss'),av_res,av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF NVL(lv_card_config.is_stock, '-1') = '0' AND lv_in(13) = '0' THEN
      lv_stock_sql                       := lv_stock_sql || lv_in(1) || '|' || lv_in(2) || '|' || lv_in(3) || '|' || lv_action_log.deal_no || '|';
      lv_stock_sql                       := lv_stock_sql || lv_action_log.deal_code || '|' || TO_CHAR(lv_action_log.deal_time,'YYYY-MM-DD HH24:MI:SS') || '|';
      lv_stock_sql                       := lv_stock_sql || lv_old_cardinfo.card_no || '|' || '' || '|' || pk_card_stock.goods_state_zlwt || '|' || '������|';
      pk_card_stock.p_bhk(lv_stock_sql, av_res, av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --16.����ҵ����־,��ʶ�Ƿ�ÿ�   �Ƿ����   �ÿ����
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
    lv_serv_rec.cost_fee      := NVL(lv_in(16), 0);       --������
    lv_serv_rec.old_card_no   := lv_old_cardinfo.card_no; --������ʱ ���¿�����
    lv_serv_rec.clr_date      := lv_clrdate.clr_date;
    IF lv_bhk_type             = '0' THEN
      lv_serv_rec.note        := lv_action_log.message || '�¿������¿�'; --��ע
    elsif lv_bhk_type          = '1' THEN
      lv_serv_rec.note        := lv_action_log.message || '�Ͽ������¿�'; --��ע
    END IF;
    lv_serv_rec.amt             := NVL(lv_in(16), 0); --������������
    lv_serv_rec.biz_time        := lv_action_log.deal_time;
    lv_serv_rec.rsv_one         := lv_in(11); --�ÿ�������ʶ  -- ����Ǻÿ����տ��������ǻ����˻����������˻�
    lv_serv_rec.rsv_two         := lv_in(13); --�Ƿ���ձ�־
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
      lv_serv_rec.prv_bal := NVL(lv_in(12),0); --����Ǻÿ�����Ҫ���ݿ�����
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
    av_msg := '��������������' || sqlerrm;
  END p_cardtrans;
--�����ƿ��Ǽ�
--1.����
--2.��Ա
--3.�ǽ��ϵ縴λ��Ϣ
--4.�ǽӴ�����
--5.�ӽӴ��ϵ縴λ��Ϣ
--6.��ʶ����
--7.״̬ 0 ���  1 �Ͽ��Ǽ�
--8.�ƿ���ˮ
--9.��ע
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
      AV_MSG    := '�ƿ��������㲻��Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '�ƿ�������Ա����Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '�������ͱ�ʶ����Ϊ��';
      RETURN;
    ELSIF LV_IN(7) NOT IN ('0','1') THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�������ͱ�ʶֻ����0��1';
      RETURN;
    END IF;
    IF LV_IN(8) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG    := '�ƿ���ˮ��Ų���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7)  = '0' THEN
      IF LV_IN(4) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '�ǽӴ����Ų���Ϊ��';
        RETURN;
       END IF;
       IF LV_IN(3) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '�ǽӴ��ϵ縴λ��Ϣ����Ϊ��';
        RETURN;
      END IF;
      IF LV_IN(5) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '�Ӵ�ʽ�ϵ縴λ��Ϣ����Ϊ��';
        RETURN;
      END IF;
      IF LV_IN(6) IS NULL THEN
        AV_RES    := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG    := '��ʶ���벻��Ϊ��';
        RETURN;
      END IF;
    END IF;
    PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_IN(1),LV_IN(2),LV_USERS,AV_RES,AV_MSG,'�ƿ���Ա��Ϣ');
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --������Ų�Ϊ�� �жϰ��Ʒ����Ϣ
    IF lv_in(4)  IS NOT NULL THEN 
    BEGIN
      SELECT *
      INTO LV_CARD_TASK_IMP
      FROM CARD_TASK_IMP_BCP
      WHERE CARD_NO                      = LV_IN(4);
      if LV_CARD_TASK_IMP.State in ('2','9') then 
        AV_RES                        := PK_PUBLIC.CS_RES_ok;
          AV_MSG                        := '�ѳɹ�����';
          RETURN;
      end if;
      
      IF LV_CARD_TASK_IMP.APPLY_BANK_ID IS NULL THEN
        IF LV_CARD_TASK_IMP.State       <> '1' THEN
          AV_RES                        := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                        := '�ð��Ʒ�����Ƿ��͵������ƿ��Ŀ�';
          RETURN;
        END IF;
      ELSE
        IF LV_CARD_TASK_IMP.State <> '0' THEN
          AV_RES                  := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                  := '�ð��Ʒ������δ����״̬';
          RETURN;
        END IF;
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_BCP_NOT_EXIST;
      AV_MSG := '���ݿ���' || LV_IN(4) || '�Ҳ������Ʒ���ɹ���Ϣ';
      RETURN;
    WHEN TOO_MANY_ROWS THEN
      AV_RES := PK_PUBLIC.CS_RES_BCP_HAS_MORE;
      AV_MSG := '���ݿ���' || LV_IN(4) || '�ҵ��������Ʒ���ɹ���Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '���ݿ���' || LV_IN(4) || '��ȡ���Ʒ����Ϣ���ִ���' || SQLERRM;
      RETURN;
    END;
    IF NVL(LV_CARD_TASK_IMP.STATE,'-1') <> '1' THEN
      AV_RES                            := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                            := '�ÿ����Ƿ��͵������ƿ��Ŀ�';
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
      LV_SYS_ACTION_LOG.MESSAGE   := '�����ƿ����ݵ���:' || LV_IN(4);
      LV_SYS_ACTION_LOG.DEAL_CODE := 10502070;
    ELSE
        if lv_in(4) is null then
            LV_SYS_ACTION_LOG.MESSAGE   := '�����ƿ�ȡ���ƿ�' || LV_IN(4);
            LV_SYS_ACTION_LOG.DEAL_CODE := 10502090;
        else
            LV_SYS_ACTION_LOG.MESSAGE   := '�����ƿ�ʧ�ܷϿ��Ǽ�:' || LV_IN(4);
            LV_SYS_ACTION_LOG.DEAL_CODE := 10502080;
        end if;
    END IF;
    INSERT INTO SYS_ACTION_LOG VALUES LV_SYS_ACTION_LOG;
    IF lv_in(4) IS NOT NULL THEN 
        PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_CARD_TASK_IMP.BRCH_ID,LV_CARD_TASK_IMP.USER_ID,LV_USERS_IN,AV_RES,AV_MSG,'�ÿ�������Ա');
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
    PK_CARD_STOCK.P_GETSTOCK_ACC(LV_USERS_IN.BRCH_ID,LV_USERS_IN.USER_ID,'1390',PK_CARD_STOCK.GOODS_STATE_ZC,LV_STOCK_ACC_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF NVL(LV_STOCK_ACC_IN.TOT_NUM,'0') < 1 THEN
      AV_RES                           := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG                           := '���Ʒ��������Ա�Ŀ���˻�����';
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
      AV_MSG        := '���°��Ʒ���Ŀ���˻����ִ���';
      RETURN;
    END IF;
    END IF;
    BEGIN
      SELECT * INTO LV_CARD_TASK_LIST FROM CARD_TASK_LIST WHERE DATA_SEQ = LV_IN(8);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�����ƿ���ˮ' || LV_IN(8) || '�Ҳ����ƿ���Ϣ';
      RETURN;
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�����ƿ���ˮ' || LV_IN(8) || '��ȡ�ƿ���Ϣ���ִ���' || SQLERRM;
      RETURN;
    END;
    IF LV_IN(7) = '0' THEN
      GOTO MK_CARD_SUC;
    END IF;
    IF lv_in(4) IS NOT NULL THEN 
    UPDATE CARD_TASK_IMP_BCP
    SET STATE        = '9'
    WHERE CARD_NO    = LV_CARD_TASK_IMP.CARD_NO;-- AND STATE = '1';----0 ��ʼ����  1 �������ƿ�  2 �ƿ����   9 �ƿ�ʧ��
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '���°��Ʒ����ʹ��״̬���ִ���';
      RETURN;
    END IF;
    END IF;
    DELETE FROM CARD_TASK_LIST WHERE DATA_SEQ = LV_CARD_TASK_LIST.DATA_SEQ;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '�����ƿ���ˮ���' || LV_IN(8) || '�Ҳ����ƿ���ϸ��Ϣ';
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
      AV_MSG        := '�����ƿ���ˮ���' || LV_IN(8) || '�Ҳ����ƿ�������Ϣ';
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
    --����ǲ��������Ͽ����Ų�Ϊ��
    IF NVL(LV_CARD_APPLY.APPLY_TYPE,'-1') IN ('1','2') AND LV_CARD_APPLY.OLD_CARD_NO IS NOT NULL THEN
      PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_TASK_LIST.CUSTOMER_ID,LV_BASE_PERSONAL,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      PK_CARD_APPLY_ISSUSE.P_GET_CARD_BASEINFO(LV_CARD_APPLY.OLD_CARD_NO,LV_CARD_BASEINFO,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG  := '�Ǽǳ��ִ��󣬻ع��Ͽ���Ϣʧ�ܣ�' || AV_MSG;
        RETURN;
      END IF;
      PK_CARD_APPLY_ISSUSE.P_GETCARDCONFIGBYCARDTYPE(LV_CARD_BASEINFO.CARD_TYPE,LV_CARD_CONFIG,AV_RES,AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        AV_MSG  := '�Ǽǳ��ִ��󣬻ع��Ͽ���Ϣʧ�ܣ�' || AV_MSG;
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
        AV_MSG          := '�Ǽǳ��ִ��󣬻ع��Ͽ���Ϣʧ�ܣ������Ͽ���״̬ʱ����' || SQL%ROWCOUNT || '��';
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
        AV_MSG        := '�Ǽǳ��ִ��󣬻ع��Ͽ���Ϣʧ�ܣ������Ͽ����˻�ʱ����' || SQL%ROWCOUNT || '��';
        RETURN;
      END IF;
      UPDATE CARD_APPLY
      SET APPLY_STATE   = PK_PUBLIC.KG_CARD_APPLY_YFF
      WHERE CUSTOMER_ID = LV_CARD_TASK_LIST.CUSTOMER_ID
      AND CARD_NO       = LV_CARD_APPLY.OLD_CARD_NO;
      IF SQL%ROWCOUNT   < 1 THEN
        AV_RES         := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG         := '�Ǽǳ��ִ��󣬻ع��Ͽ���Ϣʧ�ܣ��Ͽ������¼������';
        RETURN;
      ELSIF SQL%ROWCOUNT > 1 THEN
        AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG          := '�Ǽǳ��ִ��󣬻ع��Ͽ���Ϣʧ�ܣ��Ͽ������¼���ڶ���';
        RETURN;
      END IF;
      IF NVL(LV_CARD_BASEINFO.RECOVER_FLAG,'-1') = '0' AND LV_CARD_CONFIG.IS_STOCK = '0' THEN
        PK_CARD_STOCK.P_GETSTOCKLISTBYGOODSNO(LV_CARD_APPLY.OLD_CARD_NO,LV_STOCK_LIST,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        IF LV_STOCK_LIST.OWN_TYPE <> '0' THEN
          AV_RES                  := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                  := '�Ͽ������ϸ�������Ͳ����ڹ�Ա';
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETUSERSBYUSERID(LV_STOCK_LIST.BRCH_ID,LV_STOCK_LIST.USER_ID,LV_USERS_OUT,AV_RES,AV_MSG,'�Ͽ�������Ա��Ϣ');
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        PK_CARD_STOCK.P_GETSTOCK_ACC(LV_STOCK_LIST.BRCH_ID,LV_STOCK_LIST.USER_ID,LV_STOCK_LIST.STK_CODE,LV_STOCK_LIST.GOODS_STATE,LV_STOCK_ACC_OUT,AV_RES,AV_MSG);
        IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
          RETURN;
        END IF;
        IF LV_STOCK_ACC_OUT.TOT_NUM < 1 THEN
          AV_RES                   := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG                   := '��������˻�����';
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
        '�����ƿ�ʧ��,�ع��Ͽ�',
        LV_CARD_APPLY.OLD_CARD_NO,
        LV_CARD_APPLY.OLD_CARD_NO;
        IF SQL%ROWCOUNT <> 1 THEN
          AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG        := '��¼��������־���ִ���-' || SQL%ROWCOUNT || '��';
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
        '�����ƿ�ʧ��,�ع��Ͽ�',
        LV_STOCK_LIST.GOODS_STATE;
        IF SQL%ROWCOUNT < 1 THEN
          AV_RES       := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG       := '��¼���������ˮ��Ϣ���ִ��󣬿����ϸ������';
          RETURN;
        END IF;
        IF SQL%ROWCOUNT <> 1 THEN
          AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG        := '��¼���������ˮ��Ϣ���ִ������¼' || '1' || '����ʵ�ʼ�¼' || SQL%ROWCOUNT || '��';
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
          AV_MSG       := '���¸��������ϸ������������ȷ�����������ϸ��Ʒ��������';
          RETURN;
        ELSIF SQL%ROWCOUNT > 1 THEN
          AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG          := '���¸��������ϸ������������ȷ��������1����ʵ�ʸ���' || SQL%ROWCOUNT || '��';
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
          AV_MSG         := '���¿���˻�����ȷ����������˻�������';
          RETURN;
        END IF;
      END IF;
    END IF;
    GOTO MK_END;
    <<MK_CARD_SUC>>
    UPDATE CARD_TASK_IMP_BCP
    SET STATE        = '2'
    WHERE CARD_NO    = LV_CARD_TASK_IMP.CARD_NO;----0 ��ʼ����  1 �������ƿ�  2 �ƿ����   9 �ƿ�ʧ��
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '���°��Ʒ����ʹ��״̬���ִ���';
      RETURN;
    END IF;
    UPDATE CARD_APPLY
    SET APPLY_STATE = PK_PUBLIC.KG_CARD_APPLY_YZK,CARD_NO = LV_CARD_TASK_IMP.CARD_NO,bank_card_no = lv_card_task_imp.bank_card_no
    WHERE APPLY_ID  = LV_CARD_TASK_LIST.APPLY_ID RETURNING BUY_PLAN_ID
    INTO LV_CARD_APPLY.BUY_PLAN_ID;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES        := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG        := '�����ƿ���ˮ���' || LV_IN(8) || '�Ҳ����ƿ�������Ϣ';
      RETURN;
    END IF;
    UPDATE CARD_TASK_LIST
       SET CARD_NO = LV_CARD_TASK_IMP.CARD_NO
     WHERE DATA_SEQ = LV_CARD_TASK_LIST.DATA_SEQ;
    IF SQL%ROWCOUNT <> 1 THEN
      AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG := '�����ƿ���ˮ���' || LV_IN(8) || '�����ƿ���ϸ��Ϣ����ȷ';
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
          'ʵ���ƿ������ƿ�����',
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
      AV_MSG        := '�뿨��Ϣ����ȷ';
    END IF;
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_USERS.BRCH_ID || '|' || '1' || '|' || LV_USERS.USER_ID || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_SYS_ACTION_LOG.DEAL_NO || '|' || LV_SYS_ACTION_LOG.DEAL_CODE || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || TO_CHAR(LV_SYS_ACTION_LOG.DEAL_TIME,'yyyy-mm-dd hh24:mi:ss') || '|' || '1100' || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_IN(3) || '|' || LV_CARD_TASK_IMP.CARD_NO || '|' || PK_CARD_STOCK.GOODS_STATE_ZC || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_CARD_APPLY.BUY_PLAN_ID || '|' || LV_CARD_TASK_LIST.TASK_ID || '|' || '0' || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_USERS.BRCH_ID || '|' || LV_USERS.USER_ID || '|' || '0' || '|' || LV_USERS.ORG_ID || '|';
    LV_IMPORT_STOCK_SQL := LV_IMPORT_STOCK_SQL || LV_USERS.BRCH_ID || '|' || LV_USERS.USER_ID || '|||�����ƿ����ݵ���' || '|';
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
        AV_MSG        := '��¼ҵ����־����ȷ';
        return;
    end if;
    AV_RES := PK_PUBLIC.cs_res_Ok;
    AV_MSG := '';
  EXCEPTION
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_LOCAL_MAKECARD_REG;
--������תǮ�� д�Ҽ�¼
--1.�������/������
--2.���������
--3.�����ն˺�/����Ա
--4.�ն˽�����ˮ
--5.���κ�
--6.�¿�����
--7.�¿�������
--8.�¿��������к�
--9.������ת�˽�� ��λ����  Ϊ����ȫ��ת
--10.������֤������
--11.������֤������
--12.����������
--13��������ϵ��ʽ
  PROCEDURE p_bhk_zz_tj
    (
      av_in VARCHAR2,
      av_out OUT VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2
    )
  IS
    lv_in pk_public.myarray;                  --�����������
    lv_users sys_users%rowtype;               --����Ա
    lv_base_co_org base_co_org%rowtype;       --��������
    lv_in_card card_baseinfo%rowtype;         --�¿���Ƭ��Ϣ
    lv_in_acc_info acc_account_sub%rowtype;   --�¿��˻���Ϣ
    lv_in_card_apply card_apply%rowtype;      --�¿���Ƭ�����¼
    lv_old_card card_baseinfo%rowtype;        --�Ͽ�����Ϣ
    lv_old_acc_info acc_account_sub%rowtype;  --�Ͽ��˻���Ϣ
    lv_sys_action_log Sys_Action_Log%rowtype; --������־
    lv_tr_serv_rec tr_serv_rec%rowtype;       --ҵ����־
    lv_old_tr_serv_rec tr_serv_rec%rowtype;   --ԭҵ����־
    lv_deal_no sys_action_log.deal_no%type;   --��ˮ��
    lv_clr_date pay_clr_para.clr_date%type;   --�������
    lv_zz_amt acc_account_sub.bal%type;       --ת�˽��
    lv_zz_para VARCHAR2(1000);                --ת���ַ���
    lv_base_personal base_personal%rowtype;
  BEGIN
    SELECT clr_date INTO lv_clr_date FROM pay_clr_para;
    pk_public.p_getinputpara(av_in, --�������
    7,                              --�������ٸ���
    13,                             --����������
    'pk_YiendCard.p_bhk_zz_tj',     --���õĺ�����
    lv_in,                          --ת���ɲ�������
    av_res,                         --������������
    av_msg                          --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(1) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '������Ų���Ϊ��';
      RETURN;
    END IF;
    IF lv_in(2) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '��������Ͳ���Ϊ��';
      RETURN;
    END IF;
    IF lv_in(3) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '����Ա���ն˱�Ų���Ϊ��';
      RETURN;
    END IF;
    IF lv_in(6) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '�¿����Ų���Ϊ��';
      RETURN;
    END IF;
    --1.���������ж�
    BEGIN
      IF lv_in(2) = '1' THEN
        SELECT * INTO lv_users FROM sys_users t1 WHERE t1.user_id = lv_in(3);
        IF lv_users.brch_id <> NVL(lv_in(1), '0') THEN
          av_res            := pk_public.cs_res_user_err;
          av_msg            := '�ܿ��������֤ʧ��';
          RETURN;
        END IF;
      elsif lv_in(2) = '2' THEN
        SELECT * INTO lv_base_co_org FROM base_co_org WHERE co_org_id = lv_in(1);
        IF lv_base_co_org.co_state <> '0' THEN
          av_res                   := pk_public.cs_res_co_org_novalidateerr;
          av_msg                   := '�ܿ��������֤ʧ��';
          RETURN;
        END IF;
        SELECT * INTO lv_users FROM sys_users WHERE user_id = 'admin';
      ELSE
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '��������ʹ���';
        RETURN;
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      av_res := pk_public.cs_res_baseco_nofounderr;
      av_msg := '�������Ϣ������';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_baseco_nofounderr;
      av_msg := '�ܿ��������֤ʧ��';
      RETURN;
    END;
    --2.��ȡ�¿���
    pk_public.p_getcardbycardno(lv_in(6), lv_in_card, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in_card.card_state <> '1' THEN
      av_res                 := pk_public.cs_res_cardstateiserr;
      av_msg                 := '�¿���״̬������';
      RETURN;
    END IF;
    pk_public.p_getsubledgerbycardno(lv_in_card.card_no, pk_public.cs_acckind_qb, pk_public.cs_defaultwalletid, lv_in_acc_info, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --3.��ȡ�¿������¼��Ϣ�Ƿ񲹻��������¼
    BEGIN
      SELECT * INTO lv_in_card_apply FROM card_apply WHERE card_no = lv_in(6);
      IF lv_in_card_apply.apply_type <> '1' AND lv_in_card_apply.apply_type <> '2' THEN
        av_res                       := pk_public.cs_res_nobhktype_err;
        av_msg                       := '�¿������¼���ǲ�������¼�����ܽ��л���תǮ��';
        RETURN;
      END IF;
    EXCEPTION
    WHEN no_data_found THEN
      av_res := pk_public.cs_res_oldcardnotexist_err;
      av_msg := '�¿������¼������,�Ҳ�����Ӧ�Ͽ���Ϣ';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := sqlerrm;
      RETURN;
    END;
    IF lv_in_card_apply.old_card_no IS NULL THEN
      av_res                        := pk_public.cs_res_oldcardnotexist_err;
      av_msg                        := '�¿������¼�в����ڶ�Ӧ���Ͽ�����';
      RETURN;
    END IF;
    --��ȡ�Ͽ���������¼
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
      av_msg := '�Ҳ���ԭʼ��������¼��Ϣ';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := sqlerrm;
      RETURN;
    END;
    --4.�����Ͽ����Ż�ȡ�Ͽ�����Ϣ���˻���Ϣ
    pk_public.p_getcardbycardno(lv_in_card_apply.old_card_no, lv_old_card, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_getsubledgerbycardno(lv_old_card.card_no, pk_public.cs_acckind_qb, pk_public.cs_defaultwalletid, lv_old_acc_info, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF NVL(lv_old_tr_serv_rec.rsv_one, 1) = '0' THEN
      --�Կ���Ϊ׼
      lv_zz_amt := lv_old_tr_serv_rec.prv_bal;
    ELSE
      --���˻�Ϊ׼
      lv_zz_amt                                             := lv_old_acc_info.bal;
      IF TO_CHAR(lv_old_acc_info.lss_date + 7, 'yyyy-mm-dd') > lv_clr_date THEN
        av_res                                              := pk_public.cs_res_amt_is_zero;
        av_msg                                              := '�˻��������ڻ�δ����';
        RETURN;
      END IF;
    END IF;
    IF lv_in(9) IS NOT NULL THEN
      lv_zz_amt := lv_in(9);
    END IF;
    IF NVL(lv_old_acc_info.bal, 0) = 0 THEN
      av_res                      := pk_public.cs_res_amt_is_zero;
      av_msg                      := '�Ͽ��˻����Ϊ0���������ת��';
      RETURN;
    END IF;
    IF lv_tr_serv_rec.prv_bal > lv_old_acc_info.bal THEN
      av_res                 := pk_public.cs_res_accinsufbalance;
      av_msg                 := 'ԭʼ�Ͽ������������˻����˻�����';
      RETURN;
    END IF;
    --5.��¼������־
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
    lv_sys_action_log.message     := '������תǮ���¿�����' || lv_in(6);
    INSERT INTO sys_action_log VALUES lv_sys_action_log;
    --���������ַ�����ת�˽ӿ�
    lv_zz_para := lv_sys_action_log.deal_no || '|' || lv_sys_action_log.deal_code || '|' || lv_in(3) || '|';
    lv_zz_para := lv_zz_para || TO_CHAR(lv_sys_action_log.deal_time, 'yyyy-mm-dd hh24:mi:ss') || '|' || lv_in(1) || '|' || lv_in(5) || '|' || lv_in(4) || '|';
    lv_zz_para := lv_zz_para || lv_old_card.card_no || '|' || '|' || lv_old_tr_serv_rec.prv_bal || '|' || lv_old_acc_info.acc_kind || '|' || '00' || '|';
    lv_zz_para := lv_zz_para || lv_in_card.card_no || '|' || lv_in(8) || '|' || lv_in(7) || '|' || lv_in_acc_info.acc_kind || '|';
    lv_zz_para := lv_zz_para || '|' || lv_zz_amt || '|' || '|' || '������תǮ��' || '|' || '|' || '|' || '9' || '|' || lv_in(2) || '|';
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
    --��¼�ۺ�ҵ����־
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
    lv_tr_serv_rec.deal_state    := '9'; --�Ҽ�¼
    lv_tr_serv_rec.clr_date      := lv_clr_date;
    IF lv_in(2)                   = '2' THEN
      lv_tr_serv_rec.end_deal_no := lv_in(4); --�ն˽�����ˮ
      lv_tr_serv_rec.term_id     := lv_in(3); --�ն˺Ż��ǲ���Ա��
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
--������תǮ���Ҽ�¼ȷ��
--1.�������/������
--2.���������   1 ����  2 ����
--3.������ն˱��/����Ա
--4.�ն˲�����ˮ ���������Ϊ 1��ʱ���Ϊ��
--5.ȷ����ˮ��
--6.�������
  PROCEDURE p_bhk_zz_tj_confirm(
      av_in VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2)
  IS
    lv_in pk_public.myarray;                      --�����������
    lv_cr_acc acc_account_sub%ROWTYPE;            --�����˻�
    lv_db_acc acc_account_sub%ROWTYPE;            --�跽�˻�
    lv_acc_inout_detail acc_inout_detail%ROWTYPE; --��ȷ���˻���ˮ
  BEGIN
    --1.����������Ϣ
    pk_public.p_getinputpara(av_in,     --�������
    6,                                  --�������ٸ���
    6,                                  --����������
    'pk_YiendCard.p_bhk_zz_tj_confirm', --���õĺ�����
    lv_in,                              --ת���ɲ�������
    av_res,                             --������������
    av_msg                              --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --2.�жϽ������Ϣ
    pk_public.p_judgeacpt(lv_in(2), lv_in(1), lv_in(3), av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(5) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '������תǮ��ȷ����ˮ����Ϊ��';
      RETURN;
    END IF;
    IF lv_in(6) IS NULL THEN
      av_res    := pk_public.cs_res_paravalueerr;
      av_msg    := '������תǮ��ȷ��������ڲ���Ϊ��';
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
      av_msg := '������ˮ' || lv_in(5) || 'δ�ҵ���ȷ�ϼ�¼��Ϣ';
      RETURN;
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := Sqlerrm;
      RETURN;
    END;
    --3.ȡ�跽�˻�
    pk_public.p_getsubledgerbycardno(lv_acc_inout_detail.db_card_no, lv_acc_inout_detail.db_acc_kind, pk_public.cs_defaultwalletid, lv_db_acc, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --4.ȡ�����˻�
    pk_public.p_getsubledgerbycardno(lv_acc_inout_detail.cr_card_no, lv_acc_inout_detail.cr_acc_kind, pk_public.cs_defaultwalletid, lv_cr_acc, av_res, av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --5.ȷ�ϲ�����ת�˻Ҽ�¼
    pk_business.p_ashconfirmbyaccbookno(lv_in(6), --�������
    lv_acc_inout_detail.acc_inout_no,             --acc_book_no
    NULL,                                         --�跽�������
    NULL,                                         --�����������
    lv_db_acc.bal,                                --�跽����ǰ���
    lv_cr_acc.bal,                                --��������ǰ���
    '1',                                          --1д������־
    av_res,                                       --��������
    av_msg                                        --����������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --6.�޸���־״̬Ϊ����
    UPDATE tr_serv_rec
    SET deal_state   = '0',
      clr_date       = lv_in(6)
    WHERE deal_no    = lv_in(5);
    IF SQL%ROWCOUNT <> 1 THEN
      av_res        := pk_public.cs_res_unknownerr;
      av_msg        := '������ˮ' || lv_in(5) || 'ȷ��ת�˼�¼' || SQL%ROWCOUNT || '��';
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
--������תǮ������
--av_deal_no ԭ��ˮ
  PROCEDURE p_bhkzz_tj_cancel(
      av_deal_no VARCHAR2,
      av_res OUT VARCHAR2,
      av_msg OUT VARCHAR2)
  IS
    lv_clrdate pay_clr_para.clr_date%TYPE;
  BEGIN
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    pk_business.p_ashcancel(lv_clrdate, --�������
    av_deal_no,                         --ҵ����ˮ��
    '1',                                --1д������־
    av_res,                             --��������
    av_msg                              --����������Ϣ
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
      av_msg        := '������ˮ' || av_deal_no || '����ת�˼�¼' || SQL%ROWCOUNT || '��';
      RETURN;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    av_res := pk_public.cs_res_unknownerr;
    av_msg := SQLERRM;
  END p_bhkzz_tj_cancel;
--�����ţ����в�����
--av_in
--1.�������
--2.���������
--3.����Ա
--4.������ˮ
--5.����
--6.���п�����
--7.�̶��绰
--8.�ֻ�����
--9.���п������־
--10.������֤������
--11.������֤������
--12.����������
--13.��������ϵ�绰
--14.��ע
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
    --1.��������
    SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,7,14,'PK_SERVICE_OUTER.P_BANK_KFF',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '��������Ͳ���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '���п����Ų���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(7) IS NULL AND LV_IN(8) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '�̶��绰���ֻ����벻��ȫ��Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(9) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '���п������־����Ϊ��';
      RETURN;
    ELSIF LV_IN(9) NOT IN ('00','01') THEN
      AV_RES := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG := '���п������־����ȷ';
      RETURN;
    END IF;
    --2.������ж�
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
      AV_MSG                         := '�������п�����' || LV_IN(6) || '�ҵ��İ󶨼�¼�Ŀ���Ϊ��';
      RETURN;
    END IF;
    IF LV_CARD_BIND_BANKCARD.BANK_ID <> LV_IN(1) THEN
      AV_RES                         := PK_PUBLIC.CS_RES_BIND_BANK_ERR;
      AV_MSG                         := 'ԭ��Ƭ�����������������в�һ��';
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
        AV_MSG            := '�������п�����״̬ʧ��';
        RETURN;
      END IF;
      AV_RES := PK_PUBLIC.CS_RES_OK;
      AV_MSG := '';
      RETURN;
    ELSIF LV_CARD_BASEINFO.CARD_STATE <> '0' THEN
      AV_RES                          := PK_PUBLIC.CS_RES_CARDSTATEISERR;
      AV_MSG                          := '��״̬����δ����״̬';
      RETURN;
    END IF;
    LV_EXEC := LV_IN(1) || '|' || LV_IN(2) || '|' || LV_IN(3) || '|' || LV_IN(4) || '|';
    LV_EXEC := LV_EXEC || LV_CARD_BIND_BANKCARD.CARD_NO || '|' || LV_IN(6) || '|' || '0' || '|';
    LV_EXEC := LV_EXEC || '1' || '|' || LV_IN(10) || '|' || LV_IN(11) || '|' || LV_IN(12) || '|';
    LV_EXEC := LV_EXEC || LV_IN(13) || '|' || '���е����Žӿ�,���п�����' || LV_IN(6) || '�����־' || LV_IN(9) || '|';
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
      AV_MSG            := '�������п�����״̬ʧ��';
      RETURN;
    END IF;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
    AV_MSG := '�������п�����' || LV_IN(6) || '�Ҳ����󶨵Ŀ�Ƭ��Ϣ';
    RETURN;
  WHEN TOO_MANY_ROWS THEN
    AV_RES := PK_PUBLIC.CS_RES_BIND_BANK_MORE;
    AV_MSG := '�������п�����' || LV_IN(6) || '�ҵ������󶨿���¼';
    RETURN;
  WHEN OTHERS THEN
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_BANK_KFF;
--���п�ע��
--av_in
--1.�������
--2.���������
--3.����Ա
--4.������ˮ
--5.���񿨿���
--6.���п�����
--7.����ע��ʱ�� YYYY-MM-DD HH24:MI:SS
--8.������֤������
--9.������֤������
--10.����������
--11.�����˵绰
--12.��ע
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
    --1.��������
    SELECT * INTO LV_PAYCLRPARA FROM PAY_CLR_PARA A;
    PK_PUBLIC.P_GETINPUTPARA(AV_IN,6,12,'PK_SERVICE_OUTER.P_BANK_ZX',LV_IN,AV_RES,AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    IF LV_IN(2) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '��������Ͳ���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(2) <> '2' THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '��ҵ��ֻ����Χ���е���';
      RETURN;
    END IF;
    IF LV_IN(5) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '�籣�����Ų���Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(6) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '���п����Ų���Ϊ��';
      RETURN;
    END IF;
    --2.������ж�
    PK_CARD_APPLY_ISSUSE.P_JUDGE_ACPT(LV_IN(1), LV_IN(2), LV_IN(3), LV_USERS, LV_BASE_CO_ORG, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --3.���ݴ���Ŀ��Ż�ȡ����Ϣ
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
        AV_MSG := '���ݿ���' || LV_IN(5) || '�Ҳ�����������Ϣ';
        RETURN;
      WHEN OTHERS THEN
        AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG := '���ݿ���' || LV_IN(5) || '��ȡ������Ϣʱ���ִ���' || SQLERRM;
        RETURN;
      END;
      PK_CARD_STOCK.P_GETCARDBASEINFO(LV_CARD_APPLY.CARD_NO, LV_CARD_BASEINFO, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
      IF LV_CARD_BASEINFO.SUB_CARD_NO <> LV_IN(5) THEN
        AV_RES                        := PK_PUBLIC.CS_RES_UNKNOWNERR;
        AV_MSG                        := '���ݿ���' || LV_IN(5) || '��ȡ���Ŀ���Ϣ���ݲ�һ��';
        RETURN;
      END IF;
    ELSE
      PK_CARD_STOCK.P_GETCARDBASEINFO(LV_IN(5), LV_CARD_BASEINFO, AV_RES, AV_MSG);
      IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
        RETURN;
      END IF;
    END IF;
    --4.�ȽϿ���Ϣ�еİ���Ϣ�ʹ���Ľ����Ϣ�Ƿ�һ��
    IF LV_CARD_BASEINFO.BANK_ID IS NULL OR LV_CARD_BASEINFO.BANK_CARD_NO IS NULL THEN
      --AV_RES := PK_PUBLIC.CS_RES_NO_BIND_BANK;
      --AV_MSG := '����' || LV_IN(5) || 'δ�����п���Ϣ';
      AV_RES := PK_PUBLIC.cs_res_ok;
      AV_MSG := '';
      RETURN;
    END IF;
    IF LV_CARD_BASEINFO.BANK_ID <> NVL(LV_IN(1), 0) THEN
      AV_RES                    := PK_PUBLIC.CS_RES_BIND_BANK_ERR;
      AV_MSG                    := '����' || LV_IN(5) || '�󶨵����кͽ�����в�һ��';
      RETURN;
    END IF;
    IF LV_CARD_BASEINFO.BANK_CARD_NO <> NVL(LV_IN(6), 0) THEN
      AV_RES                         := PK_PUBLIC.CS_RES_BIND_BANKNO_ERR;
      AV_MSG                         := '����' || LV_IN(5) || '�󶨵����п����źʹ�������п����Ų�һ��';
      RETURN;
    END IF;
    --5.��ȡ����Ϣ���Ƚϰ󶨱��а���Ϣ�ͽ����Ϣ�Ƿ�һ��
    SELECT COUNT(1)
    INTO LV_COUNT
    FROM CARD_BIND_BANKCARD
    WHERE SUB_CARD_NO = LV_IN(5)
    AND CUSTOMER_ID   = LV_CARD_BASEINFO.CUSTOMER_ID;
    IF LV_COUNT       > 1 THEN
      AV_RES         := PK_PUBLIC.CS_RES_BIND_BANK_MORE;
      AV_MSG         := '���ݿ���' || LV_IN(5) || '�ҵ������󶨼�¼';
      RETURN;
    ELSIF LV_COUNT < 1 THEN
      AV_RES      := PK_PUBLIC.CS_RES_NO_BIND_BANK;
      AV_MSG      := '���ݿ���' || LV_IN(5) || '�Ҳ�������Ϣ';
      RETURN;
    ELSE
      SELECT *
      INTO LV_CARD_BIND_BANKCARD
      FROM CARD_BIND_BANKCARD
      WHERE SUB_CARD_NO = LV_IN(5);
    END IF;
    IF LV_CARD_BIND_BANKCARD.BANK_ID <> LV_IN(1) THEN
      AV_RES                         := PK_PUBLIC.CS_RES_BIND_BANK_ERR;
      AV_MSG                         := '����' || LV_IN(5) || '�󶨵����кͽ�����в�һ��';
      RETURN;
    END IF;
    IF LV_CARD_BIND_BANKCARD.BANK_CARD_NO <> LV_IN(6) THEN
      AV_RES                              := PK_PUBLIC.CS_RES_BIND_BANKNO_ERR;
      AV_MSG                              := '����' || LV_IN(5) || '�����п����źʹ�������п����Ų�һ��';
      RETURN;
    END IF;
    PK_CARD_APPLY_ISSUSE.P_GETBASEPERSONALBYCUSTOMERID(LV_CARD_BASEINFO.CUSTOMER_ID, LV_BASE_PERSONAL, AV_RES, AV_MSG);
    IF AV_RES <> PK_PUBLIC.CS_RES_OK THEN
      RETURN;
    END IF;
    --6.��¼������־
    SELECT SEQ_ACTION_NO.NEXTVAL
    INTO LV_SYSACTIONLOG.DEAL_NO
    FROM DUAL;
    LV_SYSACTIONLOG.DEAL_CODE   := '20409062';
    LV_SYSACTIONLOG.Deal_Time   := SYSDATE;
    LV_SYSACTIONLOG.MESSAGE     := '���н��,����:' || LV_CARD_BASEINFO.CARD_NO || ',�籣����:' || LV_IN(5) || ',���б��:' || LV_IN(1) || ',���п�����:' || LV_IN(6) || NVL(LV_IN(12), '');
    LV_SYSACTIONLOG.BRCH_ID     := LV_USERS.BRCH_ID;
    LV_SYSACTIONLOG.USER_ID     := LV_USERS.USER_ID;
    LV_SYSACTIONLOG.LOG_TYPE    := 0;
    LV_SYSACTIONLOG.IN_OUT_DATA := AV_IN;
    LV_SYSACTIONLOG.CO_ORG_ID   := LV_BASE_CO_ORG.CO_ORG_ID;
    LV_SYSACTIONLOG.ORG_ID      := LV_USERS.ORG_ID;
    INSERT INTO sys_action_log VALUES LV_SYSACTIONLOG;
    --7.���
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
      AV_MSG         := '��󿨺�' || LV_IN(5) || '�İ�ʱ���ҵ������󶨼�¼';
      RETURN;
    ELSIF SQL%ROWCOUNT < 1 THEN
      AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG          := '��󿨺�' || LV_IN(5) || '�İ�ʱ���ҵ�0���󶨼�¼';
      RETURN;
    END IF;
    UPDATE CARD_BASEINFO
    SET BANK_ID     = NULL,
      BANK_CARD_NO  = NULL
    WHERE CARD_NO   = LV_CARD_BASEINFO.CARD_NO;
    IF SQL%ROWCOUNT > 1 THEN
      AV_RES       := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG       := '��󿨺�' || LV_IN(5) || '�İ�ʱ���ҵ������󶨼�¼';
      RETURN;
    ELSIF SQL%ROWCOUNT < 1 THEN
      AV_RES          := PK_PUBLIC.CS_RES_UNKNOWNERR;
      AV_MSG          := '��󿨺�' || LV_IN(5) || '�İ�ʱ���ҵ�0���󶨼�¼';
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
--���˽�����Ϣ��ѯ
  PROCEDURE P_CONSUME_RECHARGE_QUERY
    (
      AV_CARD_NO    VARCHAR2,           --����
      AV_DEAL_TYPE  VARCHAR2,           --��ѯ�������� 0 ��ѯ���� 1 ��ѯ��ֵ  2 ��ѯ����
      AV_ACC_KIND   VARCHAR2,           --�˻�����
      AV_START_DATE VARCHAR2,           --��ѯ��ʼ����  YYYY-MM-DD
      AV_END_DATE   VARCHAR2,           --��ѯ�������� YYYY-MM-DD
      AV_PAGE_NO    NUMBER,             --�ڼ�ҳ
      AV_PCOUNT     NUMBER,             --ÿҳ������,
      AV_ORDERBY    VARCHAR2,           --�����ֶ�
      AV_ORDER      VARCHAR2,           --���� asc ����  desc
      AV_ALL_SIZE OUT NUMBER,           --�ܹ�������
      AV_ALL_PAGE OUT NUMBER,           --�ܹ�������ҳ
      AV_DATA OUT ZPAGE.DEFAULT_CURSOR, --�������
      AV_RES OUT VARCHAR2,              --����������
      AV_MSG OUT VARCHAR2               --������˵��
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
      AV_MSG      := '���Ų���Ϊ��';
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
      AV_MSG         := '��ѯ��ʼ���ڲ���Ϊ��';
      RETURN;
    END IF;
    IF AV_END_DATE IS NULL THEN
      AV_RES       := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG       := '��ѯ�������ڲ���Ϊ��';
      RETURN;
    END IF;
    IF AV_END_DATE < AV_START_DATE THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '��ѯ��ʼ���ڲ��ܴ��ڽ�������';
      RETURN;
    END IF;
    LV_MONTH_NUM        := MONTHS_BETWEEN(TO_DATE(AV_END_DATE, 'yyyy-mm-dd'), TO_DATE(AV_START_DATE, 'yyyy-mm-dd'));
    IF ABS(LV_MONTH_NUM) > 3 THEN
      AV_RES            := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG            := 'ֻ����ѯ����3�����ڵļ�¼��Ϣ';
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
      AV_MSG                  := '��ѯ���ڳ�������';
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
    LV_SQL         := LV_SQL || 'ELSE Z.MERCHANT_NAME END) ACPTNAME,DECODE(T.DEAL_STATE, ''0'', ''����'', ''1'', ''����'', ''2'', ''����'', ''����'') ';
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
--����9λ���籣�����Ż�ȡ20λ�ǽӿ���
  FUNCTION F_GETCARDNO_BY_SUBCARDNO(
      AV_SUB_CARD_NO VARCHAR2, --�籣������
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
--�������п����Ż�ȡ��Ӧ�Ŀ�����Ϣ
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
      av_msg                            := '���п�����' || av_bank_card_no || '��Ӧ�İ��Ʒ�Ѿ�ʹ��';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
  EXCEPTION
  WHEN no_data_found THEN
    av_res := pk_public.cs_res_bcp_not_exist;
    av_msg := '�������п�����' || av_bank_card_no || '�Ҳ�����Ӧ�İ��Ʒ����Ϣ';
    RETURN;
  WHEN too_many_rows THEN
    av_res := pk_public.cs_res_bcp_has_more;
    av_msg := '�������п�����' || av_bank_card_no || '�ҵ��������Ʒ����Ϣ';
    RETURN;
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_bcp_has_more;
    av_msg := '�������п�����' || av_bank_card_no || '��ȡ���Ʒ����Ϣ���ִ���' || SQLERRM;
  END p_getbcpcard;
--����������
--1����
--2����������״̬�� 0 ���Ӻ�����  1 ��ȥ������
--3�����Ӻ�����ʱ ��Ҫ���ݺ���������
--4�������������
  PROCEDURE P_CARD_BLACK(
      AV_DEAL_NO CARD_BLACK_REC.DEAL_NO%TYPE, --ACTIONNO
      AV_CARD_NO CARD_BASEINFO.CARD_NO%TYPE,  --�����������Ŀ�
      AV_STL_STATE VARCHAR2,                  --����������״̬  0 ���Ӻ�����  1 ��ȥ������
      AV_STL_TYPE  VARCHAR2,                  --��AV_STL_STATE = 0 ���Ӻ�����ʱ ��Ҫ���ݺ��������� 01 ���� 02 ���� 03��ʧ 09 ע��
      AV_DEAL_TIME VARCHAR2,                  --����ʱ��  ��ʽ��YYYY-MM-DD HH24:MI:SS
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
      AV_MSG      := '�������������Ų���Ϊ��';
      RETURN;
    END IF;
    IF AV_STL_STATE IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '�������������������Ͳ���Ϊ��';
      RETURN;
    ELSIF AV_STL_STATE <> '0' AND AV_STL_STATE <> '1' THEN
      AV_RES           := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG           := '��������������������ֻ����0��1';
      RETURN;
    ELSIF AV_STL_STATE = '0' AND AV_STL_TYPE IS NULL THEN
      AV_RES          := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG          := '���Ӻ��������������Ͳ���Ϊ��';
      RETURN;
    END IF;
    IF AV_DEAL_TIME IS NULL THEN
      AV_RES        := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG        := '��������������ʱ�䲻��Ϊ��';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO LV_CARD FROM CARD_BASEINFO WHERE CARD_NO = AV_CARD_NO;
    EXCEPTION
    WHEN OTHERS THEN
      AV_RES := PK_PUBLIC.CS_RES_CARDIDERR;
      AV_MSG := '�������������ݿ����Ҳ�������Ϣ';
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
        LV_CARD_BLACK.BLK_TYPE  := '00'; --������Ч������
        LV_CARD_BLACK.LAST_DATE := TO_DATE(AV_DEAL_TIME, 'yyyy-mm-dd hh24:mi:ss');
        --LV_CARD_BLACK.VERSION := SEQ_BLACK_VISION.NEXTVAL;
        SELECT SEQ_BLACK_VISION.NEXTVAL
        INTO LV_CARD_BLACK.VERSION
        FROM DUAL;
        INSERT INTO CARD_BLACK VALUES LV_CARD_BLACK;
      END IF;
    END IF;
    -- ������־
    SELECT VERSION
    INTO LV_VERSION
    FROM CARD_BLACK
    WHERE CARD_NO              = AV_CARD_NO;
    LV_CARD_BLACK_REC.DEAL_NO := AV_DEAL_NO;
    LV_CARD_BLACK_REC.CARD_ID := LV_CARD.CARD_ID;
    LV_CARD_BLACK_REC.CARD_NO := LV_CARD.CARD_NO;
    LV_CARD_BLACK_REC.VERSION := LV_VERSION;
    IF AV_STL_STATE            = 0 THEN
      LV_CARD_BLACK_REC.NOTES := '���Ӻ�����';
    ELSE
      LV_CARD_BLACK_REC.NOTES := '��ȥ������';
    END IF;
    INSERT INTO CARD_BLACK_REC VALUES LV_CARD_BLACK_REC;
    AV_RES := PK_PUBLIC.CS_RES_OK;
    AV_MSG := '�����������ɹ�';
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
    AV_MSG := SQLERRM;
  END P_CARD_BLACK;
--�����ƿ�  ���ý���
--av_in: 1����
--       2�Ա�
--       3֤������
--       4֤������
--       5���񿨿���
--       6�������ڳ���
--       7�����������򣨽ֵ���
--       8�������ڴ壨������
--       9��ס��ַ
--      10��ϵ��ַ
--      11��������
--      12�̶��绰
--      13�ֻ�����
--      14�����ʼ�
--      15��λ�ͻ�����
--      16�ܿ����ն˱�ʶ��
--      17�ܿ����ı�ʶ��
--      18��Ա��
--      19��ע
--      20������
--      21����
--      22�������� 0 ���� 1 ���
-- av_out��1�ֿ�������
--         2�ֿ����Ա�
--         3�ֿ���֤������
--         4�ֿ���֤������
--         5�������� 01
--         6�������� 00
--         7����Ч����
--         8���ñ�־
--         9����Ǯ��Ӧ����������
--         10����Ǯ��Ӧ����Ч����
  PROCEDURE p_applyCard
    (
      av_in    IN VARCHAR2, --�������
      av_debug IN VARCHAR2, --1����
      av_out OUT VARCHAR2,  --������Ϣ
      av_res OUT VARCHAR2,  --��������
      av_msg OUT VARCHAR2   --����������Ϣ
    )
  IS
    lv_count NUMBER;
    lv_in pk_public.myarray;                    --�����������
    lv_base_personal base_personal%ROWTYPE;     --��Ա������Ϣ
    lv_base_corp base_corp%ROWTYPE;             --��λ������Ϣ
    lv_operator sys_users%ROWTYPE;              --����Ա
    lv_clrdate pay_clr_para.clr_date%TYPE;      --�������
    lv_card_apply card_apply%ROWTYPE;           --���������Ϣ
    lv_card_apply_task card_apply_task%ROWTYPE; -- ������Ϣ
    lv_Card_task_list card_task_list%ROWTYPE;   -- ������ϸ��Ϣ
    lv_card card_baseinfo%ROWTYPE;              --��������Ϣ
    lv_action_log sys_action_log%ROWTYPE;       -- ������־��
    lv_serv_rec tr_serv_rec%Rowtype;            -- �ۺ�ҵ����־��
    lv_action_no sys_action_log.deal_no%type;   -- ��ˮ��
  BEGIN
    --�ֽ����
    pk_public.p_getinputpara(av_in, --�������
    22,                             --�������ٸ���
    22,                             --����������
    'pk_transfer.p_transfer',       --���õĺ�����
    lv_in,                          --ת���ɲ�������
    av_res,                         --������������
    av_msg                          --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    av_out := '';
    --�жϽ������Ϣ�Ƿ���ȷ
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(18);
    IF lv_operator.user_id IS NULL OR lv_operator.brch_id <> lv_in(17) THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '�ܿ��������֤ʧ��';
      RETURN;
    END IF;
    --�жϿ�����Ϣ�Ƿ���ȷ���Ƿ�������Ԥ���ɵĿ��ţ�
    SELECT COUNT(1)
    INTO lv_count
    FROM card_task_list t2
    WHERE t2.card_no = lv_in(5);
    IF lv_count     <> 1 THEN
      av_res        := pk_public.cs_res_cardiderr;
      av_msg        := '������֤ʧ��';
      RETURN;
    END IF;
    -- �жϸ��û��Ƿ�ֻ��һ��ȫ���ܿ�
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
        av_msg            := '�ÿͻ�����ȫ���ܿ��������ظ�����';
        RETURN;
      END IF;
    END IF;
    -- ȡ��������Ϣ
    SELECT *
    INTO lv_Card_task_list
    FROM card_task_list t5
    WHERE t5.card_no = lv_in(5);
    SELECT *
    INTO lv_card_apply_task
    FROM card_apply_task t6
    WHERE t6.task_id = lv_Card_task_list.Task_Id;
    -- ��֤��ɺ�ʼ�����������
    -- �����ۺ�ҵ����־�Ͳ�����־
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
    lv_action_log.message     := '�����ƿ���' + lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := '�����ƿ���' + lv_operator.brch_id;
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
    lv_serv_rec.note          := av_in + '�ƿ�����';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --���뵥λ��Ϣ
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
    --������Ա������Ϣ
    --1 ������ڸ���Ա��Ϣ ���޸ĸ���Ա��Ϣ�ĸ�����Ϣ  --�����������  --�� ��������������ϸ���ֶ�
    --2 ��������ڸ���Ա��Ϣ  ��������Ա��Ϣ --�� ���������  --�� ��������������ϸ���ֶ�
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
          '�����ƿ������ǣ�'
        );
    END IF;
    --���������
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
    --�޸�������Ϣ
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
    --��װ���ز���
    -- av_out��1�ֿ�������
    --         2�ֿ����Ա�
    --         3�ֿ���֤������
    --         4�ֿ���֤������
    --         5�������� 01
    --         6�������� 00
    --         7����Ч����
    --         8���ñ�־
    --         9����Ǯ��Ӧ����������
    --         10����Ǯ��Ӧ����Ч����
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
      || '------����ʧ�ܣ�������Ϣ��{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '��')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_applyCard;
--1����  ���ý���
--2֤������
--3֤������
--4����
--5��������
--6��������
--7������
--8�ܿ����ı�ʶ��
--9��Ա��
--10��ע
--11 �Ƿ����Ͽ� 0 �� 1 ��
--12 �Ͽ�����
  PROCEDURE p_openAccandCard(
      av_in    IN VARCHAR2, --�������
      av_debug IN VARCHAR2, --1����
      av_res OUT VARCHAR2,  --��������
      av_msg OUT VARCHAR2   --����������Ϣ
    )
  IS
    lv_count NUMBER;
    lv_action_no sys_action_log.deal_no%type;     -- ��ˮ��
    lv_clrdate pay_clr_para.clr_date%TYPE;        --�������
    lv_in pk_public.myarray;                      --�����������
    lv_base_personal base_personal%ROWTYPE;       --��Ա������Ϣ
    lv_Card_task_list card_task_list%ROWTYPE;     -- ������ϸ��Ϣ
    lv_operator sys_users%ROWTYPE;                --����Ա
    lv_action_log sys_action_log%ROWTYPE;         -- ������־��
    lv_serv_rec tr_serv_rec%Rowtype;              -- �ۺ�ҵ����־��
    lv_old_card card_baseinfo%rowtype;            --�Ͽ�����Ϣ
    lrec_acc_account_sub acc_account_sub%rowtype; --�˻���Ϣ
    lv_acc_in   VARCHAR2(500);
    lv_trans_in VARCHAR2(500);
  BEGIN
    --�ֽ����
    pk_public.p_getinputpara(av_in, --�������
    12,                             --�������ٸ���
    12,                             --����������
    'pk_transfer.p_transfer',       --���õĺ�����
    lv_in,                          --ת���ɲ�������
    av_res,                         --������������
    av_msg                          --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res      := pk_public.cs_res_ok;
    av_msg      := '';
    lv_acc_in   := '';
    lv_trans_in := '';
    --�жϽ������Ϣ�Ƿ���ȷ
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(18);
    IF lv_operator.user_id IS NULL OR lv_operator.brch_id <> lv_in(17) THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '�ܿ��������֤ʧ��';
      RETURN;
    END IF;
    --�жϿ�����Ϣ�Ƿ���ȷ���Ƿ�������Ԥ���ɵĿ��ţ�
    SELECT COUNT(1)
    INTO lv_count
    FROM card_task_list t2
    WHERE t2.card_no = lv_in(5);
    IF lv_count     <> 1 THEN
      av_res        := pk_public.cs_res_cardiderr;
      av_msg        := '������֤ʧ��';
      RETURN;
    END IF;
    SELECT * INTO lv_Card_task_list FROM card_task_list WHERE card_no = lv_in(1);
    --����ҵ����־�Ͳ�����־
    -- �����ۺ�ҵ����־�Ͳ�����־
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
    lv_action_log.message     := '�����ţ�' + lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := av_in + '�����ţ�' + lv_operator.brch_id;
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
    lv_serv_rec.note          := av_in + '������';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --���뿨��Ϣ
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
        NULL, --��������
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
    --���ÿ����洢����
    --���˻�
    --av_in: 1action_no|2DEAL_CODE|3oper_id|4oper_time|
    --5obj_type     ���ͣ����˻���������һ�£�0-����1-����/�� 2-��λ 3-�̻�4-������
    --6sub_type     ������(���ô���)
    --7obj_id       �˻����������ǿ�ʱ�����뿨�ţ�(�������ʱ������֮����,�ָ� cardno1,cardno2)
    --                             ��������client_id��
    --8pwd          ����
    --9encrypt      ���˻��������(�������ʱ��֮����,�ָ� encrypt1,encrypt2)
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
    FROM dual; ---����Ҫ�޸�0������
    pk_business.p_createaccount(lv_acc_in, av_res, av_msg);
    --�ж��Ƿ����Ͽ������Ͽ����Ͽ��������˻�ת���¿������˻���
    IF lv_in(12) = '0' THEN
      BEGIN
        --�п����Ͽ�����Ϊ�� cs_res_oldcardnull_err
        IF lv_in(12) IS NULL THEN
          av_res     := pk_public.cs_res_oldcardnull_err;
          av_msg     := '�Ͽ����Ų���Ϊ��';
          RETURN;
        END IF;
        SELECT *
        INTO lv_old_card
        FROM card_baseinfo
        WHERE card_no = lv_in(12)
        AND card_type = '100';
        --ת�ƽ��
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
          lv_trans_in              := lv_trans_in || lv_operator.brch_id || '|';                            --5acpt_id        �������(����Ż��̻����)
          lv_trans_in              := lv_trans_in || TO_CHAR(lv_action_log.deal_time, 'yyyymmdd') || '|';   --6tr_batch_no    ���κ�
          lv_trans_in              := lv_trans_in || TO_CHAR(lv_action_log.deal_time, 'hh24:mi:ss') || '|'; --7term_tr_no     �ն˽�����ˮ��
          lv_trans_in              := lv_trans_in || lv_in(12) || '|';                                      --8card_no1       ת������
          lv_trans_in              := lv_trans_in || '|';                                                   --9card_tr_count1 ת�������׼�����
          lv_trans_in              := lv_trans_in || '|';                                                   --10card_bal1     ת����Ǯ������ǰ���
          lv_trans_in              := lv_trans_in || '02' || '|';                                           --11acc_kind1     ת�����˻�����
          lv_trans_in              := lv_trans_in || '00' || '|';                                           --12wallet_id1    ת����Ǯ����� Ĭ��00
          lv_trans_in              := lv_trans_in || lv_in(1) || '|';                                       --13card_no2      ת�뿨��
          lv_trans_in              := lv_trans_in || '|';                                                   --14card_tr_count2ת�뿨���׼�����
          lv_trans_in              := lv_trans_in || '|';                                                   --15card_bal2     ת�뿨Ǯ������ǰ���
          lv_trans_in              := lv_trans_in || '02' || '|';                                           --16acc_kind2     ת�뿨�˻�����
          lv_trans_in              := lv_trans_in || '00' || '|';                                           --17wallet_id2    ת�뿨Ǯ����� Ĭ��00
          lv_trans_in              := lv_trans_in || '|';                                                   --18tr_amt        ת�˽��  nullʱת�����н��
          lv_trans_in              := lv_trans_in || lv_old_card.pay_pwd || '|';                            --19pwd           ת������
          lv_trans_in              := lv_trans_in || '������ת��' || '|';                                        --20note          ��ע
          lv_trans_in              := lv_trans_in || '0' || '|';                                            --21encrypt1      ת����ת�˺������� 0 �����ģ���ʱ��֪��
          lv_trans_in              := lv_trans_in || lrec_acc_account_sub.bal_crypt || '|';                 --22encrypt2      ת�뿨ת�˺�������
          lv_trans_in              := lv_trans_in || '0' || '|';                                            --23tr_state      9д�Ҽ�¼0ֱ��д������¼
          lv_trans_in              := lv_trans_in || '1' || '|';                                            --24acpt_type     ��������
          lv_trans_in              := lv_trans_in || lrec_acc_account_sub.bal || '|';                       --25acc_bal1      ת�����˻�����ǰ���
          lv_trans_in              := lv_trans_in || 0 || '|';                                              --26acc_bal2      ת�뿨�˻�����ǰ���
          pk_transfer.p_transfer(lv_trans_in, '1', av_res, av_msg);
        END IF;
        IF av_res <> pk_public.cs_res_ok THEN
          Raise_application_error(-20000, av_msg);
        END IF;
      EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_oldcardnotexist_err;
        av_Msg := 'ԭ���˻���Ϣ������';
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
      || '------����ʧ�ܣ�������Ϣ��{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '��')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_openAccandCard;
--���¸�����Ϣ
--av_in: 1֤������
--       2�ֻ���
--       3��ͥסַ
--       4��ͥ��ϵ�绰
--       5��Ա��
--       6΢�ź�
  PROCEDURE p_updatePersonalInfo(
      av_in    IN VARCHAR2, --�������
      av_debug IN VARCHAR2, --1����
      av_res OUT VARCHAR2,  --��������
      av_msg OUT VARCHAR2   --����������Ϣ
    )
  IS
    lv_count NUMBER;
    lv_action_no sys_action_log.deal_no%type; -- ��ˮ��
    lv_clrdate pay_clr_para.clr_date%TYPE;    --�������
    lv_in pk_public.myarray;                  --�����������
    lv_operator sys_users%ROWTYPE;            --����Ա
    lv_action_log sys_action_log%ROWTYPE;     -- ������־��
    lv_base_personal base_personal%ROWTYPE;   --��Ա������Ϣ
    lv_serv_rec tr_serv_rec%Rowtype;          -- �ۺ�ҵ����־��
  BEGIN
    --�ֽ����
    pk_public.p_getinputpara(av_in,          --�������
    6,                                       --�������ٸ���
    6,                                       --����������
    'PK_SERVICE_OUTER.p_updatePersonalInfo', --���õĺ�����
    lv_in,                                   --ת���ɲ�������
    av_res,                                  --������������
    av_msg                                   --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    --�жϽ������Ϣ�Ƿ���ȷ
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(5);
    IF lv_operator.user_id IS NULL THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '�ܿ��������֤ʧ��';
      RETURN;
    END IF;
    SELECT *
    INTO lv_base_personal
    FROM base_personal l
    WHERE l.cert_no                  = lv_in(1);
    IF lv_base_personal.customer_id IS NULL THEN
      av_res                        := pk_public.cs_res_user_err;
      av_msg                        := '��ݺ���֤ʧ��';
      RETURN;
    END IF;
    --������־
    SELECT seq_action_no.nextval INTO lv_action_no FROM dual;
    SELECT t.clr_date INTO lv_clrdate FROM pay_clr_para t;
    lv_action_log.deal_no     := lv_action_no;
    lv_action_log.deal_code   := 10101020;
    lv_action_log.org_id      := lv_operator.org_id;
    lv_action_log.brch_id     := lv_operator.brch_id;
    lv_action_log.user_id     := lv_operator.user_id;
    lv_action_log.deal_time   := to_date(TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type    := 0;
    lv_action_log.message     := '�޸ĸ�����Ϣ��' || lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := av_in || '�޸ĸ�����Ϣ��' || lv_operator.brch_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    --��¼ҵ����־
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
    lv_serv_rec.note          := av_in || '�޸ĸ�����Ϣ';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    lv_serv_rec.rsv_five      :=lv_in(4);--΢�ű��
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --�����ֻ���,��ͥ��ַ����ͥ��ϵ�绰
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
      || '------����ʧ�ܣ�������Ϣ��{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '��')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_updatePersonalInfo;
-- av_in:1�����������
--       2����סַ
--       3������ϵ�绰
--       4��Ա��
  PROCEDURE p_update_Co_Org(
      av_in    IN VARCHAR2, --�������
      av_debug IN VARCHAR2, --1����
      av_res OUT VARCHAR2,  --��������
      av_msg OUT VARCHAR2   --����������Ϣ
    )
  IS
    lv_count NUMBER;
    lv_action_no sys_action_log.deal_no%type; -- ��ˮ��
    lv_clrdate pay_clr_para.clr_date%TYPE;    --�������
    lv_in pk_public.myarray;                  --�����������
    lv_operator sys_users%ROWTYPE;            --����Ա
    lv_action_log sys_action_log%ROWTYPE;     -- ������־��
    lv_base_co_org base_co_org%ROWTYPE;       --����������Ϣ
    lv_serv_rec tr_serv_rec%Rowtype;          -- �ۺ�ҵ����־��
  BEGIN
    --�ֽ����
    pk_public.p_getinputpara(av_in,     --�������
    4,                                  --�������ٸ���
    4,                                  --����������
    'PK_SERVICE_OUTER.p_update_Co_Org', --���õĺ�����
    lv_in,                              --ת���ɲ�������
    av_res,                             --������������
    av_msg                              --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    --�жϽ������Ϣ�Ƿ���ȷ
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(4);
    IF lv_operator.user_id IS NULL THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '�������������֤ʧ��';
      RETURN;
    END IF;
    SELECT * INTO lv_base_co_org FROM base_co_org g WHERE g.co_org_id = lv_in(1);
    IF lv_base_co_org.customer_id IS NULL THEN
      av_res                      := pk_public.cs_res_user_err;
      av_msg                      := '���������֤ʧ��';
      RETURN;
    END IF;
    --������־
    SELECT seq_action_no.nextval INTO lv_action_no FROM dual;
    SELECT t.clr_date INTO lv_clrdate FROM pay_clr_para t;
    lv_action_log.deal_no     := lv_action_no;
    lv_action_log.deal_code   := 10101020;
    lv_action_log.org_id      := lv_operator.org_id;
    lv_action_log.brch_id     := lv_operator.brch_id;
    lv_action_log.user_id     := lv_operator.user_id;
    lv_action_log.deal_time   := to_date(TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    lv_action_log.log_type    := 0;
    lv_action_log.message     := '�޸ĺ���������Ϣ��' + lv_operator.brch_id;
    lv_action_log.in_out_data := av_in;
    lv_action_log.note        := av_in + '�޸ĺ���������Ϣ��' + lv_operator.brch_id;
    INSERT INTO sys_action_log VALUES lv_action_log;
    --��¼ҵ����־
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
    lv_serv_rec.note          := av_in + '�޸ĺ���������Ϣ';
    lv_serv_rec.biz_time      := lv_action_log.deal_time;
    INSERT INTO tr_serv_rec VALUES lv_serv_rec;
    --�����ֻ���,��ͥ��ַ����ͥ��ϵ�绰
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
      || '------����ʧ�ܣ�������Ϣ��{'
      || av_res
      || ','
      || REPLACE(av_Msg, '''', '��')
      || '}'
    WHERE deal_no = lv_action_no;
    COMMIT;
  END p_update_Co_Org;
--�����������������޸�
--1��bizid ����������
--2��oper_id ����Ա
--3��old_pwd ������
--4��new_pwd ������
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
      av_msg                      := '���������֤ʧ��';
      RETURN;
    END IF;
    SELECT * INTO LV_USERS FROM sys_users r WHERE r.user_id=LV_IN(2);
    IF LV_USERS.MYID IS NULL THEN
      av_msg         := '����Ա��֤ʧ��';
      RETURN;
    END IF;
    IF LV_IN(3) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := 'ԭʼ���벻��Ϊ��';
      RETURN;
    END IF;
    IF LV_IN(4) IS NULL THEN
      AV_RES    := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG    := '�����벻��Ϊ��';
      RETURN;
    END IF;
    IF LV_BASE_CO_ORG.Serv_Pwd<> encrypt_des_oracle(LV_IN(3),LV_BASE_CO_ORG.Customer_Id) THEN
      av_res                  := pk_public.cs_res_pwderr;
      av_msg                  := 'ԭʼ���벻��ȷ';
      RETURN;
    END IF;
    IF NVL(LV_BASE_CO_ORG.Serv_Pwd_Err_Num,0)>=pk_public.cs_serv_pwd_err_num THEN
      av_res                                := pk_public.cs_res_pwderrnum ;
      av_msg                                := '��������������'||pk_public.cs_serv_pwd_err_num||'��';
      RETURN;
    END IF;
    UPDATE base_co_org o
    SET o.serv_pwd      = encrypt_des_oracle(LV_IN(4),LV_BASE_CO_ORG.Customer_Id),
      o.serv_pwd_err_num=0
    WHERE o.co_org_id   = LV_IN(1) ;
    SELECT SEQ_ACTION_NO.NEXTVAL INTO LV_SYSACTIONLOG.DEAL_NO FROM DUAL;
    LV_SYSACTIONLOG.DEAL_CODE   := 20502020;
    LV_SYSACTIONLOG.MESSAGE     := '�����������������޸�,���:' || lv_in(1) || ',����:' || LV_BASE_CO_ORG.CO_ORG_NAME;
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
--��������������Ϣ��ѯ
  PROCEDURE P_Co_Org_Query
    (
      AV_CO_ORG_ID  VARCHAR2,           --�������
      AV_DEAL_TYPE  VARCHAR2,           --��ѯ�������� 0 ��ѯ���� 1 ��ѯ��ֵ  2 ��ѯ����
      AV_ITEM_NO    VARCHAR2,           --��Ŀ����
      AV_START_DATE VARCHAR2,           --��ѯ��ʼ����  YYYY-MM-DD
      AV_END_DATE   VARCHAR2,           --��ѯ�������� YYYY-MM-DD
      AV_PAGE_NO    NUMBER,             --�ڼ�ҳ
      AV_PCOUNT     NUMBER,             --ÿҳ������,
      AV_ORDERBY    VARCHAR2,           --�����ֶ�
      AV_ORDER      VARCHAR2,           --���� asc ����  desc
      AV_ALL_SIZE OUT NUMBER,           --�ܹ�������
      AV_ALL_PAGE OUT NUMBER,           --�ܹ�������ҳ
      AV_DATA OUT ZPAGE.DEFAULT_CURSOR, --�������
      AV_RES OUT VARCHAR2,              --����������
      AV_MSG OUT VARCHAR2               --������˵��
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
      AV_MSG        := '������Ų���Ϊ��';
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
      AV_MSG         := '��ѯ��ʼ���ڲ���Ϊ��';
      RETURN;
    END IF;
    IF AV_END_DATE IS NULL THEN
      AV_RES       := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG       := '��ѯ�������ڲ���Ϊ��';
      RETURN;
    END IF;
    IF AV_END_DATE < AV_START_DATE THEN
      AV_RES      := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG      := '��ѯ��ʼ���ڲ��ܴ��ڽ�������';
      RETURN;
    END IF;
    LV_MONTH_NUM        := MONTHS_BETWEEN(TO_DATE(AV_END_DATE, 'yyyy-mm-dd'), TO_DATE(AV_START_DATE, 'yyyy-mm-dd'));
    IF ABS(LV_MONTH_NUM) > 3 THEN
      AV_RES            := PK_PUBLIC.CS_RES_PARAVALUEERR;
      AV_MSG            := 'ֻ����ѯ����3�����ڵļ�¼��Ϣ';
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
      AV_MSG                  := '��ѯ���ڳ�������';
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
    ---trname:������, acptname :���������,accname:����,actionno:������ˮ,bal:����ǰ���,amt:���׷�����,trdate:����ʱ��}
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
--¼�����񿨱�����Ϣ
-- av_in:1�����������
-- 2 �������
-- 3 ���񿨿���
-- 4 �ͻ�����
-- 5 ���֤��
-- 6 ��ᱣ�Ϻ�
-- 7 ����ʱ��
-- 8 Ӧ��״̬(Ͷ��״̬��<1�ѹ���δ����>��<2�ѹ��򡢳�����>��<3����Ч>��<4�ѹ���>';
-- 9 ��������
-- 10 Ͷ�����
-- 11 ������Ч�ڣ���ֹ��
-- 12 ������
-- 13 ������Ա���
  PROCEDURE p_Entering_Insure(
      av_in IN VARCHAR2,   --�������
      av_res OUT VARCHAR2, --��������
      av_msg OUT VARCHAR2  --����������Ϣ
    )
  IS
    lv_in pk_public.myarray;            --�����������
    lv_operator sys_users%ROWTYPE;      --����Ա
    lv_card_app_bx CARD_APP_BX%ROWTYPE; --���յ���Ϣ
    lv_base_co_org base_co_org%ROWTYPE; --����������Ϣ
  BEGIN
    --�ֽ����
    pk_public.p_getinputpara(av_in,       --�������
    13,                                   --�������ٸ���
    13,                                   --����������
    'PK_SERVICE_OUTER.p_Entering_Insure', --���õĺ�����
    lv_in,                                --ת���ɲ�������
    av_res,                               --������������
    av_msg                                --��������������Ϣ
    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    --�жϽ������Ϣ�Ƿ���ȷ
    SELECT *
    INTO lv_operator
    FROM sys_users t1
    WHERE t1.user_id        = lv_in(13);
    IF lv_operator.user_id IS NULL THEN
      av_res               := pk_public.cs_res_user_err;
      av_msg               := '�ܿ��������֤ʧ��';
      RETURN;
    END IF;
    SELECT * INTO lv_base_co_org FROM base_co_org g WHERE g.co_org_id = lv_in(1);
    IF lv_base_co_org.customer_id IS NULL THEN
      av_res                      := pk_public.cs_res_user_err;
      av_msg                      := '���������֤ʧ��';
      RETURN;
    END IF;
    --������־
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
--�������
--1��AV_CARDBASEINFO --����Ϣ
--2��AV_BASEPERSON --��Ա��Ϣ
--3��AV_SYSACTIONLOG ��־��Ϣ
--4��AV_SMS_TYPE �������� 01����02��ֵ03����04Ȧ�� 99�Զ������
--5:AV_AMT ���
  PROCEDURE p_Save_Message
    (
      AV_CARDBASEINFO IN card_baseinfo%ROWTYPE,  --����Ϣ
      AV_BASEPERSON   IN base_personal%ROWTYPE,  --��Ա��Ϣ
      AV_SYSACTIONLOG IN SYS_ACTION_LOG%ROWTYPE, --��־��Ϣ
      AV_SMS_TYPE     IN VARCHAR2,               --�������� 01����02��ֵ03����04Ȧ�� 99�Զ������
      AV_AMT          IN INTEGER,                --���
      av_res OUT VARCHAR2,                       --��������
      av_msg OUT VARCHAR2
    )
  IS
    SMESSAGE SYS_SMESSAGES%ROWTYPE;              --������Ϣ
    SYSCODE SYS_CODE_TR%ROWTYPE;                 --����������Ϣ
    SYSSMESSAGESPARA SYS_SMESSAGES_PARA%ROWTYPE; --���Ų�����Ϣ
    ROWNCOUNT INTEGER;
    AS_SMS_NO INTEGER;
  BEGIN
    SELECT SEQ_SYS_SMESSAGES.NEXTVAL INTO AS_SMS_NO FROM DUAL;
    SMESSAGE.SMS_NO      := AS_SMS_NO;
    SMESSAGE.DEAL_NO     := AV_SYSACTIONLOG.DEAL_NO;                   --//ҵ����ˮ�ţ�����ҵ����¼
    SMESSAGE.CARD_NO     := AV_CARDBASEINFO.CARD_NO;                   --//����
    SMESSAGE.CUSTOMER_ID := AV_CARDBASEINFO.CUSTOMER_ID;               --//�ͻ���ţ������ͻ���Ϣ
    SMESSAGE.MOBILE_NO   := AV_CARDBASEINFO.Mobile_Phone;              --//�绰���룺ȡ��bs_person.MBOPEN_NO�ֻ����������ߴ���
    SMESSAGE.OPER_ID     := AV_SYSACTIONLOG.USER_ID;                   --//��Ա���
    SMESSAGE.SMS_TYPE    := AV_SMS_TYPE;                               --//�������� 01����02��ֵ03����04Ȧ�� 99�Զ������
    SMESSAGE.Create_Time := TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:ss'); --//��������ʱ�䣺Ĭ�����ݿ�ϵͳʱ��
    SMESSAGE.DEAL_CODE   := AV_SYSACTIONLOG.DEAL_CODE;
    SMESSAGE.SMS_STATE   := '0'; --//����״̬ 0δ���� 1�ѷ��� 2���ͳɹ� 3����ʧ��
    --���Ų�����Ϣ
    SELECT COUNT(*)
    INTO ROWNCOUNT
    FROM SYS_SMESSAGES_PARA S
    WHERE S.DEAL_CODE = AV_SYSACTIONLOG.DEAL_CODE
    AND S.STATE       = '0';
    --������Ϣ
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
      --�ֽ��ֵ--�𾴵��û�������{%}�����˻���{%}�ֽ��ֵ{%}Ԫ��
      IF AV_SYSACTIONLOG.DEAL_CODE = 30101020 THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '�����˻���' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '�ֽ��ֵ' || SUBSTR(TO_CHAR(AV_AMT), 0, LENGTH(TO_CHAR(AV_AMT)) - 2) || '.' || SUBSTR(TO_CHAR(AV_AMT), LENGTH(TO_CHAR(AV_AMT)) - 1, 2) || 'Ԫ';
      END IF;
      --������ֵ--�𾴵��û�������{%}�����˻���{%}������ֵ{%}Ԫ��
      IF AV_SYSACTIONLOG.DEAL_CODE = 30301020 THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '�����˻���' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '������ֵ' || SUBSTR(TO_CHAR(AV_AMT), 0, LENGTH(TO_CHAR(AV_AMT)) - 2) || '.' || SUBSTR(TO_CHAR(AV_AMT), LENGTH(TO_CHAR(AV_AMT)) - 1, 2) || 'Ԫ';
      END IF;
      --Ԥ��ʧ--�𾴵��û�������{%}��{%}Ԥ��ʧ�ɹ���ϵͳ����48Сʱ���Զ���ң�������ʱ�����񿨷������Ļ����������������ʧ��ȷ���ʽ�ȫ��
      IF AV_SYSACTIONLOG.DEAL_CODE = 20501050 THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '��' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || 'Ԥ��ʧ�ɹ���ϵͳ����48Сʱ���Զ���ң�������ʱ�����񿨷������Ļ����������������ʧ��ȷ���ʽ�ȫ��';
      END IF;
      --�˽�������֤��--�𾴵��û�������{%}�����˻�������ҽ�ƻ�����{%}�˽�������֤��{%}Ԫ��
      IF AV_SYSACTIONLOG.DEAL_CODE = '2632' THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '�����˻�������ҽ�ƻ�����' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '��ҽ�Ʊ�֤��' || AV_AMT / 100 || 'Ԫ��';
      END IF;
      --�𾴵��û�������{%}��{%}��ҳɹ���
      IF AV_SYSACTIONLOG.DEAL_CODE = 20501060 THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '��' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '��ҳɹ�';
      END IF;
      --�𾴵��û�������{%}��{%}��ʽ��ʧ�ɹ�
      IF AV_SYSACTIONLOG.DEAL_CODE = 20501040 THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '��' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '��ʽ��ʧ�ɹ�';
      END IF;
      IF AV_SYSACTIONLOG.DEAL_CODE = '2611' THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '��' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '��ʽ��ʧ�ɹ�';
      END IF;
      IF AV_SYSACTIONLOG.DEAL_CODE = 20401050 THEN
        SMESSAGE.CONTENT          := '�𾴵��û�������' || SYSCODE.DEAL_CODE_NAME || '��' || TO_CHAR(SYSDATE, 'yyyy-MM-dd HH24:mm:dd') || '�����ɹ�';
      END IF;
      --������ż�¼
      INSERT INTO SYS_SMESSAGES VALUES SMESSAGE;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    av_res := pk_public.cs_res_unknownerr;
    av_msg := 'ϵͳ����';
    ROLLBACK;
    RAISE_APPLICATION_ERROR('-20001', SQLERRM);
  END p_Save_Message;
BEGIN
  -- INITIALIZATION
  NULL;
END PK_SERVICE_OUTER;
/

