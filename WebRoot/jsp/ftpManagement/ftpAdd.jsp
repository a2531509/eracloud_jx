<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
$(function(){
		createCustomSelect({id:"bank",value:"BANK_ID",text:"BANK_NAME",table:"BASE_BANK"});

});
function addFTP() {
	
		if(dealNull($("#host_ip").val()) == ""){
			$.messager.alert("系统消息","请输入host_ip!！","error",function(){
				$("#host_ip").focus();
			});
			return;
		}
		if(dealNull($("#host_port").val()) == ""){
			$.messager.alert("系统消息","请输入host_port！","error",function(){
				$("#host_port").focus();
			});
			return;
		}
		if(dealNull($("#user_name").val()) == ""){
			$.messager.alert("系统消息","请输入user_name！","error",function(){
				$("#user_name").focus();
			});
			return;
		}
		if(dealNull($("#host_history_path").val()) == ""){
			$.messager.alert("系统消息","请输入host_history_path！","error",function(){
				$("#host_history_path").focus();
			});
			return;
		}
		if(dealNull($("#host_upload_path").val()) == ""){
			$.messager.alert("系统消息","请输入host_upload_path！","error",function(){
				$("#host_upload_path").focus();
			});
			return;
		}
		if(dealNull($("#host_download_path").val()) == ""){
			$.messager.alert("系统消息","请输入host_download_path！","error",function(){
				$("#host_download_path").focus();
			});
			return;
		}
		if(dealNull($("#pwd").val()) == ""){
			$.messager.alert("系统消息","请输入pwd！","error",function(){
				$("#pwd").focus();
			});
			return;
		}
		

		$.messager.confirm("系统消息","您确定要新增FTP吗？",function(r){
			 if(r){
				 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				 $.post("ftp/ftpAction!addFTP.action",$("#form").serialize(),function(data,status){
					 $.messager.progress('close');
					 if(status == "success"){
						 $.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
							 if(data.status == "0"){
								 $dg.datagrid("reload");
								 $.modalDialog.handler.dialog('destroy');
								 $.modalDialog.handler = undefined;
							 }
						 });
					 }else{
						 $.messager.alert("系统消息","增加FTP出现错误，请重新进行操作！","error");
						 return;
					 }
				 },"json");
			 }
		});
}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
	<input name="tempId" id="tempId"  type="hidden" value="<%= request.getParameter("tempId")%>"/>
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/> 新增FTP</legend>
				 <table class="tablegrid" style="width:100%">
					 <tr>
					    <th class="tableleft" >银行:</th>
						<td class="tableright"><input id="bank" name="bank" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${bank}"/></td>
					    <th class="tableleft" >用户名:</th>
						<td class="tableright"><input id="user_name" name="user_name" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${user_name}"/></td>
					 </tr>
					 <tr>
						<th class="tableleft">密码:</th>
						<td class="tableright"><input id="pwd"  name="pwd"  class="textinput easyui-validatebox" type="text" data-options="required:true" value="${pwd}" /></td>
						<th class="tableleft" >IP地址:</th>
						<td class="tableright"><input id="host_ip" name="host_ip" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${host_ip}"/></td>
					 </tr>
					 <tr>
						<th class="tableleft">端口号:</th>
						<td class="tableright"><input id="host_port" name="host_port" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${host_port}"/></td>
						<th class="tableleft">历史地址:</th>
						<td class="tableright"><input id="host_history_path" name="host_history_path" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${host_history_path}"/></td>
					 </tr>
					 <tr>
					    <th class="tableleft" >上传地址:</th>
						<td class="tableright"><input id="host_upload_path" name="host_upload_path" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${host_upload_path}"/></td>
						<th class="tableleft">下载地址:</th>
						<td class="tableright"><input id="host_download_path" name="host_download_path" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${host_download_path}"/></td>
					 </tr>
				 </table>
			</fieldset>
		</form>
	</div>
</div>
