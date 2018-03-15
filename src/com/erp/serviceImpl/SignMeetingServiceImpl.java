package com.erp.serviceImpl;

import com.erp.exception.CommonException;
import com.erp.model.SignMeeting;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.SignMeetingService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import org.springframework.stereotype.Service;

/**
 * Created by yn on 2017/2/23.
 */
@Service(value="signMeetingService")
public class SignMeetingServiceImpl extends BaseServiceImpl implements SignMeetingService{

    /**
     * 新增或编辑会议信息
     * @param meeting 会议信息
     * @param operType 操作类型
     * @param oper 操作员
     * @param rec 业务日志
     * @param log 操作日志
     * @return 业务日志
     */
    @Override
    public TrServRec saveAddOrUpdateSignMeeting(SignMeeting meeting,String operType,Users oper, TrServRec rec, SysActionLog log) throws CommonException{
        try{
            if(!Tools.processNull(operType).equals("0") && !Tools.processNull(operType).equals("1")){
                throw new CommonException("操作类型不正确！");
            }
            if(oper == null){
                oper =this.getUser();
            }
            if(rec == null){
                rec = new TrServRec();
            }
            if(log == null){
                log = this.getCurrentActionLog();
            }
            if(meeting == null){
                throw new CommonException("会议信息不正确！");
            }
            if(Tools.processNull(meeting.getMeetingSubject()).equals("")){
                throw new CommonException("会议主题不正确！");
            }
            if(Tools.processNull(meeting.getMeetingStartTime()).equals("")){
                throw new CommonException("会议开始时间不正确！");
            }
            if(Tools.processNull(meeting.getMeetingEndTime()).equals("")){
                throw new CommonException("会议结束时间不正确！");
            }
            log.setDealCode(0);
            log.setMessage("11111");
            this.publicDao.save(log);
            if(Tools.processNull(operType).equals("0")){
                meeting.setMeetingState("0");
                meeting.setMeetingCreatorUserId(oper.getUserId());
                meeting.setMeetingCreatorDate(log.getDealTime());
                this.publicDao.save(meeting);
            }else{
                if(Tools.processNull(meeting.getMeetingId()).equals("")){
                    throw new CommonException("会议编号不正确，不能进行编辑！");
                }
                SignMeeting oldSignMeeting = (SignMeeting) this.findOnlyRowByHql("from SignMeeting where meetingId = '" + meeting.getMeetingId() + "'");
                if(oldSignMeeting ==null){
                    throw new CommonException("根据会议编号" + meeting.getMeetingId() + "找不到会议信息！");
                }
                if(!Tools.processNull(meeting.getMeetingSubject()).equals("")){
                    oldSignMeeting.setMeetingSubject(meeting.getMeetingSubject());//会议主题
                }
                if(!Tools.processNull(meeting.getMeetingAddress()).equals("")){
                    oldSignMeeting.setMeetingAddress(meeting.getMeetingAddress());//会议地点
                }
                if(!Tools.processNull(meeting.getMeetingStartTime()).equals("")){
                    oldSignMeeting.setMeetingStartTime(meeting.getMeetingStartTime());//会议开始时间
                }
                if(!Tools.processNull(meeting.getMeetingEndTime()).equals("")){
                    oldSignMeeting.setMeetingEndTime(meeting.getMeetingEndTime());//会议结束时间
                }
                if(!Tools.processNull(meeting.getNote()).equals("")){
                    oldSignMeeting.setNote(meeting.getNote());//备注
                }
                if(!Tools.processNull(meeting.getMeetingOrganizer()).equals("")){
                    oldSignMeeting.setMeetingOrganizer(meeting.getMeetingOrganizer());//主办单位
                }
                if(!Tools.processNull(meeting.getMeetingCoOrganizer()).equals("")){
                    oldSignMeeting.setMeetingCoOrganizer(meeting.getMeetingCoOrganizer());//协办单位
                }
                if(!Tools.processNull(meeting.getMeetingUnOrganizer()).equals("")){
                    oldSignMeeting.setMeetingUnOrganizer(meeting.getMeetingUnOrganizer());//承办单位
                }
                this.publicDao.save(oldSignMeeting);
            }
            rec.setDealNo(log.getDealNo());
            rec.setDealCode(log.getDealCode());
            rec.setClrDate(this.getClrDate());
            rec.setBizTime(log.getDealTime());
            rec.setDealState(Constants.TR_STATE_ZC);
            rec.setBrchId(log.getBrchId());
            rec.setUserId(log.getUserId());
            rec.setNote(log.getMessage()+ "," + meeting.getNote());
            return rec;
        }catch(Exception e){
            throw new CommonException(e.getMessage());
        }
    }

