<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<script type="text/javascript">
	var $viewgrid;
	messsageclr = "";
	$(function(){
		createSysCode({id:"agtCertType2",codeType:"CERT_TYPE"});
		$viewgrid = createDataGrid({
			id:"dgview",
			url:"merchantManage/merchantManageAction!viewMerchantConsumeInfos.action?stlSumNo=${param.stlSumNo}",
		    queryParams:{queryType:"0"},
		    pagination:true,
			border:false,
			fit:true,
			fitColumns:true,
			border:false,
			scrollbarSize:0,
			singleSelect:false,
			columns:[[
				{field:'V_V',checkbox:true},
				{field:'ACPT_ID',title:'商户编号',sortable:true,width : parseInt($(this).width() * 0.10)},
				{field:'MERCHANT_NAME',title:'商户名称',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'DB_CARD_NO',title:'卡号',sortable:true,width : parseInt($(this).width() * 0.10)},
	            {field:'ACC_KIND_NAME',title:'账户类型',sortable:true},
	            {field:'DB_AMT',title:'交易金额',sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:'DEAL_DATE',title:'交易时间',sortable:true,width : parseInt($(this).width() * 0.10)},
				{field:'DEAL_CODE_NAME',title:'交易类型',sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:'USER_ID',title:'终端编号 ',sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:'END_DEAL_NO',title:'终端交易流水',sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:'DEAL_NO',title:'中心流水',sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:'CLR_DATE',title:'清分日期',sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:'CLR_NO', title:'是否结算标志', sortable:true, minWidth : parseInt($(this).width() * 0.04), formatter : function(value){
   					if(value == ""){
   						return "未结算";
   					} else {
   						return "已结算";
   					}
   				}}
	        ]],toolbar:'#merchantConsumeviewconts',
	        onLoadSuccess:function(rsp){
	        	$("#clrmsg").html(rsp.clrSumMessage);
	        }
		});
	});
	function exportClrConsumeMx(){
		$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
		$('#downloadcsv').attr('src','merchantSettle/merchantSettleAction!execelSettleMx.action?stlSumNo='+${param.stlSumNo});
	}
</script>
<n:layout>
<n:center layoutOptions="border:false">
	<table id="dgview" title="结算交易信息"></table>
</n:center>
<div data-options="region:'south',split:false,border:false" style="height:100px; width:auto;text-align:center;overflow:hidden;">
	<h2 id ="clrmsg"></h2>
</div>
</n:layout>