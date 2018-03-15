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
    <title>卡片注销</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $temp;
	var $grid;
	var $cardinfo;
	var cardmsg;
	var isreadcard = 1;
	var isquery = 1;
	var curreadcardno = "";
	$(function(){
		$("#agtCertType").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CERT_TYPE",
			valueField:'codeValue',
			editable:false,
		    textField:'codeName',
		    panelHeight: 'auto',
		    onSelect:function(node){
		 		$("#agtCertType").val(node.codeValue);
		 	}
		});
		$("#isGoodCard").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:'codeName',
		    panelHeight: 'auto',
		    data:[{codeValue:'0',codeName:'是'},{codeValue:'1',codeName:'否'}],
		    onSelect:function(node){
		 		if(node.codeValue == '0'){
		 			$.messager.alert("系统消息","已选择是好卡，请先进行读卡,在进行查询！","warning");
		 		}
		 		$(this).combobox('setValue',node.codeValue);
				$("#isGoodCard").val(node.codeValue);
				isreadcard = 1;
				isquery = 1;
				curreadcardno = "";
		 	}
		 });
		$("#zxreason").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CANCEL_REASON",
			valueField:'codeValue',
			editable:false,
		    textField:'codeName',
		    panelHeight: 'auto',
		    onSelect:function(node){
		 		$("#zxreason").val(node.codeValue);
		 	}
		});
		 $cardinfo = $("#cardinfo");
		 $cardinfo.datagrid({
			url:"/pointManage/pointManageAction!queryPointDetail.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			checkOnSelect:true,
			columns:[[
				{field:'DEAL_NO',title:'流水号',sortable:true,width:parseInt($(this).width()*0.04)},
				{field:'DEAL_BATCH_NO',title:'批次号',sortable:true,width:parseInt($(this).width()*0.04)},
				{field:'DEAL_CODE',title:'业务名称',sortable:true,width:parseInt($(this).width()*0.15)},
				{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.06)},
				{field:'ACC_NAME',title:'客户姓名',sortable:true,width:parseInt($(this).width()*0.06)},
				{field:'GENDER',title:'性别',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:'CERT_TYPE',title:'证件类型',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.11)},
				{field:'DEAL_DATE',title:'交易时间',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'CARD_BAL',title:'交易前积分',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'AMT',title:'交易积分',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'END_DEAL_NO',title:'终端编号',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'CARD_COUNTER',title:'卡交易序列号',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'FULL_NAME',title:'办理网点',sortable:true},
				{field:'NAME',title:'柜员',sortable:true},
				{field:'CLR_DATE',title:'清分日期',sortable:true},
				{field:'DEAL_STATE',title:'状态',sortable:true},
				{field:'NOTE',title:'备注',sortable:true}
	        ]],
		 	toolbar:'#tb',
            onLoadSuccess:function(data){
	           	 if(data.status != 0){
	           		 $.messager.alert('系统消息',data.errMsg,'error');
	           	 }
	           	 if(data.rows.length > 0 ){
		           	 $(this).datagrid('selectRow',0);
	           	 }
            }
		 });
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert('系统消息','请输入查询证件号码或是卡号！','error');
			return;
		}
		isquery = '0';
		$("input[type=checkbox]").each(function(){
			this.checked = false;
		});
		$cardinfo.datagrid('load',{
			queryType:'0',
			certNo:$('#certNo').val(),
			cardNo:$('#cardNo').val(),
			beginTime:$('#beginTime').val(),
		    endTime:$('#endTime').val()
		});
	}
	function readCard(){
		$.messager.progress({text:'正在获取卡信息，请稍后....'});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress('close');
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress('close');
		$("#cardNo").val(cardmsg["card_No"]);
		isreadcard = 0;
		query();
	}
	function readIdCard(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		//$("#certType").combobox("setValue",'1');
		$("#certNo").val(certinfo["cert_No"]);
		query();
	}
					
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>用户的积分明细进行查询！</strong></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-bottom:none;border-left:none;">
	  	<div id="tb" style="padding:2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0">
				<tr>
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" /></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableright" colspan="8">
							<shiro:hasPermission name="accountQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readIdCard()">读身份证</a>
						</td>
				</tr>
			</table>
		</div>
  		<table id="cardinfo" title="卡信息" style="height:auto;"></table>
	</div>
</body>
</html>