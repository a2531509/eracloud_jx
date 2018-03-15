<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $gridview;
	var taskState = "${param.taskState}";
	var taskStateName = decodeURI("${param.taskStateName}");
	$(function(){
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			to:10
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:1,
			to:10
		},"certNo");
		$gridview = createDataGrid({
			id:"dgview",
			url:"taskManagement/taskManagementAction!queryCardTaskList.action?taskList.taskId=${param.taskId}" ,
			border:false,
			fit:true
			<c:if test='${param.taskWay ne param.tempTaskWay}'>
		    <c:if test='${param.taskState eq param.tempTaskState}'>
				,
				singleSelect:false
			</c:if>
		    </c:if>,
			queryParams:{queryType:"0"},
			scrollbarSize:0,
			pageSize:20,
			toolbar:"#tbview"
			<c:choose>
		    	<c:when test='${APP_SHOW_BANK_MSG eq YES_NO_YES}'>
			    	,
			    	frozenColumns:[[
						<c:if test='${param.taskWay ne param.tempTaskWay}'>
						<c:if test='${param.taskState eq param.tempTaskState}'>
							{field:"DATA_SEQ",checkbox:true},
						</c:if>
						</c:if>	
						{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.12)},
						{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.08)},
						{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.06)},
						{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
						{field:"GENDERS",title:"性别",sortable:true,width:parseInt($(this).width() * 0.03)},
						{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
						{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.14)}      
			    	]],
			    	columns:[[
						{field:"APPLYSTATE",title:"申领状态",sortable:true,width:parseInt($(this).width() * 0.06)},
						{field:"BANK_ID",title:"银行编号",sortable:true,width:parseInt($(this).width() * 0.1)},
						{field:"BANK_NAME",title:"银行名称",sortable:true},
						{field:"BANK_CARD_NO",title:"银行卡卡号",sortable:true},
						{field:"BANK_CHECKREFUSE_REASON",title:"审核失败原因",sortable:true},
						{field:"RESIDE_ADDR",title:"居住地址",sortable:true}
					]]
		    	</c:when>
			    <c:otherwise>
				    ,fitColumns:true,
			    	columns:[[
						<c:if test='${param.taskWay ne param.tempTaskWay}'>
					    <c:if test='${param.taskState eq param.tempTaskState}'>
					    	{field:"DATA_SEQ",checkbox:true},
					    </c:if>
					    </c:if>	
						{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.08)},
						{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.06)},
						{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
						{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.1)},
						{field:"GENDERS",title:"性别",sortable:true,width:parseInt($(this).width() * 0.03)},
						{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.04)},
						{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.12)},
						{field:"APPLYSTATE",title:"申领状态",sortable:true},
						{field:"RESIDE_ADDR",title:"居住地址",sortable:true}
					]]
			    </c:otherwise>
			</c:choose>
		});
	});
	function toQueryTaskList(){
		var params = getformdata("viewSearchConts");
		params["queryType"] = "0";
		params["taskList.name"] = $("#name").val();
		$gridview.datagrid("load",params);
	}
	function deleteTaskList(){
		var rows = $gridview.datagrid("getChecked");
		var dataSeqs = "";
		var customerIds = "";
		if(taskState != "<%=com.erp.util.Constants.TASK_STATE_YSC %>"){
			$.messager.alert("系统消息","任务状态为【" + taskStateName + "】状态，无法进行人员删除","error");
			return;
		}
		if(rows && rows.length > 0){
			for(var i = 0;i < rows.length;i++){
				dataSeqs = dataSeqs + rows[i].DATA_SEQ + "|";
				customerIds = customerIds + rows[i].CUSTOMER_ID + "|";
			}
			dataSeqs = dataSeqs.substring(0,dataSeqs.length - 1);
			customerIds = customerIds.substring(0,customerIds.length - 1);
			if(dataSeqs.length == 0){
				$.messager.alert("系统消息","请勾选将要进行删除的的制卡明细信息！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要删除勾选的制卡明细信息吗？",function(r){
	     		if(r){
	     			$.messager.progress({text:"正在进行删除制卡明细，请稍后...."});
	  				$.post("taskManagement/taskManagementAction!deleteTaskDetails.action",
	  					{
	  						dataSeqs:dataSeqs,
	  						customerIds:customerIds,
	  						"task.taskId":rows[0].TASK_ID
	  					},function(data){
	  					$.messager.progress("close");
				     	if(data.status == "0"){
				     		isReloadGrid = true;
				     		$.messager.alert("系统消息","删除成功","info",function(){
				     			$gridview.datagrid("reload");
				     		});
				     	}else{
				     		$.messager.alert("系统消息",data.errMsg,"error");
				     	}
					},"json");
	     		}
	     	});
		}else{
			$.messager.alert("系统消息","请勾选将要进行删除的明细信息！","error");
		}
	}
	function toAdd(){
		if(taskState != "<%=com.erp.util.Constants.TASK_STATE_YSC %>"){
			 $.messager.alert("系统消息","任务状态为【" + taskStateName + "】状态，无法进行增加人员！","error");
			 return;
		}
		$.modalDialog({
			title:"人员信息预览",
			iconCls:"icon-viewInfo",
			width:700,
			height:400,
			closable:false,
			maximizable:true,
			href:"jsp/taskManage/taskListAddView.jsp?taskId=${param.taskId}",
			buttons:[
			    {
					text:"保存",
					iconCls:"icon-ok",
					handler:function(){
						saveAddTaskList($gridview);
					}
				},
				{
					text:"取消",
					iconCls:"icon-cancel",
					handler:function() {
						$.modalDialog.handler.dialog("destroy");
					    $.modalDialog.handler = undefined;
					}
				}
		   	]
		});
	}
</script>
<n:layout>
	<n:center cssStyle="border:none">
		<div id="tbview">
			<form id="viewSearchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:7%;">姓名：</td>
						<td class="tableright" style="width:18%;"><input id="name" name="taskList.name" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft" style="width:7%;">证件号码：</td>
						<td class="tableright" style="width:18%;"><input id="certNo" name="taskList.certNo" type="text" class="textinput" maxlength="18"/></td>
						<td class="tableleft" style="width:7%;">卡号：</td>
						<td class="tableright" style="width:18%;"><input id="cardNo" name="taskList.cardNo" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableright" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryTaskList()">查询</a>
							<c:if test='${param.taskWay != param.tempTaskWay}'>
								<c:if test='${param.taskState eq param.tempTaskState}'>
									<shiro:hasPermission name="deleteTaskList">
									   <a data-options="iconCls:'icon-remove',plain:false" href="javascript:void(0);" class="easyui-linkbutton"  onclick="deleteTaskList();">删除人员</a>
								    </shiro:hasPermission>
								    <shiro:hasPermission name="addTaskList">
										<a data-options="iconCls:'icon-add',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toAdd();">添加人员</a>
									</shiro:hasPermission>
								</c:if>
							</c:if>
						</td>
					</tr>
				</table>
			</form>
		</div>
	  	<table id="dgview"></table>
	</n:center>
</n:layout>