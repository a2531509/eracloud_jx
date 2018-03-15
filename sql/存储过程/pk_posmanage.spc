CREATE OR REPLACE PACKAGE pk_posmanage IS
  -- Purpose : posmanage
  /*=======================================================================================*/
  --ǩ��
  /*=======================================================================================*/
  PROCEDURE p_login(av_bizid  IN VARCHAR2, --�̻���
                    av_termid IN VARCHAR2, --�ն˺�
                    av_operid IN VARCHAR2, --����Ա���
                    av_Device_No IN VARCHAR2,--�豸��
                    av_res    OUT VARCHAR2, --������ 00 �ɹ�
                    av_msg    OUT VARCHAR2, --��������������Ϣ
                    av_table  OUT pk_public.t_cur);
  /*=======================================================================================*/
  --ǩ��
  /*=======================================================================================*/
  PROCEDURE p_logout(av_bizid      IN VARCHAR2, --�̻���
                     av_termid     IN VARCHAR2, --�ն˺�
                     av_Device_No IN VARCHAR2,--�豸��
                     --av_trbatchno1 IN VARCHAR2, --���κ�
                     av_res        OUT VARCHAR2, --������ 00 �ɹ�
                     av_msg        OUT VARCHAR2 --��������������Ϣ
                     --av_actionno   OUT VARCHAR2, --pos������ˮ��
                     --av_trbatchno2 OUT VARCHAR2 --���κ�
                     );
  /*=======================================================================================*/
  --����
  /*=======================================================================================*/
  PROCEDURE p_heart(av_bizid  IN VARCHAR2, --�̻���
                    av_termid IN VARCHAR2, --�ն˺�
                    av_operid IN VARCHAR2, --����Ա���
                    av_Device_No IN VARCHAR2,--�豸��
                    av_res    OUT VARCHAR2, --������ 00 �ɹ�
                    av_msg    OUT VARCHAR2, --��������������Ϣ
                    av_table  OUT pk_public.t_cur);
  /*=======================================================================================*/
  --���غ�����
  /*=======================================================================================*/
  PROCEDURE p_downblackcard(av_bizid       IN VARCHAR2, --�̻���
                            av_termid      IN VARCHAR2, --�ն˺�
                            av_Device_No IN VARCHAR2,--�豸��
                            av_regno       in varchar2, --�ն��ϵ��г��ǼǺ�
                            av_count       IN INTEGER, --ÿ�δ��͵ļ�¼��
                            av_next        INTEGER, --��һ������¼�Ŀ�ʼ��
                            av_version     INTEGER, --�ն˰汾��
                            av_res         OUT VARCHAR2, --������ 00 �ɹ�
                            av_msg         OUT VARCHAR2, --��������������Ϣ
                            av_followstate OUT INTEGER, --������״̬��1��ʾ�к�������0��ʾû�к�����
                            av_maxversion  OUT INTEGER, --�汾��
                            av_table       OUT pk_public.t_cur);
  /*=======================================================================================*/
  --���ز�������Ҫ������ǰ�г��ǼǺţ��Լ�ftp�Ȳ���
  /*=======================================================================================*/
  PROCEDURE p_downparam(av_bizid  IN VARCHAR2, --�̻��ţ��ӿ��е��̻����ǿ�Ϊ�գ�Ϊ�Σ���
                        av_termid IN VARCHAR2, --�ն˺�
                        av_Device_No IN VARCHAR2, --�豸��
                        av_res    OUT VARCHAR2, --������ 00 �ɹ�
                        av_msg    OUT VARCHAR2, --��������������Ϣ
                        av_table  OUT pk_public.t_cur);

  /*=======================================================================================*/
  --�̻����ײ�ѯ
  /*=======================================================================================*/
  PROCEDURE p_merchant_trans(av_bizid       IN VARCHAR2, --�̻���
                             av_termid      IN VARCHAR2, --�ն˺�
                             av_clrdate     in varchar2, --��������yyyymmdd
                             av_acckind     in varchar2, --�˻����ͣ�01Ǯ����02����
                             av_count       IN INTEGER, --ÿ�δ��͵ļ�¼��
                             av_next        INTEGER, --��һ����¼�Ŀ�ʼ��,��1��ʼ
                             av_res         OUT VARCHAR2, --������ 00 �ɹ�
                             av_msg         OUT VARCHAR2, --��������������Ϣ
                             av_followstate OUT INTEGER, --������״̬��1��ʾ�к�������0��ʾû�к�����
                             av_totalcount OUT INTEGER, --�ܼ�¼��
                             av_table       OUT pk_public.t_cur) ;
  /*=======================================================================================*/
  --�����ϴ��ļ���
  /*=======================================================================================*/
  PROCEDURE p_saveFileName(av_filename VARCHAR2,
                           av_filetype varchar2, --�ļ����ͣ�����չ,XF����,ZK�ۿ�,QDǩ��
                           av_bizid    VARCHAR2);

  /*=======================================================================================*/
  --�������
  --av_in
  --     1pbiz_id                      �̻���
  --     2pterm_id                     �ն˺�
  --     3pch                          ���κ�
  --     4pconsumenormolnum            �������ѱ���
  --     5pconsumenormolamt            �������ѽ��
  --     6pconsumecancelnum            �������ѱ���
  --     7pconsumecancelamt            �������ѽ��
  --     8pconsumereturnnum            �����˻�����
  --     9pconsumereturnamt            �����˻����
  /*=======================================================================================*/
  procedure pos_BalanceAccount(
                          av_in      IN VARCHAR2,
                          av_res         OUT VARCHAR2, --������ 00 �ɹ�
                          av_msg         OUT VARCHAR2, --��������������Ϣ
                          av_check_flag  OUT VARCHAR2, --0����ƽ 1 ���˲�ƽ
                          rAction_No out varchar2,         --POS������ˮ��
                          rconsumeCount out integer,       --��������(�����ѻ�������) �����ܱ���
                          rconsumeFee out float,           --��������(�����ѻ�������)  �����ܽ��
                          rconsumereturncount OUT INTEGER,  --�˻� �����ܱ���
                          rconsumereturnamt   OUT INTEGER,  --�˻� �����ܽ��
                          rcancelCount out integer,        --��������
                          rcancelFee out float             --�������
                       );
END pk_posmanage;
/

