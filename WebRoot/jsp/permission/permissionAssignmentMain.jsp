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
		var $function;
		var $grid;
		$(function() {
			$("#panel").panel({   
				   width:'auto',   
				   height:$(this).height(),   
				   title: '权限编辑',   
			});
			$role = $("#role");
			$grid=$role.datagrid({
					url : "permission/permissionAssignmentAction!findAllRoleList.action",
					width : 'auto',
					fitColumns:true,
					scrollbarSize:0,
					pagination:false,
					fit:true,
					border:false,
					rownumbers:true,
					singleSelect:true,
					striped:true,
					columns:[[ 
					    {field : 'name',title : '角色名称',width :parseInt($(this).width() * 0.15),align : 'center',editor : {type:'validatebox',options:{required:true}}},
					    {field : 'sort',title : '排序',width :parseInt($(this).width() * 0.15),align : 'center',editor : "numberbox"},
					    {field : 'description',title : '角色描述',width : parseInt($(this).width() * 0.15),align : 'center',editor : "text"}
					]],toolbar:'#tbRole',onDblClickRow:getPermission
				});
				
			$function = $("#function");
			$function.treegrid({
				width : 'auto',
				fit:true,
				url : "permission/permissionAssignmentAction!findAllFunctionList.action",
				rownumbers:true,
				animate: true,
				collapsible: false,
				fitColumns: true,
				border:false,
				striped:true,
				singleSelect:false,
				cascadeCheck:true,
				deepCascadeCheck:true,
				idField: 'id',
				treeField: 'name',
				parentField : 'pid',
				columns : [ [ 
				              {field:'ck',checkbox:true},
				              {field : 'name',title : '程式名称',width : parseInt($(this).width()*0.2)},
				              //{field : 'pName',title : '父程式名称',width : 100,align : 'center'},
				              //{field : 'sort',title : '排序编码',width : 50,align : 'center'},
				              //{field : 'image',title : '程式图标',width : 100},
				              //{field : 'path',title : '程式路径',width : 150,align : 'left'},
				              {field : 'myid',title : '程式编码',width : parseInt($(this).width()*0.1),align : 'center'},
				              {field : 'type',title : '程式类型',width : parseInt($(this).width()*0.1),align : 'center',
				            	  formatter:function(value,row){
				            		  if("F"==row.type)
										return "<font color=green>菜单<font>";
				            		  else
				            			return "<font color=red>操作<font>";  
									}},
							   {field : 'isused',title : '是否启用',width : parseInt($(this).width()*0.1),align : 'center',
						            formatter:function(value,row){
						            	if("Y"==row.isused)
										  return "<font color=green>是<font>";
						            	else
						            	  return "<font color=red>否<font>";  
										}},
				              {field : 'description',title : '程式描述',width : parseInt($(this).width()*0.2),align : 'left'}
				              ] ],toolbar:'#tb',onClickRow:function(row){   
				            	                      //级联选择   
				            	                   $function.treegrid('cascadeCheck',{   
				            	                          id:row.id, //节点ID   
				            	                          deepCascade:true //深度级联   
				            	                     });   
				            	               }
			});
		});
		function endEdit(){
			var flag=true;
			var rows = $role.datagrid('getRows');
			for ( var i = 0; i < rows.length; i++) {
				$role.datagrid('endEdit', i);
				var temp=$role.datagrid('validateRow', i);
				if(!temp){flag=false;}
			}
			return flag;
		}
		function addRows(){
			$role.datagrid('appendRow', {});
			var rows = $role.datagrid('getRows');
			$role.datagrid('beginEdit', rows.length - 1);
		}
		function editRows(){
			var rows = $role.datagrid('getSelections');
			$.each(rows,function(i,row){
				if (row) {
					var rowIndex = $role.datagrid('getRowIndex', row);
					$role.datagrid('beginEdit', rowIndex);
				}
			});
		}
		function removeRows(){
			var rows = $role.datagrid('getSelections');
			$.each(rows,function(i,row){
				if (row) {
					var rowIndex = $role.datagrid('getRowIndex', row);
					$role.datagrid('deleteRow', rowIndex);
				}
			});
		}
		function saveRows(){
			if(endEdit()){
				if ($role.datagrid('getChanges').length) {
					var inserted =$role.datagrid('getChanges', "inserted");
					var deleted =$role.datagrid('getChanges', "deleted");
					var updated = $role.datagrid('getChanges', "updated");
					
					var effectRow = new Object();
					if (inserted.length) {
						effectRow["inserted"] = JSON.stringify(inserted);
					}
					if (deleted.length) {
						effectRow["deleted"] = JSON.stringify(deleted);
					}
					if (updated.length) {
						effectRow["updated"] = JSON.stringify(updated);
					}
					$.post("permission/permissionAssignmentAction!persistenceRole.action", effectRow, function(rsp) {
						if(rsp.status){
							$role.datagrid('acceptChanges');
						}
						$.messager.alert(rsp.title, rsp.message);
					}, "JSON").error(function() {
						$.messager.alert("系统消息", "提交错误了！");
					});
				}
			}else{
				$.messager.alert("系统消息", "字段验证未通过!请查看");
			}
		}
		function collapseAll(){
			var node = $function.treegrid('getSelected');
			if (node) {
				$function.treegrid('collapseAll', node.id);
			} else {
				$function.treegrid('collapseAll');
			}
		}
		function expandAll(){
			var node = $function.treegrid('getSelected');
			if (node) {
				$function.treegrid('expandAll', node.id);
			} else {
				$function.treegrid('expandAll');
			}
		}
		function refresh(){
			$function.treegrid('reload');
		}
		function selectNode(){
			$function.treegrid('select','1');
		}
		function getLoad(){
			$role.datagrid('load',{ 
				roleName:$("#roleName").val()
			}); 
		}
		function getPermission(rowIndex, rowData){ 
			$.messager.progress({text:'数据处理中，请稍后....'});
			$.post("permission/permissionAssignmentAction!getRolePermission.action", {roleId:rowData.roleId}, function(rsp) {
				$function.treegrid('unselectAll');
				if(rsp.length != 0){
					$.each(rsp,function(i,e){
						try{
		    			 $function.treegrid('select',e.permissionId);
						}catch(e1){
							
						}
		    	  	});
		    	  $.messager.progress('close');
				}else{
					$.messager.progress('close');
					jAlert("该角色暂无权限！","warning");
				}
			}, "JSON").error(function() {
				$.messager.progress('close');
				jAlert("获取权限失败，请重试！");
			});
        } 
		function savePermission(){
			var selections = $function.treegrid('getSelections');
			var selectionRole = $role.datagrid('getSelected');
			var checkedIds = [];
			$.each(selections,function(i,e){
				checkedIds.push(e.id);
			});
			if(selectionRole){
				$.messager.confirm("系统消息","您确定要保存当前角色的权限分配信息吗？",function(r){
					if(r){
						$.messager.progress({text:'数据处理中，请稍后....'});
						$.ajax({
							url:"permission/permissionAssignmentAction!savePermission.action",
							data: "roleId=" + selectionRole.roleId + "&checkedIds=" + (checkedIds.length == 0 ?"" : checkedIds),
							success: function(rsp){
								parent.$.messager.show({
									title :rsp.title,
									msg : rsp.message,
									timeout : 1000 * 2
								});
								$.messager.progress('close');
							},
							error:function(){
								$.messager.progress('close');
								parent.$.messager.show({
									title :"系统消息",
									msg : "分配失败！",
									timeout : 1000 * 2
								});
							}
						});
					}
				});
			}else{
				parent.$.messager.show({
					title :"系统消息",
					msg : "请选择角色！",
					timeout : 1000 * 2
				});
			}
		}
		function delRows(){
			var row = $role.datagrid('getSelected');
			if(row){
				var rowIndex = $role.datagrid('getRowIndex', row);
				$role.datagrid('deleteRow', rowIndex);
				$.ajax({
					url:"permission/permissionAssignmentAction!delRole.action",
					data: "roleId="+row.roleId,
					success: function(rsp){
						parent.$.messager.show({
							title : rsp.title,
							msg : rsp.message,
							timeout : 1000 * 2
						});
					}
				});
			}else{
				parent.$.messager.show({
					title : "系统消息",
					msg : "请选择行数据!",
					timeout : 1000 * 2
				});
			}
		}
		//弹窗修改
		function updRowsOpenDlg() {
			var row = $role.datagrid('getSelected');
			if (row) {
				parent.$.modalDialog({
					title : "编辑角色",
					width : 600,
					height : 400,
					href : "jsp/permission/roleEditDlg.jsp",
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
					title :"系统消息",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function queryRole(){
			$role.datagrid('load',{
				queryType:'0',//查询类型
				rowName:$("#rowName").val()
			});
		}
		//弹窗增加
		function addRowsOpenDlg() {
			parent.$.modalDialog({
				title : "添加角色",
				width : 600,
				height : 400,
				href : "jsp/permission/roleEditDlg.jsp",
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
	</script>
	</head>
  <body class="easyui-layout" data-options="fit:true" style="overflow:hidden;">
		<div data-options="region:'north',border:false" title="" style="height:auto; overflow: hidden; ">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>
					新增菜单功能不属于当前角色，请在<span class="label-info"><strong>菜单权限分派</strong></span>中为该角色进行资源分派！请<span class="label-info"><strong>双击角色</strong></span>查看所属资源！
					超级管理员默认拥有<span class="label-info"><strong>所有权限！</strong></span>
				</span>
			</div>
		</div>
		<div data-options="region:'west',split:true,border:true" style="border-bottom:none;width:40%;height:auto;overflow:hidden;border-left:none;">
			<div id="tbRole" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" width="100%">
					<tr>
						<td class="tableleft" style="width:15%">角色名称：</td>
						<td class="tableright" style="width:8%"><input id="rowName" name="rowName" type="text" class="textinput" /></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="queryRole();">查询</a></td>
					</tr>
					<tr>
						<td colspan="3">
							<shiro:hasPermission name="roleAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="roleEdit">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="roleDel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="delRows();">删除</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="perConfig">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-config" plain="false" onclick="savePermission();">保存设置</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
			<table id="role" title="角色"></table>
		</div>
		<div data-options="region:'center',border:true" style="border-bottom:none; width:60%; height:atuo; overflow:hidden;">
			 <div id="tb">
				<div style="margin:5px 5px 5px 5px;">
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-undo" plain="false" onclick="expandAll();">展开</a>
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-redo" plain="false" onclick="collapseAll();">收缩</a>
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-reload" plain="false" onclick="refresh();">刷新</a>
				</div>
			</div>
			<table id="function" title="程式"></table>
		</div>
  </body>
</html>
