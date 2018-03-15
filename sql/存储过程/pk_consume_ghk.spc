CREATE OR REPLACE PACKAGE pk_consume_ghk IS
  -- Purpose : ����

  /*=======================================================================================*/
  --��������_�жϿ����Ƿ�׼������

  --merchantid IN VARCHAR2,--�̻����
  --cardno     IN VARCHAR2,--����
  --sqn_mode   IN varchar2,--�̻�����ģʽmerchantid      �̻���

  /*=======================================================================================*/

  PROCEDURE p_checkIDinfo(merchantid IN VARCHAR2,--�̻����
                          cardno     IN VARCHAR2,--����
                          sqn_mode   IN VARCHAR2,--�̻�����ģʽ
                          av_sqn_mode OUT pay_acctype_sqn%ROWTYPE,--��������ģʽ
                          av_res      OUT VARCHAR2, --��������
                          av_msg      OUT VARCHAR2 --����������Ϣ
    );
  /*=======================================================================================*/
  --��������_����
  --av_in: ���ֶ���|�ָ�
  --       1tr_code    ���״���
  --       2card_no    ����
  --       3tr_amt     ���ѽ��
  --       4mode_no    ����ģʽ
  --av_out: �˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --�������
                                 av_res OUT VARCHAR2, --��������
                                 av_msg OUT VARCHAR2, --����������Ϣ
                                 av_out OUT VARCHAR2, --��������
                                 av_cash_amt OUT VARCHAR2--�ֽ𸶿���
                                 );
  /*=======================================================================================*/
  --��������
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ҵ����ˮ��--�յĻ�ȡ�洢������ȡ����
  --       2tr_code      ������
  --       3oper_id      ����Ա/�ն˺�
  --       4oper_time    ����ʱ��--�յĻ�ȡ�洢������ȡ���ݿ�ʱ��
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9pwd          ����
  --      10tr_amt       �ܽ��׽��
  --      11acclist      �˻��б� acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12note         ��ע
  --      13acpt_type    ��������
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume(av_in    IN VARCHAR2, --�������
                            av_debug IN VARCHAR2, --1����
                            av_res   OUT VARCHAR2, --��������
                            av_msg   OUT VARCHAR2, --����������Ϣ
                            av_out   OUT VARCHAR2 --��������
                            );
  /*=======================================================================================*/
  --�������ѳ���_����
  --av_in: ���ֶ���|�ָ�
  --       1acpt_id      �������(����Ż��̻����)
  --       2oper_id      ����Ա/�ն˺�
  --       3tr_batch_no  ���κ�
  --       4term_tr_no   �ն˽�����ˮ��
  --       5card_no      ����
  --av_out: ԭ����action_no|ԭ����clr_date|�˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel_calc(av_in  IN VARCHAR2, --�������
                                       av_res OUT VARCHAR2, --��������
                                       av_msg OUT VARCHAR2, --����������Ϣ
                                       av_out OUT VARCHAR2 --��������
                                       );
  /*=======================================================================================*/
  --�������ѳ���_����
  --av_in: ���ֶ���|�ָ�
  --       1acpt_id      �������(����Ż��̻����)
  --       2oper_id      ����Ա/�ն˺�
  --       3tr_batch_no  ���κ�
  --       4action_no   �ն˽�����ˮ��
  --       5camt      ����
  --av_out: ԭ����action_no|ԭ����clr_date|�˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumeundo_calc(av_in  IN VARCHAR2, --�������
                                       av_res OUT VARCHAR2, --��������
                                       av_msg OUT VARCHAR2, --����������Ϣ
                                       av_out OUT VARCHAR2 --��������
                                       );
  /*=======================================================================================*/
  --�������ѳ���
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ҵ����ˮ��
  --       2tr_code      ������
  --       3oper_id      ����Ա/�ն˺�
  --       4oper_time    ����ʱ��
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --      10tr_amt       �ܽ��׽��
  --      11acclist      �˻��б� acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12action_no    ��������action_no
  --      13clr_date     ��������¼��clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel(av_in    IN VARCHAR2, --�������
                                  av_debug IN VARCHAR2, --1����
                                  av_res   OUT VARCHAR2, --��������
                                  av_msg   OUT VARCHAR2, --����������Ϣ
                                  av_out   OUT VARCHAR2 --��������
                                  );

  procedure p_uniondkdskqrorcancel(av_db_acc_no        in varchar2, --�跽�˻�
                       av_cr_acc_no        in varchar2, --�����˻�
                       av_dbcardbal        number, --�跽����ǰ������
                       av_crcardbal        number, --��������ǰ������
                       av_dbcardcounter    NUMBER, --�跽��Ƭ���׼�����
                       av_crcardcounter    NUMBER, --������Ƭ���׼�����
                       av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                       av_crbalanceencrypt IN VARCHAR2, --�����������
                       av_tramt            acc_inout_detail.db_amt%TYPE, --���׽��
                       av_credit           acc_inout_detail.db_credit_amt%TYPE, --���÷�����
                       av_accbookno        acc_inout_detail.acc_inout_no%TYPE, --������ˮ��
                       av_trcode           acc_inout_detail.deal_code%TYPE, --���״���
                       av_issueorgid       acc_inout_detail.card_org_id%TYPE, --��������
                       av_orgid            acc_inout_detail.acpt_org_id%TYPE, --�������
                       av_acpttype         acc_inout_detail.acpt_type%TYPE, --��������
                       av_acptid           acc_inout_detail.acpt_id%TYPE, --��������(�����/�̻��ŵ�)
                       av_operid           acc_inout_detail.user_id%TYPE, --������Ա/�ն˺�
                       av_trbatchno        acc_inout_detail.deal_batch_no%TYPE, --�������κ�
                       av_termtrno         acc_inout_detail.end_deal_no%TYPE, --�ն˽�����ˮ��
                       av_trdate_str       varchar2, --����ʱ��
                       av_trstate          acc_inout_detail.deal_state%TYPE, --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                       av_actionno         acc_inout_detail.deal_no%TYPE, --ҵ����ˮ��
                       av_note             acc_inout_detail.note%TYPE, --��ע
                       av_clrdate          pay_clr_para.clr_date%TYPE, --�������
                       av_otherin          VARCHAR2 DEFAULT NULL, --����������� �˻�ʱ����ԭacc_book_no
                       av_debug            IN VARCHAR2, --1����
                       av_res              OUT VARCHAR2, --������������
                       av_msg              OUT VARCHAR2 --��������������Ϣ
                       );


END pk_consume_ghk;
/

