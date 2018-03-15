create or replace package pk_card_Stock IS
  goods_state_zc   constant varchar2(1) := '0';--����
  goods_state_zlwt constant varchar2(1) := '2';--��������
  goods_state_hs   constant varchar2(1) := '1';--���տ�������
  goods_state_bf   constant varchar2(1) := '9';--����

  /**
  *�������
  */
  procedure p_updateCardStock(p_cardNo  in varchar2, --�¿���
                            p_cardNo2 in varchar2, --�Ͽ���
                            p_dealno  in integer, --��ˮ��
                            as_outMsg out varchar2, --�������
                            as_res    out varchar2); --��������
  --��Ա����˻�����
  --����˵����
  --1�������/������ ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� ����
  --4�ն˲�����ˮ ѡ��
  --5��������Ա�������� ����
  --6��������Ա��� ����
  --7����������� ѡ�� ��ֵʱ,���еĿ�����Ͷ����ֱ��˻�
  --8�����������״̬ ѡ�� ��ֵʱ,һ��������͵�����״̬�����˻�
  --9��ע
  PROCEDURE p_stockacc_open(av_in IN VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --�����Ʒ����
  --����˵����
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7������� stk_code ����
  --8������out_brch_id ����
  --9����Աout_user_id ����
  --10����Ʒ״̬out_goods_state  ����
  --11������in_brch_id ����
  --12�չ�Աin_user_id ����
  --13����Ʒ״̬in_goods_state  ����
  --14��潻����ʽ deliveryWay = 1ʱ��������deliveryWay = 2ʱ���տ��Ŷ� ��Ϊ"1"ʱ 15���� ��Ϊ"2"ʱ 16��17����
  --15������ taskIds
  --16��ʼ��Ʒ���� begin_googds_no
  --17������Ʒ���� end_goods_no
  --18��Ʒ���������� ����
  --19note��ע
  PROCEDURE p_stock_delivery(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --�������ȷ��
  --���������
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ѡ��
  --5������dealnos��ȷ����ˮ�Ŷ����ˮ�Ŷ��Ÿ����� 1,2,3,4,5,6 ����
  --���ز�����
  --av_res ����������
  --av_msg ������˵��
  --av_out �ɹ���������ĸ���
  PROCEDURE p_stock_delivery_confirm(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2,av_out OUT NUMBER);

  --�������ȡ�� ���͡�����ȷ�ϡ�����ȡ�����밴������ʽ����
  --���������
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ѡ��
  --5�����ˮdealnos��ȷ����ˮ�Ŷ����ˮ�Ŷ��Ÿ����� 1,2,3,4,5,6 ����
  --6������deal_code
  --7����ʱ�� deal_time
  --8��ע note
  --���ز�����
  --av_res ����������
  --av_msg ������˵��
  --av_out�ɹ���������ĸ���
  PROCEDURE p_stock_delivery_cancel(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2,av_out OUT NUMBER);

  --��Ա֮���潻�� ����
  --����˵����
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7������� stk_code ����
  --8�����Ʒ״̬goods_state
  --9������out_brch_id ����
  --10����Աout_user_id ����
  --11������in_brch_id ����
  --12�չ�Աin_user_id ����
  --13��潻����ʽ deliveryWay = 1ʱ��������deliveryWay = 2ʱ���տ��Ŷ� ��Ϊ"1"ʱ 14���� ��Ϊ"2"ʱ 15��16����
  --14������ taskIds
  --15��ʼ��Ʒ���� begin_googds_no
  --16������Ʒ���� end_goods_no
  --17��Ʒ���������� ����
  --18note��ע
  PROCEDURE p_stock_exchange(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --CardBaseinfo���ţ����˷��ţ���ģ����
  --����˵����
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7����card_no
  --8������task_id
  --9��עnote
  PROCEDURE p_card_release(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --�����Ʒ���
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7�������STK_CODE
  --8��Ʒ���id GOODS_ID
  --9��Ʒ���GOODS_NO
  --10��Ʒ״̬GOODS_STATE
  --11��������BATCH_ID
  --12��������TASK_ID
  --13�Ƿ�ȷ��STK_IS_SURE
  --14�������IN_BRCH_ID
  --15����ԱIN_USER_ID
  --16�����ˮIN_DEAL_NO
  --17��������OWN_TYPE
  --18��������ORG_ID
  --19��������BRCH_ID
  --20������ԱUSER_ID
  --21��עNOTE
  PROCEDURE p_in_stock(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --�����Ʒ���
  --����˵��
  --1�������/������ brch_id/acpt_id ����
  --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
  --3�ն˱��/��Ա��� user_id/end_id ����
  --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
  --5���״��� deal_code ����
  --6ҵ�����ʱ�� deal_time ����
  --7����Ʒ���Old_GOODS_NO
  --8����Ʒ���new_goods_no
  --9��עNOTE
  PROCEDURE p_bhk(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --�����յǼ�   �ջؿ�
   --����˵��
   --1�������/������ brch_id/acpt_id ����
   --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
   --3�ն˱��/��Ա��� user_id/end_id ����
   --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
   --5���״��� deal_code ����
   --6ҵ�����ʱ�� deal_time ����
   --7��Ʒ���/����
   --8����Ŀ����״̬ Ĭ�� 1 ���մ�����
   --9��עNOTE
   procedure p_hsdj(av_in varchar2,av_res out varchar2,av_msg out varchar2);
   --��Ʒ����
   --����˵��
   --1�������/������ brch_id/acpt_id ����
   --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
   --3�ն˱��/��Ա��� user_id/end_id ����
   --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
   --5���״��� deal_code ����
   --6ҵ�����ʱ�� deal_time ����
   --7��Ʒ���/����
   --8Ŀ����״̬ Ĭ�ϲ��޸�ԭ�����ϸ״̬ �������Ҫ�������ϸ�޸ĵ�ʲô״̬
   -- һ�㲻��Ҫ���룬�����粹��������ʱ��Ҫ����0 ��������Ϊ����������������ϸ��Ϊ��������״̬������ʱ��Ҫ�ظ�������״̬
   --9�Ƿ�У����������Ϣ  Ĭ���Ƿ񿨲���
   --10��עnote
   procedure p_out_stock(av_in varchar2,av_res out varchar2,av_msg out varchar2);

   --��Ա����
   --����˵��
   --1�������/������ brch_id/acpt_id ����
   --2��������� acpt_type ���� (1-���� 2-���� 3-���� 4-�绰 5-��վ 6-�̳�)
   --3�ն˱��/��Ա��� user_id/end_id ����
   --4�ն˲�����ˮ/ҵ����ˮ deal_no/end_deal_no ����
   --5���״���
   --6����ʱ��
   --7������
   --8����Ա
   --9������
   --10�չ�Ա
   --11�������
   --12���״̬
   --13��ע
   procedure p_teller_jj(av_in varchar2,av_res out varchar2,av_msg out varchar2);

  --���ݿ��Ż�ȡ����Ϣ
  --av_goods_no ��Ʒ���
  --av_stock_list ��Ʒ��Ϣ
  --av_res ����������
  --av_res ������˵��
  PROCEDURE p_getCardBaseinfo(av_card_no card_baseinfo.card_no%TYPE,
                           av_card_baseinfo OUT card_baseinfo%ROWTYPE,
                           av_res OUT VARCHAR2,
                           av_msg OUT VARCHAR2);

   --������Ʒ��Ż�ȡ��Ʒ��Ϣ
   --av_goods_no ��Ʒ���
   --av_stock_list ��Ʒ��Ϣ
   --av_res ����������
   --av_res ������˵��
  PROCEDURE p_getStockListByGoodsNo(av_goods_no stock_list.goods_no%TYPE,
                           av_stock_list OUT stock_list%ROWTYPE,
                           av_res OUT VARCHAR2,
                           av_msg OUT VARCHAR2);

  --���������Ż�ȡ������Ϣ
  --av_task_id ������
  --av_card_apply_task ������Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE p_getCardApplyTaskByTaskId(av_task_id card_apply_task.task_id%TYPE,
                                        av_card_apply_task OUT card_apply_task%ROWTYPE,
                                        av_res OUT VARCHAR2,
                                        av_msg OUT VARCHAR2
                                        );

  --����user_id,stk_code,stk_goods_state��ȡ����˻�
  --��Աuser_id
  --������
  --��Ʒ״̬
  --�����Ϣ
  --���ش���
  --������Ϣ
  PROCEDURE p_getStock_Acc(
                          av_brch_id VARCHAR2,
                          av_user_id VARCHAR2,
                          av_stk_code VARCHAR2,
                          av_stk_goods_state VARCHAR2,
                          av_stock_acc OUT stock_acc%ROWTYPE,
                          av_res OUT VARCHAR2,
                          av_msg OUT VARCHAR2);

  --��ȡ�������ȡ���������Ϣ
  --lv_stk_code ������
  --lv_stock_type ���������Ϣ
  --av_res ����������
  --av_msg ������˵��
  PROCEDURE p_getStock_Type(lv_stk_code stock_type.stk_code%TYPE,
                            lv_stock_type OUT stock_type%ROWTYPE,
                            av_res OUT VARCHAR2,
                            av_msg OUT VARCHAR2
                            );

  --�жϿ����Ƿ���ͬ��һ�������ҺŶ��Ƿ�����
  --av_user_id ������Ա
  --av_begin_goods_no ��ʼ����
  --av_end_goods_no ��ֹ����
  --av_card_apply_task ��������
  --av_res ����������
  --av_msg ������˵��
  FUNCTION f_judgeCardRange( av_user_id stock_list.user_id%TYPE,
                           av_begin_goods_no stock_list.goods_no%TYPE,
                           av_end_goods_no stock_list.goods_no%TYPE,
                           av_card_apply_task OUT card_apply_task%ROWTYPE,
                           av_res OUT VARCHAR2,
                           av_msg OUT VARCHAR
                           ) RETURN NUMBER;
   --�ƿ����ݵ���
   PROCEDURE pk_Import_CardData(av_in VARCHAR2,
                                av_res OUT VARCHAR2,
                                av_msg OUT VARCHAR2,
                                av_out OUT VARCHAR2);

  --����������,��Ա��Ż�ȡ��Ա��Ϣ
  -- ��������
  --��Ա���
  --���������
  --������˵��
  --��ʼ�����
  PROCEDURE p_getUsersByUserId(
                               av_brch_id VARCHAR2,
                               av_user_id VARCHAR2,
                               av_users OUT sys_users%ROWTYPE,
                               av_res OUT VARCHAR2,
                               av_msg OUT VARCHAR2,
                               av_init_msg VARCHAR
                               );
end pk_card_Stock;
/

