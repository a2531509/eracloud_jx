<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title>Insert title here</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function(){
		$.createDealCode("trName");
		
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
			url : "merchantManage/merchantManageAction!queryMerOffLineRefData.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageList : [100, 500, 1000, 2000, 5000, 10000, 20000],
			striped : true,
			border : false,
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			view:myview,
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			frozenColumns : [ [
				   			    {field:"", checkbox:true},
				   				{field:"ACPT_ID", title:"商户号", sortable:true, width : parseInt($(this).width() * 0.1)},
				   				{field:"MERCHANT_NAME", title:"商户名称", sortable:true, minWidth : parseInt($(this).width() * 0.04)},
				   				{field:"CARD_NO", title:"卡号", sortable:true, width : parseInt($(this).width() * 0.14)},
				   				{field:"ACC_KIND_NAME", title:"账户类型", sortable:true, minWidth : parseInt($(this).width() * 0.06), hidden:true}
				   			]],
				   			columns : [[
				   				{field:"ACC_BAL", title:"交易前金额", sortable:true, minWidth : parseInt($(this).width() * 0.06), formatter:function(v){
				   					return formatAmt(v/100);
				   				}},
				   				{field:"DEAL_AMT", title:"交易金额", sortable:true, minWidth : parseInt($(this).width() * 0.06), formatter:function(v){
				   					return formatAmt(v/100);
				   				}},
				   				{field:"DEAL_DATE", title:"交易时间", sortable:true, minWidth : parseInt($(this).width() * 0.12), formatter:function(v){
				   					if(v){
					   					return v.substring(0,4) + "-" + v.substring(4,6) + "-" + v.substring(6,8) + " " + v.substring(8,10) + ":" + v.substring(10,12) + ":" + v.substring(12,14);
				   					}
				   					return "";
				   				}},
				   				{field:"DEAL_CODE_NAME", title:"交易类型", sortable:true, minWidth : parseInt($(this).width() * 0.2)},
				   				{field:"END_ID", title:"终端编号", sortable:true, minWidth : parseInt($(this).width() * 0.06)},
				   				{field:"END_DEAL_NO", title:"终端交易流水", sortable:true, minWidth : parseInt($(this).width() * 0.04)},
				   				{field:"REFUSE_REASON", title:"拒付原因", sortable:true, minWidth : parseInt($(this).width() * 0.04), formatter : function(value, row){
				   					if(row.isFooter){
				   						return "";
				   					} else if(value == "00"){
				   						return "卡片发行方调整";
				   					} else if(value == "01"){
				   						return "TAC码错误";
				   					} else if(value == "02"){
				   						return "数据非法";
				   					} else if(value == "03"){
				   						return "数据重复";
				   					} else if(value == "04"){
				   						return "灰记录";
				   					} else if(value == "05"){
				   						return "金额不足";
				   					} else if(value == "06"){
				   						return "测试数据";
				   					} else if(value == "07"){
				   						return "交易时间不正确";
				   					} else if(value == "09"){
				   						return "拒付调整";
				   					} else if(value == "64"){
				   						return "异地卡消费数据";
				   					} else {
				   						return "其它【" + value + "】";
				   					}
				   				}}
				   			]],
			onLoadSuccess : function(data) {
				if (data.status == "1") {
					$.messager.alert('系统消息', data.errMsg, 'warning');
				}
				updateFooter();
			},
			onBeforeLoad : function(param){
				if(!param["queryType"] || param["queryType"] != "1"){
					return false;
				}
				
				return true;
			},
			onSelect : function(){
				updateFooter();
			},
			onUnselect : function(){
				updateFooter();
			},
			onSelectAll : function(){
				updateFooter();
			},
			onUnselectAll : function(){
				updateFooter();
			}
		});
		
		function updateFooter(){
			var selections = $("#dg").datagrid("getSelections");
			
			var dbAmt = 0;
			var num = 0;
			for(var i in selections){
				dbAmt += isNaN(selections[i].DEAL_AMT)?0:Number(selections[i].DEAL_AMT);
				num++;
			}
			
			$("#dg").datagrid("reloadFooter", [{isFooter:true, ACPT_ID:"统计：", MERCHANT_NAME:"共" + num + "笔", DEAL_AMT:dbAmt}]);
		}
		
		$.autoComplete({
			id:"merchantId",
			text:"merchant_id",
			value:"merchant_name",
			table:"base_merchant",
			keyColumn:"merchant_id",
			minLength:"1"
		},"merchantName");
		
		$.autoComplete({
			id:"merchantName",
			text:"merchant_name",
			value:"merchant_id",
			table:"base_merchant",
			keyColumn:"merchant_name",
			minLength:"1"
		},"merchantId");
		
		$.autoComplete({
			id:"termId",
			text:"end_id",
			value:"end_name",
			table:"base_tag_end",
			keyColumn:"end_id",
			minLength:"1"
		},"termName");
		
		$.autoComplete({
			id:"termName",
			text:"end_name",
			value:"end_id",
			table:"base_tag_end",
			keyColumn:"end_name",
			minLength:"1"
		},"termId");
	})
	
	function formatAmt(s, n) {
		if(isNaN(s)){
			return "";
		}
		if(isNaN(n) || n < 0 || n >= 20){
			n = 2;
		}
		
		s = parseFloat((s + "").replace(/[^\d\.-]/g, ""));
		
		if(isNaN(s)){
			s = 0;
		}
		
		s = s.toFixed(n);

		var l = (s + "").split(".")[0].split("").reverse();
		
		var r = s.split(".")[1];
		
		var t = "";
		
		for(i = 0; i < l.length; i ++ ) {  
			t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length && l[i + 1] != "-" ? "," : "");
		}
		
		return t.split("").reverse().join("") + "." + r; 
	}
	
	function query(){
		var clrStartDate = $("#clrStartDate").val();
		var clrEndDate = $("#clrEndDate").val();
		
		if(clrStartDate == ""){
			$.messager.alert("消息提示", "清分起始日期不能为空", "warning");
			return;
		}
		
		if(clrEndDate == ""){
			$.messager.alert("消息提示", "清分结束日期不能为空", "warning");
			return;
		}
		
		$("#dg").datagrid("load", {
			queryType:"1",
			merchantId:$("#merchantId").val(),
			merchantName:$("#merchantName").val(),
			tagId:$("#termId").val(),
			tagName:$("#termName").val(),
			dealBatchNo:$("#batchNo").val(),
			endDealNo:$("#termSerNo").val(),
			cardNo:$("#cardNo").val(),
			dealNo:$("#centerSerNo").val(),
			clrStartDateStr:clrStartDate,
			clrEndDateStr:clrEndDate,
			trStartDate:$("#trStartDate").val(),
			trEndDate:$("#trEndDate").val(),
			trName:$("#trName").combobox("getValue")
		});
	}
	
	function exportDetail(){
		var dealNos = "";
		var selections = $("#dg").datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				dealNos += selections[i].DEAL_NO + "|";
			}
			if(dealNos){
				dealNos = dealNos.substring(0, dealNos.length - 1);
			}
		}
		
		var params = {
			merchantId:$("#merchantId").val(),
			tagId:$("#termId").val(),
			dealBatchNo:$("#batchNo").val(),
			endDealNo:$("#termSerNo").val(),
			cardNo:$("#cardNo").val(),
			dealNo:$("#centerSerNo").val(),
			trStartDate:$("#trStartDate").val(),
			trEndDate:$("#trEndDate").val(),
			trName:$("#trName").combobox("getValue"),
			rows:65535
		};
		var paramsStr = "";
		for(var i in params){
			paramsStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({text:"正在进行导出,请稍候..."});
		$('#downloadcsv').attr('src',"merchantManage/merchantManageAction!exportMerOffLineRefData.action?expid=" + dealNos + paramsStr);
		startCycle();
	}
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportMerOffLineRefData",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">提示</span> <span>在此可以查看<span
				class="label-info"><strong>商户交易拒付数据</strong></span>
			</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hiddsen;">
		<div id="tb" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">商户号：</td>
					<td class="tableright"><input id="merchantId" class="textinput" /></td>
					<td class="tableleft">商户名称：</td>
					<td class="tableright"><input id="merchantName" class="textinput" /></td>
					<td class="tableleft">终端号：</td>
					<td class="tableright"><input id="termId" class="textinput" /></td>
					<td class="tableleft">终端名称：</td>
					<td class="tableright"><input id="termName" class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft">批次号：</td>
					<td class="tableright"><input id="batchNo" class="textinput" /></td>
					<td class="tableleft">终端流水号：</td>
					<td class="tableright"><input id="termSerNo" class="textinput" /></td>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input id="cardNo" class="textinput" /></td>
					<td class="tableleft">中心流水号：</td>
					<td class="tableright"><input id="centerSerNo" class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft">交易起始时间：</td>
					<td class="tableright"><input id="trStartDate"
						class="textinput Wdate"
						onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" /></td>
					<td class="tableleft">交易结束时间：</td>
					<td class="tableright"><input id="trEndDate"
						class="textinput Wdate"
						onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" /></td>
					<td class="tableleft">交易名称：</td>
					<td class="tableright"><input id="trName" class="textinput" /></td>
					<td class="tableright" colspan="6">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a>
						&nbsp;<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export" onclick="exportDetail()">导出</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="商户交易拒付数据" style="width: 100%"></table>
	</div>
	<iframe id="downloadcsv" style="display: none;"></iframe>
</body>
</html>