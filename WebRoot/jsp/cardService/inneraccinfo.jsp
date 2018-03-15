<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
	Object action = request.getParameter("cardNo");
	String cardNo = "";
	if(action != null){
		cardNo = action.toString();
	}
%>
<!-- 
	/**----------------------------------------------------*
	*@category                                             *
	*此页面为卡片账户信息查询N多公用页面，修改此页面内容必须兼顾到   *
	*所有页面                                                                                                             *
	*@author yangn                                         *  
	*@date 2015-08-05                                      *
	*@version 1.0                                          *
	*------------------------------------------------------*/
 -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>账户查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="description" content="This is my page">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $grid;
	var piframe;
	$(function(){
		 piframe = parent.window.document.getElementById("accinfo");
		 $dg = $("#dg");
		 $grid = $dg.datagrid({
			url : "cardService/cardServiceAction!accountQuery.action?cardNo=<%=cardNo%>&accKind=${param.accKind}&accState=${param.accState}&noAccKind=${param.noAccKind}",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			scrollbarSize:0,
			fitColumns:true,
			autoRowHeight:true,
			singleSelect:true,
			queryParams:{queryType:"0"},
			columns : [[
	            <c:if test='${param.isChecked}'>{field:'V_V',checkbox:true},</c:if>
	        	//{field:'CUSTOMER_ID',title:'客户编号 ',sortable:true,width:parseInt($(this).width() * 0.011)},
	        	//{field:'NAME',title:'s姓名',sortable:true,width:parseInt($(this).width() * 0.006)},
	        	/* {field:'CERTTYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.008)},
	        	{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.018)}, */
	        	{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.007)},
	        	{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.017)},
	        	{field:'ACC_NO',title:'账户号',sortable:true,width:parseInt($(this).width() * 0.006)},
	        	{field:'ACC_NAME',title:'账户名称',sortable:true,width:parseInt($(this).width() * 0.008)},
	        	/* {field:'BUSTYPE',title:'公交类型',sortable:true,width:parseInt($(this).width() * 0.007)},*/
	        	{field:'ACCKIND',title:'账户类型',sortable:true,width:parseInt($(this).width() * 0.01)},
	        	{field:'BAL',title:'总余额',sortable:true,width:parseInt($(this).width() * 0.008),formatter:function(value,row,index){
	        		if(row.ACC_KIND == "01"){
	        			return "<div title=\"注：钱包账户为脱机消费，消费数据未实时上传结算时，账户余额可能大于卡面余额\" style=\"font-weight:600;TEXT-DECORATION:underline;font-style:italic;color:red;width:100%;height:100%;\" class=\"easyui-tooltip\">" + value + "</div>";
	        		}else{
	        			return value;
	        		}
	        	}},
	        	{field:'FRZ_AMT',title:'冻结金额',sortable:true,width:parseInt($(this).width() * 0.008)},
	        	{field:'AVAILABLEAMT',title:'可用余额',sortable:true,width:parseInt($(this).width() * 0.008)},
	        	{field:'FRZ_DATE',title:'冻结日期',sortable:true},
	        	{field:'ACCSTATE',title:'状态',sortable:true,width:parseInt($(this).width() * 0.008),formatter:function(value,row,index){
		        		if(value == "正常"){
			    			return value;
			    		}else{
			    			return "<span style=\"color:red;\">" + value + "</span>"
			    		}
	        		}
	        	},
	        	//{field:'OPEN_BRCH_ID',title:'开户网点',sortable:true,width:parseInt($(this).width() * 0.01)},
	        	//{field:'OPEN_USER_ID',title:'开户柜员',sortable:true,width:parseInt($(this).width() * 0.01)},
	        	//{field:'OPEN_DATE',title:'开户日期',sortable:true,width:parseInt($(this).width() * 0.015)},
	        	//{field:'LSS_DATE',title:'挂失日期',sortable:true,width:parseInt($(this).width() * 0.015)},
	        	<c:if test='${param.fhrq}'>{field:'FHRQ',title:'余额返还日期',sortable:true,width:parseInt($(this).width() * 0.01)},</c:if>
	        	<c:if test='${param.bal_rslt}'>{field:'BAL_RSLT',title:'余额处理结果',sortable:true,width:parseInt($(this).width() * 0.01)},</c:if>
	        	{field:'LAST_DEAL_DATE',title:'最后交易日期',sortable:true,width:parseInt($(this).width() * 0.015)}
	        	//{field:'CLS_DATE',title:'注销日期',sortable:true,width:parseInt($(this).width() * 0.01)},//fhrq  bal_rslt
	        	//{field:'CLS_USER_ID',title:'注销柜员',sortable:true,width:parseInt($(this).width() * 0.01)}
	        ]],toolbar:'#tb',
            onLoadSuccess:function(data){
           	   if(data.status != 0){
           		    parent.$.messager.alert('系统消息',data.errMsg,'error');
           	   }else{
           			if(typeof(parent.calFee) == 'function'){
           				parent.calFee();
           			}
           	   }
           	   if(piframe && piframe.nodeName == "IFRAME" ){
           			piframe.style.height = ((data.rows.length + 1) * 26) + "px";
           	   }
            }
		});
	});
	function deleteAllData(){
		deteteGridAllRows("dg");
	}
	function getAllData(){
		return  $dg.datagrid("getRows");
	}
	function getSelectedData(){
		return  $dg.datagrid("getSelected");
	}
</script>
</head>
<body class="easyui-layout">
  <div data-options="region:'center',border:false" style="margin:0px;width:auto" id="accinfoid">
  	<table id="dg"></table>
  </div>
</body>
</html>
