create or replace package PK_CARD_GRANT is

  -- Author  : ADMINISTRATOR
  -- Created : 2015/8/7 15:28:23
  -- Purpose :


  /*=======================================================================================*/
  --�����ţ�Ŀǰֻ֧��A����
  /*=======================================================================================*/
  PROCEDURE card_grand(av_in  IN VARCHAR2, --�������
                      av_action_no  OUT VARCHAR2,--������������ҵ����ˮ��
                      av_res OUT VARCHAR2, --������������
                      av_msg OUT VARCHAR2 --��������������Ϣ
                      );
end PK_CARD_GRANT;
/

