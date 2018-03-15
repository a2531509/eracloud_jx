<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $dg;
	var $stkCode;
	$(function() {
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
		createLocalDataSelect("isSure",{
			 data:[
			       {value:"",text:"请选择"},
			       {value:"0",text:"已确认"},
			       {value:"1",text:"未确认"},
			       {value:"2",text:"已退库"}
			 ]
		});
		$dg = createDataGrid({
			id:"dg",
			toolbar:"#tb",
			singleSelect:true,
			url:"stockManage/stockManageAction!stockRecQuery.action",
			frozenColumns:[[
				{field:"STK_SER_NO",title:"库存流水",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"INORGNAME",title:"收方机构",sortable:true},
				{field:"INBRCHNAME",title:"收方网点",sortable:true},
	        	{field:"INUSERNAME",title:"收方柜员",sortable:true},
				{field:"STK_CODE",title:"库存代码",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"STK_NAME",title:"库存类型",sortable:true,width:parseInt($(this).width()*0.08)},
	        	{field:"GOODSSTATE",title:"物品状态",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"GOODS_NUMS",title:"物品数量",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width()*0.12)}
			]],
			columns:[[
	        	{field:"TRDATE",title:"配送日期",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"ISSURE",title:"配送确认状态",sortable:true,width:parseInt($(this).width()*0.08)},
	        	{field:"OUTORGNAME",title:"配送机构",sortable:true},
	        	{field:"OUTBRCHNAME",title:"配送网点",sortable:true},
	        	{field:"OUTUSERNAME",title:"配送柜员",sortable:true},
	        	{field:"DEAL_NO",title:"业务流水",sortable:true,width:parseInt($(this).width()*0.06)},
	        	{field:"CLR_DATE",title:"清分日期",sortable:true,width:parseInt($(this).width()*0.1)},
	        	{field:"START_NO",title:"起始卡号",sortable:true,width:parseInt($(this).width()*0.15)},
	        	{field:"END_NO",title:"截止卡号",sortable:true,width:parseInt($(this).width()*0.15)},
	        ]]
	   });
	   addNumberValidById("taskId");
	   addNumberValidById("batchId");
	});
	function query(){
		var params = getformdata("stockDeliveryConfirm");
		if(params["isNotBlankNum"] == 0){
			//$.messager.alert("系统消息","查询参数不能全部为空！","warning");
			//return;
		}
		params["queryType"] = "0";
		params["_timeout_"] = Math.random();
		$dg.datagrid("load",params);
	}	
</script>
<n:initpage title="库存账户操作日志进行查询操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="stockDeliveryConfirm">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">库存代码：</td>
						<td class="tableright"><input name="rec.stkCode" id="stkCode" class="textinput" type="text"/></td>
						<td class="tableleft">配送状态：</td>
						<td class="tableright"><input name="rec.isSure" id="isSure" class="textinput" type="text"/></td>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input name="rec.batchId"  class="textinput" id="batchId" value="" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input name="inBeginTime" id="inBeginTime" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">截止日期：</td>
						<td class="tableright"><input name="inEndTime" id="inEndTime" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright">
							<input name="rec.taskId" id="taskId" class="textinput" type="text"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
					<!-- 
					<tr>
						<td class="tableleft">收方机构：</td>
						<td class="tableright"><input name="rec.inOrgId"  type="text" class="textinput" id="inOrgId"/></td>
						<td class="tableleft">收方网点：</td>
						<td class="tableright"><input name="rec.inBrchId" type="text" class="textinput" id="inBrchId"/></td>
						<td class="tableleft">收方柜员：</td>
						<td class="tableright"><input name="rec.inUserId" type="text" class="textinput" id="inUserId"/></td>
					</tr>
					 -->
				</table>
			</form>
		</div>
  		<table id="dg" title="库存账户操作日志"></table>
	</n:center>
</n:initpage>