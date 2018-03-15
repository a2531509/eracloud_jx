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
    <title>卡片档案管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		
		$(function() {
 
			 $("#cardType").combobox({
					width:174,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"A卡",codeName:"A卡"},{codeValue:"B卡",codeName:"B卡"},
				          {codeValue:"C卡",codeName:"C卡"}]
				});
			 $("#chiType").combobox({
					width:174,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"1",codeName:"单接触式CPU"},{codeValue:"2",codeName:"单接非触式CPU"},
				          {codeValue:"3",codeName:"接触非接CPU"},{codeValue:"4",codeName:"双界面"},{codeValue:"5",codeName:"单接触逻辑"},
				          {codeValue:"6",codeName:"单非接M1卡"},{codeValue:"7",codeName:"充值卡"}]

				});
			 $("#mediaType").combobox({
					width:174,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"1",codeName:"普通卡"},{codeValue:"2",codeName:"异形卡"},
				          {codeValue:"3",codeName:"NFC卡"},{codeValue:"4",codeName:"贴面卡"},{codeValue:"5",codeName:"simall卡"}]
				});
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "cardProduct/CardProductAction!queryMerCardProInfo.action",
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
				columns : [ [
								{field:'CARD_TYPE',title:'卡片类型',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CHIP_TYPE',title:'芯片类型',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'IS_BANKSTRIPE',title:'磁条类型',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'MEDIA_TYPE',title:'介质类型',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'PRO_STATE',title:'使用状态',sortable:true,width : parseInt($(this).width() * 0.06)},
								
								{field:'CARD1_VOLUMEN',title:'卡片1容量',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CARD1_VERSION',title:'卡片1版本',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CARD1_COS_VENDER',title:'卡片1厂商',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CARD2_VOLUMEN',title:'卡片2容量',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CARD2_VERSION',title:'卡片2版本',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CARD2_COS_VENDER',title:'卡片2厂商',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'BRCH_ID',title:'网点编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'OPER_ID',title:'操作编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'ORG_ID',title:'机构编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								
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
					title : "编辑卡片信息",
					width : 870,
					height : 500,
					
					href : "cardProduct/CardProductAction!toEditCardPro.action?cardType="+rows[0].CARD_TYPE,
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
				title : "新增卡片档案",
				width : 870,
				height : 500,
				resizable:true,
				href : "cardProduct/CardProductAction!toAddCardPro.action",
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
				
				$.messager.confirm("系统消息","您确定要删除账户类型【" + currow.CARD_TYPE + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						
						$.post("cardProduct/CardProductAction!deleteMerCardPro.action",{cardType:currow.CARD_TYPE},function(data,status){
							
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
				<span>在此你可以对<span class="label-info"><strong>卡片档案</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		<div id="tb" >
			<form id="searchCont">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td style="padding-left:2px">卡片类型：</td>
						<td>
							<select id="cardType" class="easyui-combobox easyui-validatebox" name="cardType" style="width:174px;" >							
							</select>
						</td>
						<td style="padding-left:2px">芯片类型：</td>
						<td>
							<select id="chiType" class="easyui-combobox easyui-validatebox" name="chiType" style="width:174px;" >
							</select>
						</td>
						<td style="padding-left:2px">介质类型：</td>
						<td>
							<select id="mediaType" class="easyui-combobox easyui-validatebox" name="mediaType" style="width:174px;" >
							</select>
						</td>
						
						<td style="padding-left:2px">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
						<td style="padding-left:2px">
							<shiro:hasPermission name="terminalAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="terminalEidt">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="terminalCancel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"  plain="false" onclick="delRowsOpenDlg();">删除</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
				</form>
			</div>
	  		<table id="dg" title="卡片信息"></table>
	  </div>
  </body>
</html>
