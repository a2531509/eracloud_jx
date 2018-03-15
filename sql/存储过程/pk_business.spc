CREATE OR REPLACE PACKAGE pk_business IS
  -- Purpose : ҵ��
  /*=======================================================================================*/
  --���˻�
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --5obj_type     ���ͣ����˻���������һ�£�0-����1-����/�� 2-��λ 3-�̻�4-������
  --6sub_type     ������(���ô���)
  --7obj_id       �˻����������ǿ�ʱ�����뿨�ţ�(�������ʱ������֮����,�ָ� cardno1,cardno2)
  --                             ��������client_id��
  --8pwd          ����
  --9encrypt      ���˻��������(�������ʱ��֮����,�ָ� encrypt1,encrypt2)
  /*=======================================================================================*/
  PROCEDURE p_createaccount(av_in  IN VARCHAR2, --�������
                            av_res OUT VARCHAR2, --������������
                            av_msg OUT VARCHAR2 --��������������Ϣ
                            );
  /*=======================================================================================*/
  --���˻�����
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5OBJ_TYPE|6SUB_TYPE|7OBJ_ID|
  /*=======================================================================================*/
  PROCEDURE p_createaccountcancel(av_in  IN VARCHAR2, --�������
                                  av_res OUT VARCHAR2, --������������
                                  av_msg OUT VARCHAR2 --��������������Ϣ
                                  );
  /*=======================================================================================*/
  --�����ֽ�β��
  /*=======================================================================================*/
  PROCEDURE p_updatecashbox(av_actionno IN NUMBER, --������ˮ��
                            av_trcode   IN VARCHAR2, --���״���
                            av_operid   IN VARCHAR2, --��Ա���
                            av_trdate   IN VARCHAR2, --����yyyy-mm-dd hh24:mi:ss
                            av_amt      IN NUMBER, --���
                            av_summary  IN VARCHAR2, --��ע
                            av_clrdate  IN VARCHAR2, --�������
                            av_res      OUT VARCHAR2, --������������
                            av_msg      OUT VARCHAR2 --��������������Ϣ
                            );
  /*=======================================================================================*/
  --�����ֽ�β��
  /*=======================================================================================*/
  PROCEDURE p_updatecashbox(av_actionno    IN NUMBER, --������ˮ��
                            av_trcode      IN VARCHAR2, --���״���
                            av_operid      IN VARCHAR2, --��Ա���
                            av_trdate      IN VARCHAR2, --����yyyy-mm-dd hh24:mi:ss
                            av_amt         IN NUMBER, --���
                            av_summary     IN VARCHAR2, --��ע
                            av_clrdate     IN VARCHAR2, --�������
                            av_otherorgid  IN VARCHAR2, --�Է�����
                            av_otherbrchid IN VARCHAR2, --�Է�����
                            av_otheroperid IN VARCHAR2, --�Է���Ա
                            av_res         OUT VARCHAR2, --������������
                            av_msg         OUT VARCHAR2 --��������������Ϣ
                            );
  /*=======================================================================================*/
  --���·ֻ���
  /*=======================================================================================*/
  PROCEDURE p_updatesubledger(av_accno          IN NUMBER, --�˺�
                              av_amt            IN NUMBER, --���
                              av_credit         IN NUMBER, --����
                              av_balance_old    in varchar2, --����ǰ���
                              av_balanceencrypt IN VARCHAR2, --�������
                              av_cardno         IN VARCHAR2, --����
                              av_res            OUT VARCHAR2, --������������
                              av_msg            OUT VARCHAR2 --��������������Ϣ
                              );
  /*=======================================================================================*/
  --���ݽ���˻��������˷���
  /*=======================================================================================*/
  PROCEDURE p_account(av_db        acc_account_sub%ROWTYPE, --�跽�˻�
                      av_cr        acc_account_sub%ROWTYPE, --�����˻�
                      av_dbcardbal NUMBER, --�跽���潻��ǰ���
                      av_crcardbal NUMBER, --������Ƭ����ǰ���

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
                      av_trdate           acc_inout_detail.deal_date%TYPE, --����ʱ��
                      av_trstate          acc_inout_detail.deal_state%TYPE, --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                      av_actionno         acc_inout_detail.deal_no%TYPE, --ҵ����ˮ��
                      av_note             acc_inout_detail.note%TYPE, --��ע
                      av_clrdate          pay_clr_para.clr_date%TYPE, --�������
                      av_otherin          VARCHAR2 DEFAULT NULL, --����������� �˻�ʱ����ԭacc_book_no
                      av_debug            IN VARCHAR2, --1����
                      av_res              OUT VARCHAR2, --������������
                      av_msg              OUT VARCHAR2 --��������������Ϣ
                      );
  /*=======================================================================================*/
  --�Ҽ�¼ȷ��  ���һ��acc_daybook��¼��ȷ��
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm_onerow(av_clrdate          IN pay_clr_para.clr_date%TYPE, --�������
                                av_daybook          IN acc_inout_detail%ROWTYPE, --Ҫȷ�ϵ�daybook
                                av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                av_crbalanceencrypt IN VARCHAR2, --�����������
                                av_dbaccbal         IN VARCHAR2, --�跽����ǰ���
                                av_craccbal         IN VARCHAR2, --��������ǰ���
                                av_debug            IN VARCHAR2, --1д������־
                                av_res              OUT VARCHAR2, --��������
                                av_msg              OUT VARCHAR2 --����������Ϣ
                                );
  /*=======================================================================================*/
  --�Ҽ�¼ȷ��  ���ݴ����acc_book_no��ȷ��
  /*=======================================================================================*/
  PROCEDURE p_ashconfirmbyaccbookno(av_clrdate          IN pay_clr_para.clr_date%TYPE, --�������
                                    av_accbookno        IN VARCHAR2, --Ҫȷ�ϵ�acc_book_no
                                    av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                    av_crbalanceencrypt IN VARCHAR2, --�����������
                                    av_dbaccbal         IN varchar2, --�跽����ǰ���
                                    av_craccbal         IN varchar2, --��������ǰ���
                                    av_debug            IN VARCHAR2, --1д������־
                                    av_res              OUT VARCHAR2, --��������
                                    av_msg              OUT VARCHAR2 --����������Ϣ
                                    );
  /*=======================================================================================*/
  --�Ҽ�¼ȷ��
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_clrdate          IN pay_clr_para.clr_date%TYPE, --�������
                         av_actionno         IN NUMBER, --ҵ����ˮ��
                         av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                         av_crbalanceencrypt IN VARCHAR2, --�����������
                         av_debug            IN VARCHAR2, --1д������־
                         av_res              OUT VARCHAR2, --��������
                         av_msg              OUT VARCHAR2 --����������Ϣ
                         );
  /*=======================================================================================*/
  --�Ҽ�¼ȡ��
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_clrdate  IN pay_clr_para.clr_date%TYPE, --�������
                        av_actionno IN NUMBER, --ҵ����ˮ��
                        av_debug    IN VARCHAR2, --1д������־
                        av_res      OUT VARCHAR2, --��������
                        av_msg      OUT VARCHAR2 --����������Ϣ
                        );
  /*=======================================================================================*/
  --���˳��� ���һ��acc_daybook��¼������ daybook����˻�����,���д��
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel_onerow(av_daybook          IN acc_inout_detail%ROWTYPE, --Ҫ����daybook
                                   av_operator         IN sys_users%ROWTYPE, --��ǰ����Ա
                                   av_actionno2        IN NUMBER, --��ҵ����ˮ��
                                   av_clrdate1         IN VARCHAR2, --������¼���������
                                   av_clrdate2         IN VARCHAR2, --��ǰ�������
                                   av_trcode           IN VARCHAR2, --���״���
                                   av_dbcardbal        IN NUMBER, --�跽���潻��ǰ���
                                   av_crcardbal        IN NUMBER, --�������潻��ǰ���
                                   av_dbcardcounter    IN NUMBER, --�跽��Ƭ���׼�����
                                   av_crcardcounter    IN NUMBER, --������Ƭ���׼�����
                                   av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                   av_crbalanceencrypt IN VARCHAR2, --�����������
                                   av_dbaccbal         IN VARCHAR2, --�跽����ǰ���
                                   av_craccbal         IN VARCHAR2, --��������ǰ���
                                   av_confirm          IN VARCHAR2, --1ֱ��ȷ��
                                   av_debug            IN VARCHAR2, --1д������־
                                   av_res              OUT VARCHAR2, --��������
                                   av_msg              OUT VARCHAR2 --����������Ϣ
                                   );
  /*=======================================================================================*/
  --���˳��� ���ݴ����acc_book_no������ daybook����˻�����,���д��
  /*=======================================================================================*/
  PROCEDURE p_daybookcancelbyaccbookno(av_accbookno        IN VARCHAR2, --Ҫ����acc_book_no
                                       av_actionno2        IN NUMBER, --��ҵ����ˮ��
                                       av_clrdate1         IN VARCHAR2, --������¼���������
                                       av_clrdate2         IN VARCHAR2, --��ǰ�������
                                       av_trcode           IN VARCHAR2, --���״���
                                       av_operid           IN VARCHAR2, --��ǰ��Ա
                                       av_dbcardbal        IN NUMBER, --�跽���潻��ǰ���
                                       av_crcardbal        IN NUMBER, --�������潻��ǰ���
                                       av_dbcardcounter    IN NUMBER, --�跽��Ƭ���׼�����
                                       av_crcardcounter    IN NUMBER, --������Ƭ���׼�����
                                       av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                       av_crbalanceencrypt IN VARCHAR2, --�����������
                                       av_dbaccbal         IN VARCHAR2, --�跽����ǰ���
                                       av_craccbal         IN VARCHAR2, --��������ǰ���
                                       av_confirm          IN VARCHAR2, --1ֱ��ȷ��
                                       av_debug            IN VARCHAR2, --1д������־
                                       av_res              OUT VARCHAR2, --��������
                                       av_msg              OUT VARCHAR2 --����������Ϣ
                                       );
  /*=======================================================================================*/
  --���˳���
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel(av_actionno1        IN NUMBER, --Ҫ����ҵ����ˮ��
                            av_actionno2        IN NUMBER, --��ҵ����ˮ��
                            av_clrdate1         IN VARCHAR2, --������¼���������
                            av_clrdate2         IN VARCHAR2, --��ǰ�������
                            av_trcode           IN VARCHAR2, --���״���
                            av_operid           IN VARCHAR2, --��ǰ��Ա
                            av_dbcardbal        IN NUMBER, --�跽���潻��ǰ���
                            av_crcardbal        IN NUMBER, --�������潻��ǰ���
                            av_dbcardcounter    IN NUMBER, --�跽��Ƭ���׼�����
                            av_crcardcounter    IN NUMBER, --������Ƭ���׼�����
                            av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                            av_crbalanceencrypt IN VARCHAR2, --�����������
                            av_confirm          IN VARCHAR2, --1ֱ��ȷ��
                            av_debug            IN VARCHAR2, --1д������־
                            av_res              OUT VARCHAR2, --��������
                            av_msg              OUT VARCHAR2 --����������Ϣ
                            );
  /*=======================================================================================*/
  --��ȡ���˻������ѷ���ѵ�
  --  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --           5item_no|6amt|7note
  /*=======================================================================================*/
  PROCEDURE p_cost(av_in    IN VARCHAR2, --�������
                   av_debug IN VARCHAR2, --1����
                   av_res   OUT VARCHAR2, --������������
                   av_msg   OUT VARCHAR2 --��������������Ϣ
                   );
  /*=======================================================================================*/
  --�ֽ𽻽�
  --  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --           5oper_id1|6oper_id2|7amt|8note
  /*=======================================================================================*/
  PROCEDURE p_cashhandover(av_in    IN VARCHAR2, --�������
                           av_debug IN VARCHAR2, --1����
                           av_res   OUT VARCHAR2, --������������
                           av_msg   OUT VARCHAR2 --��������������Ϣ
                           );

  /*=======================================================================================*/
  --��ʱ�������ű�����ʹ�����ݵ���ʷ�����ڿ����Զ����ɺ󴥷�
  --ԭ�򣬿��ű���״̬Ϊ��ʹ�ã���action_no��Ӧ������״̬>�����ɲ������Ƶ���ʷ��
  --�ұ�����ǰ�������ɹ���Ŀ������е����ֵ�����������ɵĿ����ظ�
  /*=======================================================================================*/
  PROCEDURE p_card_no_2_his(av_res OUT VARCHAR2, --��������
                            av_msg OUT VARCHAR2 --����������Ϣ;
                            );

  /*=======================================================================================*/
  --�г��ű������ʱ������
  /*=======================================================================================*/
  -- procedure p_change_market_reg_no;

  procedure p_account2(av_db_acc_no        in varchar2, --�跽�˻�
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
END pk_business;
/

