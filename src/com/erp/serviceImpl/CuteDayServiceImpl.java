package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.Users;
import com.erp.service.CuteDayService;
import com.erp.service.OfflineDataProcessService;
import com.erp.service.OfflineDataService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReportUtil;
import com.erp.util.Tools;
@SuppressWarnings("unchecked")
@Service("cuteDayService")
public class CuteDayServiceImpl extends BaseServiceImpl implements CuteDayService {
	public static Logger logger = Logger.getLogger(CuteDayServiceImpl.class);
	public static Log log = LogFactory.getLog(CuteDayServiceImpl.class);
	public OfflineDataService offlineDataService;
	public OfflineDataProcessService offlineDataProcessService;
	
	@SuppressWarnings("rawtypes")
	@Override
	public void persistenceCuteDay() throws CommonException {

		//1、公交和海宁城管脱机文件返回处理
		try {
			offlineDataService.saveOfflineData_Gj_Hncg();
		} catch (Exception e) {
			log.error("公交脱机文件返回处理有误:"+e.getMessage());
		}

		//2、自行车脱机文件返回处理
		try {
			offlineDataService.saveOfflineData_Zxc();
		} catch (Exception e) {
			log.error("自行车脱机文件返回处理有误:"+e.getMessage());
		}
		
	}

