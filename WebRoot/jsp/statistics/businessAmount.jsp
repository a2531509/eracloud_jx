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
<title>系统业务量统计</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<%@ include file="/layout/variedscript.jsp" %>
<script type="text/javascript">
var revenueChart = null;
function disploseResourse(){
	if(revenueChart){
		revenueChart.dispose();
	}
}
$(function(){
	$("#myfirstfusioncharts").panel({
		collapsed:false,collapsible:false,
		tools:"#charTypeDiv",
		fit:true,doSize:true,border:false
	});
	$("#chartType").combobox({ 
		    editable:false,
		    cache:true,
		    panelHeight:'auto',
		    valueField:'codeValue',   
		    textField:'codeName',
		    style:{border:"none"},
		    width:80,
		    data:[
		          {codeValue:'area2d',codeName:"area2d"},{codeValue:'bar2d',codeName:"bar2d"},
		          {codeValue:'bar3d',codeName:"bar3d"},{codeValue:'column2d',codeName:"column2d"},
		          {codeValue:'column3d',codeName:"column3d"},{codeValue:'pareto2d',codeName:"pareto2d"},
		          {codeValue:'pareto3d',codeName:"pareto3d"},
		          {codeValue:'line',codeName:"line"},
		          {codeValue:'pie2d',codeName:"pie2d"},{codeValue:'pie3d',codeName:"pie3d"},
		          {codeValue:'doughnut2d',codeName:"doughnut2d"},{codeValue:'doughnut3d',codeName:"doughnut3d"}				    
		    ],
		    onSelect:function(option){
		    	if(revenueChart){
		    		revenueChart.chartType(option.codeValue);
		    	}
		    }
		   }); 
	  	   var revenueChart = new FusionCharts({
	         "type": "bar2d",
	         "renderAt": "myfirstfusioncharts",
	         "width":"100%",
	         "height":"95%",
	         "showShadow":true,
	         "borderAlpha":10,
	         "bgAlpha":10,
	         "showToolTip":true,
	         "showBorder": "0",
	         "showPercentValues": "0",
	         "showPercentInTooltip":"0",
	         "dataFormat":"jsonurl",
	         "adjustDiv":true,
	         "loadMessage":"正在加载，请稍后...",
	         "dataLoadStartMessage":"正在加载，请稍后...",
	         "showDataLoadingMessage":true,
	         "baseChartMessageFont":"微软雅黑",
	         "stack100Percent":0,
	         "rotateNames":0,
	         "renderErrorMessage":"图标加载失败！，请刷新页面后重试！",
	         "showChartLoadingMessage":true,
	         "dataEmptyMessage":"未获取到数据,或统计出现错误,请刷新后重试..."
	    });
	  	// revenueChart.
	    revenueChart.setJSONUrl("statistical/statisticalAnalysisAction!businessAmount.action?timeRange=0");
	    revenueChart.render();
});
</script>
 </head>
<body onunload="disploseResourse()" class="easyui-layout">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以<span class="label-info"><strong>预览系统当前业务量统计情况！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true,fit:true" style="border-left:none;border-bottom:none;">
		<div id="myfirstfusioncharts" title=<%=com.erp.util.Constants.APP_REPORT_TITLE%>"业务量汇总(当日)" style="background:#fafafa;margin:0;padding:0;overflow:auto;"></div>
		<div id="charTypeDiv">
			<input type="text" name="chartType" id="chartType" class="textinput" value="bar2d" >
		</div>
	 </div>
</body>
</html>