<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
	<script type="text/javascript">
	function saveSelect(dg,taskId,fg){
		 var dataSeqs="";
		 var rows =dg.datagrid('getChecked');
		 if(rows.length > 0){
			 //组转勾选的参数
			 for(var i=0;i<rows.length;i++){
				 dataSeqs = dataSeqs+rows[i].PERSON_ID+"|";
			 }
			 parent.$.post("/madeCardTask/madeCardTaskAction!addTaskMx.action", {personIds:dataSeqs,taskId:taskId},
					   function(data){
					     	if(data.status == '0'){
					     		$.messager.confirm('系统消息','添加成功', function(r){
					     			if (r){
					     				fg.datagrid('reload');
					     				parent.$.modalDialog.handler.dialog('close');
					     			}
					     		});
					     	}else{
					     		$.messager.alert('系统消息',data.errMsg,'error');
					     	}
					   }, "json");
		 }else{
			 $.messager.alert('系统消息','请选择记录','info');
		 }
		
	}
	</script>
  <div class="easyui-layout" data-options="fit:true">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
	  		<table id="dgcc" ></table>
	  </div>
  </div>
