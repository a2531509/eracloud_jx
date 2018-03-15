CREATE OR REPLACE PACKAGE PK_SERVICE_OUTER IS
  -- AUTHOR  : ADMINISTRATOR
  -- CREATED : 2016-02-18 15:42:24
  -- PURPOSE : 外围调用接口

  -- PUBLIC TYPE DECLARATIONS
  -- 类型，常量定义部分

  -- PUBLIC FUNCTION AND PROCEDURE DECLARATIONS
  -- 过程，函数定义部分

  --接入受理点类型判断
  PROCEDURE P_JUDGE_ACPT(AV_ACPT_ID     VARCHAR2, --受理点类型
                         AV_ACPT_TYPE   VARCHAR2, --受理点编号/网点编号
                         AV_USER_ID     VARCHAR2, --终端号/操作员
                         AV_SYS_USERS   OUT SYS_USERS%ROWTYPE,
                         AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE,
                         AV_RES         OUT VARCHAR2, --传入代码
                         AV_MSG         OUT VARCHAR2 --传出参数错误信息
                         );
  --个人登录
  PROCEDURE P_LOGIN_GR(AV_CARD_NO VARCHAR2, --卡号
                       AV_CERT_NO VARCHAR2, --证件号码
                       AV_TELNO   VARCHAR2, --手机号码
                       AV_PWD     VARCHAR2, --登录密码
                        AV_CERTNO  OUT VARCHAR2,--证件号
                       AV_RES     OUT VARCHAR2, --处理结果代码
                       AV_MSG     OUT VARCHAR2 --处理结果说明
                       );

  --合作机构登录
  PROCEDURE P_LOGIN_CO_ORG(AV_CO_ORG_ID VARCHAR2, --合作机构编号
                           AV_PWD       VARCHAR2, --密码
                           AV_RES       OUT VARCHAR2, --结果代码
                           AV_MSG       OUT VARCHAR2); --结果说明

  --密码修改
  --1acpt_id 受理点编号
  --2acpt_type 受理点类型
  --3oper_id 操作员
  --4trim_no 终端业务流水
  --5cert_no 证件号码
  --6card_no 卡号
  --7pwd_type 密码类型
  --8old_pwd 老密码
  --9pwd 新密码
  --10agt_cert_type 代理人证件号码
  --11agt_cert_type 代理人证件类型
  --12agt_name 代理人姓名
  --13agt_telno 代理人电话号码
  PROCEDURE P_PWD_MODIFY(AV_IN  VARCHAR2,
                         AV_RES OUT VARCHAR2,
                         AV_MSG OUT VARCHAR2);

  -- 挂失
  -- 1受理点编号/网点编号 brch_id/acpt_id 必填
  -- 2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  -- 3终端编号/柜员编号 user_id/end_id 必填
  -- 4终端操作流水/业务流水 deal_no/end_deal_no 必填
  -- 5证件号码 cert_no
  -- 6卡号 card_no
  -- 7挂失类型 loss_type  2口挂挂失  3 书面挂失
  -- 8代理人证件类型
  -- 9代理人证件号码
  -- 10代理人姓名
  -- 11代理人联系电话
  -- 12备注note
  -- 返回结果
  -- av_res 返回结果代码
  -- av_msg 返回结果说明
  -- av_out 输出结果
  -- 测试  10011001|1|admin||4128222198605264479||3|||||test|
  PROCEDURE p_Card_Loss(av_in  VARCHAR2,
                        av_res OUT VARCHAR2,
                        av_msg OUT VARCHAR2,
                        av_out OUT VARCHAR2);

  -- 解挂
  -- 1受理点编号/网点编号 brch_id/acpt_id 必填
  -- 2受理点类型 acpt_type 必填 (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  -- 3终端编号/柜员编号 user_id/end_id 必填
  -- 4终端操作流水/业务流水 deal_no/end_deal_no 必填
  -- 5证件号码 cert_no
  -- 6卡号 card_no
  -- 7代理人证件类型
  -- 8代理人证件号码
  -- 9代理人姓名
  -- 10代理人联系电话
  -- 11备注note
  -- 返回结果
  -- av_res 返回结果代码
  -- av_msg 返回结果说明
  -- av_out 输出结果
  PROCEDURE p_Card_Unlock(av_in  VARCHAR2,
                          av_res OUT VARCHAR2,
                          av_msg OUT VARCHAR2,
                          av_out OUT VARCHAR2);

  --补换卡
  --av_in:
  --1受理点编号/网点编号
  --2受理点类型 acpt_type (1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
  --3终端编号/柜员编号
  --4终端操作流水
  --5原卡卡号
  --6新卡卡号
  --7银行卡卡号
  --8姓名
  --9证件类型
  --10证件号码
  --11是否好卡 0好卡 坏卡：1
  --12卡面金额 根据参数10 如果是0 好卡 则传递卡面金额 如果是 1坏卡 传递0 金额单位：分,如果是好卡则在换卡转钱包时 转账此金额
  --13回收状态：回收：0 未回收：1
  --14补换卡标志 0 补卡 1 换卡
  --15换卡时 传递换卡原因 01换卡原因_质量问题,02换卡原因_损坏,05换卡原因_有效期满,99换卡原因_其他
  --16补换卡工本费 金额单位：分
  --17代理人证件类型
  --18代理人证件号码
  --19代理人姓名
  --20代理人联系电话
  --21备注
  PROCEDURE P_CARDTRANS(AV_IN    IN VARCHAR2, --传入参数
                        AV_DEBUG IN VARCHAR2, --1调试
                        AV_OUT   OUT VARCHAR2, --返回信息
                        AV_RES   OUT VARCHAR2, --传出代码
                        AV_MSG   OUT VARCHAR2 --传出错误信息
                        );

  --本地制卡登记
  --1.网点
  --2.柜员
  --3.非接上电复位信息
  --4.非接触卡号
  --5.接接触上电复位信息
  --6.卡识别码
  --7.状态 0 入库  1 废卡登记
  --8.制卡流水
  --9.备注
  PROCEDURE P_LOCAL_MAKECARD_REG(AV_IN IN VARCHAR2,AV_RES OUT VARCHAR2,AV_MSG OUT VARCHAR2);

  --换卡转钱包记灰记录
  PROCEDURE P_BHK_ZZ_TJ(AV_IN  VARCHAR2,
                        AV_OUT OUT VARCHAR2,
                        AV_RES OUT VARCHAR2,
                        AV_MSG OUT VARCHAR2);

  --换卡转钱包灰记录确认
  PROCEDURE P_BHK_ZZ_TJ_CONFIRM(AV_IN  VARCHAR2,
                                AV_RES OUT VARCHAR2,
                                AV_MSG OUT VARCHAR2);
  --换卡转钱包灰记录取消
  PROCEDURE P_BHKZZ_TJ_CANCEL(AV_DEAL_NO VARCHAR2, --业务流水
                              AV_RES     OUT VARCHAR2, --处理结果代码
                              AV_MSG     OUT VARCHAR2 --处理结果代码
                              );

  --卡发放（银行操作）
  --av_in
  --1.受理点编号
  --2.受理点类型
  --3.操作员
  --4.操作流水
  --5.卡号
  --6.银行卡卡号
  --7.固定电话
  --8.手机号码
  --9.银行卡激活标志
  --10.代理人证件类型
  --11.代理人证件号码
  --12.代理人姓名
  --13.代理人联系电话
  --14.备注
  PROCEDURE P_BANK_KFF(AV_IN VARCHAR2,AV_RES OUT VARCHAR2,AV_MSG OUT VARCHAR2,AV_OUT OUT VARCHAR2);

  --银行卡注销
  --av_in
  --1.受理点编号
  --2.受理点类型
  --3.操作员
  --4.操作流水
  --5.市民卡卡号
  --6.银行卡卡号
  --7.银行注销时间 YYYY-MM-DD HH24:MI:SS
  --8.代理人证件类型
  --9.代理人证件号码
  --10.代理人姓名
  --11.代理人电话
  --12.备注
  PROCEDURE P_BANK_ZX(AV_IN  VARCHAR2,
                      AV_RES OUT VARCHAR2,
                      AV_MSG OUT VARCHAR2);
  --个人交易信息查询
  PROCEDURE P_CONSUME_RECHARGE_QUERY(AV_CARD_NO    VARCHAR2, --卡号
                                     AV_DEAL_TYPE  VARCHAR2, --查询交易类型 0 查询所有 1 查询充值  2 查询消费
                                     AV_ACC_KIND   VARCHAR2, --账户类型
                                     AV_START_DATE VARCHAR2, --查询起始日期
                                     AV_END_DATE   VARCHAR2, --查询结束日期
                                     AV_PAGE_NO    NUMBER, --第几页
                                     AV_PCOUNT     NUMBER, --每页多少条
                                     AV_ORDERBY    VARCHAR2, --排序字段
                                     AV_ORDER      VARCHAR2, --顺序 asc 升序  desc 降序
                                     AV_ALL_SIZE   OUT NUMBER,
                                     AV_ALL_PAGE   OUT NUMBER,
                                     AV_DATA       OUT ZPAGE.DEFAULT_CURSOR, --结果数据
                                     AV_RES        OUT VARCHAR2, --处理结果代码
                                     AV_MSG        OUT VARCHAR2 --处理结果说明
                                     );

  --根据9位的社保卡卡号获取20位非接卡号
  FUNCTION F_GETCARDNO_BY_SUBCARDNO(AV_SUB_CARD_NO VARCHAR2, --社保卡卡号
                                    AV_CARD_APPLY  OUT CARD_APPLY%ROWTYPE)
    RETURN VARCHAR2;

  --根据银行卡卡号获取对应的卡号信息
  --根据银行卡卡号获取对应的卡号信息
  procedure p_getBcpCard(av_bank_card_no card_task_imp_bcp.bank_card_no%type,
                         lv_card_task_bcp out card_task_imp_bcp%rowtype,
                         av_res out varchar2,
                         av_msg out varchar2);
  --黑名单操作
  PROCEDURE P_CARD_BLACK(AV_DEAL_NO   CARD_BLACK_REC.DEAL_NO%TYPE, --业务流水
                         AV_CARD_NO   CARD_BASEINFO.CARD_NO%TYPE, --黑名单操作的卡
                         AV_STL_STATE VARCHAR2, --操作黑名单状态  0 增加黑名单  1 减去黑名单
                         AV_STL_TYPE  VARCHAR2, --当AV_STL_STATE = 0 增加黑名单时 需要传递黑名单类型 01 补卡 02 换卡 09 注销
                         AV_DEAL_TIME VARCHAR2, --操作时间  格式：YYYYMMDDHH24MISS
                         AV_RES       OUT VARCHAR2,
                         AV_MSG       OUT VARCHAR2);

  --申请制卡  适用江阴
  --av_in: 1姓名
  --       2性别
  --       3证件类型
  --       4证件号码
  --       5市民卡卡号
  --       6户籍所在城区
  --       7户籍所在乡镇（街道）
  --       8户籍所在村（社区）
  --       9居住地址
  --      10联系地址
  --      11邮政编码
  --      12固定电话
  --      13手机号码
  --      14电子邮件
  --      15单位客户名称
  --      16受卡机终端标识码
  --      17受卡方的标识码
  --      18柜员号
  --      19备注
  -- av_out：1持卡人姓名
  --         2持卡人性别
  --         3持卡人证件类型
  --         4持卡人证件号码
  --         5卡主类型 01
  --         6卡子类型 00
  --         7卡有效日期
  --         8启用标志
  --         9公共钱包应用启动日期
  --         10公共钱包应用有效日期
  PROCEDURE p_applyCard(av_in    IN VARCHAR2, --传入参数
                        av_debug IN VARCHAR2, --1调试
                        av_out   OUT VARCHAR2, --返回信息
                        av_res   OUT VARCHAR2, --传出代码
                        av_msg   OUT VARCHAR2 --传出错误信息
                        );

  --开发放 适用江阴
  --av_in: 1卡号
  --       2证件类型
  --       3证件号码
  --       4姓名
  --       5开户银行
  --       6卫生卡号
  --       7卡类型
  --       8受卡方的标识码
  --       9柜员号
  --       10备注
  --       11 是否有老卡 0 是 1 否
  --       12 老卡卡号
  PROCEDURE p_openAccandCard(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1调试
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             );
  --更新个人信息
  --av_in: 1证件号码
  --       2手机号
  --       3家庭住址
  --       4家庭联系电话
  --       5柜员号
  --       6微信号

  PROCEDURE p_updatePersonalInfo(av_in    IN VARCHAR2, --传入参数
                                 av_debug IN VARCHAR2, --1调试
                                 av_res   OUT VARCHAR2, --传出代码
                                 av_msg   OUT VARCHAR2 --传出错误信息
                                 );
  --更新合作机构信息
  -- av_in:1合作机构编号
  --       2机构住址
  --       3机构联系电话
  --       4柜员号

  PROCEDURE p_update_Co_Org(av_in    IN VARCHAR2, --传入参数
                                 av_debug IN VARCHAR2, --1调试
                                 av_res   OUT VARCHAR2, --传出代码
                                 av_msg   OUT VARCHAR2 --传出错误信息
                                 );
  --合作机构服务密码修改
  --1：bizid 合作机构号
  --2：oper_id 操作员
  --3：old_pwd 老密码
  --4：new_pwd 新密码
  PROCEDURE P_Update_Co_Org_Pwd(AV_IN  VARCHAR2,
                         AV_RES OUT VARCHAR2,
                         AV_MSG OUT VARCHAR2);
    --合作机构交易信息查询
  PROCEDURE P_Co_Org_Query(AV_Co_org_Id    VARCHAR2, --机构编号
                           AV_DEAL_TYPE  VARCHAR2, --查询交易类型 0 查询所有 1 查询充值  2 查询消费
                           AV_ITEM_NO   VARCHAR2, --科目类型
                           AV_START_DATE VARCHAR2, --查询起始日期
                           AV_END_DATE   VARCHAR2, --查询结束日期
                           AV_PAGE_NO    NUMBER, --第几页
                           AV_PCOUNT     NUMBER, --每页多少条
                           AV_ORDERBY    VARCHAR2, --排序字段
                           AV_ORDER      VARCHAR2, --顺序 asc 升序  desc 降序
                           AV_ALL_SIZE   OUT NUMBER,
                           AV_ALL_PAGE   OUT NUMBER,
                           AV_DATA       OUT ZPAGE.DEFAULT_CURSOR, --结果数据
                           AV_RES        OUT VARCHAR2, --处理结果代码
                           AV_MSG        OUT VARCHAR2 --处理结果说明
                           );

  --录入市民卡保单信息
  -- av_in:1合作机构编号
  -- 2 保单编号
  -- 3 市民卡卡号
  -- 4 客户姓名
  -- 5 身份证号
  -- 6 社会保障号
  -- 7 购买时间
  -- 8 应用状态(投保状态）<1已购买、未出单>、<2已购买、出单中>、<3已生效>、<4已过期>';
  -- 9 保险名称
  -- 10 投保金额
  -- 11 保单有效期（起止）
  -- 12 网点编号
  -- 13 操作人员编号

  PROCEDURE p_Entering_Insure(av_in    IN VARCHAR2, --传入参数
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             );

  --保存短信
  --1：AV_CARDBASEINFO --卡信息
  --2：AV_BASEPERSON --人员信息
  --3：AV_SYSACTIONLOG 日志信息
  --4：AV_SMS_TYPE 短信类型 01发放02充值03消费04圈存 99自定义短信
  --5:AV_AMT 金额
  PROCEDURE p_Save_Message(AV_CARDBASEINFO  IN card_baseinfo%ROWTYPE, --卡信息
                          AV_BASEPERSON     IN base_personal%ROWTYPE, --人员信息
                          AV_SYSACTIONLOG IN SYS_ACTION_LOG%ROWTYPE, --日志信息
                          AV_SMS_TYPE     IN VARCHAR2, --短信类型 01发放02充值03消费04圈存 99自定义短信
                          AV_AMT          IN INTEGER, --金额
                          av_res   OUT VARCHAR2, --传出代码
                          av_msg   OUT VARCHAR2);--传出错误信息
END PK_SERVICE_OUTER;
/

