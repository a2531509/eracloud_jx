alter table base_tag_end add psam_no2 varchar2(20);
alter table base_tag_end add mng_usr_phone varchar2(20);
alter table base_tag_end add ins_location varchar2(200);
alter table base_tag_end add ins_date date;

comment on column BASE_TAG_END.psam_no2 is 'ס�� PSAM ������';
comment on column BASE_TAG_END.mng_usr_phone is '(������) ��ϵ�绰';
comment on column BASE_TAG_END.ins_location is '��װλ��';
comment on column BASE_TAG_END.ins_date is '��װ����';
