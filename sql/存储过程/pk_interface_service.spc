create or replace package pk_interface_service is

  -- Author  : ADMINISTRATOR
  -- Created : 2016/7/15 9:20:16
  -- Purpose :

  /*=======================================================================================*/
  ---�������
  /*=======================================================================================*/
  PROCEDURE p_save_sms_message(av_dealcode IN INTEGER, --���״���
                               av_dealno   IN NUMBER, --��ˮ��
                               av_cardno   IN VARCHAR2, --����
                               av_tramt    IN  NUMBER, --���׽��
                               av_bef_bal  IN  NUMBER, --����ǰ���
                               av_res      OUT VARCHAR2, --������ 00 �ɹ�
                               av_msg      OUT VARCHAR2); --��������������Ϣ

end pk_interface_service;
/

