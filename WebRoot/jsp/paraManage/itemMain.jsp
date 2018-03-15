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
    <title>科目信息</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style type="text/css">
		table.tablegrid td{
			padding: 0 15px;
		}
	</style>
	<script type="text/javascript">
			var $dg;
			var $temp;
			var $grid;
			$(function() {
				 createCustomSelect({
						id:"item_id",
					 	value:"item_id",
					 	text:"item_name || '【' || item_id || '】'",
					 	table:"acc_item",where:"item_id is not null ",
					 	isShowDefaultOption:true,
					 	orderby:"item_id asc",
					 	from:1,
					 	to:50,
					 	width:274
				 });
				 $dg = $("#dg");
				 $grid=$dg.datagrid({
					url : "paraManage/itemManageAction!findBaiscItemAllList.action",
					width : $(this).width(),
					height : $(this).height()-45,
					pagination:true,
					rownumbers:true,
					fitColumns: true,
					fit:true,
					scrollbarSize:0,
					border:true,
					striped:true,
					singleSelect:true,
					columns : [ [ {field : 'ITEM_ID',title : '科目编号',width : parseInt($(this).width()*0.1),sortable:true,align:'left'},
					              {field : 'ITEM_NAME',title : '科目名称',width : parseInt($(this).width()*0.2),sortable:true},
					              {field : 'ITEM_LVL',title : '科目级别',width : parseInt($(this).width()*0.1),sortable:true},
					              {field : 'BAL_TYPE',title : '余额方向',width : parseInt($(this).width()*0.1),sortable:true,align:'left',formatter:function(value,row){
					            	  if("1"==row.BAL_TYPE){
					            		  return "借方";
					            	  }else if("2"==row.BAL_TYPE){
					            		  return "贷方";
					            	  }else{
					            		  return "双方";
					            	  }
					              }},
					              {field : 'TOP_ITEM_NO',title : '上级科目',width : parseInt($(this).width()*0.1),sortable:true},
					              {field : 'OPEN_DATE',title : '创建日期',width : parseInt($(this).width()*0.35),sortable:true}
					              ] ],toolbar:'#tb',
					              onLoadSuccess:function(data){
					            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
					            	  if(data.status != 0){
					            		 $.messager.alert('系统消息',data.errMsg,'error');
					            	  }
					              }
						});
				
			});
			
			function query(){
				$dg.datagrid('load',{
					queryType:'0',//查询类型
					item_id:$("#item_id").combobox("getValue")
				});
			}
			
			//弹窗修改
			function updRowsOpenDlg() {
				var row = $dg.datagrid('getSelected');
				if (row) {
					parent.$.modalDialog({
						title : "编辑科目信息",
						width : 300,
						height :180,
						href : "paraManage/itemManageAction!toViewItem.action?item_id="+row.ITEM_ID,		
						buttons : [ {
							text : '编辑',
							iconCls : 'icon-ok',
							handler : function() {
								parent.$.modalDialog.openner= $grid;
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
		</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>科目信息</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table class="tablegrid" style="width: auto;" cellpadding="0" cellspacing="0">
					<tr>
						<td class="tableleft">科目编号：</td>
						<td class="tableright"><input id="item_id"  class="textinput" name="item_id"  style="width:274px;cursor:pointer;"/></td>
						<td class="tableleft">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
						<td class="tableright">
							<shiro:hasPermission name="accItemEdit">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="科目信息"></table>
	  </div>
  </body>
</html>
