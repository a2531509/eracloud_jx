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
	var isEdit = false;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
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
		
		var now = new Date();
		$("#startDate").val(formatDate(now));
		$("#endDate").val(formatDate(now));
		
		$("#state").combobox({
			labelField : "value",
			textField : "name",
			panelHeight : "auto",
			editable : false,
			data : [
				{value:"", name:"请选择"},
				{value:"0", name:"待确认"},
				{value:"1", name:"审核不通过"},
				{value:"2", name:"已确认"},
				{value:"3", name:"充值失败"},
				{value:"4", name:"部分充值"},
				{value:"5", name:"已充值"}
			]
		});
		
		$("#dg").datagrid({
			url : "payCarreForm/payCarreFormAction!queryBatchInfos.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageList : [100, 200, 300, 400, 500],
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
				{field:"BATCH_NUMBER", title:"批次号", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"PROVIDE_YEAR", title:"年份", sortable:true, width : parseInt($(this).width() * 0.04)},
				{field:"PROVIDE_MONTH", title:"月份", sortable:true, width : parseInt($(this).width() * 0.04)},
				/* {field:"PROVIDE_DAY", title:"日", sortable:true, width : parseInt($(this).width() * 0.04)}, */
				{field:"EMP_NAME", title:"单位名称", sortable:true, width : parseInt($(this).width() * 0.2)},
				{field:"NUM", title:"人数", sortable:true, width : parseInt($(this).width() * 0.04)},
				{field:"AMT", title:"发放金额", sortable:true, width : parseInt($(this).width() * 0.06), formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"RECHARGE_NUM", title:"已充值人数", sortable:true, minWidth : parseInt($(this).width() * 0.04)},
				{field:"RECHARGE_AMT", title:"已充值金额", sortable:true, minWidth : parseInt($(this).width() * 0.06), formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"FAIL_NUM", title:"充值失败人数", sortable:true, minWidth : parseInt($(this).width() * 0.04)},
				{field:"STATE", title:"状态", sortable:true, width : parseInt($(this).width() * 0.06), formatter:function(value){
					if (value == "0"){
						return "<span style='color:orange'>待确认</span>";
					} else if (value == "1"){
						return "<span style='color:red'>审核不通过</span>";
					} else if (value == "2"){
						return "<span style='color:black'>已确认</span>";
					} else if (value == "3"){
						return "<span style='color:red'>充值失败</span>";
					} else if (value == "4"){
						return "<span style='color:green'>部分充值</span>";
					} else if (value == "5"){
						return "<span style='color:green'>已充值</span>";
					}
				}}
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'warning');
				}
				updateFooter();
			},
			onBeforeLoad : function(params){
				if(!params || !params.query){
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
		
		var NUM = 0;
		var AMT = 0;
		var RECHARGE_NUM = 0;
		var RECHARGE_AMT = 0;
		var FAIL_NUM = 0;
		
		for(var i in selections){
			var row = selections[i];
			
			NUM += isNaN(Number(row.NUM))?0:Number(row.NUM);// TODO
			AMT += isNaN(Number(row.AMT))?0:Number(row.AMT);
			RECHARGE_NUM += isNaN(Number(row.RECHARGE_NUM))?0:Number(row.RECHARGE_NUM);
			RECHARGE_AMT += isNaN(Number(row.RECHARGE_AMT))?0:Number(row.RECHARGE_AMT);
			FAIL_NUM += isNaN(Number(row.FAIL_NUM))?0:Number(row.FAIL_NUM);
		}
		
		$("#dg").datagrid("reloadFooter", [{
			isFooter : true,
			BATCH_NUMBER : "统计：",
			NUM : NUM,
			AMT : AMT,
			RECHARGE_NUM : RECHARGE_NUM,
			RECHARGE_AMT : RECHARGE_AMT,
			FAIL_NUM : FAIL_NUM
		}]);
	}
	
	function formatDate(date) {
		var format = "yyyy-MM";
		var month = date.getMonth() + 1;
		return format.replace("yyyy", date.getFullYear()).replace("MM", month < 10?"0" + month:month);
	}
	
	function openModalDialog(title, icon, url, saveCallback) {
		$.modalDialog({
			title : title,
			iconCls : icon,
			maximized : true,
			shadow : false,
			closable : false,
			maximizable : false,
			href : url,
			onDestroy : function() {
				if(isEdit){
					query();
				}
			},
			buttons : [ {
				text : '返回',
				iconCls : 'icon-cancel',
				handler : function() {
					$.modalDialog.handler.dialog('destroy');
					$.modalDialog.handler = undefined;
				}
			} ]
		});
	}
	
	function query(){
		$("#dg").datagrid("load", {
			query:true,
			"payCarTotal.batchNumber":$("#batchNumber").val(),
			"payCarTotal.empName":$("#empName").val(),
			"payCarTotal.state":$("#state").combobox("getValue"),
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val()
		});
	}
	
	function viewDetail(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length != 1){
			$.messager.alert("消息提示", "请选择一条记录", "info");
			return;
		}
		
		openModalDialog("车改批量充值明细", "icon-bike", 
			"payCarreForm/payCarreFormAction!toBatchDetailIndex.action" 
			+ "?payCarTotal.batchNumber=" + selection[0].BATCH_NUMBER);
	}
	
	function identify(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length < 1){
			$.messager.alert("消息提示", "请选择充值数据", "info");
			return;
		}
		
		var reqData = "";
		for(var i in selection){
			reqData += selection[i].BATCH_NUMBER + ",";
			
			if(selection[i].STATE != "0"){
				$.messager.alert("消息提示", "批量充值数据[" + selection[i].BATCH_NUMBER + "]不是[待确认]状态", "info");
				return;
			}
		}
		
		
		$.messager.confirm("确认消息", "确认审核?", function(r){
			if(r){
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				$.post("payCarreForm/payCarreFormAction!batchIdentify.action", {
						reqData:reqData
					}, function(data){
					$.messager.progress('close');
					
					var msg;
					var level = "info";
					if(data.status == "1"){//fail
						msg = data.errMsg;
						level = "error";
					} else if(data.errMsg){
						msg = "操作完成，有失败记录：<br>" + data.errMsg;
					} else {
						msg = "操作成功";
					}
					
					$.messager.alert("消息提示", msg, level, function(){
						query();
					});
				}, "json");
			}
		});
	}
	
	function recharge(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length < 1){
			$.messager.alert("消息提示", "请选择充值数据", "info");
			return;
		}
		
		var reqData = "";
		for(var i in selection){
			reqData += selection[i].BATCH_NUMBER + ",";
			
			if(selection[i].STATE < 2 || selection[i].STATE > 4){
				$.messager.alert("消息提示", "批量充值数据[" + selection[i].BATCH_NUMBER + "]不是[已确认, 充值失败, 部分充值]状态", "info");
				return;
			}
		}
		
		$.messager.confirm("确认消息", "确认充值?", function(r){
			if(r){
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				$.post("payCarreForm/payCarreFormAction!batchRecharge.action", {
						reqData:reqData
					}, function(data){
					$.messager.progress('close');
					
					var msg;
					var level = "info";
					if(data.status == "1"){//fail
						msg = data.errMsg.replace(/\./g,"<br>");
						level = "error";
					} else if (data.errMsg){
						msg = "操作完成，有失败的记录：<br>" + data.errMsg;
						
						//if(data.failList != null){
						//	msg += ", " + data.errMsg;
						//	
						//	var failList = eval(data.failList);
						//	
						//	for(var i in failList){
						//		msg += "<br>[身份证号:" + failList[i].id.certNo + ", 失败原因:" + failList[i].failureReason + "]";
						//	}
						//}
					} else {
						msg = "操作成功";
					}
					
					$.messager.alert("消息提示", msg, level, function(){
						query();
					});
				}, "json");
			}
		});
	}
	
	function invalid(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length < 1){
			$.messager.alert("消息提示", "请选择充值数据", "info");
			return;
		}
		
		var reqData = "";
		for(var i in selection){
			reqData += selection[i].BATCH_NUMBER + ",";
			
			if(selection[i].STATE != "0"){
				$.messager.alert("消息提示", "批量充值数据[" + selection[i].BATCH_NUMBER + "]不是[待确认]状态", "info");
				return;
			}
		}
		
		
		$.messager.confirm("确认消息", "确认审核?", function(r){
			if(r){
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				$.post("payCarreForm/payCarreFormAction!invalidPayCarreForm.action", {
						reqData:reqData
					}, function(data){
					parent.$.messager.progress('close');
					
					var msg;
					var level = "info";
					if(data.status == "1"){//fail
						msg = data.errMsg;
						level = "error";
					} else {
						msg = "操作陈功";
					}
					
					$.messager.alert("消息提示", msg, level, function(){
						query();
					});
				}, "json");
			}
		});
	}
	
	function autoCom(){
		$("#empName").autocomplete({
			position:{my:"left top",at:"left bottom",of:"#empName"},
			source:function(request,response){
				$.post("dataAcount/dataAcountAction!toSearchInput.action",{"corpName":$("#empName").val(),"queryType":"0"},function(data){
					response($.map(data,function(item){return {label:item.value,value:item.text};}));
				});
			},
			select:function(event,ui){
				$("#empName").val(ui.item.label);
				return false;
			},
			focus:function(event,ui){
				return false;
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
				class="label-info"><strong>车改批量充值信息</strong></span>以及<span
				class="label-info"><strong>查看明细/审核/充值</strong></span>等操作
			</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hiddsen;">
		<div id="tb" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft" style="width:13%">批次号：</td>
					<td class="tableright" style="width:20%"><input id="batchNumber" class="textinput" /></td>
					<td class="tableleft" style="width:13%">单位名称：</td>
					<td class="tableright" style="width:20%"><input id="empName" class="textinput" onchange="autoCom();" onkeyup="autoCom();" onkeydown="autoCom();" /></td>
					<td class="tableleft" style="width:13%">状态：</td>
					<td class="tableright" style="width:20%"><input id="state" class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft" style="width:13%">起始时间：</td>
					<td class="tableright" style="width:20%"><input id="startDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM',qsEnabled:false,maxDate:'%y-%M-%d'})" value=""/></td>
					<td class="tableleft" style="width:13%">结束时间：</td>
					<td class="tableright" style="width:20%"><input id="endDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM',qsEnabled:false,maxDate:'%y-%M-%d',minDate:'#F{$dp.$D(\'startDate\')}'})" value="" /></td>
					<td class="tableright" colspan="2" style="width:33%">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a>
						<shiro:hasPermission name="viewPayCarreFormList">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" onclick="viewDetail()"><!--  查看明细-->预览</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="identifyPayCarreForm">
							<a href="javascript:void(0);" class="easyui-menubutton" data-options="menu:'#mm1'" iconCls="icon-checkInfo" plain="false" onclick="javascript:void(0);">审核</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="rechargePayCarreForm">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-dzqbcz" onclick="recharge()">批量充值</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="车改批量充值信息" style="width: 100%"></table>
		<div id="mm1" style="width: 50px; display: none;">
			<div data-options="iconCls:'icon-checkInfo'" onclick="identify()">审核确认</div>
			<div class="menu-sep"></div>
			<div data-options="iconCls:'icon_cancel_01'" onclick="invalid()">审核不通过</div>
		</div>
	</div>
</body>
</html>