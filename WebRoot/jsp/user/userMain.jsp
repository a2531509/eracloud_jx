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
    <title>柜员管理</title>
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function(){
			createSysBranch({
				id:"branchId"
			},{id:"operatorId"});
			$dg = $("#dg");
   			$grid = $dg.datagrid({
				url:"user/userAction!findAllUserList.action",
				pagination:true,
				rownumbers:true,
				border:false,
				singleSelect:true,
				fit:true,
				fitColumns: true,
				scrollbarSize:0,
				striped:true,
				columns:[[
				    {field:'MYID',checkbox:true},
				    {field:'USER_ID',title:'用户编号',width:parseInt($(this).width()*0.08),align:'left',editor:"text"},
	                {field:'NAME',title:'用户名',width:parseInt($(this).width()*0.08),editor:{type:'validatebox',options:{required:true}}},
	                //{field:'PASSWORD',title:'用户密码',width:parseInt($(this).width()*0.1),editor:"validatebox",formatter:function(){return "******"}},
	                //{field:'EMAIL',title:'邮箱',width:parseInt($(this).width()*0.1),align:'left',editor:{type:'validatebox',options:{required:true,validType:'email'}}},
	                {field:'TEL',title:'电话',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
	                {field:'TITLE_ID',title:'是否结算提醒',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
	                {field:'DUTY_ID',title:'数据权限类型',width:parseInt($(this).width()*0.1),align:'left',formatter:function(value,row,index){
	                	if(value == "0"){return "一般柜员";}else if(value == "1"){return "网点主管";
	                	}else if(value == "2"){return "网点及子网点";}else if(value == "3"){return "机构";}
	                	else if(value == "4"){return "机构及子机构";
	                	}else if(value == "9"){return "所有数据权限";}else{return "";}
	                }},
				    {field:'STATUS',title:'状态',width:parseInt($(this).width()*0.05),align:'left',editor:"text",formatter:function(value,row,index){
				    	if(value != "正常"){return "<span style=\"color:red\">" + value + "</span>"}else{return value;}
				    }},
	                {field:'ORG_ID',title:'所属机构编号',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
	                //{field:'ORG_NAME',title:'所属机构名称',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
	                {field:'BRCH_ID',title:'所属网点编号',width:parseInt($(this).width()*0.1),align:'left'}, 
				    {field:'FULL_NAME',title:'所属网点名称',width:parseInt($(this).width()*0.2),align:'left',editor:"text"},
				    {field:'CREATER',title:'创建人',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
				    {field:'CREATED',title:'创建日期',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
				    {field:'LASTMOD',title:'最后修改日期',width:parseInt($(this).width()*0.1),align:'left',editor:"text"},
				    {field:'MODIFYER',title:'最后修改人',width:parseInt($(this).width()*0.05),align:'left',editor:"text"},
	                {field:'ISLOCKPWD',title:'是否锁定密码',width:parseInt($(this).width()*0.1),align:'left',editor:"text",formatter:function(value,row,index){
				    	if(value != "是"){return "<span style=\"color:red\">" + value + "</span>"}else{return value;}
				    }},
				    {field:'PASSWORD_VALIDITY',title:'密码有效期',width:parseInt($(this).width()*0.08),align:'left',editor:"text"},
				    {field:'DESCRIPTION',title:'描述',width:parseInt($(this).width()*0.1),align:'left',editor:"text"}
	            ]],
	            toolbar:'#tb',
	            onLoadSuccess:function(data){
		           	if(data.status != 0){
		           		$.messager.alert('系统消息',data.errMsg,'error');
		           	}
		            var allch = $(':checkbox').get(0);
			 	    if(allch){
			 			allch.checked = false;
			 	    }
	           }
         	});
			$("#state").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
			    textField:"codeName",
			    panelHeight: 'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"注销"}]
		    });
		});
		//查询
		function userSearch(){
			$dg.datagrid("reload",{
				branchId:$("#branchId").combobox("getValue"),
				operatorId:$("#operatorId").combobox("getValue"),
				userId:$("#userId").val(),
				state:$("#state").combobox("getValue"),
				operName:$("#operName").val(),
				queryType:"0"
			});
		}
		//注销用户
		function disableUser(){
			var row = $dg.datagrid('getSelected');
			if(row){
				if(row.STATUS != "正常"){
					$.messager.alert("系统消息","该柜员已是注销状态，无需再次注销！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要注销该用户信息吗？<br/><span style=\"color:red\">提示：注销后用户将无法登陆系统！</span>",function(r){
					if(r){
						$.post('user/userAction!disableUser.action',"status=I&userId=" + row.USER_ID,function(data,status){
							$.messager.alert("系统消息",data.msg,(data.status == "0") ? "info":"error",function(){
								if(data.status == "0"){
									$dg.datagrid("reload");
								}
							});
						},'json');
					}
				});
			}else{
				$.messager.alert("系统消息","注销柜员请选择一行记录信息");
			}
		}
		//激活
		function enableUser(){
			var row = $dg.datagrid('getSelected');
			if(row){
				if(row.STATUS == "正常"){
					$.messager.alert("系统消息","该柜员已是激活状态，无需再次激活！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要激活该用户信息吗？",function(r){
					if(r){
						$.post('user/userAction!disableUser.action',"status=A&userId=" + row.USER_ID,function(data,status){
							$.messager.alert("系统消息",data.msg,(data.status == "0") ? "info":"error",function(){
								if(data.status == "0"){
									$dg.datagrid("reload");
								}
							});
						},'json');
					}
				});
			}else{
				$.messager.alert("系统消息","注销柜员请选择一行记录信息");
			}
		}
		//弹窗修改
		function updRowsOpenDlg() {
			var row = $dg.datagrid('getSelected');
			if (row) {
				parent.$.modalDialog({
					title:"编辑用户",
					width:800,
					height:400,
					iconCls:'icon-edit',
					href:"/user/userAction!editUsers.action?userId=" + row.USER_ID,		
					buttons:[ {
								text:'编辑',
								iconCls:'icon-ok',
								handler:function() {
									parent.$.modalDialog.openner= $grid;
									//var f = parent.$.modalDialog.handler.find("#form");
									parent.saveEdit($grid);
								}
							 }, {
								text:'取消',
								iconCls:'icon-cancel',
								handler:function() {
									parent.$.modalDialog.handler.dialog('destroy');
									parent.$.modalDialog.handler = undefined;
								}
							}
					]
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录！",
					timeout:1000 * 2
				});
			}
		}
		//弹窗增加
		function addRowsOpenDlg() {
			parent.$.modalDialog({
				title:"添加柜员",
				width:800,
				height:400,
				iconCls:"icon-add",
				href:"/user/userAction!addUsers.action",
				buttons:[ {
					text:'保存',
					iconCls:'icon-ok',
					handler:function() {
						parent.$.modalDialog.openner= $grid;
						parent.saveUsers($grid);
					}
				}, {
					text:'取消',
					iconCls:'icon-cancel',
					handler:function() {
						parent.$.modalDialog.handler.dialog('close');
					}
				}
				]
			});
		}
		
		//密码解锁
		function undopwd(){
			var row = $dg.datagrid('getSelected');
			if(row){
				if(row.ISLOCKPWD == "否"){
					$.messager.alert("系统消息","该柜员密码未锁定，无需解锁！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要对该柜员进行密码解锁吗？",function(r){
					if(r){
						$.post('user/userAction!undopwderr.action',"userId=" + row.USER_ID,function(data,status){
							$.messager.alert("系统消息",data.msg,(data.status == "0") ? "info":"error",function(){
								if(data.status == "0"){
									$dg.datagrid("reload");
								}
							});
						},'json');
					}
				});
			}else{
				$.messager.alert("系统消息","注销柜员请选择一行记录信息");
			}
		}
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
	  	<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>柜员信息</strong></span>进行管理！</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style=" border-left:none;border-bottom:none; height:auto;overflow:hidden;">
	<div id="tb" style="padding:2px 0">
		<table cellpadding="0" cellspacing="0" class="tablegrid" width="100%">
			<tr>
				<td class="tableleft">柜员编号：</td>
				<td class="tableright"><input name="userId"  class="textinput" id="userId" type="text"/></td>
				<td class="tableleft">所属网点：</td>
				<td class="tableright"><input id="branchId" type="text" class="textinput  easyui-validatebox" name="branchId"  style="width:174px;"/></td>
				<td class="tableleft">柜员：</td>
				<td class="tableright"><input id="operatorId" type="text" class="textinput  easyui-validatebox" name="operatorId"  style="width:174px;"/></td>
			</tr>
			<tr>
				<td class="tableleft">柜员名称：</td>
				<td class="tableright"><input name="operName"  class="textinput" id="operName" type="text"/></td>
				<td class="tableleft">状态：</td>
				<td class="tableright"><input id="state" type="text" class="easyui-combobox  easyui-validatebox" name="state" value="" style="width:174px;"/></td>
				<td style="padding-left:2px" colspan="2">
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="userSearch();">查询</a>
					<shiro:hasPermission name="userAdd">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="addRowsOpenDlg();">添加</a>
					</shiro:hasPermission>
					<shiro:hasPermission name="userEdit">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
					</shiro:hasPermission>
					<shiro:hasPermission name="userDel">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="disableUser();">注销</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false"  onclick="enableUser();">激活</a>
					</shiro:hasPermission>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-cancel" plain="false" onclick="undopwd();">密码解锁</a>
					<!-- 
					<shiro:hasPermission name="userSave">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" plain="true" onclick="saveRows();">保存</a>
					</shiro:hasPermission>-->
				</td>				
			</tr>
		</table>
	</div>
	<table id="dg" title="柜员信息"></table>
	</div>
  </body>
</html>
