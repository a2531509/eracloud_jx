create or replace package body PK_CARD_GRANT is

  /*=======================================================================================*/
  --�����ţ�Ŀǰֻ֧��A����
  --av_in : card_type|card_no|applyId|action_no|grant_type
  --        card_type ������
  --        card_no  ����
  --        applyId  ������
  --        action_no ҵ������ˮ��
  --        grant_type ��������  0 ���Ƿ��� 1 ��ģ����
  /*=======================================================================================*/
  PROCEDURE card_grand(av_in  IN VARCHAR2, --�������
                      av_action_no  OUT VARCHAR2,--������������ҵ����ˮ��
                      av_res OUT VARCHAR2, --������������
                      av_msg OUT VARCHAR2 --��������������Ϣ
                      ) IS
   ln_count NUMBER;
   lv_action_no   sys_action_log.deal_no%type; -- ��ˮ��
   lv_in          pk_public.myarray; --�����������
   lv_card_apply  card_apply%ROWTYPE; --��������Ϣ
   lv_card_baseinfo card_baseinfo%ROWTYPE; -- ����
   lv_card_apply_task  card_apply_task%ROWTYPE; --�������
   BEGIN
       --��ʼ�����ز���
        av_res := '00000000';
        av_msg := '';
       --�ֽ����
              pk_public.p_getinputpara(av_in, --�������
                                       5, --�������ٸ���
                                       5, --����������
                                       'pk_transfer.card_grand', --���õĺ�����
                                       lv_in, --ת���ɲ�������
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
      --��������
      IF lv_in(5) = '0' THEN
          --�жϴ���Ŀ�����
          IF  lv_in(1)  = '100' THEN
                  --1,�ж�����������Ϣ�Ƿ�ﵽ�˷�������
             BEGIN
                 SELECT * INTO lv_card_apply  FROM card_apply WHERE apply_id = lv_in(3);
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        av_res := pk_public.cs_res_grant_nofindapply_err;
                        av_msg := 'δ�ҵ��κ�������Ϣ';
                        RETURN;
              END;
             BEGIN
              SELECT * INTO lv_card_apply_task FROM card_apply_task WHERE task_id = lv_card_apply.task_id;
                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        av_res := pk_public.cs_res_grant_nofindtaks_err;
                        av_msg := 'δ�ҵ��κ�������Ϣ';
                        RETURN;
              END;
              IF lv_card_apply_task.task_state = pk_public.kg_card_task_yjs OR lv_card_apply_task.task_state = pk_public.kg_card_task_fkz THEN
                   ln_count:=0;
                   --2,
              ELSE
                  av_res := pk_public.cs_res_grant_taskcondition_err;
                  av_msg := 'δ�ҵ��κ�������Ϣ';
                  RETURN;
              END IF;

          ELSE
             av_res := pk_public.cs_res_grant_cardType_err;
             av_msg := '�ÿ����ݲ�֧�ֵ��ô洢���̷���';
             RETURN;
          END IF;

      END IF;
      EXCEPTION
               WHEN OTHERS THEN
               av_res := pk_public.cs_res_unknownerr;
               av_Msg  := nvl(sqlerrm,sqlerrm);
               rollback;
               update sys_action_log
                      set in_out_data = in_out_data || '------����ʧ�ܣ�������Ϣ��{' || av_res || ',' ||
                                 replace(av_Msg, '''', '��') || '}'
                                 where deal_no = lv_action_no;
               commit;
   END card_grand;
end PK_CARD_GRANT;
/

