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
    <title>词典管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
		<script type="text/javascript" src="js/jquery-ui.js"></script>
	
		<script type="text/javascript">
			var $dg;
			var $grid;
			$(function() {
				createLocalDataSelect({
					id:"state",
				    data:[{value:'',text:"请选择"},{value:'0',text:"正常"},{value:'1',text:"停用"}]
				});
				createCustomSelect({id:"certNo",value:"code_type",text:"type_name",table:"sys_code",where:"1 = 1 group by code_type,type_name",orderby:"code_type"});

				$dg = $("#dg");
				$grid=$dg.datagrid({
					width : 'auto',
					fit:true,
					url : "sysCode/sysCodeAction!findSystemCodeList.action",
					rownumbers:true,
					animate: true,
					fitColumns: true,
					singleSelect:true,
					striped:true,
					border:true,
					pagination:true,
					columns : [ [ 
					              
					              {title:'代码类别',field:'CODE_TYPE',align : 'left',width:parseInt($(this).width()*0.2),sortable:true},
					              {field : 'TYPE_NAME',title : '类别名称',width : parseInt($(this).width()*0.1),align : 'left',sortable:true},
					              {field : 'CODE_VALUE',title : '代码值',width : parseInt($(this).width()*0.1),sortable:true},
					              {field : 'CODE_NAME',title : '代码名称',width : parseInt($(this).width()*0.2),align : 'left',sortable:true},
					              {field : 'CODE_STATE',title : '状态',width : parseInt($(this).width()*0.1),sortable:true,formatter: function(value,row,index){
					            	  if(value=="0"){
					            		  return '正常';
					            	  }else{
					            		  return '<span style="color:red">停用</span>';
					            	  }
					              }},
					              {field : 'ORD_NO',title : '序号',width : parseInt($(this).width()*0.1),sortable:true},
					              {field : 'FIELD_NAME',title : '类中属性名称',width : parseInt($(this).width()*0.1),sortable:true}
					              ] ],toolbar:'#tb'
				});
			});
			function removeNode(){
				var row = $dg.datagrid('getSelected');
				if (row) {
					$.messager.confirm("系统消息","您确定要删除数据字典吗？",function(r){
						 if(r){
							 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
							 $.post("sysCode/sysCodeAction!removeSysCode.action",{"codeType":row.CODE_TYPE,"codeValue":row.CODE_VALUE},function(data,status){
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
									 $.messager.alert("系统消息","删除数据字典出现错误，请重新进行操作！","error");
									 return;
								 }
							 },"json");
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
			//数据字典修改弹窗
			function updateCodeTpye() {
				var row = $dg.datagrid('getSelected');
				if (row) {
						$.modalDialog({
							title : "编辑词典",
							width : 600,
							height : 400,
							href:"sysCode/sysCodeAction!queryEditSysCode.action?codeType=" + row.CODE_TYPE + "&codeValue=" + row.CODE_VALUE ,
							buttons : [ {
								text : '编辑',
								iconCls : 'icon-ok',
								handler : function() {
									saveEditSysCode();
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
					parent.$.messager.show({
						title :"提示",
						msg :"请选择一行记录!",
						timeout : 1000 * 2
					});
				}
			}
			//新增数据字典弹窗
			function addCodeTpye() {
				$.modalDialog({
					title : "添加词典",
					width : 600,
					height : 400,
					href : "jsp/systemCode/systemCodeEditDlg.jsp",
					buttons : [ {
						text : '保存',
						iconCls : 'icon-ok',
						handler : function() {
							saveSysCode();
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
			//查询
			function query(){
				$dg.datagrid('load',{
					queryType:'0',//查询类型
					"state":$("#state").combobox("getValue"),
					"certNo":$("#certNo").combobox("getValue"),
			});
	}
		</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info">数据词典</span>进行编辑!！</span>
		</div>
	</div>
    <div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div style="margin-bottom:5px" ID="tb">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft" style="width:8%">代码类别：</td>
						<td class="tableright" style="width:17%"><input type="text" name="certNo" id="certNo" class="textinput"/></td>
						<td class="tableleft" style="width:8%">状态：</td>
						<td class="tableright" style="width:17%"><input type="text" name="state" id="state" class="textinput"/></td>
						
				
						<td style="padding-left:2px">
								<a href="javascript:void(0);"class="easyui-linkbutton" 
									iconCls="icon-search" plain="false"onclick="query();">查询</a> 
							<shiro:hasPermission name="dicAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton"
									iconCls="icon-add" plain="false" onclick="addCodeTpye();">添加</a>
							</shiro:hasPermission> <shiro:hasPermission name="dicEdit">
								<a href="javascript:void(0);" class="easyui-linkbutton"
									iconCls="icon-edit" plain="false" onclick="updateCodeTpye();">编辑</a>
							</shiro:hasPermission> <shiro:hasPermission name="dicDel">
								<a href="javascript:void(0);" class="easyui-linkbutton"
									iconCls="icon-remove" plain="false" onclick="removeNode();">删除</a>
							</shiro:hasPermission></td>
					</tr>
			</table>
		</div>
  		<table id="dg" title="词典管理"></table>
	</div>

  </body>
</html>
