
package com.erp.serviceImpl;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileWriter;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;

import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ResourceLoaderAware;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.dao.PublicDao;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.BaseRegion;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardConfig;
import com.erp.model.PayClrPara;
import com.erp.model.StockType;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysCode;
import com.erp.model.SysPara;
import com.erp.model.SysReport;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.BaseService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.JsonHelper;
import com.erp.util.SqlTools;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;
import com.erp.util.XmlBeanUtil;
import com.erp.viewModel.Page;
import com.erp.webservice.client.EasyServiceStub;

/**
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: BaseServiceImpl.java</p>
 * <p>Description:福产流通科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:福产流通科技</p>
 * @author hujc 631410114@qq.com
 * @date 2013-4-19 下午03:18:37
 * @version V1.0
 */
@Service("baseService")
public class BaseServiceImpl implements BaseService,ResourceLoaderAware{
	private static Log log = LogFactory.getLog(BaseServiceImpl.class);
	private static Logger logger = Logger.getLogger(BaseServiceImpl.class);
	public static List stockTypeList = new ArrayList();//库存种类
	public static List cardparaList = new ArrayList();//卡业务参数表
	public static  ResourceLoader resourceLoader;//资源加载器
	private static Properties propertiesParas = null;//= new Properties();
	public static boolean DEALCARDNO=false;//当前是否在处理卡号，true表示正在获取卡号，false表示已经获取卡号成功
	public static boolean DEAL_CARD_NO_WAIT = false;
	public static Long DEAL_CARD_NO_WAIT_TIMES = 1L;
	private EasyServiceStub easyServiceClient = null;
	@SuppressWarnings("rawtypes")
	@Autowired
	public  PublicDao publicDao;
	@SuppressWarnings("rawtypes")
	public void setPublicDao(PublicDao dao){
		this.publicDao = dao;
	}

	@SuppressWarnings("rawtypes")
	public PublicDao getPublicDao(){
		return publicDao;
	}
	
	@Override
	public  void setResourceLoader(ResourceLoader arg0) {
		BaseServiceImpl.resourceLoader = arg0;
	}
	@PostConstruct
	public synchronized void initPara(){
		try{
			if(resourceLoader == null){
				return;
			}
			Resource resource = resourceLoader.getResource("classpath:"  + Constants.SYS_CONFIG_INIT_FILENAME + ".properties");
			if(resource != null){
				propertiesParas = new Properties();
				propertiesParas.load(resource.getInputStream());
			}
		}catch(Exception e){
			log.error("加载配置文件" + Constants.SYS_CONFIG_INIT_FILENAME + ".properties 出现错误。" + e.getMessage());
		}
	}
	@Override
	public Object findOnlyRowByHql(String hql) throws CommonException {
		try {
			List list  = publicDao.find(hql);
			if(list!=null && list.size()>0){
				return list.get(0);
			}
			return null;
		} catch (Exception e) {
			throw new CommonException("the findOnlyRowByHql Method in "+this.getClass().getName()+" occur error: "+e.getMessage());
		}
	}
	public List findByHql(String hql) throws CommonException {
		try {
			return publicDao.find(hql);
		} catch (Exception e) {
			throw new CommonException("the findOnlyRowByHql Method in "+this.getClass().getName()+" occur error: "+e.getMessage());
		}
	}
	
	public List findBySql(String sql) throws CommonException {
		try {
			return publicDao.findBySQL(sql);
		} catch (Exception e) {
			throw new CommonException("the findBySql Method in "+this.getClass().getName()+" occur error: "+e.getMessage());
		}
	}

	@Override
	public SysBranch getSysBranchByUserId() throws CommonException {
		String hql = "from SysBranch where brchId ='"+this.getUser().getBrchId()+"'";
		return (SysBranch)publicDao.find(hql).get(0);
	}

	@Override
	public Users getUser() throws CommonException {
		Users existsCurrent = (Users) SecurityUtils.getSubject().getSession().getAttribute(Constants.LOGIN_SESSION_DATANAME);
		if(existsCurrent != null){
			return existsCurrent;
		}
		String hql = "from Users where userId = '" + Constants.getCurrendUser().getAccount() + "'";
		Users curusers = (Users)publicDao.find(hql).get(0);
		return curusers;
	}
	/**
	 * 获取当前session操作员
	 */
	public Users getSessionUser() throws CommonException {
		return this.getUser();
	}
	/**
	 * 获取当前session操作员
	 */
	public SysBranch getSessionSysBranch() throws CommonException {
		Subject subject=SecurityUtils.getSubject();
		Users users=(Users)getSessionUser();
		String hql = "from SysBranch where brchId ='"+users.getBrchId()+"'";
		SysBranch sysBranch=(SysBranch)publicDao.find(hql).get(0);
		subject.getSession().setAttribute(Constants.LOGIN_SESSION_SYSBRANCH,sysBranch);
        return sysBranch;
	}
	@Override
	public PayClrPara getPayClrPara() throws CommonException {
		String hql = "from PayClrPara where 1=1";
		return (PayClrPara)publicDao.find(hql).get(0);
	}
    /**
     * 取参数配置信息
     * @param paraCode
     * @return
     * @throws CommonException
     */
	public SysPara getSysParaByParaCode(String paraCode) throws CommonException {
		String hql = "from SysPara s where s.paraCode ='"+paraCode+"'";
		return (SysPara)publicDao.find(hql).get(0);
	}
	@Override
	public String getCodeNameBySYS_CODE(String CodeType, String codeValue)throws CommonException {
		String  hql = "from SysCode where id.codeType = '" + CodeType + "' and id.codeValue = '" + codeValue + "'";
		List<?> list = publicDao.find(hql);
		if(list != null && list.size() > 0){
			return ((SysCode)list.get(0)).getCodeName();
		}
		return "";
	}

	/**
	 * 取卡参数信息
	 * @param CardType
	 * @return
	 * @throws CommonException
	 */
	public CardConfig getCardConfigByCardType(String CardType) throws CommonException {
		String hql="from CardConfig c where c.cardType='"+CardType+"'";
		return (CardConfig)publicDao.find(hql).get(0);
	}

	@Override
	public String getSequenceByName(String seqName) {
		String sql="select "+seqName+".nextval from dual";
		return ((BigDecimal)publicDao.findOnlyFieldBySql(sql)).toString();
	}

	@Override
	public Object findOnlyFieldBySql(String sql) throws CommonException {
		return publicDao.findOnlyFieldBySql(sql);
	}

	@Override
	public String findTrCodeNameByCodeType(Integer codeValue) throws CommonException {
		return publicDao.findTrCodeNameByCodeType(codeValue);
	}
	/**
	 * 获取配置文件属性值
	 * @param key 键值对 key
	 * @return    键值对value
	 */
	@Override
	public String getSysConfigurationParameters(String key){
		if(!propertiesParas.isEmpty()){
			return propertiesParas.getProperty(key);
		}else{
			initPara();
			return propertiesParas.getProperty(key);
		}
	}
	/**
	 * 获取清分日期
	 */
	@Override
	public String getClrDate(){
		return Tools.processNull(publicDao.findOnlyFieldBySql("select clr_date from PAY_CLR_PARA"));
	}
	
	//取当前的清分日期
	public String getBeforeClrDate(){
		return Tools.processNull(publicDao.findOnlyFieldBySql("select to_char(to_date(clr_date,'yyyy-MM-dd')-1,'yyyy-MM-dd') AS clr_date from PAY_CLR_PARA "));
	}


