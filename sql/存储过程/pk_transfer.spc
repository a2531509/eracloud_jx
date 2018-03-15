CREATE OR REPLACE PACKAGE pk_transfer IS
  -- Purpose : ת��
  /*=======================================================================================*/
  --ת��
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --      5acpt_id        �������(����Ż��̻����)
  --      6tr_batch_no    ���κ�
  --      7term_tr_no     �ն˽�����ˮ��
  --      8card_no1       ת������
  --      9card_tr_count1 ת�������׼�����
  --      10card_bal1     ת����Ǯ������ǰ���
  --      11acc_kind1     ת�����˻�����
  --      12wallet_id1    ת����Ǯ����� Ĭ��00
  --      13card_no2      ת�뿨��
  --      14card_tr_count2ת�뿨���׼�����
  --      15card_bal2     ת�뿨Ǯ������ǰ���
  --      16acc_kind2     ת�뿨�˻�����
  --      17wallet_id2    ת�뿨Ǯ����� Ĭ��00
  --      18tr_amt        ת�˽��  nullʱת�����н��
  --      19note          ��ע
  /*=======================================================================================*/
  PROCEDURE p_transfer(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2 --����������Ϣ
                       );
  /*=======================================================================================*/
  --ת��ȷ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7ת����ȷ��ǰ���˻��������|8ת�뿨ȷ��ǰ���˻��������|9ת����ת�˺�������|10ת�뿨ת�˺�������
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm_onerow(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1д������־
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2 --����������Ϣ
                              );
  /*=======================================================================================*/
  --ת��ȷ��
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7card_no1|8card_no2
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1д������־
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2 --����������Ϣ
                              );
  /*=======================================================================================*/
  --ת�˳���
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no        �˻���ˮ��
  --       6clr_date          д�Ҽ�¼ʱ���������
  --       7acc_bal1         ת��������ǰ�˻����
  --       8acc_bal2         ת�뿨����ǰ�˻����
  --       9card_tr_count1   ת���������׼�����
  --      10card_tr_count2   ת�뿨�����׼�����
  --      11card_bal1        ת����Ǯ������ǰ���
  --      12card_bal2        ת�뿨Ǯ������ǰ���
  --      13encrypt1      ת����ת�˺�������
  --      14encrypt2      ת�뿨ת�˺�������
  /*=======================================================================================*/
  PROCEDURE p_transfercancel_onerow(av_in    IN VARCHAR2, --�������
                                    av_debug IN VARCHAR2, --1д������־
                                    av_res   OUT VARCHAR2, --��������
                                    av_msg   OUT VARCHAR2 --����������Ϣ
                                    );
  /*=======================================================================================*/
  --ת�˳���
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7tr_state|8card_no1|9card_no2|
  --       10card_tr_count1|11card_tr_count2|12card_bal1|13card_bal2
  /*=======================================================================================*/
  PROCEDURE p_transfercancel(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1д������־
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             );
END pk_transfer;
/

