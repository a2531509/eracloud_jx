CREATE OR REPLACE PACKAGE pk_posmanage IS
  -- Purpose : posmanage
  /*=======================================================================================*/
  --签到
  /*=======================================================================================*/
  PROCEDURE p_login(av_bizid  IN VARCHAR2, --商户号
                    av_termid IN VARCHAR2, --终端号
                    av_operid IN VARCHAR2, --操作员编号
                    av_Device_No IN VARCHAR2,--设备号
                    av_res    OUT VARCHAR2, --返回码 00 成功
                    av_msg    OUT VARCHAR2, --传出参数错误信息
                    av_table  OUT pk_public.t_cur);
  /*=======================================================================================*/
  --签退
  /*=======================================================================================*/
  PROCEDURE p_logout(av_bizid      IN VARCHAR2, --商户号
                     av_termid     IN VARCHAR2, --终端号
                     av_Device_No IN VARCHAR2,--设备号
                     --av_trbatchno1 IN VARCHAR2, --批次号
                     av_res        OUT VARCHAR2, --返回码 00 成功
                     av_msg        OUT VARCHAR2 --传出参数错误信息
                     --av_actionno   OUT VARCHAR2, --pos中心流水号
                     --av_trbatchno2 OUT VARCHAR2 --批次号
                     );
  /*=======================================================================================*/
  --心跳
  /*=======================================================================================*/
  PROCEDURE p_heart(av_bizid  IN VARCHAR2, --商户号
                    av_termid IN VARCHAR2, --终端号
                    av_operid IN VARCHAR2, --操作员编号
                    av_Device_No IN VARCHAR2,--设备号
                    av_res    OUT VARCHAR2, --返回码 00 成功
                    av_msg    OUT VARCHAR2, --传出参数错误信息
                    av_table  OUT pk_public.t_cur);
  /*=======================================================================================*/
  --下载黑名单
  /*=======================================================================================*/
  PROCEDURE p_downblackcard(av_bizid       IN VARCHAR2, --商户号
                            av_termid      IN VARCHAR2, --终端号
                            av_Device_No IN VARCHAR2,--设备号
                            av_regno       in varchar2, --终端上的市场登记号
                            av_count       IN INTEGER, --每次传送的记录数
                            av_next        INTEGER, --下一条条记录的开始号
                            av_version     INTEGER, --终端版本号
                            av_res         OUT VARCHAR2, --返回码 00 成功
                            av_msg         OUT VARCHAR2, --传出参数错误信息
                            av_followstate OUT INTEGER, --后续包状态：1表示有后续包，0表示没有后续包
                            av_maxversion  OUT INTEGER, --版本号
                            av_table       OUT pk_public.t_cur);
  /*=======================================================================================*/
  --下载参数，主要包括当前市场登记号，以及ftp等参数
  /*=======================================================================================*/
  PROCEDURE p_downparam(av_bizid  IN VARCHAR2, --商户号，接口中的商户号是可为空，为何？？
                        av_termid IN VARCHAR2, --终端号
                        av_Device_No IN VARCHAR2, --设备号
                        av_res    OUT VARCHAR2, --返回码 00 成功
                        av_msg    OUT VARCHAR2, --传出参数错误信息
                        av_table  OUT pk_public.t_cur);

  /*=======================================================================================*/
  --商户交易查询
  /*=======================================================================================*/
  PROCEDURE p_merchant_trans(av_bizid       IN VARCHAR2, --商户号
                             av_termid      IN VARCHAR2, --终端号
                             av_clrdate     in varchar2, --清算日期yyyymmdd
                             av_acckind     in varchar2, --账户类型，01钱包，02联机
                             av_count       IN INTEGER, --每次传送的记录数
                             av_next        INTEGER, --下一条记录的开始号,从1开始
                             av_res         OUT VARCHAR2, --返回码 00 成功
                             av_msg         OUT VARCHAR2, --传出参数错误信息
                             av_followstate OUT INTEGER, --后续包状态：1表示有后续包，0表示没有后续包
                             av_totalcount OUT INTEGER, --总记录数
                             av_table       OUT pk_public.t_cur) ;
  /*=======================================================================================*/
  --保存上传文件名
  /*=======================================================================================*/
  PROCEDURE p_saveFileName(av_filename VARCHAR2,
                           av_filetype varchar2, --文件类型，可扩展,XF消费,ZK折扣,QD签到
                           av_bizid    VARCHAR2);

  /*=======================================================================================*/
  --结算对账
  --av_in
  --     1pbiz_id                      商户号
  --     2pterm_id                     终端号
  --     3pch                          批次号
  --     4pconsumenormolnum            正常消费笔数
  --     5pconsumenormolamt            正常消费金额
  --     6pconsumecancelnum            撤销消费笔数
  --     7pconsumecancelamt            撤销消费金额
  --     8pconsumereturnnum            消费退货笔数
  --     9pconsumereturnamt            消费退货金额
  /*=======================================================================================*/
  procedure pos_BalanceAccount(
                          av_in      IN VARCHAR2,
                          av_res         OUT VARCHAR2, --返回码 00 成功
                          av_msg         OUT VARCHAR2, --传出参数错误信息
                          av_check_flag  OUT VARCHAR2, --0对账平 1 对账不平
                          rAction_No out varchar2,         --POS中心流水号
                          rconsumeCount out integer,       --正常消费(包括脱机和联机) 交易总笔数
                          rconsumeFee out float,           --正常消费(包括脱机和联机)  交易总金额
                          rconsumereturncount OUT INTEGER,  --退货 交易总笔数
                          rconsumereturnamt   OUT INTEGER,  --退货 交易总金额
                          rcancelCount out integer,        --撤销笔数
                          rcancelFee out float             --撤销金额
                       );
END pk_posmanage;
/

