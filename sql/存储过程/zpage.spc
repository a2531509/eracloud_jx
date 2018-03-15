create or replace package zpage as
ACTIVE_N NUMBER := 0;
    type default_cursor is ref cursor;
    procedure page(psql in varchar2,pnum in number,psize in number,pcount out number,precords out number,res out default_cursor,issuc out varchar2,outmasg out varchar2);
    procedure pagetest(psql in varchar2,orderby varchar2,pnum in number,psize in number,pcount out number,precords out number,res out default_cursor,issuc out varchar2,outmasg out varchar2);
    procedure p_lock(lockid varchar2,deal_code varchar2,org_id varchar2,brch_id varchar2,user_id varchar2,deal_time varchar2);

     FUNCTION GETACTIVE RETURN NUMBER;
  PROCEDURE SETACTIVE(N1 IN NUMBER);
end zpage;
/

