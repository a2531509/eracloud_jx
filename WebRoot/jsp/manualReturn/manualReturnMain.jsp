<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%@ include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $manualReturnDataGrid;
	$(function(){
		$.autoComplete({
			id: "merchantId",
			text: "merchant_id",
			value: "merchant_name",
			table: "base_merchant",
			keyColumn: "merchant_id",
			minLength: "1"
		}, "merchantName");
		$.autoComplete({
			id: "merchantName",
			text: "merchant_name",
			value: "merchant_id",
			table: "base_merchant",
			keyColumn: "merchant_name",
			minLength: "1"
		}, "merchantId");
		$("#state").combobox({
			textField:"text",
			valueField:"value",
			panelHeight:"auto",
			editable:false,
			data:[
				{text:"请选择", value:""},
				{text:"待处理", value:"0"},
				{text:"已处理", value:"1"},
				{text:"已删除", value:"2"},
			]
		});
		createSysCode({
			id: "cardType",
			codeType: "CARD_TYPE",
			codeValue: "<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			isShowDefaultOption: true
		});
		$manualReturnDataGrid = createDataGrid({
			id: "manualReturnDataGrid",
			toolbar: "#tb",
			singleSelect: true,
			scrollbarSize:0,
			fitColumns: true,
			url: "manualReturn/manualReturnAction!query.action",
			pageSize: 20,
			onBeforeLoad:  function(param){
				if (typeof(param["queryType"]) == "undefined" || param["queryType"] != 0) {
					return false;
				}
			},
			columns: [[
				{field: "ID", checkbox: true},
				{field: "TRAD_ACPT_ID", title: "商户编号", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)},
				{field: "MERCHANT_NAME", title: "商户名称", align: "center", sortable: true,width:parseInt($(this).width() * 0.1)},
				{field: "TRAD_END_ID", title: "终端号", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)},
				{field: "TRAD_BATCH_NO", title: "批次号", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)},
				{field: "TRAD_END_DEAL_NO", title: "终端交易流水号", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)},
				{field: "CARD_TYPE", title: "卡类型", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)},
				{field: "CARD_NO", title: "卡号", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)},
				{field: "TRAD_STATE", title: "处理状态", align: "center", sortable: true, formatter:function(v){
					if(v == 0){
						return "<span style='color:orange'>待处理</span>";
					} else if(v==1){
						return "<span style='color:green'>已处理</span>";
					} else if(v==2){
						return "<span style='color:red'>已删除</span>";
					}
					return v;
				}},
				{field: "TRAD_AMT", title: "交易金额", align: "center", sortable: true,width:parseInt($(this).width() * 0.08), 
					formatter:function(value,row,index){
						return Number(value).div100();
					}
				},
				{field: "OLD_DEAL_NO", title: "原交易流水号", align: "center", sortable: true,width:parseInt($(this).width() * 0.08)}
			]]
		});
	});

	function query() {
		if ($("#returnBeginDate").val() != "" && $("#returnEndDate").val() != "") {
			var begin = new Date($("#returnBeginDate").val().replace(/-/g,"/"));
			var end = new Date($("#returnEndDate").val().replace(/-/g,"/"));
			if (begin - end > 0) {
				$.messager.alert("系统消息", "退货登记起始日期不能大于退货登记结束日期！", "error");
				return;
			}
		}
		$manualReturnDataGrid.datagrid("load", {
			"queryType": "0",
			"merchantId": $("#merchantId").val(),
			"merchantName": $("#merchantName").val(),
			"cardType": $("#cardType").combobox("getValue"),
			"cardNo": $("#cardNo").val(),
			"returnBeginDate": $("#returnBeginDate").val(),
			"returnEndDate": $("#returnEndDate").val(),
			state:$("#state").combobox("getValue")
		});
	}

	function add() {
		$.modalDialog({
			title: "新增手动退货",
			iconCls: "icon-adds",
			width: 600,
			height: 200,
			shadow: false,
			closable: true,
			maximizable: false,
			href: "jsp/manualReturn/manualReturnAdd.jsp",
			buttons: [{
				text: "保存",
				iconCls: "icon-ok",
				handler: function() {
					saveManualReturn();
				}
			},{
				text: "取消",
				iconCls: "icon-cancel",
				handler: function() {
					$.modalDialog.handler.dialog("destroy");
					$.modalDialog.handler = undefined;
				}
			}]
		});
	}

	function execute() {
		var rows = $manualReturnDataGrid.datagrid("getChecked");
		if (rows.length != 1) {
			$.messager.alert("系统消息", "请选择一条要进行处理的记录！", "info");
			return;
		}
		$.messager.confirm("系统消息", "确定要对当前选择记录进行处理？", function(e) {
			if (e) {
				$.post("manualReturn/manualReturnAction!saveManaulReturnExecute.action", {
					"id": rows[0].ID
				}, function(data, status) {
					if (status == "success") {
						if (dealNull(data.errMsg) != "") {
							$.messager.progress("close");
							$.messager.alert("系统消息", data.errMsg, "error");
						} else {
							$.messager.progress("close");
							$.messager.alert("系统消息", "处理成功！", "info", function() {
								$manualReturnDataGrid.datagrid("reload");
							});
						}
					} else {
						$.messager.progress("close");
						$.messager.alert("系统消息", "手工退货处理操作发生错误！请重试！", "error");
					}
				}, "json");
			}
		});
	}
	
	function deleteItem(){
		var rows = $manualReturnDataGrid.datagrid("getChecked");
		if (rows.length != 1) {
			$.messager.alert("系统消息", "请选择一条记录！", "warning");
			return;
		}
		$.messager.confirm("系统消息", "确定删除当前选择记录？", function(e) {
			if (e) {
				$.post("manualReturn/manualReturnAction!deleteManaulReturnInfo.action", {
					"id": rows[0].ID
				}, function(data, status) {
					if (status == "success") {
						if (dealNull(data.errMsg) != "") {
							$.messager.progress("close");
							$.messager.alert("系统消息", data.errMsg, "error");
						} else {
							$.messager.progress("close");
							$.messager.alert("系统消息", "删除成功！", "info", function() {
								$manualReturnDataGrid.datagrid("reload");
							});
						}
					} else {
						$.messager.progress("close");
						$.messager.alert("系统消息", "操作失败！请重试！", "error");
					}
				}, "json");
			}
		});
	}
</script>
<n:initpage title="手工退货进行操作！">
	<n:center>
		<div id="tb" style="padding: 2px 0px">
			<table style="width: 100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width: 8%">商户编号：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="merchantId" class="textinput" /></td>
					<td class="tableleft" style="width: 8%">商户名称：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="merchantName" class="textinput" /></td>
					<td class="tableleft" style="width: 8%">卡类型：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="cardType" class="textinput" /></td>
					<td class="tableleft" style="width: 8%">卡号：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="cardNo" class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft" style="width: 8%">退货登记<br/>起始日期：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="returnBeginDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})" /></td>
					<td class="tableleft" style="width: 8%">退货登记<br/>结束日期：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="returnEndDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})" /></td>
					<td class="tableleft" style="width: 8%">状态：</td>
					<td class="tableright" style="width: 17%"><input type="text" id="state" class="textinput" /></td>
					<td colspan="2" class="tableright" style="padding-left: 20px">
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-search'" onclick="query();">查询</a>
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-adds'" onclick="add();">新增</a>
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-save'" onclick="execute();">处理</a>
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-remove'" onclick="deleteItem();">删除</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="manualReturnDataGrid" title="手工退货信息"></table>
	</n:center>
</n:initpage>