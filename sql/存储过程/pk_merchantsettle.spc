CREATE OR REPLACE PACKAGE pk_merchantsettle IS

  -- Purpose : �̻�����
  /*=======================================================================================*/
  --��һ�̻����н���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_bizid  IN base_merchant.merchant_id%TYPE, --�̻���
                     av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     );
  /*=======================================================================================*/
  --�������̻����н���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     );
  /*=======================================================================================*/
  --��һ�̻����м�ʱ����
  /*=======================================================================================*/
  PROCEDURE p_settle_immediate(av_bizid  IN base_merchant.merchant_id%TYPE, --�̻���
                               av_operid IN sys_users.user_id%TYPE, --�����Ա
                               av_res    OUT VARCHAR2, --��������
                               av_msg    OUT VARCHAR2 --����������Ϣ
                               );
  /*=======================================================================================*/
  --�������̻����н����job
  /*=======================================================================================*/
  PROCEDURE p_job;
  /*=======================================================================================*/
  --�̻��������
  /*=======================================================================================*/
  PROCEDURE p_settlerollback(av_stlsumno IN stl_deal_sum.stl_sum_no%TYPE, --�̻�����������
                             av_res      OUT VARCHAR2, --��������
                             av_msg      OUT VARCHAR2 --����������Ϣ
                             );
  /*=======================================================================================*/
  --�̻�����֧��
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5stlsumnos|6NOTE
  --stlsumnos��STL_SUM_NO$CARD_TYPE$ACC_KIND,STL_SUM_NO$CARD_TYPE$ACC_KIND
  /*=======================================================================================*/
  PROCEDURE p_settlepay(av_in    IN VARCHAR2, --�������
                        av_debug IN VARCHAR2, --1����
                        av_res   OUT VARCHAR2, --��������
                        av_msg   OUT VARCHAR2 --����������Ϣ
                        );
END pk_merchantsettle;
/

