package com.erp.action;

import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.StockAcc;
import com.erp.model.StockList;
import com.erp.model.StockRec;
import com.erp.model.StockType;
import com.erp.model.SysBranch;
import com.erp.model.Users;
import com.erp.service.StockService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@Namespace("/stockManage")
@Action(value="stockManageAction")
@Results({ 
	@Result(name="viewTask",location="/jsp/stockManage/viewstock.jsp"),
	@Result(name="totellersj",location="/jsp/stockManage/tellerhanded.jsp"),
	@Result(name="stockTypeAdd",location="/jsp/stockManage/stockTypeAdd.jsp"),
	@Result(name="stockAccsubAdd",location="/jsp/stockManage/stockAccsubAdd.jsp"),
	@Result(name="stockDeliveryMain",location="/jsp/stockManage/stockDeliveryMain.jsp"),
	@Result(name="stockDeliveryConfirmMain",location="/jsp/stockManage/stockDeliveryConfirmMain.jsp"),
	@Result(name="stockDeliveryCancelMain",location="/jsp/stockManage/stockDeliveryCancelMain.jsp"),
	@Result(name="tellerReceiveMain",location="/jsp/stockManage/tellerReceiveMain.jsp"),
	@Result(name="tellerTransitionMain",location="/jsp/stockManage/tellerTransitionMain.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class StockManageAction extends BaseAction {
	private static final long serialVersionUID = 1L;
	public Logger log = Logger.getLogger(StockManageAction.class);
	private StockService stockService;
	private StockList stock = new StockList();
	private StockAcc stockAcc = new StockAcc();
	private StockType stockType = new StockType();
	public StockRec rec = new StockRec();
	private String queryType = "1";// 查询标志
	public String brch_Name = "";// 网点名称
	public String oper_Name = "";// 柜员
	public String pwd;//收方柜员
	public String beginDate, endDate, task_Name,stkCodeId="",stkTypeId="";
	public String[] dealnos = null;
	private String brchId;
	private String brchName;
	private String userId;
	private String userName;
	private String otherBrchId;//对方网点编号
	private String otherBrchName;//对方网点名称
	private String otherUserId;//对方柜员编号
	private String otherUserName;//对方柜员名称
	private String inBeginTime;//入库开始时间
	private String inEndTime;//入库结束时间
	private String outBeginTime;//出库开始时间
	private String outEndTime;//出库结束时间
	private String sort="";//排序字段名称
	private String order="";//顺序 或是反序
	private String isZero;//数量是否为0
	private String beginGoodsNo;//起始物品编号
	private String endGoodsNo;//结束物品编号
	private String defaultErrorMsg;//错误提示信息
	private String taskIds;
	private String deliveryWay;
	/**
	 * 获取所有的库存类型查询
	 * @return
	 */
	public String findAllStkCode(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("status","0");
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		try{
			if(Tools.processNull(queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t.stk_type,(select code_name from sys_code where code_type = 'STK_TYPE' and code_value = t.stk_type) stytypename,t.stk_code,t.stk_name,");
				sb.append("(CASE t.lst_flag WHEN '0' THEN '是' WHEN '1' THEN '否' ELSE '未设置' END) lstFlag,");
				sb.append("(CASE t.stk_code_state WHEN '0' THEN '正常' WHEN '1' THEN '注销' ELSE '未知' end) stkcodestate,t.note, ");
				sb.append("(CASE t.out_flag WHEN '0' THEN '柜员' when '1' then  '网点' ELSE '未设置' end) outflag,o.org_name,t.org_id,");
				sb.append("(SELECT name from sys_users where user_id = t.open_user_id) openuserid,t.stk_code_state,");
				sb.append("to_char(t.open_date,'yyyy-mm-dd hh24:mi:ss') opendate,");
				sb.append("(SELECT name from sys_users where user_id = t.cls_user_id) clsuserid ,");
				sb.append("to_char(t.cls_date,'yyyy-mm-dd hh24:mi:ss') clsdate ");
				sb.append("from STOCK_TYPE t,Sys_Organ o WHERE t.org_id = o.org_id ");
				if(!Tools.processNull(stockType.getStkType()).equals("")){
					sb.append("and t.stk_type = '" + stockType.getStkType() + "' ");
				}
				if(!Tools.processNull(stockType.getStkName()).equals("")){
					sb.append("and t.stk_name like '%" + stockType.getStkName() + "%' ");
				}
				if(!Tools.processNull(stockType.getStkCode()).equals("")){
					sb.append("and t.stk_code = '" + stockType.getStkCode() + "' ");
				}
				if(!Tools.processNull(stockType.getStkCodeState()).equals("")){
					sb.append("and t.stk_code_state = '" + stockType.getStkCodeState() + "' ");
				}
				if(!Tools.processNull(sort).equals("")){
					sb.append(" order by " + sort + " " + this.order);
				}else{
					sb.append("order by t.stk_type asc, t.stk_code asc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);	
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应库存类型信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			log.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存类型新增或是编辑页面
	 * @return
	 */
	public String toStockTypeAddIndex(){
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				stockType = (StockType) baseService.findOnlyRowByHql("from StockType t where t.stkCode = '" + stockType.getStkCode() + "'");
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
			log.error(e);
			this.saveErrLog(e);
		}
		return "stockTypeAdd";
	}
	/**
	 * 库存类型管理
	 * @return
	 */
	public String saveOrUpdateStockType(){
		String typestring = "";
		try{
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			if(Tools.processNull(queryType).equals("0")){
				typestring = "新增库存类型";
			}else if(Tools.processNull(queryType).equals("1")){
				typestring = "编辑库存类型";
			}else if(Tools.processNull(queryType).equals("2")){
				typestring = "删除库存类型";	
			}else if(Tools.processNull(queryType).equals("3")){
				typestring = "注销库存类型";
			}else if(Tools.processNull(queryType).equals("4")){
				typestring = "启用库存类型";
			}else{
				throw new CommonException("库存类型的操作类型不正确！");
			}
		 	stockService.saveOrUpdateStockType(stockType,baseService.getUser(),baseService.getCurrentActionLog(),this.queryType);
			jsonObject.put("status","0");
			jsonObject.put("msg",typestring + "成功！");
		}catch(Exception e){
			jsonObject.put("msg",typestring + "发生错误：" + e.getMessage());
			log.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存明细查询
	 * @return
	 */
	public String toStockListQueryIndex(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("status","0");
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				//1.查询表头
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t.stk_code,t.goods_id,t.goods_no,DECODE(t.own_type,'0','柜员','1','客户','未知') owntype,c.STK_NAME,");
				sb.append("DECODE(t.goods_state,'0','正常','1','回收待处理','2','质量问题退回待处理','3','注销卡待处理','9','报废') goodsstate,");
				sb.append("t.task_id,(SELECT full_name from sys_branch where brch_id = t.in_brch_id) inbrchid,t.customer_id,t.customer_name,");
				sb.append("(SELECT name from sys_users where user_id = t.in_user_id) inuserid,to_char(t.in_date,'yyyy-mm-dd hh24:mi:ss') indate,");
				sb.append("(SELECT full_name from sys_branch where brch_id = t.out_brch_id) outbrchid ,t.in_deal_no,t.out_deal_no,t.note,t.brch_Id,");
				sb.append("(SELECT name from sys_users where user_id = t.out_user_id) outuserid,to_char(t.out_date,'yyyy-mm-dd hh24:mi:ss') outdate,");
				sb.append("(SELECT full_name from sys_branch where brch_id = t.brch_id) brchid ,(SELECT name from sys_users where user_id = t.user_id) userid ");
				sb.append("from STOCK_LIST t,STOCK_TYPE c,base_personal p where t.stk_code = c.stk_code and t.customer_id = p.customer_id(+) ");
				//2.查询条件 01
				if(stock.getId() != null && !Tools.processNull(stock.getId().getStkCode()).equals("")){
					sb.append("and t.stk_code = '" + stock.getId().getStkCode() + "' ");
				}
				if(!Tools.processNull(stock.getGoodsNo()).equals("")){
					sb.append("and t.goods_no = '" + stock.getGoodsNo() + "' ");
				}
				if(!Tools.processNull(stock.getBatchId()).equals("")){
					sb.append("and t.batch_Id = '" + stock.getBatchId() + "' ");
				}
				if(!Tools.processNull(stock.getTaskId()).equals("")){
					sb.append("and t.task_id = '" + stock.getTaskId() + "' ");
				}
				//02
				if(!Tools.processNull(stock.getInBrchId()).equals("")){
					sb.append("and t.in_brch_id = '" + stock.getInBrchId() + "' ");
				}
				if(!Tools.processNull(stock.getInUserId()).equals("")){
					sb.append("and t.in_user_id = '" + stock.getInUserId() + "' ");
				}
				if(!Tools.processNull(this.inBeginTime).equals("")){
					sb.append("and to_char(t.in_date,'yyyy-mm-dd') >= '" + inBeginTime + "' ");
				}
				if(!Tools.processNull(inEndTime).equals("")){
					sb.append("and to_char(t.in_date,'yyyy-mm-dd') <= '" + inEndTime + "' ");
				}
				//03
				if(!Tools.processNull(stock.getOutBrchId()).equals("")){
					sb.append("and t.out_brch_id = '" + stock.getOutBrchId() + "' ");
				}
				if(!Tools.processNull(stock.getOutUserId()).equals("")){
					sb.append("and t.out_user_id = '" + stock.getOutUserId() + "' ");
				}
				if(!Tools.processNull(outBeginTime).equals("")){
					sb.append("and to_date(t.out_date,'yyyy-mm-dd') >= '" + outBeginTime + "' ");
				}
				if(!Tools.processNull(outEndTime).equals("")){
					sb.append("and to_date(t.out_date,'yyyy-mm-dd') <= '" + outEndTime + "' ");
				}
				//04
				if(stock.getId() != null && !Tools.processNull(stock.getId().getGoodsState()).equals("")){
					sb.append("and t.goods_state = '" + stock.getId().getGoodsState() + "' ");
				}
				if(!Tools.processNull(stock.getOwnType()).equals("") && Tools.processNull(stock.getOwnType()).equals("0")){
					sb.append("and t.own_type = '" + stock.getOwnType() + "' ");
					if(!Tools.processNull(stock.getBrchId()).equals("")){
						sb.append("and t.brch_id = '" + stock.getBrchId() + "' ");
					}
					if(!Tools.processNull(stock.getUserId()).equals("")){
						sb.append("and t.user_id = '" + stock.getUserId() + "' ");
					}
				}
				if(!Tools.processNull(stock.getOwnType()).equals("") && Tools.processNull(stock.getOwnType()).equals("1")){
					sb.append("and t.own_type = '" + stock.getOwnType() + "' ");
					if(!Tools.processNull(stock.getCustomerId()).equals("")){
						sb.append("and p.cert_no = '" + stock.getCustomerId() + "' ");
					}
					if(!Tools.processNull(stock.getCustomerName()).equals("")){
						sb.append("and t.customer_name like '%" + stock.getCustomerName() + "%' ");
					}
				}
				if(!Tools.processNull(sort).equals("")){
					sb.append(" order by " + sort + " " + this.order);
				}else{
					sb.append("order by t.out_date desc ");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);	
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应物品信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			log.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存分帐户查询
	 * @return
	 */
	public String toStockAccQueryIndex(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("status","0");
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		JSONArray footer = new JSONArray();
		JSONObject ftotal = new JSONObject();
		ftotal.put("TOTNUM",0);
		ftotal.put("TOTFACEVAL",0);
		ftotal.put("GOODSSTATE","信息统计：");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t.org_id,o.org_name,t.acc_name,t.stk_code,s.stk_name,");
				sb.append("(SELECT full_name from sys_branch where brch_id = t.brch_id) brchname ,");
				sb.append("(SELECT name from sys_users where user_id = t.user_id) username ,");
				sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'GOODS_STATE' AND CODE_VALUE = t.goods_state) goodsstate,");
				sb.append("to_char(nvl(t.tot_num,0),'999,999,990') totnum,to_char(NVL(t.tot_face_val,0)/100,'999,999,990.99') totfaceval,");
				sb.append("to_char(t.open_date,'yyyy-mm-dd hh24:mi:ss') opendate,");
				sb.append("(SELECT name from sys_users where user_id = t.auth_user_id) authuserid ,");
				sb.append("to_char(t.cls_date,'yyyy-mm-dd hh24:mi:ss') clsdate,");
				sb.append("(SELECT name from sys_users where user_id = t.cls_user_id) clsuserid ,");
				sb.append("to_char(t.last_deal_date,'yyyy-mm-dd hh24:mi:ss') lastdealdate,");
				sb.append("DECODE(t.acc_state,'0','正常','1','注销','注销') accstate,t.note ");
				StringBuffer where = new StringBuffer();
				where.append("FROM STOCK_ACC t ,stock_type s,Sys_Organ o ");
				where.append("WHERE t.stk_code = s.stk_code AND t.org_id = o.org_id(+) ");
				//01
				if(stockAcc.getId() != null && !Tools.processNull(stockAcc.getId().getStkCode()).equals("")){
					where.append("and t.stk_code = '" + stockAcc.getId().getStkCode() + "' ");
				}
				if(stockAcc.getId() != null && !Tools.processNull(stockAcc.getId().getGoodsState()).equals("")){
					where.append("and t.goods_state = '" + stockAcc.getId().getGoodsState() + "' ");
				}
				if(!Tools.processNull(stockAcc.getAccState()).equals("")){
					where.append("and t.acc_state = '" + stockAcc.getAccState() + "'" );
				}
				//02
				if(!Tools.processNull(stockAcc.getBrchId()).equals("")){
					where.append("and t.brch_id = '" + stockAcc.getBrchId() + "' ");
				}
				if(stockAcc.getId() != null && !Tools.processNull(stockAcc.getId().getUserId()).equals("")){
					where.append("and t.user_id = '" + stockAcc.getId().getUserId() + "' ");
				}
				if(Tools.processNull(isZero).equals("0")){
					where.append("and t.tot_num = 0 ");
				}
				if(Tools.processNull(isZero).equals("1")){
					where.append("and t.tot_num > 0 ");
				}
				//03
				String temporder = "";
				if(!Tools.processNull(sort).equals("")){
					temporder = " order by " + sort + " " + this.order;
				}else{
					temporder = " order by t.user_id asc,t.stk_code asc,t.goods_state asc, t.last_deal_date desc ";
				}
				Page list = baseService.pagingQuery(sb.toString() + where.toString() +  temporder,page,rows);	
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
					Object[] stat = (Object[]) baseService.findOnlyFieldBySql("select to_char(sum(nvl(t.tot_num,0)),'999,999,999,990') allnum,to_char(sum(nvl(t.tot_face_val,0))/100,'999,999,990.99') allamt " + where.toString());
					if(stat != null && stat.length > 0){
						ftotal.put("TOTNUM",stat[0].toString());
						ftotal.put("TOTFACEVAL",stat[1].toString());
					}
				}else{
					throw new CommonException("根据查询条件未找到对应库存账户信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			log.error(e);
		}
		footer.add(ftotal);
		jsonObject.put("footer",footer);
		return this.JSONOBJ;
	}
	/**
	 * 库存账户开户首页
	 * @return
	 */
	public String toStockAccAddIndex(){
		return "stockAccsubAdd";
	}
	/**
	 * 库存账户开户保存
	 * @return
	 */
	public String saveStockAccAdd(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			Users user = (Users) stockService.findOnlyRowByHql("from Users where userId = '" + stockAcc.getId().getUserId() + "'");
			if (user == null) {
				throw new CommonException("柜员【" + stockAcc.getId().getUserId() + "】不存在！");
			}
			stockAcc.setBrchId(user.getBrchId());
			stockAcc.setOrgId(user.getOrgId());
			stockService.saveStockAccOpen(stockAcc,baseService.getUser(),baseService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","库存账户开户成功！");
		}catch(Exception e){
			jsonObject.put("msg","保存库存账户开户发生错误：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 到达库存配送首页
	 * @return
	 */
	public String toStockDeliveryIndex(){
		try{
			this.brchId = baseService.getUser().getBrchId();
			this.userId = baseService.getUser().getUserId();
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "stockDeliveryMain";
	}
	/**
	 * 库存配送按照任务配送时,查找可以配送的任务
	 * @return
	 */
	public String toQueryCanDeliveryCardTask(){
		jsonObject.put("status","0");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.make_batch_id,t.task_id,t.task_name,t.task_sum,decode(t.task_src,'0','零星申领','1','规模申领','未知') tasksrc,");
			sb.append("to_char(t.task_date,'yyyy-mm-dd hh24:mi:ss') taskdate,b.full_name,c.name,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE ");
			sb.append("= 'CARD_TYPE' AND CODE_VALUE = t.card_type) cardtype,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'TASK_WAY' AND ");
			sb.append("CODE_VALUE = t.task_way) taskway,decode(t.is_urgent,'0','本地','1','外包','未知') isurgent,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'TASK_STATE' AND CODE_VALUE = t.task_state) taskstate, ");
			sb.append("(SELECT full_name FROM SYS_branch WHERE brch_id = t.brch_id) l_brch_name, t.brch_id ");
			sb.append("from CARD_APPLY_TASK t,Sys_Branch b,Sys_Users c WHERE t.task_brch_id = b.brch_id AND t.task_oper_id = c.user_id ");
			sb.append("and t.task_state = '" + Constants.TASK_STATE_YZK + "' " );
			sb.append("and t.card_type ='" + (Tools.processNull(this.stkTypeId).startsWith("1") ? this.stkTypeId.substring(1) : "erp2") +  "' ");
			sb.append("and exists (select 1 from stock_list l where l.own_type = '0' and l.brch_id ='" + stockService.getUser().getBrchId() + "' and l.user_id = '");
			sb.append(stockService.getUser().getUserId() + "')"); 
			Page list = stockService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到可供配送的任务信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			log.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存配送保存
	 * @return
	 */
	public String saveStockDelivery(){
		jsonObject.put("status","1");
		try{
			if(Tools.processNull(this.deliveryWay).equals("1") && Tools.processNull(rec.getTaskId()).equals("")){
				throw new CommonException("库存配送方式已选择【按任务配送】，请选择任务编号！");
			}else if(Tools.processNull(deliveryWay).equals("2") && (
					Tools.processNull(rec.getStartNo()).equals("") ||
					Tools.processNull(rec.getEndNo()).equals("") ||
					Tools.processNull(rec.getGoodsNums()).equals("") ||
					rec.getGoodsNums() == 0
							
			)){
				throw new CommonException("库存配送方式已选择【按号段配送】，请输入起止号码和数量！");
			}
			if(Tools.processNull(rec.getInBrchId()).equals("") || Tools.processNull(rec.getInUserId()).equals("")){
				throw new CommonException("库存配送接收柜员信息不能为空！");
			}
			if(Tools.processNull(rec.getBrchId()).equals("") || Tools.processNull(rec.getUserId()).equals("")){
				throw new CommonException("库存配送柜员信息不能为空！");
			}
			stockService.saveStockDelivery(rec,deliveryWay,stockService.getUser(),stockService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","库存配送成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage() + "！");
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存配送确认首页
	 * @return
	 */
	public String stockDeliveryConfirmMain(){
		return "stockDeliveryConfirmMain";
	}
	/**
	 * 库存配送记录查询
	 * @return
	 */
	public String stockDeliveryRecQuery(){
		jsonObject.put("status","0");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT t.stk_ser_no, t.deal_no, t.stk_code,s.stk_name,t.batch_id,t.task_id,");
			sb.append("(SELECT org_name FROM Sys_Organ WHERE org_id = t.in_org_id) inorgname,");
			sb.append("(SELECT full_name from sys_branch where brch_id = t.in_brch_id) inbrchname,");
			sb.append("(SELECT name from sys_users where user_id = t.in_user_id) inusername ,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'STOCK_ACC_GOODS_STATE' AND CODE_VALUE = t.in_goods_state) goodsstate,");
			sb.append("t.goods_nums,DECODE(t.is_sure,'0','已确认','1','未确认','2','已退库','未说明') issure,");
			sb.append("to_char(t.tr_date,'yyyy-mm-dd hh24:mi:ss') trdate,t.clr_date,t.start_no,t.end_no,");
			sb.append("(SELECT org_name FROM Sys_Organ WHERE org_id = t.out_org_id) outorgname,");
			sb.append("(SELECT full_name from sys_branch where brch_id = t.out_brch_id) outbrchname ,");
			sb.append("(SELECT name from sys_users where user_id = t.out_user_id) outusername ");
			sb.append("from STOCK_REC t,stock_type s WHERE t.stk_code = s.stk_code and t.task_id is not null ");
			if(!Tools.processNull(rec.getStkCode()).equals("")){
				sb.append("and t.stk_code = '" + rec.getStkCode() + "' ");
			}
			if(!Tools.processNull(rec.getInGoodsState()).equals("")){
				sb.append("and t.in_goods_state = '" + rec.getInGoodsState() + "' ");
			}
			if(!Tools.processNull(rec.getIsSure()).equals("")){
				sb.append("and t.is_sure = '" + rec.getIsSure() + "' ");
			}
			if(!Tools.processNull(this.inBeginTime).equals("")){
				sb.append("and to_char(t.tr_date,'yyyy-mm-dd') >= '" + inBeginTime + "' ");
			}
			if(!Tools.processNull(this.inEndTime).equals("")){
				sb.append("and to_char(t.tr_date,'yyyy-mm-dd') <= '" + inEndTime + "' ");
			}
			if(!Tools.processNull(rec.getTaskId()).equals("")){
				sb.append("and t.task_id = '" + rec.getTaskId() + "' ");
			}
			if(!Tools.processNull(rec.getBatchId()).equals("")){
				sb.append("and t.batch_id = '" + rec.getBatchId() + "' ");
			}
			if(!Tools.processNull(rec.getInBrchId()).equals("")){
				sb.append("and t.in_brch_id = '" + rec.getInBrchId() + "' ");
			}
			if(!Tools.processNull(rec.getInUserId()).equals("")){
				sb.append("and t.in_user_id = '" + rec.getInUserId() + "' ");
			}
			if(Tools.processNull(this.isZero).equals("0")){
				sb.append("and t.in_brch_id = '" + stockService.getUser().getBrchId() + "' ");
				sb.append("and t.in_user_id = '" + stockService.getUser().getUserId() + "' ");
			}else if(Tools.processNull(this.isZero).equals("1")){
				sb.append("and t.out_brch_id = '" + stockService.getUser().getBrchId() + "' ");
				sb.append("and t.out_user_id = '" + stockService.getUser().getUserId() + "' ");
			}
			sb.append("and t.deal_code = '" + DealCode.STOCK_DELIVERY + "' ");
			if(!Tools.processNull(this.sort).equals("")){
				sb.append("order by " + this.sort + " " + this.order);
			}else{
				sb.append("order by tr_date desc");
			}
			Page list = stockService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException(Tools.processNull(this.isZero).equals("0") ? "未找到可进行确认的配送任务信息！" : "未找到可供撤销的配送任务信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			log.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存配送确认保存
	 * @return
	 */
	public String saveStockDeliveryConfirm(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(Tools.processNull(this.taskIds).equals("")){
				throw new CommonException("请勾选需要确认的库存配送记录！");
			}
			stockService.saveStockDeliveryConfirm(taskIds,stockService.getUser(),stockService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","库存配送确认成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存配送取消首页
	 * @return
	 */
	public String stockDeliveryCancelMain(){
		return "stockDeliveryCancelMain";
	}
	/**
	 * 库存配送取消保存
	 * @return
	 */
	public String saveStockDeliveryCancel(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(Tools.processNull(this.taskIds).equals("")){
				throw new CommonException("请勾选需要取消的库存配送记录！");
			}
			stockService.saveStockDeliveryCancel(taskIds,stockService.getUser(),stockService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","库存配送取消成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 柜员领用首页
	 * @return
	 */
	public String tellerReceiveMain(){
		try{
			this.brchId = baseService.getUser().getBrchId();
			this.userId = baseService.getUser().getUserId();
		}catch(Exception e){
			
		}
		return "tellerReceiveMain";
	}
	/**
	 * 按照任务领用时,查询可以领取的任务
	 * @return
	 */
	public String stockTaskQuery(){
		jsonObject.put("status","0");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.make_batch_id,t.task_id,t.task_name,t.task_sum,decode(t.task_src,'0','零星申领','1','规模申领','未知') tasksrc,");
			sb.append("to_char(t.task_date,'yyyy-mm-dd hh24:mi:ss') taskdate,b.full_name,c.name,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE ");
			sb.append("= 'CARD_TYPE' AND CODE_VALUE = t.card_type) cardtype,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'TASK_WAY' AND ");
			sb.append("CODE_VALUE = t.task_way) taskway,decode(t.is_urgent,'0','本地','1','外包','未知') isurgent,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'TASK_STATE' AND CODE_VALUE = t.task_state) taskstate ");
			sb.append("from CARD_APPLY_TASK t,Sys_Branch b,Sys_Users c WHERE t.task_brch_id = b.brch_id AND t.task_oper_id = c.user_id ");
			sb.append("and t.task_state = '" + Constants.TASK_STATE_YJS + "' " );
			sb.append("and t.card_type ='" + (Tools.processNull(stkTypeId).startsWith("1") ? this.stkTypeId.substring(1) : "erp2") +  "' ");
			sb.append("and exists (select 1 from stock_list l where l.task_id = t.task_id and l.own_type = '0' and brch_id ='" + baseService.getUser().getBrchId() + "' and l.user_id = '");
			sb.append(baseService.getUser().getUserId() + "') ");
			Page list = stockService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到可供领用的任务信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			log.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 柜员领用保存
	 * @return
	 */
	public String saveTellerReceive(){
		jsonObject.put("status","1");
		try{
			stockService.judgeOperPwd(stockService.getUser().getUserId(),pwd);
			if(Tools.processNull(this.deliveryWay).equals("1") && Tools.processNull(rec.getTaskId()).equals("")){
				throw new CommonException("柜员领用方式已选择【按任务领用】，请选择任务编号！");
			}else if(Tools.processNull(deliveryWay).equals("2") && (
					Tools.processNull(rec.getStartNo()).equals("") ||
					Tools.processNull(rec.getEndNo()).equals("") ||
					Tools.processNull(rec.getGoodsNums()).equals("") ||
					rec.getGoodsNums() == 0
			)){
				throw new CommonException("柜员领用方式已选择【按号段领用】，请输入起止号码和数量！");
			}
			if(Tools.processNull(rec.getInBrchId()).equals("") || Tools.processNull(rec.getInUserId()).equals("")){
				throw new CommonException("柜员领用接收柜员信息不能为空！");
			}
			if(Tools.processNull(rec.getBrchId()).equals("") || Tools.processNull(rec.getUserId()).equals("")){
				throw new CommonException("柜员领用出库柜员信息不能为空！");
			}
			stockService.saveTellerReceive(rec,deliveryWay,stockService.getUser(),stockService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","柜员领用成功");
		}catch(Exception e){
			String temperror= e.getMessage();
			if(temperror.endsWith("！")) temperror = temperror.substring(0,temperror.length() - 1);
			jsonObject.put("msg","柜员领用发生错误：" + temperror + "！");
		}
		return this.JSONOBJ;
	}
	/**
	 * 柜员交接
	 * @return
	 */
	public String tellerTransitionMain(){
		try{
			this.brchId = baseService.getUser().getBrchId();
			this.userId = baseService.getUser().getUserId();
		}catch(Exception e){
			defaultErrorMsg = e.getMessage();
		}
		return "tellerTransitionMain";
	}
	/**
	 * 保存柜员交接
	 * @return
	 */
	public String saveTellerTransitionMain(){
		jsonObject.put("status","1");
		try{
			deliveryWay = "2";
			stockService.judgeOperPwd(stockService.getUser().getUserId(),pwd);
			if(Tools.processNull(this.deliveryWay).equals("1") && Tools.processNull(rec.getTaskId()).equals("")){
				throw new CommonException("柜员领用方式已选择【按任务领用】，请选择任务编号！");
			}else if(Tools.processNull(deliveryWay).equals("2") && (
					Tools.processNull(rec.getStartNo()).equals("") ||
					Tools.processNull(rec.getEndNo()).equals("") ||
					Tools.processNull(rec.getGoodsNums()).equals("") ||
					rec.getGoodsNums() == 0
			)){
				throw new CommonException("柜员交接方式已选择【按号段交接】，请输入起止号码和数量！");
			}
			if(Tools.processNull(rec.getInBrchId()).equals("") || Tools.processNull(rec.getInUserId()).equals("")){
				throw new CommonException("柜员交接接收柜员信息不能为空！");
			}
			if(Tools.processNull(rec.getBrchId()).equals("") || Tools.processNull(rec.getUserId()).equals("")){
				throw new CommonException("柜员交接出库柜员信息不能为空！");
			}
			stockService.saveTellerTransitionMain(rec,deliveryWay,stockService.getUser(),stockService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","柜员交接成功");
		}catch(Exception e){
			String temperror= e.getMessage();
			if(temperror.endsWith("！")) temperror = temperror.substring(0,temperror.length() - 1);
			jsonObject.put("msg","柜员交接发生错误：" + temperror + "！");
		}
		return this.JSONOBJ;
	}
	
	public String saveTellerTransitionAll() {
		try {
			if (Tools.processNull(rec.getInBrchId()).equals("") || Tools.processNull(rec.getInUserId()).equals("")) {
				throw new CommonException("柜员交接接收柜员信息不能为空！");
			}
			if (Tools.processNull(rec.getBrchId()).equals("") || Tools.processNull(rec.getUserId()).equals("")) {
				throw new CommonException("柜员交接出库柜员信息不能为空！");
			}
			stockService.judgeOperPwd(stockService.getUser().getUserId(), pwd);
			stockService.saveTellerTransitionAll(rec, stockService.getUser(), stockService.getCurrentActionLog());
			jsonObject.put("status", "0");
			jsonObject.put("msg", "柜员交接成功");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			String temperror = e.getMessage();
			if (temperror.endsWith("！"))
				temperror = temperror.substring(0, temperror.length() - 1);
			jsonObject.put("msg", "柜员交接发生错误：" + temperror + "！");
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 库存日志查询
	 * @return
	 */
	public String stockRecQuery(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","1");
		jsonObject.put("total","0");
		jsonObject.put("rows",new JSONArray());
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT t.stk_ser_no, t.deal_no, t.stk_code,s.stk_name,t.batch_id,t.task_id,");
			sb.append("(SELECT org_name FROM Sys_Organ WHERE org_id = t.in_org_id) inorgname,");
			sb.append("(SELECT full_name from sys_branch where brch_id = t.in_brch_id) inbrchname,");
			sb.append("(SELECT name from sys_users where user_id = t.in_user_id) inusername ,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'STOCK_ACC_GOODS_STATE' AND CODE_VALUE = t.in_goods_state) goodsstate,");
			sb.append("t.goods_nums,DECODE(t.is_sure,'0','已确认','1','未确认','2','已退库','未说明') issure,");
			sb.append("to_char(t.tr_date,'yyyy-mm-dd hh24:mi:ss') trdate,t.clr_date,t.start_no,t.end_no,");
			sb.append("(SELECT org_name FROM Sys_Organ WHERE org_id = t.out_org_id) outorgname,");
			sb.append("(SELECT full_name from sys_branch where brch_id = t.out_brch_id) outbrchname ,");
			sb.append("(SELECT name from sys_users where user_id = t.out_user_id) outusername ");
			sb.append("from STOCK_REC t,stock_type s WHERE t.stk_code = s.stk_code ");
			if(!Tools.processNull(rec.getStkCode()).equals("")){
				sb.append("and t.stk_code = '" + rec.getStkCode() + "' ");
			}
			if(!Tools.processNull(rec.getInGoodsState()).equals("")){
				sb.append("and t.in_goods_state = '" + rec.getInGoodsState() + "' ");
			}
			if(!Tools.processNull(rec.getIsSure()).equals("")){
				sb.append("and t.is_sure = '" + rec.getIsSure() + "' ");
			}
			if(!Tools.processNull(this.inBeginTime).equals("")){
				sb.append("and to_char(t.tr_date,'yyyy-mm-dd') >= '" + inBeginTime + "' ");
			}
			if(!Tools.processNull(this.inEndTime).equals("")){
				sb.append("and to_char(t.tr_date,'yyyy-mm-dd') <= '" + inEndTime + "' ");
			}
			if(!Tools.processNull(rec.getTaskId()).equals("")){
				sb.append("and t.task_id = '" + rec.getTaskId() + "' ");
			}
			if(!Tools.processNull(rec.getBatchId()).equals("")){
				sb.append("and t.batch_id = '" + rec.getBatchId() + "' ");
			}
			if(!Tools.processNull(rec.getInOrgId()).equals("")){
				sb.append("and t.in_org_id = '" + rec.getInOrgId() + "' ");
			}
			if(!Tools.processNull(rec.getInBrchId()).equals("")){
				sb.append("and t.in_brch_id = '" + rec.getInBrchId() + "' ");
			}
			if(!Tools.processNull(rec.getInUserId()).equals("")){
				sb.append("and t.in_user_id = '" + rec.getInUserId() + "' ");
			}
			if(!Tools.processNull(rec.getOutOrgId()).equals("")){
				sb.append("and t.out_org_id = '" + rec.getOutOrgId() + "' ");
			}
			if(!Tools.processNull(rec.getOutBrchId()).equals("")){
				sb.append("and t.out_brch_id = '" + rec.getOutBrchId() + "' ");
			}
			if(!Tools.processNull(rec.getOutUserId()).equals("")){
				sb.append("and t.out_user_id = '" + rec.getOutUserId() + "' ");
			}
			if(!Tools.processNull(this.sort).equals("")){
				sb.append("order by " + this.sort + " " + this.order);
			}else{
				sb.append("order by tr_date desc");
			}
			Page list = stockService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到库存操作日志！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 库存物品出入库流水
	 * @return
	 */
	public String stockInoutDetailsQuery(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","1");
		jsonObject.put("total","0");
		jsonObject.put("rows",new JSONArray());
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT t.stk_inout_no,s.deal_code_name,t.deal_no,to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealdate,t.goods_id,");
			sb.append("t.goods_no,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'STK_TYPE' AND CODE_VALUE = t.stk_type) stktype,");
			sb.append("t.stk_code,p.stk_name,(SELECT org_name FROM sys_organ WHERE org_id = t.in_org_id) inorgname,");
			sb.append("(SELECT full_name FROM sys_branch WHERE brch_id = t.in_brch_id) inbrchname,");
			sb.append("(SELECT NAME FROM Sys_Users WHERE user_id = t.in_user_id) inusername,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'GOODS_STATE' AND CODE_VALUE = t.in_goods_state) ingoodsstate,");
			sb.append("(SELECT org_name FROM sys_organ WHERE org_id = t.out_org_id) outorgname,");
			sb.append("(SELECT full_name FROM sys_branch WHERE brch_id = t.out_brch_id) outbrchname,");
			sb.append("(SELECT NAME FROM Sys_Users WHERE user_id = t.out_user_id) outusername,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'GOODS_STATE' AND CODE_VALUE = t.out_goods_state) outgoodsstate,");
			sb.append("t.task_id,t.batch_id,t.clr_date,t.note ");
			sb.append("FROM STOCK_INOUT_DETAIL t,stock_type p,Sys_Code_Tr s ");
			sb.append("WHERE t.stk_code = p.stk_code AND t.deal_code = s.deal_code ");
			if(!Tools.processNull(this.beginDate).equals("")){
				sb.append("and to_char(t.deal_date,'yyyy-mm-dd') >= '" + this.beginDate + "' ");
			}
			if(!Tools.processNull(this.endDate).equals("")){
				sb.append("and to_char(t.deal_date,'yyyy-mm-dd') <= '" + this.endDate + "' ");
			}
			if(!Tools.processNull(rec.getGoodsNo()).equals("")){
				sb.append("and t.goods_no = '" + rec.getGoodsNo() + "' ");
			}
			if(!Tools.processNull(rec.getDealNo()).equals("")){
				sb.append("and t.deal_no = '" + this.endDate + "' ");
			}
			if(!Tools.processNull(rec.getInOrgId()).equals("")){
				sb.append("and t.in_org_id = '" + rec.getInOrgId() + "' ");
			}
			if(!Tools.processNull(rec.getInBrchId()).equals("")){
				sb.append("and t.in_brch_id = '" + rec.getInBrchId() + "' ");
			}
			if(!Tools.processNull(rec.getInUserId()).equals("")){
				sb.append("and t.in_user_id = '" + rec.getInUserId() + "' ");
			}
			if(!Tools.processNull(rec.getOutOrgId()).equals("")){
				sb.append("and t.out_org_id = '" + rec.getOutOrgId() + "' ");
			}
			if(!Tools.processNull(rec.getOutBrchId()).equals("")){
				sb.append("and t.out_brch_id = '" + rec.getOutBrchId() + "' ");
			}
			if(!Tools.processNull(rec.getOutUserId()).equals("")){
				sb.append("and t.out_user_id = '" + rec.getOutUserId() + "' ");
			}
			if(!Tools.processNull(rec.getTaskId()).equals("")){
				sb.append("and t.task_id = '" + rec.getTaskId() + "' ");
			}
			if(!Tools.processNull(rec.getBatchId()).equals("")){
				sb.append("and t.batch_id = '" + rec.getBatchId() + "' ");
			}
			if(!Tools.processNull(rec.getStkCode()).equals("")){
				sb.append("and t.stk_code = '" + rec.getStkCode() + "' ");
			}
			sb.append(stockService.getLimitQueryData("t.brch_id","t.user_id"));
			if(!Tools.processNull(this.sort).equals("")){
				sb.append("order by " + this.sort + " " + this.order);
			}else{
				sb.append("order by stk_inout_no desc");
			}
			Page list = stockService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到库存物品出入库流水信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 柜员上交
	 * @return
	 */
	public String toTellerSj(){
		try{
			Users oper = baseService.getUser();
			this.userId = oper.getUserId();
			this.userName = oper.getName();
			SysBranch brch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch t where t.brchId = '" + oper.getBrchId() + "'");
			this.brchId = oper.getBrchId();
			this.brchName = brch.getFullName();
		}catch(Exception e){
			defaultErrorMsg = e.getMessage();
			log.error(e);
		}
		return "totellersj";
	}
	public String saveTellerSj(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			
		}catch(Exception e){
			jsonObject.put("msg","柜员上交发生错误：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 查询库存在信息
	 * 
	 * @return
	 */
	public String queryBranchAccept() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
			if (this.queryType.equals("0")) {
				String head = "", htj = "";
				head += "select to_char(a.action_No), d.code_Name,a.stk_Code,b.stk_Name,  a.make_Batch_Id,a.task_Id,a.start_No,a.end_No,  a.tot_Num,a.tr_Date,a.is_Sure";
				htj += " from Stock_Rec a,Stock_Type b, Sys_Code d where a.stk_Code=b.stk_Code and a.stk_Type = d.code_Value and d.code_Type = 'STK_TYPE'"
						+ " AND D.CODE_VALUE = A.STK_TYPE AND A.IS_SURE='1' AND A.deal_CODE='"+ DealCode.ACC_BLANCE_ENCRYPT+ "' and in_Oper_Id='"+ this.getUserId() + "'";

				// sql += SqlTools.eq("a.stk_Type", rec.getStkType());
				htj += SqlTools.eq("a.stk_Code", rec.getStkCode());
				htj += SqlTools.eq("a.task_Id", rec.getTaskId());
				htj += SqlTools.ge("trunc(a.tr_Date)",DateUtil.formatSqlDate(beginDate));
				htj += SqlTools.le("trunc(a.tr_Date)",DateUtil.formatSqlDate(endDate));
				Page list = stockService.pagingQuery(head + htj.toString(),page, rows);
				if (list.getAllRs() != null) {
					jsonObject.put("rows", list.getAllRs());
					jsonObject.put("total", list.getTotalCount());
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 保存配送信息
	 * @return
	 */
	public String saveBranchAccept() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
		
		stockService.saveBranchAccept(rec, dealnos);
			
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getBrch_Name() {
		return brch_Name;
	}

	public void setBrch_Name(String brch_Name) {
		this.brch_Name = brch_Name;
	}

	public String getOper_Name() {
		return oper_Name;
	}

	public void setOper_Name(String oper_Name) {
		this.oper_Name = oper_Name;
	}

	public StockRec getRec() {
		return rec;
	}

	public void setRec(StockRec rec) {
		this.rec = rec;
	}

	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	public String getBeginDate() {
		return beginDate;
	}

	public void setBeginDate(String beginDate) {
		this.beginDate = beginDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public String getTask_Name() {
		return task_Name;
	}

	public void setTask_Name(String task_Name) {
		this.task_Name = task_Name;
	}

	@Autowired
	public void setStockService(StockService stockService) {
		this.stockService = stockService;
	}
	public String[] getDealnos() {
		return dealnos;
	}
	public void setDealnos(String[] dealnos) {
		this.dealnos = dealnos;
	}
	public String getStkCodeId() {
		return stkCodeId;
	}
	public void setStkCodeId(String stkCodeId) {
		this.stkCodeId = stkCodeId;
	}
	public String getStkTypeId() {
		return stkTypeId;
	}
	public void setStkTypeId(String stkTypeId) {
		this.stkTypeId = stkTypeId;
	}
	public StockList getStock() {
		return stock;
	}
	public void setStock(StockList stock) {
		this.stock = stock;
	}
	public StockAcc getStockAcc() {
		return stockAcc;
	}
	public void setStockAcc(StockAcc stockAcc) {
		this.stockAcc = stockAcc;
	}
	public String getBrchId() {
		return brchId;
	}
	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}
	public String getBrchName() {
		return brchName;
	}
	public void setBrchName(String brchName) {
		this.brchName = brchName;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getOtherBrchId() {
		return otherBrchId;
	}
	public void setOtherBrchId(String otherBrchId) {
		this.otherBrchId = otherBrchId;
	}
	public String getOtherBrchName() {
		return otherBrchName;
	}
	public void setOtherBrchName(String otherBrchName) {
		this.otherBrchName = otherBrchName;
	}
	public String getOtherUserId() {
		return otherUserId;
	}
	public void setOtherUserId(String otherUserId) {
		this.otherUserId = otherUserId;
	}
	public String getOtherUserName() {
		return otherUserName;
	}
	public void setOtherUserName(String otherUserName) {
		this.otherUserName = otherUserName;
	}
	public String getInBeginTime() {
		return inBeginTime;
	}
	public void setInBeginTime(String inBeginTime) {
		this.inBeginTime = inBeginTime;
	}
	public String getInEndTime() {
		return inEndTime;
	}
	public void setInEndTime(String inEndTime) {
		this.inEndTime = inEndTime;
	}
	public String getOutBeginTime() {
		return outBeginTime;
	}
	public void setOutBeginTime(String outBeginTime) {
		this.outBeginTime = outBeginTime;
	}
	public String getOutEndTime() {
		return outEndTime;
	}
	public void setOutEndTime(String outEndTime) {
		this.outEndTime = outEndTime;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
	public String getOrder() {
		return order;
	}
	public void setOrder(String order) {
		this.order = order;
	}
	public String getIsZero() {
		return isZero;
	}
	public void setIsZero(String isZero) {
		this.isZero = isZero;
	}
	public String getBeginGoodsNo() {
		return beginGoodsNo;
	}
	public void setBeginGoodsNo(String beginGoodsNo) {
		this.beginGoodsNo = beginGoodsNo;
	}
	public String getEndGoodsNo() {
		return endGoodsNo;
	}
	public void setEndGoodsNo(String endGoodsNo) {
		this.endGoodsNo = endGoodsNo;
	}
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}
	public StockService getStockService() {
		return stockService;
	}
	public StockType getStockType() {
		return stockType;
	}
	public void setStockType(StockType stockType) {
		this.stockType = stockType;
	}
	public String getTaskIds() {
		return taskIds;
	}
	public void setTaskIds(String taskIds) {
		this.taskIds = taskIds;
	}
	public String getDeliveryWay() {
		return deliveryWay;
	}
	public void setDeliveryWay(String deliveryWay) {
		this.deliveryWay = deliveryWay;
	}
 }
