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
    <title>机构管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
			var $dg;
			var $grid;
			$(function() {
				 $dg = $("#dg");
				 $grid=$dg.datagrid({
					width : $(this).width(),
					height : $(this).height()-45,
					url : "sysOrgan/sysOrganAction!findAllSysOrgan.action",
					rownumbers:true,
					singleSelect: true,
					collapsible: true,
					fitColumns: true,
					fit:true,
					scrollbarSize:0,
					striped:true,
					border:false,
					//singleSelect:false,
					idField: 'SysBranchId',
					treeField: 'fullName',
					 frozenColumns:[[
					                 {title:'机构名称',field:'orgName',width:parseInt($(this).width()*0.3),
					                  formatter:function(value){
					                   return '<span style="color:purple">'+value+'</span>';
					                  }
					                 }
					    ]],
					columns : [ [ 
					              {field : 'orgId',title : '机构编码',width : parseInt($(this).width()*0.1)},
					              {field : 'orgType',title : '机构类型',width : parseInt($(this).width()*0.1),align : 'left',formatter:function(value,row){
										//机构类型01-发卡机构   02-清算机构 03-收单机构   04-机具投资方 05-银行 06-银联
										if("01"==row.orgType){
											return "发卡机构";
										}else if("02"==row.orgType){
											return "清算机构";
										}else if("03"==row.orgType){
											return "收单机构";
										}else if("04"==row.orgType){
											return "机具投资方";
										}else if("05"==row.orgType){
											return "银行";
										}else{
											return "银联";
										}
									}},
					              {field : 'orgClass',title : '机构级别',width : parseInt($(this).width()*0.1),align : 'left',formatter:function(value,row){
										//机构级别（1一级2二级3三级）
										if("1"==row.orgClass){
											return "一级";
										}else if("2"==row.orgClass){
											return "二级";
										}else{
											return "三级";
										}
					                }},
					              {field : 'accNo',title : '银行账号',width : parseInt($(this).width()*0.3),align : 'left'},
					              {field : 'orgState',title : '状态',align : 'center',width : parseInt($(this).width()*0.1),align : 'left',formatter:function(value,row){
										//机构级别（1一级2二级3三级）
										if("0"==row.orgState){
											return "正常";
										}else{
											return "注销";
										}
					                }}
					              ] ],
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
			});
			
			//弹窗修改
			function updRowsOpenDlg() {
				var row = $dg.datagrid('getSelected');
				if (row) {
					parent.$.modalDialog({
						title : "编辑组织",
						width : 700,
						height : 500,
						href : "jsp/orgManage/orgManagEditDlg.jsp",
						onLoad:function(){
							var f = parent.$.modalDialog.handler.find("#form");
							f.form("load", row);
						},			
						buttons : [ {
							text : '编辑',
							iconCls : 'icon-ok',
							handler : function() {
								parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
								var f = parent.$.modalDialog.handler.find("#form");
								f.submit();
							}
						}, {
							text : '取消',
							iconCls : 'icon-cancel',
							handler : function() {
								parent.$.modalDialog.handler.dialog('destroy');
								parent.$.modalDialog.handler = undefined;
							}
						}
						]
					});
				}else{
					parent.$.messager.show({
						title :"提示",
						msg :"请选择一行记录!",
						timeout : 1000 * 2
					});
				}
			}
			//弹窗增加
			function addRowsOpenDlg() {
				var row = $dg.datagrid('getSelected');
				parent.$.modalDialog({
					title : "添加机构",
					width : 700,
					height : 500,
					href : "jsp/orgManage/orgManagAddDlg.jsp",
					onLoad:function(){
						if(row){
							var f = parent.$.modalDialog.handler.find("#form");
							f.form("load", {"pid":row.SysBranchId});
						}
					},
					buttons : [ {
						text : '保存',
						iconCls : 'icon-ok',
						handler : function() {
							parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							parent.$.modalDialog.handler.dialog('destroy');
							parent.$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}
			//机构注销
			function delRows(){
				var row = $dg.datagrid('getSelected');
				if (row) {
					$.messager.confirm('确认','<font style="color:red">您确认要注销该机构吗，注销后机构下的网点和柜员将同时被注销？</font>',function(r){    
					    if (r){    
					    	$.ajax({
								type: "POST",
								url: "sysOrgan/sysOrganAction!zxOrgan.action?orgId="+row.orgId,
								cache: false,
								dataType : "json",
								success: function(data){
									if(data.status){
										$.messager.alert(data.title,data.message,'info');
										$dg.datagrid('reload');
									}else{
										$.messager.alert(data.title,data.message,'error');
									}
								}
					        }); 
					    }    
					}); 
						
				}else{
					parent.$.messager.show({
						title :"提示",
						msg :"请选择一行记录!",
						timeout : 1000 * 2
					});
				}
			}
			//机构账户开户
			function openAcc(){
				var row = $dg.datagrid('getSelected');
				if("0"!=row.orgState){
					$.messager.alert('系统消息','机构状态不正常不准许开户','error');
					return;
				}
				if (row) {
					$.ajax({
						type: "POST",
						url: "sysOrgan/sysOrganAction!openOrgAcc.action?orgId="+row.orgId,
						cache: false,
						dataType : "json",
						success: function(data){
							parent.$.messager.show({
								title :data.title,
								msg :data.message,
								timeout : 1000 * 2
							}); 
						}
			        }); 	
				}else{
					parent.$.messager.show({
						title :"提示",
						msg :"请选择一行记录!",
						timeout : 1000 * 2
					});
				}
			}
			
			function orgSearch(){
				$dg.datagrid("reload",{
					orgId:$("#orgId").val(),
					orgName:$("#orgName").val()
				});
			}
		</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
	  	<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
		<span><span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>机构</strong></span>进行新增，注销，编辑和开户操作!</span>进行管理！</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style=" border-left:none;border-bottom:none; height:auto;overflow:hidden;">
	<div id="tb" style="padding:2px 0">
		<table cellpadding="0" cellspacing="0" class="tablegrid" width="100%">
			<tr>
				<td class="tableleft" style="width:6%">机构编号：</td>
				<td class="tableright" style="width:15%"><input name="orgId"  class="textinput easyui-validatebox" id="orgId" type="text" /></td>
				<td class="tableleft" style="width:6%">机构名称：</td>
				<td class="tableright" style="width:15%"><input id="orgName" type="text" class="textinput  easyui-validatebox" name="orgName"  style="width:174px;"/></td>
				<td class="tableright" >
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="true" onclick="orgSearch();">查询</a>
					<shiro:hasPermission name="orgationAdd">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="true" onclick="addRowsOpenDlg();">添加</a>
					</shiro:hasPermission>
					<shiro:hasPermission name="orgationEdit">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="true" onclick="updRowsOpenDlg();">编辑</a>
					</shiro:hasPermission>
					<shiro:hasPermission name="orgCancel">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="true" onclick="delRows();">注销</a>
					</shiro:hasPermission>
					<shiro:hasPermission name="orgOpenAcc">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-orgOpenAcc" plain="true" onclick="openAcc();">开户</a>
					</shiro:hasPermission>
				</td>
			</tr>
		</table>
	</div>
	<table id="dg" title="机构管理"></table>
	</div>
  </body>
</html>
