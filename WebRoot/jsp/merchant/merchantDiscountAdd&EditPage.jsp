<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<style>
#address2 {
	width: 100%;
}
</style>
<script type="text/javascript">
	var model = "${model}";

	var submitUrl = "";

	var merchantId = "";

	$(function() {
		if ($("#discountType2").val() != "3") {
			$("#discountTxt3").hide();
		} else {
			$("#discountTxt2").hide();
		}

		merchantId = $("#merchantId2").val();

		$("#accKind2").combobox(
						{
							url : "merchant/merchantDiscountAction!getAccKind.action?merchant.merchantId="
									+ merchantId,
							valueField : "accKind",
							textField : "accName",
							editable : false,
							panelHeight : 'auto'
						});

		$("#discountType2").combobox({
			valueField : "value",
			textField : "label",
			data : [ {
				label : "请选择",
				value : ""
			}, {
				label : "月",
				value : "1"
			}, {
				label : "周",
				value : "2"
			}, {
				label : "固定日",
				value : "3"
			} ],
			editable : false,
			panelHeight : 'auto',
			onSelect : function(r) {
				if (r.value == "3") {
					$("#discountTxt2").hide();
					$("#discountTxt2").removeAttr("name");

					$("#discountTxt3").show();
					$("#discountTxt3").attr("name", "discount.discountText");
				} else {
					$("#discountTxt3").hide();
					$("#discountTxt3").removeAttr("name");

					$("#discountTxt2").show();
					$("#discountTxt2").attr("name", "discount.discountText");
				}
			}
		});

		if (model == "add") {
			submitUrl = "merchant/merchantDiscountAction!addDiscount.action";
		} else {
			submitUrl = "merchant/merchantDiscountAction!modifyDiscount.action";
		}

		$("#form").form({
			url : submitUrl,
			onSubmit : function() {
				if (!$("#form").form("validate")) {
					return false;
				}

				var discount = $("#discount2").val();

				if (isNaN(discount)) {
					$.messager.alert("消息提示", "折扣率格式不正确", "info");
					return false;
				} else if (discount<=0||discount>100) {
					$.messager.alert("消息提示", "折扣率必须是0~100之间的整数", "info");
					return false;
				}

				if ($("#accKind2").combobox("getValue") == "") {
					$.messager.alert("消息提示", "账户类型不能为空", "info");
					return false;
				}

				if ($("#discountType2").combobox("getValue") == "") {
					$.messager.alert("消息提示", "折扣方式不能为空", "info");
					return false;
				}

				if ($("input[name='discount.discountText']").val() == "") {
					$.messager.alert("消息提示", "折扣时间不能为空", "info");
					return false;
				}
			},
			success : function(data) {
				var info = JSON.parse(data);

				if (info.status == "1") {
					$.messager.alert("消息提示", info.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "商户折扣率保存成功", "info");
					$.modalDialog.handler.dialog('destroy');
					$.modalDialog.handler = undefined;
				}
			}
		});
	});

	function save() {
		$("#form").form("submit");
	}

	function autoCom2() {
		if ($("#merchantId2").val() == "") {
			$("#merchantName2").val("");
		}
		$("#merchantId2")
				.autocomplete(
						{
							position : {
								my : "left top",
								at : "left bottom",
								of : "#merchantId2"
							},
							source : function(request, response) {
								$
										.post(
												'merchantRegister/merchantRegisterAction!initAutoComplete.action',
												{
													"merchant.merchantId" : $(
															"#merchantId2")
															.val(),
													"queryType" : "1"
												},
												function(data) {
													response($
															.map(
																	data.rows,
																	function(
																			item) {
																		return {
																			label : item.label,
																			value : item.text
																		}
																	}));
												}, 'json');
							},
							select : function(event, ui) {
								merchantId = ui.item.label;
								$('#merchantId2').val(ui.item.label);
								$('#merchantName2').val(ui.item.value);
								$("#accKind2").combobox(
										"reload",
										"merchant/merchantDiscountAction!getAccKind.action?merchant.merchantId="
												+ merchantId);
								return false;
							},
							focus : function(event, ui) {
								return false;
							}
						});
	}

	function autoComByName2() {
		if ($("#merchantName2").val() == "") {
			$("#merchantId2").val("");
		}
		$("#merchantName2")
				.autocomplete(
						{
							source : function(request, response) {
								$
										.post(
												'merchantRegister/merchantRegisterAction!initAutoComplete.action',
												{
													"merchant.merchantName" : $(
															"#merchantName2")
															.val(),
													"queryType" : "0"
												},
												function(data) {
													response($
															.map(
																	data.rows,
																	function(
																			item) {
																		return {
																			label : item.text,
																			value : item.label
																		}
																	}));
												}, 'json');
							},
							select : function(event, ui) {
								merchantId = ui.item.value;
								$('#merchantId2').val(ui.item.value);
								$('#merchantName2').val(ui.item.label);
								$("#accKind2").combobox(
										"reload",
										"merchant/merchantDiscountAction!getAccKind.action?merchant.merchantId="
												+ merchantId);
								return false;
							},
							focus : function(event, ui) {
								return false;
							}
						});
	}
