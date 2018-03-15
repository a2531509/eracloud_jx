-- Add/modify columns 
alter table SYS_BRANCH add IS_LK_BRCH2 VARCHAR2(1) default 1;
-- Add comments to the columns 
comment on column SYS_BRANCH.IS_LK_BRCH
  is '是否可设置成金融社保卡领卡网点，0是1否';
comment on column SYS_BRANCH.IS_LK_BRCH2
  is '是否可设置成全功能卡卡领卡网点，0是1否';
