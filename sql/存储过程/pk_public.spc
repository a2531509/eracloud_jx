CREATE OR REPLACE PACKAGE pk_public IS

  -- Purpose : ���ð�
  TYPE myarray IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  --�α�
  TYPE t_cur IS REF CURSOR;

  cs_cm_card_nums         NUMBER := 20; --��Ƭ��ֱ�����
  cs_trade_pwd_err_num    NUMBER := 6; --��������������
  cs_serv_pwd_err_num     NUMBER := 6; --��������������
  cs_co_org_serv_pwd_err_num     NUMBER := 6; --������������������
  cs_points_exchange_acc  VARCHAR2(2) := '09'; --���ֶһ�Ŀ���˻���ȡ�˻����ͣ�09δȦ���˻�
  cs_points_exchange_rate NUMBER := 100; --���ֶ��ֱ���100��1Ԫ��ֵΪ100
  cs_points_period_rule   NUMBER := 4; --�������ɣ����ּ��ڹ���1��2��3��4��
  cs_points_period        NUMBER := 1; --�������ɣ�������Ч�ڣ�����ڹ������ʹ�ã�����ʱ����365������ʱ����24
  cs_yesno_yes        CONSTANT VARCHAR2(1) := '0'; --�Ƿ�_��
  cs_yesno_no         CONSTANT VARCHAR2(1) := '1'; --�Ƿ�_��
  cs_defaultwalletid  CONSTANT VARCHAR2(2) := '00'; --Ĭ��Ǯ�����
  cs_client_type_card CONSTANT VARCHAR2(1) := '1'; --�ͻ����ͣ�0-����1-����/�� 2-��λ 3-�̻�4-������
  cs_acpt_type_wd     CONSTANT VARCHAR2(1) := '1'; --�������ࣺ(0-�̻� 1-����)
  cs_acpt_type_sh     CONSTANT VARCHAR2(1) := '0'; --�������ࣺ(0-�̻� 1-����)

  CARD_TYPE_SMZK CONSTANT card_baseinfo.card_type%TYPE  := '120';--ȫ���ܿ� ������

  --�˻�����
  cs_acckind_pt   CONSTANT acc_account_sub.acc_kind%TYPE := '00'; --��ͨ�˻�
  cs_acckind_qb   CONSTANT acc_account_sub.acc_kind%TYPE := '01'; --Ǯ���˻�
  cs_acckind_zj   CONSTANT acc_account_sub.acc_kind%TYPE := '02'; --�ʽ��˻�
  cs_acckind_jf   CONSTANT acc_account_sub.acc_kind%TYPE := '03'; --�����˻�
  cs_acckind_djq  CONSTANT acc_account_sub.acc_kind%TYPE := '04'; --����ȯ�˻�
  cs_acckind_zfbt CONSTANT acc_account_sub.acc_kind%TYPE := '05'; --���������˻�
  cs_acckind_zy   CONSTANT acc_account_sub.acc_kind%TYPE := '06'; --ר���˻�
  cs_acckind_czk  CONSTANT acc_account_sub.acc_kind%TYPE := '07'; --��ֵ���˻�
  cs_acckind_yhq  CONSTANT acc_account_sub.acc_kind%TYPE := '08'; --�Ż�ȯ�˻�
  cs_acckind_wqc  CONSTANT acc_account_sub.acc_kind%TYPE := '09'; --δȦ���˻�
  cs_acckind_yj   CONSTANT acc_account_sub.acc_kind%TYPE := '10'; --Ѻ���˻�

  --��Ŀ��
  cs_accitem_cash                CONSTANT acc_item.item_id%TYPE := '101101'; --�ֽ�
  cs_accitem_org_bank            CONSTANT acc_item.item_id%TYPE := '102100'; --����������
  cs_accitem_org_points          CONSTANT acc_item.item_id%TYPE := '102101'; --��������
  cs_accitem_card_deposit_300    CONSTANT acc_item.item_id%TYPE := '201101'; --�����
  cs_accitem_card_points         CONSTANT acc_item.item_id%TYPE := '201102'; --��Ƭ���˻���
  cs_accitem_card_deposit_310    CONSTANT acc_item.item_id%TYPE := '201103'; --�̻��������
  cs_accitem_card_deposit_800    CONSTANT acc_item.item_id%TYPE := '201104'; --��ֵ�������
  cs_accitem_card_foregift       CONSTANT acc_item.item_id%TYPE := '201105'; --��Ѻ��
  cs_accitem_biz_clr             CONSTANT acc_item.item_id%TYPE := '205101'; --�̻��������
  cs_accitem_biz_stl             CONSTANT acc_item.item_id%TYPE := '205102'; --�̻������
  cs_accitem_brch_prestore       CONSTANT acc_item.item_id%TYPE := '207101'; --��������Ԥ���
  cs_accitem_org_handding_fee_in CONSTANT acc_item.item_id%TYPE := '701101'; --����������
  cs_accitem_org_cost_in         CONSTANT acc_item.item_id%TYPE := '702101'; --��������
  cs_accitem_org_serv_fee_in     CONSTANT acc_item.item_id%TYPE := '703101'; --��Ѻ��/���������
  cs_accitem_org_zxc_ree_in      CONSTANT acc_item.item_id%TYPE := '703102'; --���г�Ѻ������
  cs_accitem_org_remain_in       CONSTANT acc_item.item_id%TYPE := '709101'; --����ֵ�����
  cs_accitem_org_other_in        CONSTANT acc_item.item_id%TYPE := '709999'; --��������
  cs_accitem_org_prmt_out        CONSTANT acc_item.item_id%TYPE := '713101'; --����֧��
  cs_accitem_org_points_chg_out  CONSTANT acc_item.item_id%TYPE := '713102'; --���ֶһ�֧��
  cs_accitem_org_credit_chg_out  CONSTANT acc_item.item_id%TYPE := '713103'; --����֧��
  cs_accitem_co_org_rechage_in   CONSTANT acc_item.item_id%TYPE := '208101'; --��������Ӧ�տ�
  cs_accitem_co_rechage_yck_in   CONSTANT acc_item.item_id%TYPE := '208301'; --��������Ԥ���

  --����״̬
  --����״̬00-������,10-���������� 20-�ƿ��� 30-���ƿ� 40-������ 50-�ѽ���  60-�ѷ��� 70-���˿� 90ע��)

  kg_card_apply_ysq CONSTANT  VARCHAR2(2) := '00';
  kg_card_apply_rwysc CONSTANT  VARCHAR2(2) := '10';
  kg_card_apply_yfwjw    constant  varchar2(2) := '11';--�ѷ�����ί
  kg_card_apply_wjwshbtg constant  varchar2(2) := '12';--����ί��˲�ͨ��
  kg_card_apply_wjwshtg  constant  varchar2(2) := '13';--����ί�����ͨ��
  kg_card_apply_yfbank   constant  varchar2(2) := '14';--�ѷ�����
  kg_card_apply_yhshbtg  constant  varchar2(2) := '15';--������˲�ͨ��
  kg_card_apply_yhshtg   constant  varchar2(2) := '16';--�������ͨ��
  kg_card_apply_yfst     constant  varchar2(2) := '17';--�ѷ�ʡ��
  kg_card_apply_stshbtg  constant  varchar2(2) := '18';--ʡ����˲�ͨ��
  kg_card_apply_stshtg   constant  varchar2(2) := '19';--ʡ�����ͨ��
  kg_card_apply_zkz CONSTANT  VARCHAR2(2) := '20';
  kg_card_apply_yzk CONSTANT  VARCHAR2(2) := '30';
  kg_card_apply_yps CONSTANT  VARCHAR2(2) := '40';
  kg_card_apply_yjs CONSTANT  VARCHAR2(2) := '50';
  kg_card_apply_yff CONSTANT  VARCHAR2(2) := '60';
  kg_card_apply_ytk CONSTANT  VARCHAR2(2) := '70';
  kg_card_apply_yhs      constant  varchar2(2) := '80';
  kg_card_apply_yzx CONSTANT  VARCHAR2(2) := '90';

  --����״̬
  --����״̬(00����������,10�ƿ���,20���ƿ�,30������,40�ѽ���,50����������90�������)
  kg_card_task_ysc CONSTANT  VARCHAR2(2) := '00';
  kg_card_task_yfwjw  CONSTANT  VARCHAR2(2) := '01';--�ѷ�����ί
  kg_card_task_wjwysh CONSTANT  VARCHAR2(2) := '02';--����ί�����
  kg_card_task_yfyh   CONSTANT  VARCHAR2(2) := '03';--�ѷ�����
  kg_card_task_yhysh  CONSTANT  VARCHAR2(2) := '04';--���������
  kg_card_task_yfst   CONSTANT  VARCHAR2(2) := '05';--�ѷ�ʡ��
  kg_card_task_stysh  CONSTANT  VARCHAR2(2) := '06';--ʡ�������
  kg_card_task_zkz CONSTANT  VARCHAR2(2) := '10';
  kg_card_task_yzk CONSTANT  VARCHAR2(2) := '20';
  kg_card_task_yps CONSTANT  VARCHAR2(2) := '30';
  kg_card_task_yjs CONSTANT  VARCHAR2(2) := '40';
  kg_card_task_fkz CONSTANT  VARCHAR2(2) := '50';
  kg_card_task_yff CONSTANT  VARCHAR2(2) := '90';

  --������
  cs_res_ok                   CONSTANT VARCHAR2(8) := '00000000'; --�ɹ�
  cs_res_paravalueerr         CONSTANT VARCHAR2(8) := '88880001'; --����ֵ����
  cs_res_validatetypeerr      CONSTANT VARCHAR2(8) := '88880002'; --��֤���ʹ���
  cs_res_clr_control_paraerr  CONSTANT VARCHAR2(8) := '88880003'; --��ȡ����״̬����
  cs_res_sysworking           CONSTANT VARCHAR2(8) := '88880004'; --ϵͳ�������մ���,���Ժ�
  cs_res_operatorerr          CONSTANT VARCHAR2(8) := '88880005'; --�û���������֤ʧ��
  cs_res_cashinsufbalance     CONSTANT VARCHAR2(8) := '88880006'; --��Աβ�䲻��
  cs_res_cardiderr            CONSTANT VARCHAR2(8) := '88880007'; --������֤��ͨ��
  cs_res_accnotexit           CONSTANT VARCHAR2(8) := '88880008'; --�˻�������
  cs_res_accstateerr          CONSTANT VARCHAR2(8) := '88880009'; --�ʻ�״̬Ϊ������
  cs_res_accinsufbalance      CONSTANT VARCHAR2(8) := '88880010'; --�˻�����
  cs_res_pwderr               CONSTANT VARCHAR2(8) := '88880011'; --�������
  cs_res_pwderrnum            CONSTANT VARCHAR2(8) := '88880012'; --�������������
  cs_res_prepaidcardisused    CONSTANT VARCHAR2(8) := '88880013'; --��ֵ����ʹ��
  cs_res_prepaidcardnotexist  CONSTANT VARCHAR2(8) := '88880014'; --��ֵ��������
  cs_res_prepaidcardfeeerr    CONSTANT VARCHAR2(8) := '88880015'; --��ֵ��������
  cs_res_prepaidcardpwderr    CONSTANT VARCHAR2(8) := '88880016'; --��ֵ���������
  cs_res_rechg_exceed_limit   CONSTANT VARCHAR2(8) := '88880017'; --��ֵ����
  cs_res_busierr              CONSTANT VARCHAR2(8) := '88880018'; --�̻���֤ʧ��
  cs_res_termerr              CONSTANT VARCHAR2(8) := '88880019'; --�ն���֤ʧ��
  cs_res_relogin              CONSTANT VARCHAR2(8) := '88880020'; --��ǩ���������ظ�ǩ��
  cs_res_relogout             CONSTANT VARCHAR2(8) := '88880021'; --��ǩ�ˣ������ظ�ǩ��
  cs_res_notlogin             CONSTANT VARCHAR2(8) := '88880022'; --�ն�δǩ��
  cs_res_glidenotexit         CONSTANT VARCHAR2(8) := '88880023'; --����/��������ˮ�Ų�����
  cs_res_glideinfoerr         CONSTANT VARCHAR2(8) := '88880024'; --����/��������ˮ��Ϣ����ȷ
  cs_res_glideflushesed       CONSTANT VARCHAR2(8) := '88880025'; --��ˮ�ѳ����������ظ�����
  cs_res_flushesoperdifferent CONSTANT VARCHAR2(8) := '88880026'; --��������Ա��ԭ����Ա������ͬ
  cs_res_tr_dataerr           CONSTANT VARCHAR2(8) := '88880027'; --�������ݴ���
  cs_res_tradeiderr           CONSTANT VARCHAR2(8) := '88880028'; --���������
  cs_res_cancelfeeerr         CONSTANT VARCHAR2(8) := '88880029'; --�˻��ܽ�����ԭ���ѽ�ϵͳ�ܾ����ν���
  cs_res_exp_acc_unallowed    CONSTANT VARCHAR2(8) := '88880030'; --���̻�������ʹ�ô�ר���˻�����
  cs_res_consume_quotas_amt   CONSTANT VARCHAR2(8) := '88880031'; --�������ѳ����޶�
  cs_res_consume_quotas_num   CONSTANT VARCHAR2(8) := '88880032'; --�����ѳ�������
  cs_res_rljljxf_amt          CONSTANT VARCHAR2(8) := '88880033'; --�����ѳ������
  cs_res_rowunequalone        CONSTANT VARCHAR2(8) := '88880034'; --���ݲ�Ψһ�������ظ�;
  cs_res_signin_apply_unique  CONSTANT VARCHAR2(8) := '88880035'; --�����̻���������;
  cs_res_signin_apply_max     CONSTANT VARCHAR2(8) := '88880036'; --������������;
  cs_res_user_err             CONSTANT VARCHAR2(8) := '88880037'; --�ܿ������ʶ�����;
  cs_res_cardis_err           CONSTANT VARCHAR2(8) := '88880038'; --�ÿͻ����ڿ��ţ������ظ�����;
  cs_res_oldcardnull_err      CONSTANT VARCHAR2(8) := '88880039'; --�Ͽ�����Ϊ��;
  cs_res_oldcardnotexist_err  CONSTANT VARCHAR2(8) := '88880040'; --ԭ�˻���Ϣ������;
  cs_res_oldcardtansvil_err   CONSTANT VARCHAR2(8) := '88880041'; --��������֤ʧ��;
  cs_res_personalvil_err      CONSTANT VARCHAR2(8) := '88880042'; --�ͻ���Ϣ��֤ʧ��;
  cs_res_card_ban_deal        CONSTANT VARCHAR2(8) := '88880043'; --��״̬�ý������ֹ����;
  cs_res_consume_upbig_num    CONSTANT VARCHAR2(8) := '88880044'; --�̻��ۼƳ������ױ�������;
  cs_res_co_check_bill_rep    CONSTANT VARCHAR2(8) := '88880045'; --���������������ظ�����
  cs_res_co_check_bill_nomsg  CONSTANT VARCHAR2(8) := '88880046'; --��������������Ϣ������
  cs_res_access_pointtr_err   CONSTANT VARCHAR2(8) := '88880047'; --����㽻����֤ʧ��
  cs_res_baseco_nofounderr    CONSTANT VARCHAR2(8) := '88880048'; --����������Ϣδ�Ǽ�
  cs_res_tagdev_validateerr   CONSTANT VARCHAR2(8) := '88880049'; --�ն��豸����֤����
  cs_res_cardisblackerr       CONSTANT VARCHAR2(8) := '88880050'; --���Ƿ�Ϊ��������
  cs_res_cardstateiserr       CONSTANT VARCHAR2(8) := '88880051'; --��״̬������
  cs_res_co_org_novalidateerr CONSTANT VARCHAR2(8) := '88880052'; --�����������Ϸ�
  cs_res_apply_msg_err        CONSTANT VARCHAR2(8) := '88880053'; --�����¼����ȷ
  cs_res_nobhktype_err        CONSTANT VARCHAR2(8) := '88880054'; --�����¼���ǲ�������¼
  cs_res_amt_is_zero          CONSTANT VARCHAR2(8) := '88880055'; --�Ͽ��˻������0�������ת��
  cs_res_tramt_acc_oneerr     CONSTANT VARCHAR2(8) := '88880056'; --�˻��������ѳ���
  cs_res_tramt_acc_allerr     CONSTANT VARCHAR2(8) := '88880057'; --�˻��ۼ����ѳ���
  cs_res_wallettramt_allerr   CONSTANT VARCHAR2(8) := '88880058'; --С�����ѵ������ѳ���
  cs_res_trmun_acc_allerr     CONSTANT VARCHAR2(8) := '88880059'; -- �˻��ۼ����ѱ�������
  cs_res_onerechage_accerr    CONSTANT VARCHAR2(8) := '88880060'; -- �����˻����ʳ�ֵ����
  cs_res_onerechage_walerr    CONSTANT VARCHAR2(8) := '88880061'; -- ����Ǯ�����ʳ�ֵ����
  cs_res_checkcongh_walerr    CONSTANT VARCHAR2(8) := '88880062'; -- ���Ŷ�Ӧ����Ա��׼���ڸ��̻�������
  cs_res_sqnmode_mererr       CONSTANT VARCHAR2(8) := '88880063'; -- ���������ģʽ�����ڸ��̻�
  cs_res_sqngetmode_mererr    CONSTANT VARCHAR2(8) := '88880064'; -- ��ȡ�˻�����ģʽ����
  cs_res_no_bind_bank         CONSTANT VARCHAR2(8) := '88880065'; -- ��δ������
  cs_res_bind_bank_err        CONSTANT VARCHAR2(8) := '88880066'; --�����д��󣬲��Ǳ����еĿ�
  cs_res_bind_bankno_err      CONSTANT VARCHAR2(8) := '88880067'; --���ʱ��������п����ź͵�ǰ�󶨵Ŀ��Ų�һ��
  cs_res_bind_bank_more       CONSTANT VARCHAR2(8) := '88880068'; --�ҵ������󶨼�¼
  cs_res_card_apply_noexist   CONSTANT VARCHAR2(8) := '88880069'; --��Ƭ��Ӧ�������¼������
  cs_res_card_apply_noyjs     CONSTANT VARCHAR2(8) := '88880070'; --��Ƭ��Ӧ�������¼�����ѽ���״̬
  cs_res_bcp_not_exist        CONSTANT VARCHAR2(8) := '88880071'; --�������п������Ҳ�����Ӧ�Ŀ���
  cs_res_bcp_has_more         CONSTANT VARCHAR2(8) := '88880072'; --
  cs_res_bcp_has_bind         CONSTANT VARCHAR2(8) := '88880073'; --���п���Ӧ�Ŀ����Ѿ�ʹ��
  cs_res_bcp_notmadecard_list CONSTANT VARCHAR2(8) := '88880074'; --���Ʒ���ɹ���ϸ������
  cs_res_bcp_notmadecard_task CONSTANT VARCHAR2(8) := '88880075'; --���Ʒ���ɹ����񲻴���
  cs_res_bcp_not_madecard     CONSTANT VARCHAR2(8) := '88880076'; --���ǰ��Ʒ���ɹ�������
  cs_res_not_cardconfig       CONSTANT VARCHAR2(8) := '88880077'; --�����ò�����Ϣ����ȷ
  cs_res_bcp_updateerr        CONSTANT VARCHAR2(8) := '88880078'; --���°��Ʒ��ʹ��״̬ʧ��


  --------�����Ŵ�����
  cs_res_grant_cardType_err   CONSTANT VARCHAR2(8) :=  '22220001'; --Ŀǰ��֧�ָÿ����͵ķ���
  cs_res_grant_nofindapply_err    CONSTANT VARCHAR2(8) := '22220002'; --δ�ҵ��κ���������
  cs_res_grant_nofindtaks_err  CONSTANT VARCHAR2(8) := '22220003';--δ�ҵ��κ�������������
  cs_res_grant_condition_err  CONSTANT  VARCHAR2(8) := '22220004';--�����㷢������
  cs_res_grant_taskcondition_err  CONSTANT  VARCHAR2(8) := '22220005';--����״̬����ȷ����׼����

  cs_res_ruleerr    CONSTANT VARCHAR2(8) := '88880070'; --���ù����������
  cs_res_dberr      CONSTANT VARCHAR2(8) := '88880080'; --���ݴ���ͳ��
  cs_no_datafound_err  CONSTANT VARCHAR2(8) := '88880098';--δ�ҵ��κ�����
  cs_res_unknownerr CONSTANT VARCHAR2(8) := '88880099'; --δ֪����
  --------���������-----
  cs_res_kc1 CONSTANT VARCHAR2(8) := '11111001'; --�����ϸ����
  cs_res_kc2    CONSTANT VARCHAR2(8) := '11111002'; --����˻�����
  cs_res_kc3    CONSTANT VARCHAR2(8) := '11111003'; --�����±�����
  --------����������-----
  cs_res_apply1 CONSTANT VARCHAR2(8) := '11112001'; --������֤����
  cs_res_apply2 CONSTANT VARCHAR2(8) := '11112002'; --����״̬����ȷ
  cs_res_apply3 CONSTANT VARCHAR2(8) := '11112003'; --���챨��
  /*=======================================================================================*/
  --�ֽ��ַ���
  /*=======================================================================================*/
  FUNCTION f_splitstr(av_in      IN VARCHAR2,
                      av_partstr IN VARCHAR2,
                      av_out     OUT myarray) RETURN INT DETERMINISTIC;
  /*=======================================================================================*/
  --������av_start��av_end���ÿ�
  /*=======================================================================================*/
  PROCEDURE p_initarray(av_in    IN OUT myarray,
                        av_start NUMBER,
                        av_end   NUMBER);
  /*=======================================================================================*/
  --��ѯϵͳ����
  /*=======================================================================================*/
  FUNCTION f_getsyspara(av_paraname IN sys_para.para_code%TYPE --��������
                        ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --���ݿ��ŷ��ؿ�Ƭ���ڱ���
  /*=======================================================================================*/
  FUNCTION f_getcardtablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC;
  /*=======================================================================================*/
  --���ݿ��ŷ����˻����ڱ���
  /*=======================================================================================*/
  FUNCTION f_getsubledgertablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC;
  /*=======================================================================================*/
  --���ݿ��ŷ��ػ��ֹ��ɱ����ڱ���
  /*=======================================================================================*/
  FUNCTION f_getpointsperiodbycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC;
  /*=======================================================================================*/
  --���ݿ��š�������ڷ��ؿ�Ƭ���׼�¼�����ڱ���
  /*=======================================================================================*/
  FUNCTION f_gettrcardtable(av_cardno VARCHAR2, av_trdate DATE)
    RETURN VARCHAR2 DETERMINISTIC;
  /*=======================================================================================*/
  --�ǵ�����־
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog(av_remark   acc_rzcllog.remark%TYPE,
                            av_actionno NUMBER);
  /*=======================================================================================*/
  --�ǵ�����־
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog_(av_log_flag CHAR, --�Ƿ����־���أ�0��1��
                             av_remark   acc_rzcllog.remark%TYPE,
                             av_actionno NUMBER);
  /*=======================================================================================*/
  --���ݻ�����ȡ�����admin��Ա���
  /*=======================================================================================*/
  FUNCTION f_getorgoperid(av_orgid VARCHAR2 --�������
                          ) RETURN VARCHAR2 DETERMINISTIC;
  /*=======================================================================================*/
  --���ݻ�����ȡ�����admin��Ա
  /*=======================================================================================*/
  PROCEDURE p_getorgoperator(av_orgid    VARCHAR2, --�������
                             av_operator OUT sys_USERS%ROWTYPE, --��Ա
                             av_res      OUT VARCHAR2, --������������
                             av_msg      OUT VARCHAR2 --��������������Ϣ
                             );
  /*=======================================================================================*/
  --���ݿ����Ͳ�ѯ��Ŀ��--��ֵ����ֵʱ�õ�
  /*=======================================================================================*/
  FUNCTION f_getitemnobycardtype(av_cardtype VARCHAR2 --������
                                 ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --���ݿ�Ŀ�źͻ����Ų��һ������˻�
  /*=======================================================================================*/
  PROCEDURE p_getorgsubledger(av_orgid     VARCHAR2, --������
                              av_itemno    VARCHAR2, --��Ŀ��
                              av_subledger OUT acc_account_sub%ROWTYPE, --�ֻ���
                              av_res       OUT VARCHAR2, --������������
                              av_msg       OUT VARCHAR2 --��������������Ϣ
                              );
  /*=======================================================================================*/
  --���ݿ�Ŀ�ź�����Ų��ҷ��˻�
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbyclientid(av_clientid  VARCHAR2, --�ͻ���/�����
                                     av_itemno    VARCHAR2, --��Ŀ��
                                     av_subledger OUT acc_account_sub%ROWTYPE, --�ֻ���
                                     av_res       OUT VARCHAR2, --������������
                                     av_msg       OUT VARCHAR2 --��������������Ϣ
                                     );
  /*=======================================================================================*/
  --���ݿ��ź��˻����Ͳ��ҷ��˻�
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbycardno(av_cardno    VARCHAR2, --����
                                   av_acckind   VARCHAR2, --�˻�����
                                   av_walletid  IN acc_account_sub.wallet_no%TYPE, --Ǯ�����
                                   av_subledger OUT acc_account_sub%ROWTYPE, --�ֻ���
                                   av_res       OUT VARCHAR2, --������������
                                   av_msg       OUT VARCHAR2 --��������������Ϣ
                                   );
  /*=======================================================================================*/
  --���ݿ��ź��˻����Ͳ����˻����
  /*=======================================================================================*/
  FUNCTION f_getcardbalance(av_cardno   VARCHAR2, --����
                            av_acckind  VARCHAR2, --�˻�����
                            av_walletid VARCHAR2 --Ǯ�����
                            ) RETURN NUMBER;
  /*=======================================================================================*/
  --���ݿ��Ų��ҿ�Ƭ������Ϣ
  /*=======================================================================================*/
  PROCEDURE p_getcardbycardno(av_cardno VARCHAR2, --����
                              av_card   OUT card_baseinfo%ROWTYPE, --��Ƭ������Ϣ
                              av_res    OUT VARCHAR2, --������������
                              av_msg    OUT VARCHAR2 --��������������Ϣ
                              );
  /*=======================================================================================*/
  --���ݿ��Ų��ҿ�����
  /*=======================================================================================*/
  FUNCTION f_getcardtypebycardno(av_cardno VARCHAR2 --����
                                 ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --�����˺źͿ��Ų����˻�����
  /*=======================================================================================*/
  FUNCTION f_getacckindbyaccnoandcardno(av_accno  acc_account_sub.acc_no%TYPE, --�˺�
                                        av_cardno VARCHAR2 --����
                                        ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --���ݿ����Ͳ鿨������
  /*=======================================================================================*/
  PROCEDURE p_getcardparabycardtype(av_cardtype VARCHAR2, --������
                                    av_para     OUT card_config%ROWTYPE, --��������
                                    av_res      OUT VARCHAR2, --������������
                                    av_msg      OUT VARCHAR2 --��������������Ϣ
                                    );
  /*=======================================================================================*/
  --�жϿ���������
  /*=======================================================================================*/
  PROCEDURE p_judgetradepwd(av_card card_baseinfo%ROWTYPE, --����Ϣ
                            av_pwd  VARCHAR2, --����
                            av_res  OUT VARCHAR2, --������������
                            av_msg  OUT VARCHAR2 --��������������Ϣ
                            );

  /*=======================================================================================*/
  --�жϸ��˷�������
  /*=======================================================================================*/
  PROCEDURE p_judgeservicepwd(av_cert_no VARCHAR2, --֤������
                            av_customer_name VARCHAR2,--����
                            av_pwd  VARCHAR2, --����
                            av_res  OUT VARCHAR2, --������������
                            av_msg  OUT VARCHAR2 --��������������Ϣ
                            );
  PROCEDURE p_judgepaypwd(av_card_no VARCHAR2, --����
                        av_pwd  VARCHAR2, --����
                        av_res  OUT VARCHAR2, --������������
                        av_msg  OUT VARCHAR2 --��������������Ϣ
                        );
  PROCEDURE p_judgeacpt(av_acpt_type VARCHAR2,--���������
                        av_acpt_id  VARCHAR2, --�������/������
                        av_user_id  VARCHAR2, --�ն˺�/����Ա
                        av_res  out varchar2,--�������
                        av_msg  OUT VARCHAR2 --��������������Ϣ
                        ) ;
  /*=======================================================================================*/
  --�ж�Ԥ����޶�
  /*=======================================================================================*/
  PROCEDURE p_judgebranchagentlimit(av_brchid  VARCHAR2, --������
                                    av_balance NUMBER, --�۳������Ԥ������
                                    av_res     OUT VARCHAR2, --������������
                                    av_msg     OUT VARCHAR2 --��������������Ϣ
                                    );
  /*=======================================================================================*/
  --�жϿ�״̬�¸ý����Ƿ�׼��
  /*=======================================================================================*/
  PROCEDURE p_judgecardstatebandeal(av_card_no  VARCHAR2, --����
                                    av_deal_code VARCHAR2, --���״���
                                    av_res     OUT VARCHAR2, --������������
                                    av_msg     OUT VARCHAR2 --��������������Ϣ
                                    );
  /*=======================================================================================*/
  --�ж�ĳ���˻����ͺͿ����жϴν����Ƿ���ȷ
  /*=======================================================================================*/
  PROCEDURE p_judgecardacciftrade(av_card_no  VARCHAR2, --����
                                    av_acc_kind VARCHAR2, --���״���
                                    av_amt      VARCHAR2,--���׽��
                                    av_pwd_falg  NUMBER,--�����Ƿ��������� 0 �� 1 ��
                                    av_res     OUT VARCHAR2, --������������
                                    av_msg     OUT VARCHAR2 --��������������Ϣ
                                    );
  /*=======================================================================================*/
  --ȡ�������
  /*=======================================================================================*/
  PROCEDURE p_getinputpara(av_in        IN VARCHAR2, --�������
                           av_minnum    IN NUMBER, --�������ٸ���
                           av_maxnum    IN NUMBER, --����������
                           av_procedure IN VARCHAR2, --���õĺ�����
                           av_out       OUT myarray, --ת���ɲ�������
                           av_res       OUT VARCHAR2, --������������
                           av_msg       OUT VARCHAR2 --��������������Ϣ
                           );
  /*=======================================================================================*/
  --���ݴ����sql����ִ��sql
  /*=======================================================================================*/
  PROCEDURE p_dealsqlbyarray(av_varlist IN strarray);
  /*=======================================================================================*/
  --��ȡ����ʱ��������
  /*=======================================================================================*/
  FUNCTION f_timestamp_diff(endtime IN TIMESTAMP, starttime IN TIMESTAMP)
    RETURN INTEGER;
   /*=======================================================================================*/
  --����ڶ�����У��λ
  /*=======================================================================================*/

    FUNCTION createSubCardNo(prefix in varchar2,seq in varchar2) return varchar2;


    /*====================================================================================
    ���ݿͻ���Ż�ȡ�ͻ���Ϣ
    */
    PROCEDURE p_getBasePersonalByCustomerId(av_customer_id BASE_PERSONAL.CUSTOMER_ID%TYPE,
                                            av_base_personal OUT base_personal%ROWTYPE,
                                            av_res OUT VARCHAR2,
                                            av_msg OUT VARCHAR2);
    /*====================================================================================
    ����֤�������ȡ�ͻ���Ϣ
    */
    PROCEDURE p_getBasePersonalByCertNo(av_cert_no BASE_PERSONAL.CERT_NO%TYPE,
                                        av_base_personal OUT base_personal%ROWTYPE,
                                        av_res OUT VARCHAR2,
                                        av_msg OUT VARCHAR2);
END pk_public;
/

