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
			 ],
			 value:"1"
		});
		$dg = createDataGrid({
			id:"dg",
			toolbar:"#tb",
			singleSelect:false,
			url:"stockManage/stockManageAction!stockDeliveryRecQuery.action",
			frozenColumns:[[
			    {field:"V_V",checkbox:true},
				{field:"STK_SER_NO",title:"库存流水",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"STK_CODE",title:"库存代码",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"STK_NAME",title:"库存类型",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width()*0.12)}
			]],
			columns:[[
	        	{field:"GOODSSTATE",title:"物品状态",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"GOODS_NUMS",title:"物品数量",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"TRDATE",title:"配送日期",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"ISSURE",title:"配送确认状态",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"INORGNAME",title:"接收机构",sortable:true},
				{field:"INBRCHNAME",title:"接收网点",sortable:true},
	        	{field:"INUSERNAME",title:"接收柜员",sortable:true},
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
			$.messager.alert("系统消息","查询参数不能全部为空！","warning");
			return;
		}
		params["queryType"] = "0";
		params["isZero"] = "0";
		params["_timeout_"] = Math.random();
		$dg.datagrid("load",params);
	}	
	function stockDeliveryConfirm(){
		var selects = $dg.datagrid("getSelections");
		if(selects.length > 0){
			var stkSerNos = "";
			for(var i = 0; i < selects.length;i++){
				stkSerNos += selects[i].STK_SER_NO + ",";
			}
			$.messager.confirm("系统消息","您确定要确认勾选的库存配送记录信息吗？<br><span style='color:red'>提示：批量操作请当心，已勾选" + selects.length + "条记录</span",function(m) {
				if(m){
					$.messager.progress({text : '正在进行库存配送确认，请稍后....'});
					stkSerNos = stkSerNos.substring(0,stkSerNos.length - 1);
					$.post("stockManage/stockManageAction!saveStockDeliveryConfirm.action",{taskIds:stkSerNos},function(data,status){
						$.messager.progress('close');
						if(status == "success"){
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
								if(data.status == "0"){
									$dg.datagrid("reload");
								}else{
									
								}
							});
						}else{
							$.messager.alert("系统消息","库存配送确认发生错误，请重试！","error");
						}
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请至少选择一条配送记录进行确认","error");
		}
	}
</script>
<n:initpage title="库存配送信息进行确认操作！<span style='color:red'>注意：</span>只有库存配送的接收人才能进行库存配送确认操作！">
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
						<td class="tableleft">配送起始日期：</td>
						<td class="tableright"><input name="inBeginTime" id="inBeginTime" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">配送截止日期：</td>
						<td class="tableright"><input name="inEndTime" id="inEndTime" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright">
							<input name="rec.taskId" id="taskId" class="textinput" type="text"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="stockDeliveryConfirm()">配送确认</a>
						</td>
					</tr>
					<!-- 
					<tr>
						<td class="tableleft">物品状态：</td>
						<td class="tableright"><input name="rec.inGoodsState" id="inGoodsState" class="textinput" type="text"/></td>
						<td class="tableleft">接收网点：</td>
						<td class="tableright"><input name="rec.inBrchId" type="text" class="textinput  easyui-validatebox" id="inBrchId"  style="width:174px;"/></td>
						<td class="tableleft">接收柜员：</td>
						<td class="tableright"><input name="rec.inUserId" type="text" class="textinput  easyui-validatebox" id="inUserId"  style="width:174px;"/></td>
					</tr>
					-->
				</table>
			</form>
		</div>
  		<table id="dg" title="库存配送记录"></table>
	</n:center>
</n:initpage>