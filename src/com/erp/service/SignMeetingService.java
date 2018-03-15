package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.SignMeeting;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

/**
 * Created by yn on 2017/2/23.
 */
public interface SignMeetingService extends BaseService{

    /**
     * 新增或编辑会议信息
     * @param meeting 会议信息
     * @param operType 操作类型
     * @param oper 操作员
     * @param rec 业务日志
     * @param log 操作日志
     * @return 业务日志
     */
    public TrServRec saveAddOrUpdateSignMeeting(SignMeeting meeting, String operType, Users oper, TrServRec rec, SysActionLog log) throws CommonException;

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
    public TrServRec saveSignMeetingStateChanged(Long meetingId,String operType,Users oper,TrServRec rec,SysActionLog log)throws CommonException;

}
