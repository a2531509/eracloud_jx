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
    <title>票据信息管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function() {
			 $("#billType").combobox({
					width:174,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"1",codeName:"银行汇票"},
				          {codeValue:"2",codeName:"商业汇票"},{codeValue:"3",codeName:"商业本票"},
				          {codeValue:"4",codeName:"银行本票"},{codeValue:"5",codeName:"记名支票"},
				          {codeValue:"6",codeName:"不记名支票"},{codeValue:"7",codeName:"划线支票"},
				          {codeValue:"8",codeName:"现金支票"},{codeValue:"9",codeName:"转帐支票"}]
				});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "baseBill/baseBillAction!queryBaseBill.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				rownumbers:true,
				border:true,
				fit:true,
				singleSelect:false,
				checkOnSelect:true,
				striped:true,
				autoRowHeight:true,
				columns : [ [   {field:'BILL_NO',title:'id',sortable:true,checkbox:'true'},
								{field:'BILL_NAME',title:'票据名称',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'BILL_TYPE',title:'票据类型',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'START_NO',title:'开始编号',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'END_NO',title:'结束编号',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'BILL_NUM',title:'张数',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'AMT_FLAG',title:'定额标志',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'BILL_AMT',title:'金额',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'VALIDITY_DATE',title:'有效日期',sortable:true,width : parseInt($(this).width() * 0.07)},
								{field:'NOTE',title:'备注',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'OPER_DATE',title:'操作日期',sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:'OPER_ID',title:'操作编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'ORG_ID',title:'机构编号',sortable:true,width : parseInt($(this).width() * 0.06)}
				              ]],toolbar:'#tb',
			});
		});
		function query(){
			var c = getformdata("searchCont");
			$dg.datagrid("load",c);			
		}
		//弹窗修改
		function updRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				parent.$.modalDialog({
					title : "编辑票据信息",
					width : 870,
					height : 500,
					
					href : "baseBill/baseBillAction!toEditBaseBill.action?billNo="+rows[0].BILL_NO,
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
				title : "新增票据信息",
				width : 870,
				height : 500,
				resizable:true,
				href : "baseBill/baseBillAction!toAddBaseBill.action",
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
		function delRowsOpenDlg(){
			var currow = $dg.datagrid("getSelected");
			if(currow){
				
				$.messager.confirm("系统消息","您确定要删除票据【" + currow.BILL_NAME + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						
						$.post("baseBill/baseBillAction!deleteBaseBill.action",{billNo:currow.BILL_NO},function(data,status){
							
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
								 }
							});
						},"json");
					}
				});
			}else{
				$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
			}
		}
	</script>
  </head>
   <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>票据信息</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		<div id="tb" >
			<form id="searchCont">
				<table cellpadding="0" cellspacing="0"  style="width:100%" class="tablegrid">
					<tr>
						<td style="padding-left:2px">票据名称：</td>
						<td>
						<td class="tableright"><input type="text" name="billName" id="billName" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td style="padding-left:2px">票据类型：</td>
						<td>
							<select id="billType" class="easyui-combobox easyui-validatebox" name="billType" style="width:174px;" >
							</select>
						</td>
						<td style="padding-left:2px">
						        <a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"  plain="false" onclick="delRowsOpenDlg();">删除</a>
						</td>
					</tr>
				</table>
				</form>
			</div>
	  		<table id="dg" title="票据信息"></table>
	  </div>
  </body>
</html>
