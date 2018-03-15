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
    <title>柜员柜面业务</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style>
		.combobox-item{
			cursor:pointer;
		}
		.panel-with-icon:{padding-left:0px;marign-left:0px;}
		.panel-title:{width:13px;padding-left:0px;}
		.datagrid-cell-group {
    		font-family: 幼圆,helvetica,tahoma,verdana,sans-serif;
    		color: black;
   		 	font-weight: 600;
		}
	</style>
	<script type="text/javascript"> 
	
	$(function() {
		createSysBranch("branchId","userId");
		
		var myview = $.extend({}, $.fn.datagrid.defaults.view, {
		    renderFooter: function(target, container, frozen){
		        var opts = $.data(target, 'datagrid').options;
		        var rows = $.data(target, 'datagrid').footer || [];
		        var fields = $(target).datagrid('getColumnFields', frozen);
		        var table = ['<table class="datagrid-ftable" cellspacing="0" cellpadding="0" border="0"><tbody>'];
		         
		        for(var i=0; i<rows.length; i++){
		            var styleValue = opts.rowStyler ? opts.rowStyler.call(target, i, rows[i]) : '';
		            var style = styleValue ? 'style="' + styleValue + '"' : '';
		            table.push('<tr class="datagrid-row" datagrid-row-index="' + i + '"' + style + '>');
		            table.push(this.renderRow.call(this, target, fields, frozen, i, rows[i]));
		            table.push('</tr>');
		        }
		         
		        table.push('</tbody></table>');
		        $(container).html(table.join(''));
		    }
		});
		
		$("#dg").datagrid({
			url:"sysReportQuery/sysReportQueryAction!businessQuery.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageList : [100, 200, 500, 1000, 2000],
			striped : true,
			border : false,  
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			singleSelect : false,
			view:myview,
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			frozenColumns : [[
				{field:"", checkbox:true},
				{field:"BRCH_ID", title:"网点编号", sortable:true, width:parseInt($(this).width()*0.08)},
				{field:"BRCH_NAME", title:"网点名称", sortable:true, width:parseInt($(this).width()*0.15)},
				{field:"USER_ID", title:"柜员编号", sortable:true, width:parseInt($(this).width()*0.08)},
				{field:"USER_NAME", title:"柜员名称", sortable:true, width:parseInt($(this).width()*0.08)}
			]],
			columns:[[
				{field:"FWMMCZ_NUM", title:"服务密码重置", width:"80px", align:"center", formatter:buildNum},
				{field:"FWMMXG_NUM", title:"服务密码修改", width:"80px", align:"center", formatter:buildNum},
				{field:"JYMMCZ_NUM", title:"交易密码重置", width:"80px", align:"center", formatter:buildNum},
				{field:"JYMMXG_NUM", title:"交易密码修改", width:"80px", align:"center", formatter:buildNum},
				{field:"SBMMCZ_NUM", title:"医保密码重置", width:"80px", align:"center", formatter:buildNum},
				{field:"SBMMXG_NUM", title:"医保密码修改", width:"80px", align:"center", formatter:buildNum},
				{field:"GMGRSL_NUM", title:"零星申领", width:"80px", align:"center", formatter:buildNum},
				{field:"CARD_ISSUE_NUM", title:"卡发放", width:"80px", align:"center", formatter:buildNum},
				{field:"YGSYW_NUM", title:"临时挂失", width:"80px", align:"center", formatter:buildNum},
				{field:"GSYW_NUM", title:"挂失", width:"80px", align:"center", formatter:buildNum},
				{field:"JGSYW_NUM", title:"解挂失", width:"80px", align:"center", formatter:buildNum},
				{field:"BKYW_NUM", title:"补卡", width:"80px", align:"center", formatter:buildNum},
				{field:"HKYW_NUM", title:"换卡", width:"80px", align:"center", formatter:buildNum},
				{field:"ZXYW_NUM", title:"注销", width:"80px", align:"center", formatter:buildNum},
				{field:"HKZQB_NUM", title:"换卡转钱包", width:"80px", align:"center", formatter:buildNum},
				{field:"TCQBG_NUM", title:"统筹区变更", width:"80px", align:"center", formatter:buildNum},
				{field:"YHKBD_NUM", title:"银行卡绑定", width:"80px", align:"center", formatter:buildNum},
				{field:"YHKJB_NUM", title:"银行卡解绑", width:"80px", align:"center", formatter:buildNum}
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', "加载数据失败, " + data.errMsg, 'error');
				}
				
				updateFooter();
			},
			onBeforeLoad : function(params){
				if(!params["brch_Id"] || params["brch_Id"] == ""){
					return false;
				}
			},
			onSelect:function(){
				updateFooter();
			},
			onUnselect:function(){
				updateFooter();
			},
			onSelectAll:function(){
				updateFooter();
			},
			onUnselectAll:function(){
				updateFooter();
			}
		});
	});
	
	function updateFooter(){
		var selections = $("#dg").datagrid("getSelections");

		var BRCH_ID = "统计：";
		var FWMMCZ_NUM = 0;
		var FWMMXG_NUM = 0;
		var JYMMCZ_NUM = 0;
		var JYMMXG_NUM = 0;
		var KPSDYW_NUM = 0;
		var KPJSYW_NUM = 0;
		var YGSYW_NUM = 0;
		var GSYW_NUM = 0;
		var JGSYW_NUM = 0;
		var BKYW_NUM = 0;
		var HKYW_NUM = 0;
		var ZXYW_NUM = 0;
		var GMGRSL_NUM = 0;
		var HJLQR_NUM = 0;
		var HJLQR_AMT = 0;
		var SBMMCZ_NUM = 0;
		var SBMMXG_NUM = 0;
		var CARD_ISSUE_NUM = 0;
		var HKZQB_NUM = 0;
		var TCQBG_NUM = 0;
		var YHKBD_NUM = 0;
		var YHKJB_NUM = 0;
		
		for(var i in selections){
			var row = selections[i];
			
			FWMMCZ_NUM += Number(row.FWMMCZ_NUM);
			FWMMXG_NUM += Number(row.FWMMXG_NUM);
			JYMMCZ_NUM += Number(row.JYMMCZ_NUM);
			JYMMXG_NUM += Number(row.JYMMXG_NUM);
			KPSDYW_NUM += Number(row.KPSDYW_NUM);
			KPJSYW_NUM += Number(row.KPJSYW_NUM);
			YGSYW_NUM += Number(row.YGSYW_NUM);
			GSYW_NUM += Number(row.GSYW_NUM);
			JGSYW_NUM += Number(row.JGSYW_NUM);
			BKYW_NUM += Number(row.BKYW_NUM);
			HKYW_NUM += Number(row.HKYW_NUM);
			ZXYW_NUM += Number(row.ZXYW_NUM);
			GMGRSL_NUM += Number(row.GMGRSL_NUM);
			HJLQR_NUM += Number(row.HJLQR_NUM);
			HJLQR_AMT += Number(row.HJLQR_AMT);
			SBMMCZ_NUM += Number(row.SBMMCZ_NUM);
			SBMMXG_NUM += Number(row.SBMMXG_NUM);// 
			CARD_ISSUE_NUM += Number(row.CARD_ISSUE_NUM);
			HKZQB_NUM += Number(row.HKZQB_NUM);
			TCQBG_NUM += Number(row.TCQBG_NUM);
			YHKBD_NUM += Number(row.YHKBD_NUM);
			YHKJB_NUM += Number(row.YHKJB_NUM);
		}
		
		$("#dg").datagrid("reloadFooter", [{
			isFooter : true,
			BRCH_ID : BRCH_ID,
			BRCH_NAME : "共 " + selections.length + " 条记录",
			FWMMCZ_NUM : FWMMCZ_NUM,
			FWMMXG_NUM : FWMMXG_NUM,
			JYMMCZ_NUM : JYMMCZ_NUM,
			JYMMXG_NUM : JYMMXG_NUM,
			KPSDYW_NUM : KPSDYW_NUM,
			KPJSYW_NUM : KPJSYW_NUM,
			YGSYW_NUM : YGSYW_NUM,
			GSYW_NUM : GSYW_NUM,
			JGSYW_NUM : JGSYW_NUM,
			BKYW_NUM : BKYW_NUM,
			HKYW_NUM : HKYW_NUM,
			ZXYW_NUM : ZXYW_NUM,
			GMGRSL_NUM : GMGRSL_NUM,
			HJLQR_NUM : HJLQR_NUM,
			HJLQR_AMT : HJLQR_AMT,
			SBMMCZ_NUM : SBMMCZ_NUM,
			SBMMXG_NUM : SBMMXG_NUM,
			CARD_ISSUE_NUM : CARD_ISSUE_NUM,
			HKZQB_NUM : HKZQB_NUM,
			TCQBG_NUM : TCQBG_NUM,
			YHKBD_NUM : YHKBD_NUM,
			YHKJB_NUM : YHKJB_NUM
		}]);
	}
	
	function formatAmt(s){
		var n = 2; //小数
		var lessThanZero = false;
		s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n);
		if(s < 0){
			lessThanZero = true;
		}
		var l = (Math.abs(s) + "").split(".")[0].split("").reverse(),
		r = s.split(".")[1];
		t = "";
		for(i = 0; i < l.length; i ++ ){  
			t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : "");
		}
		t = t.split("").reverse().join("") + "." + r;
		return lessThanZero?"-" + t:t;
	}
	
	function buildAmt(value){
		var span = "<span style='color:green'>value</span>";
		
		if(isNaN(value) || Number(value) == 0){
			value = 0;
			span = span.replace(/green/g, "black");
		}
		
		return span.replace(/value/g, formatAmt(parseFloat(value) / 100));
	}
	
	function buildNum(value){
		var span = "<span style='color:green'>value</span>";
		
		if(isNaN(value) || Number(value) == 0){
			value = 0;
			span = span.replace(/green/g, "black");
		}
		
		return span.replace(/value/g, value);
	}
	
	function query(){
		var brchId = $("#branchId").combobox("getValue");
		var queryRpType = 0;
		if(!brchId || brchId == ""){
			$.messager.alert("提示", "请输入网点.", "warning");
			return;
		}
		
		var param = {
				brch_Id:brchId,
				user_Id:$("#userId").combobox("getValue"),
				startDate:$("#startDate").val(),
				endDate:$("#endDate").val(),
				queryType:queryRpType
			};
		
		$("#dg").datagrid("load", param);
	}
	
	function view(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(!selection || selection.length != 1) {
			$.messager.alert("提示", "请选择一条数据.", "warning");
			return;
		}
		
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		$.post("cuteDayManage/cuteDayAction!queryDayBal.action",
					{userId:selection[0]["USER_ID"],
					 branchId:selection[0]["BRCH_ID"],
					 clrDate:selection[0]["CLR_DATE"]},
					function(result){
						$.messager.progress('close');
						if(result.status =='1'){
							$.messager.alert('系统消息',result.msg,'error');
						}else{
							showCurrentPdf(result.rptilte);
						}
				},'json');
	}
	
	function exportToExcel(){
		var param = "brch_Id=" + $("#branchId").combobox("getValue")
				+ "&user_Id=" + $("#userId").combobox("getValue")
				+ "&startDate=" + $("#startDate").val()
				+ "&endDate=" + $("#endDate").val()
				+ "&queryType=0&rows=1000";
		
		var brchIds = "";
		var selections = $("#dg").datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				brchIds += selections[i].BRCH_ID + selections[i].USER_ID + ",";
			}
		}
		if(brchIds){
			brchIds = brchIds.substring(0, brchIds.length - 1);
		}
		if(brchIds){
			param += "&checkIds=" + brchIds;
		}
		$("#frame_download").attr("src", "sysReportQuery/sysReportQueryAction!exportBusinessStat.action?" + param);
	}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>柜员柜面业务统计信息</strong></span>进行查询，导出操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;background-color:rgb(245,245,245);">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft">所属网点：</td>
						<td class="tableright">
							<input id="branchId" type="text" class="textinput  easyui-validatebox" name="branchId"/>
						</td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput  easyui-validatebox" name="userId"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input id="startDate" type="text" name="clrDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endDate" type="text" name="clrDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,minDate:'#F{$dp.$D(\'startDate\')}', maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft" style="padding-right: 25px;">
						   <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						   <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="exportToExcel()">导出</a>
						</td>
					</tr>
				</table>
			</div>
			<table id="dg" title="柜员柜面业务统计"></table>
	  </div>
	  <iframe id="frame_download" style="display: none"></iframe>
</body>
</html>