CREATE OR REPLACE PACKAGE PK_SERVICE_OUTER IS
  -- AUTHOR  : ADMINISTRATOR
  -- CREATED : 2016-02-18 15:42:24
  -- PURPOSE : ��Χ���ýӿ�

  -- PUBLIC TYPE DECLARATIONS
  -- ���ͣ��������岿��

  -- PUBLIC FUNCTION AND PROCEDURE DECLARATIONS
  -- ���̣��������岿��

  --��������������ж�
  PROCEDURE P_JUDGE_ACPT(AV_ACPT_ID     VARCHAR2, --���������
                         AV_ACPT_TYPE   VARCHAR2, --�������/������
                         AV_USER_ID     VARCHAR2, --�ն˺�/����Ա
                         AV_SYS_USERS   OUT SYS_USERS%ROWTYPE,
                         AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE,
                         AV_RES         OUT VARCHAR2, --�������
                         AV_MSG         OUT VARCHAR2 --��������������Ϣ
                         );
  --���˵�¼
  PROCEDURE P_LOGIN_GR(AV_CARD_NO VARCHAR2, --����
                       AV_CERT_NO VARCHAR2, --֤������
                       AV_TELNO   VARCHAR2, --�ֻ�����
                       AV_PWD     VARCHAR2, --��¼����
                        AV_CERTNO  OUT VARCHAR2,--֤����
                       AV_RES     OUT VARCHAR2, --����������
                       AV_MSG     OUT VARCHAR2 --������˵��
                       );

  --����������¼
  PROCEDURE P_LOGIN_CO_ORG(AV_CO_ORG_ID VARCHAR2, --�����������
                           AV_PWD       VARCHAR2, --����
                           AV_RES       OUT VARCHAR2, --�������
                           AV_MSG       OUT VARCHAR2); --���˵��

  --�����޸�
  --1acpt_id �������
  --2acpt_type ���������
  --3oper_id ����Ա
  --4trim_no �ն�ҵ����ˮ
  --5cert_no ֤������
  --6card_no ����
  --7pwd_type ��������
  --8old_pwd ������
  --9pwd ������
  --10agt_cert_type ������֤������
  --11agt_cert_type ������֤������
  --12agt_name ����������
  --13agt_telno �����˵绰����
  PROCEDURE P_PWD_MODIFY(AV_IN  VARCHAR2,
                         AV_RES OUT VARCHAR2,
                         AV_MSG OUT VARCHAR2);

  -- ��ʧ
  -- 1�������/������ brch_id/acpt_id ����
  -- 2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  -- 3�ն˱��/��Ա��� user_id/end_id ����
  -- 4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  -- 5֤������ cert_no
  -- 6���� card_no
  -- 7��ʧ���� loss_type  2�ڹҹ�ʧ  3 �����ʧ
  -- 8������֤������
  -- 9������֤������
  -- 10����������
  -- 11��������ϵ�绰
  -- 12��עnote
  -- ���ؽ��
  -- av_res ���ؽ������
  -- av_msg ���ؽ��˵��
  -- av_out ������
  -- ����  10011001|1|admin||4128222198605264479||3|||||test|
  PROCEDURE p_Card_Loss(av_in  VARCHAR2,
                        av_res OUT VARCHAR2,
                        av_msg OUT VARCHAR2,
                        av_out OUT VARCHAR2);

  -- ���
  -- 1�������/������ brch_id/acpt_id ����
  -- 2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  -- 3�ն˱��/��Ա��� user_id/end_id ����
  -- 4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  -- 5֤������ cert_no
  -- 6���� card_no
  -- 7������֤������
  -- 8������֤������
  -- 9����������
  -- 10��������ϵ�绰
  -- 11��עnote
  -- ���ؽ��
  -- av_res ���ؽ������
  -- av_msg ���ؽ��˵��
  -- av_out ������
  PROCEDURE p_Card_Unlock(av_in  VARCHAR2,
                          av_res OUT VARCHAR2,
                          av_msg OUT VARCHAR2,
                          av_out OUT VARCHAR2);

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
  PROCEDURE P_CARDTRANS(AV_IN    IN VARCHAR2, --�������
                        AV_DEBUG IN VARCHAR2, --1����
                        AV_OUT   OUT VARCHAR2, --������Ϣ
                        AV_RES   OUT VARCHAR2, --��������
                        AV_MSG   OUT VARCHAR2 --����������Ϣ
                        );

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
  PROCEDURE P_LOCAL_MAKECARD_REG(AV_IN IN VARCHAR2,AV_RES OUT VARCHAR2,AV_MSG OUT VARCHAR2);

  --����תǮ���ǻҼ�¼
  PROCEDURE P_BHK_ZZ_TJ(AV_IN  VARCHAR2,
                        AV_OUT OUT VARCHAR2,
                        AV_RES OUT VARCHAR2,
                        AV_MSG OUT VARCHAR2);

  --����תǮ���Ҽ�¼ȷ��
  PROCEDURE P_BHK_ZZ_TJ_CONFIRM(AV_IN  VARCHAR2,
                                AV_RES OUT VARCHAR2,
                                AV_MSG OUT VARCHAR2);
  --����תǮ���Ҽ�¼ȡ��
  PROCEDURE P_BHKZZ_TJ_CANCEL(AV_DEAL_NO VARCHAR2, --ҵ����ˮ
                              AV_RES     OUT VARCHAR2, --����������
                              AV_MSG     OUT VARCHAR2 --����������
                              );

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
  PROCEDURE P_BANK_KFF(AV_IN VARCHAR2,AV_RES OUT VARCHAR2,AV_MSG OUT VARCHAR2,AV_OUT OUT VARCHAR2);

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
  PROCEDURE P_BANK_ZX(AV_IN  VARCHAR2,
                      AV_RES OUT VARCHAR2,
                      AV_MSG OUT VARCHAR2);
  --���˽�����Ϣ��ѯ
  PROCEDURE P_CONSUME_RECHARGE_QUERY(AV_CARD_NO    VARCHAR2, --����
                                     AV_DEAL_TYPE  VARCHAR2, --��ѯ�������� 0 ��ѯ���� 1 ��ѯ��ֵ  2 ��ѯ����
                                     AV_ACC_KIND   VARCHAR2, --�˻�����
                                     AV_START_DATE VARCHAR2, --��ѯ��ʼ����
                                     AV_END_DATE   VARCHAR2, --��ѯ��������
                                     AV_PAGE_NO    NUMBER, --�ڼ�ҳ
                                     AV_PCOUNT     NUMBER, --ÿҳ������
                                     AV_ORDERBY    VARCHAR2, --�����ֶ�
                                     AV_ORDER      VARCHAR2, --˳�� asc ����  desc ����
                                     AV_ALL_SIZE   OUT NUMBER,
                                     AV_ALL_PAGE   OUT NUMBER,
                                     AV_DATA       OUT ZPAGE.DEFAULT_CURSOR, --�������
                                     AV_RES        OUT VARCHAR2, --����������
                                     AV_MSG        OUT VARCHAR2 --������˵��
                                     );

  --����9λ���籣�����Ż�ȡ20λ�ǽӿ���
  FUNCTION F_GETCARDNO_BY_SUBCARDNO(AV_SUB_CARD_NO VARCHAR2, --�籣������
                                    AV_CARD_APPLY  OUT CARD_APPLY%ROWTYPE)
    RETURN VARCHAR2;

  --�������п����Ż�ȡ��Ӧ�Ŀ�����Ϣ
  --�������п����Ż�ȡ��Ӧ�Ŀ�����Ϣ
  procedure p_getBcpCard(av_bank_card_no card_task_imp_bcp.bank_card_no%type,
                         lv_card_task_bcp out card_task_imp_bcp%rowtype,
                         av_res out varchar2,
                         av_msg out varchar2);
  --����������
  PROCEDURE P_CARD_BLACK(AV_DEAL_NO   CARD_BLACK_REC.DEAL_NO%TYPE, --ҵ����ˮ
                         AV_CARD_NO   CARD_BASEINFO.CARD_NO%TYPE, --�����������Ŀ�
                         AV_STL_STATE VARCHAR2, --����������״̬  0 ���Ӻ�����  1 ��ȥ������
                         AV_STL_TYPE  VARCHAR2, --��AV_STL_STATE = 0 ���Ӻ�����ʱ ��Ҫ���ݺ��������� 01 ���� 02 ���� 09 ע��
                         AV_DEAL_TIME VARCHAR2, --����ʱ��  ��ʽ��YYYYMMDDHH24MISS
                         AV_RES       OUT VARCHAR2,
                         AV_MSG       OUT VARCHAR2);

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
  PROCEDURE p_applyCard(av_in    IN VARCHAR2, --�������
                        av_debug IN VARCHAR2, --1����
                        av_out   OUT VARCHAR2, --������Ϣ
                        av_res   OUT VARCHAR2, --��������
                        av_msg   OUT VARCHAR2 --����������Ϣ
                        );

  --������ ���ý���
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
  PROCEDURE p_openAccandCard(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             );
  --���¸�����Ϣ
  --av_in: 1֤������
  --       2�ֻ���
  --       3��ͥסַ
  --       4��ͥ��ϵ�绰
  --       5��Ա��
  --       6΢�ź�

  PROCEDURE p_updatePersonalInfo(av_in    IN VARCHAR2, --�������
                                 av_debug IN VARCHAR2, --1����
                                 av_res   OUT VARCHAR2, --��������
                                 av_msg   OUT VARCHAR2 --����������Ϣ
                                 );
  --���º���������Ϣ
  -- av_in:1�����������
  --       2����סַ
  --       3������ϵ�绰
  --       4��Ա��

  PROCEDURE p_update_Co_Org(av_in    IN VARCHAR2, --�������
                                 av_debug IN VARCHAR2, --1����
                                 av_res   OUT VARCHAR2, --��������
                                 av_msg   OUT VARCHAR2 --����������Ϣ
                                 );
  --�����������������޸�
  --1��bizid ����������
  --2��oper_id ����Ա
  --3��old_pwd ������
  --4��new_pwd ������
  PROCEDURE P_Update_Co_Org_Pwd(AV_IN  VARCHAR2,
                         AV_RES OUT VARCHAR2,
                         AV_MSG OUT VARCHAR2);
    --��������������Ϣ��ѯ
  PROCEDURE P_Co_Org_Query(AV_Co_org_Id    VARCHAR2, --�������
                           AV_DEAL_TYPE  VARCHAR2, --��ѯ�������� 0 ��ѯ���� 1 ��ѯ��ֵ  2 ��ѯ����
                           AV_ITEM_NO   VARCHAR2, --��Ŀ����
                           AV_START_DATE VARCHAR2, --��ѯ��ʼ����
                           AV_END_DATE   VARCHAR2, --��ѯ��������
                           AV_PAGE_NO    NUMBER, --�ڼ�ҳ
                           AV_PCOUNT     NUMBER, --ÿҳ������
                           AV_ORDERBY    VARCHAR2, --�����ֶ�
                           AV_ORDER      VARCHAR2, --˳�� asc ����  desc ����
                           AV_ALL_SIZE   OUT NUMBER,
                           AV_ALL_PAGE   OUT NUMBER,
                           AV_DATA       OUT ZPAGE.DEFAULT_CURSOR, --�������
                           AV_RES        OUT VARCHAR2, --����������
                           AV_MSG        OUT VARCHAR2 --������˵��
                           );

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

  PROCEDURE p_Entering_Insure(av_in    IN VARCHAR2, --�������
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             );

  --�������
  --1��AV_CARDBASEINFO --����Ϣ
  --2��AV_BASEPERSON --��Ա��Ϣ
  --3��AV_SYSACTIONLOG ��־��Ϣ
  --4��AV_SMS_TYPE �������� 01����02��ֵ03����04Ȧ�� 99�Զ������
  --5:AV_AMT ���
  PROCEDURE p_Save_Message(AV_CARDBASEINFO  IN card_baseinfo%ROWTYPE, --����Ϣ
                          AV_BASEPERSON     IN base_personal%ROWTYPE, --��Ա��Ϣ
                          AV_SYSACTIONLOG IN SYS_ACTION_LOG%ROWTYPE, --��־��Ϣ
                          AV_SMS_TYPE     IN VARCHAR2, --�������� 01����02��ֵ03����04Ȧ�� 99�Զ������
                          AV_AMT          IN INTEGER, --���
                          av_res   OUT VARCHAR2, --��������
                          av_msg   OUT VARCHAR2);--����������Ϣ
END PK_SERVICE_OUTER;
/

