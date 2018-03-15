<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	$(function(){
		$personDetail = createDataGrid({
			id:"personDetail",
			url:"cardapply/cardApplyAction!viewPersonDetail.action?selectedId=" + encodeURI(encodeURI(decodeURI("${param.selectedId}"))),
			fit:true,
			border:false,
			pageList:[300,500,800,1000,1200],
			singleSelect:true,
			queryParams:{queryType:"0"},
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
			    	{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width()*0.06)},
			    	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.04)},
			    	{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.05)},
			    	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"BIRTHDAY",title:"出生年月",sortable:true,width:parseInt($(this).width()*0.06)},
			    	{field:"GENDER",title:"性别",sortable:true},
			    	{field:"NATION",title:"民族",sortable:true,width:parseInt($(this).width()*0.03)},
			    	{field:"REGIONNAME",title:"所属区域",sortable:true,width:parseInt($(this).width()*0.04)},
			    	{field:"TOWNNAME",title:"乡镇（街道）",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"COMMNAME",title:"社区（村）",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"MOBILE_NO",title:"联系电话",sortable:true,width:parseInt($(this).width()*0.07)},
			    	{field:"CORP_CUSTOMER_ID",title:"单位",sortable:true,width:parseInt($(this).width()*0.08)},
			    	{field:"SURE_FLAG",title:"是否确认",sortable:false}
			    ]],
		 	toolbar:"#tb2"
		});
	});
</script>
<n:layout>
	<n:center layoutOptions="border:false">
  		<table id="personDetail"></table>
	</n:center>
</n:layout>