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
    <title>账户限额设置信息</title>
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
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"accountManager/accountManagerAction!toAccLimitIndex.action",
				width : $(this).width(),
				height : $(this).height()-45,
				//fitColumns:true,
				fit:true,
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				singleSelect:true,
				autoRowHeight:true,
				scrollbarSize:0,
				pageSize:20,
				frozenColumns:[[
						{field:'V_V',checkbox:true},
						{field:'DEAL_NO',title:'流水号',sortable:true,width:parseInt($(this).width() * 0.06)},
						{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.08)},
						{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.08)},
						{field:'CERT_TYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.06)},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.12)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.13)}    
				]],
				columns:[[
				    	{field:'CARD_TYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.05)},
				    	//{field:'ACC_NO',title:'账户号',sortable:true,width:parseInt($(this).width() * 0.03)},
				    	{field:'ACC_KIND',title:'账户类型',sortable:true,width:parseInt($(this).width() * 0.06)},
				    	{field:'MIN_AMT',title:'小额免密码支付',sortable:true,width:parseInt($(this).width() * 0.1)},
				    	{field:'MAX_NUM',title:'单日消费最大笔数',sortable:true,width:parseInt($(this).width() * 0.1)},
				    	{field:'AMT',title:'单笔消费最大金额',sortable:true,width:parseInt($(this).width() * 0.1)},
				    	{field:'MAX_AMT',title:'单日消费最大总金额',sortable:true,width:parseInt($(this).width() * 0.11)},
				    	//{field:'ITEM_NO',title:'科目编号',sortable:true,width:parseInt($(this).width() * 0.04)},
				    	//{field:'CLR_DATE',title:'清分日期',sortable:true},
				    	{field:'STATE',title:'状态',sortable:true,width:parseInt($(this).width() * 0.04),formatter:function(value,row,index){
				    		if(value == "正常"){
				    			return value;
				    		}else{
				    			return "<span style=\"color:red;\">" + value + "</span>"
				    		}
				    	}},
				    	{field:'BIZ_TIME',title:'办理时间',sortable:true,width:parseInt($(this).width() * 0.12)},
				    	//{field:'ORG_ID',title:'机构',sortable:true},
				    	{field:'FULL_NAME',title:'办理网点',sortable:true},
				    	{field:'OPERNAME',title:'办理柜员',sortable:true}
				    	//{field:'NOTE',title:'备注',sortable:true},
				   ]],
				  toolbar:'#tb',
	              onLoadSuccess:function(data){
	            	  $("input[type=checkbox]").each(function(){
	        				this.checked = false;
	        		  });
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
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				"card.cardType":$("#cardType2").val(),
				"card.cardNo":$("#cardNo2").val(),
				"bp.certType":$("#certType2").combobox("getValue"),
				"bp.certNo":$("#certNo2").val(),
				"acc.accKind":$("#accKind").combobox("getValue"),
				"limit.state":$("#state").combobox("getValue")
			});
		}
		function addRowsOpenDlg(type){
			var currow = $dg.datagrid("getSelected");
			if(type == "0" || (currow && type == "1")){
				var subtitle = "",subicon = "",ruleId = "";
				if(type == "0"){subtitle = "新增账户额度限制";subicon = "icon-add";}else{subtitle = "编辑账户额度限制";subicon = "icon-edit";ruleId = currow.DEAL_NO;}
				$.modalDialog({
					title:subtitle,width:740,height:300,
					iconCls:subicon,maximizable:true,maximized:true,
					href:"accountManager/accountManagerAction!toAccLimitEdit.action?ruleId=" + ruleId + "&queryType=" + type,	
					buttons:[ 
				        {
							text:'保存',iconCls:'icon-ok',
							handler:function(){
								saveOrUpdateAccLimit();
							}
						 },{
							text:'取消',iconCls:'icon-cancel',
							handler:function(){
								$.modalDialog.handler.dialog('destroy');
								$.modalDialog.handler = undefined;
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
				st = "启用账户限额设置信息";
			}else if(type == "1"){
				st = "禁用账户限额设置信息";
			}
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(type == "0" && currow.STATE == "正常"){
					$.messager.alert("系统消息","当前账户限额设置信息已经处于【正常】状态！无需重复启用！","warning");
					return;
				}
				if(type == "1" && currow.STATE == "注销"){
					$.messager.alert("系统消息","当前账户限额设置信息已经处于【注销】状态！无需重复禁用！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要" + st + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!saveDisableOrEnableAccLimit.action","ruleId=" + currow.DEAL_NO + "&queryType=" + type,function(data,status){
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
		function savedelete(){
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(currow.STATE != "注销"){
					$.messager.alert("系统消息","【正常】状态下的账户限额设置信息不能进行删除，请先进行注销。<span style=\"color:red\">提示：只有【注销】状态下的账户限额设置信息可以进行删除！</span>","error");
					return;
				}
				parent.$.messager.confirm("系统消息","您确定要删除该账户限额设置信息吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!saveAccLimitDelete.action","ruleId=" + currow.DEAL_NO,function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
								 if(data.status == "0"){
									 //$dg.datagrid("reload");
									$dg.datagrid($dg.datagrid("getRowIndex",currow));
								 }
							});
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
			<span>在此你可以对<span class="label-info"><strong>账户消费限额信息进行管理！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;border-left:none;border-bottom:none;">
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
					<td class="tableright"><input name="state"  class="easyui-combobox" id="state"  type="text" data-options="width:174,panelHeight:'auto',valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'正常'},{label:'1',value:'注销'}]"/></td>
					<td class="tableleft" colspan="4">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false"  onclick="readCard2()">读卡</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readIdcard" plain="false"   onclick="readIdCard2()">读身份证</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search"   plain="false"  onclick="queryacclimitinfo()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"      plain="false"  onclick="addRowsOpenDlg('0');">添加</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit"     plain="false"  onclick="addRowsOpenDlg('1');">编辑</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"   plain="false"  onclick="savedelete();">删除</a>
						<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-checkInfo" data-options="menu:'#mm1'" plain="false" onclick="javascript:void(0)">状态管理</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="账户消费限额信息"></table>
  		<div id="mm1" style="width:50px;display: none;">
			<div data-options="iconCls:'icon-signout'" onclick="enableOrDisable('1');">注销</div>
			<div class="menu-sep"></div>
			<div data-options="iconCls:'icon-signin'" onclick="enableOrDisable('0');">激活</div>
		</div>
 	</div>
</body>
</html>