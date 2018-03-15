package com.erp.serviceImpl;

import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.axis2.context.MessageContext;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.BasePersonal;
import com.erp.model.BasePhoto;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardApplySb;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysErrLog;
import com.erp.model.TrServRec;
import com.erp.service.CardApplyService;
import com.erp.service.NetAppOfSbService;
import com.erp.util.Base64;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.ExportExcel;
import com.erp.util.ResourceUtil;
import com.erp.util.Tools;
import com.erp.viewModel.KanwuExecelView;
import com.erp.viewModel.Page;
import com.erp.webservice.server.bean.BankAccInfo;
import com.erp.webservice.server.bean.Data;
import com.erp.webservice.server.bean.InNetRequestBean;
import com.erp.webservice.server.bean.RequestBean;
import com.erp.webservice.server.bean.ResponseBean;
@Service("netAppOfSbService")
public class NetAppOfSbServiceImpl extends BaseServiceImpl implements  NetAppOfSbService {
	private static String absoluteDownloadPath = ResourceUtil.getDownloadDirPath();
	
	@Autowired
	private CardApplyService cardApplyService;
	
	private String methodName;
	/**
	 * 查询统计      -------1007
	 * @param inXml
	 * @return
	 * @throws CommonException//注：查询从 已申报到已发放的所有数据
	 */

