<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $dg;
	var $stkCode;
	$(function() {
		createSysOrg(
			{
				id:"inOrgId",
				isJudgePermission:false,
				isShowDefaultOption:true
			},
			{id:"inBrchId"},
			{id:"inUserId"}
		);
		createSysOrg({id:"outOrgId",isJudgePermission:false},{id:"outBrchId"},{id:"outUserId"});
		$stkCode = createCustomSelect({
			id:"stkCode",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",where:"stk_code is not null ",
			isShowDefaultOption:true,
			orderby:"stk_code asc",
			from:1,
			to:30
		});
		$dg = createDataGrid({
			id:"dg",
			toolbar:"#tb",
			singleSelect:true,
			url:"stockManage/stockManageAction!stockInoutDetailsQuery.action",
			pageList:[30,50,100,150,200,500],
			frozenColumns:[[
				{field:"STK_INOUT_NO",title:"库存流水",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"DEAL_CODE_NAME",title:"业务类型",sortable:true},
				{field:"DEAL_NO",title:"业务流水",sortable:true},
	        	{field:"DEALDATE",title:"操作日期",sortable:true},
				//{field:"GOODS_ID",title:"物品唯一编号",sortable:true},
				{field:"GOODS_NO",title:"物品编号",sortable:true},
	        	{field:"STKTYPE",title:"库存种类",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"STK_NAME",title:"库存类型",sortable:true,width:parseInt($(this).width()*0.05)}
			]],
			columns:[[
				{field:"INORGNAME",title:"收方机构",sortable:true},
				{field:"INBRCHNAME",title:"收方网点",sortable:true},
	        	{field:"INUSERNAME",title:"收方柜员",sortable:true},
	        	{field:"INGOODSSTATE",title:"收方物品状态",sortable:true,width:parseInt($(this).width()*0.08)},
	        	{field:"OUTORGNAME",title:"付方机构",sortable:true},
	        	{field:"OUTBRCHNAME",title:"付方网点",sortable:true},
	        	{field:"OUTUSERNAME",title:"付方柜员",sortable:true},
	        	{field:"OUTGOODSSTATE",title:"付方物品状态",sortable:true,width:parseInt($(this).width()*0.08)},
	        	{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width()*0.1)},
	        	{field:"BATCH_ID",title:"批次号",sortable:true},
	        	{field:"CLR_DATE",title:"清分日期",sortable:true,width:parseInt($(this).width()*0.15)},
	        	{field:"NOTE",title:"备注",sortable:false}
	        ]]
	   });
	   $.addNumber("taskId");
	   //$.addNumber("batchId");
	   $.addNumber("dealNo");
	});
	function query(){
		var params = getformdata("stockDeliveryConfirm");
		if(params["isNotBlankNum"] == 0){
			$.messager.alert("系统消息","查询参数不能全部为空！","warning");
			return;
		}
		params["queryType"] = "0";
		params["_timeout_"] = Math.random();
		$dg.datagrid("load",params);
	}	
</script>
<n:initpage title="库存物品出入库流水进行查询操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="stockDeliveryConfirm">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">库存代码：</td>
						<td class="tableright"><input name="rec.stkCode" id="stkCode" class="textinput" type="text"/></td>
						<td class="tableleft">业务流水：</td>
						<td class="tableright"><input name="rec.dealNo" id="dealNo" class="textinput" type="text" maxlength="10"/></td>
						<td class="tableleft">物品编号：</td>
						<td class="tableright" style="width:25%"><input name="rec.goodsNo" class="textinput" id="goodsNo" value="" type="text" maxlength="20"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input name="beginDate" id="beginDate" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">截止日期：</td>
						<td class="tableright"><input name="endDate" id="endDate" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务编号：</td>
						<td class="tableright"><input name="rec.taskId" id="taskId" class="textinput" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">收方机构：</td>
						<td class="tableright"><input name="rec.inOrgId"  type="text" class="textinput" id="inOrgId"/></td>
						<td class="tableleft">收方网点：</td>
						<td class="tableright"><input name="rec.inBrchId" type="text" class="textinput" id="inBrchId"/></td>
						<td class="tableleft">收方柜员：</td>
						<td class="tableright"><input name="rec.inUserId" type="text" class="textinput" id="inUserId"/></td>
					</tr>
					<tr>
						<td class="tableleft">付方机构：</td>
						<td class="tableright"><input name="rec.outOrgId"  type="text" class="textinput" id="outOrgId"/></td>
						<td class="tableleft">付方网点：</td>
						<td class="tableright"><input name="rec.outBrchId" type="text" class="textinput" id="outBrchId"/></td>
						<td class="tableleft">付方柜员：</td>
						<td class="tableright">
							<input name="rec.outUserId" type="text" class="textinput" id="outUserId"/>
							<a  data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div> 
  		<table id="dg" title="库存物品出入库流水"></table>
	</n:center>
</n:initpage>