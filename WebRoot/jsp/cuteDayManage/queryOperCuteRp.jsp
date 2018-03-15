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
    <title>系统业务凭证查询</title>
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
			url:"cuteDayManage/cuteDayAction!queryDayBals.action",
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
				{field:"", checkbox:true, rowspan:3},
				{field:"BRCH_ID", title:"网点编号", sortable:true, width:parseInt($(this).width()*0.08), rowspan:3},
				{field:"BRCH_NAME", title:"网点名称", sortable:true, width:parseInt($(this).width()*0.15), rowspan:3},
				{field:"USER_NAME", title:"柜员", sortable:true, width:parseInt($(this).width()*0.08), rowspan:3},
				{field:"CLR_DATE", title:"清分日期", sortable:true, width:parseInt($(this).width()*0.08), rowspan:3}
			],[],[]],
			columns:[[
						{title:"收入", align:"center", colspan:8},
						{title:"支出", align:"center", colspan:12},
						{title:"现金汇总", align:"center", colspan:3, rowspan:2},
						{title:"业务统计", align:"center", colspan:19},
					],[
						{title:"市民卡账户充值", align:"center", colspan:2},
						{title:"市民卡钱包充值", align:"center", colspan:2},
						{title:"补换卡金额", align:"center", colspan:2},
						{title:"本日收入汇总", align:"center", colspan:2},
						// 支出
						{title:"市民卡账户充值撤销", align:"center", colspan:2},
						{title:"市民卡钱包充值撤销", align:"center", colspan:2},
						{title:"补换卡撤销金额", align:"center", colspan:2},
						{title:"注销账户返还余额", align:"center", colspan:2},
						{title:"网点存款", align:"center", colspan:2},
						{title:"本日支出汇总", align:"center", colspan:2},
						// 业务汇总
						{title:"灰记录确认", align:"center", colspan:2},
						{field:"FWMMCZ_NUM", title:"服务密码重置", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"FWMMXG_NUM", title:"服务密码修改", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"JYMMCZ_NUM", title:"交易密码重置", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"JYMMXG_NUM", title:"交易密码修改", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"SBMMCZ_NUM", title:"医保密码重置", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"SBMMXG_NUM", title:"医保密码修改", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"GMGRSL_NUM", title:"零星申领", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"CARD_ISSUE_NUM", title:"卡发放", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"YGSYW_NUM", title:"临时挂失", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"GSYW_NUM", title:"挂失", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"JGSYW_NUM", title:"解挂失", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"BKYW_NUM", title:"补卡", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"HKYW_NUM", title:"换卡", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"ZXYW_NUM", title:"注销", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"HKZQB_NUM", title:"换卡转钱包", width:"80px", align:"center", rowspan:2, formatter:buildNum},
						{field:"TCQBG_NUM", title:"统筹区变更", width:"80px", align:"center", rowspan:2, formatter:buildNum}
					],[
					   	// 收入
						{field:"ZHXJCZ_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"ZHXJCZ_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"QBXJCZ_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"QBXJCZ_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"BHKYW_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:function(v, row, index){
							var num = Number(row.BKYW_NUM) + Number(row.HKYW_NUM);
							return buildNum(num);
						}},
						{field:"BHKYW_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"DAY_IN_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"DAY_IN_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						// 支出
						{field:"ZHCZCX_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"ZHCZCX_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"QBCZCX_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"QBCZCX_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"BHKCXYW_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"BHKCXYW_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"ZXFH_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"ZXFH_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"WDCK_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"WDCK_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"DAY_OUT_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"DAY_OUT_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt},
						{field:"DAY_AMT", align:"center", title:"本期发生额", sortable:true, width:"80px", formatter:function(v, row, index){
							var num = Number(row.DAY_IN_AMT) - Number(row.DAY_OUT_AMT);
							return buildAmt(num);
						}},
						{field:"PER_AMT", align:"center", title:"上期结余", sortable:true, width:"80px", formatter:function(v, r, i){
							if(r.isFooter){
								return;
							}
							return buildAmt(v);
						}},
						{field:"CUR_AMT", align:"center", title:"本期结余", sortable:true, width:"80px", formatter:function(v, r, i){
							if(r.isFooter){
								return;
							}
							return buildAmt(v);
						}},
						{field:"HJLQR_NUM", align:"center", title:"笔数", sortable:true, width:"80px", formatter:buildNum},
						{field:"HJLQR_AMT", align:"center", title:"金额", sortable:true, width:"80px", formatter:buildAmt}
					]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', "加载数据失败, " + data.errMsg, 'error');
				}
				
				updateFooter();
			},
			onBeforeLoad : function(params){
				if(!params["branchId"] || params["branchId"] == ""){
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
		var ZHXJCZ_NUM = 0;
		var ZHXJCZ_AMT = 0;
		var QBXJCZ_NUM = 0;
		var QBXJCZ_AMT = 0;
		var ZHXJCZCX_NUM = 0;
		var ZHXJCZCX_AMT = 0;
		var QBXJCZCX_NUM = 0;
		var QBXJCZCX_AMT = 0;
		var BHKCXYW_NUM = 0;
		var BHKCXYW_AMT = 0;
		var BHKYW_AMT = 0;
		var PER_AMT = 0;
		var DAY_IN_NUM = 0;
		var DAY_IN_AMT = 0;
		var DAY_OUT_NUM = 0;
		var DAY_OUT_AMT = 0;
		var CUR_AMT = 0;
		var XJCZ_NUM = 0;
		var XJCZ_AMT = 0;
		var GYTJ_NUM = 0;
		var GYTJ_AMT = 0;
		var CZCX_NUM = 0;
		var CZCX_AMT = 0;
		var ZXFH_NUM = 0;
		var ZXFH_AMT = 0;
		var WDCK_NUM = 0;
		var WDCK_AMT = 0;
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
		
		for(var i in selections){
			var row = selections[i];
			
			ZHXJCZ_NUM += Number(row.ZHXJCZ_NUM);
			ZHXJCZ_AMT += Number(row.ZHXJCZ_AMT);
			QBXJCZ_NUM += Number(row.QBXJCZ_NUM);
			QBXJCZ_AMT += Number(row.QBXJCZ_AMT);
			ZHXJCZCX_NUM += Number(row.ZHCZCX_NUM);
			ZHXJCZCX_AMT += Number(row.ZHCZCX_AMT);
			QBXJCZCX_NUM += Number(row.QBCZCX_NUM);
			QBXJCZCX_AMT += Number(row.QBCZCX_AMT);
			BHKCXYW_NUM += Number(row.BHKCXYW_NUM);
			BHKCXYW_AMT += Number(row.BHKCXYW_AMT);
			BHKYW_AMT += Number(row.BHKYW_AMT);
			PER_AMT += Number(row.PER_AMT);
			DAY_IN_NUM += Number(row.DAY_IN_NUM);
			DAY_IN_AMT += Number(row.DAY_IN_AMT);
			DAY_OUT_NUM += Number(row.DAY_OUT_NUM);
			DAY_OUT_AMT += Number(row.DAY_OUT_AMT);
			CUR_AMT += Number(row.CUR_AMT);
			XJCZ_NUM += Number(row.XJCZ_NUM);
			XJCZ_AMT += Number(row.XJCZ_AMT);
			GYTJ_NUM += Number(row.GYTJ_NUM);
			GYTJ_AMT += Number(row.GYTJ_AMT);
			CZCX_NUM += Number(row.CZCX_NUM);
			CZCX_AMT += Number(row.CZCX_AMT);
			ZXFH_NUM += Number(row.ZXFH_NUM);
			ZXFH_AMT += Number(row.ZXFH_AMT);
			WDCK_NUM += Number(row.WDCK_NUM);
			WDCK_AMT += Number(row.WDCK_AMT);
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
		}
		
		$("#dg").datagrid("reloadFooter", [{
			isFooter : true,
			BRCH_ID : BRCH_ID,
			BRCH_NAME : "共 " + selections.length + " 条记录",
			ZHXJCZ_NUM : ZHXJCZ_NUM,
			ZHXJCZ_AMT : ZHXJCZ_AMT,
			QBXJCZ_NUM : QBXJCZ_NUM,
			QBXJCZ_AMT : QBXJCZ_AMT,
			ZHCZCX_NUM : ZHXJCZCX_NUM,
			ZHCZCX_AMT : ZHXJCZCX_AMT,
			QBCZCX_NUM : QBXJCZCX_NUM,
			QBCZCX_AMT : QBXJCZCX_AMT,
			BHKCXYW_NUM : BHKCXYW_NUM,
			BHKCXYW_AMT : BHKCXYW_AMT,
			BHKYW_AMT : BHKYW_AMT,
			PER_AMT : PER_AMT,
			DAY_IN_NUM : DAY_IN_NUM,
			DAY_IN_AMT : DAY_IN_AMT,
			DAY_OUT_NUM : DAY_OUT_NUM,
			DAY_OUT_AMT : DAY_OUT_AMT,
			CUR_AMT : CUR_AMT,
			XJCZ_NUM : XJCZ_NUM,
			XJCZ_AMT : XJCZ_AMT,
			GYTJ_NUM : GYTJ_NUM,
			GYTJ_AMT : GYTJ_AMT,
			CZCX_NUM : CZCX_NUM,
			CZCX_AMT : CZCX_AMT,
			ZXFH_NUM : ZXFH_NUM,
			ZXFH_AMT : ZXFH_AMT,
			WDCK_NUM : WDCK_NUM,
			WDCK_AMT : WDCK_AMT,
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
			TCQBG_NUM : TCQBG_NUM
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
		
		if(!value || isNaN(value) || value == 0){
			value = 0;
			span = span.replace(/green/g, "black");
		}
		
		return span.replace(/value/g, formatAmt(parseFloat(value) / 100));
	}
	
	function buildNum(value){
		var span = "<span style='color:green'>value</span>";
		
		if(!value || value == ""){
			value = 0;
			span = span.replace(/green/g, "black");
		}
		
		return span.replace(/value/g, value);
	}
	
	function query(){
		var brchId = $("#branchId").combobox("getValue");
		var userId = $("#userId").combobox("getValue");
		var queryRpType = "0";
		if(!brchId || brchId == ""){
			$.messager.alert("提示", "请输入网点.", "warning");
			return;
		}
		
		if(userId == "erp2_erp2"){
			userId = "";
		}
		
		var param = {
				branchId:brchId,
				userId:userId,
				startDate:$("#startDate").val(),
				endDate:$("#endDate").val(),
				queryRpType:queryRpType
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
		var param = "branchId=" + $("#branchId").combobox("getValue")
				+ "&userId=" + $("#userId").combobox("getValue")
				+ "&startDate=" + $("#startDate").val()
				+ "&endDate=" + $("#endDate").val()
				+ "&queryRpType=0&rows=1000";
		
		var brchIds = "";
		var selections = $("#dg").datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				brchIds += selections[i].BRCH_ID + selections[i].USER_ID + selections[i].CLR_DATE + ",";
			}
		}
		if(brchIds){
			brchIds = brchIds.substring(0, brchIds.length - 1);
		}
		if(brchIds){
			param += "&checkIds=" + brchIds;
		}
		$("#frame_download").attr("src", "cuteDayManage/cuteDayAction!exportDayBals.action?" + param);
	}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>柜员营业报表</strong></span>进行查询，打印操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;background-color:rgb(245,245,245);">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput  easyui-validatebox" name="branchId"/></td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput  easyui-validatebox" name="userId"/></td>
						<td class="tableleft">清分起始日期：</td>
						<td class="tableright"><input id="startDate" type="text" name="clrDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">清分结束日期：</td>
						<td class="tableright">
							<input id="endDate" type="text" name="clrDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,minDate:'#F{$dp.$D(\'startDate\')}', maxDate:'%y-%M-%d'})"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft" colspan="8" style="padding-right: 2%">
						   <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						   <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-viewInfo'" href="javascript:void(0);" class="easyui-linkbutton" id="btn_view" name="subbutton" onclick="view()">预览</a>
						   <!-- <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="exportToExcel()">导出</a> -->
						</td>
					</tr>
				</table>
			</div>
			<table id="dg" title="柜员营业报表"></table>
	  </div>
	   <iframe id="frame_download" style="display: none"></iframe>
</body>
</html>