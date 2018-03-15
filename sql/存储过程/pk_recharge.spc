CREATE OR REPLACE PACKAGE pk_recharge IS
  -- Purpose : ��ֵ
  /*
  ����
    acc_sub_ledger �����ֶ� credit ��ʾ���ö�� ����֧��least(credit,greatest(0,credit-balance))
    acc_daybook    �����ֶ� db_credit,cr_credit,card_credit
    tr_card        �����ֶ�credit,card_credit
    �ֻ������0  ���ö��0
    1����ֵ100   �ֻ���balance 100 credit 0
                 ��ˮ db_amt 100 credit 0
    2�����ö�ȱ��200 �ֻ���balance 300 db_credit 200
                       ��ˮ  db_amt 200  db_credit 200
    3������50    �ֻ���balance250 credit 200
                 ��ˮ  db_amt 50  db_credit 0
    4������200   �ֻ���balance50  credit 200
                 ��ˮ  db_amt 200 db_credit 150
    5����ֵ300   �ֻ���balance350 credit 200
                 ��ˮ  db_amt 300 db_credit 150
    6�����ö�ȱ��300 �ֻ��� 450  credit 300
                       ��ˮdb_amt 300 db_credit 100
    6�����ö�ȱ��100 �ֻ��� 250  credit 100
                       ��ˮdb_amt -100 db_credit -200

  */

  /*=======================================================================================*/
  --��ֵд�Ҽ�¼
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9card_tr_count�����׼�����
  --      10card_bal     Ǯ������ǰ���
  --      11acc_kind     �˻�����
  --      12wallet_id    Ǯ����� Ĭ��00
  --      13tr_amt       ��ֵ���(�������ö��ʱ������ĺ�����ö��)
  --      14pay_source   ��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���
  --      15sourcecard   ��ֵ�����Ż����п�����
  --      16rechg_pwd    ��ֵ������
  --      17note         ��ע
  --      18tr_state     9д�Ҽ�¼0ֱ��д������¼
  --      19encrypt      ��ֵ���˻��������
  /*=======================================================================================*/
  PROCEDURE p_recharge(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1д������־
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2 --����������Ϣ
                       );
  /*=======================================================================================*/
  --��ֵȷ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7encryptȷ�Ϻ��˻��������|8ȷ��ǰ���˻��������
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm_onerow(av_in    IN VARCHAR2, --�������
                                     av_debug IN VARCHAR2, --1д������־
                                     av_res   OUT VARCHAR2, --��������
                                     av_msg   OUT VARCHAR2 --����������Ϣ
                                     );
  /*=======================================================================================*/
  --��ֵȷ��
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7card_no|8ȷ�Ϻ��˻��������
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1д������־
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2 --����������Ϣ
                              );
  /*=======================================================================================*/
  --��ֵ����
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7card_tr_count|8card_bal|9�������˻��������|10����ǰ���˻����
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel_onerow(av_in    IN VARCHAR2, --�������
                                    av_debug IN VARCHAR2, --1д������־
                                    av_res   OUT VARCHAR2, --��������
                                    av_msg   OUT VARCHAR2 --����������Ϣ
                                    );
  /*=======================================================================================*/
  --��ֵ����
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7card_no|8tr_state|9card_tr_count|10card_bal|11�������˻��������
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1д������־
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             );
  /*=======================================================================================*/
  --��ֵ������¼�ĳɻҼ�¼״̬
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  ԭ��ֵ��¼��ҵ����ˮ��
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel2ash(av_in    IN VARCHAR2, --�������
                                 av_debug IN VARCHAR2, --1д������־
                                 av_res   OUT VARCHAR2, --��������
                                 av_msg   OUT VARCHAR2 --����������Ϣ
                                 );
  /*=======================================================================================*/
  --�˻�����
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id|6tr_batch_no|7term_tr_no|8card_no|9card_tr_count|10card_bal|11acc_kind|12wallet_id|13tr_amt|
  --       14note|15���ֺ�������
  /*=======================================================================================*/
  PROCEDURE p_returncash(av_in    IN VARCHAR2, --�������
                         av_debug IN VARCHAR2, --1����
                         av_res   OUT VARCHAR2, --��������
                         av_msg   OUT VARCHAR2 --����������Ϣ
                         );
  /*=======================================================================================*/
  --��ֵ������Ԥ���
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id      �����  Ԥ��������
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8tr_amt       ��ֵ���(�������ö��ʱ������ĺ�����ö��)
  --       9pay_source   ��ֵ�ʽ���Դ0�ֽ�1ת��4�������ö��
  --      10note         ��ע
  --      11tr_state     9д�Ҽ�¼0ֱ��д������¼
  /*=======================================================================================*/
  PROCEDURE p_recharge2brch(av_in    IN VARCHAR2, --�������
                            av_debug IN VARCHAR2, --1����
                            av_res   OUT VARCHAR2, --��������
                            av_msg   OUT VARCHAR2 --����������Ϣ
                            );
END pk_recharge;
/

