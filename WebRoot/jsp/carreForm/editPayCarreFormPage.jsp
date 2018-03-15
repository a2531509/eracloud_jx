<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<script type="text/javascript">
	$(function() {
		$("#form3").form({
			url : "payCarreForm/payCarreFormAction!modifyPayCarreForm.action",
			onSubmit : function() {
				if (!$("#form3").form("validate")) {
					return false;
				}
			},
			success : function(data) {
				var info = JSON.parse(data);

				if (info.status == "1") {
					$.messager.alert("消息提示", info.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "充值信息保存成功", "info", function() {
						$("#editDialog2").dialog("close");
						query2();
					});
				}
			}
		});
	})

	function save3() {
		$("#form3").form("submit");
	}
</script>
<div class="easyui-layout" data-options="fit:true">
	<div data-options="region:'center',border:false"
		style="overflow: hidden; padding: 0px;" class="datagrid-toolbar">
		<form id="form3" method="post">
			<input type="hidden" name="payCarreform.id.certNo" value="${payCarreform.id.certNo}">
			<table class="tablegrid" style="width: 100%">
				<tbody>
					<tr>
						<th class="tableleft">批次号：</th>
						<td class="tableright"><input id="batchNumber3"
							name="payCarreform.id.batchNumber"
							style="background: rgb(235, 235, 228);" class="textinput"
							readonly="readonly" value="${payCarreform.id.batchNumber}" /></td>
						<th class="tableleft">单位：</th>
						<td class="tableright"><input id="empName3" class="textinput"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${payCarreform.empName}" /></td>
					</tr>
					<tr>
						<th class="tableleft">年份：</th>
						<td class="tableright"><input id="year3" class="textinput"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${payCarreform.provideYear}" /></td>
						<th class="tableleft">月份：</th>
						<td class="tableright"><input id="month3" class="textinput"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${payCarreform.provideMonth}" /></td>
					</tr>
					<tr>
						<th class="tableleft">身份证号：</th>
						<td class="tableright"><input id="certNo3" class="textinput"
							name="newPayCarreform.id.certNo" value="${payCarreform.id.certNo}" /></td>
						<th class="tableleft">卡号：</th>
						<td class="tableright"><input id="cardNo3"
							name="newPayCarreform.cardNo" class="textinput"
							value="${payCarreform.cardNo}" /></td>
					</tr>
					<tr>
						<th class="tableleft">姓名：</th>
						<td class="tableright"><input id="name3"
							name="newPayCarreform.name" class="textinput easyui-validatebox"
							data-options="required:true" value="${payCarreform.name}" /></td>
						<th class="tableleft">金额：</th>
						<td class="tableright"><input id="amt3" class="textinput"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${payCarreform.provideAmt/100}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
</div>