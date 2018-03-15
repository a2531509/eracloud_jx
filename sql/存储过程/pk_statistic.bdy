CREATE OR REPLACE PACKAGE BODY "PK_STATISTIC" IS
  /*=======================================================================================*/
  --�������˻�����stat_day_bal_base����ͳ�Ƶ��������ݱ���stat_day_bal_data
  /*=======================================================================================*/
  PROCEDURE p_daybal_data(av_clrdate        varchar2, --�������
                          av_daybal_type    varchar2, --1��Ա��2���㣬3����
                          av_daybal_ownerid IN VARCHAR2, --����������
                          av_actionno       in number, --ҵ����ˮ��
                          av_debug          IN VARCHAR2, --����0�ǣ�1��
                          av_res            OUT VARCHAR2, --������������
                          av_msg            OUT VARCHAR2 --��������������Ϣ
                          ) IS
    lv_cursor             pk_public.t_cur; --�α�
    lv_orgid              sys_users.org_id%TYPE := ''; --�������
    lv_brchid             sys_users.brch_id%TYPE := ''; --������
    lv_operid             sys_users.user_id%TYPE := ''; --����Ա���
    lv_stat_table         stat_day_bal_data%rowtype; --Ŀ���
    lv_prev               stat_day_bal_data%rowtype; --ǰ�ڽ����¼
    lv_sql                varchar2(4000);
    lv_count              number;
    lv_daybook_table_name varchar2(32) := 'ACC_INOUT_DETAIL_';
    lv_daybook_exists     char(1) := '1'; --�˻���ˮ���Ƿ����,0��1�񣬲�����ʱ���Զ�����
    lv_actionno           acc_rzcllog.deal_no%type;
    lv_remark             acc_rzcllog.remark%type := 'p_daybal_data:'; --��־
    ls_key                varchar(128) := 'key:';
    ls_param              varchar(128) := 'param:clr_date= ' || av_clrdate ||
                                          ',daybal_type=' || av_daybal_type ||
                                          ',daybal_id=' ||
                                          av_daybal_ownerid;
    ls_cartype            varchar2(3);
    --���뵽 Ӫҵ������������  stat_day_bal_data
    PROCEDURE p_ins_stat_table(av_stat_item_type char --ͳ�������ͣ�0������1��֧����
                               ) IS
    begin
      SELECT seq_day_bal_id.nextval, SYSDATE
        INTO lv_stat_table.id, lv_stat_table.insert_date
        FROM dual;
      lv_stat_table.clr_date := av_clrdate;
      lv_stat_table.user_id  := lv_operid;
      lv_stat_table.brch_id  := lv_brchid;
      lv_stat_table.org_id   := lv_orgid;
      lv_stat_table.own_type := av_daybal_type;
      lv_stat_table.deal_no  := av_actionno;
      --��ȡǰ�ڽ���
      if av_stat_item_type = '1' then
        begin
          select *
            into lv_prev
            from (select *
                    from stat_day_bal_data t
                   where stat_key = lv_stat_table.stat_key
                     and clr_date < lv_stat_table.clr_date
                     and own_type = av_daybal_type
                     and ((av_daybal_type = '1' and user_id = lv_operid) or
                         (av_daybal_type = '2' and brch_id = lv_brchid and
                         user_id is null) or
                         (av_daybal_type = '3' and org_id = lv_orgid and
                         brch_id is null))
                   order by clr_date desc)
           where rownum < 2;
          lv_stat_table.pre_amt := lv_prev.cur_amt;
        exception
          when no_data_found then
            null;
        end;
      end if;
      lv_stat_table.cur_amt := lv_stat_table.pre_amt +
                               lv_stat_table.cur_in_amt +
                               lv_stat_table.cur_out_amt;
      INSERT INTO stat_day_bal_data VALUES lv_stat_table;
    END;
    --���� ���� Ӫҵ������������  stat_day_bal_data
  begin
    av_res := pk_public.cs_res_ok;
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '��ʼ:' || ls_param,
                               lv_actionno);
    --return;
    if av_clrdate is null or av_daybal_type is null or
       av_daybal_ownerid is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ϊ��';
      RETURN;
    end if;
  
    --��Ա
    if av_daybal_type = '1' then
      lv_operid := av_daybal_ownerid;
      select org_id, brch_id
        into lv_orgid, lv_brchid
        from sys_users t
       where user_id = lv_operid;
      --����
    elsif av_daybal_type = '2' then
      lv_brchid := av_daybal_ownerid;
      select org_id
        into lv_orgid
        from sys_branch t
       where brch_id = lv_brchid;
      --����
    elsif av_daybal_type = '3' then
      lv_orgid := av_daybal_ownerid;
    end if;
  
    lv_daybook_table_name := lv_daybook_table_name ||
                             substr(replace(av_clrdate, '-', ''), 0, 6);
  
    select count(*)
      into lv_count
      from user_tables t
     where table_name = lv_daybook_table_name;
    if lv_count = 1 then
      lv_daybook_exists := '0';
      null;
    end if;
    --�������¼
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || 'DELETE tr_day_bal_data:' ||
                               ls_param,
                               lv_actionno);
    DELETE FROM stat_day_bal_data
     WHERE clr_date = av_clrdate
       and own_type = av_daybal_type
       and ((av_daybal_type = '1' and user_id = lv_operid) or
           (av_daybal_type = '2' and (brch_id = lv_brchid)) or
           (av_daybal_type = '3' and org_id = lv_orgid));
    --delete from a;
  
    --���������ͳ����
    for lrec_conf in (select *
                        from stat_day_bal_conf
                       where instr(STAT_REPORT_TYPE, av_daybal_type) > 0 --��Ա�����㡢����
                         and STAT_ITEM_TYPE = '0' --���������ͳ����
                         and state = '0'
                      --and stat_key = 'CASE_WALLET'
                       order by ord_no) loop
      --���ݱ���Դ:1-tr_day_bal_base
    
      if lrec_conf.from_table = '1' then
        ls_key := '�������from stat_day_bal,stat_key:' || lrec_conf.stat_key ||
                  ',day_bal_type=' || av_daybal_type || ',org_id=' ||
                  lv_orgid || ',brch_id=' || lv_brchid || ',user_id=' ||
                  lv_operid;
        pk_public.p_insertrzcllog_(av_debug,
                                   lv_remark || ls_key,
                                   lv_actionno);
        lv_sql := ' select null,
               null,
               :1,
               null,
               null,
               null,
               :2,
               card_type,
               sysdate,
               sum(counts),
               sum(abs(' || lrec_conf.num_conf || ')),
               sum(' || lrec_conf.amt_conf || '),
               0,
               0,
               0,
               0,
               0,
               0,
               null
          from stat_day_bal
          WHERE clr_date = :3
                and ((:4 = ''1'' and user_id = :5)
                or (:6 = ''2'' and brch_id = :7 and user_id is null)
                or (:8 = ''3'' and org_id =  :9 and brch_id is null))
                and deal_code ' || lrec_conf.stat_dealcode || '
           group by decode(:10,
                         ''1'',
                         user_id,
                         ''2'',
                         brch_id,
                         ''3'',
                         org_id),
                  card_type';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING av_daybal_type, lrec_conf.stat_key, av_clrdate, av_daybal_type, lv_operid, av_daybal_type, lv_brchid, av_daybal_type, lv_orgid, av_daybal_type;
        LOOP
          FETCH lv_cursor
            INTO lv_stat_table;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_ins_stat_table(lrec_conf.stat_item_type);
        END LOOP;
        CLOSE lv_cursor;
        null;
      end if;
    
      --���ݱ���Դ:2-cash_box_rec
      if lrec_conf.from_table = '2' then
        ls_key := '�������from cash_box_rec,stat_key:' || lrec_conf.stat_key ||
                  ',day_bal_type=' || av_daybal_type || ',org_id=' ||
                  lv_orgid || ',brch_id=' || lv_brchid || ',user_id=' ||
                  lv_operid;
        pk_public.p_insertrzcllog_(av_debug,
                                   lv_remark || ls_key,
                                   lv_actionno);
        lv_sql := ' select null,
               null,
               :1,
               null,
               null,
               null,
               :2,
               null,
               sysdate,
               count(1),
               count(1),
               sum(' || lrec_conf.amt_conf || '),
               0,
               0,
               0,
               0,
               0,
               0,
               null
          from cash_box_rec
          WHERE clr_date = :3
                and ((:4 = ''1'' and user_id = :5)
                or (:6 = ''2'' and brch_id = :7)
                or (:8 = ''3'' and org_id =  :9))
                and deal_code ' || lrec_conf.stat_dealcode || '
           group by decode(:10,
                         ''1'',
                         user_id,
                         ''2'',
                         brch_id,
                         ''3'',
                         org_id)';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING av_daybal_type, lrec_conf.stat_key, av_clrdate, av_daybal_type, lv_operid, av_daybal_type, lv_brchid, av_daybal_type, lv_orgid, av_daybal_type;
        LOOP
          FETCH lv_cursor
            INTO lv_stat_table;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_ins_stat_table(lrec_conf.stat_item_type);
        END LOOP;
        CLOSE lv_cursor;
        null;
      end if;
      --���ݱ���Դ:2-acc_day_book���˻���ˮ��������ڽ�β
      if lrec_conf.from_table = '3' and lv_daybook_exists = '0' then
        ls_key := '�������from ' || lv_daybook_table_name || ',stat_key:' ||
                  lrec_conf.stat_key || ',day_bal_type=' || av_daybal_type ||
                  ',org_id=' || lv_orgid || ',brch_id=' || lv_brchid ||
                  ',user_id=' || lv_operid;
        pk_public.p_insertrzcllog_(av_debug,
                                   lv_remark || ls_key,
                                   lv_actionno);
        lv_sql := ' select null,
               null,
               :1,
               null,
               null,
               null,
               :2,
               db_card_type,
               sysdate,
               count(' || lrec_conf.num_conf || '),
               count(' || lrec_conf.num_conf || '),
               sum(' || lrec_conf.amt_conf || '),
               0,
               0,
               0,
               0,
               0,
               0,
               null
          from ' || lv_daybook_table_name || '
          WHERE clr_date = :10
               and ((:3 = ''1'' and user_id = :4)
                or (:5 = ''2'' and ACPT_ID = :6 and user_id is null)
                or (:7 = ''3'' and acpt_org_id =  :8 ))
                and deal_code ' || lrec_conf.stat_dealcode || '
           group by decode(:9,
                         ''1'',
                         user_id,
                         ''2'',
                         ACPT_ID,
                         ''3'',
                         acpt_org_id),
                     db_card_type';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING av_daybal_type, lrec_conf.stat_key, av_daybal_type, lv_operid, av_daybal_type, lv_brchid, av_daybal_type, lv_orgid, av_daybal_type, av_clrdate;
        LOOP
          FETCH lv_cursor
            INTO lv_stat_table;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_ins_stat_table(lrec_conf.stat_item_type);
        END LOOP;
        CLOSE lv_cursor;
        null;
      end if;
    
    end loop;
  
    --��֧������ͳ����
    for lrec_conf in (select *
                        from stat_day_bal_conf
                       where instr(STAT_REPORT_TYPE, av_daybal_type) > 0
                         and STAT_ITEM_TYPE = '1' --��֧������ͳ����
                         and state = '0'
                      --and stat_key = 'POINTS_CHG_ACC'
                       order by ord_no) loop
      --���ݱ���Դ:1-tr_day_bal_base,�����ڿ����֧
      if lrec_conf.from_table = '1' then
        if lrec_conf.bigtype = '23' then
          --ȡͳ�����ĩ3λ��Ϊ������
          ls_cartype := substr(lrec_conf.stat_key,
                               length(lrec_conf.stat_key) - 2);
        end if;
        ls_key := '��֧����from tr_day_bal_base,stat_key:' ||
                  lrec_conf.stat_key || ',day_bal_type=' || av_daybal_type ||
                  ',org_id=' || lv_orgid || ',brch_id=' || lv_brchid ||
                  ',user_id=' || lv_operid;
        pk_public.p_insertrzcllog_(av_debug,
                                   lv_remark || ls_key,
                                   lv_actionno);
        lv_sql := ' select null,
               null,
               :1,
               null,
               null,
               null,
               :2,
               card_type,
               sysdate,
               0,
               0,
               0,
               0,' || '
               abs(sum(' || lrec_conf.cur_in_cnt || ')),
               sum(' || lrec_conf.cur_in || '),
               abs(sum(' || lrec_conf.cur_out_cnt || ')),
               sum(' || lrec_conf.cur_out || '),
               null,
               null
          from tr_day_bal_base
          WHERE clr_date = :3
                and card_type=''' || ls_cartype || '''
                and ((:4 = ''1'' and own_type=''1'' and user_id = :5)
                or (:6 = ''2'' and own_type=''2'' and brch_id = :7 and user_id is null)
                or (:8 = ''3'' and own_type=''3'' and org_id =  :9 and brch_id is null))
                and deal_code ' || lrec_conf.stat_dealcode || '
                and (nvl(stk_in_cnt,0)<>0 or nvl(stk_out_cnt,0)<>0 )
           group by decode(:10,
                         ''1'',
                         user_id,
                         ''2'',
                         brch_id,
                         ''3'',
                         org_id),
                  card_type';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING av_daybal_type, lrec_conf.stat_key, av_clrdate, av_daybal_type, lv_operid, av_daybal_type, lv_brchid, av_daybal_type, lv_orgid, av_daybal_type;
        LOOP
          FETCH lv_cursor
            INTO lv_stat_table;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_ins_stat_table(lrec_conf.stat_item_type);
        END LOOP;
        CLOSE lv_cursor;
        null;
      end if;
      --���ݱ���Դ:2-CS_CASH_BOX_BOOK
      if lrec_conf.from_table = '2' then
        ls_key := '��֧����from cs_cash_box_book,stat_key:' ||
                  lrec_conf.stat_key || ',day_bal_type=' || av_daybal_type ||
                  ',org_id=' || lv_orgid || ',brch_id=' || lv_brchid ||
                  ',user_id=' || lv_operid;
        pk_public.p_insertrzcllog_(av_debug,
                                   lv_remark || ls_key,
                                   lv_actionno);
        for lr_stat_table in (select null day_bal_id,
                                     av_clrdate clr_date, --clr_date
                                     av_daybal_type own_type, --av_daybal_type
                                     null org_id,
                                     null brch_id,
                                     null user_id,
                                     lrec_conf.stat_key, --stat_key
                                     null card_type,
                                     sysdate insert_date,
                                     0 cnt,
                                     0 num,
                                     0 amt,
                                     0 pre_amt,
                                     sum(decode(in_out_flag, '1', 1, 0)) cur_in_num,
                                     sum(decode(in_out_flag, '1', amt, 0)) cur_in_amt,
                                     sum(decode(in_out_flag, '2', 1, 0)) cur_out_num,
                                     sum(decode(in_out_flag, '2', amt, 0)) cur_out_amt,
                                     0 cur_amt,
                                     null action_no
                                from (select t.in_out_flag,
                                             deal_code,
                                             sum(amt) amt,
                                             org_id,
                                             brch_id,
                                             user_id,
                                             clr_date,
                                             deal_no,
                                             count(1)
                                        from cash_box_rec t
                                       where clr_date = av_clrdate
                                         and ((av_daybal_type = '1' and
                                             user_id = lv_operid) or
                                             (av_daybal_type = '2' and
                                             brch_id = lv_brchid and
                                             --ͬ������ո����ݲ���֧ͳ��
                                             (other_brch_id is null or
                                             other_brch_id <> brch_id)) or
                                             (av_daybal_type = '3' and
                                             org_id = lv_orgid and
                                             (other_org_id is null or
                                             other_org_id <> org_id)))
                                       group by clr_date,
                                                deal_code,
                                                deal_no,
                                                in_out_flag,
                                                org_id,
                                                brch_id,
                                                user_id) tt
                               group by decode(av_daybal_type,
                                               '1',
                                               tt.user_id,
                                               '2',
                                               tt.brch_id,
                                               '3',
                                               tt.org_id)) loop
        
          select seq_day_bal_id.nextval
            into lr_stat_table.day_bal_id
            from dual;
          lr_stat_table.user_id := lv_operid;
          lr_stat_table.brch_id := lv_brchid;
          lr_stat_table.org_id  := lv_orgid;
          --lr_stat_table.own_type := av_daybal_type;
          begin
            select *
              into lv_prev
              from (select *
                      from stat_day_bal_data t
                     where stat_key = lr_stat_table.stat_key
                       and clr_date < lr_stat_table.clr_date
                       and own_type = av_daybal_type
                       and ((av_daybal_type = own_type and
                           user_id = lv_operid) or
                           (av_daybal_type = own_type and
                           brch_id = lv_brchid and user_id is null) or
                           (av_daybal_type = own_type and org_id = lv_orgid and
                           brch_id is null))
                     order by clr_date desc)
             where rownum < 2;
            lr_stat_table.pre_amt := lv_prev.cur_amt;
          exception
            when no_data_found then
              null;
          end;
          lr_stat_table.cur_amt := lr_stat_table.pre_amt +
                                   lr_stat_table.cur_in_amt +
                                   lr_stat_table.cur_out_amt;
          insert into stat_day_bal_data values lr_stat_table;
        end loop;
        /*   lv_sql := ' select null,
               null,
               :1,
               null,
               null,
               null,
               :2,
               null,
               sysdate,
               0,
               0,
               0,
               0,
               abs(sum(' || lrec_conf.cur_in_cnt || ')),
               sum(' || lrec_conf.cur_in || '),
               abs(sum(' || lrec_conf.cur_out_cnt || ')),
               sum(' || lrec_conf.cur_out || '),
               sum(' || lrec_conf.cur_in || '+' ||
                  lrec_conf.cur_out || ')
          from cs_cash_box_book
          WHERE clr_date = :3
                and ((:4 = ''1'' and oper_id = :5)
                or (:6 = ''2'' and brch_id = :7)
                or (:8 = ''3'' and org_id =  :9))
                and tr_code ' || lrec_conf.stat_trcode || '
           group by decode(:10,
                         ''1'',
                         oper_id,
                         ''2'',
                         brch_id,
                         ''3'',
                         org_id)';
        insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING av_daybal_type, lrec_conf.stat_key, av_clrdate, av_daybal_type, lv_operid, av_daybal_type, lv_brchid, av_daybal_type, lv_orgid, av_daybal_type;
        LOOP
          FETCH lv_cursor
            INTO lv_stat_table;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_ins_stat_table(lrec_conf.stat_item_type);
        END LOOP;
        CLOSE lv_cursor;*/
        null;
      end if;
      --���ݱ���Դ:2-acc_inout_detail���˻���ˮ��������ڽ�β
      if lrec_conf.from_table = '3' and lv_daybook_exists = '0' then
        ls_key := '��֧����from ' || lv_daybook_table_name || ',stat_key:' ||
                  lrec_conf.stat_key || ',day_bal_type=' || av_daybal_type ||
                  ',org_id=' || lv_orgid || ',brch_id=' || lv_brchid ||
                  ',user_id=' || lv_operid;
        pk_public.p_insertrzcllog_(av_debug,
                                   lv_remark || ls_key,
                                   lv_actionno);
        lv_sql := ' select null,
               null,
               :1,
               null,
               null,
               null,
               :2,
               null,
               sysdate,
               0,
               0,
               0,
               0,
               abs(sum(' || lrec_conf.cur_in_cnt || ')),
               sum(' || lrec_conf.cur_in || '),
               abs(sum(' || lrec_conf.cur_out_cnt || ')),
               sum(' || lrec_conf.cur_out || '),
               null,
               null
           from ' || lv_daybook_table_name || '
          WHERE clr_date =:10 and 
                (db_item_id =''102100'' or cr_item_id =''102100'')
                and  ((:3 = ''1'' and user_id = :4)
                or (:5 = ''2'' and ACPT_ID = :6)
                or (:7 = ''3'' and ACPT_ORG_ID =  :8))
                and deal_code ' || lrec_conf.stat_dealcode || '
           group by decode(:9,
                         ''1'',
                         user_id,
                         ''2'',
                         ACPT_ID,
                         ''3'',
                         ACPT_ORG_ID),
                     db_card_type';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING av_daybal_type, lrec_conf.stat_key, av_daybal_type, lv_operid, av_daybal_type, lv_brchid, av_daybal_type, lv_orgid, av_daybal_type, av_clrdate;
        LOOP
          FETCH lv_cursor
            INTO lv_stat_table;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_ins_stat_table(lrec_conf.stat_item_type);
        END LOOP;
        CLOSE lv_cursor;
        null;
      end if;
    
    end loop;
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '����:' || ls_param,
                               lv_actionno);
  exception
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := lv_remark || '�쳣:' || ls_param || ',key:' || ls_key ||
                SQLERRM;
      pk_public.p_insertrzcllog_(av_debug, av_msg, 0);
  end p_daybal_data;

  /*=======================================================================================*/
  --���� �������ݵ� tr_day_bal_base������ٻ��ܵ�tr_day_bal_data����
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5clr_date|6daybal_type|7daybal_owner_id
  --daybal_type:1���ˣ�2����(�ȸ���������)��3����(���к󴥷�����������Ӫҵ����Ļ�������)
  /*=======================================================================================*/
  PROCEDURE p_daybal(av_in    IN VARCHAR2, --�������
                     av_debug IN VARCHAR2, --����0�ǣ�1��
                     av_res   OUT VARCHAR2, --������������
                     av_msg   OUT VARCHAR2 --��������������Ϣ
                     ) IS
    lv_cursor        pk_public.t_cur; --�α�
    lv_rec_tablename VARCHAR2(50);
    lv_stk_tablename VARCHAR2(50);
    lv_daybal        stat_day_bal%ROWTYPE;
    lv_count         NUMBER;
    lv_daybal_type   char(1); --����Ա���
    lv_orgid         sys_users.org_id%TYPE; --�������
    lv_brchid        sys_users.brch_id%TYPE; --������
    lv_operid        sys_users.user_id%TYPE; --����Ա���
    lv_clrdate       pay_clr_para.clr_date%TYPE; --Ҫ���˵��������
    lv_in            pk_public.myarray; --�����������
    lv_sql           varchar2(4000);
    lv_actionno      acc_rzcllog.deal_no%type;
    lv_remark        acc_rzcllog.remark%type := 'p_daybal:'; --��־
    ls_key           varchar(128);
    --�������˼�¼
    PROCEDURE p_insertdaybal IS
    begin
      SELECT COUNT(*)
        INTO lv_count
        FROM stat_day_bal
       WHERE clr_date = lv_daybal.clr_date
         and own_type = lv_daybal.own_type
         and ((lv_daybal.own_type = '1' and user_id = lv_daybal.user_id) or
             (lv_daybal.own_type = '2' and brch_id = lv_daybal.brch_id) or
             (lv_daybal.own_type = '3' and org_id = lv_daybal.org_id))
         AND deal_code = lv_daybal.deal_code
         AND nvl(card_type, '-1') = nvl(lv_daybal.card_type, '-1');
      IF lv_count = 0 THEN
        lv_daybal.cur_user_id := lv_in(3);
        SELECT seq_day_bal_id.nextval, SYSDATE
          INTO lv_daybal.id, lv_daybal.insert_date
          FROM dual;
        lv_daybal.deal_no := lv_in(1);
        INSERT INTO stat_day_bal VALUES lv_daybal;
      ELSE
        UPDATE stat_day_bal
           SET num         = num + lv_daybal.num,
               num2        = num2 + lv_daybal.num2,
               num3        = num3 + lv_daybal.num3,
               amt         = amt + lv_daybal.amt,
               amt2        = amt2 + lv_daybal.amt2,
               amt3        = amt3 + lv_daybal.amt3,
               amt4        = amt4 + lv_daybal.amt4,
               amt5        = amt5 + lv_daybal.amt5,
               stk_in_cnt  = stk_in_cnt + lv_daybal.stk_in_cnt,
               stk_in_num  = stk_in_num + lv_daybal.stk_in_num,
               stk_out_cnt = stk_out_cnt + lv_daybal.stk_out_cnt,
               stk_out_num = stk_out_num + lv_daybal.stk_out_num,
               insert_date = sysdate
         WHERE clr_date = lv_daybal.clr_date
           and own_type = lv_daybal.own_type
           and ((lv_daybal.own_type = '1' and user_id = lv_daybal.user_id) or
               (lv_daybal.own_type = '2' and brch_id = lv_daybal.brch_id) or
               (lv_daybal.own_type = '3' and org_id = lv_daybal.org_id))
           AND nvl(card_type, '-1') = nvl(lv_daybal.card_type, '-1')
           and deal_code = lv_daybal.deal_code;
      END IF;
    END;
  
  BEGIN
    lv_count := pk_public.f_splitstr(av_in, '|', lv_in);
    IF lv_count < 7 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '���������������ȷ';
      RETURN;
    END IF;
    if lv_in(5) is null or lv_in(6) is null or lv_in(7) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ϊ��';
      RETURN;
    end if;
    lv_clrdate     := lv_in(5);
    lv_daybal_type := lv_in(6);
    if lv_daybal_type = '1' then
      lv_operid := lv_in(7);
    elsif lv_daybal_type in ('2') then
      lv_brchid := lv_in(7);
    elsif lv_daybal_type = '3' then
      lv_orgid := lv_in(7);
    else
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������';
      RETURN;
    end if;
    lv_actionno := lv_in(1);
  
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '-��ʼ-���:' || av_in,
                               lv_actionno);
  
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    --delete from a;
  
    --�������¼
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark ||
                               'DELETE stat_day_bal:day_bal_type=' ||
                               lv_daybal_type || ',org_id=' || lv_orgid ||
                               ',brch_id=' || lv_brchid || ',oper_id=' ||
                               lv_operid,
                               lv_actionno);
    DELETE FROM stat_day_bal
     WHERE clr_date = lv_clrdate
       and ((lv_daybal_type = '1' and user_id = lv_operid) or
           --��������ʱҲһ��Ҫ�ѹ�Ա���������
           (lv_daybal_type = '2' and brch_id = lv_brchid) or
           (lv_daybal_type = '3' and org_id = lv_orgid and brch_id is null and
           user_id is null));
  
    lv_rec_tablename := 'tr_serv_rec';
    lv_stk_tablename := 'stock_rec';
  
    ----------------
    --��Ա���������ˣ��ȴ����Ա��
    ----------------
    if lv_daybal_type in ('1', '2') then
      ls_key := '����Ա:brch_id=' || lv_brchid || ',user_id=' || lv_operid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      --����Աҵ��
      lv_sql := 'select null,
               clr_date,
               1,
               t3.org_id,
               t3.brch_id,
               t3.user_id,
               null,
               t1.deal_code,
               card_type,
               null,
               nvl(sum(t1.num), 0),
               0,
               0,
               nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_users t3
         where t1.deal_code = t2.deal_code
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''1''
           and t2.is_tosum = ''0''
           and t1.user_id = t3.user_id
           and clr_date = :1
           and nvl(t1.org_id,t3.org_id) = t3.org_id
           and(:2 is null or t3.user_id = :3)
           and(:4 is null or t3.brch_id = :5)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t3.user_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_operid, lv_operid, lv_brchid, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      --��Ա֮�䷢����ҵ��
      --�շ�
      ls_key := '��Ա��:brch_id=' || lv_brchid || ',user_id=' || lv_operid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               1,
               t3.org_id,
               t3.brch_id,
               t3.user_id,
               null,
               t1.deal_code,
               card_type,
               null,
               nvl(sum(t1.num), 0),
               0,
               0,
               nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_users t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''0''
           and t2.is_tosum = ''0''
           and t1.user_id_in = t3.user_id
           and clr_date = :1
           and nvl(t1.org_id_in,t3.org_id) = t3.org_id
           and(:2 is null or t3.user_id = :3)
           and(:4 is null or t3.brch_id = :5)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t3.user_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_operid, lv_operid, lv_brchid, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
      --����,����������Ǹ�ֵ
      ls_key := '��Ա��:brch_id=' || lv_brchid || ',user_id=' || lv_operid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               1,
               t3.org_id,
               t3.brch_id,
               t3.user_id,
               null,
               t1.deal_code,
               card_type,
               null,
               -nvl(sum(t1.num), 0),
               0,
               0,
               -nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_users t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''0''
           and t2.is_tosum = ''0''
           and t1.user_id_out = t3.user_id
           and clr_date = :1
           and nvl(t1.org_id_out,t3.org_id) = t3.org_id
           and(:2 is null or t3.user_id = :3)
           and(:4 is null or t3.brch_id = :5)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t3.user_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_operid, lv_operid, lv_brchid, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      --�����֧����������Ҫ�ӿ����ˮ����ͳ�ƣ���ͬһ��ҵ���硰��ֵ�����ۡ��������ֿ�����ʱ���޷�����
      --����û�п��ҵ����־���������ۿ�������ص���Щҵ�������ҵ���޷�����
      --�翨�������Ϊ1������ʵ�������޿�ע������Ƭ��δ���գ������Ҫͨ���շ����������ֶν���ͳ��
      --����Աѭ��
      ls_key := '��Ա�����֧:brch_id=' || lv_brchid || ',user_id=' || lv_operid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      for lrec_temp in (select *
                          from sys_users
                         where ((lv_daybal_type = '1' and
                               user_id = lv_operid) or (lv_daybal_type = '2' and
                               brch_id = lv_brchid))) loop
        ls_key := '��Ա�����: user_id=' || lrec_temp.user_id;
        lv_sql := 'select null day_bal_id,
               t1.clr_date,
               1 own_type,
               t3.org_id,
               t3.brch_id,
               t3.user_id,
               null cur_oper_id,
               t1.deal_code,
               substr(t2.stk_code, 2) card_type,
               null insert_date,
               0 num,
               0 num2,
               0 num3,
               0 amt,
               0 amt2,
               0 amt3,
               0 amt4,
               0 amt5,
               0 counts,
               count(distinct(t2.deal_no)) stk_in_cnt,
               count(1) stk_in_num,
               0 stk_out_cnt,
               0 stk_out_num,
               null action_no
          from ' || lv_rec_tablename || ' t1,' ||
                  lv_stk_tablename ||
                  ' t2, sys_users t3
         where t1.deal_no = t2.deal_no
           and t1.deal_code = t2.deal_code
           and t1.deal_state not in (''2'', ''9'')
           and t2.in_user_id = t3.user_id
           and t1.clr_date = :1
           and t3.user_id=:2
           and t2.in_out_flag in (''1'', ''3'')
           and t1.co_org_id is null
         group by t1.clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t3.user_id,
                  t1.deal_code,
                  substr(t2.stk_code, 2)';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING lv_clrdate, lrec_temp.user_id;
        LOOP
          FETCH lv_cursor
            INTO lv_daybal;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_insertdaybal;
        END LOOP;
        CLOSE lv_cursor;
        ls_key := '��Ա���֧: user_id=' || lrec_temp.user_id;
        lv_sql := 'select null day_bal_id,
             t1.clr_date,
             1 own_type,
             t3.org_id,
             t3.brch_id,
             t3.user_id,
             null cur_oper_id,
             t1.deal_code,
             substr(t2.stk_code, 2) card_type,
             null insert_date,
             0 num,
             0 num2,
             0 num3,
             0 amt,
             0 amt2,
             0 amt3,
             0 amt4,
             0 amt5,
             0 counts,
             0 stk_in_cnt,
             0 stk_in_num,
             count(distinct(t2.deal_no)) stk_out_cnt,
             -count(1) stk_out_num,
             null action_no
        from ' || lv_rec_tablename || ' t1,' ||
                  lv_stk_tablename ||
                  ' t2,  sys_users t3
       where t1.deal_no = t2.deal_no
         and t1.deal_code = t2.deal_code
         and t1.deal_state not in (''2'', ''9'')
         and t2.out_user_id = t3.user_id
         and t1.clr_date = :1
         and t3.user_id=:2
         and t2.in_out_flag in (''2'', ''3'')
         and t1.co_org_id is null
       group by t1.clr_date,
                t3.org_id,
                t3.brch_id,
                t3.user_id,
                t1.deal_code,
                substr(t2.stk_code, 2)';
        --insert into a values (lv_sql);
        OPEN lv_cursor FOR lv_sql
          USING lv_clrdate, lrec_temp.user_id;
        LOOP
          FETCH lv_cursor
            INTO lv_daybal;
          EXIT WHEN lv_cursor%NOTFOUND;
          p_insertdaybal;
        END LOOP;
        CLOSE lv_cursor;
      end loop;
    end if;
  
    ----------------
    --��������
    ----------------
    if lv_daybal_type in ('2') then
      --������ҵ��
      ls_key := '������:brch_id=' || lv_brchid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               2,
               t3.org_id,
               t3.brch_id,
               null,
               null,
               t1.deal_code,
               card_type,
               null,
               nvl(sum(t1.num), 0),
               0,
               0,
               nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_branch t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''1''
           and t1.brch_id = t3.brch_id
           and clr_date = :1
           and nvl(t1.org_id,t3.org_id) = t3.org_id
           and(:2 is null or t3.brch_id = :3)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_brchid, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
      --����֮�䷢����ҵ��
      --�շ�
      ls_key := '������:brch_id=' || lv_brchid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               2,
               t3.org_id,
               t3.brch_id,
               null,
               null,
               t1.deal_code,
               card_type,
               null,
               nvl(sum(t1.num), 0),
               0,
               0,
               nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_branch t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''0''
           and t1.brch_id_in = t3.brch_id
           and clr_date = :1
           and nvl(t1.org_id_in,t3.org_id) = t3.org_id
           and(:2 is null or t3.brch_id = :3)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_brchid, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      --����,����������Ǹ�ֵ
      ls_key := '���㸶:brch_id=' || lv_brchid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               2,
               t3.org_id,
               t3.brch_id,
               null,
               null,
               t1.deal_code,
               card_type,
               null,
               -nvl(sum(t1.num), 0),
               0,
               0,
               -nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_branch t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''0''
           and t1.brch_id_out = t3.brch_id
           and clr_date = :1
           and nvl(t1.org_id_out,t3.org_id) = t3.org_id
           and(:2 is null or t3.brch_id = :3)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_brchid, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      --�����֧����������Ҫ�ӿ����ˮ����ͳ�ƣ���ͬһ��ҵ���硰��ֵ�����ۡ��������ֿ�����ʱ���޷�����
      --����û�п��ҵ����־���������ۿ�������ص���Щҵ�������ҵ���޷�����
      --�翨�������Ϊ1������ʵ�������޿�ע������Ƭ��δ���գ������Ҫͨ���շ����������ֶν���ͳ��
      --����ҵ��ʱ��ֻͳ�Ʋ�ͬ������ҵ�������ڲ���ת��������
      --��ͬ�����Ա������������ͳ�����ݲ�Ӱ��
      ls_key := '��������֧:brch_id=' || lv_brchid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      ls_key := '��������: brch_id=' || lv_brchid;
      lv_sql := 'select null day_bal_id,
               t1.clr_date,
               2 own_type,
               t3.org_id,
               t3.brch_id,
               null user_id,
               null cur_oper_id,
               t1.deal_code,
               substr(t2.stk_code, 2) card_type,
               null insert_date,
               0 num,
               0 num2,
               0 num3,
               0 amt,
               0 amt2,
               0 amt3,
               0 amt4,
               0 amt5,
               0 counts,
               count(distinct(t2.deal_no)) stk_in_cnt,
               count(1) stk_in_num,
               0 stk_out_cnt,
               0 stk_out_num,
               null action_no
          from ' || lv_rec_tablename || ' t1,' ||
                lv_stk_tablename ||
                ' t2, sys_branch t3
         where t1.deal_no = t2.deal_no
           and t1.deal_code = t2.deal_code
           and t1.deal_state not in (''2'', ''9'')
           and t2.brch_id = t3.brch_id
           and (t2.out_brch_id is null or t2.out_brch_id <> t3.brch_id)
           and t1.clr_date = :1
           and t3.brch_id=:2
           and t2.in_out_flag in (''1'', ''3'')
           and t1.co_org_id is null
         group by t1.clr_date,
                  t3.org_id,
                  t3.brch_id,
                  t1.deal_code,
                  substr(t2.stk_code, 2)';
      --insert into a values (lv_sql);
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
      ls_key := '������֧: brch_id=' || lv_brchid;
      lv_sql := 'select null day_bal_id,
             t1.clr_date,
             2 own_type,
             t3.org_id,
             t3.brch_id,
             null user_id,
             null cur_oper_id,
             t1.deal_code,
             substr(t2.stk_code, 2) card_type,
             null insert_date,
             0 num,
             0 num2,
             0 num3,
             0 amt,
             0 amt2,
             0 amt3,
             0 amt4,
             0 amt5,
             0 counts,
             0 stk_in_cnt,
             0 stk_in_num,
             count(distinct(t2.deal_no)) stk_out_cnt,
             -count(1) stk_out_num,
             null action_no
        from ' || lv_rec_tablename || ' t1,' ||
                lv_stk_tablename || ' t2,  sys_branch t3
       where t1.deal_no = t2.deal_no
         and t1.deal_code = t2.deal_code
         and t1.deal_state not in (''2'', ''9'')
         and t2.brch_id = t3.brch_id
         and (t2.in_brch_id is null or t2.in_brch_id <> t3.brch_id)
         and t1.clr_date = :1
         and t3.brch_id=:2
         and t2.in_out_flag in (''2'', ''3'')
         and t1.co_org_id is null
       group by t1.clr_date,
                t3.org_id,
                t3.brch_id,
                t1.deal_code,
                substr(t2.stk_code, 2)';
      --insert into a values (lv_sql);
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_brchid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      ----------------
      --��������
      ----------------
    elsif lv_daybal_type in ('3') then
      --������ҵ��
      ls_key := '������:org_id=' || lv_orgid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               3,
               t3.org_id,
               null,
               null,
               null,
               t1.deal_code,
               card_type,
               null,
               nvl(sum(t1.num), 0),
               0,
               0,
               nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_organ t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''1''
           and clr_date = :1
           and t1.org_id = t3.org_id
           and (:2 is null or t3.org_id = :3)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_orgid, lv_orgid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
      --����֮�䷢����ҵ�������������������
      --�շ�
      ls_key := '������:org_id=' || lv_orgid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               3,
               t3.org_id,
               null,
               null,
               null,
               t1.deal_code,
               card_type,
               null,
               nvl(sum(t1.num), 0),
               0,
               0,
               nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_organ t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''0''
           and clr_date = :1
           and nvl(t1.org_id_in,t3.org_id) = t3.org_id
           and (:2 is null or t3.org_id = :3)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_orgid, lv_orgid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      --����,����������Ǹ�ֵ
      ls_key := '������:org_id=' || lv_orgid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      lv_sql := 'select null,
               clr_date,
               3,
               t3.org_id,
               null,
               null,
               null,
               t1.deal_code,
               card_type,
               null,
               -nvl(sum(t1.num), 0),
               0,
               0,
               -nvl(sum(t1.amt), 0),
               0,
               0,
               0,
               0,
               count(*) counts,
               0,
               0,
               0,
               0,
               null action_no
          from ' || lv_rec_tablename ||
                ' t1, sys_code_tr t2, sys_organ t3
         where t1.deal_code = t2.deal_code
           and t1.deal_code not like''100%''--�ų��ƿ��������͵���������ҵ������Ϊ�յ�����
           and t1.deal_state not in (2, 9)
           and t2.between_flag = ''0''
           and clr_date = :1
           and nvl(t1.org_id_out,t3.org_id) = t3.org_id
           and (:2 is null or t3.org_id = :3)--�������
           and t1.co_org_id is null
         group by clr_date,
                  t3.org_id,
                  t1.deal_code,
                  card_type';
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_orgid, lv_orgid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    
      --����ҵ��ʱ��ֻͳ�Ʋ�ͬ�������ҵ�񣬻����ڲ���ת������
      ls_key := '���������֧:org_id=' || lv_orgid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      ls_key := '���������: brch_id=' || lv_brchid;
      lv_sql := 'select null day_bal_id,
               t1.clr_date,
               3 own_type,
               t3.org_id,
               null brch_id,
               null user_id,
               null cur_oper_id,
               t1.deal_code,
               substr(t2.stk_code, 2) card_type,
               null insert_date,
               0 num,
               0 num2,
               0 num3,
               0 amt,
               0 amt2,
               0 amt3,
               0 amt4,
               0 amt5,
               0 counts,
               count(distinct(t2.deal_no)) stk_in_cnt,
               count(1) stk_in_num,
               0 stk_out_cnt,
               0 stk_out_num,
               null action_no
          from ' || lv_rec_tablename || ' t1,' ||
                lv_stk_tablename ||
                ' t2, sys_organ t3
         where t1.deal_no = t2.deal_no
           and t1.deal_code = t2.deal_code
           and t1.deal_state not in (''2'', ''9'')
           and t2.org_id = t3.org_id
           and (t2.out_org_id is null or t2.out_org_id <> t3.org_id)
           and t1.clr_date = :1
           and t3.org_id=:2
           and t2.in_out_flag in (''1'', ''3'')
           and t1.co_org_id is null
         group by t1.clr_date,
                  t3.org_id,
                  t1.deal_code,
                  substr(t2.stk_code, 2)';
      --insert into a values (lv_sql);
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_orgid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
      ls_key := '�������֧: oper_id=' || lv_brchid;
      lv_sql := 'select null day_bal_id,
             t1.clr_date,
             3 own_type,
             t3.org_id,
             null brch_id,
             null user_id,
             null cur_oper_id,
             t1.deal_code,
             substr(t2.stk_code, 2) card_type,
             null insert_date,
             0 num,
             0 num2,
             0 num3,
             0 amt,
             0 amt2,
             0 amt3,
             0 amt4,
             0 amt5,
             0 counts,
             0 stk_in_cnt,
             0 stk_in_num,
             count(distinct(t2.deal_no)) stk_out_cnt,
             -count(1) stk_out_num,
             null action_no
        from ' || lv_rec_tablename || ' t1,' ||
                lv_stk_tablename || ' t2,  sys_organ t3
       where t1.deal_no = t2.deal_no
         and t1.deal_code = t2.deal_code
         and t1.deal_state not in (''2'', ''9'')
         and t2.org_id = t3.org_id
         and (t2.in_org_id is null or t2.in_org_id <> t3.org_id)
         and t1.clr_date = :1
         and t3.org_id=:2
         and t2.in_out_flag in (''2'', ''3'')
         and t1.co_org_id is null
       group by t1.clr_date,
                t3.org_id,
                t1.deal_code,
                substr(t2.stk_code, 2)';
      --insert into a values (lv_sql);
      OPEN lv_cursor FOR lv_sql
        USING lv_clrdate, lv_orgid;
      LOOP
        FETCH lv_cursor
          INTO lv_daybal;
        EXIT WHEN lv_cursor%NOTFOUND;
        p_insertdaybal;
      END LOOP;
      CLOSE lv_cursor;
    end if;
  
    --��������tr_day_bal_data����
    --���˻�����ʱ�����������������
    if lv_daybal_type in ('1', '2') then
      ls_key := 'tr_day_bal_data��Ա������-��ʼ:brch_id=' || lv_brchid ||
                ',oper_id=' || lv_operid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      for lrec_temp in (select *
                          from sys_users
                         where (lv_daybal_type = '1' and user_id = lv_operid or
                               (lv_daybal_type = '2' and
                               brch_id = lv_brchid))) loop
        p_daybal_data(lv_clrdate,
                      '1',
                      lrec_temp.user_id,
                      lv_in(1),
                      av_debug,
                      av_res,
                      av_msg);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark ||
                                 'tr_day_bal_data��Ա������-����:brch_id=' ||
                                 lv_brchid || ',oper_id=' || lv_operid,
                                 lv_actionno);
    
    end if;
  
    --����ʱ����������������
    if lv_daybal_type in ('2') then
      ls_key := 'tr_day_bal_data����-��ʼ:brch_id=' || lv_brchid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      for lrec_temp in (select * from sys_branch where brch_id = lv_brchid) loop
        p_daybal_data(lv_clrdate,
                      '2',
                      lrec_temp.brch_id,
                      lv_in(1),
                      av_debug,
                      av_res,
                      av_msg);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark ||
                                 'tr_day_bal_data����-����:brch_id=' ||
                                 lv_brchid,
                                 lv_actionno);
      --����ʱ���������������
    elsif lv_daybal_type in ('3') then
      ls_key := 'tr_day_bal_data����-��ʼ:org_id=' || lv_orgid;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || ls_key,
                                 lv_actionno);
      for lrec_temp in (select * from sys_organ where org_id = lv_orgid) loop
        p_daybal_data(lv_clrdate,
                      '3',
                      lrec_temp.org_id,
                      lv_in(1),
                      av_debug,
                      av_res,
                      av_res);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark ||
                                 'tr_day_bal_data����-����:org_id=' || lv_orgid,
                                 lv_actionno);
    end if;
  
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '����-���:' || av_in,
                               lv_actionno);
  
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
      av_msg := lv_remark || '�쳣-���:' || av_in || ',' || 'key:' || ls_key || ',' ||
                SQLERRM;
      pk_public.p_insertrzcllog_(av_debug, av_msg, lv_actionno);
  END p_daybal;

  /*=======================================================================================*/
  --����ֹʱ�������������˻������ݱ�tr_day_bal_base
  --as_orgid������ָ�������������л���[as_orgΪ��ʱ]�������㡢��Ա����
  /*=======================================================================================*/
  PROCEDURE p_batch_daybal(as_start_date varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                           as_end_date   varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                           as_orgid      sys_organ.org_id%type, --Ϊ��ʱͳ�����л���
                           av_actionno   in number, --ҵ����ˮ��
                           av_debug      IN VARCHAR2, --����0�ǣ�1��
                           av_res        OUT VARCHAR2, --������������
                           av_msg        OUT VARCHAR2 --��������������Ϣ
                           ) is
    ld_date     date := sysdate;
    ls_cur_date varchar2(10); --��ǰͳ������
    ls_end_date varchar2(10); --ͳ�ƽ�������
    --ls_res      varchar2(20);
    --ls_msg      varchar2(500);
  
  begin
    ls_cur_date := as_start_date;
    if ls_cur_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_cur_date from dual;
      null;
    end if;
    ls_end_date := as_end_date;
    if as_end_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_end_date from dual;
      null;
    end if;
    while ls_cur_date <= ls_end_date loop
      --av_in: 1action_no|2tr_code|3oper_id|4oper_time| 5clr_date|6daybal_type|7daybal_owner_id
      --�����㣬�ٻ�������������ʱ���ȴ����Ա
      for lrec_brch in (select org_id, brch_id
                          from sys_branch
                         where brch_type = '1'
                           and as_orgid is null
                            or org_id = as_orgid) loop
        p_daybal(av_actionno || '|1|admin||' || ls_cur_date || '|2|' ||
                 lrec_brch.brch_id,
                 av_debug,
                 av_res,
                 av_msg);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
      for lrec_org in (select org_id
                         from sys_organ
                        where as_orgid is null
                           or org_id = as_orgid) loop
        p_daybal(av_actionno || '|1|admin||' || ls_cur_date || '|3|' ||
                 lrec_org.org_id,
                 av_debug,
                 av_res,
                 av_msg);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
      ls_cur_date := to_char(to_date(ls_cur_date, 'yyyy-mm-dd') + 1,
                             'yyyy-mm-dd');
      null;
    end loop;
  exception
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  end p_batch_daybal;

  /*=======================================================================================*/
  --����ֹʱ�����������������ݱ�tr_day_bal_data��ǰ����tr_day_base�����Ѿ�����
  --av_daybal_typeΪ1��Ա�����ɹ�Ա���ݣ�2���㣺�������㡢��Ա���ݣ�3���������ɻ��������㡢��Ա����
  /*=======================================================================================*/
  PROCEDURE p_batch_daybal_data(as_start_date     varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                as_end_date       varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                av_daybal_type    varchar2, --1��Ա��2���㣬3����
                                av_daybal_ownerid IN VARCHAR2, --����������
                                av_actionno       in number, --ҵ����ˮ��
                                av_debug          IN VARCHAR2, --����0�ǣ�1��
                                av_res            OUT VARCHAR2, --������������
                                av_msg            OUT VARCHAR2 --��������������Ϣ
                                ) is
    ld_date     date := sysdate;
    ls_cur_date varchar2(10); --��ǰͳ������
    ls_end_date varchar2(10); --ͳ�ƽ�������
  begin
    ls_cur_date := as_start_date;
    if ls_cur_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_cur_date from dual;
      null;
    end if;
    ls_end_date := as_end_date;
    if as_end_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_end_date from dual;
      null;
    end if;
    while ls_cur_date <= ls_end_date loop
      if av_daybal_type in ('1', '2', '3') then
        for lrec_temp in (select *
                            from sys_users
                           where (av_daybal_type = '1' and
                                 user_id = av_daybal_ownerid or
                                 (av_daybal_type = '2' and
                                 brch_id = av_daybal_ownerid) or
                                 (av_daybal_type = '3' and
                                 (av_daybal_ownerid is null or
                                 org_id = av_daybal_ownerid)))) loop
          p_daybal_data(ls_cur_date,
                        '1',
                        lrec_temp.user_id,
                        av_actionno,
                        av_debug,
                        av_res,
                        av_msg);
          if av_res <> pk_public.cs_res_ok then
            return;
            null;
          end if;
        end loop;
      elsif av_daybal_type in ('2', '3') then
        for lrec_temp in (select *
                            from sys_branch
                           where ((av_daybal_type = '2' and
                                 brch_id = av_daybal_ownerid) or
                                 (av_daybal_type = '3' and
                                 org_id = av_daybal_ownerid))) loop
          p_daybal_data(ls_cur_date,
                        '2',
                        lrec_temp.brch_id,
                        av_actionno,
                        av_debug,
                        av_res,
                        av_msg);
          if av_res <> pk_public.cs_res_ok then
            return;
            null;
          end if;
        end loop;
        --��ǰ���������л���
      elsif av_daybal_type in ('3') then
        for lrec_temp in (select *
                            from sys_organ
                           where (av_daybal_ownerid is null or
                                 org_id = av_daybal_ownerid)) loop
          p_daybal_data(ls_cur_date,
                        '3',
                        lrec_temp.org_id,
                        av_actionno,
                        av_debug,
                        av_res,
                        av_msg);
          if av_res <> pk_public.cs_res_ok then
            return;
            null;
          end if;
        end loop;
      end if;
    
      ls_cur_date := to_char(to_date(ls_cur_date, 'yyyy-mm-dd') + 1,
                             'yyyy-mm-dd');
      null;
    end loop;
  exception
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  end p_batch_daybal_data;

  /*=======================================================================================*/
  --��ֵ����ͳ�ƣ����������ͳ���˻���ˮ���¼��stat_charge_consume����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_stat_charge_consume(av_clrdate varchar2, --�������
                                  av_orgid   sys_organ.org_id%type, --������Ϊ��ʱͳ�����л���
                                  av_debug   IN VARCHAR2, --����0�ǣ�1��
                                  av_res     OUT VARCHAR2, --������������
                                  av_msg     OUT VARCHAR2 --��������������Ϣ
                                  ) is
    lr_cursor     pk_public.t_cur; --�α�
    ls_tablename  VARCHAR2(50);
    ld_date       date := sysdate;
    lr_stat_table stat_card_pay%ROWTYPE;
    ln_count      number;
    ls_sql        varchar2(4000);
    lr_stat_conf  stat_conf%rowtype;
    lv_remark     acc_rzcllog.remark%type := 'p_stat_charge_consume:'; --��־
    ls_key        varchar(128) := '';
    ls_param      varchar(128) := 'param:clr_date= ' || av_clrdate ||
                                  ',org_id=' || av_orgid;
    PROCEDURE p_ins_stat_table IS
      lv_per_num NUMBER;
      lv_per_amt NUMBER;
      lv_end_num NUMBER;
      lv_end_amt NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO ln_count
        FROM stat_card_pay
       WHERE clr_date = lr_stat_table.clr_date
         AND org_id = lr_stat_table.org_id
         AND co_org_id = lr_stat_table.co_org_id
         AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
         AND deal_code = lr_stat_table.deal_code
         AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
         AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
      IF ln_count = 0 THEN
        SELECT seq_stat_id.nextval, ld_date
          INTO lr_stat_table.stat_id, lr_stat_table.create_time
          FROM dual;
      ELSE
        SELECT seq_stat_id.nextval, ld_date
          INTO lr_stat_table.stat_id, lr_stat_table.create_time
          FROM dual;
        DELETE FROM stat_card_pay
         WHERE clr_date = lr_stat_table.clr_date
           AND org_id = lr_stat_table.org_id
           AND co_org_id = lr_stat_table.co_org_id
           AND acpt_id = lr_stat_table.acpt_id
           AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
           AND deal_code = lr_stat_table.deal_code
           AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
           AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
      END IF;
    
      INSERT INTO stat_card_pay VALUES lr_stat_table;
      --�����ڳ���� ��ĩ���  �ڳ����� ��ĩ����
      SELECT nvl(SUM(end_num), 0), nvl(SUM(end_amt), 0)
        INTO lv_per_num, lv_per_amt
        FROM (select *
                from stat_card_pay
               WHERE clr_date < av_clrdate
                 AND co_org_id = lr_stat_table.co_org_id
                 AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
                 AND deal_code = lr_stat_table.deal_code
                 AND acpt_id = lr_stat_table.acpt_id
                 AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
                 AND nvl(card_type, '-1') =
                     nvl(lr_stat_table.card_type, '-1')
               order by clr_date desc)
       where rownum < 2;
    
      UPDATE stat_card_pay
         SET per_num = lv_per_num, per_amt = lv_per_amt
       WHERE clr_date = lr_stat_table.clr_date
         AND org_id = lr_stat_table.org_id
         AND co_org_id = lr_stat_table.co_org_id
         AND acpt_id = lr_stat_table.acpt_id
         AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
         AND deal_code = lr_stat_table.deal_code
         AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
         AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
    
      UPDATE stat_card_pay
         SET end_num = lv_per_num + lr_stat_table.num,
             end_amt = lv_per_amt + lr_stat_table.amt
       WHERE clr_date = lr_stat_table.clr_date
         AND org_id = lr_stat_table.org_id
         AND co_org_id = lr_stat_table.co_org_id
         AND acpt_id = lr_stat_table.acpt_id
         AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
         AND deal_code = lr_stat_table.deal_code
         AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
         AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
    END p_ins_stat_table;
  
  begin
    av_res := pk_public.cs_res_ok;
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '��ʼ:' || ls_param,
                               0);
    if av_clrdate is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ϊ��' || ls_param;
      RETURN;
    end if;
  
    ls_tablename := 'acc_inout_detail_' ||
                    substr(replace(av_clrdate, '-', ''), 0, 6); /*replace(av_clrdate, '-', '')*/
  
    select count(*)
      into ln_count
      from user_tables t
     where table_name = ls_tablename;
    if ln_count = 1 then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��' || ls_tablename || '������' || ls_param;
      return;
    end if;
  
    select t.*
      into lr_stat_conf
      from stat_conf t
     where stat_conf_id = 'STAT_CARD_PAY'; --ȡ��ǰͳ�ƵĽ��״�������
  
    --������ѭ��
  
    for lr_org in (select *
                     from sys_organ
                    where (org_id = av_orgid or av_orgid is null)) loop
      DELETE FROM stat_card_pay
      /*WHERE (org_id = av_orgid or av_orgid is null)*/
       WHERE org_id = lr_org.org_id
         and clr_date = av_clrdate;
    
      ls_key := 'org_id= ' || lr_org.org_id || ',table_name=' ||
                ls_tablename;
      ls_sql := 'select null,
               t.acpt_type,
               t.acpt_id,
               t.card_org_id,
               t.acpt_org_id,
               ''' || av_clrdate || ''' clr_Date,
               t.deal_code,
               t.cr_card_type card_type,
               t.cr_acc_kind acc_kind,
               count(1),
               sum(cr_amt),
               null,
               null,
               null,
               null,
               null,
               null
          from ' || ls_tablename || ' t
         where   card_org_id =''' || lr_org.org_id || '''
           and deal_code ' || lr_stat_conf.trcode_1 ||
                ' --��ֵ��
           and clr_date =''' || av_clrdate || '''
         group by card_org_id,acpt_org_id,acpt_type, acpt_id, deal_code, cr_card_type,cr_acc_kind
         union
         select null,
               t.acpt_type,
               t.acpt_id,
               t.card_org_id,
               t.acpt_org_id,
               ''' || av_clrdate || ''',
               t.deal_code,
               t.db_card_type card_type,
               t.db_acc_kind acc_kind,
               count(1),
               -sum(db_amt),
               null,
               null,
               null,
               null,
               null,
               null
          from ' || ls_tablename || ' t
         where card_org_id =''' || lr_org.org_id || '''
           and deal_code ' || lr_stat_conf.trcode_2 ||
                ' --������
           and clr_date =''' || av_clrdate || '''
         group by card_org_id,acpt_org_id,acpt_type, acpt_id, deal_code, db_card_type,db_acc_kind';
    
      open lr_cursor for ls_sql;
      LOOP
        FETCH lr_cursor
          INTO lr_stat_table;
        EXIT WHEN lr_cursor%NOTFOUND;
        p_ins_stat_table;
      END LOOP;
      CLOSE lr_cursor;
    end loop;
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '����:' || ls_param,
                               0);
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := lv_remark || '�쳣:' || ls_param || ',' || 'key:' || ls_key ||
                SQLERRM;
      pk_public.p_insertrzcllog_(av_debug, av_msg, 0);
  end p_stat_charge_consume;
  /*=======================================================================================*/
  --�����ֹ�ͳ�ƣ���ֵ����ͳ�ƣ����������ͳ���˻���ˮ���¼��stat_charge_consume����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_batch_stat_charge_consume(av_start_date varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                        av_end_date   varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                        av_orgid      sys_organ.org_id%type, --������Ϊ��ʱͳ�����л���
                                        av_debug      IN VARCHAR2, --����0�ǣ�1��
                                        av_res        OUT VARCHAR2, --������������
                                        av_msg        OUT VARCHAR2 --��������������Ϣ
                                        ) is
    ld_date     date := sysdate;
    ls_cur_date varchar2(10); --��ǰͳ������
    ls_end_date varchar2(10); --ͳ�ƽ�������
  begin
    ls_cur_date := av_start_date;
    if ls_cur_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_cur_date from dual;
      null;
    end if;
    ls_end_date := av_end_date;
    if ls_end_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_end_date from dual;
      null;
    end if;
    while ls_cur_date <= ls_end_date loop
      --������ѭ��
      for lr_org in (select *
                       from sys_organ
                      where (org_id = av_orgid or av_orgid is null)) loop
        p_stat_charge_consume(ls_cur_date,
                              lr_org.org_id,
                              av_debug,
                              av_res,
                              av_msg);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
      ls_cur_date := to_char(to_date(ls_cur_date, 'yyyy-mm-dd') + 1,
                             'yyyy-mm-dd');
    
    end loop;
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  end p_batch_stat_charge_consume;

  /*=======================================================================================*/
  --����ҵ��ͳ�ƣ����������ͳ���ۺ�ҵ����¼��stat_agent_busi����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_stat_agent_busi(av_clrdate varchar2, --�������
                              av_coorgid sys_organ.org_id%type, --����
                              av_debug   IN VARCHAR2, --����0�ǣ�1��
                              av_res     OUT VARCHAR2, --������������
                              av_msg     OUT VARCHAR2 --��������������Ϣ
                              ) is
    ld_date date := sysdate;
    --lr_stat_table stat_agent_busi%ROWTYPE;
    ln_count  number;
    lv_remark acc_rzcllog.remark%type := 'p_stat_agent_busi:'; --��־
    ls_key    varchar(128) := 'key:';
    ls_param  varchar(128) := 'param:clr_date= ' || av_clrdate ||
                              ',org_id=' || av_coorgid;
  begin
    av_res := pk_public.cs_res_ok;
    if av_clrdate is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ϊ��' || ls_param;
      RETURN;
    end if;
    DELETE FROM stat_agent
     WHERE clr_date = av_clrdate
       and (org_id = av_coorgid or av_coorgid is null)
       and (acpt_id = av_coorgid or av_coorgid is null);
    for lr_stat_table in (select null as stat_id, --id
                                 t.co_org_id,
                                 t.co_org_id acpt_id,
                                 av_clrdate as clr_date, --clr_date
                                 t.deal_code,
                                 t.card_type,
                                 sum(nvl(num, 1)) cnt,
                                 SUM(nvl(num, 1)) num,
                                 SUM(nvl(amt, 0)) amt,
                                 sum(0) points,
                                 null create_Time,
                                 null notes
                            from tr_serv_rec t
                           where t.co_org_id = av_coorgid
                             and t.clr_date = av_clrdate
                           group by t.co_org_id, t.deal_code, t.card_Type) loop
      ls_key := 'org_id= ' || lr_stat_table.co_org_id || ',brch_id=' ||
                lr_stat_table.acpt_id || ',deal_code=' ||
                lr_stat_table.deal_code || ',card_type=' ||
                lr_stat_table.card_type;
      --lr_stat_table.stat_id := seq_stat_id.nextval;
      select seq_stat_id.nextval into lr_stat_table.stat_id from dual;
      INSERT INTO stat_agent VALUES lr_stat_table;
    end loop;
  
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '����:' || ls_param,
                               0);
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := lv_remark || '�쳣:' || ls_param || ',' || 'key:' || ls_key ||
                SQLERRM;
      pk_public.p_insertrzcllog_(av_debug, av_msg, 0);
  end p_stat_agent_busi;

  /*=======================================================================================*/
  --�����ֹ�ͳ�ƣ�����ҵ��ͳ�ƣ����������ͳ���ۺ�ҵ����¼��stat_agent_busi����ʱ������
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_batch_stat_agent_busi(av_start_date varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                    av_end_date   varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                    av_coorgid    sys_organ.org_id%type, --����
                                    av_debug      IN VARCHAR2, --����0�ǣ�1��
                                    av_res        OUT VARCHAR2, --������������
                                    av_msg        OUT VARCHAR2 --��������������Ϣ
                                    ) is
    ld_date     date := sysdate;
    ls_cur_date varchar2(10); --��ǰͳ������
    ls_end_date varchar2(10); --ͳ�ƽ�������
  begin
    /* select t.*
     into lr_stat_conf
     from stat_conf t
    where stat_conf_id = 'STAT_AGENT_BUSI';*/ --ȡ��ǰͳ�ƵĽ��״�������
    ls_cur_date := av_start_date;
    if ls_cur_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_cur_date from dual;
      null;
    end if;
    ls_end_date := av_end_date;
    if av_end_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_end_date from dual;
      null;
    end if;
    while ls_cur_date <= ls_end_date loop
      --������ѭ��
      for lr_brch in (select *
                        FROM base_co_org
                       where (co_org_id = av_coorgid or av_coorgid is NULL)) loop
        p_stat_agent_busi(ls_cur_date,
                          lr_brch.co_org_id,
                          av_debug,
                          av_res,
                          av_msg);
        if av_res <> pk_public.cs_res_ok then
          return;
          null;
        end if;
      end loop;
    
      ls_cur_date := to_char(to_date(ls_cur_date, 'yyyy-mm-dd') + 1,
                             'yyyy-mm-dd');
    
    end loop;
  
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  end p_batch_stat_agent_busi;

  /*=======================================================================================*/
  --�ֽ�ҵ��ͳ�ƣ�ֱ��ȡ�������ݱ�tr_day_bal_data�е�CASH_ITEM��Ӧ��ͳ����
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_stat_cash_busi(av_clrdate        varchar2, --�������
                             av_daybal_type    varchar2, --1��Ա��2���㣬3����
                             av_daybal_ownerid IN VARCHAR2, --����������
                             av_debug          IN VARCHAR2, --����0�ǣ�1��
                             av_res            OUT VARCHAR2, --������������
                             av_msg            OUT VARCHAR2 --��������������Ϣ
                             ) is
    ld_date   date := sysdate;
    lv_remark acc_rzcllog.remark%type := 'p_stat_cash_busi:'; --��־
    ls_param  varchar(128) := 'param:clr_date= ' || av_clrdate ||
                              ',daybal_type=' || av_daybal_type ||
                              ',daybal_id=' || av_daybal_ownerid;
    ls_key    varchar(128) := '';
  begin
    av_res := pk_public.cs_res_ok;
    av_res := pk_public.cs_res_ok;
    if av_clrdate is null or av_daybal_type is null or
       av_daybal_ownerid is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ϊ��' || ls_param;
      RETURN;
    end if;
    DELETE FROM stat_cash
     WHERE clr_date = av_clrdate
       and ((av_daybal_type = '1' and oper_id = av_daybal_ownerid) or
           --������������ʱ���������������
           (av_daybal_type = '2' and brch_id = av_daybal_ownerid and
           oper_id is null) or
           (av_daybal_type = '3' and org_id = av_daybal_ownerid and
           brch_id is null and oper_id is null));
  
    if av_daybal_type = '1' then
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || '��Ա' || ls_param,
                                 0);
      for lr_stat_table in (select null stat_id, --seq_stat_id.nextval,
                                   av_daybal_type own_type,
                                   org_id,
                                   brch_id,
                                   user_id,
                                   av_clrdate,
                                   deal_code,
                                   count(distinct(deal_no)) num,
                                   sum(amt) amt,
                                   ld_date,
                                   null
                              from cash_box_rec t
                             where clr_date = av_clrdate
                               and user_id = av_daybal_ownerid
                               and org_id is not null
                               and brch_id is not null
                               and user_id is not null
                             group by deal_code, org_id, brch_id, user_id) loop
        ls_key := 'org_id= ' || lr_stat_table.org_id || ',brch_id=' ||
                  lr_stat_table.brch_id || ',oper_id=' ||
                  lr_stat_table.user_id || ',deal_code=' ||
                  lr_stat_table.deal_code;
        select seq_stat_id.nextval into lr_stat_table.stat_id from dual;
        BEGIN
          insert into stat_cash values lr_stat_table;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      end loop;
    elsif av_daybal_type = '2' then
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || '����' || ls_param,
                                 0);
      for lr_stat_table in (select null stat_id, --seq_stat_id.nextval,
                                   av_daybal_type own_type,
                                   org_id,
                                   brch_id,
                                   null oper_id,
                                   av_clrdate,
                                   deal_code,
                                   count(distinct(deal_no)) num,
                                   sum(amt) amt,
                                   ld_date,
                                   null
                              from cash_box_rec t
                             where clr_date = av_clrdate
                               and brch_id = av_daybal_ownerid
                               and org_id is not null
                               and brch_id is not null
                            --�ո����㲻ͬʱ�ż���ͳ��
                            /*and (t.other_brch_id is null or
                                                        t.other_brch_id <> brch_id)*/
                             group by deal_code, org_id, brch_id) loop
        ls_key := 'org_id= ' || lr_stat_table.org_id || ',brch_id=' ||
                  lr_stat_table.brch_id || ',deal_code=' ||
                  lr_stat_table.deal_code;
        select seq_stat_id.nextval into lr_stat_table.stat_id from dual;
      
        BEGIN
          insert into stat_cash values lr_stat_table;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      end loop;
    elsif av_daybal_type = '3' then
      pk_public.p_insertrzcllog_(av_debug,
                                 lv_remark || '����' || ls_param,
                                 0);
      for lr_stat_table in (select null stat_id, --seq_stat_id.nextval,
                                   av_daybal_type own_type,
                                   org_id,
                                   null brch_id,
                                   null oper_id,
                                   av_clrdate,
                                   deal_code,
                                   count(distinct(deal_no)) num,
                                   sum(amt) amt,
                                   ld_date,
                                   null
                              from cash_box_rec t
                             where clr_date = av_clrdate
                               and org_id = av_daybal_ownerid
                               and org_id is not null
                            --�ո����㲻ͬʱ�ż���ͳ��
                            /* and (t.other_org_id is null or
                                                        t.other_org_id <> org_id)*/
                             group by deal_code, org_id) loop
        ls_key := 'org_id= ' || lr_stat_table.org_id || ',deal_code=' ||
                  lr_stat_table.deal_code;
        select seq_stat_id.nextval into lr_stat_table.stat_id from dual;
        BEGIN
          insert into stat_cash values lr_stat_table;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      end loop;
    end if;
  
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := lv_remark || '�쳣:' || ls_param || ',key:' || ls_key || ',' ||
                SQLERRM;
      pk_public.p_insertrzcllog_(av_debug, av_msg, 0);
  end p_stat_cash_busi;

  /*=======================================================================================*/
  --�����ֹ�ͳ�ƣ��ֽ�ҵ��ͳ�ƣ�ֱ��ȡ�������ݱ�tr_day_bal_data�е�CASH_ITEM��Ӧ��ͳ����
  --�����ѯʱ��ֱ�Ӳ�ѯ��ʱ��
  /*=======================================================================================*/
  procedure p_batch_stat_cash_busi(as_start_date     varchar2, --��ʼ����yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                   as_end_date       varchar2, --��������yyyy-mm-dd��Ϊ��Ĭ��Ϊ����
                                   av_daybal_type    varchar2, --1��Ա��2���㣬3����
                                   av_daybal_ownerid IN VARCHAR2, --����������
                                   av_debug          IN VARCHAR2, --����0�ǣ�1��
                                   av_res            OUT VARCHAR2, --������������
                                   av_msg            OUT VARCHAR2 --��������������Ϣ
                                   ) is
    ld_date     date := sysdate;
    ls_cur_date varchar2(10); --��ǰͳ������
    ls_end_date varchar2(10); --ͳ�ƽ�������
  begin
    ls_cur_date := as_start_date;
    if ls_cur_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_cur_date from dual;
      null;
    end if;
    ls_end_date := as_end_date;
    if as_end_date is null then
      select to_char(ld_date, 'yyyy-mm-dd') into ls_end_date from dual;
      null;
    end if;
    while ls_cur_date <= ls_end_date loop
      --p_stat_cash_busi(ls_cur_date, av_debug, av_res, av_msg);
      if av_res <> pk_public.cs_res_ok then
        return;
        null;
      end if;
    
      if av_daybal_type in ('1', '2', '3') then
        for lrec_temp in (select *
                            from sys_users
                           where ((av_daybal_type = '1' and
                                 user_id = av_daybal_ownerid) or
                                 (av_daybal_type = '2' and
                                 brch_id = av_daybal_ownerid) or
                                 (av_daybal_type = '3' and
                                 org_id = av_daybal_ownerid) or
                                 av_daybal_ownerid is null)) loop
          p_stat_cash_busi(ls_cur_date,
                           '1',
                           lrec_temp.user_id,
                           av_debug,
                           av_res,
                           av_msg);
          if av_res <> pk_public.cs_res_ok then
            return;
            null;
          end if;
        end loop;
      end if;
      if av_daybal_type in ('2', '3') then
        for lrec_temp in (select *
                            from sys_branch
                           where ((av_daybal_type = '2' and
                                 brch_id = av_daybal_ownerid) or
                                 (av_daybal_type = '3' and
                                 org_id = av_daybal_ownerid) or
                                 av_daybal_ownerid is null)) loop
          p_stat_cash_busi(ls_cur_date,
                           '2',
                           lrec_temp.brch_id,
                           av_debug,
                           av_res,
                           av_msg);
          if av_res <> pk_public.cs_res_ok then
            return;
            null;
          end if;
        end loop;
      end if;
      --��ǰ���������л���
      if av_daybal_type in ('3') then
        for lrec_temp in (select *
                            from sys_organ
                           where (av_daybal_ownerid is null or
                                 org_id = av_daybal_ownerid)) loop
          p_stat_cash_busi(ls_cur_date,
                           '3',
                           lrec_temp.org_id,
                           av_debug,
                           av_res,
                           av_msg);
          if av_res <> pk_public.cs_res_ok then
            return;
            null;
          end if;
        end loop;
      end if;
      ls_cur_date := to_char(to_date(ls_cur_date, 'yyyy-mm-dd') + 1,
                             'yyyy-mm-dd');
    end loop;
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  end p_batch_stat_cash_busi;

  /*=======================================================================================*/
  --�����ѻ����ݵĶ��˵���������ͳ��
  /*=======================================================================================*/
  procedure p_clr_offline_sum(av_biz_id   varchar2, --�̻���
                              av_clr_date varchar2, --�������
                              av_debug    IN VARCHAR2, --����0�ǣ�1��
                              av_res      OUT VARCHAR2, --������������
                              av_msg      OUT VARCHAR2 --��������������Ϣ
                              ) IS
    lv_nor_num    NUMBER; --��������
    lv_nor_amt    NUMBER; --�������
    lv_refuse_num NUMBER; --�ܸ�����
    lv_refuse_amt NUMBER; --�ܸ����
    lv_deal_num   NUMBER; --��������
    lv_deal_amt   NUMBER; --�������
  BEGIN
    --�������������
    SELECT nvl(COUNT(*), 0), nvl(SUM(deal_amt), 0)
      INTO lv_nor_num, lv_nor_amt
      FROM pay_offline_list t
     WHERE t.refuse_reason = '10'
       AND t.acpt_id = av_biz_id
       AND t.clr_date = av_clr_date;
    --�ܸ����������
    SELECT nvl(COUNT(*), 0), nvl(SUM(deal_amt), 0)
      INTO lv_refuse_num, lv_refuse_amt
      FROM pay_offline_black t
     WHERE t.acpt_id = av_biz_id
       AND t.clr_date = av_clr_date;
    --�������������
    SELECT nvl(COUNT(*), 0), nvl(SUM(deal_amt), 0)
      INTO lv_deal_num, lv_deal_amt
      FROM pay_offline_list t
     WHERE t.refuse_reason = '00'
       AND t.acpt_id = av_biz_id
       AND t.clr_date = av_clr_date;
  
    INSERT INTO pay_offline_clr_sum
      (merchant_id,
       clr_date,
       normol_num,
       normol_amt,
       refuse_num,
       refuse_amt,
       deal_num,
       deal_amt)
    VALUES
      (av_biz_id,
       av_clr_date,
       lv_nor_num,
       lv_nor_amt,
       lv_refuse_num,
       lv_refuse_amt,
       lv_deal_num,
       lv_deal_amt);
    av_res := pk_public.cs_res_ok;
    av_msg := '';
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  END p_clr_offline_sum;

  /*=======================================================================================*/
  --�������ֵͳ��
  --STAT_DEAL_CODE  VARCHAR2(100) Y     ͳ�ƵĽ��״���
  --STAT_IN_OUT_FLAG  VARCHAR2(1) Y     ͳ������֧��flag 1������ 2�� ֧�� 3�������� 4����֧�� 5�������� 6����֧�� 6���˻���ת
  --DATA_SOURCE VARCHAR2(1) Y     1��tr_serv_rec 2��acc_inout_detail 3��cash_book_rec 4��clr_deal_sum
  /*=======================================================================================*/
  procedure p_stat_readypay_sum(av_org_id   varchar2, --�̻���
                                av_clr_date varchar2, --�������
                                av_debug    IN VARCHAR2, --����0�ǣ�1��
                                av_res      OUT VARCHAR2, --������������
                                av_msg      OUT VARCHAR2 --��������������Ϣ
                                ) is
    lv_tablename             varchar2(50);
    lv_per_num               number;
    lv_per_amt               number;
    now_date                 date;
    lv_count                 number;
    lv_stat_readypayamt_data stat_readypayamt_data%rowtype;
  begin
    av_res := pk_public.cs_res_ok;
    delete from stat_readypayamt_data t where t.clr_date = av_clr_date;
    for cc in (select t.*, t.rowid from stat_readypayamt_conf t) loop
      SELECT nvl(SUM(end_num), 0), nvl(SUM(end_amt), 0)
        INTO lv_per_num, lv_per_amt
        FROM (select *
                from stat_readypayamt_data t
               WHERE clr_date < av_clr_date
                 AND t.stat_deal_code = cc.stat_item
               order by clr_date desc)
       where rownum < 2;
      /* 1:��Դ��tr_serv_Rec��*/
      if cc.data_source = 1 then
        EXECUTE IMMEDIATE 'select count(*) from stat_readypayamt_data t  where t.deal_code ' ||
                          cc.stat_deal_code_sql ||
                          ' and  t.deal_state = 0  and t.clr_date =:1'
          INTO lv_count
          USING av_clr_date;
        if lv_count = 0 then
          insert into stat_readypayamt_data
            (stat_deal_code,
             stat_in_out_flag,
             per_num,
             per_amt,
             num,
             amt,
             end_num,
             end_amt,
             clr_date)
          values
            (cc.stat_item,
             cc.stat_in_out_flag,
             lv_per_num,
             lv_per_amt,
             0,
             0,
             lv_per_num,
             lv_per_amt,
             av_clr_date);
        else
          execute immediate 'insert into stat_readypayamt_data ' ||
                            ' select :1,:2,:3,:4,nvl(count(1),0),nvl(count(1),0),(:5+nvl(count(1),0)),(:6+sum(abs(nvl(amt,0)))),:7 from tr_serv_Rec t' ||
                            ' where  t.deal_code ' || cc.stat_deal_code_sql ||
                            ' and t.deal_state = 0 and t.clr_date =:8 group by t.deal_code '
            using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_num, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
        end if;
      
        /* 2:��Դ��acc_inout_detail��*/
      elsif cc.data_source = 2 then
        lv_tablename := 'ACC_INOUT_DETAIL_' ||
                        substr(REPLACE(av_clr_date, '-', ''), 0, 6);
      
        EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                          ' t  where t.deal_code ' || cc.stat_deal_code_sql ||
                          ' and  /*t.deal_state in(0,3)  and*/ t.clr_date =:1'
          INTO lv_count
          USING av_clr_date;
        if lv_count = 0 then
          insert into stat_readypayamt_data
            (stat_deal_code,
             stat_in_out_flag,
             per_num,
             per_amt,
             num,
             amt,
             end_num,
             end_amt,
             clr_date)
          values
            (cc.stat_item,
             cc.stat_in_out_flag,
             lv_per_num,
             lv_per_amt,
             0,
             0,
             lv_per_num,
             lv_per_amt,
             av_clr_date);
        else
          execute immediate 'insert into  stat_readypayamt_data ' ||
                            ' select :1,:2,:3,:4,nvl(count(1),0),abs(sum(nvl(cr_amt,0))),(:5+nvl(count(1),0)),(:6+sum(abs(nvl(cr_amt,0)))),:7 from ' ||
                            lv_tablename || ' t where  deal_code' ||
                            cc.stat_deal_code_sql ||
                            ' /*and t.deal_state in(0,3)*/ ' ||
                            ' and t.clr_date =:8'
            using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
        end if;
        /* 3:��Դ��cash_book_rec��*/
      elsif cc.data_source = 3 then
        EXECUTE IMMEDIATE 'select count(*) from cash_box_rec t  where t.deal_code ' ||
                          cc.stat_deal_code_sql || '   and t.clr_date =:1'
          INTO lv_count
          USING av_clr_date;
        if lv_count = 0 then
          insert into stat_readypayamt_data
            (stat_deal_code,
             stat_in_out_flag,
             per_num,
             per_amt,
             num,
             amt,
             end_num,
             end_amt,
             clr_date)
          values
            (cc.stat_item,
             cc.stat_in_out_flag,
             lv_per_num,
             lv_per_amt,
             0,
             0,
             lv_per_num,
             lv_per_amt,
             av_clr_date);
        else
          execute immediate 'insert into stat_readypayamt_data ' ||
                            ' select :1,:2,:3,:4,nvl(count(1),0),nvl(abs(sum(nvl(amt,0))),0),nvl((:5+nvl(count(1),0)),0),nvl((:6+sum(abs(nvl(amt,0)))),0),:7 from cash_box_rec t' ||
                            ' where t.deal_code ' || cc.stat_deal_code_sql ||
                            '  and t.clr_date=:8 group by t.deal_code '
            using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
        
        end if;
      
        /* 4:��Դ��pay_clr_sum��*/
      elsif cc.data_source = 4 then
        if cc.stat_item = 'meronline_tot_out' then
          EXECUTE IMMEDIATE 'select count(*) from pay_clr_sum t  where t.deal_code ' ||
                            cc.stat_deal_code_sql || ' and t.clr_date =:1'
            INTO lv_count
            USING av_clr_date;
          if lv_count = 0 then
            insert into stat_readypayamt_data
              (stat_deal_code,
               stat_in_out_flag,
               per_num,
               per_amt,
               num,
               amt,
               end_num,
               end_amt,
               clr_date)
            values
              (cc.stat_item,
               cc.stat_in_out_flag,
               lv_per_num,
               lv_per_amt,
               0,
               0,
               lv_per_num,
               lv_per_amt,
               av_clr_date);
          else
            execute immediate 'insert into stat_readypayamt_data ' ||
                              ' select :1,:2,:3,:4,nvl(sum(deal_num),0),nvl(abs(sum(nvl(deal_amt,0))),0),nvl((:5+sum(deal_num)),0),nvl((:6+sum(deal_amt)),0),:7 from pay_clr_sum t' ||
                              ' where t.deal_code ' ||
                              cc.stat_deal_code_sql ||
                              ' and t.clr_date=:8 '
              using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
          end if;
        elsif cc.stat_item = 'meroffline_tot_out' then
          EXECUTE IMMEDIATE 'select count(*) from pay_clr_sum t  where t.deal_code ' ||
                            cc.stat_deal_code_sql || '  and t.clr_date =:1'
            INTO lv_count
            USING av_clr_date;
          if lv_count = 0 then
            insert into stat_readypayamt_data
              (stat_deal_code,
               stat_in_out_flag,
               per_num,
               per_amt,
               num,
               amt,
               end_num,
               end_amt,
               clr_date)
            values
              (cc.stat_item,
               cc.stat_in_out_flag,
               lv_per_num,
               lv_per_amt,
               0,
               0,
               lv_per_num,
               lv_per_amt,
               av_clr_date);
          else
            execute immediate 'insert into stat_readypayamt_data ' ||
                              ' select :1,:2,:3,:4,nvl(sum(deal_num),0),nvl(abs(sum(nvl(deal_amt,0))),0),nvl((:5+sum(deal_num)),0),nvl((:6+sum(deal_amt)),0),:7 from pay_clr_sum t' ||
                              ' where t.deal_code ' ||
                              cc.stat_deal_code_sql ||
                              ' and t.clr_date=:8 '
              using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
          end if;
        elsif cc.stat_item = 'meronline_yjs_out' then
          EXECUTE IMMEDIATE 'select count(*) from pay_clr_sum t  where t.deal_code ' ||
                            cc.stat_deal_code_sql ||
                            '  and t.stl_flag=0 and t.clr_date =:1'
            INTO lv_count
            USING av_clr_date;
          if lv_count = 0 then
            insert into stat_readypayamt_data
              (stat_deal_code,
               stat_in_out_flag,
               per_num,
               per_amt,
               num,
               amt,
               end_num,
               end_amt,
               clr_date)
            values
              (cc.stat_item,
               cc.stat_in_out_flag,
               lv_per_num,
               lv_per_amt,
               0,
               0,
               lv_per_num,
               lv_per_amt,
               av_clr_date);
          else
            execute immediate 'insert into stat_readypayamt_data ' ||
                              ' select :1,:2,:3,:4,nvl(sum(deal_num),0),nvl(abs(sum(nvl(deal_amt,0))),0),nvl((:5+sum(deal_num)),0),nvl((:6+sum(deal_amt)),0),:7 from pay_clr_sum t' ||
                              ' where t.deal_code ' ||
                              cc.stat_deal_code_sql ||
                              '  and t.stl_flag=0 and t.clr_date=:8 '
              using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
          end if;
        elsif cc.stat_item = 'meroffline_yjs_out' then
          EXECUTE IMMEDIATE 'select count(*) from pay_clr_sum t  where t.deal_code ' ||
                            cc.stat_deal_code_sql ||
                            '  and t.stl_flag=0 and t.clr_date =:1'
            INTO lv_count
            USING av_clr_date;
          if lv_count = 0 then
            insert into stat_readypayamt_data
              (stat_deal_code,
               stat_in_out_flag,
               per_num,
               per_amt,
               num,
               amt,
               end_num,
               end_amt,
               clr_date)
            values
              (cc.stat_item,
               cc.stat_in_out_flag,
               lv_per_num,
               lv_per_amt,
               0,
               0,
               lv_per_num,
               lv_per_amt,
               av_clr_date);
          else
            execute immediate 'insert into stat_readypayamt_data ' ||
                              ' select :1,:2,:3,:4,nvl(sum(deal_num),0),nvl(abs(sum(nvl(deal_amt,0))),0),nvl((:5+sum(deal_num)),0),nvl((:6+sum(deal_amt)),0),:7 from pay_clr_sum t' ||
                              ' where t.deal_code ' ||
                              cc.stat_deal_code_sql ||
                              '  and t.stl_flag=0 and t.clr_date=:8'
              using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
          end if;
        elsif cc.stat_item = 'meronline_wjs_out' then
          EXECUTE IMMEDIATE 'select count(*) from pay_clr_sum t  where t.deal_code ' ||
                            cc.stat_deal_code_sql ||
                            '  and t.stl_flag is null and t.clr_date =:1'
            INTO lv_count
            USING av_clr_date;
          if lv_count = 0 then
            insert into stat_readypayamt_data
              (stat_deal_code,
               stat_in_out_flag,
               per_num,
               per_amt,
               num,
               amt,
               end_num,
               end_amt,
               clr_date)
            values
              (cc.stat_item,
               cc.stat_in_out_flag,
               lv_per_num,
               lv_per_amt,
               0,
               0,
               lv_per_num,
               lv_per_amt,
               av_clr_date);
          else
            execute immediate 'insert into stat_readypayamt_data ' ||
                              ' select :1,:2,:3,:4,nvl(sum(deal_num),0),nvl(abs(sum(nvl(deal_amt,0))),0),nvl((:5+sum(deal_num)),0),nvl((:6+sum(deal_amt)),0),:7 from pay_clr_sum t' ||
                              ' where  t.deal_code ' ||
                              cc.stat_deal_code_sql ||
                              '  and t.stl_flag is null and t.clr_date=:8 '
              using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
          end if;
        elsif cc.stat_item = 'meroffline_wjs_out' then
          EXECUTE IMMEDIATE 'select count(*) from pay_clr_sum t  where t.deal_code ' ||
                            cc.stat_deal_code_sql ||
                            '  and t.stl_flag is null and t.clr_date =:1'
            INTO lv_count
            USING av_clr_date;
          if lv_count = 0 then
            insert into stat_readypayamt_data
              (stat_deal_code,
               stat_in_out_flag,
               per_num,
               per_amt,
               num,
               amt,
               end_num,
               end_amt,
               clr_date)
            values
              (cc.stat_item,
               cc.stat_in_out_flag,
               lv_per_num,
               lv_per_amt,
               0,
               0,
               lv_per_num,
               lv_per_amt,
               av_clr_date);
          else
            execute immediate 'insert into stat_readypayamt_data ' ||
                              ' select :1,:2,:3,:4,nvl(sum(deal_num),0),nvl(abs(sum(nvl(deal_amt,0))),0),nvl((:5+sum(deal_num)),0),nvl((:6+sum(deal_amt)),0),:7 from pay_clr_sum t' ||
                              ' where  t.deal_code ' ||
                              cc.stat_deal_code_sql ||
                              '  and t.stl_flag is null and t.clr_date=:8 '
              using cc.stat_item, cc.stat_in_out_flag, lv_per_num, lv_per_amt, lv_per_num, lv_per_amt, av_clr_date, av_clr_date;
          end if;
        else
          null;
        end if;
      else
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '����ֵ����';
      end if;
    end loop;
  end p_stat_readypay_sum;
  /*=======================================================================================*/
  --����������ֵ����ͳ�ƣ�
  /*=======================================================================================*/
  procedure p_stat_charge_consume_co_org(av_clrdate   varchar2, --�������
                                         av_co_org_id base_co_org.co_org_id%type, --������Ϊ��ʱͳ�����л���
                                         av_debug     IN VARCHAR2, --����0�ǣ�1��
                                         av_res       OUT VARCHAR2, --������������
                                         av_msg       OUT VARCHAR2 --��������������Ϣ
                                         ) is
    lr_cursor              pk_public.t_cur; --�α�
    ls_tablename           VARCHAR2(50);
    ld_date                date := sysdate;
    lr_stat_table          stat_card_pay%ROWTYPE;
    ln_count               number;
    ls_sql                 varchar2(4000);
    lr_stat_conf           stat_conf%rowtype;
    lv_remark              acc_rzcllog.remark%type := 'p_stat_charge_consume:'; --��־
    ls_key                 varchar(128) := '';
    ls_param               varchar(128) := 'param:clr_date= ' || av_clrdate ||
                                           ',org_id=' || av_co_org_id;
    lv_pay_co_check_single pay_co_check_single%rowtype;
    lv_count               number;
    PROCEDURE p_ins_stat_table IS
      lv_per_num NUMBER;
      lv_per_amt NUMBER;
      lv_end_num NUMBER;
      lv_end_amt NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO ln_count
        FROM stat_card_pay
       WHERE clr_date = lr_stat_table.clr_date
         AND org_id = lr_stat_table.org_id
         AND co_org_id = lr_stat_table.co_org_id
         AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
         AND deal_code = lr_stat_table.deal_code
         AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
         AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1')
         and nvl(notes, '-1') = nvl(lr_stat_table.notes, '-1');
      IF ln_count = 0 THEN
        SELECT seq_stat_id.nextval, ld_date
          INTO lr_stat_table.stat_id, lr_stat_table.create_time
          FROM dual;
      ELSE
        SELECT seq_stat_id.nextval, ld_date
          INTO lr_stat_table.stat_id, lr_stat_table.create_time
          FROM dual;
        DELETE FROM stat_card_pay
         WHERE clr_date = lr_stat_table.clr_date
           AND org_id = lr_stat_table.org_id
           AND co_org_id = lr_stat_table.co_org_id
           AND acpt_id = lr_stat_table.acpt_id
           AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
           AND deal_code = lr_stat_table.deal_code
           AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
           AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
      END IF;
    
      INSERT INTO stat_card_pay VALUES lr_stat_table;
      --�����ڳ���� ��ĩ���  �ڳ����� ��ĩ����
      SELECT nvl(SUM(end_num), 0), nvl(SUM(end_amt), 0)
        INTO lv_per_num, lv_per_amt
        FROM (select *
                from stat_card_pay
               WHERE clr_date < av_clrdate
                 AND co_org_id = lr_stat_table.co_org_id
                 AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
                 AND deal_code = lr_stat_table.deal_code
                 AND acpt_id = lr_stat_table.acpt_id
                 AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
                 AND nvl(card_type, '-1') =
                     nvl(lr_stat_table.card_type, '-1')
               order by clr_date desc)
       where rownum < 2;
    
      UPDATE stat_card_pay
         SET per_num = lv_per_num, per_amt = lv_per_amt
       WHERE clr_date = lr_stat_table.clr_date
         AND org_id = lr_stat_table.org_id
         AND co_org_id = lr_stat_table.co_org_id
         AND acpt_id = lr_stat_table.acpt_id
         AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
         AND deal_code = lr_stat_table.deal_code
         AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
         AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
    
      UPDATE stat_card_pay
         SET end_num = lv_per_num + lr_stat_table.num,
             end_amt = lv_per_amt + lr_stat_table.amt
       WHERE clr_date = lr_stat_table.clr_date
         AND org_id = lr_stat_table.org_id
         AND co_org_id = lr_stat_table.co_org_id
         AND acpt_id = lr_stat_table.acpt_id
         AND nvl(acpt_type, 9) = nvl(lr_stat_table.acpt_type, 9)
         AND deal_code = lr_stat_table.deal_code
         AND nvl(acc_kind, '-2') = nvl(lr_stat_table.acc_kind, '-2')
         AND nvl(card_type, '-1') = nvl(lr_stat_table.card_type, '-1');
    END p_ins_stat_table;
  
  begin
    av_res := pk_public.cs_res_ok;
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '��ʼ:' || ls_param,
                               0);
    if av_clrdate is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��������Ϊ��' || ls_param;
      RETURN;
    end if;
  
    ls_tablename := 'pay_card_deal_rec_' ||
                    substr(replace(av_clrdate, '-', ''), 0, 6); /*replace(av_clrdate, '-', '')*/
  
    select count(*)
      into ln_count
      from user_tables t
     where table_name = ls_tablename;
    if ln_count = 1 then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '��' || ls_tablename || '������' || ls_param;
      return;
    end if;
  
    select t.*
      into lr_stat_conf
      from stat_conf t
     where stat_conf_id = 'STAT_CARD_PAY_CO_ORG'; --ȡ��ǰͳ�ƵĽ��״�������
  
    --������ѭ��
  
    for lr_org in (select * from base_co_org where co_org_id = av_co_org_id) loop
    
      DELETE FROM stat_card_pay
       WHERE org_id = lr_org.org_id
         and co_org_id = lr_org.co_org_id
         and clr_date = av_clrdate;
    
      ls_key := 'org_id= ' || lr_org.org_id || ',table_name=' ||
                ls_tablename;
    
      ls_sql := 'select null,
               t.acpt_type,
               t.acpt_id,
               t.org_id,
               t.co_org_id,
               ''' || av_clrdate || ''' clr_Date,
               t.deal_code,
               t.card_type,
               t.acc_kind,
               count(1),
               sum(t.amt),
               null,
               null,
               null,
               null,
               null,
               nvl(t.posp_proc_state, ''1'') 
          from ' || ls_tablename ||
                ' t where t.co_org_id =''' || lr_org.co_org_id || '''
           and t.deal_code ' || lr_stat_conf.trcode_1 || ' 
           and t.acpt_type = ''2'' 
           and t.clr_date =''' || av_clrdate || '''
         group by t.acpt_type, t.acpt_id, t.org_id, t.co_org_id, t.deal_code, t.card_type, t.acc_kind, t.posp_proc_state';
    
      open lr_cursor for ls_sql;
      LOOP
        FETCH lr_cursor
          INTO lr_stat_table;
        EXIT WHEN lr_cursor%NOTFOUND;
        p_ins_stat_table;
      END LOOP;
      CLOSE lr_cursor;
    end loop;
    pk_public.p_insertrzcllog_(av_debug,
                               lv_remark || '����:' || ls_param,
                               0);
  exception
    when others then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := lv_remark || '�쳣:' || ls_param || ',' || 'key:' || ls_key ||
                SQLERRM;
      pk_public.p_insertrzcllog_(av_debug, av_msg, 0);
  end p_stat_charge_consume_co_org;
END pk_statistic;
/

