<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<script type="text/javascript">
	var $dg;
	$(function() {
		$dg = createDataGrid({
			id:"dg",
			toolbar:"",
			queryParams:{queryType:"0"},
			singleSelect:false,
			url:"stockManage/stockManageAction!stockTaskQuery.action?stkTypeId=" + ${param.type},
			frozenColumns:[[
			    {field:"V_V",checkbox:true},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"TASK_ID",title:"任务号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"TASK_NAME",title:"任务名称",sortable:true},
				{field:"TASK_SUM",title:"任务数量",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"TASKSRC",title:"任务来源",sortable:true,width:parseInt($(this).width()*0.06)}
			]],
			columns:[[
	        	{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"TASKWAY",title:"任务组织方式",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"TASKDATE",title:"任务生成时间",sortable:true,width:parseInt($(this).width()*0.16)},
	        	{field:"ISURGENT",title:"制卡类型",sortable:true,width:parseInt($(this).width()*0.06)},
	        	{field:"TASKSTATE",title:"任务状态 ",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"FULL_NAME",title:"任务生成网点",sortable:true},
	        	{field:"NAME",title:"任务生成柜",sortable:true},
	        	{field:"NOTE",title:"备注",sortable:true}
	        ]]
	   });
	});
	function query(){
		var params = getformdata("stocklistdetails");
		if(params["isNotBlankNum"] == 0){
			$.messager.alert("系统消息","查询参数不能全部为空！","warning");
			return;
		}
		params["queryType"] = "0";
		$dg.datagrid("load",params);
	}
	function selectOneRow(){
		var currow = $dg.datagrid("getChecked");
		if(currow && currow.length){
			var finaltaskids = "";
			for(var i = 0;i<currow.length;i++){
				finaltaskids += currow[i].TASK_ID + ",";
			}
			$("#taskIds").textbox("setValue",(finaltaskids.substring(0,finaltaskids.length - 1)));
			$.modalDialog.handler.dialog("destroy");
			$.modalDialog.handler = undefined;
			$.messager.progress('close');
		}else{
			$.messager.alert("系统消息","请至少选一个任务任务进行保存！","error");
		}
	}
</script>
<n:layout>
	<n:center layoutOptions="border:false,iconCls:'icon-viewInfo'">
  		<table id="dg"></table>
	</n:center>
</n:layout>