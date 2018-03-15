create or replace package body PK_CARD_GRANT is

  /*=======================================================================================*/
  --卡发放（目前只支持A卡）
  --av_in : card_type|card_no|applyId|action_no|grant_type
  --        card_type 卡类型
  --        card_no  卡号
  --        applyId  申领编号
  --        action_no 业务处理流水号
  --        grant_type 发放类型  0 零星发放 1 规模发放
  /*=======================================================================================*/
  PROCEDURE card_grand(av_in  IN VARCHAR2, --传入参数
                      av_action_no  OUT VARCHAR2,--传出参数返回业务流水号
                      av_res OUT VARCHAR2, --传出参数代码
                      av_msg OUT VARCHAR2 --传出参数错误信息
                      ) IS
   ln_count NUMBER;
   lv_action_no   sys_action_log.deal_no%type; -- 流水号
   lv_in          pk_public.myarray; --传入参数数组
   lv_card_apply  card_apply%ROWTYPE; --卡申领信息
   lv_card_baseinfo card_baseinfo%ROWTYPE; -- 卡表
   lv_card_apply_task  card_apply_task%ROWTYPE; --卡任务表
   BEGIN
       --初始化返回参数
        av_res := '00000000';
        av_msg := '';
       --分解入参
              pk_public.p_getinputpara(av_in, --传入参数
                                       5, --参数最少个数
                                       5, --参数最多个数
                                       'pk_transfer.card_grand', --调用的函数名
                                       lv_in, --转换成参数数组
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
      --零星申领
      IF lv_in(5) = '0' THEN
          --判断传入的卡类型
          IF  lv_in(1)  = '100' THEN
                  --1,判断申领表里的信息是否达到了发放条件
             BEGIN
                 SELECT * INTO lv_card_apply  FROM card_apply WHERE apply_id = lv_in(3);
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        av_res := pk_public.cs_res_grant_nofindapply_err;
                        av_msg := '未找到任何申领信息';
                        RETURN;
              END;
             BEGIN
              SELECT * INTO lv_card_apply_task FROM card_apply_task WHERE task_id = lv_card_apply.task_id;
                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        av_res := pk_public.cs_res_grant_nofindtaks_err;
                        av_msg := '未找到任何任务信息';
                        RETURN;
              END;
              IF lv_card_apply_task.task_state = pk_public.kg_card_task_yjs OR lv_card_apply_task.task_state = pk_public.kg_card_task_fkz THEN
                   ln_count:=0;
                   --2,
              ELSE
                  av_res := pk_public.cs_res_grant_taskcondition_err;
                  av_msg := '未找到任何任务信息';
                  RETURN;
              END IF;

          ELSE
             av_res := pk_public.cs_res_grant_cardType_err;
             av_msg := '该卡类暂不支持调用存储过程发放';
             RETURN;
          END IF;

      END IF;
      EXCEPTION
               WHEN OTHERS THEN
               av_res := pk_public.cs_res_unknownerr;
               av_Msg  := nvl(sqlerrm,sqlerrm);
               rollback;
               update sys_action_log
                      set in_out_data = in_out_data || '------处理失败，错误信息：{' || av_res || ',' ||
                                 replace(av_Msg, '''', '‘') || '}'
                                 where deal_no = lv_action_no;
               commit;
   END card_grand;
end PK_CARD_GRANT;
/

