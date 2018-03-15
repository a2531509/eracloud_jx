create or replace package pk_co_org_handle is

  -- Author  : ADMINISTRATOR
  -- Created : 2015/7/23 13:54:39
  -- Purpose : 合作机构结相关错作

  /*=======================================================================================*/
  --对一个合作机构结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_co_org_id  IN base_co_org.co_org_id%TYPE, --机构号
                     av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2 --传出错误信息
                     );

  /*=======================================================================================*/
  --对所有合作结构进行结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2 --传出错误信息
                     );

  /*=======================================================================================*/
  --对所有合作机构进行结算的job
  /*=======================================================================================*/
  PROCEDURE p_job;

  /*=======================================================================================*/
  --合作机构结算回退
  /*=======================================================================================*/
  PROCEDURE p_settlerollback(av_stlsumno IN stl_co_deal_sum.stl_sum_no%TYPE, --合作机构结算汇总序号
                             av_res      OUT VARCHAR2, --传出代码
                             av_msg      OUT VARCHAR2 --传出错误信息
                             );


  /*=======================================================================================*/
  --合作机构对账
  /*=======================================================================================*/
 PROCEDURE p_check_bill(av_co_org_id IN base_co_org.co_org_id%TYPE, --合作机构编号
                               av_acpt_id   IN VARCHAR2,--代理点编号
                               av_batch_id  IN VARCHAR2,--批次号
                               av_end_id    IN VARCHAR2,--终端号/柜员号
                               av_check_type IN VARCHAR2,--对账类型 01 充值 02 消费
                               av_check_filenmae IN VARCHAR2, --对账文件名
                               av_check_date IN VARCHAR2, --对账日期yyyymm
                               av_check_zc_sum  IN NUMBER,--对账正常总笔数
                               av_check_zc_amt  IN NUMBER,--对账正常总金额
                               --av_check_cx_sum  IN NUMBER,--对账撤销笔数
                               --av_check_cx_amt  IN NUMBER,--对账撤销金额
                               av_check_th_sum  IN NUMBER,--对账退货笔数
                               av_check_th_amt  IN NUMBER,--对账退货金额
                               av_res      OUT VARCHAR2, --传出代码
                               av_msg      OUT VARCHAR2 --传出错误信息
                             );
 /*=======================================================================================*/
  --合作机构对账明细入库
  /*=======================================================================================*/

  procedure p_check_bill_implist(av_co_org_id IN base_co_org.co_org_id%TYPE, --合作机构编号
                       av_acpt_id IN VARCHAR2, --代理网点编号
                       av_termid in varchar2,--终端号/柜员号
                       av_trbatchno in varchar2,--批次号
                       av_trserno in varchar2,--终端流水
                       av_cardno in varchar2,-- 卡号
                       av_bank_id in varchar2,--银行编号
                       av_bank_acc in varchar2,--银行账户
                       av_cr_card_no in varchar2,--转入卡卡号
                       av_cr_acc_kind in varchar2,--转入账户类型
                       av_db_card_no in varchar2,--转出卡卡号
                       av_db_acc_kind in varchar2,--转出账户类型
                       av_acc_bal in varchar2,--交易金额
                       av_deal_count in varchar2,--交易序号
                       av_tramt  in number,--交易金额
                       av_trdate in varchar2,--yyyy-mm-dd hh24:mi:ss
                       av_actionno in number,--业务流水号
                       av_clrdate in varchar2,--yyyy-mm-dd
                       av_co_clrdate in varchar2, --yyyy-mm-dd
                       av_file_line in varchar2,--文件行号
                       av_deal_code IN VARCHAR2,-- 交易代码
                       av_res      OUT VARCHAR2, --传出代码
                       av_msg      OUT VARCHAR2 --传出错误信息
                       );


 /*=======================================================================================*/
  --合作机构对账明细对账
  /*=======================================================================================*/

  PROCEDURE  p_check_list_bill(av_co_org_id  IN base_co_org.co_org_id%TYPE,--合作机构
                               av_acpt_id   IN VARCHAR2,--代理网点编号
                               av_clr_date IN VARCHAR2,--对账日期
                               av_res      OUT VARCHAR2, --传出代码
                               av_msg      OUT VARCHAR2 --传出错误信息
                               );
end pk_co_org_handle;
/

