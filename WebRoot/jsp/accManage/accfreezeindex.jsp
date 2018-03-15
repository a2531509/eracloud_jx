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
    <title>账户冻结管理</title>
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
				url:"accountManager/accountManagerAction!accFreezeQuery.action",
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
						{field:'CERTTYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.06)},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.12)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.13)}
				]],
				columns:[[
				    	{field:'CARD_TYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.05)},
				    	//{field:'ACC_NO',title:'账户号',sortable:true,width:parseInt($(this).width() * 0.03)},
				    	{field:'ACCKIND',title:'账户类型',sortable:true,width:parseInt($(this).width() * 0.05)},
				    	{field:'FRZ_AMT',title:'冻结金额',sortable:true,width:parseInt($(this).width() * 0.06)},
				    	{field:'FRZ_TYPE',title:'冻结类型',sortable:true,width:parseInt($(this).width() * 0.08)},
				    	{field:'INSERT_DATE',title:'冻结日期',sortable:true,sortable:true,width:parseInt($(this).width() * 0.12)},
				    	{field:'STATE',title:'状态',sortable:true,width:parseInt($(this).width() * 0.03),formatter:function(value,row,index){
				    		if(value == "正常"){
				    			return value;
				    		}else{
				    			return "<span style=\"color:red;\">" + value + "</span>"
				    		}
				    	}},
				    	//{field:'ITEM_NO',title:'科目编号',sortable:true,width:parseInt($(this).width() * 0.04)},
				    	//{field:'CLR_DATE',title:'清分日期',sortable:true},
				    	{field:'FULL_NAME',title:'操作网点',sortable:true,width:parseInt($(this).width() * 0.12)},
				    	{field:'USERNAME',title:'操作柜员',sortable:true,width:parseInt($(this).width() * 0.12)}
				    	//{field:'ORG_ID',title:'机构',sortable:true},
				    	//{field:'BRCH_ID',title:'网点',sortable:true},
				    	//{field:'USER_ID',title:'柜员',sortable:true},
				    	//{field:'NOTE',title:'备注',sortable:true},
				   ]],
				  toolbar:'#tb',
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
		function readIdCard2(){
			var o = getcertinfo();
			if(dealNull(o["name"]).length == 0){
				return;
			}
			$("#certNo2").val(o["cert_No"]);
			queryacclimitinfo();
		}
		function queryacclimitinfo(){
			$("input[type=checkbox]").each(function(){
				this.checked = false;
			});
			$dg.datagrid('reload',{
				queryType:'0',//查询类型
				"card.cardType":$("#cardType2").val(),
				"card.cardNo":$("#cardNo2").val(),
				"bp.certType":$("#certType2").combobox("getValue"),
				"bp.certNo":$("#certNo2").val(),
				"acc.accKind":$("#accKind").combobox("getValue"),
				"acc.accState":$("#state").combobox("getValue"),
				"startTime":$("#startTime").val(),
				"endTime":$("#endTime").val()
			});
		}
		function addRowsOpenDlg(){
			var subtitle = "",subicon = "";
			subtitle = "新增账户余额冻结信息";subicon = "icon-signout";
			$.modalDialog({
				title:subtitle,width:740,height:300,
				iconCls:subicon,maximizable:false,maximized:true,closed:false,resizable:false,closable:false,shadow:false,inline:false,fit:true,
				href:"accountManager/accountManagerAction!toAccFreezeAdd.action",	
				buttons:[ 
			        {
						text:'保存',iconCls:'icon-ok',
						handler:function(){
							saveAccFreezeAdd();
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
		}
		function saveAccUnFreeze(){
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(currow.REC_TYPE == "1"){
					$.messager.alert("系统消息","该冻结记录已经解冻无需重复进行解冻！<br/><span style=\"color:red\">提示：只有【正常】状态下的冻结记录可以进行解冻！</span>","error");
					return;
				}
				if(currow.REC_TYPE != "0"){
					$.messager.alert("系统消息","该冻结记录状态正常无法进行解冻操作！<br/><span style=\"color:red\">提示：只有【正常】状态下的冻结记录可以进行解冻！</span>","error");
					return;
				}
				$.messager.confirm("系统消息","您确定要解冻该账户冻结金额吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!saveAccUnFreeze.action","ruleId=" + currow.DEAL_NO,function(data,status){
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
				$.messager.alert("系统消息","请选择一条冻结记录信息再进行解冻操作！","error");
			}
		}
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>账户余额进行冻结或解冻管理！<span style="color:red;font-size:600;">注意：</span>只有账户状态正常的账户才能进行冻结；解冻无账户状态限制。</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
			<div id="tb">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft" style="width:6%;">卡类型：</td>
						<td class="tableright" style="width:21%;"><input id="cardType2" type="text" class="textinput" name="cardType2"/></td>
						<td class="tableleft" style="width:14%;">卡号：</td>
						<td class="tableright" style="width:23%;"><input id="cardNo2" type="text" class="textinput" name="cardNo2"/></td>
						<td class="tableleft" style="width:18%;">账户类型：</td>
						<td class="tableright" style="width:18%;"><input id="accKind" type="text" class="easyui-combobox" name="accKind"/></td>
					</tr>
					<tr>
						<td class="tableleft">证件类型：</td>
						<td class="tableright"><input id="certType2" type="text" class="textinput" name="certType2"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo2" type="text" class="textinput" name="certNo2"/></td>
						<td class="tableleft">状态：</td>
						<td class="tableright"><input name="state"  class="easyui-combobox" id="state"  type="text" data-options="width:174,panelHeight:'auto',valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'正常'},{label:'1',value:'注销'}]"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="startTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft" colspan="2">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false"  onclick="readCard2()">读卡</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readIdcard" plain="false"   onclick="readIdCard2()">读身份证</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false"  onclick="queryacclimitinfo()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signout" plain="false"  onclick="addRowsOpenDlg();">添加账户冻结</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signin" plain="false"  onclick="saveAccUnFreeze('0');">账户解冻</a>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="账户冻结信息"></table>
  		</div>
</body>
</html>