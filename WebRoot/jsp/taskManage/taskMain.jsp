<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var isReloadGrid = false;
	var $grid;
	$(function() {
		$.addNumber("makeBatchId");
		$.autoComplete({
			id:"taskId",
			text:"task_id",
			value:"task_name",
			table:"card_apply_task",
			keyColumn:"task_id",
			optimize:true,
			minLength:"1"
		},"taskName");
		$.autoComplete({
			id:"taskName",
			text:"task_name",
			value:"task_id",
			table:"card_apply_task",
			keyColumn:"task_name",
			optimize:true,
			minLength:"1"
		},"taskId");
		$.addNumber("corpId");
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"corp_name",
			minLength:1
		},"corpId");
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_LIST%>"
		});
		createRegionSelect(
			{id:"regionId"},
			{id:"townId"},
			{id:"commId"}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST %>",
			isShowDefaultOption:true
		});
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!cardTaskQuery.action",
			border:false,
			fit:true,
			scrollbarSize:0,
			singleSelect:false,
			showFooter:true,
			pageList:[50,80,100,150,200,300,500]
			<c:choose>
		    	<c:when test='${APP_SHOW_BANK_MSG eq YES_NO_YES}'>
		    		,
			    	frozenColumns:[[
	   					{field:"SETTLEID",title:"id",sortable:true,checkbox:true},
	   					{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.12)},
	   					{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"TASKSTATE",title:"任务状态",sortable:true},
	   					{field:"TASKWAY",title:"任务组织方式",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"CORP_NAME",title:"单位名称",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"TASK_NAME",title:"任务名称",sortable:true},
	   					{field:"TASK_DATE",title:"任务时间",sortable:true,width : parseInt($(this).width() * 0.12)},
	   					{field:"CARD_TYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)} 
	   				]],
	   				columns:[[
	   					{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"TASK_SUM",title:"任务初始数量",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"BANK_ID",title:"审核银行编号",sortable:true},
	   					{field:"BANK_NAME",title:"审核银行名称",sortable:true},
	   					{field:"YH_NUM",title:"审核成功数量",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"LKBRCHNAME",title:"领卡网点",sortable:true,width : parseInt($(this).width() * 0.08)}
	   				]]
		    	</c:when>
			    <c:otherwise>
			    	,
			   		fitColumns:true,
			    	columns:[[
						{field:"SETTLEID",title:"id",sortable:true,checkbox:true},
						{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.12)},
						{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
						{field:"TASKSTATE",title:"任务状态",sortable:true},
						{field:"TASKWAY",title:"任务组织方式",sortable:true,width : parseInt($(this).width() * 0.08)},
						{field:"TASK_NAME",title:"任务名称",sortable:true},
						{field:"TASK_DATE",title:"任务时间",sortable:true,width : parseInt($(this).width() * 0.12)},
						{field:"CARD_TYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
	   					{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
	   					{field:"TASK_SUM",title:"任务数量",sortable:true,width : parseInt($(this).width() * 0.08)}
	   				]]
			    </c:otherwise>
			</c:choose>
			,
			onLoadSuccess:function(){
				updateFooter();
			},
			onSelect:updateFooter,
			onUnselect:updateFooter,
			onSelectAll:updateFooter,
			onUnselectAll:updateFooter
		});
	});
	function updateFooter(){
		var taskNum = 0;
		var taskSum = 0;
		var selections = $grid.datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				taskNum++;
				taskSum += isNaN(selections[i].TASK_SUM)?0:Number(selections[i].TASK_SUM);
			}
		}
		$grid.datagrid("reloadFooter", [{TASK_ID:"统计：", TASK_NAME:"共 " + taskNum + " 个任务", TASK_SUM:taskSum}]);
	}
	function toQuery(){
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		if(params["isNotBlankNum"] < 1){
			$.messager.alert("系统消息","查询参数不能全部为空！请至少输入或选择一个查询参数","warning");
			return;
		}
		$grid.datagrid("load",params);
	}
	function viewTaskList(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$.messager.progress({text:"正在加载，请稍后...."});
			$("#taskListViewWin").window({
				title:"预览任务明细",
				iconCls:"icon-viewInfo",
				shadow:false,
				border:false,
				maximized:true,
				shadow:false,
				closable:false,
				maximizable:false,
				minimizable:false,
				closable:false,
			    collapsed:false,
				collapsible:false,
				href:"jsp/taskManage/viewCardTask.jsp?taskId=" + rows[0].SETTLEID + "&taskState=" + rows[0].TASK_STATE +
						"&taskStateName=" + escape(encodeURIComponent(rows[0].TASKSTATE)) + "&taskWay=" + rows[0].TASK_WAY +
						"&tempTaskWay=<%=com.erp.util.Constants.TASK_WAY_WD%>" + "&tempTaskState=<%=com.erp.util.Constants.TASK_STATE_YSC%>" ,
				tools:[{
			    	iconCls:"icon_cancel_01",
					handler:function(){
						if(isReloadGrid){
							$grid.datagrid("reload");
							isReloadGrid = false;
						}
						$.messager.progress("close");
						$("#taskListViewWin").window("close");
				    }
				}]
			});
		}else{
			$.messager.alert("提示信息","请选择一条记录进行预览","error");
		}
	}
	function toBackTask(){
		var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(rows.length == 1){
			for(var i = 0;i < rows.length;i++){
				if(rows[i].TASK_STATE != "<%=com.erp.util.Constants.TASK_STATE_YSC %>"){
					$.messager.alert("系统消息","任务编号为【" + rows[i].TASK_ID + "】的任务， 状态为【" + rows[i].TASKSTATE + "】，无法进行删除！","error");
					return;
				}else{
					taskIds = taskIds + rows[i].TASK_ID + "|";
				}
			}
			taskIds = taskIds.substring(0,taskIds.length - 1);
			if(dealNull(taskIds).length == 0){
				$.messager.alert("系统消息","勾选的任务信息不存在任务编号，请仔细核对后重试！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要删除所勾选的任务信息吗？",function(r){
	     		if(r){
	     			$.messager.progress({text:"正在回退制卡任务信息，请稍后...."});
	  				 $.post("taskManagement/taskManagementAction!deleteTask.action",{taskIds:taskIds},function(data){
	  					$.messager.progress("close");
				     	if(data.status == "0"){
				     		$.messager.alert("系统消息","删除成功","info",function(){
				     			$grid.datagrid("reload");
				     		});
				     	}else{
				     		$.messager.alert("系统消息",data.errMsg,"error");
				     	}
				    },"json");
	     		}
	     	});
		}else{
			$.messager.alert("系统消息","请选择一条记录进行删除","error");
			return;
		}
	}
	
	function exportTask() {
		var selections = $("#dg").datagrid("getSelections");
		var taskIds = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				if(selections[i].TASK_ID){
					taskIds += "," + selections[i].TASK_ID;
				}
			}
		}
		if(taskIds){
			taskIds = taskIds.substring(1);
		}
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		params["rows"] = 65000;
		params["taskIds"] = taskIds;
		var paraStr = "";
		for(var i in params){
			paraStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({text:"数据处理中..."});
		$('#download').attr('src',"taskManagement/taskManagementAction!exportTask.action?" + paraStr.substring(1));
		startCycle();
	}

	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportTask",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
