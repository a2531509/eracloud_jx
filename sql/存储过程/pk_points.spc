CREATE OR REPLACE PACKAGE pk_points IS
  -- Purpose : ����
  /*=======================================================================================*/
  --���ֶһ�
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --      5acpt_id        �������(����Ż��̻����)
  --      6tr_batch_no    ���κ�
  --      7term_tr_no     �ն˽�����ˮ��
  --      8card_no        ����
  --      9tr_amt         �һ��Ļ�����
  --      10type          �һ����� 1�һ���δȦ���˻�2�һ���Ʒ3���ֵ��ڿۼ�
  --      11note          ��ע
  /*=======================================================================================*/
  PROCEDURE p_exchange(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2, --����������Ϣ
                       av_out   OUT VARCHAR2 --��������
                       );
  /*=======================================================================================*/
  --���ֶһ�����
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no ԭ��¼��action_no
  --       6clr_date  ԭ��¼���������
  --       7card_no   ����
  --       8encrypt   ������δȦ���˻��������
  /*=======================================================================================*/
  PROCEDURE p_exchangecancel(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2, --����������Ϣ
                             av_out   OUT VARCHAR2 --��������
                             );
  /*=======================================================================================*/
  --��������
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id        �������(����Ż��̻����)
  --       6tr_batch_no    ���κ�
  --       7term_tr_no     �ն˽�����ˮ��
  --       8card_no        ����
  --       9tr_amt         ���ӵĻ�����
  --      10type           �������ӵ�;��
  --      11note           ��ע
  /*=======================================================================================*/
  PROCEDURE p_generate(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2, --����������Ϣ
                       av_out   OUT VARCHAR2 --��������
                       );
  /*=======================================================================================*/
  --�����������ȡ�������ں�ʧЧ����
  /*=======================================================================================*/
  PROCEDURE p_getpointsperiod(av_clrdate      IN VARCHAR2, --�������
                              av_period_name  OUT VARCHAR2, --����˵������2014-01-01(��)��2014-01(��)��2014(��)
                              av_invalid_date OUT VARCHAR2, --����ʧЧ����
                              av_res          OUT VARCHAR2, --��������
                              av_msg          OUT VARCHAR2 --����������Ϣ
                              );
  /*=======================================================================================*/
  --��������
  /*=======================================================================================*/
  PROCEDURE p_generate(av_dbsubledger IN acc_account_sub%ROWTYPE, --���ֽ跽�ֻ���
                       av_cardno      IN VARCHAR2, --����
                       av_amt         IN NUMBER, --����
                       av_trcode      IN VARCHAR2, --���״���
                       av_orgid       IN VARCHAR2, --����������
                       av_brchid      IN VARCHAR2, --��������(�����/�̻��ŵ�)
                       av_operid      IN VARCHAR2, --������Ա/�ն˺�
                       av_trbatchno   IN VARCHAR2, --�������κ�
                       av_termtrno    IN VARCHAR2, --�ն˽�����ˮ��
                       av_actionno    IN NUMBER, --ҵ����ˮ��
                       av_note        IN VARCHAR2, --��ע
                       av_clrdate     IN VARCHAR2, --�������
                       av_debug       IN VARCHAR2, --1����
                       av_res         OUT VARCHAR2, --��������
                       av_msg         OUT VARCHAR2 --����������Ϣ
                       );
  /*=======================================================================================*/
  --������������ (ֻ���»��ֹ��ɱ��˻�����ˮ������ͳһ����)
  /*=======================================================================================*/
  PROCEDURE p_generatecancel(av_cardno  IN VARCHAR2, --����
                             av_amt     IN NUMBER, --����
                             av_clrdate IN VARCHAR2, --�������
                             av_res     OUT VARCHAR2, --��������
                             av_msg     OUT VARCHAR2 --����������Ϣ
                             );
END pk_points;
/

