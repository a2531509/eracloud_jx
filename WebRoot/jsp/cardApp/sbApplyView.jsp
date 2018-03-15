<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	$(function(){
		$personDetail = createDataGrid({
			id:"sbapplyinfo",
			url:"cardApplysbAction/cardApplysbAction!viewSbApplyDetail.action?selectedId=${param.selectedId}",
			fit:true,
			border:false,
			pageList:[300,500,800,1000,1200],
			singleSelect:true,
			queryParams:{queryType:"0"},
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
			    	{field:"EMP_ID",title:"单位编号",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"EMP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"APPLY_DATE",title:"申领时间",sortable:true,width:parseInt($(this).width()*0.1)},
			    	{field:"RECV_BRCH_NAME",title:"申领网点",sortable:true,width:parseInt($(this).width()*0.1)}
			    ]],
		 	toolbar:"#tb2"
		});
	});
</script>
<n:layout>
	<n:center layoutOptions="border:false">
  		<table id="sbapplyinfo" title=""></table>
	</n:center>
</n:layout>