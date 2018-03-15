<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!queryCardApply.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			fitColumns:true,
			scrollbarSize:0,
			autoRowHeight:true,
			columns:[[   
			    {field:"SETTLEID",title:"id",sortable:true,checkbox:"ture"},
				{field:"BRCH_ID",title:"领卡网点编号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"FULL_NAME",title:"领卡网点名称",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"APPLY_WAY",title:"申领方式",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"TASK_SUM",title:"卡片数量",sortable:true,width : parseInt($(this).width() * 0.05)}
				/* {field:"APPLY_BRCH_ID",title:"申领网点编号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"APPLY_BRCH_NAME",title:"申领网点名称",sortable:true,width : parseInt($(this).width() * 0.08)}, */
			]]
		});
		createSysOrg(
			{id:"orgId",isJudgePermission:false},
			{id:"brchId"},
			{id:"userId"}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			value:"<%=com.erp.util.Constants.CARD_TYPE_SMZK%>",
			isShowDefaultOption:false
		});
		createSysBranch({id:"recvBrchId"});
	});	
	function query(){
		var data = getformdata("searchConts");
		data["queryType"] = "0";
		data["taskStartDate"] = dealNull($("#taskStartDate").val()).replace(/\s/g,"").replace(/-/g,"").replace(/:/g,"");
		data["taskEndDate"] = dealNull($("#taskEndDate").val()).replace(/\s/g,"").replace(/-/g,"").replace(/:/g,"");
		$grid.datagrid("load",data);
	}
	function toCreateTask(){
		 var rows = $grid.datagrid("getChecked");
		 var selectIds = "";
		 if(rows.length == 1){
			for(var d = 0;d < rows.length;d++){
				selectIds = selectIds + rows[d].SETTLEID + ",";
			}
			$.messager.confirm("系统消息","您确定要将选择的记录确认生成任务吗？",function(r){
	     		if(r){
	     			$.messager.progress({text:"正在确认生成任务，请稍后...."});
	  				$.post("taskManagement/taskManagementAction!saveTaskCreate.action",{selectIds:selectIds},function(data){
	  					$.messager.progress("close");
					   	if(data.status == "0"){
					     	$.messager.alert("系统消息","生成任务保存成功","info",function(){
					     		$grid.datagrid("reload");
					     	});
					  	}else{
					     	$.messager.alert("系统消息",data.errMsg,"error");
					    }
  					}, "json");
	     		}
	     	});
		}else{
			$.messager.alert("系统消息","请选择一条记录进行确认","error");
			return;
		}
	}
	function viewCardApply(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$.messager.progress({text:"正在加载，请稍后...."});
			$.modalDialog({
				title:"预览申领明细",
				iconCls:"icon-viewInfo",
				shadow:false,
				border:false,
				maximized:true,
				shadow:false,
				closable:false,
				maximizable:false,
				href:"jsp/taskManage/taskCreateView.jsp?selectIds=" + escape(encodeURIComponent(rows[0].SETTLEID)),
				tools:[{
			    	iconCls:"icon_cancel_01",
					handler:function(){
						$.messager.progress("close");
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
				    }
				}]
			});
		}else{
			$.messager.alert("系统消息","请选择一条记录进行预览","warning");
		}
	}
</script>
<n:initpage title="零星申领数据确认生成任务操作！">
	<n:center>
		<div id="tb" >
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">所属机构：</td>
						<td class="tableright"><input id="orgId" name="apply.orgId" type="text"class="textinput"/></td>
						<td class="tableleft">申领网点：</td>
						<td class="tableright"><input id="brchId" name="apply.applyBrchId" type="text" class="textinput"/></td>
						<td class="tableleft">申领柜员：</td >
						<td class="tableright"><input id="userId" name="apply.applyUserId" type="text" class="textinput"/></td>
						<td class="tableleft">领卡网点：</td>
						<td class="tableright"><input id="recvBrchId" name="apply.recvBrchId" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td >
						<td class="tableright"><input id="cardType" name="apply.cardType" type="text" class="textinput"/></td>
						<td class="tableleft">申领日期开始：</td>
						<td class="tableright" ><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">申领日期结束：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',maxDate:'%y-%M-%d'})"/></td>
						<td style="text-align:center;" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						    <a data-options="iconCls:'icon-viewInfo',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="viewCardApply()">预览</a>
						    <a data-options="iconCls:'icon-save',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toCreateTask();">任务生成</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="申领信息"></table>
	</n:center>
</n:initpage>