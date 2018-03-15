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
<style type="text/css">
	.disabled{
		background: rgb(235, 235, 228);
	}
</style>
<script type="text/javascript">
	$(function(){
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
		
		$("#stlFlag").combobox({
			editable:false,
		    panelHeight:'auto',
		    valueField:'value',   
		    textField:'text',
		    data:[{text:"请选择", value:""},
		          {text:"已结算", value:"0"},
		          {text:"未结算", value:"1"}]
		});
		
		createSysCode("cardType",{codeType:"CARD_TYPE",isShowDefaultOption:true});
		createSysCode("accKind",{codeType:"ACC_KIND",isShowDefaultOption:true});

		$("#dealCode").combobox({ 
		    url:"statistical/statisticalAnalysisAction!getAllDealCodes.action",
		    editable:false,
		    cache: false,
		    panelWidth:300,
		    groupField:"GCODE",
		    width:174,
		    valueField:'CODE_VALUE',   
		    textField:'CODE_NAME',
		    groupFormatter:function(value){
		    	return "<span style=\"color:red;font-weight:600;font-style:italic;\">" + value + "</span>";
		    },
		    loadFilter : function(data){
		    	var reg = /40[21]0\d{4}/g;
		    	var data2 = new Array();
		    	for(var i in data){
		    		if(reg.test(data[i]["CODE_VALUE"])){
		    			data2.unshift(data[i]);
		    		}
		    	}
		    	
		    	data2.unshift({"CODE_NAME":"请选择","CODE_VALUE":""});
		    	
		    	return data2;
		    }
		});
		
		$("#dg").datagrid({
			url:"merchantSettle/merchantSettleAction!queryMerchantClrSumData.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageList : [100, 500, 1000, 2000, 5000],
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
			columns : [ [
				{field:"", checkbox:true},
				{field:"CLR_NO", title:"清分编号", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"MERCHANT_ID", title:"商户编号", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"MERCHANT_NAME", title:"商户名称", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"DEAL_CODE_NAME", title:"交易名称", sortable:true, width : parseInt($(this).width() * 0.08)},
				{field:"CARD_TYPE_NAME", title:"卡类型", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"ACC_KIND_NAME", title:"账户种类", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"DEAL_NUM", title:"笔数", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"DEAL_AMT", title:"金额", sortable:true, width : parseInt($(this).width() * 0.1), formatter:function(value){
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"CLR_DATE", title:"清分日期", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"STL_FLAG", title:"结算状态", sortable:true, width : parseInt($(this).width() * 0.06), formatter : function(value, row){
					if(row.isFooter){
						return "";
					} else if(value == "0"){
						return "<span style='color:green'>已结算</span>";
					} else {
						return "<span style='color:orange'>未结算</span>";
					}
				}},
				{field:"STL_DATE", title:"结算日期", sortable:true, width : parseInt($(this).width() * 0.1)}
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'warning');
				}
				updateFooter();
			},
			onBeforeLoad : function(params){
				if(!params["query"]){
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
	})
		
	function updateFooter(){
			var selections = $("#dg").datagrid("getSelections");
			
			var dbAmt = 0;
			var num = 0;
			for(var i in selections){
				dbAmt += isNaN(selections[i].DEAL_AMT)?0:Number(selections[i].DEAL_AMT);
				num += isNaN(selections[i].DEAL_NUM)?0:Number(selections[i].DEAL_NUM);
			}
			
			$("#dg").datagrid("reloadFooter", [{isFooter:true, CLR_NO:"统计：", DEAL_NUM:"共" + num + "笔", DEAL_AMT:dbAmt}]);
		}
	
	function formatAmt(s){
		n = 2; //小数
		s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n) + "";  
		var l = s.split(".")[0].split("").reverse(),  
		r = s.split(".")[1];  
		t = "";  
		for(i = 0; i < l.length; i ++ ){  
			t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : "");  
		}
		return t.split("").reverse().join("") + "." + r; 
	}
	
	function autoComMer(){
 		if($("#merchantId").val() == ""){
    		$("#merchantName").val("");
    	}
      	$("#merchantId").autocomplete({
     		position: {my:"left top",at:"left bottom",of:"#merchantId"},
  			source: function(request,response){
         		$.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
              		response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
             	},'json');
         	},
         	select: function(event,ui){
            	$('#merchantId').val(ui.item.label);
             	$('#merchantName').val(ui.item.value);
               	return false;
         	},
         	focus:function(event,ui){
             	return false;
			}
       	}); 
  	}
  	
	function autoComByNameMer(){
      	if($("#merchantName").val() == ""){
          	$("#merchantId").val("");
      	}
      	$("#merchantName").autocomplete({
          	source:function(request,response){
           		$.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
             	  	response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
           		},'json');
           	},
           	select: function(event,ui){
              	$('#merchantId').val(ui.item.value);
               	$('#merchantName').val(ui.item.label);
               	return false;
          	},
           	focus: function(event,ui){
             	return false;
           	}
       	}); 
   	}
	
	function query(){
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		
		if(!startDate || startDate == ""){
			$.messager.alert("提示", "清分开始日期不能为空.", "warning");
			return;
		}
		
		if(!endDate || endDate == ""){
			$.messager.alert("提示", "清分结束日期不能为空.", "warning");
			return;
		}
		
		$("#dg").datagrid("load", {
			query:true,
			merchantId:$("#merchantId").val(),
			merchantName:$("#merchantName").val(),
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val(),
			dealCode:$("#dealCode").combobox("getValue"),
			cardType:$("#cardType").combobox("getValue"),
			accKind:$("#accKind").combobox("getValue"),
			stlState:$("#stlFlag").combobox("getValue")
		});
	}
	
	function exportMerchantClrSum(){
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		
		if(!startDate || startDate == ""){
			$.messager.alert("提示", "清分开始日期不能为空.", "warning");
			return;
		}
		
		if(!endDate || endDate == ""){
			$.messager.alert("提示", "清分结束日期不能为空.", "warning");
			return;
		}
		
		var params = {
			query:true,
			merchantId:$("#merchantId").val(),
			merchantName:$("#merchantName").val(),
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val(),
			dealCode:$("#dealCode").combobox("getValue"),
			cardType:$("#cardType").combobox("getValue"),
			accKind:$("#accKind").combobox("getValue"),
			stlState:$("#stlFlag").combobox("getValue")
		};
		
		$.messager.progress({
			title:"提示",
			text:"数据处理中, 请稍候..."
		});
	    
		$.post("merchantSettle/merchantSettleAction!validExportMerchantClrSumData.action", params, function(data){
			$.messager.progress("close");
			if(!data || !data.status || data.status == "1" || !data.expid){
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$('#downloadcsv').attr('src',"merchantSettle/merchantSettleAction!exportMerchantClrSumData.action?expid=" + data.expid);
			}
		}, "json");
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">提示</span>
			<span>在此可以查询
				<span class="label-info"><strong>商户清分汇总</strong></span>数据
			</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true"
		style="border-left: none; border-bottom: none;border-right: none; height: auto; overflow: hiddsen;">
		<div id="tb" style="padding: 2px 0" class="toolbar">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">商户编号：</td>
					<td class="tableright">
						<input id="merchantId" class="textinput" onclick="autoComMer()"/>
					</td>
					<td class="tableleft">商户名称：</td>
					<td class="tableright">
						<input id="merchantName" class="textinput" onclick="autoComByNameMer()" />
					</td>
					<td class="tableleft">清分起始日期：</td>
					<td class="tableright">
						<input id="startDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" />
					</td>
					<td class="tableleft">清分结束日期：</td>
					<td class="tableright">
						<input id="endDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,minDate:'#F{$dp.$D(\'startDate\')}',maxDate:'%y-%M-%d'})"/>
					</td>
				</tr>
				<tr>
					<td class="tableleft">交易名称：</td>
					<td class="tableright">
						<input id="dealCode" class="textinput" />
					</td>
					<td class="tableleft">卡类型：</td>
					<td class="tableright">
						<input id="cardType" class="textinput" />
					</td>
					<td class="tableleft">账户种类：</td>
					<td class="tableright">
						<input id="accKind" class="textinput" />
					</td>
					<td class="tableleft">结算状态：</td>
					<td class="tableright">
						<input id="stlFlag" class="textinput" />
					</td>
				</tr>
			</table>
			<div id="menu_bar" style="padding: 2px 20px; border: 1px dotted rgb(149, 184, 231); border-top: none;">
				<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a>
				<shiro:hasPermission name="exportMerchantClrSum">
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export" onclick="exportMerchantClrSum()">导出</a>
				</shiro:hasPermission>
			</div>
		</div>
		<table id="dg" title="商户清分汇总数据" style="width: 100%"></table>
	</div>
	<iframe id="downloadcsv" style="display: none;"></iframe>
</body>
</html>