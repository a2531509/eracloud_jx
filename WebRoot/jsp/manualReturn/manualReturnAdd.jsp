<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<script type="text/javascript">
	$(function(){
		createSysCode({
			id: "add_cardType",
			codeType: "CARD_TYPE",
			codeValue: "<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			isShowDefaultOption: true
		});
	});

	function saveManualReturn() {
		if ($("#add_cardType").combobox("getValue") == "") {
			$.messager.alert("系统消息", "请选择卡类型！", "info", function() {
				$("#add_cardType").combobox("showPanel");
			});
			return;
		}
		if ($("#add_cardNo").val() == "") {
			$.messager.alert("系统消息", "请输入卡号！", "info", function() {
				$("#add_cardNo").focus();
			});
			return;
		}
		if ($("#add_oldDealNo").val() == "") {
			$.messager.alert("系统消息", "请输入原交易流水！", "info", function() {
				$("#add_oldDealNo").focus();
			});
			return;
		}
		if ($("#add_oldDealClearingDate").val() == "") {
			$.messager.alert("系统消息", "请选择原交易清分日期！", "info", function() {
				$("#add_oldDealClearingDate").focus();
			});
			return;
		}
		if ($("#add_returnAmount").val() == "") {
			$.messager.alert("系统消息", "请输入退货金额！", "info", function() {
				$("#add_returnAmount").focus();
			});
			return;
		}
		if (!/^\d+(\.?\d{1,2})?$/g.test($("#add_returnAmount").val())) {
			$.messager.alert("系统消息", "请输入正确的金额格式！", "info", function() {
				$("#add_returnAmount").focus();
			});
			return;
		}
		if (parseFloat($("#add_returnAmount").val()) <= 0) {
			$.messager.alert("系统消息", "退货金额不能小于等于0元！", "info", function() {
				$("#add_returnAmount").focus();
			});
			return;
		}
		var returnAmount;
		if ($("#add_returnAmount").val().indexOf(".") == -1) {
			returnAmount = $("#add_returnAmount").val() + "00";
		} else {
			if ($("#add_returnAmount").val().substring($("#add_returnAmount").val().indexOf(".") + 1).length == 1){
				returnAmount = $("#add_returnAmount").val().replace(".", "") + "0";
			} else {
				returnAmount = $("#add_returnAmount").val().replace(".", "");
			}
		}
		$.post("manualReturn/manualReturnAction!saveManualReturn.action", {
			"cardType": $("#add_cardType").combobox("getValue"),
			"cardNo": $("#add_cardNo").val(),
			"oldDealNo": $("#add_oldDealNo").val(),
			"oldDealClearingDate": $("#add_oldDealClearingDate").val(),
			"returnAmount": returnAmount
		}, function(data, status) {
			$.messager.progress("close");
			if (status == "success") {
				if (dealNull(data.errMsg) != "") {
					$.messager.alert("系统消息", data.errMsg, "error");
				} else {
					$.messager.alert("系统消息", "操作成功！", "info", function() {
						$manualReturnDataGrid.datagrid("reload");
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					});
				}
			} else {
				$.messager.alert("系统消息", "新增手工退货发生错误！请重试！", "error");
			}
		}, "json");
	}
</script>
<div class="easyui-layout" data-options="fit: true, border: false">
	<div data-options="region: 'center', border: false" style="overflow: hidden; padding: 0px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<table class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft" style="width: 15%">卡类型：</td>
					<td class="tableright" style="width: 35%"><input id="add_cardType" class="textinput" type="text" /></td>
					<td class="tableleft" style="width: 15%">卡号：</td>
					<td class="tableright" style="width: 35%"><input id="add_cardNo" class="textinput" type="text" /></td>
				</tr>
				<tr>
					<td class="tableleft" style="width: 15%">原交易流水：</td>
					<td class="tableright" style="width: 35%"><input id="add_oldDealNo" class="textinput" type="text" /></td>
					<td class="tableleft" style="width: 15%">原交易清分日期：</td>
					<td class="tableright" style="width: 35%"><input id="add_oldDealClearingDate" class="Wdate textinput" type="text" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})" /></td>
				</tr>
				<tr>
					<td class="tableleft" style="width: 15%">退货金额：</td>
					<td colspan="3" class="tableright" style="width: 85%"><input id="add_returnAmount" class="textinput" type="text" /></td>
				</tr>
			</table>
		</form>
	</div>
</div>