	public String savetongjiquery(String inXml) throws CommonException {
		try {
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			String sql1 ="select count(*) from Card_Apply_Sb a where  a.companyId = '"+reqBean.getCompanyId()+"' and a.sb_Apply_State = '00'";
			String sql2 ="select count(*) from Card_apply a,Base_Corp s,Base_Personal p where a.customer_Id=p.customer_Id and p.corp_Customer_Id=s.customer_Id and s.companyId = '"+reqBean.getCompanyId()+"' and a.apply_state in('00','10','20')";
			String sql3 ="select count(*) from Card_apply a,Base_Corp s,Base_Personal p where a.customer_Id=p.customer_Id and p.corp_Customer_Id=s.customer_Id and s.companyId = '"+reqBean.getCompanyId()+"' and a.apply_state in('30','40')";
			String sql4 ="select count(*) from Card_apply a,Base_Corp s,Base_Personal p where a.customer_Id=p.customer_Id and p.corp_Customer_Id=s.customer_Id and  s.companyId = '"+reqBean.getCompanyId()+"' and a.apply_state='50'";
			String sql5 ="select count(*) from Card_apply a,Base_Corp s,Base_Personal p where a.customer_Id=p.customer_Id and p.corp_Customer_Id=s.customer_Id and  s.companyId = '"+reqBean.getCompanyId()+"' and a.apply_state='60'";
			
			Long totCount1=((BigDecimal)findOnlyFieldBySql(sql1)).longValue();
			Long totCount2=((BigDecimal)findOnlyFieldBySql(sql2)).longValue();
			Long totCount3=((BigDecimal)findOnlyFieldBySql(sql3)).longValue();
			Long totCount4=((BigDecimal)findOnlyFieldBySql(sql4)).longValue();
			Long totCount5=((BigDecimal)findOnlyFieldBySql(sql5)).longValue();

			Data data1 =new Data();
			data1.setSbqueryCount(totCount1);
			data1.setApplyState("已申报");
			Data data2 =new Data();
			data2.setSbqueryCount(totCount2);
			data2.setApplyState("制卡中");
			Data data3 =new Data();
			data3.setSbqueryCount(totCount3);
			data3.setApplyState("已制卡");
			Data data4 =new Data();
			data4.setSbqueryCount(totCount4);
			data4.setApplyState("已接收");
			Data data5 =new Data();
			data5.setSbqueryCount(totCount5);
			data5.setApplyState("已发放");
			datas.add(data1);
			datas.add(data2);
			datas.add(data3);
			datas.add(data4);
			datas.add(data5);
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 根据状态分别查询从已申报到发放的人员信息------ 1001
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savequeryyzk(String inXml) throws CommonException {
		try {
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			String head="";
			String hql="";
			if(!Tools.processNull(reqBean.getApplyState()).equals("")&& reqBean.getApplyState().equals("00")){
				 head = "select tt.*,rownum rn from (select p.customer_Id,p.name,p.cert_No,p.corp_Customer_Id,s.corp_Name,p.mobile_No,p.letter_addr,a.sb_apply_state,a.apply_date ";
				 hql = " from Base_Personal p, Base_Corp s,Card_Apply_Sb a where p.corp_Customer_Id = s.customer_Id  and p.cert_No = a.cert_no and  a.companyId = '"+reqBean.getCompanyId()+"' and a.sb_apply_state='00'" ;
			}else{
				head =" select tt.*,rownum rn from (select p.customer_Id,p.name,p.cert_No,p.corp_Customer_Id,s.corp_Name,p.mobile_No,p.letter_addr,a.apply_state,a.apply_date ";
				hql = " from Base_Personal p, Base_Corp s,Card_apply a where p.corp_Customer_Id = s.customer_Id  and p.customer_Id = a.customer_Id(+) and " ;
				hql += " exists (select c.customer_Id from Card_Apply c where c.customer_Id = p.customer_Id) ";
				if(!Tools.processNull(reqBean.getCompanyId()).equals(""))
					hql += " and  s.companyId = '"+reqBean.getCompanyId()+"'";
				if(!Tools.processNull(reqBean.getApplyState()).equals("")){
					if(Tools.processNull(reqBean.getApplyState()).equals("012")){
						hql += " and  a.apply_state in ('00','10','20')";
					}else if(Tools.processNull(reqBean.getApplyState()).equals("34")){
						hql += " and  a.apply_state in ('30','40')";
					}else if(Tools.processNull(reqBean.getApplyState()).equals("5")){
						hql += " and  a.apply_state ='50'";
					}else if(Tools.processNull(reqBean.getApplyState()).equals("6")){
						hql += "and  a.apply_state ='60'";
					}
				}
			}
			if(!Tools.processNull(reqBean.getCertNo()).equals(""))
				hql += "and p.cert_no='"+reqBean.getCertNo()+"'";
			if(!Tools.processNull(reqBean.getXmName()).equals(""))
				hql += "and p.name='"+reqBean.getXmName()+"'";
			hql += " ) tt";
			Long totCount=((BigDecimal)findOnlyFieldBySql("select count(*) from ("+head+hql+")")).longValue();
			List<Object[]> list = this.findBySql("select * from ("+head+hql+" where rownum<="+reqBean.getPCount()*reqBean.getPageNo()+") where rn>"+(reqBean.getPageNo()-1)*reqBean.getPCount());
			if(list!=null&&list.size()>0){
				for(Object[] obj:list){
					Data data = new Data();
					data.setClientId(Tools.processNull(obj[0]));//个人客户编号
					data.setXmName(Tools.processNull(obj[1]));//个人客户姓名
					data.setCertNo(Tools.processNull(obj[2]));//证件号码
					data.setEmpId(Tools.processNull(obj[3]));//单位id
					data.setEmpName(Tools.processNull(obj[4]));//单位名称
					data.setTelNo(Tools.processNull(obj[5]));//联系电话
					data.setLetterAddr(Tools.processNull(obj[6]));//联系地址
					data.setApplyState(Constants.getUnApplyState(Tools.processNull(obj[7])));//申领状态
					data.setApplyDate(Tools.processNull(obj[8]));//申领时间
					datas.add(data);
				}
			}
			return createReturnXml(new ResponseBean("0","",totCount,datas), getMethodName(1),true,reqBean);
		}catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 查询未申报人员信息-------1005
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savequerywzk(String inXml) throws CommonException {//查询未制卡人员信息1005
		try {
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			String head ="select tt.*,rownum rn from (select p.customer_Id,p.name,p.cert_No,p.corp_Customer_Id,s.corp_Name,p.mobile_No,p.letter_addr,a.apply_state ";
			String hql = "from Base_Personal p, Base_Corp s,Card_apply a  where  p.corp_Customer_Id = s.customer_Id and p.customer_Id = a.customer_Id(+) and " ;
			hql += " not exists (select c.customer_Id from Card_Apply c where c.customer_Id = p.customer_Id) ";
			hql +=" and not exists (select cert_no from Card_apply_Sb i where i.sb_apply_state='00' and p.cert_no=i.cert_no )";
			if(!Tools.processNull(reqBean.getCompanyId()).equals(""))
				hql += "and  s.companyId = '"+reqBean.getCompanyId()+"'";
			if(!Tools.processNull(reqBean.getCertNo()).equals(""))
				hql += "and p.cert_no='"+reqBean.getCertNo()+"'";
			if(!Tools.processNull(reqBean.getXmName()).equals(""))
				hql += "and p.name='"+reqBean.getXmName()+"'";
			hql += " ) tt";
			String xu = head+hql;
			Long totCount=((BigDecimal)findOnlyFieldBySql("select count(*) from ("+xu+")")).longValue();
			List<Object[]> list = this.findBySql("select * from ("+head+hql+" where rownum<="+reqBean.getPCount()*reqBean.getPageNo()+") where rn>"+(reqBean.getPageNo()-1)*reqBean.getPCount());
			if(list!=null&&list.size()>0){
				for(Object[] obj:list){
					Data data = new Data();
					BasePhoto photo=(BasePhoto)this.findOnlyRowByHql(" from  BasePhoto o where o.customerId='"+obj[0].toString()+"'");
					if (photo !=null && !Tools.processNull(photo.getPhoto()).equals("")){ 
    					data.setPhoto(Base64.encodeBytes(Base64.blobToBytes(photo.getPhoto())));
    					data.setPhotoExist("有照片");
					}else{
						data.setPhotoExist("无照片");
					}
					data.setClientId(Tools.processNull(obj[0]));//个人客户编号
					data.setXmName(Tools.processNull(obj[1]));//个人客户姓名
					data.setCertNo(Tools.processNull(obj[2]));//证件号码
					data.setEmpId(Tools.processNull(obj[3]));//单位id
					data.setEmpName(Tools.processNull(obj[4]));//单位名称
					data.setTelNo(Tools.processNull(obj[5]));//联系电话
					data.setLetterAddr(Tools.processNull(obj[6]));//联系地址
					data.setApplyState(Tools.processNull(obj[7]));//申领状态s
					//data.setPhotoState(Tools.processNull(obj[8]));//是否有照片
					datas.add(data);
				}
			}
			return createReturnXml(new ResponseBean("0","",totCount,datas), getMethodName(1),true,reqBean);
		}catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 更新保存个人照片1003
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String updateapplyphoto(String inXml) throws CommonException {
		ArrayList datas = new ArrayList();
		InNetRequestBean reqBean;
		try {
			reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal b where b.certNo='"+reqBean.getCertNo()+"'");
			if(person!=null){
				List<BasePhoto> photoList = publicDao.find("from BasePhoto where customerId='"+person.getCustomerId()+"'");
				byte[] ingByte = Base64.decode(reqBean.getPhoto());
				if(photoList!=null&&photoList.size()>0){
					publicDao.updatePhotoImg(photoList.get(0),ingByte);
				}else{
					BasePhoto photo=new BasePhoto();
					photo.setCustomerId(person.getCustomerId()+"");
					photo.setPhotoState("0");
					publicDao.savePhotoImg(photo,ingByte);
				}
			}else {
				throw new CommonException("未找到该人员！");
			}
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}

	/**
	 * 更新个人信息和修改确认标志----1004
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String updatesureFlag(String inXml) throws CommonException {
		try {
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal t where t.certNo='"+reqBean.getCertNo()+"'");
			if(Tools.processNull(person.getCertNo()).equals("")){
				throw new CommonException("根据身份证号没有找到相应信息！");
			}
			person.setMobileNo(reqBean.getMobileNo());
			person.setPhoneNo(reqBean.getTelNo());
			person.setLetterAddr(reqBean.getLetterAddr());
			person.setSureFlag(reqBean.getSureFlag());
			publicDao.merge(person);
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 保存网上申报数据录入卡管系统数据库-确认申报1002
	 * @param inXml
	 * @return
	 * @throws CommonException 注：不能重复申报，表里面状态为正常的数据一个身份证只能有1条，状态为撤销的数据一个身份证可以有N条
	 */
	@SuppressWarnings("unchecked")
	public String saveapplyinfo(String inXml) throws CommonException {
		try {
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			CardApplySb sbapp = (CardApplySb)this.findOnlyRowByHql("from CardApplySb t where t.certNo='"+reqBean.getCertNo()+"' and  t.sbApplyState='00' ");
			if(sbapp==null){
				BaseCorp emp = (BaseCorp) this.findOnlyRowByHql("from BaseCorp e where e.companyid='"+reqBean.getCompanyId()+"' ");
				if(emp!=null){
					if(Tools.processNull(emp.getLkBrchId()).equals("")){
						throw new CommonException("你未选择领卡网点，需至联合办公点市民卡窗口输手续！");
					}
				}
				//Card_Baseinfo_Apply这里制卡表里面有待控制，已经有制卡任务的卡不能再申报，注销的卡是否可以再申报？
				BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal t where t.certNo='"+reqBean.getCertNo()+"' and t.name='"+Tools.processNull(reqBean.getXmName())+"' ");
				if(person==null){
					throw new CommonException("根据身份证姓名没有找到人员信息！");
				}
				person.setSureFlag("0");
				publicDao.update(person);
				BaseSiinfo siinfo = (BaseSiinfo) this.findOnlyRowByHql("from BaseSiinfo s where s.certNo='"+reqBean.getCertNo()+"' ");
				if(Tools.processNull(siinfo.getCertNo()).equals("")){
					throw new CommonException("根据身份证号没有找到社保信息！");
				}
				siinfo.setMedState("0");
				publicDao.update(siinfo);
				
				publicDao.doSql(" insert into card_apply_sb(companyid,emp_id,emp_name, cert_no,name,apply_date,apply_name,recv_brch_id,apply_pici, sb_apply_state, sb_apply_id)" +
						"values('"+reqBean.getCompanyId()+"','"+emp.getCustomerId()+"','"+emp.getCorpName()+"','"+reqBean.getCertNo()+"','"+Tools.processNull(reqBean.getXmName())+"', sysdate," +
						"'','"+Tools.processNull(reqBean.getRecvBrchId())+"','','00',SEQ_SB_APPLY_ID.NEXTVAL) ");
			}else {
				throw new CommonException("该人员已申报，不能重复申报！");
			}
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 撤销申报(回退)//要根据身份证和状态查找这条数据，别把已撤销的数据查进来
	 * @param inXml
	 * @return
	 * @throws CommonException//注：
	 */
	public String savechexiaoapply(String inXml) throws CommonException {
		try {
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			CardApplySb sbapp = (CardApplySb)this.findOnlyRowByHql("from CardApplySb t where t.certNo='"+reqBean.getCertNo()+"' and t.sbApplyState='00'");//注意：万一手动插入1条数据，一个身份证有2条正常数据，就会报错（身份证不唯一）
			if(sbapp==null){
				throw new CommonException("申报记录不存在，或该记录已经撤销！");
			}
			sbapp.setSbApplyState("01");
			publicDao.merge(sbapp);
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	
	/**
	 * 打印领卡单 1008
	 * 
	 * @param inXml
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String savelingkadan(String inXml) throws CommonException {
		try {
			InNetRequestBean reqBean = (InNetRequestBean) this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getCompanyId()).equals("")) {
				throw new CommonException("社保单位编码为空！");
			}
			//
			String hql = "from BaseCorp t where t.companyid = '" + reqBean.getCompanyId() + "' ";
			if (!Tools.processNull(reqBean.getRegionId()).equals("")) {
				hql += "and regionId = '" + reqBean.getRegionId() + "'";
			}
			List<BaseCorp> corps = findByHql(hql);
			if (corps == null || corps.isEmpty()) {
				throw new CommonException("单位不存在！");
			} else if (corps.size() > 1) {
				if(Tools.processNull(reqBean.getRegionId()).equals("")){
					throw new CommonException("根据单位编号【" + reqBean.getCompanyId() + "】查询到多个单位，请输入单位区域编号！");
				} else {
					throw new CommonException("根据区域【" + reqBean.getRegionId() + "】，单位编号【" + reqBean.getCompanyId() + "】查询到多个单位，请联系系统管理人员！");
				}
			}
			//
			String sql = "select tt.*, rownum rn from (";
			sql += "select s.corp_Name, to_char(c.task_date, 'yyyy-mm-dd hh24:mi:ss'), c.task_sum, c.make_batch_id, c.task_id, "
					+ "(select t.name from Card_task_list t where t.task_id = c.task_id and rownum <= 1) as name,"
					+ "(select full_name from sys_branch where brch_id = c.brch_id) lkBrchName, c.corp_id ";
			sql += "from card_apply_task c, base_corp s where c.corp_Id = s.customer_id and s.companyId = '" + reqBean.getCompanyId() + "' ";
			if (!Tools.processNull(reqBean.getRegionId()).equals("")) {
				sql += "and s.region_id = '" + reqBean.getRegionId() + "' ";
			}
			if (!Tools.processNull(reqBean.getStartDate()).equals("")) {
				sql += "and c.task_date >= to_date('" + reqBean.getStartDate() + "','yyyy-MM-dd HH24:mi:ss') ";
			}
			if (!Tools.processNull(reqBean.getEndDate()).equals("")) {
				sql += "and c.task_date <= to_date('" + reqBean.getEndDate() + "','yyyy-MM-dd HH24:mi:ss') ";
			}
			sql += "order by c.task_date desc) tt";
			//
			Long totCount = ((BigDecimal) findOnlyFieldBySql("select count(*) from (" + sql + ")")).longValue();
			List<Object[]> list = this.findBySql("select * from (" + sql + " where rownum<=" + reqBean.getPCount() * reqBean.getPageNo() + ") where rn>" + (reqBean.getPageNo() - 1) * reqBean.getPCount());
			if (list == null || list.isEmpty()) {
				throw new CommonException("单位无规模申领记录！");
			}
			ArrayList<Data> datas = new ArrayList<Data>();
			for (Object[] obj : list) {
				Data data = new Data();
				data.setEmpId(Tools.processNull(obj[7]));// 单位编号
				data.setLkBrchName(Tools.processNull(obj[6]));// 领卡网点
				data.setEmpName(Tools.processNull(obj[0]));// 单位名称
				data.setTaskDate(Tools.processNull(obj[1]));// 任务生成时间
				data.setTaskSum(Tools.processNull(obj[2]));// 任务总数
				data.setMakeBatchId(Tools.processNull(obj[3]));// 批次号
				data.setTaskId(Tools.processNull(obj[4]));// 任务号
				data.setXmName(Tools.processNull(obj[5]));// 名字
				datas.add(data);
			}
			return createReturnXml(new ResponseBean("0", "", totCount, datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	
	public String getMethodName() {
		return methodName;
	}

	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}
	public String getMethodName(int i) {
		methodName=new Exception().getStackTrace()[i].getClassName()+"["+new Exception().getStackTrace()[i].getMethodName()+"]";
		return methodName;
	}
	public String createReturnXml(ResponseBean resBean, String methodName, boolean isActionLog, RequestBean reqBean) throws CommonException {
		try {
			String clientIp="";//客户端IP
			//记业务日志，对于查询的一些接口，业务方法并没有主动记日志，不便于以后查询，因此需要手工记日志
			if(isActionLog){
				//dao.insert(createActionlog("", Tools.processNull(reqBean.getOperId()), methodName,reqBean));
			}
			//记错误日志
			if ("1".equals(resBean.getResult())) {
//				if(resBean.getMessage().indexOf("com.zt.common.CommonException:")==0)
//					resBean.setMessage(resBean.getMessage().substring("com.zt.common.CommonException:".length()+1));
				resBean.setMessage(resBean.getMessage());
				resBean.seteCode("0000");
				SysErrLog errlog = new SysErrLog();
				errlog.setUserId("admin");
				errlog.setErrTime(new Timestamp(publicDao.getDateBaseTime().getTime()));
				errlog.setMessage("外围系统调用接口方法：" + methodName + "发生错误：" + resBean.getMessage()+"请求参数："+(reqBean==null?"未取到":reqBean.toString()));//异常时也将入口参数记录下来
				errlog.setMessage(errlog.getMessage().length()>1000?errlog.getMessage().substring(0,1000):errlog.getMessage());//截取长度，以免字段内容超长
				errlog.setIp(Tools.processNull(clientIp).equals("")?fetchClientIp():clientIp);
				errlog.setErrType("0");
				publicDao.save(errlog);
			}
			return this.java2xml(resBean);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 获取客户端的IP
	 */
	private String fetchClientIp(){
       String clientIp="";
		try { 
            HttpServletRequest request = null; 
            MessageContext mc = MessageContext.getCurrentMessageContext(); 
            if (mc == null) 
                clientIp="无法获取WebService客户端IP"; 
            request = (HttpServletRequest) mc.getProperty(HTTPConstants.MC_HTTP_SERVLETREQUEST); 
           clientIp=Tools.processNull(request.getRemoteAddr()); 
        } catch (Exception e) {
        	clientIp="无法获取WebService客户端IP"+e.getMessage(); 
        }
        return clientIp;
	}
	/**
	 * 查询单位经办人，银行领卡网点信息
	 */
	public String saveQueryEmp(String inXml) throws CommonException {
		try { 
			ArrayList datas = new ArrayList();
			InNetRequestBean reqBean = (InNetRequestBean) xml2java(inXml, "RequestBean", InNetRequestBean.class);
			BaseCorp emp = (BaseCorp) this.findOnlyRowByHql("from BaseCorp e where e.companyid='"+reqBean.getCompanyId()+"' ");
			Data data = new Data();
			if(emp!=null){
				if(Tools.processNull(emp.getLkBrchId()).equals("")){
					throw new CommonException("你未选择领卡网点，需至联合办公点市民卡窗口输手续！");
				}
			}
			SysBranch sysBranch = (SysBranch) this.findOnlyRowByHql("from SysBranch e where e.brchId='"+emp.getLkBrchId()+"'");
			data.setCeoName(Tools.processNull(emp.getCeoName()));//单位负责人
			data.setBank_Id(Tools.processNull(emp.getLkBrchId()));//领卡网点编号
			data.setBank_Name(Tools.processNull(sysBranch.getFullName()));//网点名称
			datas.add(data);
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
        }
	}
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
	public String expPersonErrata(String inXml) {
		try { 
			InNetRequestBean reqBean = (InNetRequestBean) this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getCompanyId()).equals("")) {
				throw new CommonException("社保单位编码为空！");
			} else if (Tools.processNull(reqBean.getRegionId()).equals("")) {
				throw new CommonException("单位区域编码为空！");
			}
			//
			BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp t where t.companyid = '" + reqBean.getCompanyId() + "' and regionId = '" + reqBean.getRegionId() + "'");
			if (corp == null) {
				throw new CommonException("单位不存在！");
			}
			String sql = "SELECT P.CUSTOMER_ID,P.NAME,P.CERT_NO,DECODE(P.RESIDE_TYPE,'0','嘉兴','1','外地') RESIDE_TYPE ,P.CORP_CUSTOMER_ID,S.CORP_NAME,"
					+ "DECODE(P.SURE_FLAG,'0','成功','1','失败') SURE_FLAG,DECODE(DECODE(DBMS_LOB.GETCHUNKSIZE(PHOTO),NULL,1,0),'0','是','1','否')  PHOTO "
					+ "FROM BASE_PERSONAL P, BASE_CORP S, BASE_PHOTO E, base_siinfo x WHERE P.CORP_CUSTOMER_ID  = S.CUSTOMER_ID AND P.CUSTOMER_ID = E.CUSTOMER_ID(+) "
					+ "and p.customer_id = x.customer_id AND NOT EXISTS(SELECT C.CUSTOMER_ID FROM CARD_APPLY C WHERE C.CUSTOMER_ID = P.CUSTOMER_ID) and x.med_State='0' "
					+ "and s.customer_id = '" + corp.getCustomerId() + "' ORDER BY P.NAME";
			List<Object[]> entityList = (List<Object[]>)findBySql(sql);
			if (entityList == null || entityList.isEmpty()) {
				throw new CommonException("该单位没有符合勘误条件的人员数据！");
			}
			//
			String[] headers = { "市民卡人员编号", "姓名", "公民身份证号", "户籍", "单位编号", "单位名称", "照片标志位" };
			List<KanwuExecelView> excelList = new ArrayList<KanwuExecelView>();
			for (int i = 0; i < entityList.size(); i++) {
				KanwuExecelView view = new KanwuExecelView();
				Object[] obj = (Object[]) entityList.get(i);
				view.setCustomerId(Tools.processNull(obj[0]));
				view.setName(Tools.processNull(obj[1]));
				view.setCertNo(Tools.processNull(obj[2]));
				view.setRegionAdd(Tools.processNull(obj[3]));
				view.setRegionId(Tools.processNull(obj[4]));
				view.setRegionName(Tools.processNull(obj[5]));
				view.setCheckPhoto(Tools.processNull(obj[7]));
				excelList.add(view);
			}
			ExportExcel<KanwuExecelView> ex = new ExportExcel<KanwuExecelView>();
			String fileName = "corperratadata_" + corp.getRegionId() + "_" + corp.getCompanyid() + "_" + corp.getCustomerId() + "_" + DateUtil.formatDate(new Date(), "yyyyMMddHHmmss") + ".xls";
			ex.exportExcel("勘误人员数据", headers, excelList, new FileOutputStream(absoluteDownloadPath + "/" +fileName), "");
			//
			ArrayList datas = new ArrayList();
			Data data = new Data();
			data.setEmpId(corp.getCustomerId());
			data.setEmpName(corp.getCorpName());
			data.setFileName(fileName);
			datas.add(data);
			return createReturnXml(new ResponseBean("0", "", datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException("获取单位勘误人员数据失败，" + e.getMessage());
        }
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public String impCorpNetAppData(String inXml) {
		Workbook wb = null;
		try { 
			InNetRequestBean reqBean = (InNetRequestBean) this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getCompanyId()).equals("")) {
				throw new CommonException("社保单位编码为空！");
			} else if (Tools.processNull(reqBean.getRegionId()).equals("")) {
				throw new CommonException("单位区域编码为空！");
			} else if (Tools.processNull(reqBean.getData()).equals("")) {
				throw new CommonException("上传数据为空！");
			}
			BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp t where t.companyid = '" + reqBean.getCompanyId() + "' and regionId = '" + reqBean.getRegionId() + "'");
			if (corp == null) {
				throw new CommonException("单位不存在！");
			}
			
			// 解析文件
			String base64Data = reqBean.getData();
			ByteArrayInputStream bais = new ByteArrayInputStream(Base64.decode(base64Data));
			try {
				wb = new HSSFWorkbook(bais);
			} catch (Exception e) {
				try {
					wb = new XSSFWorkbook(bais);
				} catch (Exception e1) {
					throw new CommonException("上传数据解析失败，请确认文件格式为 excel '97(-2007) 格式，以及传输编码为  BASE64！");
				}
			}
			Sheet sheet = wb.getSheetAt(0);
			int lastRowNum = sheet.getLastRowNum();
			List<Map<String, String>> persons = new ArrayList<Map<String, String>>();
			for (int i = 1; i <= lastRowNum; i++) {
				Row row = sheet.getRow(i);
				if (row == null) {
					continue;
				}
				// name
				Cell nameCell = row.getCell(0);
				if (nameCell == null) {
					continue;
				}
				String name = nameCell.getStringCellValue().trim();
				if (name == null) {
					continue;
				}
				// certNo
				Cell certNoCell = row.getCell(1);
				if (certNoCell == null) {
					continue;
				}
				String certNo = certNoCell.getStringCellValue().trim();
				if (certNo == null) {
					continue;
				}
				//
				Map<String, String> person = new HashMap<String, String>();
				person.put("name", name);
				person.put("certNo", certNo);
				persons.add(person);
			}
			//
			SysActionLog log = new SysActionLog();
			log.setBrchId("10010001");
			log.setUserId("admin");
			log.setDealCode(99999999);
			log.setOrgId("1001");
			log.setDealTime(new Date());
			TrServRec rec = cardApplyService.saveCorpNetAppData(corp.getCustomerId(), corp.getRegionId(), persons, log);
			//
			ArrayList datas = new ArrayList();
			Data data = new Data();
			datas.add(data);
			ResponseBean resBean = new ResponseBean("0", "", rec.getDealNo().toString());
			resBean.setDatas(datas);
			return createReturnXml(resBean, getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException("导入单位人员申领数据失败，" + e.getMessage());
		} finally {
			try {
				if (wb != null)
					wb.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
	public String getCorpNetAppData(String inXml) {
		try { 
			InNetRequestBean reqBean = (InNetRequestBean) this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getActionNo()).equals("")) {
				if (Tools.processNull(reqBean.getCompanyId()).equals("")) {
					throw new CommonException("社保单位编码为空！");
				} else if (Tools.processNull(reqBean.getRegionId()).equals("")) {
					throw new CommonException("单位区域编码为空！");
				}
			}
			
			//
			Object[] corpNetAppData = (Object[]) findOnlyRowBySql("select * from (select t.deal_no, t.task_id, t2.customer_id, t2.corp_name, t2.region_id, t2.companyid, to_char(t.apply_date, 'yyyy-mm-dd hh24:mi:ss') "
					+ "from corp_netapp_data t join base_corp t2 on t.corp_id = t2.customer_id where t.deal_no = '" + reqBean.getActionNo() 
					+ "' or (t2.companyid = '" + reqBean.getCompanyId() + "' and t2.region_id = '" + reqBean.getRegionId() + "')  order by apply_date desc) where rownum = 1");
			if (corpNetAppData == null) {
				throw new CommonException("未找到单位上传申领数据！");
			}
			String fileName = "corpnetappdata_" + corpNetAppData[4] + "_" + corpNetAppData[5] + "_" + corpNetAppData[2] + "_" + DateUtil.formatDate(new Date(), "yyyyMMddHHmmss") + ".xls";
			createFile(corpNetAppData[0].toString(), corpNetAppData[2].toString(), corpNetAppData[3].toString(), corpNetAppData[6].toString(), fileName);
			//
			ArrayList datas = new ArrayList();
			Data data = new Data();
			data.setEmpId(corpNetAppData[2].toString());
			data.setEmpName(corpNetAppData[3].toString());
			data.setFileName(fileName);
			datas.add(data);
			return createReturnXml(new ResponseBean("0", "", datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException("获取单位勘误人员数据失败，" + e.getMessage());
        }
	}
	
	private void createFile(String dealNo, String corpId, String corpName, String appDate, String fileName) {
		Workbook workbook = null;
		try {
			String sql = "select t.customer_id, t.name, (select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.cert_type) cert_type, t.cert_no, t2.corp_id, t3.corp_name, t.sure_flag, (select code_name from sys_code where code_type = 'APPLY_STATE' and code_value = t4.apply_state) applystate, t4.apply_state from corp_netapp_data_detail t join corp_netapp_data t2 on t.deal_no = t2.deal_no join base_corp t3 on t2.corp_id = t3.customer_id left join card_apply t4 on t2.task_id = t4.task_id and t.customer_id = t4.customer_id where t.deal_no = '" + dealNo + "'";
			Page data = pagingQuery(sql, 1, 65500);
			JSONArray list = data.getAllRs();
			//
			workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 8000);
			sheet.setColumnWidth(5, 8000);
			sheet.setColumnWidth(6, 8000);
			sheet.setColumnWidth(7, 8000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 8;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(corpId + "_" + corpName + "_" + appDate + "_上传申领数据");

			// second header
			String string = "";
			if(!Tools.processNull(appDate).equals("")){
				string += "申领时间：" + appDate + "    ";
			}
			string += "导出时间：" + DateUtil.formatDate(new Date());
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("客户编号");
			sheet.getRow(2).getCell(1).setCellValue("姓名");
			sheet.getRow(2).getCell(2).setCellValue("证件类型");
			sheet.getRow(2).getCell(3).setCellValue("证件号码");
			sheet.getRow(2).getCell(4).setCellValue("单位编号");
			sheet.getRow(2).getCell(5).setCellValue("单位名称");
			sheet.getRow(2).getCell(6).setCellValue("备注");
			sheet.getRow(2).getCell(7).setCellValue("申领状态");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(4, headRows);
			
			// data
			int noAppNum = 0; // 未申领
			int canAppNum = 0; // 可申领
			int abNormalNum = 0; // 状态不正常
			int noSiinfoNum = 0; // 无参保
			int noPhotoNum = 0; // 无照片
			int appNum = 0; // 已申领
			for (int i = 0; i < list.size(); i++, noAppNum++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				// data
				JSONObject item = list.getJSONObject(i);
				row.getCell(0).setCellValue(item.getString("CUSTOMER_ID"));
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("CERT_TYPE"));
				row.getCell(3).setCellValue(item.getString("CERT_NO"));
				row.getCell(4).setCellValue(item.getString("CORP_ID"));
				row.getCell(5).setCellValue(item.getString("CORP_NAME"));
				
				String flag = item.getString("SURE_FLAG");
				//
				String applyState = item.getString("APPLY_STATE");
				if(flag.equals("1") && Constants.APPLY_STATE_YSQ.compareTo(applyState) <= 0 && Constants.APPLY_STATE_YZX.compareTo(applyState) >= 0) {
					appNum++;
				}
				if(!Tools.processNull(applyState).equals("")) {
					row.getCell(7).setCellValue(item.getString("APPLYSTATE"));
				} else {
					row.getCell(7).setCellValue("未申领或已撤销！");
				}
				//
				if (flag.equals("1")) {
					flag = "可申领";
					canAppNum++;
				} else if (flag.equals("2")) {
					flag = "人员状态不正常";
					abNormalNum++;
				} else if (flag.equals("3")) {
					flag = "参保信息不存在或参保状态不正常";
					noSiinfoNum++;
				} else if (flag.equals("4")) {
					flag = "照片不存在或照片状态不正常";
					noPhotoNum++;
				} else if (flag.equals("5")) {
					flag = "人员不属于该单位";
				} else if (flag.equals("6")) {
					flag = "人员不存在";
				} else if (flag.equals("7")) {
					flag = "人员已有金融市民卡";
				} else if (flag.equals("9")) {
					flag = "人员已有全功能卡";
				}
				row.getCell(6).setCellValue(flag);
			}

			Row row = sheet.createRow(list.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + noAppNum + " 人未制卡， 其中 " + canAppNum + " 人可制卡， " + abNormalNum + " 人【人员状态不正常】， " + noSiinfoNum + " 人【参保信息不存在或参保状态不正常】， " + noPhotoNum + " 人【照片不存在或照片状态不正常】， 成功申领 " + appNum + " 张");
			sheet.addMergedRegion(new CellRangeAddress(list.size() + headRows, list.size() + headRows, 1, maxColumn - 1));
			//
			String filePath = absoluteDownloadPath + "/" +fileName;
			workbook.write(new FileOutputStream(filePath));
		} catch (Exception e) {
			throw new CommonException("生成文件失败！");
		} finally {
			if(workbook!=null){
				try {
					workbook.close();
				} catch (IOException e) {
					// TODO
				}
			}
		}
	}
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public String getPersonPhoto(String inXml) {
		try { 
			InNetRequestBean reqBean = (InNetRequestBean) this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getCertNo()).equals("")) {
				throw new CommonException("证件号码为空！");
			}
			//
			BasePhoto photo = (BasePhoto) findOnlyRowByHql("from BasePhoto p where exists(select 1 from BasePersonal where customerId = p.customerId and certNo = '" + reqBean.getCertNo() + "')");
			if (photo == null || photo.getPhotoState().equals(Constants.STATE_ZX)) {
				throw new CommonException("照片无效或照片不存在！");
			}
			//
			ArrayList datas = new ArrayList();
			Data data = new Data();
			data.setCertNo(reqBean.getCertNo());
			data.setPhoto(Base64.encodeBytes(Base64.blobToBytes(photo.getPhoto())));
			datas.add(data);
			return createReturnXml(new ResponseBean("0", "", datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException("获取人员照片失败，" + e.getMessage());
        }
	}
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
	public String getBankCardInfo(String inXml) {
		try {
			//
			InNetRequestBean reqBean = (InNetRequestBean) this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getCertNo()).equals("")) {
				throw new CommonException("证件号码为空！");
			}
			
			// person
			BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal p where certNo = '" + reqBean.getCertNo() + "'");
			if (person == null) {
				throw new CommonException("客户信息不存在！");
			} else if (reqBean.getName() != null && !reqBean.getName().equals(person.getName())) {
				throw new CommonException("证件号码不匹配！");
			} 
			
			// card
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo p where customerId = '" + person.getCustomerId() + "' and cardType = '120' and cardState < '9'");
			if (card == null) {
				throw new CommonException("客户无金融社保卡！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZC)) {
				throw new CommonException("客户金融社保卡状态【" + getCodeNameBySYS_CODE("CARD_STATE", card.getCardState()) + "】不正常！");
			}

			//
			ArrayList datas = new ArrayList();
			BankAccInfo data = new BankAccInfo();
			data.setCertNo(person.getCertNo());
			data.setName(person.getName());
			data.setBankAccName(person.getName());
			data.setBankCardNo(card.getBankCardNo());
			data.setBankId(card.getBankId());
			data.setBankClrNo("");
			datas.add(data);
			return createReturnXml(new ResponseBean("0", "", datas), getMethodName(1), true, reqBean);
		} catch (Exception e) {
			throw new CommonException("获取金融卡银行账户信息失败，" + e.getMessage());
        }
	}
}