	@Override
	public void saveTrServRec(SysActionLog actionLog) throws CommonException {
		try {
			//综合业务记录 Tr_Serv_Rec_年份
			TrServRec serv = new TrServRec();
			serv.setDealNo(actionLog.getDealNo());//业务流水号
			serv.setOrgId(actionLog.getOrgId());//办理机构
			serv.setDealCode(actionLog.getDealCode());//交易代码
			serv.setBizTime(actionLog.getDealTime());//业务办理时间
			serv.setUserId(actionLog.getUserId());//办理操作员编号
			serv.setBrchId(actionLog.getBrchId());//办理柜员所在网点
			serv.setClrDate(this.getClrDate());//清分日期
			serv.setNote(actionLog.getMessage());//note字段
			serv.setDealState(Sys_Code.TR_STATE_ZC);//业务状态0正常1撤销)
			publicDao.save(serv);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 保存系统打印报表
	 * @param actionLog   SysActionLog 操作日志
	 * @param jsonObject  JSONObject 报表数据
	 * @param filename    filename 报表路径 + 文件名
	 * @param format      String 报表格式
	 * @param print_Times Long 打印次数
	 * @param return_Url  String 打印后跳转路径 @可设空
	 * @return SysReport 报表对象
	 */
	@SuppressWarnings("unchecked")
	public SysReport saveSysReport(SysActionLog actionLog,JSONObject jsonObject,String filename,String format,Long print_Times,String return_Url,byte[] pdfContent) throws CommonException {
		try {
			SysReport report = new SysReport();
			report.setDealNo(actionLog.getDealNo());//业务流水号
			report.setRpTitile(Constants.APP_REPORT_TITLE + Tools.processNull(findTrCodeNameByCodeType(actionLog.getDealCode())) + "凭证");//报表名称
			if(jsonObject != null){
				jsonObject.put("title",Tools.processNull(report.getRpTitile()));
				report.setContent(jsonObject.toString());
			}
			report.setFormat(format);//报表类型，PDF或HTML
			report.setFileName(filename);//报表文件名称或报表执行ftl路径
			report.setUserId(actionLog.getUserId());//操作员
			report.setDealDate(actionLog.getDealTime());//操作日期
			report.setReturnUrl(return_Url);//打印页面返回url
			report.setPrintTimes(print_Times);//打印次数，>1表示补打
			report.setPdfContent(pdfContent);
			publicDao.save(report);
			return report;
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	public Date getDateBaseTime() throws CommonException{
    		 return publicDao.getDateBaseTime();
    }

    public Date getDateBaseDate() throws CommonException{
    		 return publicDao.getDateBaseDate();
    }
	public Page pagingQuery(String sql,Integer pageNum,Integer pageSize) throws Exception{
		try{
			return publicDao.pagingQuery(sql, pageNum, pageSize);
		}catch(Exception e){
			throw e;
		}
	}

	@Override
	public Object findOnlyRowBySql(String hql) throws Exception {
		try{
			List l = publicDao.findBySQL(hql);
			if(l != null && l.size() > 0){
				return l.get(0);
			}else{
				return null;
			}
		}catch(Exception e){
			throw e;
		}
	}

	@Override
	public ResultSet tofindResultSet(String sql) throws CommonException {
		ResultSet set = null;
		try{
			set = publicDao.findResultSet(sql);
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return set;
	}
	
	 /**
	  * 获取当前用户的actionLog
	  */
	 
	 public SysActionLog getCurrentActionLog() throws CommonException{
		 try {
			Subject subject = SecurityUtils.getSubject();
			SysActionLog log = (SysActionLog) subject.getSession().getAttribute(Constants.ACTIONLOG);
			log.setDealTime(this.getDateBaseTime());
			log.setOrgId(this.getUser().getOrgId());
			if(log.getInOutData() != null && log.getInOutData().length() >= 4000){
				log.setInOutData(log.getInOutData().substring(0, 3900) + "...");
			}
			return log;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	 }
	 /**
	 * 判断柜员数据权限
	 * @param branchColumnName
	 * @param operColumn
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public String getLimitQueryData(String branchColumnName,String operColumn) throws CommonException{
		try{
			//String existsLimit = (String) SecurityUtils.getSubject().getSession().getAttribute("_Individuals_Limit_Branch_Query_");
			/*if(!Tools.processNull(existsLimit).equals("")){
				//return existsLimit;
			}*/
			String limitSql = "";
			String allBranchs = "";
			Users currUser = getUser();
			if(Constants.SYS_OPERATOR_LEVEL_COMMON == currUser.getDutyId()){//普通柜员权限
				limitSql += " and " + operColumn + " = '" + currUser.getUserId() + "' and " + branchColumnName  + " = '" + currUser.getBrchId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCH == currUser.getDutyId() ){//网点主管权限
				limitSql += " and " + branchColumnName + " = '" + currUser.getBrchId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCHALL == currUser.getDutyId() ){//网点和子网点权限
				allBranchs = (String) this.findOnlyFieldBySql("select ltrim(max(sys_connect_by_path('''' || t.brch_id || '''',',')),',') " +
			    " from sys_branch t start with t.brch_id = " + currUser.getBrchId() + " connect by t.pid = prior t.SysBranch_id");
				limitSql += " and " + branchColumnName + " in (" + allBranchs + ") ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGAN == currUser.getDutyId() ){//机构权限,查询机构下的所有网点
				List<String> orgBranchs = this.findBySql("select distinct t.brch_id  from SYS_BRANCH t start with  t.org_id = ' " +
				currUser.getOrgId() + "' connect by t.pid = prior t.SysBranch_id");
				if(orgBranchs != null && orgBranchs.size() > 0){
					for (String tempbranchId : orgBranchs) {allBranchs += "'" + tempbranchId + "',";}
					if(allBranchs.length() > 0){allBranchs = allBranchs.substring(0,allBranchs.length() - 1);}else{allBranchs = "'_erp2_erp2_'";}
				}else{
					allBranchs = "'_erp2_erp2_'";
				}
				limitSql += " and " + branchColumnName + " in (" + allBranchs + ") ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGANALL == currUser.getDutyId()){
				List<String> orgBranchs = this.findBySql("select distinct t.brch_id  from SYS_BRANCH t,sys_organ o " + 
			    "  where t.org_id = o.org_id start with  o.org_id = '" + currUser.getOrgId() + "' connect by o.parent_org_id = prior o.org_id");
				if(orgBranchs != null && orgBranchs.size() > 0){
					for (String tempbranchId : orgBranchs) {allBranchs += "'" + tempbranchId + "',";}
					if(allBranchs.length() > 0){allBranchs = allBranchs.substring(0,allBranchs.length() - 1);}else{allBranchs = "'_erp2_erp2_'";}
				}else{
					allBranchs = "'_erp2_erp2_'";
				}
				limitSql += " and " + branchColumnName + " in (" + allBranchs + ") ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ADMIN == currUser.getDutyId() ){
				limitSql += " and 1 = 1 ";
			}else{
				limitSql += " and " + branchColumnName + " = '_erp2_erp2_' and " + operColumn + "= '_erp2_erp2_' ";
			}
			//SecurityUtils.getSubject().getSession().setAttribute("_Individuals_Limit_Branch_Query_",limitSql);
			return limitSql;
		}catch(Exception e){
			throw new CommonException("获取数据权限失败," + e.getMessage());
		}
	}
	/**
	 * 根据传入的网点编号和柜员权限获取下级网点 字符串 格式：'123','456','789'
	 * @param branchColumnName
	 * @param operColumn
	 * @return
	 * @throws CommonException
	 */
	public String getNextLimitBrch(String curBrchId) throws CommonException{
		try{
			String limitSql = "";
			Users currUser = getUser();
			if(Constants.SYS_OPERATOR_LEVEL_COMMON == currUser.getDutyId()){
				limitSql = "'" + currUser.getBrchId() + "'";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCH == currUser.getDutyId() ){
				limitSql = "'" + currUser.getBrchId() + "'";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCHALL == currUser.getDutyId() || 
					Constants.SYS_OPERATOR_LEVEL_ORGAN == currUser.getDutyId() || 
					Constants.SYS_OPERATOR_LEVEL_ORGANALL == currUser.getDutyId() ||
					Constants.SYS_OPERATOR_LEVEL_ADMIN == currUser.getDutyId()
			){
				List allBranchs = this.findBySql("select t.brch_id " +
			    " from sys_branch t start with t.brch_id = '" + curBrchId + "' connect by t.pid = prior t.SysBranch_id");
				if(allBranchs != null && allBranchs.size() > 0){
					for (Object object : allBranchs) {
						limitSql += "'" + Tools.processNull(object) + "',";
					}
					limitSql = limitSql.substring(0,limitSql.length() - 1);
				}else{
					limitSql = "'" + curBrchId + "'";
				}
			}else{
				limitSql += "erp2erp2";
			}
			//SecurityUtils.getSubject().getSession().setAttribute("_Individuals_Limit_Branch_Query_",limitSql);
			return limitSql;
		}catch(Exception e){
			throw new CommonException("获取数据权限失败," + e.getMessage());
		}
	}
	/**
	 * 判断网点的下拉框数据权限
	 * @param branchColumnName 待查询语句中网点字段名
	 * @param isShowOrg 页面中是否显示机构查询下拉框
	 * @retu 性语句
	 */
	@SuppressWarnings("unchecked")
	public String getLimitSysBranchQueryData(String branchColumnName) throws CommonException{
		try{
			String existsLimit = (String) SecurityUtils.getSubject().getSession().getAttribute("_Individuals_Limit_Queorg");
			if(!Tools.processNull(existsLimit).equals("")){
				return existsLimit;
			}
			String limitSql = "";
			String allBranchs = "";
			Users currUser = getUser();
			if(Constants.SYS_OPERATOR_LEVEL_COMMON == currUser.getDutyId()){
				limitSql += " and " + branchColumnName + " = '" + currUser.getBrchId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCH == currUser.getDutyId() ){
				limitSql += " and " + branchColumnName + " = '" + currUser.getBrchId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCHALL == currUser.getDutyId() ){
				allBranchs = (String) this.findOnlyFieldBySql("SELECT LTRIM(MAX(SYS_CONNECT_BY_PATH('''' || T.BRCH_ID || '''',',')),',')  FROM SYS_BRANCH T START WITH T.BRCH_ID = '" + currUser.getBrchId() + "' CONNECT BY PRIOR T.SYSBRANCH_ID =  T.PID");
				limitSql += " and " + branchColumnName + " in (" + allBranchs + ") ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGAN == currUser.getDutyId() ){
				List<String> orgBranchs = this.findBySql("SELECT DISTINCT T.BRCH_ID  FROM SYS_BRANCH T START WITH T.PID IS NULL AND T.ORG_ID = '" + currUser.getOrgId() + "' CONNECT BY PRIOR T.SYSBRANCH_ID = T.PID");
				//the reason is muti branch. so must be
				if(orgBranchs != null && orgBranchs.size() > 0){
					for (String tempbranchId : orgBranchs) {
						allBranchs += "'" + tempbranchId + "',";
					}
					if(allBranchs.length() > 0){
						allBranchs = allBranchs.substring(0,allBranchs.length() - 1);
					}else{
						allBranchs = "'_erp2_erp2_'";
					}
				}else{
					allBranchs = "'_erp2_erp2_'";
				}
				limitSql += " and " + branchColumnName + " in (" + allBranchs + ") ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGANALL == currUser.getDutyId()){
				String allOrgs = (String) this.findOnlyFieldBySql("select ltrim(max(sys_connect_by_path('''' || b.org_id || '''',',')),',')  from Sys_Organ b start with b.org_id = '" + currUser.getOrgId() + "' connect by prior b.customer_id = b.parent_org_id ");
				if(!Tools.processNull(allOrgs).equals("")){
					List<String> orgBranchs = this.findBySql("select distinct t.brch_id  from SYS_BRANCH t where t.org_id in (" + allOrgs + ")");
					if(orgBranchs != null && orgBranchs.size() > 0){
						for (String tempbranchId : orgBranchs) {
							allBranchs += "'" + tempbranchId + "',";
						}
						if(allBranchs.length() > 0){
							allBranchs = allBranchs.substring(0,allBranchs.length() - 1);
						}else{
							allBranchs = "'_erp2_erp2_'";
						}
					}else{
						allBranchs = "'_erp2_erp2_'";
					}
				}else{
					allBranchs = "'_erp2_erp2_'";
				}
				limitSql += " and " + branchColumnName + " in (" + allBranchs + ") ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ADMIN == currUser.getDutyId() ){
				limitSql += " and 1 = 1 ";
			}else{
				limitSql += " and " + branchColumnName + " = '_erp2_erp2_' ";
			}
			SecurityUtils.getSubject().getSession().setAttribute("_Individuals_Limit_Query_",limitSql);
			return limitSql;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings("unchecked")
	public String getLimitSysOrganQueryData(String orgClounmName){
		try{
			String existsLimit = (String) SecurityUtils.getSubject().getSession().getAttribute("_Individuals_Limit_Query_");
			if(!Tools.processNull(existsLimit).equals("")){
				return existsLimit;
			}
			String limitSql = "";
			String allOrgIds = "";
			Users currUser = getUser();
			if(Constants.SYS_OPERATOR_LEVEL_COMMON == currUser.getDutyId()){//普通柜员权限
				limitSql += " and " + orgClounmName + " = '" + currUser.getOrgId()+ "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCH == currUser.getDutyId() ){//网点主管权限
				limitSql += " and " + orgClounmName + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCHALL == currUser.getDutyId() ){//网点和子网点权限
				limitSql += " and " + orgClounmName + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGAN == currUser.getDutyId() ){//机构权限,查询机构下的所有网点
				limitSql += " and " + orgClounmName + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGANALL == currUser.getDutyId()){
				List<String> allOrgs = this.findBySql("select distinct o.org_id  from sys_organ o " +
				" where 1=1 start with  o.org_id = '" + currUser.getOrgId() + "' connect by o.parent_org_id = prior o.org_id");
				if(allOrgs != null && allOrgs.size() > 0){
					for (String temporgId : allOrgs) {
						allOrgIds += "'" + temporgId + "',";
					}
					if(allOrgIds.length() > 0){
						allOrgIds = allOrgIds.substring(0,allOrgIds.length() - 1);
					}else{
						allOrgIds = "'_erp2_erp2_'";
					}
				}else{
					allOrgIds = "'_erp2_erp2_'";
				}
				limitSql += " and " + orgClounmName + " in (" + allOrgs + ") ";
					
			}else if(Constants.SYS_OPERATOR_LEVEL_ADMIN == currUser.getDutyId() ){
				limitSql += " and 1 = 1 ";
			}else{
				limitSql += " and " + orgClounmName + " = '_erp2_erp2_' ";
			}
			SecurityUtils.getSubject().getSession().setAttribute("_Individuals_Limit_Query_",limitSql);
			return limitSql;
		}catch(Exception e){
			throw new CommonException("获取数据权限失败," + e.getMessage());
		}
	}
	/**
	 * 机构下拉框权限判断
	 * @param orgIdColumn 机构列表字段名
	 * @return 机构限制性语句
	 */
	public String getLimitSysOrgQueryData(String orgIdColumn) throws CommonException{
		try{
			String existsLimit = (String) SecurityUtils.getSubject().getSession().getAttribute("_Individuals_Limit_Query_org_");
			if(!Tools.processNull(existsLimit).equals("")){
				return existsLimit;
			}
			String limitSql = "";
			Users currUser = getUser();
			if(Constants.SYS_OPERATOR_LEVEL_COMMON == currUser.getDutyId()){//普通柜员权限
				limitSql += " and " + orgIdColumn + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCH == currUser.getDutyId() ){//网点主管权限
				limitSql += " and " + orgIdColumn + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_BRANCHALL == currUser.getDutyId() ){//网点和子网点权限
				limitSql += " and " + orgIdColumn + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGAN == currUser.getDutyId() ){//机构权限,查询机构下的所有网点
				limitSql += " and " + orgIdColumn + " = '" + currUser.getOrgId() + "' ";
			}else if(Constants.SYS_OPERATOR_LEVEL_ORGANALL == currUser.getDutyId()){
				String allOrgs = (String) this.findOnlyFieldBySql("select ltrim(max(sys_connect_by_path('''' || b.org_id || '''',',')),',')  from Sys_Organ b start with b.org_id = '" + currUser.getOrgId() + "' connect by prior b.customer_id = b.parent_org_id ");
				limitSql += " and " + orgIdColumn + " in (" + allOrgs + ") ";
					
			}else if(Constants.SYS_OPERATOR_LEVEL_ADMIN == currUser.getDutyId() ){
				limitSql += " and 1 = 1 ";
			}else{
				limitSql += " and " + orgIdColumn + " = '_erp2_erp2_' ";
			}
			SecurityUtils.getSubject().getSession().setAttribute("_Individuals_Limit_Query_org_",limitSql);
			return limitSql;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 根据证件号码,网点编号判断是否是同一统筹区域
	 * Description <p>TODO</p>
	 * @param certNo
	 * @param brchId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public boolean judgeRegion(String certNo,String brchId) throws CommonException{
		try{
			if(Tools.processNull(certNo).equals("")){
				throw new CommonException("证件号码不能为空！");
			}
			List<?> persons = this.findByHql("from BasePersonal where certNo = '" + certNo + "'");
			if(persons == null || persons.size() <= 0){
				throw new CommonException("客户信息不存在！");
			}
			if(persons.size() != 1){
				throw new CommonException("根据证件号码" + certNo + "查找到多条人员信息！");
			}
			BasePersonal bp = (BasePersonal) persons.get(0);
			List<BaseSiinfo> baseSiinfos =  this.findByHql("from BaseSiinfo where certNo = '" + bp.getCertNo() + "' and medState = '0'");
			if(baseSiinfos == null || baseSiinfos.size() <= 0){
				throw new CommonException("该人员参保信息不存在或参保状态不正常！");
			}
			if(baseSiinfos.size() > 1){
				throw new CommonException("该人员存在多条参保信息记录！");
			}
			BaseSiinfo baseSiinfo = baseSiinfos.get(0);
			if(Tools.processNull(baseSiinfo.getMedState()).equals(Constants.YES_NO_YES)){
				throw new CommonException("该人员参保状态不是【正常】状态！");
			}
			SysBranch brch = (SysBranch) this.findOnlyRowByHql("from SysBranch where brchId = '" + brchId + "'");
			if(Tools.processNull(brch.getRegionId()).equals("")){
				throw new CommonException("柜员所属网点的区域编号信息设置不正确！");
			}
			BaseRegion region = (BaseRegion) this.findOnlyRowByHql("from BaseRegion where regionId = '" + brch.getRegionId() + "'");
			if(region == null){
				throw new CommonException("根据网点所属区域编号" + brch.getRegionId() + "找不到区域信息");
			}
			if(Tools.processNull(region.getCityId()).equals("")){
				throw new CommonException("区域" + region.getRegionName() + "的统筹区域编号未设置！");
			}
			if(Tools.processNull(region.getCityId()).equals(baseSiinfo.getMedCertNo())){
				throw new CommonException("该人员不属于当前的统筹区域！无法办理相关业务！");
			}
			return true;
		}catch(Exception e){
			throw new CommonException("判断统筹区域出现错误" + e.getMessage());
		}
	}
	/**
	 * 
	 * Description <p>TODO</p>
	 * @return
	 * @throws CommonException
	 */
	public String getBrchRegion() throws CommonException{
		try{
			if(!Tools.processNull(SecurityUtils.getSubject().getSession().getAttribute("_brch_region_id_")).equals("")){
				return SecurityUtils.getSubject().getSession().getAttribute("_brch_region_id_").toString();
			}
			SysBranch brch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + this.getUser().getBrchId() + "'");
			if(brch == null){
				throw new CommonException("根据网点编号" + this.getUser().getBrchId() + "找不到网点信息！");
			}
			BaseRegion region = (BaseRegion) this.findOnlyRowByHql("from BaseRegion where regionId = '" + brch.getRegionId() + "'");
			if(region == null){
				throw new CommonException("根据网点所属区域编号" + brch.getRegionId() + "找不到区域信息！" );
			}
			SecurityUtils.getSubject().getSession().setAttribute("_brch_region_id_",region.getCityId());
			return region.getCityId();
		}catch(Exception e){
			throw new CommonException("获取网点统筹区域出现错误：" + e.getMessage());
		}
	}
	/**
	 * 根据证件号码判断该人员是否属于当前的统筹区域
	 * @param certNo  证件号码
	 * @return  true 返回true 验证成功
	 */
	@SuppressWarnings("unchecked")
	public boolean judgeRegion(String certNo) throws CommonException{
		try{
			if(Tools.processNull(certNo).equals("")){
				throw new CommonException("证件号码不能为空");
			}
			BigDecimal isExistPersonal = (BigDecimal) this.findOnlyFieldBySql("select count(1) from base_personal t where t.cert_no = '" + certNo + "'");
			if(isExistPersonal == null || isExistPersonal.longValue() <= 0){
				throw new CommonException("客户信息不存在");
			}
			if(isExistPersonal.longValue() != 1){
				throw new CommonException("根据证件号码" + certNo + "查找到多条人员信息");
			}
			SysBranch brch = (SysBranch) this.findOnlyRowByHql("from SysBranch where brchId = '" + this.getUser().getBrchId() + "'");
			if(Tools.processNull(brch.getRegionId()).equals("")){
				throw new CommonException("柜员所属网点的区域编号信息设置不正确");
			}
			BaseRegion region = (BaseRegion) this.findOnlyRowByHql("from BaseRegion where regionId = '" + brch.getRegionId() + "'");
			if(region == null){
				throw new CommonException("根据网点所属区域编号" + brch.getRegionId() + "找不到区域信息");
			}
			if(Tools.processNull(region.getCityId()).equals("")){
				throw new CommonException("区域" + region.getRegionName() + "的统筹区域编号未设置");
			}
			List<BaseSiinfo> baseSiinfos =  this.findByHql("from BaseSiinfo where certNo = '" + certNo + "' and id.medWholeNo = '" + region.getCityId() + "'");
			if(baseSiinfos == null || baseSiinfos.size() <= 0){
				throw new CommonException("该人员参保信息不存在，或参保信息不属于本区域");
			}
			if(baseSiinfos.size() > 1){
				throw new CommonException("该人员存在多条参保信息记录");
			}
			BaseSiinfo baseSiinfo = baseSiinfos.get(0);
			if(!Tools.processNull(baseSiinfo.getMedState()).equals(Constants.YES_NO_YES)){
				throw new CommonException("该人员参保状态不是【正常】状态");
			}
			if(!Tools.processNull(region.getCityId()).equals(baseSiinfo.getId().getMedWholeNo())){
				throw new CommonException("该人员不属于当前的统筹区域");
			}
			return true;
		}catch(Exception e){
			throw new CommonException(e.getMessage() + "，无法办理相关业务！");
		}
	}
	/**
	 * 同步社保信息
	 * @param taskId
	 * @param certNo
	 * @param cardNo1
	 * @param cardNo2
	 * @param dealNo
	 * @param applyType
	 * @throws CommonException
	 */
	public void saveSynch2CardUpate(String taskId,String certNo,String cardNo1,String cardNo2,Long dealNo,String applyType) throws CommonException{
		try{
			List inPara = new ArrayList();
			inPara.add(Tools.processNull(taskId));
			inPara.add(Tools.processNull(certNo));
			inPara.add(Tools.processNull(cardNo1));
			inPara.add(Tools.processNull(cardNo2));
			inPara.add(Tools.processNull(dealNo) + "");
			inPara.add(Tools.processNull(applyType));
			List outPara = new ArrayList();
			outPara.add(java.sql.Types.VARCHAR);
			outPara.add(java.sql.Types.VARCHAR);
			List out = publicDao.callProc("PK_CARD_APPLY_ISSUSE.P_SYNCH2CARD_UPATE",inPara,outPara);
			if(out == null && out.isEmpty()){
				throw new CommonException("同步社保信息出现错误！");
			}
			if(Integer.valueOf(out.get(0).toString()) != 0){
				throw new CommonException(out.get(1).toString());
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 校验柜员密码
	 */
	public boolean judgeOperPwd(String userId,String pwd) throws CommonException{
		try{
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("验证柜员密码，传入柜员编号不能为空！");
			}
			if(Tools.processNull(pwd).equals("")){
				throw new CommonException("验证柜员密码，传入柜员密码不能为空！");
			}
			Users user = (Users) this.findOnlyRowByHql("from Users t where t.status = 'A' and t.userId = '" + userId + "'");
			if(user == null){
				throw new CommonException("验证柜员密码失败，根据柜员编号" + userId + "未找到有效的柜员信息，或该柜员已注销！");
			}
			if(!Tools.processNull(user.getPassword()).equals(this.encrypt_des(pwd,Constants.APP_DES3_DEFAULT))){
				throw new CommonException("验证柜员密码失败，密码不正确！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return true;
	}
	
	/**
	 * 获取数据内容为字符串类型
	 * @param cell
	 * @return
	 */
	@SuppressWarnings("unused")
	public String getCellFormatValue(HSSFCell cell) {
		String strCell = "";
		switch (cell.getCellType()) {
		case HSSFCell.CELL_TYPE_STRING:
			strCell = cell.getStringCellValue();
			break;
		case HSSFCell.CELL_TYPE_NUMERIC:
			strCell = String.valueOf(cell.getNumericCellValue());
			break;
		case HSSFCell.CELL_TYPE_BOOLEAN:
			strCell = String.valueOf(cell.getBooleanCellValue());
			break;
		case HSSFCell.CELL_TYPE_BLANK:
			strCell = "";
			break;
		default:
			strCell = "";
			break;
		}
		if (strCell.equals("") || strCell == null) {
			return "";
		}
		if (cell == null) {
			return "";
		}
		return strCell;
	}
	/**
	 * @param region_Id 根据bs_region表的region_Id查找region_code用于非接卡卡号的2位区编码
	 * @param card_Type 根据card_Type获取不同的卡号段，表示在卡号中第七位，在sys_para中配置，以“CARDTYPE_”开头的配置
	 * @param deal_No 业务日志表SYS_ACTION_LOG的主键，不能为空
	 * @param size 本次获取卡号的数量
	 * @return 获取卡号
	 * @throws CommonException
	 */
	@SuppressWarnings("rawtypes")
	public List getCard_No(String region_Id,String region_Code,String card_Type,Long deal_No,int size)throws CommonException{
		try{
			BaseRegion region = (BaseRegion) this.findOnlyRowByHql("from BaseRegion where regionId = '" + region_Id + "'");
			if(region == null){
				throw new CommonException("根据区域编号" + region_Id + "找不到区域信息！");
			}
			if(Tools.processNull(region.getRegionCode()).equals("") || Tools.processNull(region.getRegionCode()).trim().length() != 2){
				throw new CommonException("区域" + region_Id + "的区编码设置不正确！");
			}
			createCardNo(card_Type,region.getRegionCode(),Long.valueOf(size + "") ,deal_No);
			List list = publicDao.findBySQL("SELECT CARD_NO FROM CARD_NO WHERE DEAL_NO = " + deal_No);
			if (list.size() != size){
				throw new CommonException("当前卡号获取数量不正确！");
			}
			return list;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 根据卡类型获取指定数量的卡号
	 * @param String cardType 卡类型
	 * @param Long num 卡数量
	 * @param Long actionNo 操作流水
	 */
	public synchronized Long createCardNo(String cardType,String regionCode,Long num,Long dealNo) throws CommonException  {
		try{
			if(Tools.processNull(cardType).equals("")){
				throw new CommonException("获取卡号出现错误，卡类型不能为空！");
			}
			if(Tools.processNull(regionCode).equals("")){
				throw new CommonException("获取卡号出现错误，区编号不能为空！");
			}
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("获取卡号出现错误，业务操作流水不能为空！");
			}
			if(Tools.processLong(num + "") < 1){
				throw new CommonException("获取卡号出现错误，获取卡数量参数必须大于1！");
			}
			String cityCode = (String) this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'CITY_CODE'");
			if(Tools.processNull(cityCode).trim().length() != 4){
				throw new CommonException("获取卡号失败，城市代码配置不正确！");
			}else{
				cityCode = Tools.tensileString(cityCode,4,true,"0");
			}
			String cardTypeCatalog = "";
			CardConfig config = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + cardType + "'");
			if(config == null){
				throw new CommonException("获取卡号失败，指定卡类型" + cardType + "，卡参数信息不存在！");
			}
			if(Tools.processNull(config.getCardTypeCatalog()).trim().equals("") || Tools.processNull(config.getCardTypeCatalog()).length() != 2){
				throw new CommonException("获取卡号失败，指定卡类型" + cardType + "，卡大类信息设置不正确！");
			}else{
				cardTypeCatalog = config.getCardTypeCatalog();
				if(cardTypeCatalog.length() == 1){
					cardTypeCatalog = "0" + cardTypeCatalog;
				}
			}
			//cardTypeCatalog = "10";
			String lock = Tools.processNull(this.findOnlyFieldBySql("SELECT BUSI_KEY FROM SYS_BUSI_LOCK K WHERE K.BUSI_KEY = '" + cityCode + regionCode + cardTypeCatalog + "'"));
			if(Tools.processNull(lock).equals("")){
				throw new CommonException("生成卡号业务锁未配置，请先联系系统管理员进行业务锁配置！");
			}
			try{
				publicDao.doSql("SELECT BUSI_KEY FROM SYS_BUSI_LOCK K WHERE K.BUSI_KEY = '" + cityCode + regionCode + cardTypeCatalog + "' FOR UPDATE WAIT 50");
			}catch(Exception e){
				if(Tools.processNull(e.getMessage()).toLowerCase().indexOf("ora-30006") > -1){
					throw new CommonException("业务锁被长久锁定，等待50秒内没有被释放，请稍候进行重试！");
				}else{
					throw new CommonException(e.getMessage());
				}
			}
			String tj = " CITY = '" + cityCode + "' AND CARD_CATALOG = '" + cardTypeCatalog + "' AND USED = '1' AND REGION_CODE = '" + regionCode + "' AND CARD_TYPE = '" + cardType + "' ";
			BigDecimal notUsedCount = (BigDecimal) this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_NO WHERE " + tj + " AND ROWNUM < " + (num + 1));
			if(notUsedCount.longValue() < num){
				createCard_No(cardType,regionCode,(int)(num - notUsedCount.longValue()));
			}
			notUsedCount = (BigDecimal) this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_NO WHERE " + tj + " AND ROWNUM < " + (num + 1));
			if(notUsedCount.longValue() < num){
				throw new CommonException("卡号数量不足，获取卡号失败！");
			}
			StringBuffer sb = new StringBuffer("MERGE INTO CARD_NO A USING ");
			sb.append("(SELECT CARD_NO FROM (SELECT CARD_NO FROM CARD_NO WHERE " + tj + " ORDER BY CARD_NO) WHERE ROWNUM < " + (num + 1) + ") b ");
			sb.append(" ON (A.CARD_NO = B.CARD_NO) ");
			sb.append(" WHEN MATCHED THEN ");
			sb.append(" UPDATE SET A.USED = 0,A.DEAL_NO = " + dealNo);
			sb.append(" WHERE " + tj);
			publicDao.doSql(sb.toString());
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return 0L;
	}
	/**
	 * 实时调取汤伟忠获取卡校验位
	 * @param city            城市代码
	 * @param card_catalog    卡号大类标示
	 * @param size            获取卡号数量
	 * @throws CommonException
	 */
	@SuppressWarnings({"rawtypes","unchecked" })
	public void createCard_No(String cardType,String regionCode,int size)throws CommonException{
		try{
			String cardCatalog = "";
			if(Tools.processNull(cardType).equals("")){
				throw new CommonException("获取卡号失败，卡类型不能为空！");
			}
			if(Tools.processNull(regionCode).equals("")){
				throw new CommonException("获取卡号失败，区编码不能为空！");
			}
			if(Tools.processNull(regionCode).length() != 2){
				throw new CommonException("获取卡号失败，区编码设置不正确！");
			}
			if(size < 1){
				throw new CommonException("获取卡号失败，设置的获取卡号数量不正确！");
			}
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + cardType + "'");
			if(cfg == null){
				throw new CommonException("获取卡号失败，编号为" + cardType + "的卡类型的卡参数信息未配置！");
			}
			if(Tools.processNull(cfg.getCardTypeCatalog()).length() != 2){
				throw new CommonException("获取卡号失败，" + cfg.getCardName() + "的卡大类信息配置不正确！");
			}else{
                cardCatalog = cfg.getCardTypeCatalog();
                if(cardCatalog.length() == 1){
                    cardCatalog = "0" + cardCatalog;
                }
			}
			//cardCatalog = "10";
			String cityCode = (String) this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'CITY_CODE'");
			if(Tools.processNull(cityCode).trim().equals("") || Tools.processNull(cityCode).length() != 4){
				throw new CommonException("获取卡号失败，城市代码配置不正确！");
			}
			String pwd = (String)publicDao.findOnlyFieldBySql("SELECT P.PARA_VALUE FROM SYS_PARA P WHERE P.PARA_CODE = 'TRADE_PWD_DEFAULT'");
			if(Tools.processNull(pwd).equals("")){
				throw new CommonException("联机账户默认密码未配置！");
			}
			int one_size = 1000;
			String curMaxCardno = Tools.processNull(this.findOnlyFieldBySql("SELECT MAX(SUBSTR(CARD_NO,1,16)) AS CUR_MAX_CARDNO "
			+ "FROM CARD_NO T WHERE T.CITY = '" + cityCode + "' AND T.CARD_CATALOG = '" + cardCatalog + "' AND T.REGION_CODE = '" + regionCode + "'"));
			/**如果不存在最大值,默认00000000 开始   城市代码(4) +地区代码(2)+ 卡大类(2) + 递增(8) + 校验位(4)*/
			if(Tools.processNull(curMaxCardno).equals("")){
				curMaxCardno = cityCode + regionCode + cardCatalog + "00000000";
			}
			Integer dosize = size > one_size ? one_size : size;
			List<Map> inListMap = new ArrayList<Map>();
			for(int i = 1;i <= dosize;i++){
				Map map = new HashMap();
				map.put("cardid",Tools.tensileString(Arith.add(curMaxCardno,i + ""),16,true,"0"));
				map.put("money", "0");
				map.put("psw", Tools.processNull(pwd));
				map.put("trcode",Sys_Code.ENCRYPT_SERVICE_CODE_CARDNO_VERIFYCODE);
				inListMap.add(map);
			}
			if(easyServiceClient == null){
				easyServiceClient = new EasyServiceStub();
			}
			EasyServiceStub.Invoke invoke = new EasyServiceStub.Invoke();
			invoke.setJson(JsonHelper.parseListMap2JSon(inListMap));
			easyServiceClient._getServiceClient().getOptions().setProperty(HTTPConstants.CHUNKED,"false");			
			String resMsg = easyServiceClient.Invoke(invoke).getInvokeResult();
			List<Map<String,Object>> outListMap = new ArrayList<Map<String, Object>>();
			outListMap = JsonHelper.parseJSON2ListMap(resMsg);
			Map map = new HashMap();
			StringBuffer exe_sb = new StringBuffer();
			String cardno = "",pin = "",money = "",errcode = "",psw = "";
			for(int k = 0;k < outListMap.size();k++){
				map = new HashMap();
				map = (Map)outListMap.get(k);
				errcode = Tools.processNull((String)map.get("errcode"));
				if(!Tools.processNull(errcode).equals("00")){
					continue;
				}
				cardno = Tools.processNull((String)map.get("cardno"));
				pin = Tools.processNull((String)map.get("pin"));
				money = Tools.processNull((String)map.get("money"));
				psw = Tools.processNull((String)map.get("psw"));
				if(Tools.processNull(cardno).length() == 20){
					exe_sb.append("'INSERT INTO CARD_NO(CITY,CARD_CATALOG,REGION_CODE,CARD_TYPE,CARD_NO,PWD,PWD_CRYPT,BAL_CRYPT) VALUES (''");
					exe_sb.append(cityCode + "'',''" + cardCatalog + "'',''" + regionCode + "'',''" + cardType + "'',''" + Tools.processNull(cardno) + "'',");
					exe_sb.append("''" + Tools.processNull(psw) + "'',''" + Tools.processNull(pin) + "'',''" + Tools.processNull(money) + "'')',");
				}else{
					logger.error(Tools.processNull("返回卡号存在：" + Tools.processNull(cardno) + "，长度不符合要求！"));
				}
				if((k + 1) % 500 == 0){
					publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + exe_sb.substring(0,exe_sb.length()-1) + "))");
					exe_sb = new StringBuffer();
					//publicDao.doSql("COMMIT");
				}
			}
			if(exe_sb != null && exe_sb.toString().length() > 0){
				publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + exe_sb.substring(0,exe_sb.length() - 1) + "))");
			}
			size = size - one_size;
			if(size > 0){
				createCard_No(cardType,regionCode,size);
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 调取汤伟忠统一接口--------------xml格式 
	 * @param code   交易代码
	 * @param list   参数信息 xml节点和节点属性
	 * @return       结果集
	 * @throws CommonException
	 */
	@SuppressWarnings({ "rawtypes","unchecked" })
	public List<Map> doWork(String code,List<Map> list)throws CommonException{
		String pwd=(String)publicDao.findOnlyFieldBySql("select p.para_value from sys_para p where p.para_code='TRADE_PWD_DEFAULT' ");
		Long startTime = System.currentTimeMillis();
		StringBuffer sb = new StringBuffer("<?xml version='1.0' encoding='UTF-8'?>");
		try{
			if(easyServiceClient == null){
				easyServiceClient = new EasyServiceStub();
			}
			EasyServiceStub.Execute execute = new EasyServiceStub.Execute();
			sb.append("<Fields>");
			Map map = null;
			for(int i = 0;i < list.size();i++){
				new HashMap();
				map = list.get(i);
				Iterator ite = map.keySet().iterator();
				while(ite.hasNext()){
					String key = Tools.processNull(ite.next());
					String cardnos=(String)map.get(key);
					String[] strcardno=cardnos.split(",");
					for(int j = 0;j < strcardno.length;j++){
						sb.append("<parms ");
						sb.append(" trcode=\""  + code + "\" ");
						sb.append(" money=\"0\" ");
						sb.append(" psw=\""+ Tools.processNull(pwd) +"\"  ");
						sb.append(" "+key + "=\"" + strcardno[j].toString() + "\" ");
						sb.append(">" + j + "</parms>");
					}
				}
			}
			map = null;
			list = null;
			sb.append("</Fields>");
			execute.setXml(sb.toString());
			easyServiceClient._getServiceClient().getOptions().setProperty(HTTPConstants.CHUNKED,"false");			
			String return_str = easyServiceClient.Execute(execute).getExecuteResult();//小汤返回的结果
			//开始构造返回数据
			List<Map> rt_map = new ArrayList<Map>();
			SAXBuilder saxb = new SAXBuilder();
			Document doc = saxb.build(new ByteArrayInputStream(return_str.getBytes("UTF-8")));   
			Element root = doc.getRootElement();
			Map param_map = new HashMap();
			List e_param_name_list = new ArrayList();
			List param = root.getChildren("parms");
			for(int j = 0;j < param.size();j++){
				Element param_e = (Element)param.get(j);//每一个parm对应的节点
				param_map.clear();
				e_param_name_list = param_e.getAttributes();//每一个parm对应的节点的所有Attribute属性
				for(int k = 0;k < e_param_name_list.size();k++){
					org.jdom.Attribute abt = (org.jdom.Attribute)e_param_name_list.get(k);
					param_map.put(abt.getName(),abt.getValue());
					abt = null;
				}
				e_param_name_list = null;
				rt_map.add(Integer.valueOf(param_e.getText()).intValue(),param_map);
				if(!Tools.processNull(param_map.get("errcode")).equals("00")){
					logger.info("("+code+")发生失败，入参：" + sb.toString() + "。出参：" + param_map.toString());
				}
			}
			param = null;
			return rt_map;
		}catch (Exception e){
			if(Tools.processNull(e.getMessage()).startsWith("org.apache.axis2.AxisFault")){
				throw new CommonException("前置系统正在启动中");
			}
			throw new CommonException(e);
		}finally{
			Long endTime = System.currentTimeMillis();
			if((endTime - startTime) / 1000 > 10){
				logger.info("执行时间为" + (endTime-startTime) / 1000 + "秒，需小汤优化，入参如下：\r\n" + sb.toString());
			}
		}
	}

	/**
	 * 调取汤伟忠统一接口--------------json格式 
	 * @param code   交易代码
	 * @param list   参数信息 xml节点和节点属性
	 * @return       结果集
	 * @throws CommonException
	 */
	@SuppressWarnings({ "rawtypes","unchecked" })
	public List<Map<String, Object>> getJosn(String code,List<Map> list)throws CommonException{
		Long startTime = System.currentTimeMillis();
		StringBuffer sb = new StringBuffer(512);
		try{
			String pwd=(String)publicDao.findOnlyFieldBySql("select p.para_value from sys_para p where p.para_code='TRADE_PWD_DEFAULT' ");
			if(easyServiceClient == null){
				easyServiceClient = new EasyServiceStub();
			}
			EasyServiceStub.Invoke invoke = new EasyServiceStub.Invoke();
			Map map = new HashMap();
		    List<Map> mapList = new ArrayList<Map>();
			for(int i = 0;i < list.size();i++){
				map = list.get(i);
				Iterator ite = map.keySet().iterator();
				while(ite.hasNext()){
					String key = Tools.processNull(ite.next());
					String cardnos=(String)map.get(key);
					String[] strcardno=cardnos.split(",");
					Map p=new HashMap();
					for(int j = 0;j < strcardno.length;j++){
						p=new HashMap();
						p.put("money", "0");
						p.put("trcode", code);
						p.put("cardid", strcardno[j].toString());
						p.put("psw", Tools.processNull(pwd));
						mapList.add(p);
					}
				}
			}
			
			list = null;
			invoke.setJson(JsonHelper.parseListMap2JSon(mapList));
			easyServiceClient._getServiceClient().getOptions().setProperty(HTTPConstants.CHUNKED,"false");			
			String jsonStr = easyServiceClient.Invoke(invoke).getInvokeResult();//小汤返回的结果
			//开始构造返回数据
			List<Map<String, Object>> rt_map = new ArrayList<Map<String, Object>>();
			rt_map=JsonHelper.parseJSON2ListMap(jsonStr);
			return rt_map;
		}catch (Exception e){
			if(Tools.processNull(e.getMessage()).startsWith("org.apache.axis2.AxisFault")){
				throw new CommonException("前置系统出现异常");
			}
			throw new CommonException(e);
		}finally{
			Long endTime = System.currentTimeMillis();
			if((endTime - startTime) / 1000 > 10){
				logger.info("执行时间为" + (endTime-startTime) / 1000 + "秒，需小汤优化，入参如下：\r\n" + sb.toString());
			}
		}
	}

	
	
	public synchronized void initStkStockTypeList(){
		if(stockTypeList==null){
			try {
				stockTypeList = new ArrayList();
				stockTypeList=findByHql("from Stk_Stock_Type s");
			} catch (Exception e) {}
		}
	}
	/**
	 * 获取库存代码 
	 * @param stkCode
	 * @return
	 */
	public StockType getStockTypeByStkCode(String stkCode){
		initStkStockTypeList();
		for(int i=0;i<stockTypeList.size();i++){
			StockType stocktype = (StockType)stockTypeList.get(i);
			if(Tools.processNull(stocktype.getStkCode()).equals(stkCode))
				return stocktype;
		}
		throw new CommonException("通过库存代码'"+stkCode+"'找不到库存种类实体");
	}
	
	/**
	 * 通过卡类型来获得库存代码
	 */
	public String getStkCodeByCardType(String cardtype){
		return (getCardparaByCardType(cardtype)).getStkCode();
	}
	/**
	 * 通过卡类型来获得卡业务参数对象
	 */
	public CardConfig getCardparaByCardType(String cardtype){
		initCardparaList();
		for(int i=0;i<cardparaList.size();i++){
			CardConfig para = (CardConfig)cardparaList.get(i);
			if(Tools.processNull(para.getCardType()).equals(cardtype))return para;
		}
		throw new CommonException("通过卡类型'"+cardtype+"'来找不到卡业务参数对象");
	}
	/**
	 * 通过库存代码来获得卡业务参数对象
	 */
	public CardConfig getCardparaByStkCode(String stkcode){
		initCardparaList();
		for(int i=0;i<cardparaList.size();i++){
			CardConfig para = (CardConfig)cardparaList.get(i);
			if(Tools.processNull(para.getStkCode()).equals(stkcode))return para;
		}
		throw new CommonException("通过库存代码'"+stkcode+"'来找不到卡业务参数对象");
	}
	
	public synchronized void initCardparaList(){
		if(cardparaList==null){
			try {
				cardparaList=this.findByHql("from CardConfig c ");
			} catch (Exception e) {
				logger.error(e.getMessage());
			}
		}
	}
	/**
	 * 根据柜员编号、密码查询柜员
	 * @param oper_Id
	 * @param pwd
	 * @return
	 * @throws CommonException
	 */
	public Users findOperByOperId(String userId, String pwd) throws CommonException {
		try {
			String hql = "from Users s where s.userId='" + userId + "'";
			hql += SqlTools.eq("pwd", pwd);
			return (Users) this.findOnlyRowByHql(hql);
		} catch (Exception e) {
			throw new CommonException("根据柜员编号、密码查询柜员信息失败！", e);
		}
	}
	
	/**
	 * 通过库存代码来获得卡类型
	 */
	public String getCardTypeByStkCode(String stkcode){
		initCardparaList();
		for(int i=0;i<cardparaList.size();i++){
			CardConfig para = (CardConfig)cardparaList.get(i);
			if(Tools.processNull(para.getStkCode()).equals(stkcode))return para.getCardType();
		}
		throw new CommonException("通过库存代码'"+stkcode+"'找不到卡类型");
	}

	/* (non-Javadoc)
	 * @see com.erp.service.BaseService#getDateBaseDateStr()
	 */
	@Override
	public String getDateBaseDateStr() throws CommonException {
		return publicDao.getDateBaseTimeStr();
	}
	/**
	 * 获取FTP配置信息
	 * @param ftp_use
	 * @return map 参数信息
	 * @param host_ip 主机地址
	 * @param host_port 端口号
	 * @param host_upload_path 上传路径
	 * @param host_download_path 下载路径
	 * @param host_history_path 历史目录
	 * @param user_name 用户名
	 * @param pwd 密码
	 */
	public Map<String,String> initFtpOptions(String ftp_use) throws CommonException {
		try{
			Map<String,String> res = new HashMap<String, String>();
			List<?> ftpPara = this.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '" + ftp_use + "'");
			if(ftpPara == null || ftpPara.size() <= 0){
				throw new CommonException("获取ftp配置出错，请联系系统管理员！");
			}
			for(int k = 0;k < ftpPara.size();k++){
				Object[] objs = (Object[])ftpPara.get(k);
				if(Tools.processNull(objs[0]).equals("host_ip")){
					res.put("host_ip",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_upload_path")){
					res.put("host_upload_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_download_path")){
					res.put("host_download_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_history_path")){
					res.put("host_history_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_port")){
					res.put("host_port",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("pwd")){
					res.put("pwd",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("user_name")){
					res.put("user_name",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("black")){
					res.put("black",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("zxcktqx")){
					res.put("zxcktqx",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("medwholeno")){
					res.put("medwholeno",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_repeat_path")){
					res.put("host_repeat_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_err_path")){
					res.put("host_err_path",Tools.processNull(objs[1]));
				}
			}
			return res;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 检查ＦＴＰ配置信息
	 * @param ftpOptions ftp配置信息
	 * @return ＦＴＰ客户端
	 * @throws CommonException
	 */
	public DefaultFTPClient checkFtp(Map<String,String> ftpOptions) throws Exception{
		DefaultFTPClient client = null;
		if(Tools.processNull(ftpOptions.get("host_ip")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp地址未配置，请联系系统管理员！");
		}else{
			logger.error("host_ip:" + ftpOptions.get("host_ip"));
		}
		if(Tools.processNull(ftpOptions.get("host_port")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp端口未配置，请联系系统管理员！");
		}else{
			logger.error("host_port:" + ftpOptions.get("host_port"));
		}
		if(Tools.processNull(ftpOptions.get("user_name")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp用户名未配置，请联系系统管理员！");
		}else{
			logger.error("user_name:" + ftpOptions.get("user_name"));
		}
		if(Tools.processNull(ftpOptions.get("pwd")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp密码未配置，请联系系统管理员！");
		}else{
			logger.error("pwd:" + ftpOptions.get("pwd"));
		}
		client = new DefaultFTPClient();
		if(!client.toConnect(ftpOptions.get("host_ip"),Integer.valueOf(ftpOptions.get("host_port")))){
			throw new CommonException("FTP连接失败！");
		}else{
			logger.error("FTP连接正常");
		}
		if(!client.toLogin(ftpOptions.get("user_name"),ftpOptions.get("pwd"))){
			throw new CommonException("FTP登录失败！");
		}else{
			logger.error("FTP登录正常");
		}
		client.setControlEncoding("GBK");
		client.setFileTransferMode(DefaultFTPClient.STREAM_TRANSFER_MODE);
		client.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
		return client;
	}
	
	/**
	 * DES加密。
	 * @param data
	 * @param key
	 * @return
	 */
	@Override
	@SuppressWarnings("unchecked")
	public String encrypt_des(String data, String key) {
		List<Object> inParameters = new ArrayList<Object>();
		inParameters.add(data);
		inParameters.add(key);
		List<Object> outParameters = new ArrayList<Object>();
		outParameters.add(java.sql.Types.VARCHAR);
		List<Object> result = publicDao.callProc("encrypt_des_oracle_java", inParameters, outParameters);
		if (result != null && result.size() > 0) {
			return result.get(0).toString();
		}
		throw new CommonException("调用加密存储过程发生错误！");
	}
	
	/**
	 * DES解密。
	 * @param data
	 * @param key
	 * @return
	 */
	@Override
	@SuppressWarnings("unchecked")
	public String decrypt_des(String data, String key) {
		List<Object> inParameters = new ArrayList<Object>();
		inParameters.add(data);
		inParameters.add(key);
		List<Object> outParameters = new ArrayList<Object>();
		outParameters.add(java.sql.Types.VARCHAR);
		List<Object> result = publicDao.callProc("decrypt_des_oracle_java", inParameters, outParameters);
		if (result != null && result.size() > 0) {
			return result.get(0).toString();
		}
		throw new CommonException("调用加密存储过程发生错误！");
	}
	
	public Object xml2java(String xmlStr, String objName, Class cls) throws Exception {
		//这个替换首字母大写的代码，原因是由于使用betwixt工具转成java类对象时，这个变量值丢失，可能是betwixt工具的bug，
		//因此以后定义变量时，首字母小写的部分一定至少是两个小写字母，如pCount就声明成ppCount。
		xmlStr=xmlStr.replaceAll("<pCount>","<PCount>").replaceAll("</pCount>","</PCount>");
		Object retObject=XmlBeanUtil.xml2java(xmlStr,objName,cls);
		return retObject;
	}
	/**
	 * 传入XML格式字符串转换为java对象
	 */
	public Object xml2java(String method,String xmlStr, String objName, Class cls) throws Exception {
		//这个替换首字母大写的代码，原因是由于使用betwixt工具转成java类对象时，这个变量值丢失，可能是betwixt工具的bug，
		//因此以后定义变量时，首字母小写的部分一定至少是两个小写字母，如pCount就声明成ppCount。
		xmlStr=xmlStr.replaceAll("<pCount>","<PCount>").replaceAll("</pCount>","</PCount>");
		Object retObject=XmlBeanUtil.xml2java(xmlStr,objName,cls);
		writeLog(method,xmlStr);
		return retObject;
	}
	/**
	 * 所有请求参数写文件（包括请求的方法名和请求的参数内容）
	 */
	private void writeLog(String method,String xmlStr) throws CommonException{
		//System.out.println(content);
		//获取操作系统名称   
		String operation = System.getProperty("os.name").toUpperCase(Locale.ENGLISH);    
		//判断是否是AIX的   
		if (operation.indexOf("AIX") != -1){
			try{
				xmlStr = new String(xmlStr.getBytes("GBK"), "ISO8859_1");
			}catch(Exception e){
				System.out.println (e.getMessage());
			}
		}
		try{
		   File write = new File("webserivce_"+DateUtil.getNowDate()+".log");
		   FileWriter fw = new FileWriter(write,true);
		    //写文件
		   fw.write(DateUtil.getNowTime() + "---" + method + "\r\n");
		   fw.write(DateUtil.getNowTime() + "---" + xmlStr + "\r\n");
		   fw.close();
		}catch(Exception e){
			System.out.println (e.getMessage());
		}
	}
	/**
	 * java对象转换为XML格式字符串
	 */
	public String java2xml(Object inBean) throws Exception {
		return XmlBeanUtil.java2xml(inBean);//.replaceAll("<data>","<Data>").replaceAll("</data>","</Data>");
	}
	
}
