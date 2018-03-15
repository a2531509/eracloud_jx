<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%@ taglib prefix="s" uri="/struts-tags" %>

<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>账户状态禁止交易的关联</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
	//$.fn.datagrid.defaults.loadMsg = '正在处理，请稍待。。。';
		var $dg;
		var $grid;
		$(function() {
			createSysCode({
				id:"cardType",
				codeType:"CARD_TYPE"
			});
			createSysCode({
				id:"accState",
				codeType:"ACC_STATE"
			});
			createSysCode({
				id:"accKind",
				codeType:"ACC_KIND"
			});
			$.createDealCode({
				id:"dealCode"
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"accountManager/accountManagerAction!toAccStateBanDealCodeQuery.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				singleSelect:true,
				autoRowHeight:true,
				showFooter: true,
				fitColumns:true,
				scrollbarSize:0,
				pageSize:20,
				columns:[[
							{field:'CARD_TYPE',title:'卡类型编号',sortable:true,width:parseInt($(this).width()*0.08)},
							{field:'CARDNAME',title:'卡类型名称',sortable:true,width:parseInt($(this).width()*0.11)},
							{field:'ACC_KIND',title:'账户编号',sortable:true,width:parseInt($(this).width()*0.11)},
							{field:'ACCNAME',title:'账户名称',sortable:true,width:parseInt($(this).width()*0.077)},
							{field:'ACC_STATE',title:'账户状态编号',sortable:true,width:parseInt($(this).width()*0.077)},
							{field:'ACCSTATE',title:'账户状态名称',sortable:true,width:parseInt($(this).width()*0.1)},
							{field:'BAN_DEAL_CODE',title:'禁止交易代码',sortable:true,width:parseInt($(this).width()*0.1)},
							{field:'DEAL_CODE_NAME',title:'禁止交易代码名称',sortable:true,width:parseInt($(this).width()*0.1)},
							{field:'STATE',title:'状态',sortable:true,width:parseInt($(this).width()*0.08),formatter:function(value,row,index){
								if(value == "注销"){
									return "<span style=\"color:red;\">" + value + "</span>"
								}else{
									return value;
								}
							}}
				  ]],
				  toolbar:'#tb',
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
				"ban.cardType":$("#cardType").combobox("getValue"),
				"ban.accState":$("#accState").combobox("getValue"),
				"ban.banDealCode":$("#dealCode").combobox("getValue"),
				"ban.state":$("#state").combobox("getValue"),
				"ban.accKind":$("#accKind").combobox("getValue")
				//mainType:$("#mainType").combobox("getValue"),
				//"accOpenConf.subType":$("#subType").combobox("getValue"),
				//"accOpenConf.confState":$("#confState").combobox("getValue")
			});
		}
		/**
		*@param type 0 新增  1编辑
		*/
		function addRowsOpenDlg(type){
			var currow = $dg.datagrid("getSelected");
			if(type == "0" || (currow && type == "1")){
				var subtitle = "",subicon = "",ruleId = "";
				if(type == "0"){subtitle = "新增账户状态和交易代码关联";subicon = "icon-add";
				}else{subtitle = "编辑账户状态和交易代码关联";subicon = "icon-edit";ruleId = currow.ID;}
				parent.$.modalDialog({
					title:subtitle,width:740,height:300,
					iconCls:subicon,maximizable:true,
					href:"accountManager/accountManagerAction!toAccStateBanDealCodeEdit.action?ruleId=" + ruleId + "&queryType=" + type,	
					buttons:[ 
				        {
							text:'保存',iconCls:'icon-ok',
							handler:function(){
								parent.save($grid);
							}
						 },{
							text:'取消',iconCls:'icon-cancel',
							handler:function(){
								parent.$.modalDialog.handler.dialog('destroy');
								parent.$.modalDialog.handler = undefined;
							}
						}
					]
				});
			}else{
				$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
			}
		}
		/**
		 *启用或是禁用
	 	 */
		function enableOrDisable(type){
			var st = "";
			if(type == "0"){
				st = "启用账户状态和禁止交易代码关联";
			}else if(type == "1"){
				st = "禁用账户状态和禁止交易代码关联";
			}
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(type == "0" && currow.STATE == "正常"){
					$.messager.alert("系统消息","当前账户状态和禁止交易代码关联已经处于【正常】状态！无需重复启用！","warning");
					return;
				}
				if(type == "1" && currow.STATE == "注销"){
					$.messager.alert("系统消息","当前账户状态和禁止交易代码关联已经处于【注销】状态！无需重复禁用！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要" + st + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!saveDisableOrEnableStateBanDealCode.action","ruleId=" + currow.ID + "&queryType=" + type,function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"), function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
								 }
							})
						},"json");
					}
				});
			}else{
				$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
			}
		}
		function saveDel(){
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(currow.STATE != "注销"){
					$.messager.alert("系统消息","【正常】状态下的账户状态和禁止交易代码关联不能进行删除，请先进行注销。<br/><span style=\"color:red\">提示：只有【注销】状态下的账户状态和禁止交易代码关联规则可以进行删除！</span>","error");
					return;
				}
				parent.$.messager.confirm("系统消息","您确定要删除该账户状态和禁止交易代码关联规则吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!saveAccStateTradingBanDelete.action","ruleId=" + currow.ID,function(data,status){
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
			<span>在此你可以对<span class="label-info"><strong>账户状态和禁止交易代码关联规则进行管理！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft" style="width:16%">卡类型：</td>
					<td class="tableright" style="width:16%"><input id="cardType" type="text" class="easyui-combobox" name="cardType"  style="width:174px;"/></td>
					<td class="tableleft" style="width:16%">账户类型：</td>
					<td class="tableright" style="width:16%"><input id="accKind" type="text" class="easyui-combobox" name="accKind"  style="width:174px;"/></td>
					<td class="tableleft" style="width:16%">账户状态：</td>
					<td class="tableright" style="width:17%"><input id="accState" type="text" class="textinput" name="accState"  style="width:174px;"/></td>
				</tr>
				<tr>
					<td class="tableleft">交易码：</td>
					<td class="tableright"><input id="dealCode" type="text" class="textinput" name="dealCode"  style="width:174px;"/></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input name="state"  class="easyui-combobox" id="state"  type="text" data-options="width:174,panelHeight:'auto',valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'正常'},{label:'1',value:'注销'}]"/></td>
					<td class="tableleft" colspan="2">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false"  onclick="query()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"    plain="false"  onclick="addRowsOpenDlg('0');">添加</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit"   plain="false"  onclick="addRowsOpenDlg('1');">编辑</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false"  onclick="saveDel();">删除</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signout" plain="false"  onclick="enableOrDisable('1');">注销</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signin"    plain="false"  onclick="enableOrDisable('0');">激活</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="账户状态和禁止交易代码关联规则管理"></table>
 	</div>
</body>
</html>