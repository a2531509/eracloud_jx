<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
	$(function() {
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		//所属网点
		$("#brchId").combotree({
			url:"orgz/SysBranchAction!findSysBranchList.action",
			idFiled:'id',
		 	textFiled:'name',
		 	parentField:'pid',
		 	width:174,
		 	onSelect:function(node){
		 		$("#brchId").val(node.text);
		 	},
		 	onLoadSuccess:function(){
		 		$("#brchId").combotree("tree").tree("collapseAll");
		 	}
		});
		if("${editType}" == "0" && dealNull("${editType}").length != ""){
			$("#brchId").combotree("setValue","${users.brchId}");
			$("#brchId").combotree("disable");
		}
		//商户结算提醒
		$("#titleId").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"是"},{codeValue:'1',codeName:"否"}]
		});
	});
	//表单提交
	function saveUsers(oldgrid){
		if(dealNull($("#userId").val()).length == 0){
			$.messager.alert("系统消息","柜员编号不能为空！","error",function(){
				$("#userId").focus();
			});
			return false;
		}
		/* if (!$("#password").val().match(/(?!^[0-9]+$)(?!^[A-z]+$)(?!^[^A-z0-9]+$)^.{8,16}$/)){ 
			$.messager.alert("系统消息","柜员密码必须是数字或字母或字符的组合密码，且密码长度不能小于8位，最大16位","error",function(){
				$("#password").focus();
			});
			return false; 
			}  */
		if(dealNull($("#password").val()).length == 0){
			$.messager.alert("系统消息","柜员密码不能为空！","error",function(){
				$("#password").focus();
			});
			return false;
		}
		if(dealNull($("#name").val()).length == 0){
			$.messager.alert("系统消息","柜员名称不能为空！","error",function(){
				$("#name").focus();
			});
			return false;
		}
		if(dealNull($("#dutyId").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","柜员数据权限类型不能为空！","error",function(){
				$("#dutyId").combobox('showPanel');
			});
			return false;
		}
		if(dealNull($("#brchId").combotree("getValue")).length == 0){
			$.messager.alert("系统消息","柜员所属网点不能为空！","error",function(){
				$("#brchId").combotree('showPanel');
			});
			return false;
		}
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		/* var isValid = $(this).form('validate');
		if (!isValid) {
			$.messager.progress('close');
			return;
		}*/
		$("#descriptionId").val(document.getElementById("description").value);//设置备注
		$.post("user/userAction!persistenceUsersDig.action",$("form").serialize(),function(data,status){
			$.messager.progress('close');
			$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
				if(data.status == "0"){
					oldgrid.datagrid("reload",{queryType:"0"});
					$.modalDialog.handler.dialog('close');
				}
			});
		},"json");
		return isValid;
	}
	function saveEdit(oldgrid){
		/* if (!$("#password").val().match(/(?!^[0-9]+$)(?!^[A-z]+$)(?!^[^A-z0-9]+$)^.{8,16}$/)){ 
			$.messager.alert("系统消息","柜员密码必须是数字或字母或字符的组合密码，且密码长度不能小于8位，最大16位","error",function(){
				$("#password").focus();
			});
			return false; 
			}  */
		if(dealNull($("#password").val()).length == 0){
			$.messager.alert("系统消息","柜员密码不能为空！","error",function(){
				$("#password").focus();
			});
			return false;
		}
		if(dealNull($("#name").val()).length == 0){
			$.messager.alert("系统消息","柜员名称不能为空！","error",function(){
				$("#name").focus();
			});
			return false;
		}
		if(dealNull($("#dutyId").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","柜员数据权限类型不能为空！","error",function(){
				$("#dutyId").combobox('showPanel');
			});
			return false;
		}
		if(dealNull($("#brchId").combotree("getValue")).length == 0){
			$.messager.alert("系统消息","柜员所属网点不能为空！","error",function(){
				$("#brchId").combotree('showPanel');
			});
			return false;
		}
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		/* var isValid = $(this).form('validate');
		if (!isValid) {
			$.messager.progress('close');
			return;
		} */
		$("#descriptionId").val(document.getElementById("description").value);//设置备注
		$.post("user/userAction!persistenceUsersDig.action",$("form").serialize(),function(data,status){
			$.messager.progress('close');
			$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
				if(data.status == "0"){
					oldgrid.datagrid("reload",{queryType:"0"});
					$.modalDialog.handler.dialog('close');
				}
			});
		},"json");
		return isValid;
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding:10px;background-color:rgb(245,245,245);">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>用户编辑</legend>
				<input name="users.myid" id="myid"  type="hidden" value="${users.myid}" />
				<input name="users.description" id="descriptionId" type="hidden"/>
				<table class="tablegrid" width="100%">
					 <tr>
					    <th class="tableleft">柜员编号：</th>
						<td class="tableright"><input value="${users.userId}" name="users.userId" id="userId" placeholder="请输入用户账号" class="textinput easyui-validatebox" type="text" <s:if test='%{editType == "0"}'>disabled="disabled"</s:if> /></td>
					 	<th class="tableleft">用户密码：</th>
						<td class="tableright"><input value="${users.password}" id="password" name="users.password" type="password" class="textinput easyui-validatebox"   required="required" /></td>
					 </tr>
					 <tr>
					    <th class="tableleft">柜员名称：</th>
						<td class="tableright"><input value="${users.name}" name="users.name" id="name" type="text" class="textinput easyui-validatebox" required="required"/></td>
						<th class="tableleft">邮箱：</th>
						<td class="tableright"><input value="${users.email}" id="email" name="users.email" type="text" class="textinput easyui-validatebox" required="required"/></td>
					 </tr>
					  <tr>
						<th class="tableleft">电话：</th>
						<td class="tableright"><input value="${users.tel}" id="tel" name="users.tel" type="text" class="textinput easyui-validatebox" required="required"/></td>
						<th class="tableleft">数据权限：</th>
						<td class="tableright">
						<input name="users.dutyId"  id="dutyId"  class="easyui-combobox" <s:if test='%{editType == "0"}'>value="${users.dutyId}"</s:if>   style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '0',
									value: '一般柜员'
								},{
									label: '1',
									value: '网点主管'
								},{
									label: '2',
									value: '网点及子网点'
								},{
									label: '3',
									value: '当前机构'
								},{
									label: '4',
									value: '机构及子机构'
								},{
									label: '9',
									value: '所有数据权限'
								}]" />
					   </td>
					 </tr>
					 <tr>
					 	<th class="tableleft">商户结算提醒权限：</th>
						<td class="tableright"><input value="${users.titleId}" id="titleId" name="users.titleId" type="text" class="easyui-combobox"/></td>
					    <th class="tableleft">所属网点：</th>
						<td class="tableright"><input id="brchId" name="users.brchId" type="text" class="textinput" /></td>
					 </tr>
					  <tr>
					 	<th class="tableleft">密码有效期：</th>
						<td class="tableright"><input  id="passwordValidity" value="180" name="users.passwordValidity" type="text" class="textinput""/>天</td>
					 </tr>
					 <tr>
						<th class="tableleft">描述：</th>
						<td class="tableright" colspan="3"><textarea class="textinput" name="description" id="description" style="width:610px;height: 100px;overflow:hidden;">${users.description}</textarea></td>
					</tr>
				 </table>
			</fieldset>
		</form>
	</div>
</div>
