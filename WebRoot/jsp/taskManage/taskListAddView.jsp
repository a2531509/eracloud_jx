<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $taskListAddGrid;
	$(function(){
		$taskListAddGrid = createDataGrid({
			id:"taskListAdd",
			url:"taskManagement/taskManagementAction!findNoInsertPerson.action?task.taskId=${param.taskId}",
			border:false,
			singleSelect:false,
			queryParams:{queryType:"0"},
			checkOnSelect:true,
			autoRowHeight:true,
			fitColumns:true,
			scrollbarSize:0,
			toolbar:"",
			columns:[[ 	
             	{field:"PERSON_ID",checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"NAME",title:"姓名",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"CERTTYPE",title:"证件类型",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.15)},
				{field:"GENDER",title:"性别",sortable:true,width : parseInt($(this).width() * 0.06)}
			]]
		});
	});
	function saveAddTaskList(taskViewGrid){
		var addCustomerIds = "";
		var rows = $taskListAddGrid.datagrid("getChecked");
		if(rows && rows.length > 0){
			for(var i = 0;i < rows.length;i++){
				addCustomerIds = addCustomerIds + rows[i].PERSON_ID + "|";
			}
			addCustomerIds = addCustomerIds.substring(0,addCustomerIds.length - 1);
			if(dealNull(addCustomerIds).length == ""){
				$.messager.alert("系统消息","请勾选将要进行添加的人员信息！","error");
			}
			$.messager.confirm("系统消息","您确定要将勾选的人员信息添加到该任务当中去吗？",function(r){
				if(r){
					$.messager.progress({text:"正在进行添加制卡明细，请稍后...."});
					 $.post("taskManagement/taskManagementAction!addTaskList.action",{customerIds:addCustomerIds,"task.taskId":${param.taskId}},function(data){
						$.messager.progress("close");
				     	if(data.status == "0"){
				     		$.messager.alert("系统消息","添加成功！","info",function(){
				     			isReloadGrid = true;
				     			taskViewGrid.datagrid("reload");
			     				$.modalDialog.handler.dialog("close");
				     		});
				     	}else{
				     		$.messager.alert("系统消息",data.errMsg,"error");
				     	}
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选将要进行添加的人员信息！","error");
		}
	}
</script>
<n:layout>
  	<n:center cssStyle="border:none">
  		<table id="taskListAdd" ></table>
  	</n:center>
</n:layout>