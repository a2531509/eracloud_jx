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
    <title>消费模式维护</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
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
		
		$(function(){
			$("#modeState01").combobox({
				width:174,
				valueField:'codeValue',
				value:"",
			    textField:"codeName",
			    editable:false,
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"有效"},{codeValue:'1',codeName:"无效"}]
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "merchantRegister/merchantRegisterAction!merCsmModeInfoQuery.action",
				pagination:true,
				rownumbers:true,
				border:false,
				fit:true,
				fitColumns: true,
				scrollbarSize:0,
				striped:true,
				autoRowHeight:true,
				columns : [ [ {field : 'MODE_ID',hidden:true},
				              {field : 'MODE_NAME',title : '模式名称',width : parseInt($(this).width() * 0.1),sortable:true},
				              {field : 'ACC_SQN',title : '账户消费顺序',width : parseInt($(this).width()*0.1),sortable:true},
				              {field : 'REACC_TYPE',title : '退货账户',width : parseInt($(this).width()*0.1)},
				              {field : 'REACC_TYPE_BAK',title : '退货备用账户',width : parseInt($(this).width()*0.1),sortable:true},
				              {field : 'MODE_STATE',title : '状态', width :parseInt($(this).width()*0.1),formatter:function(value,row){
				            	  if(value == '0'){
				            		  return '有效';
				            	  }else if(value == '1'){
				            		  return '无效';
				            	  }else{
				            		  return '未知';
				            	  }
				              }},
				              {field : 'NOTE',title : '备注',width:parseInt($(this).width()*0.3)}
				              ]],toolbar:'#tb',
				              onLoadSuccess:function(data){
				            	  if(data.status != 0){
				            		 $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
			});
		});
		function query(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				modeName:$("#modeName").val(), 
				modeState:$("#modeState01").combobox('getValue')
			});
		}
		
		//弹窗修改
		function updRowsOpenDlg() {
			var row = $dg.datagrid('getSelected');
			if (row) {
				parent.$.modalDialog({
					title : "编辑商户消费模式",
					width : 900,
					height : 500,
					href : "merchantRegister/merchantRegisterAction!toEditConsumeModeView.action?modeId="+row.MODE_ID,		
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
			parent.$.modalDialog({
				title : "添加商户消费模式",
				width : 600,
				height : 300,
				resizable:false,
				href : "jsp/merchant/merConsumeModeView.jsp",
				onLoad:function(){
					if(row){
						var f = parent.$.modalDialog.handler.find("#form");
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
		
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户信息</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table class="tablegrid" cellpadding="0" cellspacing="0" style="width: auto;">
					<tr>
						<td class="tableleft">模式名称：</td>
						<td class="tableright"><input id="modeName" type="text" class="textinput  easyui-validatebox" name="modeName"  style="width:174px;cursor:pointer;"  /></td>
						<td class="tableleft">模式状态：</td>
						<td class="tableright">
							<input id="modeState01" name="modeState" class="textinput"   style="width:174px;" ></input>
						</td>
						<td class="tableright">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="addConsumeMode">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="editConsumeMode">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="delConsumeMode">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-del" plain="false" onclick="updRowsOpenDlg();">删除</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="消费模式信息"></table>
	  </div>
	  
  </body>
</html>