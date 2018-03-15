<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">


function editFTP() {
	if(dealNull($("#ftpUseEdit").val()) == ""){
		$.messager.alert("系统消息","请输入ftpUseEdit！","error",function(){
			$("#ftpUseEdit").focus();
		});
		return;
	}
	if(dealNull($("#ftpParaNameEdit").val()) == ""){
		$.messager.alert("系统消息","请输入ftpParaNameEdit！","error",function(){
			$("#ftpParaNameEdit").focus();
		});
		return;
	}
	if(dealNull($("#ftpParaValueEdit").val()) == ""){
		$.messager.alert("系统消息","请输入ftpParaValueEdit！","error",function(){
			$("#ftpParaValueEdit").focus();
		});
		return;
	}

	$.messager.confirm("系统消息","您确定要编辑FTP吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("ftp/ftpAction!editsaveFTP.action",$("#form").serialize(),function(data,status){
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
					 $.messager.alert("系统消息","编辑FTP出现错误，请重新进行操作！","error");
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
			<h3 class="subtitle">FTP编辑</h3>
				 <table class="tablegrid" style="width:100%">
					 <tr>
					    <th class="tableleft" >银行:</th>
						<td class="tableright" colspan="3"><input style="width:450px" id="ftpUseEdit" width="50px" name="sysFtpConf.id.ftpUse" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${sysFtpConf.id.ftpUse}" readonly="readonly"/></td>
					 </tr>
					 <tr>
						<th class="tableleft">参数名称:</th>
						<td class="tableright"><input id="ftpParaNameEdit" name="sysFtpConf.id.ftpParaName" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${sysFtpConf.id.ftpParaName}" readonly="readonly"/></td>
						<th class="tableleft">参数值:</th>
						<td class="tableright"><input id="ftpParaValueEdit"  name="sysFtpConf.ftpParaValue"  class="textinput easyui-validatebox" type="text" data-options="required:true" value="${sysFtpConf.ftpParaValue}" /></td>
					 </tr>
				 </table>
		</form>
	</div>
</div>
