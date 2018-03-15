CREATE OR REPLACE PACKAGE BODY pk_transfer IS
  /*=======================================================================================*/
  --ת��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id        �������(����Ż��̻����)
  --       6tr_batch_no    ���κ�
  --       7term_tr_no     �ն˽�����ˮ��
  --       8card_no1       ת������
  --       9card_tr_count1 ת�������׼�����
  --      10card_bal1     ת����Ǯ������ǰ���
  --      11acc_kind1     ת�����˻�����
  --      12wallet_id1    ת����Ǯ����� Ĭ��00
  --      13card_no2      ת�뿨��
  --      14card_tr_count2ת�뿨���׼�����
  --      15card_bal2     ת�뿨Ǯ������ǰ���
  --      16acc_kind2     ת�뿨�˻�����
  --      17wallet_id2    ת�뿨Ǯ����� Ĭ��00
  --      18tr_amt        ת�˽��  nullʱת�����н��
  --      19pwd           ת������
  --      20note          ��ע
  --      21encrypt1      ת����ת�˺�������
  --      22encrypt2      ת�뿨ת�˺�������
  --      23tr_state      9д�Ҽ�¼0ֱ��д������¼
  --      24acpt_type     ��������
  --      25acc_bal1      ת�����˻�����ǰ���
  --      26acc_bal2      ת�뿨�˻�����ǰ���
  /*=======================================================================================*/
  PROCEDURE p_transfer(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2 --����������Ϣ
                       ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --����Ա
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_card        card_baseinfo%ROWTYPE; --��������Ϣ
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             23, --�������ٸ���
                             26, --����������
                             'pk_transfer.p_transfer', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --Ĭ��д�Ҽ�¼
    IF lv_in(23) IS NULL THEN
      lv_in(23) := '9';
    ELSIF lv_in(23) NOT IN ('9', '0') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'tr_stateֻ��9��0';
      RETURN;
    END IF;
    --Ǯ�����Ĭ��00
    lv_in(12) := nvl(lv_in(12), pk_public.cs_defaultwalletid);
    lv_in(17) := nvl(lv_in(17), pk_public.cs_defaultwalletid);
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    --ȡ�跽�ֻ���
    pk_public.p_getsubledgerbycardno(lv_in(8), --����
                                     lv_in(11), --�˻�����
                                     lv_in(12), --Ǯ�����
                                     lv_dbsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --ȡ��������Ϣ�Ϳ�������
    pk_public.p_getcardbycardno(lv_dbsubledger.card_no, --����
                                lv_card, --��Ƭ������Ϣ
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      --�ж�����
      pk_public.p_judgetradepwd(lv_card, --����Ϣ
                                lv_in(19), --����
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    IF lv_in(18) IS NULL THEN
      --ת�˽���nullʱת�����н��
      lv_in(18) := lv_dbsubledger.bal;
    END IF;
    --ȡ�����ֻ���
    pk_public.p_getsubledgerbycardno(lv_in(13), --����
                                     lv_in(16), --�˻�����
                                     lv_in(17), --Ǯ�����
                                     lv_crsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_dbsubledger.acc_kind IN ('02') AND
       lv_dbsubledger.bal <> nvl(lv_in(25), 0) THEN
      --�����˻���Ҫ�ж��ǲ���ͬʱ�����˻�
      av_res := pk_public.cs_res_dberr;
      av_msg := 'ת�����˻�����ǰ����ȷ';
      RETURN;
    END IF;
    IF lv_crsubledger.acc_kind IN ('02') AND
       lv_crsubledger.bal <> nvl(lv_in(26), 0) THEN
      --�����˻���Ҫ�ж��ǲ���ͬʱ�����˻�
      av_res := pk_public.cs_res_dberr;
      av_msg := 'ת�뿨�˻�����ǰ����ȷ';
      RETURN;
    END IF;
    --�ж��Ƿ�����ת��
    IF lv_dbsubledger.bal - lv_dbsubledger.credit_lmt < lv_in(18) THEN
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '�˻�����';
      RETURN;
    END IF;
    IF lv_in(24)='2' THEN
       lv_operator.org_id := lv_in(5);
    END IF;
    --д��ˮ
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --�跽�˻�
                          lv_crsubledger, --�����˻�
                          lv_in(10), --�跽���潻��ǰ���
                          lv_in(15), --�������潻��ǰ���
                          lv_in(9), --�跽��Ƭ���׼�����
                          lv_in(14), --������Ƭ���׼�����
                          lv_in(21), --�跽�������
                          lv_in(22), --�����������
                          lv_in(18), --���׽��
                          0, --���÷�����
                          lv_accbookno, --������ˮ��
                          lv_in(2), --���״���
                          lv_crsubledger.org_id, --��������
                          lv_operator.org_id, --�������
                          lv_in(24),--��������
                          lv_in(5), --��������(�����/�̻��ŵ�)
                          lv_in(3), --������Ա/�ն˺�
                          lv_in(6), --�������κ�
                          lv_in(7), --�ն˽�����ˮ��
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                          lv_in(23), --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          lv_in(1), --ҵ����ˮ��
                          lv_in(20), --��ע
                          lv_clrdate, --�������
                          null,--����������� �˻�ʱ����ԭacc_book_no
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );
  END p_transfer;

  /*=======================================================================================*/
  --ת��ȷ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7ת����ȷ��ǰ���˻��������|8ת�뿨ȷ��ǰ���˻��������|9ת����ת�˺�������|10ת�뿨ת�˺�������
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm_onerow(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1д������־
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2 --����������Ϣ
                              ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             10, --�������ٸ���
                             10, --����������
                             'pk_transfer.p_transferconfirm_onerow', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --�Ҽ�¼ȷ��
    pk_business.p_ashconfirmbyaccbookno(lv_in(6), --�������
                                        lv_in(5), --acc_book_no
                                        lv_in(9), --�跽�������
                                        lv_in(10), --�����������
                                        lv_in(7), --�跽����ǰ���
                                        lv_in(8), --��������ǰ���
                                        av_debug, --1д������־
                                        av_res, --��������
                                        av_msg --����������Ϣ
                                        );
  END p_transferconfirm_onerow;
  /*=======================================================================================*/
  --ת��ȷ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no|6clr_date|7card_no1|8card_no2|9ת����ת�˺�������|10ת�뿨ת�˺�������
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1д������־
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2 --����������Ϣ
                              ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             8, --�������ٸ���
                             10, --����������
                             'pk_transfer.p_transferconfirm', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --�Ҽ�¼ȷ��
    pk_business.p_ashconfirm(lv_clrdate, --�������
                             lv_in(5), --ҵ����ˮ��
                             lv_in(9), --�跽�������
                             lv_in(10), --�����������
                             av_debug, --1д������־
                             av_res, --��������
                             av_msg --����������Ϣ
                             );
  END p_transferconfirm;

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
                                    ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             13, --�������ٸ���
                             13, --����������
                             'pk_transfer.p_transfercancel_onerow', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    pk_business.p_daybookcancelbyaccbookno(lv_in(5), --Ҫ����acc_book_no
                                           lv_in(1), --��ҵ����ˮ��
                                           lv_in(6), --������¼���������
                                           lv_clrdate, --��ǰ�������
                                           lv_in(2), --���״���
                                           lv_in(3), --��ǰ��Ա
                                           lv_in(11), --�跽���潻��ǰ���
                                           lv_in(12), --�������潻��ǰ���
                                           lv_in(9), --�跽��Ƭ���׼�����
                                           lv_in(10), --������Ƭ���׼�����
                                           lv_in(13), --�跽�������
                                           lv_in(14), --�����������
                                           lv_in(7), --�跽����ǰ���
                                           lv_in(8), --��������ǰ���
                                           '0', --1ֱ��ȷ��
                                           av_debug, --1д������־
                                           av_res, --��������
                                           av_msg --����������Ϣ
                                           );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := 'ת�˳��� ��������' || SQLERRM;
  END p_transfercancel_onerow;
  /*=======================================================================================*/
  --ת�˳���
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no         ת��ʱ��ҵ����ˮ��
  --       6clr_date          д�Ҽ�¼ʱ���������
  --       7tr_state          ԭת�˼�¼״̬  �Ҽ�¼��������¼������
  --       8card_no1          ת������
  --       9card_no2          ת�뿨��
  --      10card_tr_count1   ת���������׼�����
  --      11card_tr_count2   ת�뿨�����׼�����
  --      12card_bal1        ת����Ǯ������ǰ���
  --      13card_bal2        ת�뿨Ǯ������ǰ���
  --      14encrypt1      ת����ת�˺�������
  --      15encrypt2      ת�뿨ת�˺�������
  /*=======================================================================================*/
  PROCEDURE p_transfercancel(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1д������־
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             15, --�������ٸ���
                             15, --����������
                             'pk_transfer.p_transfercancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    IF lv_in(7) = '9' THEN
      --ȡ���Ҽ�¼
      pk_business.p_ashcancel(lv_clrdate, --�������
                              lv_in(5), --ҵ����ˮ��
                              av_debug, --1д������־
                              av_res, --��������
                              av_msg --����������Ϣ
                              );
    ELSIF lv_in(7) = '0' THEN
      --����������¼
      pk_business.p_daybookcancel(lv_in(5), --Ҫ����ҵ����ˮ��
                                  lv_in(1), --��ҵ����ˮ��
                                  lv_in(6), --������¼���������
                                  lv_clrdate, --��ǰ�������
                                  lv_in(2), --���״���
                                  lv_in(3), --��Ա���
                                  lv_in(12), --�跽���潻��ǰ���
                                  lv_in(13), --�������潻��ǰ���
                                  lv_in(10), --�跽��Ƭ���׼�����
                                  lv_in(11), --������Ƭ���׼�����
                                  lv_in(14), --�跽�������
                                  lv_in(15), --�����������
                                  '0', --1ֱ��ȷ��
                                  av_debug, --1д������־
                                  av_res, --��������
                                  av_msg --����������Ϣ
                                  );
    END IF;
  END p_transfercancel;
BEGIN
  -- initialization
  NULL;
END pk_transfer;
/