    /**
     * save sign meeting state changed
     * @param meetingId
     * @param operType
     * @param oper
     * @param rec
     * @param log
     * @return
     * @throws CommonException
     */
    @Override
    public TrServRec saveSignMeetingStateChanged(Long meetingId,String operType,Users oper,TrServRec rec,SysActionLog log)throws CommonException{
        try{
            String operString = "";
            String targetState = "";
            if(Tools.processLong(meetingId).equals("")){
                throw new CommonException("会议编号不正确！");
            }
            if(oper == null){
                oper =this.getUser();
            }
            if(rec == null){
                rec = new TrServRec();
            }
            if(log == null){
                log = this.getCurrentActionLog();
            }
            if(Tools.processNull(operType).equals("0")){
                operString = "激活";
                targetState = "0";
            }else if(Tools.processNull(operType).equals("1")){
                operString = "禁用";
                targetState = "9";
            }else if(Tools.processNull(operType).equals("2")){
                operString = "删除";
            }else{
                throw new CommonException("操作类型不正确！");
            }
            log.setDealCode(0);
            log.setMessage(operString + "会议信息，会议编号meetingId=" + meetingId);
            this.publicDao.save(log);
            SignMeeting signMeeting = (SignMeeting) this.findOnlyRowByHql("from SignMeeting where meetingId = " + meetingId);
            if(signMeeting == null){
                throw new CommonException("根据会议编号" + meetingId + "找不到会议信息！");
            }
            //会议状态<0 初始新建;1,客户端已下载;2 会议进行中;3 会议已结束;9 已作废>
            if(Tools.processNull(operType).equals("0")){
                if(!Tools.processNull(signMeeting.getMeetingState()).equals("9")){
                    throw new CommonException("当前会议不是已作废状态,不能进行激活操作！");
                }
            }else if(Tools.processNull(operType).equals("1")){
                if(!Tools.processNull(signMeeting.getMeetingState()).equals("0")){
                    throw new CommonException("当前会议不是初始新建状态,不能进行作废操作！");
                }
            }else if(Tools.processNull(operType).equals("2")){
                if(!Tools.processNull(signMeeting.getMeetingState()).equals("9")){
                    throw new CommonException("当前会议不是已作废状态,不能进行删除操作！");
                }
            }else{
                throw new CommonException("操作类型不正确！");
            }
            String doSql = "";
            if(Tools.processNull(operType).equals("2")){
                doSql = "delete from sign_meeting where meeting_id = '" + meetingId + "'";
            }else{
                doSql = "update sign_meeting set meeting_state = '" + targetState + "' ";
                if(Tools.processNull(operType).equals("1")){
                    doSql += ",meeting_cls_user_id = '" + oper.getUserId() +
                    "',meeting_cls_date = to_date('" + DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss') ";
                }
                doSql += "where meeting_id = '" + meetingId + "'";
            }
            int upcount = this.publicDao.doSql(doSql);
            if(upcount != 1){
                throw new CommonException("更新条数不正确");
            }
            rec.setDealNo(log.getDealNo());
            rec.setDealCode(log.getDealCode());
            rec.setClrDate(this.getClrDate());
            rec.setBizTime(log.getDealTime());
            rec.setDealState(Constants.TR_STATE_ZC);
            rec.setBrchId(log.getBrchId());
            rec.setUserId(log.getUserId());
            rec.setNote(log.getMessage());
            return rec;
        }catch(Exception e){
            throw new CommonException(e.getMessage());
        }
    }
}