</script>
<n:initpage title="制卡任务进行管理操作！<span style='color:red'>注意</span>：任务回退时，如果是批量申领，则删除申领记录，删除制卡明细，删除制卡任务；零星申领时:申领记录回退到【已申请】状态，删除制卡明细，删除制卡任务！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="makeBatchId" name="task.makeBatchId" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">任务名称：</td>
						<td class="tableright"><input id="taskName" name="task.taskName" type="text" class="textinput"/></td>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="task.taskState" type="text" class="textinput"/></td>
					</tr>
					<tr>
	                    <td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" name="task.corpId" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright" ><input id="corpName" name="corpName" type="text" class="textinput" maxlength="80"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="task.cardType" type="text"  class="textinput"/></td>
					    <td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="regionId" name="task.regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">乡镇（街道）：</td>
						<td class="tableright"><input id="townId" name="task.townId" type="text" class="textinput"/></td>
						<td class="tableleft">社区（村）：</td>
						<td class="tableright"><input id="commId" name="task.commId" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td colspan="8" class="tableleft" style="padding-right: 2%">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false"   onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-viewInfo',plain:false" onclick="viewTaskList();">任务预览</a>
							<shiro:hasPermission name="taskReBack">
								<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-undo',plain:false" onclick="toBackTask();">任务回退</a>
							</shiro:hasPermission>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export"  plain="false" onclick="exportTask();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="任务信息"></table>
    </n:center>
    <div id="taskListViewWin"></div>
    <iframe id="download" style="display:none"></iframe>
</n:initpage>