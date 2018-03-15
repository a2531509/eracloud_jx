<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
$(function(){
	createLocalDataSelect({
		id:"codeState",
	    data:[{value:'',text:"请选择"},{value:'0',text:"正常"},{value:'1',text:"停用"}]
	});
	$('#codeState').combobox('setValue', '${sysCode.codeState}');

});
function saveEditSysCode() {
	if(dealNull($("#codeType").val()) == ""){
		$.messager.alert("系统消息","请输入代码类别！","error",function(){
			$("#codeType").focus();
		});
		return;
	}
	if(dealNull($("#typeName").val()) == ""){
		$.messager.alert("系统消息","请输入类别名称！","error",function(){
			$("#typeName").focus();
		});
		return;
	}
	if(dealNull($("#codeValue").val()) == ""){
		$.messager.alert("系统消息","请输入代码值！","error",function(){
			$("#codeValue").focus();
		});
		return;
	}
	if(dealNull($("#codeName").val()) == ""){
		$.messager.alert("系统消息","请输入代码名称！","error",function(){
			$("#codeName").focus();
		});
		return;
	}
	if(dealNull($("#ordNo").val()) == ""){
		$.messager.alert("系统消息","请输入排序！","error",function(){
			$("#ordNo").focus();
		});
		return;
	}
	if(dealNull($("#codeState").val()) == ""){
		$.messager.alert("系统消息","请选择状态！","error",function(){
			$("#codeState").focus();
		});
		return;
	}	
	if(dealNull($("#fieldName").val()) == ""){
		$.messager.alert("系统消息","请输入类中属性名称！","error",function(){
			$("#fieldName").focus();
		});
		return;
	}


	$.messager.confirm("系统消息","您确定要编辑据字典吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("sysCode/sysCodeAction!editsaveSysCode.action",$("#form").serialize(),function(data,status){
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
					 $.messager.alert("系统消息","编辑增加数据字典出现错误，请重新进行操作！","error");
					 return;
				 }
			 },"json");
		 }
	});
}

//新增数据字典
function saveSysCode() {
	if(dealNull($("#codeType").val()) == ""){
		$.messager.alert("系统消息","请输入代码类别！","error",function(){
			$("#codeType").focus();
		});
		return;
	}
	if(dealNull($("#typeName").val()) == ""){
		$.messager.alert("系统消息","请输入类别名称！","error",function(){
			$("#typeName").focus();
		});
		return;
	}
	if(dealNull($("#codeValue").val()) == ""){
		$.messager.alert("系统消息","请输入代码值！","error",function(){
			$("#codeValue").focus();
		});
		return;
	}
	if(dealNull($("#codeName").val()) == ""){
		$.messager.alert("系统消息","请输入代码名称！","error",function(){
			$("#codeName").focus();
		});
		return;
	}
	if(dealNull($("#ordNo").val()) == ""){
		$.messager.alert("系统消息","请输入排序！","error",function(){
			$("#ordNo").focus();
		});
		return;
	}
	if(dealNull($("#codeState").val()) == ""){
		$.messager.alert("系统消息","请选择状态！","error",function(){
			$("#codeState").focus();
		});
		return;
	}
	if(dealNull($("#fieldName").val()) == ""){
		$.messager.alert("系统消息","请输入类中属性名称！","error",function(){
			$("#fieldName").focus();
		});
		return;
	}

	$.messager.confirm("系统消息","您确定要新增数据字典吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("sysCode/sysCodeAction!saveSysCode.action",$("#form").serialize(),function(data,status){
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
					 $.messager.alert("系统消息","增加数据字典出现错误，请重新进行操作！","error");
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/> 代码编辑</legend>
				<input name="codeId" id="codeId"  type="hidden"/>
				<input name="created" id="created"  type="hidden"/>
				<input name="permissionName" id="permissionName"  type="hidden"/>
				<input name="codePid" id="codePid"  type="hidden"/>
				 <table class="tablegrid" style="width:100%">
					 <tr>
					    <th class="tableleft" style="width:10%">代码类别</th>
						<td class="tableright"><input id="codeType" name="sysCode.id.codeType" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${sysCode.id.codeType}"/></td>
						<th class="tableleft">类别名称</th>
						<td class="tableright"><input id="typeName" name="sysCode.typeName" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${sysCode.typeName}"/></td>
					 </tr>
					 <tr>
						<th class="tableleft">代码值</th>
						<td class="tableright"><input id="codeValue"  name="sysCode.id.codeValue"  class="textinput easyui-validatebox" type="text" data-options="required:true" value="${sysCode.id.codeValue}" /></td>
					 	<th class="tableleft">代码名称</th>
						<td class="tableright"><input id="codeName" name="sysCode.codeName" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${sysCode.codeName}"/></td>
					 </tr>
					 <tr>
					    <th class="tableleft">排序</th>
						<td class="tableright"><input id="ordNo" name="sysCode.ordNo" type="text" class="textinput easyui-validatebox" data-options="required:true" value="${sysCode.ordNo}"/></td>
						<th class="tableleft">状态</th>
						<td class="tableright"><input id="codeState" name="sysCode.codeState" class="textinput easyui-validatebox" style="width:171px;" data-options="required:true" /></td>
					 </tr>
					 <tr>
						<th class="tableleft">类中属性名称</th>
						<td class="tableright"><input id="fieldName" name="sysCode.fieldName" class="textinput easyui-validatebox" type="text" data-options="required:true" value="${sysCode.fieldName}"/></td>
					</tr>
					<tr>					 
						<th >描述</th>
						<td colspan="3"><textarea class="textinput" name="description"  style="width: 415px;height: 100px;"></textarea></td>
					</tr>
				 </table>
			</fieldset>
		</form>
	</div>
</div>
