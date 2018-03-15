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
    <title>账户锁定与解锁</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
		var $dg;
		var $grid;
		$(function() {
			createSysCode({
				id:"accKind",
				codeType:"ACC_KIND"
			});
			createSysCode({
				id:"certType2",
				codeType:"CERT_TYPE"
			});
			createSysCode({
				id:"cardType2",
				codeType:"CARD_TYPE"
			});
			createSysCode({
				id:"state",
				codeType:"ACC_STATE"
			});
			$dg = $("#dg");
			$grid = $dg.datagrid({
				url : "cardService/cardServiceAction!accountQuery.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:true,
				striped:false,
				scrollbarSize:0,
				//fitColumns:true,
				singleSelect:true,
				//0未启用1正常2口头挂失3书面挂失9注销
				frozenColumns:[[
							{field:'V_V',checkbox:true},
							{field:'CUSTOMER_ID',title:'客户编号 ',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'CERTTYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.05)},
							{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.12)},
							{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.13)} 
				]],
				columns : [[
				        	{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.05)},
				        	{field:'BUSTYPE',title:'公交类型',sortable:true,width:parseInt($(this).width() * 0.05)},
				        	{field:'ACCKIND',title:'账户类型',sortable:true,width:parseInt($(this).width() * 0.05)},
				        	{field:'ACCSTATE',title:'账户状态',sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
				        		if(value != "正常"){
				        			return "<span style=\"color:red\">" + value + "</span>";
				        		}else{
				        			return value;
				        		}
				        	}},
				        	{field:'BAL',title:'余额',sortable:true,width:parseInt($(this).width() * 0.05)},
				        	{field:'FRZ_AMT',title:'冻结金额',sortable:true,width:parseInt($(this).width() * 0.05)},
				        	{field:'FRZ_DATE',title:'冻结日期',sortable:true,width:parseInt($(this).width() * 0.12)},
				        	{field:'AVAILABLEAMT',title:'可用余额',sortable:true},
				        	{field:'LAST_DEAL_DATE',title:'最后交易日期',sortable:true,width:parseInt($(this).width() * 0.12)},
				        	{field:'OPEN_BRCH_ID',title:'开户网点',sortable:true,width:parseInt($(this).width() * 0.12)},
				        	{field:'OPEN_USER_ID',title:'开户柜员',sortable:true,width:parseInt($(this).width() * 0.08)},
				        	{field:'OPEN_DATE',title:'开户日期',sortable:true,width:parseInt($(this).width() * 0.12)},
				        	{field:'LSS_DATE',title:'挂失日期',sortable:true,width:parseInt($(this).width() * 0.12)}
		        ]],toolbar:'#tb',
                   onLoadSuccess:function(data){
	            	  if(data.status != 0){
	            		  $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
               }
			});
		});
		function readCard2(){
			cardmsg = getcardinfo();
			if(dealNull(cardmsg["card_No"]).length == 0){
				$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
				return;
			}
			$("#cardNo2").val(cardmsg["card_No"]);
			//$("#cardAmt").val((parseFloat(isNaN(cardmsg['wallet_Amt']) ? 0:cardmsg['wallet_Amt'])/100).toFixed(2));
			queryacclimitinfo();
		}
		function queryacclimitinfo(){
			$("input[type=checkbox]").each(function(){
				this.checked = false;
			});
			if(dealNull($("#cardNo2").val()).length == 0 && dealNull($("#certNo2").val()).length == 0){
				$.messager.alert("系统消息","请输入卡号或证件号码以进行查询账户信息！","error",function(){
					$("#cardNo2").focus();
				});
				return;
			}
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				"cardType":$("#cardType2").val(),
				"cardNo":$("#cardNo2").val(),
				"certType":$("#certType2").combobox("getValue"),
				"certNo":$("#certNo2").val(),
				"accKind":$("#accKind").combobox("getValue"),
				"accState":$("#state").combobox("getValue")
			});
		}
		/**
		 *启用或是禁用
	 	 */
		function enableOrDisable(type){
			var st = "";
			if(type == "0"){
				st = "锁定账户信息";
			}else if(type == "1"){
				st = "解锁账户信息";
			}
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(type == "0" && currow.ACC_STATE == "4"){
					$.messager.alert("系统消息","当前账户已经处于【锁定】状态！无需重复锁定！","warning");
					return;
				}
				if(type == "1" && currow.ACC_STATE == "1"){
					$.messager.alert("系统消息","当前账户已经处于【正常】状态！无需重复解锁！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要【" + st + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!saveAccountLockOrUnlock.action","card.cardNo=" + currow.CARD_NO + "&queryType=" + type + "&accKind=" + currow.ACC_KIND,function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
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
		function readIdCard2(){
			var o = getcertinfo();
			if(dealNull(o["name"]).length == 0){
				return;
			}
			$("#certNo2").val(o["cert_No"]);
			queryacclimitinfo();
		}
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>账户进行锁定与解锁管理！<span style="color:red;font-size:600;">注意：</span>账户锁定后将不允许该账户进行相关的交易；钱包账户脱机使用，锁定将失效。</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input id="cardNo2" type="text" class="textinput" name="cardNo2"  style="width:174px;"/></td>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input id="cardType2" type="text" class="textinput" name="cardType2"  style="width:174px;"/></td>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input id="certNo2" type="text" class="textinput" name="certNo2"  style="width:174px;"/></td>
					<td class="tableleft">证件类型：</td>
					<td class="tableright"><input id="certType2" type="text" class="textinput" name="certType2"  style="width:174px;"/></td>
				</tr>
				<tr>
					<td class="tableleft">账户类型：</td>
					<td class="tableright"><input id="accKind" type="text" class="easyui-combobox" name="accKind"  style="width:174px;"/></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input name="state"  class="easyui-combobox" id="state"  type="text"/></td>
					<td class="tableleft" colspan="4">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false"  onclick="readCard2()">读卡</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readIdcard" plain="false"   onclick="readIdCard2()">读身份证</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search"   plain="false"  onclick="queryacclimitinfo()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-lock"   plain="false"  onclick="enableOrDisable('0');">锁定</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-unlock"      plain="false"  onclick="enableOrDisable('1');">解锁</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="账户锁定与解锁"></table>
	</div>
</body>
</html>