</script>
<div class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">折扣时间</span><span><span class="label-info"><strong>月</strong></span>:1|2|3
				表示 每月1号、2号、3号; <span class="label-info"><strong>周</strong></span>:1|2|3
				表示每周一、周二、周三; <span class="label-info"><strong>固定日</strong></span>:请输入日期
			</span>
		</div>
	</div>
	<div data-options="region:'center',border:false"
		style="overflow: hidden; padding: 0px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<input type="hidden" name="discount.id" value="${discount.id}" />
			<table class="tablegrid" style="width: 100%">
				<tbody>
					<tr>
						<!-- style="background: rgb(235, 235, 228);" -->
						<th class="tableleft">商户编号：</th>
						<td class="tableright"><input id="merchantId2"
							name="discount.merchantId" class="textinput easyui-validatebox"
							type="text" value="${discount.merchantId}" onkeydown="autoCom2()"
							onkeyup="autoCom2()"
							data-options="required:true, missMessage:'商户编号不能为空'"
							<c:if test="${model ne 'add'}"> disabled="disabled" style="background: rgb(235, 235, 228);"</c:if> /></td>
						<th class="tableleft">商户名称：</th>
						<td class="tableright"><input id="merchantName2" type="text"
							class="textinput" onkeydown="autoComByName2()"
							onkeyup="autoComByName2()" value="${merchant.merchantName}"
							<c:if test="${model ne 'add'}"> disabled="disabled" style="background: rgb(235, 235, 228);"</c:if> /></td>
					</tr>
					<tr>
						<th class="tableleft">账户种类：</th>
						<td class="tableright"><input id="accKind2"
							name="discount.accKind" class="textinput"
							value="${discount.accKind}" /></td>
						<th class="tableleft">折扣方式：</th>
						<td class="tableright"><input id="discountType2"
							name="discount.discountType" type="text" class="textinput"
							value="${discount.discountType}" /></td>
					</tr>
					<tr>
						<th class="tableleft">折扣时间：</th>
						<td class="tableright"><input id="discountTxt2"
							name="discount.discountText" type="text" class="textinput"
							value='${discount.discountText}' /><input id="discountTxt3"
							type="text" class="Wdate textinput"
							value='${discount.discountText}' readonly="readonly"
							onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})" /></td>
						<th class="tableleft">折扣率：</th>
						<td class="tableright"><input id="discount2" type="number"
							name="discount.discount" class="textinput easyui-validatebox"
							value="${discount.discount}"
							data-options="required:true, missMessage:'折扣率不能为空'" /></td>
					</tr>
					<tr>
						<th class="tableleft">备注：</th>
						<td class="tableright" colspan="3"><input type="text"
							name="discount.note" class="textinput" style="width: 468px"
							value="${discount.note}" /></td>
					</tr>
					<tr>
						<th class="tableleft">生效日期：</th>
						<td class="tableright"><input type="text"
							name="discount.startDate"
							value='<fmt:formatDate value="${discount.startDate}" type="date"/>'
							class="Wdate textinput easyui-validatebox"
							onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"
							data-options="required:true, missMessage:'生效日期不能为空'"
							readonly="readonly" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
</div>