	@Override
	public String saveUserDayBal(SysActionLog actionLog, Users user, String dealType)
			throws CommonException {
		String returnFlag = "1";
		try {
			actionLog.setDealCode(DealCode.CUTE_USER_DAY_BAL);
			this.publicDao.save(actionLog);
			// 检查有无灰记录
			
		      List in = new ArrayList();
		      StringBuffer inpara = new StringBuffer();
		      inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
		      inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
		      inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
		      inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"))).append("|");
		      inpara.append(Tools.processNull(getClrDate())).append("|");
		      inpara.append(Tools.processNull(dealType)).append("|");
		      inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
		      in.add(inpara.toString());
		      in.add("1");
		      List out = new ArrayList();
		      out.add(Integer.valueOf(12));
		      out.add(Integer.valueOf(12));
		      try {
		        List ret = this.publicDao.callProc("PK_STATISTIC.P_DAYBAL", in, out);
		        if ((ret != null) && (ret.size() != 0)) {
		          int res = Integer.parseInt(ret.get(0).toString());
		          if (res != 0) {
		            String outMsg = ret.get(1).toString();
		            throw new CommonException(outMsg);
		          }
		          returnFlag = "2";
		        }
		        else {
		          returnFlag = "2";
		          throw new CommonException("扎帐发生错误！");
		        }
		      } catch (Exception ex) {
		        returnFlag = "2";
		        ex.printStackTrace();
		        throw new CommonException(ex.getMessage());
		      }

		      this.publicDao.doSql("update sys_users t set t.isemployee = '0' where t.user_id= '" + user.getUserId() + "'");

		      Map reportPara = new HashMap();
		      reportPara.put("p_Title", Constants.APP_REPORT_TITLE + user.getName() + findTrCodeNameByCodeType(DealCode.CUTE_USER_DAY_BAL) + "凭证");
		      reportPara.put("p_Yrbzw", "日");
		      reportPara.put("p_Oper_Name", user.getName());
		      reportPara.put("p_Date", DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
		      reportPara.put("p_ClrDate", getClrDate());
		      SysBranch brch = new SysBranch();
		      setReportPara(reportPara, "1", user, brch,getClrDate());
		      ReportUtil rputil = new ReportUtil(ServletActionContext.getRequest(), ServletActionContext.getResponse());
		      byte[] pdfContent = rputil.exportPDFBYJRResset("", "/reportfiles/YCYingYeBaoBiao.jasper", reportPara, null);
			  this.saveSysReport(actionLog, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1L, "", pdfContent);
		} catch (Exception e) {
			returnFlag = "2" ;
			throw new CommonException(e.getMessage());
		}
		return returnFlag;
	}

	@Override
	public String saveBrchDayBal(SysActionLog actionLog, Users user, String dealType)
			throws CommonException {
		String returnFlag = "1";
		try {
			actionLog.setDealCode(DealCode.CUTE_BRCH_DAY_BAL);
			publicDao.save(actionLog);
			//1，调用存储过程汇总扎帐明细表 按照业务数据自己组合形成报表
			//1action_no|2tr_code|3oper_id|4oper_time|5clr_date|6daybal_type|7daybal_owner_id
			List<Object> in = new java.util.ArrayList<Object>();
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
			inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
			inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss"))).append("|");
			inpara.append(Tools.processNull(this.getClrDate())).append("|");
			inpara.append(Tools.processNull(dealType)).append("|");
			inpara.append(Tools.processNull(actionLog.getBrchId())).append("|");
			in.add(inpara.toString());
			in.add("1");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("PK_STATISTIC.P_DAYBAL", in,out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} else {
						returnFlag = "2" ;
					}
				} else {
					returnFlag = "2" ;
					throw new CommonException("扎帐发生错误！");
				}
			} catch (Exception ex) {
				returnFlag = "2" ;
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
			//2.银行补换卡业务数据统计
			try {
				in.clear();
				in.add(getClrDate());
				in.add(Tools.processNull(actionLog.getBrchId()));
				in.add(actionLog.getDealNo());
				in.add(1);
				List ret = publicDao.callProc("pk_statistic.p_stat_bank_bhkyw", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} else {
						returnFlag = "2";
					}
				} else {
					returnFlag = "2";
					throw new CommonException("扎帐发生错误！");
				}
			} catch (Exception ex) {
				returnFlag = "2";
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
			//2，修改网点扎帐标志
			publicDao.doSql("update Sys_Branch set IS_DAY_FLAG = '0'  where BRCH_ID ='"+user.getBrchId()+"'");
			//3,构造业务日志报表
			//查询扎帐报表
			Map reportPara = new HashMap();
			reportPara.put("p_Title", Constants.APP_REPORT_TITLE+this.getSysBranchByUserId().getFullName()+this.findTrCodeNameByCodeType(DealCode.CUTE_BRCH_DAY_BAL)+"凭证");//全功能卡电子钱包充值笔数
			reportPara.put("p_Yrbzw", "日");//全功能卡电子钱包充值笔数
			reportPara.put("p_Oper_Name", user.getName());//操作员
			reportPara.put("p_Date", DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
			reportPara.put("p_ClrDate", getClrDate());
			Users user1 = new Users();
			setReportPara(reportPara, "2", user1, this.getSysBranchByUserId(), getClrDate());
			ReportUtil rputil = new ReportUtil( ServletActionContext.getRequest(),ServletActionContext.getResponse());
			byte[] pdfContent = rputil.exportPDFBYJRResset("", "/reportfiles/YCYingYeBaoBiao2.jasper", reportPara, null);
			this.saveSysReport(actionLog, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1L, "", pdfContent);
		} catch (Exception e) {
			returnFlag = "2" ;
			throw new CommonException(e.getMessage());
		}
		return returnFlag;
	}

	@Override
	public String saveReforceUserDayBal(SysActionLog actionLog, Users user,
			String[] ids) throws CommonException {
		//ids 用户编号 CUTE_REFORCE_USER_DAY_BAL
		String returnFlag = "1";
		String dealType   = "1";
		try {
			for (int i = 0; i < ids.length; i++) {
				actionLog.setDealCode(DealCode.CUTE_USER_DAY_BAL);
				publicDao.save(actionLog);
				//调用存储过程汇总扎帐明细表 按照业务数据自己组合形成报表
				//1action_no|2tr_code|3oper_id|4oper_time|5clr_date|6daybal_type|7daybal_owner_id
				List<Object> in = new java.util.ArrayList<Object>();
				StringBuffer inpara = new StringBuffer();
				inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
				inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
				inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
				inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:MM:ss"))).append("|");
				inpara.append(Tools.processNull(this.getClrDate())).append("|");
				inpara.append(Tools.processNull(dealType)).append("|");
				inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
				in.add(inpara.toString());
				in.add("1");
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("PK_STATISTIC.P_DAYBAL", in,out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						} else {
							returnFlag = "2" ;
						}
					} else {
						returnFlag = "2" ;
						throw new CommonException("扎帐发生错误！");
					}
				} catch (Exception ex) {
					returnFlag = "2" ;
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
				//2,修改柜员扎帐状态为已挂失状态
				publicDao.doSql("update sys_users t set t.isemployee = '0' where t.user_id= '"+ids[i]+"'");
			}
		} catch (Exception e) {
			returnFlag = "2" ;
			throw new CommonException(e.getMessage());
		}
		return returnFlag;
	}
	/**
	 * 填入报表信息公共方法
	 * Description <p>TODO</p>
	 * @param map  报表参数
	 * @param type 类型  1 柜员  2 网点
	 * @param user 柜员
	 * @param brch 网点
	 * @param clrDate 清分日期
	 * @return
	 */
	public Map setReportPara(Map map,String type,Users user,SysBranch brch,String clrDate){
		try {
			Object[] online_in_100 = null;
			Object[] online_in_120 = null;
			Object[] online_in_991 = null;
			Object[] offline_in_100 = null;
			Object[] offline_in_120 = null;
			Object[] offline_in_991 = null;
			Object[] hjlqr_in_100 = null;
			Object[] hjlqr_in_120 = null;
			Object[] hjlqr_in_991 = null;
			Object[] gytj_in = null;
			Object[] gytj_out = null;
			Object[] obj_day_in = null;
			Object[] online_out_100 = null;
			Object[] online_out_120 = null;
			Object[] online_out_991 = null;
			Object[] offline_out_100 = null;
			Object[] offline_out_120 = null;
			Object[] offline_out_991 = null;
			Object[] zhfh_out_100 = null;
			Object[] zhfh_out_120 = null;
			Object[] zhfh_out_991 = null;
			Object[] wdck_out = null;
			Object fwmmcz_100 = null;
			Object fwmmcz_120 = null;
			Object fwmmcz_991 = null;
			Object fwmmxg_100 = null;
			Object fwmmxg_120 = null;
			Object fwmmxg_991 = null;
			Object jymmcz_100 = null;
			Object jymmcz_120 = null;
			Object jymmcz_991 = null;
			Object jymmxg_100 = null;
			Object jymmxg_120 = null;
			Object jymmxg_991 = null;
			Object sbkmmcz_100 = null;
			Object sbkmmcz_120 = null;
			Object sbkmmcz_991 = null;
			Object sbkmmxg_100 = null;
			Object sbkmmxg_120 = null;
			Object sbkmmxg_991 = null;
			Object kpsd_100 = null;
			Object kpsd_120 = null;
			Object kpsd_991 = null;
			Object kpjs_100 = null;
			Object kpjs_120 = null;
			Object kpjs_991 = null;
			Object kpgs_100 = null;
			Object kpgs_120 = null;
			Object kpgs_991 = null;
			Object kpjg_100 = null;
			Object kpjg_120 = null;
			Object kpjg_991 = null;
			Object kpbk_100 = null;
			Object kpbk_120 = null;
			Object kpbk_991 = null;
			Object kphk_100 = null;
			Object kphk_120 = null;
			Object kphk_991 = null;
			Object kpzx_100 = null;
			Object kpzx_120 = null;
			Object kpzx_991 = null;
			Object lxsl_100 = null;
			Object lxsl_120 = null;
			Object lxsl_991 = null;
			Object dsfzsl_100 = null;
			Object dsfzsl_120 = null;
			Object dsfzsl_991 = null;
			Object hkzqb_100 = null;
			Object hkzqb_120 = null;
			Object hkzqb_991 = null;
			Object ygsyw_100 = null;
			Object ygsyw_120 = null;
			Object ygsyw_991 = null;
			// 补换卡工本费
			Object[] bhkgbf_100 = null;
			Object[] bhkgbf_120 = null;
			Object[] bhkgbf_991 = null;
			// 补换卡工本费(撤销)
			Object[] bhkcxgbf_100 = null;
			Object[] bhkcxgbf_120 = null;
			Object[] bhkcxgbf_991 = null;
			// 卡发放
			Object cardissue_100 = null;
			Object cardissue_120 = null;
			Object cardissue_991 = null;
			// 卡发放
			Object tcqbg_100 = null;
			Object tcqbg_120 = null;
			Object tcqbg_991 = null;
			if(type.equals("1")){
				// 补换卡工本费
				bhkgbf_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key in ('bkyw','hkyw') and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				bhkgbf_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'hkyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				bhkgbf_991 = new Object[]{"0","0.00"};
				// 补换卡工本费(撤销)
				bhkcxgbf_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key in ('bkcxyw','hkcxyw') and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				bhkcxgbf_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'hkcxyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				bhkcxgbf_991 = new Object[]{"0","0.00"};
				//报表第一行信息
				online_in_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'online_in' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				online_in_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'online_in' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				online_in_991 = new Object[]{"0","0.00"};
				if(online_in_100 == null){
					online_in_100 = new Object[]{"0","0.00"};
				}
				if(online_in_120 == null){
					online_in_120 = new Object[]{"0","0.00"};
				}
				//报表第二行信息
				offline_in_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'offline_in' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				offline_in_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'offline_in' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				offline_in_991 = new Object[]{"0","0.00"};
				if(offline_in_100 == null){
					offline_in_100 = new Object[]{"0","0.00"};
				}
				if(offline_in_120 == null){
					offline_in_120 = new Object[]{"0","0.00"};
				}
				//报表第三行信息
				hjlqr_in_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'hjl_qr_in' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				hjlqr_in_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'hjl_qr_in' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				if(hjlqr_in_100 == null){
					hjlqr_in_100 = new Object[]{"0","0.00"};
				}
				if(hjlqr_in_120 == null){
					hjlqr_in_120 = new Object[]{"0","0.00"};
				}
				hjlqr_in_991 = new Object[]{"0","0.00"};
				//报表第四行信息
				gytj_in = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'gytj' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.amt >0");
				if(gytj_in == null){
					gytj_in = new Object[]{"0","0.00"};
				}
				gytj_out = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'gytj' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.amt <0 ");
				if(gytj_out == null){
					gytj_out = new Object[]{"0","0.00"};
				}
				//现金收支统计
				obj_day_in = (Object[])this.findOnlyRowBySql("SELECT to_char(SUM(abs(nvl(t4.cur_in_num,0)))),"
		        		+ "trim(to_char((SUM(abs(nvl(t4.cur_in_amt,0))))/100,'999999990.00')),to_char(SUM(abs(nvl(t4.cur_out_num,0)))),"
		        		+ "trim(to_char(SUM(abs(nvl(t4.cur_out_amt,0)))/100,'999999990.00')),trim(to_char(sum(abs(nvl(t4.cur_amt,0)))/100,'9999999900.00')),trim(to_char(sum(t4.pre_amt)/100,'999999990.00'))"
		        		+ "FROM stat_day_bal_data t4 WHERE  t4.stat_key='in_out' and  EXISTS (SELECT 1 FROM stat_day_bal_conf t3 WHERE t3.stat_key = t4.stat_key AND t3.stat_item_type = '1' )and t4.user_id='" + 
		        			user.getUserId() + "' and t4.clr_date='" + clrDate + "'");
				if(obj_day_in == null){
					obj_day_in = new Object[]{"0","0.00","0","0.00","0.00","0.00"};
				}
				//报表第七行数据
				online_out_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'online_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				online_out_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'online_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				online_out_991 = new Object[]{"0","0.00"};
				if(online_out_100 == null){
					online_out_100 = new Object[]{"0","0.00"};
				}
				if(online_out_120 == null){
					online_out_120 = new Object[]{"0","0.00"};
				}
				//报表第八行数据
				offline_out_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'offline_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				offline_out_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'offline_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				offline_out_991 = new Object[]{"0","0.00"};
				if(offline_out_100 == null){
					offline_out_100 = new Object[]{"0","0.00"};
				}
				if(offline_out_120 == null){
					offline_out_120 = new Object[]{"0","0.00"};
				}
				//报表第九行数据
				zhfh_out_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'zxzhfh_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				zhfh_out_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'zxzhfh_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				zhfh_out_991 = new Object[]{"0","0.00"};
				if(zhfh_out_100 == null){
					zhfh_out_100 = new Object[]{"0","0.00"};
				}
				if(zhfh_out_120 == null){
					zhfh_out_120 = new Object[]{"0","0.00"};
				}
				//网点存款
				wdck_out = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key = 'wdck_out' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "'");
				if(wdck_out == null ){
					wdck_out = new Object[]{"0","0.00"};
				}
				//报表第十四行数据（服务密码重置）
				fwmmcz_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'fwmmcz' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				fwmmcz_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'fwmmcz' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				fwmmcz_991 = "0";
				if(fwmmcz_100 == null){
					fwmmcz_100 = "0";
				}
				if(fwmmcz_120 == null){
					fwmmcz_120 = "0";
				}
				fwmmxg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'fwmmxg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				fwmmxg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'fwmmxg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				fwmmxg_991 = "0";
				if(fwmmxg_100 == null){
					fwmmxg_100 = "0";
				}
				if(fwmmxg_120 == null){
					fwmmxg_120 = "0";
				}
				//报表第十五行数据
				jymmcz_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'jymmcz' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				jymmcz_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'jymmcz' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				jymmcz_991 = "0";
				if(jymmcz_100 == null){
					jymmcz_100 = "0";
				}
				if(jymmcz_120 == null){
					jymmcz_120 = "0";
				}
				jymmxg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'jymmxg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				jymmxg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'jymmxg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				jymmxg_991 = "0";
				if(jymmxg_100 == null){
					jymmxg_100 = "0";
				}
				if(jymmxg_120 == null){
					jymmxg_120 = "0";
				}
				//报表第十六行数据
				sbkmmcz_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'sbkmmcz' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				sbkmmcz_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'sbkmmcz' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				sbkmmcz_991 = "0";
				if(sbkmmcz_100 == null){
					sbkmmcz_100 = "0";
				}
				if(sbkmmcz_120 == null){
					sbkmmcz_120 = "0";
				}
				sbkmmxg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'sbkmmxg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				sbkmmxg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'sbkmmxg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				sbkmmxg_991 = "0";
				if(sbkmmxg_100 == null){
					sbkmmxg_100 = "0";
				}
				if(sbkmmxg_120 == null){
					sbkmmxg_120 = "0";
				}
				//报表第十七行数据(卡片锁定)
				cardissue_100 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'kpsdyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpsd_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'kpsdyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpsd_991 = "0";
				if(kpsd_100 == null){
					kpsd_100 = "0";
				}
				if(kpsd_120 == null){
					kpsd_120 = "0";
				}
				kpjs_100 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'kpjsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpjs_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'kpjsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpjs_991 = "0";
				if(kpjs_100 == null){
					kpjs_100 = "0";
				}
				if(kpjs_120 == null){
					kpjs_120 = "0";
				}
				//报表第十八行数据
				kpgs_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'gsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpgs_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'gsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpgs_991 = "0";
				if(kpgs_100 == null){
					kpgs_100 = "0";
				}
				if(kpgs_120 == null){
					kpgs_120 = "0";
				}
				kpjg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'jgsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpjg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'jgsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpjg_991 =  "0";
				if(kpjg_100 == null){
					kpjg_100 = "0";
				}
				if(kpjg_120 == null){
					kpjg_120 = "0";
				}
				//报表第十九行数据（补卡换卡业务注销）
				kpbk_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key in( 'bkyw','bkcxyw') and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'"); 
				kpbk_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key in( 'bkyw','bkcxyw') and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpbk_991 = "0"; 
				if(kpbk_100 == null){
					kpbk_100 = "0";
				}
				if(kpbk_120 == null){
					kpbk_120 = "0";
				}
				kphk_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key in ('hkyw','hkcxyw') and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'"); 
				kphk_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key in ('hkyw','hkcxyw') and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kphk_991 = "0"; 
				if(kphk_100 == null){
					kphk_100 = "0";
				}
				if(kphk_120 == null){
					kphk_120 = "0";
				}
				kpzx_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'zxyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpzx_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'zxyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpzx_991 = "0"; 
				if(kpzx_100 == null){
					kpzx_100 = "0";
				}
				if(kpzx_120 == null){
					kpzx_120 = "0";
				}
				
				lxsl_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'grslyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				lxsl_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'grslyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				lxsl_991 = "0"; 
				if(lxsl_100 == null){
					lxsl_100 = "0";
				}
				if(lxsl_120 == null){
					lxsl_120 = "0";
				}
				
				//报表第二十行数据
				dsfzsl_100 = "0";
				dsfzsl_120 = "0";
				dsfzsl_991 = "0";
				hkzqb_100  = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'hkzqb' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				hkzqb_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'hkzqb' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				hkzqb_991 = "0";
				if(hkzqb_100 == null){
					hkzqb_100 = "0";
				}
				if(hkzqb_120 == null){
					hkzqb_120 = "0";
				}
				ygsyw_100  = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'ygsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				ygsyw_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'ygsyw' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				ygsyw_991 = "0";
				if(ygsyw_100 == null){
					ygsyw_100 = "0";
				}
				if(ygsyw_120 == null){
					ygsyw_120 = "0";
				}
				if (obj_day_in[0] == null) {
			        obj_day_in[0] = "0";
			    }
			    if (obj_day_in[1] == null) {
			        obj_day_in[1] = "0.00";
			    }
			    if (obj_day_in[2] == null) {
			        obj_day_in[2] = "0";
			    }
			    if (obj_day_in[3] == null) {
			        obj_day_in[3] = "0.00";
			    }
			    if (obj_day_in[4] == null) {
			        obj_day_in[4] = "0.00";
			    }
			    if (obj_day_in[5] == null) {
			        obj_day_in[5] = "0.00";
			    }
				// 卡发放
			    cardissue_100 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'card_issue' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				cardissue_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'card_issue' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				cardissue_991 = "0";
				if(cardissue_100 == null){
					cardissue_100 = "0";
				}
				if(cardissue_120 == null){
					cardissue_120 = "0";
				}
				// 统筹区变更
			    tcqbg_100 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'tcqbg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				tcqbg_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'tcqbg' and t.user_id='" + user.getUserId() + "' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				tcqbg_991 = "0";
				if(tcqbg_100 == null){
					tcqbg_100 = "0";
				}
				if(tcqbg_120 == null){
					tcqbg_120 = "0";
				}
			}else if(type.equals("2")){
				// 补换卡工本费
				bhkgbf_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key in ('bkyw','hkyw','yhbkyw','yhhkyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				bhkgbf_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key in ('bkyw','hkyw','yhbkyw','yhhkyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				bhkgbf_991 = new Object[]{"0","0.00"};
				// 补换卡工本费(撤销)
				bhkcxgbf_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key in ('bkcxyw','hkcxyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				bhkcxgbf_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'99999990.00')) "
						+ "from stat_day_bal_data t where t.stat_key in ('bkcxyw','hkcxyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				bhkcxgbf_991 = new Object[]{"0","0.00"};
				//报表第一行信息
				online_in_100 = (Object[])this.findOnlyFieldBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'online_in' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				online_in_120 = (Object[])this.findOnlyFieldBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'online_in' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				online_in_991 = new Object[]{"0","0.00"};
				if(online_in_100 == null){
					online_in_100 = new Object[]{"0","0.00"}; 
				}
				if(online_in_120 == null){
					online_in_120 = new Object[]{"0","0.00"}; 
				}
				//报表第二行信息
				offline_in_100 = (Object[])this.findOnlyFieldBySql("select to_char(sum(abs(nvl(num,0)))),to_char(sum(abs(nvl(amt,0)))/100,'999999990.99') from stat_day_bal_data t where "
						+ "t.stat_key = 'offline_in' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				offline_in_120 = (Object[])this.findOnlyFieldBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'offline_in' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				offline_in_991 = new Object[]{"0","0.00"};
				if(offline_in_100 == null){
					offline_in_100 = new Object[]{"0","0.00"}; 
				}
				if(offline_in_120 == null){
					offline_in_120 = new Object[]{"0","0.00"}; 
				}
				//报表第三行信息
				hjlqr_in_100 = (Object[])this.findOnlyFieldBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'9999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'hjl_qr_in' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				hjlqr_in_120 = (Object[])this.findOnlyFieldBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'9999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'hjl_qr_in' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				hjlqr_in_991 = new Object[]{"0","0.00"};
				if(hjlqr_in_100 == null){
					hjlqr_in_100 = new Object[]{"0","0.00"}; 
				}
				if(hjlqr_in_120 == null){
					hjlqr_in_120 = new Object[]{"0","0.00"}; 
				}
				//报表第四行信息
				gytj_in = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'9999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'gytj' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+clrDate+"'");
				if(gytj_in == null){
					gytj_in = new Object[]{"0","0.00"}; 
				}
				gytj_out = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'9999999990.99')) from stat_day_bal_data t where "
						+ "t.stat_key = 'gytj' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+clrDate+"'");
				if(gytj_out == null){
					gytj_out = new Object[]{"0","0.00"}; 
				}
				//现金收支统计
				obj_day_in = (Object[])findOnlyRowBySql("SELECT to_char(SUM(abs(nvl(t4.cur_in_num,0)))),"
		        		+ "trim(to_char(SUM(abs(nvl(t4.cur_in_amt,0)))/100,'99999990.00')),to_char(SUM(abs(nvl(t4.cur_out_num,0)))),"
		        		+ "trim(to_char(SUM(abs(nvl(t4.cur_out_amt,0)))/100,'99999990.00')),trim(to_char(sum(abs(nvl(t4.cur_amt,0)))/100,'999999990.00')),trim(to_char(sum(abs(nvl(t4.pre_amt,0)))/100,'99999990.00')) "
		        		+ "FROM stat_day_bal_data t4 WHERE  t4.stat_key='in_out' and  t4.own_type = '2' and t4.brch_id='" + 
		        			brch.getBrchId() + "' and t4.clr_date='" + clrDate + "'");
				if(obj_day_in == null){
					obj_day_in = new Object[]{"0","0.00","0","0.00","0.00","0.00"}; 
				}
				//报表第七行数据
				online_out_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) from stat_day_bal_data t where "
						+ "t.stat_key = 'online_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				online_out_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) from stat_day_bal_data t where "
						+ "t.stat_key = 'online_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				online_out_991 = new Object[]{"0","0.00"};
				if(online_out_100 == null){
					online_out_100 = new Object[]{"0","0.00"}; 
				}
				if(online_out_120 == null){
					online_out_120 = new Object[]{"0","0.00"}; 
				}
				//报表第八行数据
				offline_out_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) from stat_day_bal_data t where "
						+ "t.stat_key = 'offline_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				offline_out_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) from stat_day_bal_data t where "
						+ "t.stat_key = 'offline_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				offline_out_991 = new Object[]{"0","0.00"};
				if(offline_out_100 == null){
					offline_out_100 = new Object[]{"0","0.00"}; 
				}
				if(offline_out_120 == null){
					offline_out_120 = new Object[]{"0","0.00"}; 
				}
				//报表第九行数据
				zhfh_out_100 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) from stat_day_bal_data t where "
						+ "t.stat_key = 'zxzhfh_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				zhfh_out_120 = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00')) from stat_day_bal_data t where "
						+ "t.stat_key = 'zxzhfh_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				zhfh_out_991 = new Object[]{"0","0.00"};
				if(zhfh_out_100 == null){
					zhfh_out_100 = new Object[]{"0","0.00"}; 
				}
				if(zhfh_out_120 == null){
					zhfh_out_120 = new Object[]{"0","0.00"}; 
				}
				//网点存款
				wdck_out = (Object[])this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))),trim(to_char(sum(abs(nvl(amt,0)))/100,'999999990.00'))  from stat_day_bal_data t where "
						+ "t.stat_key = 'wdck_out' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"'");
				if(wdck_out == null){
					wdck_out = new Object[]{"0","0.00"};
				}
				//报表第十四行数据（服务密码）
				fwmmcz_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'fwmmcz' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"'");
				fwmmcz_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'fwmmcz' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				fwmmcz_991 = "0";
				if(fwmmcz_100 == null){
					fwmmcz_100 = "0"; 
				}
				if(fwmmcz_120 == null){
					fwmmcz_120 = "0"; 
				}
				fwmmxg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'fwmmxg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				fwmmxg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'fwmmxg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				fwmmxg_991 = "0";
				if(fwmmxg_100 == null){
					fwmmxg_100 = "0"; 
				}
				if(fwmmxg_120 == null){
					fwmmxg_120 = "0"; 
				}
				//报表第十五行数据（交易密码）
				jymmcz_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'jymmcz' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				jymmcz_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'jymmcz' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				jymmcz_991 = "0";
				if(jymmcz_100 == null){
					jymmcz_100 = "0"; 
				}
				if(jymmcz_120 == null){
					jymmcz_120 = "0"; 
				}
				jymmxg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'jymmxg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				jymmxg_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'jymmxg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				jymmxg_991 = "0";
				if(jymmxg_100 == null){
					jymmxg_100 = "0"; 
				}
				if(jymmxg_120 == null){
					jymmxg_120 = "0"; 
				}
				//报表第十六行数据（社保密码）
				sbkmmcz_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'sbkmmcz' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				sbkmmcz_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'sbkmmcz' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				sbkmmcz_991 = "0";
				if(sbkmmcz_100 == null){
					sbkmmcz_100 = "0"; 
				}
				if(sbkmmcz_120 == null){
					sbkmmcz_120 = "0"; 
				}
				sbkmmxg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'sbkmmxg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				sbkmmxg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'sbkmmxg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				sbkmmxg_991 = "0";
				if(sbkmmxg_100 == null){
					sbkmmxg_100 = "0"; 
				}
				if(sbkmmxg_120 == null){
					sbkmmxg_120 = "0"; 
				}
				//报表第十七行数据（卡片锁定）
				kpsd_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'kpsdyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpsd_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'kpsdyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpsd_991 = "0";
				if(kpsd_100 == null){
					kpsd_100 = "0"; 
				}
				if(kpsd_120 == null){
					kpsd_120 = "0"; 
				}
				kpjs_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'kpjsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpjs_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'kpjsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpjs_991 = "0";
				if(kpjs_100 == null){
					kpjs_100 = "0"; 
				}
				if(kpjs_120 == null){
					kpjs_120 = "0"; 
				}
				//报表第十八行数据（挂失解挂失）
				kpgs_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'gsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpgs_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'gsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpgs_991 = "0";
				if(kpgs_100 == null){
					kpgs_100 = "0"; 
				}
				if(kpgs_120 == null){
					kpgs_120 = "0"; 
				}
				kpjg_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'jgsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpjg_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'jgsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpjg_991 = "0";
				if(kpjg_100 == null){
					kpjg_100 = "0"; 
				}
				if(kpjg_120 == null){
					kpjg_120 = "0"; 
				}
				kpbk_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key in ('bkyw','bkcxyw','yhbkyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpbk_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key in ('bkyw','bkcxyw','yhbkyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpbk_991 = "0";
				if(kpbk_100 == null){
					kpbk_100 = "0"; 
				}
				if(kpbk_120 == null){
					kpbk_120 = "0"; 
				}
				kphk_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key in ('hkyw','hkcxyw','yhhkyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kphk_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key  in ('hkyw','hkcxyw','yhhkyw') and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kphk_991 = "0";
				if(kphk_100 == null){
					kphk_100 = "0"; 
				}
				if(kphk_120 == null){
					kphk_120 = "0"; 
				}
				kpzx_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'zxyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				kpzx_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'zxyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				kpzx_991 = "0";
				if(kpzx_100 == null){
					kpzx_100 = "0"; 
				}
				if(kpzx_120 == null){
					kpzx_120 = "0"; 
				}
				lxsl_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'grslyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				lxsl_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'grslyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				lxsl_991 = "0";
				if(lxsl_100 == null){
					lxsl_100 = "0"; 
				}
				if(kpzx_120 == null){
					lxsl_120 = "0"; 
				}
				dsfzsl_100 = "0";
				dsfzsl_120 = "0";
				dsfzsl_991 = "0";
				
				hkzqb_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'hkzqb' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				hkzqb_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'hkzqb' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				hkzqb_991 = "0";
				if(hkzqb_100 == null){
					hkzqb_100 = "0"; 
				}
				if(hkzqb_120 == null){
					hkzqb_120 = "0"; 
				}
				ygsyw_100 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'ygsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				ygsyw_120 = (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) from stat_day_bal_data t where "
						+ "t.stat_key = 'ygsyw' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='"
						+ clrDate+"' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				ygsyw_991 = "0";
				if(ygsyw_100 == null){
					ygsyw_100 = "0"; 
				}
				if(ygsyw_120 == null){
					ygsyw_120 = "0"; 
				}
				if (obj_day_in[0] == null) {
			        obj_day_in[0] = "0";
			    }
			    if (obj_day_in[1] == null) {
			        obj_day_in[1] = "0.00";
			    }
			    if (obj_day_in[2] == null) {
			        obj_day_in[2] = "0";
			    }
			    if (obj_day_in[3] == null) {
			        obj_day_in[3] = "0.00";
			    }
			    if (obj_day_in[4] == null) {
			        obj_day_in[4] = "0.00";
			    }
			    if (obj_day_in[5] == null) {
			        obj_day_in[5] = "0.00";
			    }
			    // 卡发放
			    cardissue_100 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'card_issue' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				cardissue_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'card_issue' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				cardissue_991 = "0";
				if(cardissue_100 == null){
					cardissue_100 = "0";
				}
				if(cardissue_120 == null){
					cardissue_120 = "0";
				}
				// 统筹区变更
			    tcqbg_100 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'tcqbg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_QGN+"'");
				tcqbg_120 =  (Object)this.findOnlyRowBySql("select to_char(sum(abs(nvl(num,0)))) "
						+ "from stat_day_bal_data t where t.stat_key = 'tcqbg' and t.user_id is null and t.brch_id='"+brch.getBrchId()+"' and t.clr_date='" 
						+ clrDate + "' and t.card_type ='"+Constants.CARD_TYPE_SMZK+"'");
				tcqbg_991 = "0";
				if(tcqbg_100 == null){
					tcqbg_100 = "0";
				}
				if(tcqbg_120 == null){
					tcqbg_120 = "0";
				}
			}else{
				throw new CommonException("传入参数类型无法填入报表信息");
			}
			//向报表里添加数据
			/**************************************************************************/
			if(Tools.processNull(bhkgbf_100[0]).equals("")){
				bhkgbf_100[0] = "0";
			}
			if(Tools.processNull(bhkgbf_100[1]).equals("")){
				bhkgbf_100[1] = "0.00";
			}
			if(Tools.processNull(bhkgbf_120[0]).equals("")){
				bhkgbf_120[0] = "0";
			}
			if(Tools.processNull(bhkgbf_120[1]).equals("")){
				bhkgbf_120[1] = "0.00";
			}
			if(Tools.processNull(bhkcxgbf_100[0]).equals("")){
				bhkcxgbf_100[0] = "0";
			}
			if(Tools.processNull(bhkcxgbf_100[1]).equals("")){
				bhkcxgbf_100[1] = "0.00";
			}
			if(Tools.processNull(bhkcxgbf_120[0]).equals("")){
				bhkcxgbf_120[0] = "0";
			}
			if(Tools.processNull(bhkcxgbf_120[1]).equals("")){
				bhkcxgbf_120[1] = "0.00";
			}
			map.put("p_bhk_Num_Bk", Tools.processNull(bhkgbf_100[0] + ""));
			map.put("p_bhk_Amt_Bk", Tools.processNull(Arith.cardreportstomoney(bhkgbf_100[1] + "")));
			map.put("p_bhk_Num_Ck", Tools.processNull(bhkgbf_120[0] + ""));
			map.put("p_bhk_Amt_Ck", Tools.processNull(Arith.cardreportstomoney(bhkgbf_120[1] + "")));
			map.put("p_bhk_Num_Tk", Tools.processNull(bhkgbf_991[0] + ""));
			map.put("p_bhk_Amt_Tk", Tools.processNull(Arith.cardreportstomoney(bhkgbf_991[1] + "")));
			map.put("p_bhk_Num_Tot", (Integer.parseInt(bhkgbf_100[0] + "") + Integer.parseInt(bhkgbf_120[0] + "") + Integer.parseInt(bhkgbf_991[0] + "") + ""));
			map.put("p_bhk_Amt_Tot", Arith.cardreportstomoney(Float.parseFloat(bhkgbf_100[1] + "") + Float.parseFloat(bhkgbf_120[1] + "") + Float.parseFloat(bhkgbf_991[1] + "") + ""));
			map.put("p_bhk_Num_Bk_1", Tools.processNull(bhkcxgbf_100[0] + ""));
			map.put("p_bhk_Amt_Bk_1", Arith.cardreportstomoney(Tools.processNull(bhkcxgbf_100[1] + "")));
			map.put("p_bhk_Num_Ck_1", Tools.processNull(bhkcxgbf_120[0] + ""));
			map.put("p_bhk_Amt_Ck_1", Arith.cardreportstomoney(Tools.processNull(bhkcxgbf_120[1] + "")));
			map.put("p_bhk_Num_Tk_1", Tools.processNull(bhkcxgbf_991[0] + ""));
			map.put("p_bhk_Amt_Tk_1", Arith.cardreportstomoney(Tools.processNull(bhkcxgbf_991[1] + "")));
			map.put("p_bhk_Num_Tot_1", Integer.parseInt(bhkcxgbf_100[0] + "") + Integer.parseInt(bhkcxgbf_120[0] + "") + Integer.parseInt(bhkcxgbf_991[0] + "") + "");
			map.put("p_bhk_Amt_Tot_1", Arith.cardreportstomoney(Float.parseFloat(bhkcxgbf_100[1] + "") + Float.parseFloat(bhkcxgbf_120[1] + "") + Float.parseFloat(bhkcxgbf_991[1] + "") + ""));
			/**************************************************************************/
			if(Tools.processNull(online_in_100[0]).equals("")){
				online_in_100[0] = "0";
			}
			if(Tools.processNull(online_in_100[1]).equals("")){
				online_in_100[1] = "0.00";
			}
			if(Tools.processNull(online_in_120[0]).equals("")){
				online_in_120[0] = "0";
			}
			if(Tools.processNull(online_in_120[1]).equals("")){
				online_in_120[1] = "0.00";
			}
			map.put("p_Lj_Xjcz_Num_Bk",Tools.processNull(online_in_100[0]));
			map.put("p_Lj_Xjcz_Amt_Bk", Arith.cardreportstomoney(Tools.processNull(online_in_100[1])));
			map.put("p_Lj_Xjcz_Num_Ck", Tools.processNull(online_in_120[0]));
			map.put("p_Lj_Xjcz_Amt_Ck", Arith.cardreportstomoney(Tools.processNull(online_in_120[1])));
			map.put("p_Lj_Xjcz_Num_Tk", Tools.processNull(online_in_991[0]));
			map.put("p_Lj_Xjcz_Amt_Tk", Arith.cardreportstomoney(Tools.processNull(online_in_991[1])));
			map.put("p_Tj_Ljcz_Num_Tot",(Integer.parseInt(online_in_100[0]+"")+Integer.parseInt(online_in_120[0]+"")) + "");
			map.put("p_Lj_Xjcz_Amt_Tot", Arith.cardreportstomoney(Float.parseFloat(online_in_100[1]+"")+Float.parseFloat(online_in_120[1]+"") + ""));
			/**************************************************************************/
			if(Tools.processNull(offline_in_100[0]).equals("")){
				offline_in_100[0] = "0";
			}
			if(Tools.processNull(offline_in_100[1]).equals("")){
				offline_in_100[1] = "0.00";
			}
			if(Tools.processNull(offline_in_120[0]).equals("")){
				offline_in_120[0] = "0";
			}
			if(Tools.processNull(offline_in_120[1]).equals("")){
				offline_in_120[1] = "0.00";
			}
			map.put("p_Tj_Xjcz_Num_Bk",Tools.processNull(offline_in_100[0]));
			map.put("p_Tj_Xjcz_Amt_Bk", Arith.cardreportstomoney(Tools.processNull(offline_in_100[1]).trim()));
			map.put("p_Tj_Xjcz_Num_Ck", Tools.processNull(offline_in_120[0]));
			map.put("p_Tj_Xjcz_Amt_Ck", Arith.cardreportstomoney(Tools.processNull(offline_in_120[1])));
			map.put("p_Tj_Xjcz_Num_Tk", Tools.processNull(offline_in_991[0]));
			map.put("p_Tj_Xjcz_Amt_Tk", Arith.cardreportstomoney(Tools.processNull(offline_in_991[1])));
			map.put("p_Tj_Xjcz_Num_Tot",Integer.parseInt(offline_in_100[0]+"")+Integer.parseInt(offline_in_120[0]+"") + "");
			map.put("p_Tj_Xjcz_Amt_Tot", Arith.cardreportstomoney(Float.parseFloat(offline_in_100[1]+"")+Float.parseFloat(offline_in_120[1]+"") + ""));
			/**************************************************************************/
			if(Tools.processNull(hjlqr_in_100[0]).equals("")){
				hjlqr_in_100[0] = "0";
			}
			if(Tools.processNull(hjlqr_in_100[1]).equals("")){
				hjlqr_in_100[1] = "0.00";
			}
			if(Tools.processNull(hjlqr_in_120[0]).equals("")){
				hjlqr_in_120[0] = "0";
			}
			if(Tools.processNull(hjlqr_in_120[1]).equals("")){
				hjlqr_in_120[1] = "0.00";
			}
			map.put("p_HjlQR_Num_Bk",Tools.processNull(hjlqr_in_100[0]));
			map.put("p_HjlQR_Amt_Bk", Arith.cardreportstomoney(Tools.processNull(hjlqr_in_100[1])));
			map.put("p_HjlQR_Num_Ck", Tools.processNull(hjlqr_in_120[0]));
			map.put("p_HjlQR_Amt_Ck", Arith.cardreportstomoney(Tools.processNull(hjlqr_in_120[1])));
			map.put("p_HjlQR_Num_Tk", Tools.processNull(hjlqr_in_991[0]));
			map.put("p_HjlQR_Amt_Tk", Arith.cardreportstomoney(Tools.processNull(hjlqr_in_991[1])));
			map.put("p_HjlQR_Num_Tot",Integer.parseInt(hjlqr_in_100[0]+"")+Integer.parseInt(hjlqr_in_120[0]+"") + "");
			map.put("p_HjlQR_Amt_Tot", Arith.cardreportstomoney(Float.parseFloat(hjlqr_in_100[1]+"")+Float.parseFloat(hjlqr_in_120[1]+"") + ""));
			/**************************************************************************/
			if(Tools.processNull(gytj_in[0]).equals("")){
				gytj_in[0] = "0";
			}
			if(Tools.processNull(gytj_in[1]).equals("")){
				gytj_in[1] = "0.00";
			}
			map.put("p_Xjtj_In_Num",Tools.processNull(gytj_in[0]));
			map.put("p_Xjtj_In_Amt", Tools.processNull(gytj_in[1]));
			/**************************************************************************/
			map.put("p_Per_Amt", Tools.processNull(obj_day_in[5]));
			/**************************************************************************/
			map.put("p_Day_In_Num", Tools.processNull(obj_day_in[0]));
			map.put("p_Day_In_Amt", Tools.processNull(obj_day_in[1]));
			/**************************************************************************/
			if(Tools.processNull(online_out_100[0]).equals("")){
				online_out_100[0] = "0";
			}
			if(Tools.processNull(online_out_100[1]).equals("")){
				online_out_100[1] = "0.00";
			}
			if(Tools.processNull(online_out_120[0]).equals("")){
				online_out_120[0] = "0";
			}
			if(Tools.processNull(online_out_120[1]).equals("")){
				online_out_120[1] = "0.00";
			}
			map.put("p_Lj_Czcx_Bk_Num",Tools.processNull(online_out_100[0]));
			map.put("p_Lj_Czcx_Bk_Amt", Arith.cardreportstomoney(Tools.processNull(online_out_100[1])));
			map.put("p_Lj_Czcx_Ck_Num", Tools.processNull(online_out_120[0]));
			map.put("p_Lj_Czcx_Ck_Amt", Arith.cardreportstomoney(Tools.processNull(online_out_120[1])));
			map.put("p_Lj_Czcx_Tk_Num", Tools.processNull(online_out_991[0]));
			map.put("p_Lj_Czcx_Tk_Amt", Arith.cardreportstomoney(Tools.processNull(online_out_991[1])));
			map.put("p_Lj_Czcx_Tot_Num",Integer.parseInt(online_out_100[0]+"")+Integer.parseInt(online_out_120[0]+"") + "");
			map.put("p_Lj_Czcx_Tot_Amt", Arith.cardreportstomoney(Float.parseFloat(online_out_100[1]+"")+Float.parseFloat(online_out_120[1]+"") + ""));
			/**************************************************************************/
			if(Tools.processNull(offline_out_100[0]).equals("")){
				offline_out_100[0] = "0";
			}
			if(Tools.processNull(offline_out_100[1]).equals("")){
				offline_out_100[1] = "0.00";
			}
			if(Tools.processNull(offline_out_120[0]).equals("")){
				offline_out_120[0] = "0";
			}
			if(Tools.processNull(offline_out_120[1]).equals("")){
				offline_out_120[1] = "0.00";
			}
			map.put("p_Tj_Czcx_Bk_Num",Tools.processNull(offline_out_100[0]));
			map.put("p_Tj_Czcx_Bk_Amt", Arith.cardreportstomoney(Tools.processNull(offline_out_100[1])));
			map.put("p_Tj_Czcx_Ck_Num", Tools.processNull(offline_out_120[0]));
			map.put("p_Tj_Czcx_Ck_Amt", Arith.cardreportstomoney(Tools.processNull(offline_out_120[1])));
			map.put("p_Tj_Czcx_Tk_Num", Tools.processNull(offline_out_991[0]));
			map.put("p_Tj_Czcx_Tk_Amt", Arith.cardreportstomoney(Tools.processNull(offline_out_991[1])));
			map.put("p_Tj_Czcx_Tot_Num",Integer.parseInt(offline_out_100[0]+"")+Integer.parseInt(offline_out_120[0]+"") + "");
			map.put("p_Tj_Czcx_Tot_Amt", Arith.cardreportstomoney(Float.parseFloat(offline_out_100[1]+"")+Float.parseFloat(offline_out_120[1]+"") + ""));
			/**************************************************************************/
			if(Tools.processNull(zhfh_out_100[0]).equals("")){
				zhfh_out_100[0] = "0";
			}
			if(Tools.processNull(zhfh_out_100[1]).equals("")){
				zhfh_out_100[1] = "0.00";
			}
			if(Tools.processNull(zhfh_out_120[0]).equals("")){
				zhfh_out_120[0] = "0";
			}
			if(Tools.processNull(zhfh_out_120[1]).equals("")){
				zhfh_out_120[1] = "0.00";
			}
			map.put("p_ZxFh_Bk_Num",Tools.processNull(zhfh_out_100[0]));
			map.put("p_ZxFh_Bk_Amt", Arith.cardreportstomoney(Tools.processNull(zhfh_out_100[1])));
			map.put("p_ZxFh_Ck_Num", Tools.processNull(zhfh_out_120[0]));
			map.put("p_ZxFh_Ck_Amt", Arith.cardreportstomoney(Tools.processNull(zhfh_out_120[1])));
			map.put("p_ZxFh_Tk_Num", Tools.processNull(zhfh_out_991[0]));
			map.put("p_ZxFh_Tk_Amt", Arith.cardreportstomoney(Tools.processNull(zhfh_out_991[1])));
			map.put("p_ZxFh_Tot_Num",Integer.parseInt(zhfh_out_100[0]+"")+Integer.parseInt(zhfh_out_120[0]+"") + "");
			map.put("p_ZxFh_Tot_Amt", Arith.cardreportstomoney(Float.parseFloat(zhfh_out_100[1]+"")+Float.parseFloat(zhfh_out_120[1]+"") + ""));
			/**************************************************************************/
			if(Tools.processNull(wdck_out[0]).equals("")){
				wdck_out[0] = "0";
			}
			if(Tools.processNull(wdck_out[1]).equals("")){
				wdck_out[1] = "0.00";
			}
			map.put("p_Wdck_Out_Num",Tools.processNull(wdck_out[0]));
			map.put("p_Wdck_Out_Amt",Tools.processNull(wdck_out[1]));
			/**************************************************************************/
			if(Tools.processNull(gytj_out[0]).equals("")){
				gytj_out[0] = "0";
			}
			if(Tools.processNull(gytj_out[1]).equals("")){
				gytj_out[1] = "0.00";
			}
			map.put("p_Xjtj_Out_Num",Tools.processNull(gytj_out[0]));
			map.put("p_Xjtj_Out_Amt",Tools.processNull(gytj_out[1]));
			/**************************************************************************/
			map.put("p_Day_Out_Num",Tools.processNull(obj_day_in[2]));
			map.put("p_Day_Out_Amt",Tools.processNull(obj_day_in[3]));
			map.put("p_Money_Tot",Tools.processNull(obj_day_in[4]));
			/**************************************************************************/
			if(Tools.processNull(fwmmcz_100).equals("")){
				fwmmcz_100 = "0";
			}
			if(Tools.processNull(fwmmcz_120).equals("")){
				fwmmcz_120 = "0";
			}
			map.put("p_Gmfwmmcz_Bk_Num",Tools.processNull(fwmmcz_100));
			map.put("p_Gmfwmmcz_Ck_Num",Tools.processNull(fwmmcz_120));
			map.put("p_Gmfwmmcz_Tk_Num",Tools.processNull(fwmmcz_991));
			map.put("p_Gmfwmmcz_Tot_Num",Integer.parseInt(fwmmcz_100+"")+Integer.parseInt(fwmmcz_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(fwmmxg_100).equals("")){
				fwmmxg_100 = "0";
			}
			if(Tools.processNull(fwmmxg_120).equals("")){
				fwmmxg_120 = "0";
			}
			map.put("p_Gmfwmmxg_Bk_Num",Tools.processNull(fwmmxg_100));
			map.put("p_Gmfwmmxg_Ck_Num",Tools.processNull(fwmmxg_120));
			map.put("p_Gmfwmmxg_Tk_Num",Tools.processNull(fwmmxg_991));
			map.put("p_Gmfwmmxg_Tot_Num",Integer.parseInt(fwmmxg_100+"")+Integer.parseInt(fwmmxg_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(jymmcz_100).equals("")){
				jymmcz_100 = "0";
			}
			if(Tools.processNull(jymmcz_120).equals("")){
				jymmcz_120 = "0";
			}
			map.put("p_Gmjymmcz_Bk_Num",Tools.processNull(jymmcz_100));
			map.put("p_Gmjymmcz_Ck_Num",Tools.processNull(jymmcz_120));
			map.put("p_Gmjymmcz_Tk_Num",Tools.processNull(jymmcz_991));
			map.put("p_Gmjymmcz_Tot_Num",Integer.parseInt(jymmcz_100+"")+Integer.parseInt(jymmcz_120+"") + "");
			/**************************************************************************/
			if(jymmxg_100 == null){
				jymmxg_100  = "0";
			}
			if(Tools.processNull(jymmxg_100).equals("")){
				jymmxg_100 = "0";
			}
			if(Tools.processNull(jymmcz_120).equals("")){
				jymmxg_120 = "0";
			}
			map.put("p_Gmjymmxg_Bk_Num",Tools.processNull(jymmxg_100));
			map.put("p_Gmjymmxg_Ck_Num",Tools.processNull(jymmxg_120));
			map.put("p_Gmjymmxg_Tk_Num",Tools.processNull(jymmxg_991));
			map.put("p_Gmjymmxg_Tot_Num",Integer.parseInt(jymmxg_100+"")+Integer.parseInt(jymmxg_120+"") + "");
			/**************************************************************************/
			if(sbkmmcz_100 == null){
				sbkmmcz_100  = "0";
			}
			if(Tools.processNull(sbkmmcz_100).equals("")){
				sbkmmcz_100 = "0";
			}
			if(Tools.processNull(sbkmmcz_120).equals("")){
				sbkmmcz_120 = "0";
			}
			map.put("p_Gmsbmmcz_Bk_Num",Tools.processNull(sbkmmcz_100));
			map.put("p_Gmsbmmcz_Ck_Num",Tools.processNull(sbkmmcz_120));
			map.put("p_Gmsbmmcz_Tk_Num",Tools.processNull(sbkmmcz_991));
			map.put("p_Gmsbmmcz_Tot_Num",Integer.parseInt(sbkmmcz_100+"")+Integer.parseInt(sbkmmcz_120+"") + "");
			/**************************************************************************/
			if(sbkmmxg_100 == null){
				sbkmmxg_100  = "0";
			}
			if(Tools.processNull(sbkmmxg_100).equals("")){
				sbkmmxg_100 = "0";
			}
			if(Tools.processNull(sbkmmxg_120).equals("")){
				sbkmmxg_120 = "0";
			}
			map.put("p_Gmsbmmxg_Bk_Num",Tools.processNull(sbkmmxg_100));
			map.put("p_Gmsbmmxg_Ck_Num",Tools.processNull(sbkmmxg_120));
			map.put("p_Gmsbmmxg_Tk_Num",Tools.processNull(sbkmmxg_991));
			map.put("p_Gmsbmmxg_Tot_Num",Integer.parseInt(sbkmmxg_100+"")+Integer.parseInt(sbkmmxg_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kpsd_100).equals("")){
				kpsd_100 = "0";
			}
			if(Tools.processNull(kpsd_120).equals("")){
				kpsd_120 = "0";
			}
			map.put("p_CardLock_Bk",Tools.processNull(kpsd_100));
			map.put("p_CardLock_Ck",Tools.processNull(kpsd_120));
			map.put("p_CardLock_Tk",Tools.processNull(kpsd_991));
			map.put("p_CardLock_Tot",Integer.parseInt(kpsd_100+"")+Integer.parseInt(kpsd_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kpjs_100).equals("")){
				kpjs_100 = "0";
			}
			if(Tools.processNull(kpjs_120).equals("")){
				kpjs_120 = "0";
			}
			map.put("p_CardUnLock_Bk",Tools.processNull(kpjs_100));
			map.put("p_CardUnLock_Ck",Tools.processNull(kpjs_120));
			map.put("p_CardUnLock_Tk",Tools.processNull(kpjs_991));
			map.put("p_CardUnLock_Tot",Integer.parseInt(kpjs_100+"")+Integer.parseInt(kpjs_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(ygsyw_120).equals("")){
				ygsyw_120 = "0";
			}
			map.put("p_Guashi_Kt_Bk",Tools.processNull(ygsyw_100));
			map.put("p_Guashi_Kt_Ck",Tools.processNull(ygsyw_120));
			map.put("p_Guashi_Kt_Tk",Tools.processNull(ygsyw_991));
			map.put("p_Guashi_Amt_Kt_Tot",Integer.parseInt(ygsyw_100+"")+Integer.parseInt(ygsyw_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kpgs_100).equals("")){
				kpgs_100 = "0";
			}
			if(Tools.processNull(ygsyw_120).equals("")){
				kpgs_120 = "0";
			}
			map.put("p_Guashi_Bk",Tools.processNull(kpgs_100));
			map.put("p_Guashi_Ck",Tools.processNull(kpgs_120));
			map.put("p_Guashi_Tk",Tools.processNull(kpgs_991));
			map.put("p_Guashi_Amt_Tot",Integer.parseInt(kpgs_100+"")+Integer.parseInt(kpgs_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kpbk_100).equals("")){
				kpbk_100 = "0";
			}
			if(Tools.processNull(kpbk_120).equals("")){
				kpbk_120 = "0";
			}
			map.put("p_Bbk_Bk",Tools.processNull(kpbk_100));
			map.put("p_Bbk_Ck",Tools.processNull(kpbk_120));
			map.put("p_Bbk_Tk",Tools.processNull(kpbk_991));
			map.put("p_Bbk_Tot",Integer.parseInt(kpbk_100+"")+Integer.parseInt(kpbk_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kphk_100).equals("")){
				kphk_100 = "0";
			}
			if(Tools.processNull(kphk_120).equals("")){
				kphk_120 = "0";
			}
			map.put("p_Hk_Bk",Tools.processNull(kphk_100));
			map.put("p_Hk_Ck",Tools.processNull(kphk_120));
			map.put("p_Hk_Tk",Tools.processNull(kphk_991));
			map.put("p_Hk_Tot",Integer.parseInt(kphk_100+"")+Integer.parseInt(kphk_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kpzx_100).equals("")){
				kpzx_100 = "0";
			}
			if(Tools.processNull(kpzx_120).equals("")){
				kpzx_120 = "0";
			}
			map.put("p_Zhuxiao_Bk",Tools.processNull(kpzx_100));
			map.put("p_Zhuxiao_Ck",Tools.processNull(kpzx_120));
			map.put("p_Zhuxiao_Tk",Tools.processNull(kpzx_991));
			map.put("p_Zhuxiao_Num_Tot",Integer.parseInt(kpzx_100+"")+Integer.parseInt(kpzx_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(lxsl_100).equals("")){
				lxsl_100 = "0";
			}
			if(Tools.processNull(lxsl_120).equals("")){
				lxsl_120 = "0";
			}
			map.put("p_Shengling_Bk",Tools.processNull(lxsl_100));
			map.put("p_Shengling_Ck",Tools.processNull(lxsl_120));
			map.put("p_Shengling_Tk",Tools.processNull(lxsl_991));
			map.put("p_Shengling_Num_Tot",Integer.parseInt(lxsl_100+"")+Integer.parseInt(lxsl_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(dsfzsl_100).equals("")){
				dsfzsl_100 = "0";
			}
			if(Tools.processNull(dsfzsl_120).equals("")){
				dsfzsl_120 = "0";
			}
			map.put("p_ShenglingSfz_Bk",Tools.processNull(dsfzsl_100));
			map.put("p_ShenglingSfz_Ck",Tools.processNull(dsfzsl_120));
			map.put("p_ShenglingSfz_Tk",Tools.processNull(dsfzsl_991));
			map.put("p_ShenglingSfz_Tot",Integer.parseInt(dsfzsl_100+"")+Integer.parseInt(dsfzsl_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(hkzqb_100).equals("")){
				hkzqb_100 = "0";
			}
			if(Tools.processNull(hkzqb_120).equals("")){
				hkzqb_120 = "0";
			}
			map.put("p_Hkzqb_Bk",Tools.processNull(hkzqb_100));
			map.put("p_Hkzqb_Ck",Tools.processNull(hkzqb_120));
			map.put("p_Hkzqb_Tk",Tools.processNull(hkzqb_991));
			map.put("p_Hkzqb_Tot",Integer.parseInt(hkzqb_100+"")+Integer.parseInt(hkzqb_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(kpjg_100).equals("")){
				kpjg_100 = "0";
			}
			if(Tools.processNull(kpjg_120).equals("")){
				kpjg_120 = "0";
			}
			kpjg_991 = "0";
			map.put("p_Guashi_Undo_Bk",kpjg_100);
			map.put("p_Guashi_Undo_Ck",kpjg_120);
			map.put("p_Guashi_Undo_Tk",kpjg_991);
			map.put("p_Guashi_Amt_Undo_Tot",(Integer.parseInt(kpjg_100+""))+Integer.parseInt(kpjg_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(cardissue_100).equals("")){
				cardissue_100 = "0";
			}
			if(Tools.processNull(cardissue_120).equals("")){
				cardissue_120 = "0";
			}
			map.put("p_CardIssue_Bk",Tools.processNull(cardissue_100));
			map.put("p_CardIssue_Ck",Tools.processNull(cardissue_120));
			map.put("p_CardIssue_Tk",Tools.processNull(cardissue_991));
			map.put("p_CardIssue_Tot",Integer.parseInt(cardissue_100+"")+Integer.parseInt(cardissue_120+"") + "");
			/**************************************************************************/
			if(Tools.processNull(tcqbg_100).equals("")){
				tcqbg_100 = "0";
			}
			if(Tools.processNull(tcqbg_120).equals("")){
				tcqbg_120 = "0";
			}
			map.put("p_tcqbg_Bk",Tools.processNull(tcqbg_100));
			map.put("p_tcqbg_Ck",Tools.processNull(tcqbg_120));
			map.put("p_tcqbg_Tk",Tools.processNull(tcqbg_991));
			map.put("p_tcqbg_Tot",Integer.parseInt(tcqbg_100+"")+Integer.parseInt(tcqbg_120+"") + "");
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return map;
	}
	@Autowired
	public void setOfflineDataProcessService(
			OfflineDataProcessService offlineDataProcessService) {
		this.offlineDataProcessService = offlineDataProcessService;
	}

	@Autowired
	public void setOfflineDataService(OfflineDataService offlineDataService) {
		this.offlineDataService = offlineDataService;
	}

}
