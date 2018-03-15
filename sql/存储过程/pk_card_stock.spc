create or replace package pk_card_Stock IS
  goods_state_zc   constant varchar2(1) := '0';--正常
  goods_state_zlwt constant varchar2(1) := '2';--质量问题
  goods_state_hs   constant varchar2(1) := '1';--回收卡代处理
  goods_state_bf   constant varchar2(1) := '9';--报废

  /**
  *更换库存
  */
  procedure p_updateCardStock(p_cardNo  in varchar2, --新卡号
                            p_cardNo2 in varchar2, --老卡号
                            p_dealno  in integer, --流水号
                            as_outMsg out varchar2, --错误代码
                            as_res    out varchar2); --错误描述
  --柜员库存账户开户
  --参数说明：
  --1受理点编号/网点编号 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 必填
  --4终端操作流水 选填
  --5待开户柜员所属网点 必填
  --6待开户柜员编号 必填
  --7开户库存类型 选填 空值时,所有的库存类型都将分别建账户
  --8开户库存类型状态 选填 空值时,一个库存类型的所有状态都建账户
  --9备注
  PROCEDURE p_stockacc_open(av_in IN VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --库存物品配送
  --参数说明：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7库存类型 stk_code 必填
  --8出网点out_brch_id 必填
  --9出柜员out_user_id 必填
  --10出物品状态out_goods_state  必填
  --11收网点in_brch_id 必填
  --12收柜员in_user_id 必填
  --13收物品状态in_goods_state  必填
  --14库存交换方式 deliveryWay = 1时按照任务，deliveryWay = 2时按照卡号段 当为"1"时 15必填 当为"2"时 16、17必填
  --15任务编号 taskIds
  --16起始物品号码 begin_googds_no
  --17结束物品号码 end_goods_no
  --18物品数量总数量 必填
  --19note备注
  PROCEDURE p_stock_delivery(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --库存配送确认
  --请求参数：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 选填
  --5任务编号dealnos待确认流水号多个流水号逗号隔开如 1,2,3,4,5,6 必填
  --返回参数：
  --av_res 处理结果代码
  --av_msg 处理结果说明
  --av_out 成功处理任务的个数
  PROCEDURE p_stock_delivery_confirm(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2,av_out OUT NUMBER);

  --库存配送取消 配送、配送确认、配送取消必须按照任务方式进行
  --请求参数：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 选填
  --5库存流水dealnos待确认流水号多个流水号逗号隔开如 1,2,3,4,5,6 必填
  --6交易码deal_code
  --7交易时间 deal_time
  --8备注 note
  --返回参数：
  --av_res 处理结果代码
  --av_msg 处理结果说明
  --av_out成功处理任务的个数
  PROCEDURE p_stock_delivery_cancel(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2,av_out OUT NUMBER);

  --柜员之间库存交换 领用
  --参数说明：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7库存类型 stk_code 必填
  --8库存物品状态goods_state
  --9出网点out_brch_id 必填
  --10出柜员out_user_id 必填
  --11收网点in_brch_id 必填
  --12收柜员in_user_id 必填
  --13库存交换方式 deliveryWay = 1时按照任务，deliveryWay = 2时按照卡号段 当为"1"时 14必填 当为"2"时 15、16必填
  --14任务编号 taskIds
  --15起始物品号码 begin_googds_no
  --16结束物品号码 end_goods_no
  --17物品数量总数量 必填
  --18note备注
  PROCEDURE p_stock_exchange(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --CardBaseinfo发放，个人发放，规模发放
  --参数说明：
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7卡号card_no
  --8任务编号task_id
  --9备注note
  PROCEDURE p_card_release(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --库存物品入库
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7库存类型STK_CODE
  --8物品编号id GOODS_ID
  --9物品编号GOODS_NO
  --10物品状态GOODS_STATE
  --11所属批次BATCH_ID
  --12所属任务TASK_ID
  --13是否确认STK_IS_SURE
  --14入库网点IN_BRCH_ID
  --15入库柜员IN_USER_ID
  --16入库流水IN_DEAL_NO
  --17归属类型OWN_TYPE
  --18归属机构ORG_ID
  --19归属网点BRCH_ID
  --20归属柜员USER_ID
  --21备注NOTE
  PROCEDURE p_in_stock(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --库存物品入库
  --参数说明
  --1受理点编号/网点编号 brch_id/acpt_id 必填
  --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号 user_id/end_id 必填
  --4终端操作流水/业务流水 deal_no/end_deal_no 必填
  --5交易代码 deal_code 必填
  --6业务操作时间 deal_time 必填
  --7旧物品编号Old_GOODS_NO
  --8新物品编号new_goods_no
  --9备注NOTE
  PROCEDURE p_bhk(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2);

  --卡回收登记   收回卡
   --参数说明
   --1受理点编号/网点编号 brch_id/acpt_id 必填
   --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
   --3终端编号/柜员编号 user_id/end_id 必填
   --4终端操作流水/业务流水 deal_no/end_deal_no 必填
   --5交易代码 deal_code 必填
   --6业务操作时间 deal_time 必填
   --7物品编号/卡号
   --8回收目标库存状态 默认 1 回收代处理
   --9备注NOTE
   procedure p_hsdj(av_in varchar2,av_res out varchar2,av_msg out varchar2);
   --物品出库
   --参数说明
   --1受理点编号/网点编号 brch_id/acpt_id 必填
   --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
   --3终端编号/柜员编号 user_id/end_id 必填
   --4终端操作流水/业务流水 deal_no/end_deal_no 必填
   --5交易代码 deal_code 必填
   --6业务操作时间 deal_time 必填
   --7物品编号/卡号
   --8目标库存状态 默认不修改原库存明细状态 出库后需要将库存明细修改到什么状态
   -- 一般不需要传入，但是如补换卡撤销时需要传入0 正常，因为补换卡操作后库存明细变为质量问题状态，撤销时需要回复到正常状态
   --9是否校验所属人信息  默认是否卡操作
   --10备注note
   procedure p_out_stock(av_in varchar2,av_res out varchar2,av_msg out varchar2);

   --柜员交接
   --参数说明
   --1受理点编号/网点编号 brch_id/acpt_id 必填
   --2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
   --3终端编号/柜员编号 user_id/end_id 必填
   --4终端操作流水/业务流水 deal_no/end_deal_no 必填
   --5交易代码
   --6交易时间
   --7出网点
   --8出柜员
   --9收网点
   --10收柜员
   --11库存类型
   --12库存状态
   --13备注
   procedure p_teller_jj(av_in varchar2,av_res out varchar2,av_msg out varchar2);

  --根据卡号获取卡信息
  --av_goods_no 物品编号
  --av_stock_list 物品信息
  --av_res 处理结果代码
  --av_res 处理结果说明
  PROCEDURE p_getCardBaseinfo(av_card_no card_baseinfo.card_no%TYPE,
                           av_card_baseinfo OUT card_baseinfo%ROWTYPE,
                           av_res OUT VARCHAR2,
                           av_msg OUT VARCHAR2);

   --根据物品编号获取物品信息
   --av_goods_no 物品编号
   --av_stock_list 物品信息
   --av_res 处理结果代码
   --av_res 处理结果说明
  PROCEDURE p_getStockListByGoodsNo(av_goods_no stock_list.goods_no%TYPE,
                           av_stock_list OUT stock_list%ROWTYPE,
                           av_res OUT VARCHAR2,
                           av_msg OUT VARCHAR2);

  --根据任务编号获取任务信息
  --av_task_id 任务编号
  --av_card_apply_task 任务信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE p_getCardApplyTaskByTaskId(av_task_id card_apply_task.task_id%TYPE,
                                        av_card_apply_task OUT card_apply_task%ROWTYPE,
                                        av_res OUT VARCHAR2,
                                        av_msg OUT VARCHAR2
                                        );

  --根据user_id,stk_code,stk_goods_state获取库存账户
  --柜员user_id
  --库存代码
  --物品状态
  --库存信息
  --返回代码
  --返回信息
  PROCEDURE p_getStock_Acc(
                          av_brch_id VARCHAR2,
                          av_user_id VARCHAR2,
                          av_stk_code VARCHAR2,
                          av_stk_goods_state VARCHAR2,
                          av_stock_acc OUT stock_acc%ROWTYPE,
                          av_res OUT VARCHAR2,
                          av_msg OUT VARCHAR2);

  --获取库存代码获取库存类型信息
  --lv_stk_code 库存代码
  --lv_stock_type 库存类型信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE p_getStock_Type(lv_stk_code stock_type.stk_code%TYPE,
                            lv_stock_type OUT stock_type%ROWTYPE,
                            av_res OUT VARCHAR2,
                            av_msg OUT VARCHAR2
                            );

  --判断卡段是否是同属一个任务且号段是否连续
  --av_user_id 所属柜员
  --av_begin_goods_no 起始卡号
  --av_end_goods_no 截止卡号
  --av_card_apply_task 所属任务
  --av_res 处理结果代码
  --av_msg 处理结果说明
  FUNCTION f_judgeCardRange( av_user_id stock_list.user_id%TYPE,
                           av_begin_goods_no stock_list.goods_no%TYPE,
                           av_end_goods_no stock_list.goods_no%TYPE,
                           av_card_apply_task OUT card_apply_task%ROWTYPE,
                           av_res OUT VARCHAR2,
                           av_msg OUT VARCHAR
                           ) RETURN NUMBER;
   --制卡数据导入
   PROCEDURE pk_Import_CardData(av_in VARCHAR2,
                                av_res OUT VARCHAR2,
                                av_msg OUT VARCHAR2,
                                av_out OUT VARCHAR2);

  --根据网点编号,柜员编号获取柜员信息
  -- 所属网点
  --柜员编号
  --处理结果编号
  --处理结果说明
  --初始化语句
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

