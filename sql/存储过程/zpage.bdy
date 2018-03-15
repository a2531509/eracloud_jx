create or replace package body zpage as
/* oracle 分页查询
 *@author yangn
 *@param psql     查询语句
 *@param pnum     第几页
 *@param psize    每页多少条
 *@param pcount   总共多少条
 *@param precord  总共多少页
 *@param res      结果集
 *@param issuc    分页查询是否成功 0 成功  -1 分页查询失败
 *@param outmasg  分页查询消息,查询失败时的描述信息
*/
procedure page(psql in varchar2,pnum in number,psize in number,pcount out number,precords out number,res out default_cursor,issuc out varchar2,outmasg out varchar2)
as
    v_sql varchar2(8000);
    v_string varchar2(8000);
    v_max number;
    v_min number;
    v_pnum number;
    v_psize number;
 begin
    if pnum is null or pnum <= 0 then
        v_pnum := 1;
    else
        v_pnum := pnum;
    end if;
    if psize is null or  psize <= 0 then
        v_psize := 10;
    else
        v_psize := psize;
    end if;
    v_sql := 'select count(*) from (' || psql || ')';
    execute immediate v_sql into pcount;
    if pcount = 0 then
        pcount := 0;
        precords := 0;
        issuc := '2';
        outmasg := '未查询到记录';
        return;
    end if;
    precords := ceil(pcount / v_psize);
    if v_pnum > precords then
        v_pnum := precords;
    end if;
    v_max := v_psize * v_pnum;
    v_min := v_max - v_psize + 1;
    --v_string := 'select * from (' || 'select rownum as v_v,t.* from (' || psql || ' rownum >=' || v_min || ' and rownum <=' || v_max  ||') t )' || ' where v_v between ' || v_min || ' and ' || v_max;
    v_string := 'select * from (' || 'select rownum as v_v,t_N.* from (' || psql || ') t_N )' || ' where v_v >= ' || v_min || ' and  v_v <= ' || v_max;
    --dbms_output.put_line(v_string);
  open res for v_string;
    issuc := '0';
    outmasg := '';
exception when others then
    issuc := '-1';
    outmasg := '分页查询出现错误:' || sqlerrm;
end page;


procedure pagetest(psql in varchar2,orderby varchar2,pnum in number,psize in number,pcount out number,precords out number,res out default_cursor,issuc out varchar2,outmasg out varchar2)
as
    v_sql varchar2(2000);
    v_string varchar2(2000);
    v_max number;
    v_min number;
    v_pnum number;
    v_psize number;
    select_index number;
    from_index number;--must
    finalsql varchar2(2000);
    selectsql varchar2(2000);
    fromsql varchar2(2000);
 begin
    if pnum is null or pnum <= 0 then
        v_pnum := 1;
    else
        v_pnum := pnum;
    end if;
    if psize is null or  psize <= 0 then
        v_psize := 10;
    else
        v_psize := psize;
    end if;
    v_sql := 'select count(*) from (' || psql || ')';
    execute immediate v_sql into pcount;
    if pcount = 0 then
       pcount := 0;
       precords := 0;
       issuc := '2';
       outmasg := '未查询到记录';
       return;
    end if;
    precords := ceil(pcount / v_psize);
    if v_pnum > precords then
       v_pnum := precords;
    end if;
    v_max := v_psize * v_pnum;
    v_min := v_max - v_psize + 1;
    if orderby is not null then
       from_index := instr(psql,'from',1,1);
       select_index := instr(psql,'select',1,1);
       selectsql := substr(psql,1,(select_index + 6)) || ' row_number() over(order by ' || orderby || ') v_v, ';
       fromsql := substr(psql,select_index + 6,from_index - select_index -6);
       finalsql := selectsql || fromsql || substr(psql,from_index,(length(psql) - from_index) - 1);
       v_string := 'select * from (' || finalsql || ') where  v_v between ' || v_min || ' and ' || v_max;
    else
       v_string := 'select * from (' || 'select rownum as v_v,t_N.* from (' || psql || ') t_N )' || ' where v_v >= ' || v_min || ' and  v_v <= ' || v_max;
    end if;
    dbms_output.put_line(v_string);
  open res for v_string;
    issuc := '0';
    outmasg := '';
exception when others then
    issuc := '-1';
    outmasg := '分页查询出现错误:' || sqlerrm;
end pagetest;

procedure p_lock(lockid varchar2,deal_code varchar2,org_id varchar2,brch_id varchar2,user_id varchar2,deal_time varchar2)
    is pragma autonomous_transaction;
    pcount number := 0;
begin
    select count(1) into pcount from sys_busi_lock where busi_key = lockid;
    IF pcount > 0 THEN
        NULL;
    END IF;
end p_lock;

 FUNCTION GETACTIVE RETURN NUMBER IS
  BEGIN
    RETURN ACTIVE_N;
  END GETACTIVE;
  PROCEDURE SETACTIVE(N1 IN NUMBER) IS
  BEGIN
    ACTIVE_N := N1;
  END SETACTIVE;

end zpage;
/

