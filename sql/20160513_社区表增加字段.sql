-- Add/modify columns 
alter table BASE_COMM add LK_BRCH_ID2 VARCHAR2(20);
-- Add comments to the columns 
comment on column BASE_COMM.LK_BRCH_ID2
  is 'ȫ���ܿ��쿨����';
