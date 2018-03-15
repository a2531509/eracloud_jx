-- Add/modify columns 
alter table SYS_BRANCH add IS_LK_BRCH VARCHAR2(1) default 1;
-- Add comments to the columns 
comment on column SYS_BRANCH.IS_LK_BRCH
  is '是否可设置成领卡网点，0是1否';
