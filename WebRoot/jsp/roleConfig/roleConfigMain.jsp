<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>权限编辑</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $role;
		var $user;
		$(function() {
			$user = $("#user");
			$user.datagrid({
				url : "user/userAction!findAllUserList.action",
				width : 'auto',
				fit:true,
				pagination:true,
				rownumbers:true,
				singleSelect:true,
				queryParams:{queryType:"0"},
				striped:true,
				border:false,
				columns : [ [ {field : 'MYID',title : '用户编码',width : parseInt($(this).width()*0.1),align : 'left',editor : "text"},
				              {field : 'USER_ID',title : '用户账号',width : parseInt($(this).width()*0.1),align : 'left',editor : "text"},
				              {field : 'NAME',title : '用户名',width : parseInt($(this).width()*0.1),editor : {type:'validatebox',options:{required:true}}},
				              //{field : 'password',title : '用户密码',width : 100,editor : "validatebox"},
				              //{field : 'email',title : '邮箱',width : 150,align : 'left',editor : {type:'validatebox',options:{required:true,validType:'email'}}},
				              //{field : 'tel',title : '电话',width : 100,align : 'left',editor : "text"},
							  {field : 'ORG_NAME',title : '组织部门',width : parseInt($(this).width()*0.1),align : 'left',editor : "text"},
				              //{field : 'DESCRIPTION',title : '描述',width : parseInt($(this).width()*0.1),align : 'left',editor : "text"}
				              ] ],toolbar:"#tbUser",onDblClickRow:getRoles
			});
			$role = $("#role");
			$role.datagrid({
					url : "permission/permissionAssignmentAction!findAllRoleListNotPage.action",
					width : 'auto',
					//height : $(this).height()-120,
					pagination:false,
					border:false,
					rownumbers:true,
					singleSelect:false,
					striped:true,
					scrollbarSize:0,
					//fitColumns:true,
					//fit:true,
					idField: 'CK',
					columns : [ [ {field:'CK',checkbox:true},
					              {field:'NAME',title : '角色名称',align:'center',editor : {type:'validatebox',options:{required:true}},width:parseInt($(this).width()*0.15)},
					              {field:'DESCRIPTION',title:'角色描述',align:'center',editor:"text",width:parseInt($(this).width()*0.15)}
					              ] ],toolbar:"#tbRole"
			});
			
		});
		
		function queryUser(){
			$user.datagrid('load',{
				queryType:'0',//查询类型
				userId:$("#userId").val(),
				operName:$("#operName").val()
			});
		}
		function queryRole(){
			$role.datagrid('load',{
				queryType:'0',//查询类型
				rowName:$("#rowName").val()
			});
		}
		
		 function saveUserRoles(){
			 var selectRow=$user.datagrid("getSelected");
			 var selectRows=$role.datagrid("getSelections");
			 var isCheckedIds=[];
			 $.each(selectRows,function(i,e){
				 isCheckedIds.push(e.CK);
			 });
			 if(selectRow){
				 $.ajax({
						url:"user/userAction!saveUserRoles.action",
						data: "userId="+selectRow.MYID+"&isCheckedIds="+isCheckedIds,
						success: function(rsp){
								parent.$.messager.show({
									title :rsp.title,
									msg :rsp.message,
									timeout : 1000 * 2
								});
						},
						error:function(){
							parent.$.messager.show({
								title :"提示",
								msg :"保存用户角色失败！",
								timeout : 1000 * 2
							});
						}

					});
			 }else{
				 parent.$.messager.show({
						title :"提示",
						msg :"请选择角色！",
						timeout : 1000 * 2
					});
			 }
			 
			 /*$.post("user/userAction!saveUserRoles.action", {userId:selectRow.userId,isCheckedIds:isCheckedIds}, function(rsp) {
				 $.messager.alert(rsp.title, rsp.message);
				}, "JSON").error(function() {
					$.messager.alert("提示", "保存用户角色失败！");
				});*/
		 }
		 function getRoles(rowIndex, rowData){
			 $.post("user/userAction!findUsersRolesList.action", {userId:rowData.MYID}, function(rsp) {
					 $role.datagrid("unselectAll");
				 if(rsp.length!=0){
					 $.each(rsp,function(i,e){
						 $role.datagrid("selectRecord",e.roleId);
					 });
				 }else{
					 parent.$.messager.show({
							title :"提示",
							msg : "该用户暂无角色！",
							timeout : 1000 * 2
						});
				 }
				}, "JSON").error(function() {
					 parent.$.messager.show({
							title :"提示",
							msg : "获取用户角色失败！",
							timeout : 1000 * 2
						});
				});
		}
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
		<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden; padding: 0px;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>
					为用户分配角色，请<span class="label-info"><strong>双击用户</strong></span>查看所属角色！超级管理员默认拥有<span class="label-info"><strong>所有权限！</strong></span>
				</span>
			</div>
		</div>
		<div data-options="region:'west',split:true,border:true" style="width:800px;">
			<div id="tbUser" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td class="tableleft">用户账号：</td>
						<td class="tableright"><input id="userId" name="userId" type="text" class="textinput" /></td>
						<td class="tableleft">用户名：</td>
						<td class="tableright"><input id="operName" name="operName" type="text" class="textinput" /></td>
						<td style="padding-left:2px">
							<shiro:hasPermission name="userRoleConfig">
								<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="queryUser();">查询</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-config" plain="false" onclick="saveUserRoles();">保存设置</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
			<table id="user" title="用户"></table>
		</div>
		<div data-options="region:'center',border:true,fit:true">
			<div id="tbRole" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td class="tableleft">角色名称：</td>
						<td class="tableright"><input id="rowName" name="rowName" type="text" class="textinput" /></td>
						<td style="padding-left:4px;padding-bottom:4px;">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="queryRole();">查询</a>
						</td>
					</tr>
				</table>
			</div>
			<table id="role" title="角色"></table>
		</div>
  </body>
</html>
