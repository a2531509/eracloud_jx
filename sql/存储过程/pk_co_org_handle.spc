create or replace package pk_co_org_handle is

  -- Author  : ADMINISTRATOR
  -- Created : 2015/7/23 13:54:39
  -- Purpose : ������������ش���

  /*=======================================================================================*/
  --��һ��������������
  /*=======================================================================================*/
  PROCEDURE p_settle(av_co_org_id  IN base_co_org.co_org_id%TYPE, --������
                     av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     );

  /*=======================================================================================*/
  --�����к����ṹ���н���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     );

  /*=======================================================================================*/
  --�����к����������н����job
  /*=======================================================================================*/
  PROCEDURE p_job;

  /*=======================================================================================*/
  --���������������
  /*=======================================================================================*/
  PROCEDURE p_settlerollback(av_stlsumno IN stl_co_deal_sum.stl_sum_no%TYPE, --������������������
                             av_res      OUT VARCHAR2, --��������
                             av_msg      OUT VARCHAR2 --����������Ϣ
                             );


  /*=======================================================================================*/
  --������������
  /*=======================================================================================*/
 PROCEDURE p_check_bill(av_co_org_id IN base_co_org.co_org_id%TYPE, --�����������
                               av_acpt_id   IN VARCHAR2,--�������
                               av_batch_id  IN VARCHAR2,--���κ�
                               av_end_id    IN VARCHAR2,--�ն˺�/��Ա��
                               av_check_type IN VARCHAR2,--�������� 01 ��ֵ 02 ����
                               av_check_filenmae IN VARCHAR2, --�����ļ���
                               av_check_date IN VARCHAR2, --��������yyyymm
                               av_check_zc_sum  IN NUMBER,--���������ܱ���
                               av_check_zc_amt  IN NUMBER,--���������ܽ��
                               --av_check_cx_sum  IN NUMBER,--���˳�������
                               --av_check_cx_amt  IN NUMBER,--���˳������
                               av_check_th_sum  IN NUMBER,--�����˻�����
                               av_check_th_amt  IN NUMBER,--�����˻����
                               av_res      OUT VARCHAR2, --��������
                               av_msg      OUT VARCHAR2 --����������Ϣ
                             );
 /*=======================================================================================*/
  --��������������ϸ���
  /*=======================================================================================*/

  procedure p_check_bill_implist(av_co_org_id IN base_co_org.co_org_id%TYPE, --�����������
                       av_acpt_id IN VARCHAR2, --����������
                       av_termid in varchar2,--�ն˺�/��Ա��
                       av_trbatchno in varchar2,--���κ�
                       av_trserno in varchar2,--�ն���ˮ
                       av_cardno in varchar2,-- ����
                       av_bank_id in varchar2,--���б��
                       av_bank_acc in varchar2,--�����˻�
                       av_cr_card_no in varchar2,--ת�뿨����
                       av_cr_acc_kind in varchar2,--ת���˻�����
                       av_db_card_no in varchar2,--ת��������
                       av_db_acc_kind in varchar2,--ת���˻�����
                       av_acc_bal in varchar2,--���׽��
                       av_deal_count in varchar2,--�������
                       av_tramt  in number,--���׽��
                       av_trdate in varchar2,--yyyy-mm-dd hh24:mi:ss
                       av_actionno in number,--ҵ����ˮ��
                       av_clrdate in varchar2,--yyyy-mm-dd
                       av_co_clrdate in varchar2, --yyyy-mm-dd
                       av_file_line in varchar2,--�ļ��к�
                       av_deal_code IN VARCHAR2,-- ���״���
                       av_res      OUT VARCHAR2, --��������
                       av_msg      OUT VARCHAR2 --����������Ϣ
                       );


 /*=======================================================================================*/
  --��������������ϸ����
  /*=======================================================================================*/

  PROCEDURE  p_check_list_bill(av_co_org_id  IN base_co_org.co_org_id%TYPE,--��������
                               av_acpt_id   IN VARCHAR2,--����������
                               av_clr_date IN VARCHAR2,--��������
                               av_res      OUT VARCHAR2, --��������
                               av_msg      OUT VARCHAR2 --����������Ϣ
                               );
end pk_co_org_handle;
/

