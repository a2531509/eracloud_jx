CREATE OR REPLACE PACKAGE pk_statistic IS
  -- Purpose : ͳ��

  /*=======================================================================================*/
  --�������˻�����tr_day_bal_base����ͳ�Ƶ��������ݱ���tr_day_bal_data
  /*=======================================================================================*/
  PROCEDURE p_daybal_data(av_clrdate        varchar2, --�������
                          av_daybal_type    IN varchar2, --1��Ա��2���㣬3����
                          av_daybal_ownerid IN VARCHAR2, --����������
                          av_actionno       in number, --ҵ����ˮ��
                          av_debug          IN VARCHAR2, --1����
                          av_res            OUT VARCHAR2, --������������
                          av_msg            OUT VARCHAR2 --��������������Ϣ
                          );
  /*=======================================================================================*/
  --���� �������ݵ� tr_day_bal_base������ٻ��ܵ�tr_day_bal_data����
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5clr_date|6daybal_type|7daybal_owner_id
  --daybal_type:1���ˣ�2����(�ȸ���������)��3����(���к󴥷�����������Ӫҵ����Ļ�������)
  /*=======================================================================================*/
  PROCEDURE p_daybal(av_in    IN VARCHAR2, --�������
                     av_debug IN VARCHAR2, --1����
                     av_res   OUT VARCHAR2, --������������
                     av_msg   OUT VARCHAR2 --��������������Ϣ
                     );
  /*=======================================================================================*/
  --����ֹʱ�������������˻������ݱ�tr_day_bal_base
  --as_orgid������ָ�������������л���[as_orgΪ��ʱ]�������㡢��Ա����
  /*=======================================================================================*/
  PROCEDURE p_batch_daybal(as_start_date varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                           as_end_date   varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                           as_orgid      sys_organ.org_id%type, --Ϊ��ʱͳ�����л���
                           av_actionno   in number, --ҵ����ˮ��
                           av_debug      IN VARCHAR2, --1����
                           av_res        OUT VARCHAR2, --������������
                           av_msg        OUT VARCHAR2 --��������������Ϣ
                           );
  /*=======================================================================================*/
  --����ֹʱ�����������������ݱ�tr_day_bal_data��ǰ����tr_day_base�����Ѿ�����
  --av_daybal_typeΪ1��Ա�����ɹ�Ա���ݣ�2���㣺�������㡢��Ա���ݣ�3���������ɻ��������㡢��Ա����
  /*=======================================================================================*/
  PROCEDURE p_batch_daybal_data(as_start_date     varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                as_end_date       varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                av_daybal_type    varchar2, --1��Ա��2���㣬3����
                                av_daybal_ownerid IN VARCHAR2, --����������
                                av_actionno       in number, --ҵ����ˮ��
                                av_debug          IN VARCHAR2, --1����
                                av_res            OUT VARCHAR2, --������������
                                av_msg            OUT VARCHAR2 --��������������Ϣ
                                );
  /*=======================================================================================*/
  --��ֵ����ͳ�ƣ����������ͳ���˻���ˮ���¼��stat_charge_consume����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_stat_charge_consume(av_clrdate varchar2, --�������
                                  av_orgid   sys_organ.org_id%type, --������Ϊ��ʱͳ�����л���
                                  av_debug   IN VARCHAR2, --����0�ǣ�1��
                                  av_res     OUT VARCHAR2, --������������
                                  av_msg     OUT VARCHAR2 --��������������Ϣ
                                  );
  /*=======================================================================================*/
  --�����ֹ����ɳ�ֵ����ͳ�ƣ����������ͳ���˻���ˮ���¼��stat_charge_consume����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_batch_stat_charge_consume(av_start_date varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                        av_end_date   varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                        av_orgid      sys_organ.org_id%type, --������Ϊ��ʱͳ�����л���
                                        av_debug      IN VARCHAR2, --����0�ǣ�1��
                                        av_res        OUT VARCHAR2, --������������
                                        av_msg        OUT VARCHAR2 --��������������Ϣ
                                        );
  /*=======================================================================================*/
  --����ҵ��ͳ�ƣ����������ͳ���ۺ�ҵ����¼��stat_agent_busi����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_stat_agent_busi(av_clrdate varchar2, --�������
                              av_coorgid sys_organ.org_id%type, --����
                              av_debug   IN VARCHAR2, --����0�ǣ�1��
                              av_res     OUT VARCHAR2, --������������
                              av_msg     OUT VARCHAR2 --��������������Ϣ
                              );
  /*=======================================================================================*/
  --�����ֹ�ͳ�ƣ�����ҵ��ͳ�ƣ����������ͳ���ۺ�ҵ����¼��stat_agent_busi����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_batch_stat_agent_busi(av_start_date varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                    av_end_date   varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                    av_coorgid    sys_organ.org_id%type, --����
                                    av_debug      IN VARCHAR2, --����0�ǣ�1��
                                    av_res        OUT VARCHAR2, --������������
                                    av_msg        OUT VARCHAR2 --��������������Ϣ
                                    );
  /*=======================================================================================*/
  --�ֽ�ҵ��ͳ�ƣ�ֱ��ȡ�������ݱ�tr_day_bal_data�е�CASH_ITEM��Ӧ��ͳ����
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_stat_cash_busi(av_clrdate        varchar2, --�������
                             av_daybal_type    varchar2, --1��Ա��2���㣬3����
                             av_daybal_ownerid IN VARCHAR2, --����������
                             av_debug          IN VARCHAR2, --����0�ǣ�1��
                             av_res            OUT VARCHAR2, --������������
                             av_msg            OUT VARCHAR2 --��������������Ϣ
                             );
  /*=======================================================================================*/
  --�����ֹ�ͳ�ƣ��ֽ�ҵ��ͳ�ƣ�ֱ��ȡ�������ݱ�tr_day_bal_data�е�CASH_ITEM��Ӧ��ͳ����
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_batch_stat_cash_busi(as_start_date     varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                   as_end_date       varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                   av_daybal_type    varchar2, --1��Ա��2���㣬3����
                                   av_daybal_ownerid IN VARCHAR2, --����������
                                   av_debug          IN VARCHAR2, --����0�ǣ�1��
                                   av_res            OUT VARCHAR2, --������������
                                   av_msg            OUT VARCHAR2 --��������������Ϣ
                                   );

  /*=======================================================================================*/
  --�����ѻ����ݵĶ��˵���������ͳ��
  /*=======================================================================================*/
  procedure p_clr_offline_sum(av_biz_id   varchar2, --�̻���
                              av_clr_date varchar2, --�������
                              av_debug    IN VARCHAR2, --����0�ǣ�1��
                              av_res      OUT VARCHAR2, --������������
                              av_msg      OUT VARCHAR2 --��������������Ϣ
                              );

  /*=======================================================================================*/
  --�������ֵͳ��
  /*=======================================================================================*/
  procedure p_stat_readypay_sum(av_org_id   varchar2, --�̻���
                                av_clr_date varchar2, --�������
                                av_debug    IN VARCHAR2, --����0�ǣ�1��
                                av_res      OUT VARCHAR2, --������������
                                av_msg      OUT VARCHAR2 --��������������Ϣ
                                );
  /*=======================================================================================*/
  --����������ֵ����ͳ�ƣ�
  /*=======================================================================================*/
  procedure p_stat_charge_consume_co_org(av_clrdate   varchar2, --�������
                                         av_co_org_id base_co_org.co_org_id%type, --������Ϊ��ʱͳ�����л���
                                         av_debug     IN VARCHAR2, --����0�ǣ�1��
                                         av_res       OUT VARCHAR2, --������������
                                         av_msg       OUT VARCHAR2 --��������������Ϣ
                                         );
END pk_statistic;
/

