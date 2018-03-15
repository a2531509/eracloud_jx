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
    <title>商户类型管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
			var $dg;
			var $grid;
			$(function(){
				 $dg = $("#dg");
				 $grid=$dg.treegrid({
					width : $(this).width(),
					height : $(this).height()-45,
					url : "merchantType/merchantTypeAction!queryMerType.action",
					rownumbers:false,
					animate: true,
					collapsible: true,
					striped:true,
					border:true,
					pagination:true,
					pageSize:20,
					fit:true,
					//parentField:'parentId',
					idField: 'ID',
					//treeField: 'TYPE_NAME',
					 frozenColumns:[[
					                 {title : '商户类型',field : 'TYPE_NAME', sortable:true, width : parseInt($(this).width() * 0.3),
					                  formatter:function(value){
					                   return '<span style="color:purple">'+value+'</span>';
					                  }
					                 }
					    ]],
					columns : [ [ 
					              
					              {field : 'LEV',title : '商户级别',sortable:true,width : parseInt($(this).width()*0.1),formatter:function(value,row){
					            	 var c = '';
					            	 value = Number(value);
					            	 switch(value){//switch语句必须是整数,不能是字符串.
					            	 	case 1:c = '一级';break;
					            	 	case 2:c = '二级';break;
					            	 	case 3:c = '三级';break;
					            	 	default : c = '其他';
					            	 }
					            	 return c;	  
					              }},
					              {field : 'ORD_NO',title : '序号',sortable:true,width : parseInt($(this).width()*0.15)},
					              {field : 'OWNMERCHANTS',title : '当前包含的商户数',sortable:true,width:parseInt($(this).width()*0.15)},
					              {field : 'PARENTTYPENAME',title : '上级商户',sortable:true,width:parseInt($(this).width()*0.23)},
					              {field : 'TYPE_STATE',title : '状态',sortable:true,align:'left',width:parseInt($(this).width()*0.2),formatter:function(value,row){
					            	  var c;
					            	  value = Number(value);
					            	  switch(value){
					            	  	case 0:c = "正常";break;
					            	  	case 1:c = "注销";break;
					            	  	default:c = "其他";
					            	  }
					            	  return c;
					              }}
					              ]],toolbar:'#tb',
					              onLoadSuccess:function(data){
					            	  if(data.status != 0){
					            		 $.messager.alert('系统消息',data.errMsg,'error');
					            	  }
					              }
					});
			});
			
			//弹窗修改
			function updRowsOpenDlg() {
				var row = $dg.datagrid('getSelected');
				if (row) {
					$.modalDialog({
						title : "编辑行业",
						width : 500,
						height : 300,
						href : "jsp/merchant/merTypeAddDlg.jsp",
						onLoad:function(){
							var f = $.modalDialog.handler.find("#form");
							f.form("load", {"mtype.typeName":row.TYPE_NAME,"mtype.lev":row.LEV,"mtype.ordNo":row.ORD_NO,"mtype.parentId":dealNull(row.PARENT_ID),"mtype.id":row.ID});
						},			
						buttons : [ {
							text : '编辑',
							iconCls : 'icon-ok',
							handler : function() {
								$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
								var f = $.modalDialog.handler.find("#form");
								f.submit();
							}
						}, {
							text : '取消',
							iconCls : 'icon-cancel',
							handler : function() {
								$.modalDialog.handler.dialog('destroy');
								$.modalDialog.handler = undefined;
							}
						}
						]
					});
				}else{
					$.messager.show({
						title :"提示",
						msg :"请选择一行记录!",
						timeout : 1000 * 2
					});
				}
			}
			//弹窗增加
			function addRowsOpenDlg() {
				var row = $dg.datagrid('getSelected');
				$.modalDialog({
					title : "添加行业",
					width : 550,
					height : 300,
					href : "jsp/merchant/merTypeAddDlg.jsp",
					onLoad:function(){
						if(row){
							var f = $.modalDialog.handler.find("#form");
							f.form("load", {"pid":row.SysBranchId});
						}
					},
					buttons : [ {
						text : '保存',
						iconCls : 'icon-ok',
						handler : function() {
							$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							$.modalDialog.handler.dialog('destroy');
							$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}
			
		</script>
  </head>
  <body>
  	<div class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户行业类别</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			
			
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td style="padding-left:2px">
							<%-- <shiro:hasPermission name="TypeOnwMer">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="viewMer();">预览商户</a>
							</shiro:hasPermission> --%>
							<shiro:hasPermission name="merTypeAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merTypeEite">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
						</td>
					</tr>
							
					</table>
			</div>
	  		<table id="dg" title="行业信息"></table>
	  </div>
	</div>
  </body>
</html>
