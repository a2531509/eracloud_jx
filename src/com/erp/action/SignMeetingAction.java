package com.erp.action;

import com.erp.exception.CommonException;
import com.erp.model.SignMeeting;
import com.erp.service.SignMeetingService;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.*;

import javax.annotation.Resource;

/**
 * Created by yn on 2017/2/22.
 */
@SuppressWarnings("serial")
@Namespace("/meeting")
@Action(value="signMeetingAction")
@Results({
    @Result(name="signMeetingMain",location="/jsp/meeting/signMeetingMain.jsp"),
    @Result(name="toSaveOrUpdateSignMeetingIndex",location="/jsp/meeting/signMeetingAdd.jsp"),
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class SignMeetingAction extends BaseAction{
    private Logger logger = Logger.getLogger(TaskManagementAction.class);
    @Resource(name = "signMeetingService")
    private SignMeetingService signMeetingService;
    private String sort = "";
    private String order = "";
    private String queryType = "1";
    private String beginDate;
    private String endDate;
    private SignMeeting meeting;

    /**
     * find all sign meeting msg
     * @return
     */
    public String findAllSignMeetings(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.meeting_id selectid,t.meeting_id,t.meeting_subject,t.meeting_address,");
            sb.append("to_char(t.meeting_start_time,'yyyy-mm-dd hh24:mi:ss') meeting_start_time,decode(t.meeting_state,'0','初始新建','1','客户端已下载','2','会议进行中','3','会议已结束','9','已作废','其他') meetingstate,");
            sb.append("to_char(t.meeting_end_time,'yyyy-mm-dd hh24:mi:ss') meeting_end_time,t.meeting_state,");
            sb.append("nvl(t.meeting_init_sum,0) meeting_init_sum,nvl(t.meeting_actu_sum,0) meeting_actu_sum,nvl(t.meeting_temp_sum,0) meeting_temp_sum,nvl(t.meeting_final_sum,0) meeting_final_sum,");
            sb.append("t.meeting_creator_user_id,to_char(t.meeting_creator_date,'yyyy-mm-dd hh24:mi:ss') meeting_creator_date,t.meeting_cls_user_id,t.meeting_cls_date,t.note ");
            sb.append("from sign_meeting t ");
            if(!Tools.processNull(sort).equals("")){
                String[]tempSorts = sort.split(",");
                String[] tempOrders = order.split(",");
                sb.append("order by ");
                for(int i = 0;i < tempSorts.length;i++){
                    sb.append(tempSorts[i] + " " + tempOrders[i]);
                    if(i != (tempSorts.length - 1)){
                        sb.append(",");
                    }
                    sb.append(" ");
                }
            }else{
                sb.append("order by t.meeting_id desc");
            }
            Page pages = baseService.pagingQuery(sb.toString(),page,rows);
            if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
                throw new CommonException("根据指定信息未查询到对应的会议信息！");
            }else{
                jsonObject.put("rows",pages.getAllRs());
                jsonObject.put("total",pages.getTotalCount());
                jsonObject.put("totPages_01",pages.getTotalPages());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * reach add or update sign meeting index page.
     * @return
     */
    public String toSaveAddOrUpdateSignMeetingIndex(){
        try{
            if(Tools.processNull(this.queryType).equals("1") || Tools.processNull(this.queryType).equals("2")){
                meeting = (SignMeeting) baseService.findOnlyRowByHql("from SignMeeting where meetingId = '" + meeting.getMeetingId() + "'");
                if(meeting != null){
                    if(!Tools.processNull(meeting.getMeetingStartTime()).equals("")){
                        this.beginDate = DateUtil.formatDate(meeting.getMeetingStartTime(),"yyyy-MM-dd HH:mm:ss");
                    }
                    if(!Tools.processNull(meeting.getMeetingEndTime()).equals("")){
                       this.endDate = DateUtil.formatDate(meeting.getMeetingEndTime(),"yyyy-MM-dd HH:mm:ss");
                    }
                }
            }
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            return "signMeetingMain";
        }
        return "toSaveOrUpdateSignMeetingIndex";
    }
    /**
     * to save or update a sign meeting msg.
     * @return
     */
    public String saveAddOrUpdateSignMeeting(){
        try{
            if(!Tools.processNull(this.beginDate).equals("")){
                meeting.setMeetingStartTime(DateUtil.parse("yyyy-MM-dd HH:mm:dd",this.beginDate));
            }
            if(!Tools.processNull(this.endDate).equals("")){
                meeting.setMeetingEndTime(DateUtil.parse("yyyy-MM-dd HH:mm:dd",this.endDate));
            }
            signMeetingService.saveAddOrUpdateSignMeeting(meeting,this.queryType,baseService.getUser(),null,null);
            jsonObject.put("status","0");
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    /**
     *  save sign meeting state changed
     * @return
     */
    public String saveSignMeetingStateChanged(){
        try{
            signMeetingService.saveSignMeetingStateChanged(meeting.getMeetingId(),this.queryType,null,null,null);
            jsonObject.put("status","0");
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    @Override
    public String getSort(){
        return sort;
    }
    @Override
    public void setSort(String sort){
        this.sort = sort;
    }
    @Override
    public String getOrder(){
        return order;
    }
    @Override
    public void setOrder(String order){
        this.order = order;
    }
    public String getQueryType(){
        return queryType;
    }
    public void setQueryType(String queryType){
        this.queryType = queryType;
    }
    public String getBeginDate(){
        return beginDate;
    }
    public void setBeginDate(String beginDate){
        this.beginDate = beginDate;
    }
    public String getEndDate(){
        return endDate;
    }
    public void setEndDate(String endDate){
        this.endDate = endDate;
    }
    public SignMeeting getMeeting(){
        return meeting;
    }
    public void setMeeting(SignMeeting meeting){
        this.meeting = meeting;
    }
    public SignMeetingService getSignMeetingService(){
        return signMeetingService;
    }
    public void setSignMeetingService(SignMeetingService signMeetingService){
        this.signMeetingService = signMeetingService;
    }
}
