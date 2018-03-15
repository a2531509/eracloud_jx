CREATE OR REPLACE PACKAGE BODY pk_createobject IS
  cs_days CONSTANT NUMBER := 20; --预生成天数
  /*=======================================================================================*/
  --生成表acc_daybook,预生成cs_days天的表
  /*=======================================================================================*/
  PROCEDURE p_acc_day_book IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
    lv_sysdate   DATE;
    lv_table_comments varchar2(500);
  BEGIN
    lv_sysdate := SYSDATE;
    --lv_sysdate := to_date('2014-12-01','yyyy-MM-dd');
    lv_sysdate := to_date('2016-06-01','yyyy-MM-dd');
    FOR i IN 0 .. cs_days
    LOOP
      lv_tablename := upper('acc_inout_detail_' || to_char(add_months(trunc(lv_sysdate,'mm'),i), 'yyyymm'));
      EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' || lv_tablename || ''''
      INTO lv_count;
      IF lv_count = 0 THEN
        EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                          ' as select * from acc_inout_detail where rownum < 1';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','')|| '_an on ' ||
                          lv_tablename || '(deal_no)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','') ||'_db on ' ||
                          lv_tablename || '(db_acc_no)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_cr on ' ||
                          lv_tablename || '(cr_acc_no)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_rcd on ' ||
                          lv_tablename || '(cr_card_no)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_dcd on ' ||
                          lv_tablename || '(db_card_no)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_tim on ' ||
                          lv_tablename || '(deal_date)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_acp on ' ||
                          lv_tablename || '(acpt_id)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_bat on ' ||
                          lv_tablename || '(DEAL_BATCH_NO)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_deo on ' ||
                          lv_tablename || '(END_DEAL_NO)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_udr on ' ||
                          lv_tablename || '(user_id)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_ate on ' ||
                          lv_tablename || '(ACPT_TYPE)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_cde on ' ||
                          lv_tablename || '(CLR_DATE)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_cak on ' ||
                          lv_tablename || '(CR_ACC_KIND)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_dak on ' ||
                          lv_tablename || '(DB_ACC_KIND)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_dct on ' ||
                          lv_tablename || '(DB_CARD_TYPE)';
        EXECUTE IMMEDIATE 'create index ik_'|| replace(lv_tablename,'_','')||'_dal on ' ||
                          lv_tablename || '(DEAL_CODE)';
        EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                          ' add constraint pk_'||lv_tablename||' primary key (acc_inout_no) using index';
        begin
           select t.comments into lv_table_comments from user_tab_comments t where t.table_name = 'ACC_INOUT_DETAIL';
           lv_table_comments := substr(lv_table_comments,1,instr(lv_table_comments,'，',1,1) - 1);
           EXECUTE IMMEDIATE 'comment on table ' || lv_tablename || ' is ''' || lv_table_comments || to_char(add_months(trunc(lv_sysdate,'mm'),i),'yyyymm') || '''';
        exception
          when others then
            null;
        end;
        FOR lv_comment IN (SELECT *
                             FROM user_col_comments
                            WHERE table_name = upper('acc_inout_detail'))
        LOOP
          EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                            lv_comment.column_name || ' is ''' ||
                            lv_comment.comments || '''';
        END LOOP;
      END IF;
    END LOOP;
  END p_acc_day_book;

  /*=======================================================================================*/
  --生成表stk_stock_book,预生成下一年的表
  /*=======================================================================================*/
 /* PROCEDURE p_stk_stock_book IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
  BEGIN
    lv_tablename := upper('stk_stock_book_' ||
                          (to_char(SYSDATE, 'yyyy') + 1));
    EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                      lv_tablename || ''''
      INTO lv_count;
    IF lv_count = 0 THEN
      EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                        ' as select * from stk_stock_book where rownum < 1';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_an on ' ||
                        lv_tablename || '(action_no)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_cd on ' ||
                        lv_tablename || '(clr_date)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_ip on ' ||
                        lv_tablename || '(in_oper_id)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_op on ' ||
                        lv_tablename || '(out_oper_id)';
      EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                        ' add constraint pk_' || lv_tablename ||
                        ' primary key (stk_ser_no) using index';
      FOR lv_comment IN (SELECT *
                           FROM user_col_comments
                          WHERE table_name = upper('stk_stock_book'))
      LOOP
        EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                          lv_comment.column_name || ' is ''' ||
                          lv_comment.comments || '''';
      END LOOP;
    END IF;
  END p_stk_stock_book;
  /*=======================================================================================*/
  --生成表tr_serv_rec,预生成下一年的表
  /*=======================================================================================*/
 /* PROCEDURE p_tr_serv_rec IS
    lv_count     NUMBER;
    lv_min_year  VARCHAR2(4) := '2014';
    lv_tablename VARCHAR2(50);
  BEGIN
    BEGIN
      SELECT substr(MIN(table_name), 13)
        INTO lv_min_year
        FROM user_tables
       WHERE table_name LIKE upper('tr_serv_rec%');
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    lv_tablename := upper('tr_serv_rec_' || (to_char(SYSDATE, 'yyyy') + 1));
    EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                      lv_tablename || ''''
      INTO lv_count;
    IF lv_count = 0 THEN
      EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                        ' as select * from tr_serv_rec_' || lv_min_year ||
                        ' where rownum < 1';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_bt on ' ||
                        lv_tablename || '(biz_time)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_cd on ' ||
                        lv_tablename || '(clr_date)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_cln on ' ||
                        lv_tablename || '(client_name)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_cn on ' ||
                        lv_tablename || '(card_no)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_oi on ' ||
                        lv_tablename || '(oper_id)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_tn on ' ||
                        lv_tablename || '(cert_no)';
      EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_tr on ' ||
                        lv_tablename || '(tr_code)';
      EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                        ' add constraint pk_' || lv_tablename ||
                        ' primary key (action_no) using index';
      FOR lv_comment IN (SELECT *
                           FROM user_col_comments
                          WHERE table_name =
                                upper('tr_serv_rec_' || lv_min_year))
      LOOP
        EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                          lv_comment.column_name || ' is ''' ||
                          lv_comment.comments || '''';
      END LOOP;
    END IF;
  END p_tr_serv_rec;
  /*=======================================================================================*/
  --生成表tr_offline,预生成cs_days天的表
  /*=======================================================================================*/
 /* PROCEDURE p_tr_offline IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
    lv_sysdate   DATE;
  BEGIN
    lv_sysdate := SYSDATE;
    FOR i IN 0 .. cs_days
    LOOP
      lv_tablename := upper('tr_offline_' ||
                            to_char(lv_sysdate + i, 'yyyymmdd'));
      EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                        lv_tablename || ''''
        INTO lv_count;
      IF lv_count = 0 THEN
        EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                          ' as select * from tr_offline where rownum < 1';
        EXECUTE IMMEDIATE 'alter table ' || lv_tablename || ' add constraint pk_' || lv_tablename || ' primary key (ACTION_NO) using INDEX';
        EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_cn on ' ||
                          lv_tablename || '(card_no)';
        EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_fn on ' ||
                          lv_tablename || '(send_file_name)';
        EXECUTE IMMEDIATE 'create index ik_' || lv_tablename || '_zh on ' ||
                          lv_tablename ||
                          '(acpt_id, term_id, tr_batch_no, tr_ser_no, card_no, tr_amt)';
        FOR lv_comment IN (SELECT *
                             FROM user_col_comments
                            WHERE table_name = upper('tr_offline'))
        LOOP
          EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                            lv_comment.column_name || ' is ''' ||
                            lv_comment.comments || '''';
        END LOOP;
      END IF;
    END LOOP;
  END p_tr_offline;
  /*=======================================================================================*/
  --生成表tr_card,预生成下个月的表
  /*=======================================================================================*/
  PROCEDURE p_tr_card(av_sysdate DATE) IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
    lv_sysdate   DATE;
    lv_table_comments varchar2(500);
  BEGIN
    lv_sysdate := nvl(av_sysdate, SYSDATE);
    lv_sysdate := nvl(av_sysdate, SYSDATE);
    lv_sysdate := to_date('2016-06-01','yyyy-MM-dd');
    FOR i IN 1 .. 20
    --FOR i IN 1 .. pk_public.cs_cm_card_nums
    LOOP
      lv_tablename := upper('pay_card_deal_rec_' ||to_char(add_months(trunc(lv_sysdate, 'mm'),i),
                                    'yyyymm'));
      EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                        lv_tablename || ''''
        INTO lv_count;
      IF lv_count = 0 THEN
        EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                          ' as select * from pay_card_deal_rec where rownum < 1';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'cardno on ' || lv_tablename ||
                          '(card_no, card_counter)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'trdate on ' || lv_tablename || '(deal_date)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'cardno1 on ' || lv_tablename || '(card_no)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'cardty on ' || lv_tablename || '(card_type)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'acptid on ' || lv_tablename || '(acpt_id)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'ACCKID on ' || lv_tablename || '(ACC_KIND)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'batno on ' || lv_tablename || '(DEAL_BATCH_NO)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'userid on ' || lv_tablename || '(USER_ID)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'endno on ' || lv_tablename || '(END_DEAL_NO)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'act on ' || lv_tablename || '(ACPT_TYPE)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'acn on ' || lv_tablename || '(ACC_NO)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'cld on ' || lv_tablename || '(CLR_DATE)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'ain on ' || lv_tablename || '(ACC_INOUT_NO)';
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
                          'dco on ' || lv_tablename || '(DEAL_CODE)';                                   
        EXECUTE IMMEDIATE 'create index ik_' || replace(lv_tablename,'_','') ||
        'cusid on ' || lv_tablename || '(CUSTOMER_ID)';
        EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                          ' add constraint pk_' || lv_tablename ||
                          ' primary key (id) using index';
        begin
         select t.comments into lv_table_comments from user_tab_comments t where t.table_name = 'PAY_CARD_DEAL_REC';
         lv_table_comments := substr(lv_table_comments,1,instr(lv_table_comments,'，',1,1) - 1);
         EXECUTE IMMEDIATE 'comment on table ' || lv_tablename || ' is ''' || lv_table_comments || to_char(add_months(trunc(lv_sysdate,'mm'),i),'yyyymm') || '''';
        exception
          when others then
            null;
        end;
        FOR lv_comment IN (SELECT *
                             FROM user_col_comments
                            WHERE table_name = upper('pay_card_deal_rec'))
        LOOP
          EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                            lv_comment.column_name || ' is ''' ||
                            lv_comment.comments || '''';
        END LOOP;
      END IF;
    END LOOP;
  END p_tr_card;
  /*=======================================================================================*/
  --生成表cm_card各分表
  /*=======================================================================================*/
 /* PROCEDURE p_cm_card IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
  BEGIN
    FOR i IN 2 .. pk_public.cs_cm_card_nums
    LOOP
      lv_tablename := upper('cm_card_' || TRIM(to_char(i - 1, '00')));
      EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                        lv_tablename || ''''
        INTO lv_count;
      IF lv_count = 0 THEN
        EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                          ' as select * from cm_card_00 where rownum < 1';
        EXECUTE IMMEDIATE 'create index ik_' || lv_tablename ||
                          '_clientid on ' || lv_tablename || '(client_id)';
        EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                          ' add constraint pk_' || lv_tablename ||
                          ' primary key (card_no) using index';
        FOR lv_comment IN (SELECT *
                             FROM user_col_comments
                            WHERE table_name = upper('cm_card_00'))
        LOOP
          EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                            lv_comment.column_name || ' is ''' ||
                            lv_comment.comments || '''';
        END LOOP;
      END IF;
    END LOOP;
  END p_cm_card;
  /*=======================================================================================*/
  --生成acc_points_period各分表
  /*=======================================================================================*/
/*  PROCEDURE p_acc_sub_ledger IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
  BEGIN
    FOR i IN 1 .. pk_public.cs_cm_card_nums
    LOOP
      lv_tablename := upper('acc_sub_ledger_' || TRIM(to_char(i - 1, '00')));
      EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                        lv_tablename || ''''
        INTO lv_count;
      IF lv_count = 0 THEN
        EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                          ' as select * from acc_sub_ledger where rownum < 1';
        EXECUTE IMMEDIATE 'create index ik_' || lv_tablename ||
                          '_cardno on ' || lv_tablename || '(card_no)';
        EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                          ' add constraint pk_' || lv_tablename ||
                          ' primary key (acc_no) using index';
        FOR lv_comment IN (SELECT *
                             FROM user_col_comments
                            WHERE table_name = upper('acc_sub_ledger'))
        LOOP
          EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                            lv_comment.column_name || ' is ''' ||
                            lv_comment.comments || '''';
        END LOOP;
      END IF;
    END LOOP;
  END p_acc_sub_ledger;
  /*=======================================================================================*/
  --生成acc_points_period各分表
  /*=======================================================================================*/
/*  PROCEDURE p_acc_points_period IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
  BEGIN
    FOR i IN 1 .. pk_public.cs_cm_card_nums
    LOOP
      lv_tablename := upper('acc_points_period_' ||
                            TRIM(to_char(i - 1, '00')));
      EXECUTE IMMEDIATE 'select count(*) from user_tables where table_name = ''' ||
                        lv_tablename || ''''
        INTO lv_count;
      IF lv_count = 0 THEN
        EXECUTE IMMEDIATE 'create table ' || lv_tablename ||
                          ' as select * from acc_points_period where rownum < 1';
        EXECUTE IMMEDIATE 'create index ik_' || lv_tablename ||
                          '_accno on ' || lv_tablename || '(acc_no)';
        EXECUTE IMMEDIATE 'alter table ' || lv_tablename ||
                          ' add constraint pk_' || lv_tablename ||
                          ' primary key (period_id) using index';
        FOR lv_comment IN (SELECT *
                             FROM user_col_comments
                            WHERE table_name = upper('acc_points_period'))
        LOOP
          EXECUTE IMMEDIATE 'comment on column ' || lv_tablename || '.' ||
                            lv_comment.column_name || ' is ''' ||
                            lv_comment.comments || '''';
        END LOOP;
      END IF;
    END LOOP;
  END p_acc_points_period;
  /*=======================================================================================*/
  --生成表
  /*=======================================================================================*/
  PROCEDURE p_create IS
  BEGIN
  --  p_cm_card;
  --  p_acc_sub_ledger;
   -- p_acc_points_period;
    p_acc_day_book;
  --  p_stk_stock_book;
  --  p_tr_serv_rec;
  --  p_tr_offline;
  -- p_tr_offline;
    p_tr_card(SYSDATE);
  END p_create;
BEGIN
  -- initialization
  NULL;
END pk_createobject;
/

