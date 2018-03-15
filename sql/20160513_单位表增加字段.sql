-- Add/modify columns 
alter table BASE_CORP add LK_BRCH_ID2 VARCHAR2(20);
-- Add comments to the columns 
comment on column BASE_CORP.LK_BRCH_ID2
  is '全功能卡领卡网点';
