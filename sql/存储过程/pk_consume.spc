CREATE OR REPLACE PACKAGE pk_consume IS
  -- Purpose : ����
  /*=======================================================================================*/
  --�����̻��� �����˻��б�
  --av_table:code_value code_name
  /*=======================================================================================*/
  PROCEDURE p_getAccKindList(av_bizid IN base_merchant.merchant_id%TYPE, --�̻�����
                             av_table OUT pk_public.t_cur --�˻��б�
                             );

  /*=======================================================================================*/
  --ȡ�˻���Ϣ
  --av_table:acc_no,acc_kind,acc_name,item_no,acc_state,balance,balance_encrypt,frz_flag,frz_amt,psw
  /*=======================================================================================*/
  PROCEDURE p_getcardacc(av_cardno  VARCHAR2, --����
                         av_acckind VARCHAR2, --�˻�����
                         av_res     OUT VARCHAR2, --������������
                         av_msg     OUT VARCHAR2, --��������������Ϣ
                         av_table   OUT pk_public.t_cur);
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
                                 av_out OUT VARCHAR2 --��������
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

  /*=======================================================================================*/
  --���������˻�_����
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ���Ѽ�¼��ҵ����ˮ��
  --       2card_no      ����
  --       3clr_date     ���Ѽ�¼���������
  --       4tr_amt       �˻����
  --       5
  --av_out: �˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn_calc(av_in  IN VARCHAR2, --�������
                                       av_res OUT VARCHAR2, --��������
                                       av_msg OUT VARCHAR2, --����������Ϣ
                                       av_out OUT VARCHAR2 --��������
                                       );
  /*=======================================================================================*/
  --���������˻�
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
  --      12action_no    ���˻���action_no
  --      13clr_date     ���˻���¼��clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn(av_in    IN VARCHAR2, --�������
                                  av_debug IN VARCHAR2, --1����
                                  av_res   OUT VARCHAR2, --��������
                                  av_msg   OUT VARCHAR2, --����������Ϣ
                                  av_out   OUT VARCHAR2 --��������
                                  );

  /*=======================================================================================*/
  --�ѻ���������
  --av_in: ���ֶ���|�ָ�
  --org_id|co_org_id|acpt_id|end_id|batch_no|ser_no|card_no|CARD_IN_TYPE|CARD_IN_SUBTYPE|CARD_VALID_DATE|
  --Applyusedate|Applyvaliddate|Moneynum|Psamid|Psamnum|CardBalmoney|Trademoney|Tradetime|Tradetype|Tac|
  --Flag|deal_state|SEND_FILE_NAME|FILE_LINE_NO|TR_CODE
  --
  /*=======================================================================================*/
  PROCEDURE p_upofflineconsume(av_in    IN VARCHAR2, --�������
                               av_debug IN VARCHAR2, --1����
                               av_res   OUT VARCHAR2, --��������
                               av_msg   OUT VARCHAR2 --����������Ϣ
                               );

  /*=======================================================================================*/
  --�ѻ����ݴ���
  --av_in: ���ֶ���|�ָ�
  --       1biz_id    �̻���
  --�ܸ�ԭ��:00����Ƭ���з�����01��tac���02�����ݷǷ�03�������ظ�04���Ҽ�¼05������06-��������09�����ܸ�10��������
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             );
  /*=======================================================================================*/
  --�ѻ����ѻҼ�¼ȷ��
  --av_in: ���ֶ���|�ָ�
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_in    IN VARCHAR2, --�������
                         av_debug IN VARCHAR2, --1����
                         av_res   OUT VARCHAR2, --��������
                         av_msg   OUT VARCHAR2 --����������Ϣ
                         );
  /*=======================================================================================*/
  --�ѻ������˻�
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  ԭaction_no
  --       6clr_date   ԭ���Ѽ�¼���������
  --       7card_bal   Ǯ������ǰ���
  --       8card_tr_count�����׼�����
  /*=======================================================================================*/
  PROCEDURE p_offlineconsumereturn(av_in    IN VARCHAR2, --�������
                                   av_debug IN VARCHAR2, --1����
                                   av_res   OUT VARCHAR2, --��������
                                   av_msg   OUT VARCHAR2 --����������Ϣ
                                   );
  /*=======================================================================================*/
  --�ѻ����ѻҼ�¼���� --����״̬Ϊ�ѳ���
  --av_in: ���ֶ���|�ָ�
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_in    IN VARCHAR2, --�������
                        av_debug IN VARCHAR2, --1����
                        av_res   OUT VARCHAR2, --��������
                        av_msg   OUT VARCHAR2 --����������Ϣ
                        );
  /*=======================================================================================*/
  --�ѻ����Ѿܸ��ĳ�����
  --av_in: ���ֶ���|�ָ�
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_black2normal(av_in    IN VARCHAR2, --�������
                           av_debug IN VARCHAR2, --1����
                           av_res   OUT VARCHAR2, --��������
                           av_msg   OUT VARCHAR2 --����������Ϣ
                           );
  /*=======================================================================================*/
  --ȡ��Ա������Ϣ
  --av_in: ���ֶ���|�ָ�  card_no|cert_no|sub_card_no|
  /*=======================================================================================*/
  PROCEDURE p_getPersonalInfo(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1����
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2, --����������Ϣ
                              av_table OUT pk_public.t_cur);

  /*=======================================================================================*/
  --��ȡ����ģʽ�����ݴ������
  --av_in: 1merchant_id|
  --       2acc_kind|
  --       3cousume_type  0 ���˻����� 1 ��������
  /*=======================================================================================*/
  PROCEDURE p_getConsumeMode(av_in           IN VARCHAR2, --�������
                             av_debug        IN VARCHAR2, --1����
                             av_res          OUT VARCHAR2, --��������
                             av_msg          OUT VARCHAR2, --����������Ϣ
                             av_consume_mode OUT VARCHAR2 --��������ģʽ
                             );
  /*=======================================================================================*/
  --ǩ������
  --ÿ��������ǩ�����Ӿ�Ӫ�����̻������0.4Ԫ����Ա����δȦ���˻��ϣ�
  --  ͬʱÿ��ǩ��30�μ����ϵĴ��¸���10Ԫ��˽�Ľ�����
  --      ÿ��ǩ��100�μ����ϵ��������10Ԫ��˽�
  /*=======================================================================================*/
  /*PROCEDURE p_signpromotion(as_filename VARCHAR2, --ǩ���ļ���
                            av_debug    IN VARCHAR2, --1����
                            av_res      OUT VARCHAR2, --��������
                            av_msg      OUT VARCHAR2 --����������Ϣ
                            );
  /*=======================================================================================*/
  --ǩ������
  --  ͬʱÿ��ǩ��30�μ����ϵĴ��¸���10Ԫ��˽�Ľ�����
  /*=======================================================================================*/
  /*  PROCEDURE p_signpromotion_month(as_month VARCHAR2, --�·� yyyy-mm
                                  av_debug IN VARCHAR2, --1����
                                  av_res   OUT VARCHAR2, --��������
                                  av_msg   OUT VARCHAR2 --����������Ϣ
                                  );
  /*=======================================================================================*/
  --ǩ������
  --  ÿ��ǩ��100�μ����ϵ��������10Ԫ��˽�
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion_year(as_year  VARCHAR2, --��� yyyy
  av_debug IN VARCHAR2, --1����
  av_res   OUT VARCHAR2, --��������
  av_msg   OUT VARCHAR2 --����������Ϣ
  );*/
  /*=======================================================================================*/
  --��������
  --VIP��ÿ������1Ԫ��˽�һ��365Ԫ
  /*=======================================================================================*/
  /*PROCEDURE p_vippromotion(av_trdate IN VARCHAR2, --����yyyy-mm-dd
  av_debug  IN VARCHAR2, --1����
  av_res    OUT VARCHAR2, --��������
  av_msg    OUT VARCHAR2 --����������Ϣ
  );*/
  procedure p_accFreeze(av_in    in varchar2,
                        av_debug in varchar2,
                        av_res   out varchar2,
                        av_msg   out varchar2,
                        av_out   out varchar2);
   /*=======================================================================================*/
    --�˻����ⶳ
    --������Ϣ
    --       1deal_no       ��ˮ��
    --       2acpt_id       �������(����Ż��̻����)
    --       3acpt_type     ��������
    --       4user_id       ����Ա/�ն˺�
    --       5deal_time     ����ʱ��--�յĻ�ȡ�洢������ȡ���ݿ�ʱ��
    --       6old_deal_no   ԭʼ������ˮ
    --       7pwd           ����
    --       8deal_batch_no ���κ�
    --       9end_deal_no   �ն˽�����ˮ��
    --       10end_id        �ն˱��
    --       11note         ��ע

  /*=======================================================================================*/                       
  procedure p_accUnFreeze(av_in    in varchar2,
                          av_debug in varchar2,
                          av_res   out varchar2,
                          av_msg   out varchar2,
                          av_out   out varchar2);
                          
  /*=======================================================================================*/
  --�ѻ����ݴ���twz
  --av_deal_no ��ˮ��
  --�ܸ�ԭ��:00����Ƭ���з�����01��tac���02�����ݷǷ�03�������ظ�04���Ҽ�¼05������06-��������09�����ܸ�10��������
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume_twz(av_deal_no    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             );
END pk_consume;
/

