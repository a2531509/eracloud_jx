CREATE OR REPLACE PACKAGE PK_CARD_APPLY_ISSUSE IS

  /*=======================================================================================*/
  --���˷���
  /*=======================================================================================*/
  PROCEDURE P_ONECARD_ISSUSE(AS_CARD_NO         VARCHAR2, --����
                             AS_DEAL_NO         INTEGER, --���Ľ�����ˮ��
                             AS_BANK_NO         VARCHAR2, --���п���
                             AS_STOCK_FLAG      VARCHAR2, --�Ƿ���¿ⷿ��0�У�1û��
                             AS_SYNCH2CARDUPATE VARCHAR2, --�Ƿ�ͬ��������ƽ̨��0ͬ����1��ͬ��
                             AS_ACPT_TYPE       VARCHAR2, --���������-1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳� ---- ����
                             AV_RES             OUT VARCHAR2, --������������
                             AV_MSG             OUT VARCHAR2 --��������������Ϣ
                             );
  /*=======================================================================================*/
  --��ģ���Ž����ֻ��� �����۳�Ѻ��
  /*=======================================================================================*/
  PROCEDURE P_BATCH_ISSUSE(AS_DEAL_CODE IN ACC_INOUT_DETAIL.DEAL_CODE%TYPE, --���״���
                           AS_TASKID    IN CARD_APPLY.TASK_ID%TYPE, --�����
                           AS_CARD_TYPE IN CARD_BASEINFO.CARD_TYPE%TYPE, --������
                           AS_DEAL_NO   IN INTEGER, --ҵ����ˮ��
                           AV_MSG       OUT VARCHAR2, --��������
                           AV_RES       OUT VARCHAR2);

  /*=======================================================================================*/
  --ͬ�����籣 taskId,Bs_Person person,Cm_Card card,Cm_Card oldcard,Sys_Action_Log log,String applyType,long count
  /*=======================================================================================*/
  PROCEDURE P_SYNCH2CARD_UPATE(AS_TASKID    VARCHAR2, --����
                               AS_CERT_NO   varchar2, --���Ľ�����ˮ��
                               AS_CARD_NO1  VARCHAR2, --�Ƿ���¿ⷿ��0�У�1û��
                               AS_CARD_NO2  VARCHAR2, --�Ƿ�ͬ��������ƽ̨��0ͬ����1��ͬ��
                               AS_DEAL_NO   INTEGER, --������ˮ��
                               AS_APPLYTYPE VARCHAR2, --��������
                               AV_RES       OUT VARCHAR2, --������������
                               AV_MSG       OUT VARCHAR2 --��������������Ϣ
                               );

  /*=======================================================================================*/
  --����������ϸ
  /*=======================================================================================*/
  PROCEDURE P_INSERTCARDTASKLIST(AV_TASKID IN VARCHAR2, --�����
                                 AV_DEBUG  IN VARCHAR2, --����0�ǣ�1��
                                 AV_RES    OUT VARCHAR2, --������������
                                 AV_MSG    OUT VARCHAR2 --��������������Ϣ
                                 );
  -- Author  : hujc
  -- Created : 2015/7/3 14:39:11
  -- Purpose : ����������

  /*=======================================================================================*/
  --�����ƿ�
  --av_in: 1����
  --       2�Ա�
  --       3֤������
  --       4֤������----����
  --       5���񿨿���-----����
  --       6�������ڳ���
  --       7�����������򣨽ֵ���
  --       8�������ڴ壨������
  --       9��ס��ַ
  --      10��ϵ��ַ
  --      11��������
  --      12�̶��绰
  --      13�ֻ�����-----����
  --      14�����ʼ�
  --      15��λ�ͻ�����
  --      16�ն˴�������㣬----����
  --      17����(����)����,---����
  --      18��Ա��-----����
  --      19��ע
  --      20������
  --      21����
  --      22�������� 0 ���� 1 ���
  --      23������--��λ����
  --      24�Ӽ���--��λ����
  --      25������֤������
  --      26������֤������
  --      27����������
  --      28��������ϵ�绰
  --      29���������-1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳� ---- ����
  --      30�ն˽�����ˮ��--����
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

  /*=======================================================================================*/
  PROCEDURE P_APPLYCARD(AV_IN    IN VARCHAR2, --�������
                        AV_DEBUG IN VARCHAR2, --1����
                        AV_OUT   OUT VARCHAR2, --������Ϣ
                        AV_RES   OUT VARCHAR2, --��������
                        AV_MSG   OUT VARCHAR2 --����������Ϣ
                        );

  PROCEDURE P_PERSONAL_APPLY(AV_IN    IN VARCHAR2, --�������
                             AV_DEBUG IN VARCHAR2, --1����
                             AV_OUT   OUT VARCHAR2, --������Ϣ
                             AV_RES   OUT VARCHAR2, --��������
                             AV_MSG   OUT VARCHAR2 --����������Ϣ
                             );

  /*=======================================================================================*/
  --������
  --av_in: 1����
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
  PROCEDURE P_OPENACCANDCARD(AV_IN    IN VARCHAR2, --�������
                             AV_DEBUG IN VARCHAR2, --1����
                             AV_RES   OUT VARCHAR2, --��������
                             AV_MSG   OUT VARCHAR2 --����������Ϣ
                             );

  PROCEDURE P_SMZ_KFF(AV_IN  VARCHAR2, --������Ϣ
                      AV_RES OUT VARCHAR2, --������������
                      AV_MSG OUT VARCHAR2, --��������������Ϣ
                      AV_OUT OUT VARCHAR2);

  --�ж����������
  --av_acpt_id �������
  --av_acpt_type���������
  --av_oper_id ����Ա���
  --av_sys_users ����Ա��Ϣ
  --av_base_co_org ����������Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_JUDGE_ACPT(AV_ACPT_ID     VARCHAR2,
                         AV_ACPT_TYPE   VARCHAR2,
                         AV_OPER_ID     VARCHAR2,
                         AV_SYS_USERS   OUT SYS_USERS%ROWTYPE,
                         AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE,
                         AV_RES         OUT VARCHAR2,
                         AV_MSG         OUT VARCHAR2);

  PROCEDURE P_BATCH_KFF(AV_IN  IN VARCHAR2,
                        AV_RES OUT VARCHAR2,
                        AV_MSG OUT VARCHAR2);

  PROCEDURE P_UNDO_SMZ_KFF(AV_IN  VARCHAR2,
                           AV_RES OUT VARCHAR2,
                           AV_MSG OUT VARCHAR2,
                           AV_OUT OUT VARCHAR2);

  PROCEDURE P_GETCARDAPPLYBYCARDNO(AV_CARD_NO    CARD_APPLY.CARD_NO%TYPE,
                                   AV_CARD_APPLY OUT CARD_APPLY%ROWTYPE,
                                   AV_RES        OUT VARCHAR2,
                                   AV_MSG        OUT VARCHAR2);
  --���ݿ��Ż�ȡ����Ϣ
  PROCEDURE P_GET_CARD_BASEINFO(
                                AV_CARD_NO CARD_BASEINFO.CARD_NO%TYPE,
                                AV_CARD_BASEINFO OUT CARD_BASEINFO%ROWTYPE,
                                AV_RES OUT VARCHAR2,
                                AV_MSG OUT VARCHAR2
                               );

  --����֤�������ȡ��Ա��Ϣ
  --av_cert_no �ͻ����
  --av_base_personal ��Ա��Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_GET_BASE_PERSONAL(AV_CERT_NO   BASE_PERSONAL.CERT_NO%TYPE,
                                AV_BASE_PERSONAL OUT BASE_PERSONAL%ROWTYPE,
                                AV_RES           OUT VARCHAR2,
                                AV_MSG           OUT VARCHAR2);

  --��ȡ�����п���Ϣ
  PROCEDURE P_GET_BIND_BANKCARD(AV_CARD_NO CARD_BASEINFO.SUB_CARD_NO%TYPE,
                                AV_CARD_BIND_BANKCARD OUT CARD_BIND_BANKCARD%ROWTYPE,
                                AV_RES           OUT VARCHAR2,
                                AV_MSG           OUT VARCHAR2);
  --���ݿͻ���Ż�ȡ��Ա��Ϣ
  --av_customer_id �ͻ����
  --av_base_personal ��Ա��Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_GETBASEPERSONALBYCUSTOMERID(AV_CUSTOMER_ID   BASE_PERSONAL.CUSTOMER_ID%TYPE,
                                          AV_BASE_PERSONAL OUT BASE_PERSONAL%ROWTYPE,
                                          AV_RES           OUT VARCHAR2,
                                          AV_MSG           OUT VARCHAR2);

  --���ݿ����ͻ�ȡ������������Ϣ
  --av_card_type ������
  --av_card_config ������������Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE P_GETCARDCONFIGBYCARDTYPE(AV_CARD_TYPE   CARD_CONFIG.CARD_TYPE%TYPE,
                                      AV_CARD_CONFIG OUT CARD_CONFIG%ROWTYPE,
                                      AV_RES         OUT VARCHAR2,
                                      AV_MSG         OUT VARCHAR2);

  PROCEDURE P_APPLY_BANK_SH(AV_IN  VARCHAR2,
                            AV_RES OUT VARCHAR2,
                            AV_MSG OUT VARCHAR2);

  --���쳷��
  --av_in
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
  PROCEDURE p_Apply_Cancel(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2,av_out OUT VARCHAR2);
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
  procedure p_card_recovery(av_in varchar2,av_res out varchar2,av_msg out varchar2,av_out out varchar2);
END PK_CARD_APPLY_ISSUSE;
/

