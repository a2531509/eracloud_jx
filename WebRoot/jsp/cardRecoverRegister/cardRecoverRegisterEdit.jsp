<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<script type="text/javascript">
	var $cardRecoverRegisterEditDataGrid;
	$(function(){
		$cardRecoverRegisterEditDataGrid = createDataGrid({
			id: "cardRecoverRegisterEditDataGrid",
			toolbar:"#edittb",
			pagination:false,
			singleSelect:false,
			remoteSort:false,
			frozenColumns: [[
				{field:"ID", checkbox:true},
				{field:"BOX_NO",title:"盒号",align:"center",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"NAME",title:"姓名",align:"center",sortable:true, width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",align:"center",sortable:true, width:parseInt($(this).width() * 0.12)},
				{field:"CARD_TYPE",title:"卡类型",align:"center",sortable:true, width:parseInt($(this).width() * 0.05)},
				{field:"CARD_NO",title:"卡号", align:"center",sortable:true, width:parseInt($(this).width() * 0.13)}
			]],
			columns:[[
				{field:"APPLY_WAY",title:"申领方式",align:"center",sortable:true, width:parseInt($(this).width() * 0.06)},
				{field:"APPLY_TYPE",title:"申领类型",align:"center",sortable:true, width:parseInt($(this).width() * 0.06)},
				{field:"APPLY_DATE",title:"申领时间",align:"center",sortable:true, width:parseInt($(this).width() * 0.12)},
				{field:"CORP_ID",title:"单位编号",align:"center",sortable:true, width:parseInt($(this).width() * 0.08)},
				{field:"CORP_NAME",title:"单位名称",align:"center",sortable:true},
				{field:"REGION_NAME",title:"区域",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"TOWN_NAME",title:"乡镇（街道）", align:"center", sortable:true},
				{field:"COMMUNITY_NAME",title:"社区（村）",align:"center",sortable:true},
				{field:"CONCAT_ADDRESS",title:"联系地址",align:"center"}
			]]
		});
	});
	function queryCard() {
		if($("#register_cardNo").val() == "") {
			$.messager.alert("系统消息", "请输入卡号在进行查询！", "warning");
			return;
		}
		$.messager.progress({text:"处理中，请稍后......"});
		$.post("cardRecoverRegister/cardRecoverRegisterAction!queryCardApplyInfo.action","cardNo=" + $("#register_cardNo").val(), function(data, status) {
			$.messager.progress("close");
			if (status == "success") {
				if (dealNull(data.errMsg) != "") {
					$.messager.alert("系统消息", data.errMsg, "error");
				} else {
					confirmRegister(data, null);
				}
			} else {
				$.messager.alert("系统消息","查询申领信息发生错误！请重试！","error");
			}
		}, "json");
	}
	function readCard(){
		$.messager.progress({text:"正在获取卡信息，请稍后......"});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0) {
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"], "error");
			return;
		}
		$.messager.progress("close");
		$("#register_cardNo").val(cardmsg["card_No"]);
		queryCard();
	}
	function confirmRegister(data,row) {
		$("#dd").dialog({
			buttons:[{
				text:"确定",
				iconCls:"icon-ok",
				handler:function() {
					if($("#info_boxNo").val() == "") {
						$.messager.alert("系统消息", "请输入存放盒号！","error",function(){
							$("#info_boxNo").focus();
						});
						return;
					}
					if (data != null) {
						var rows = $("#cardRecoverRegisterEditDataGrid").datagrid("getRows");
						for (var index = 0; index < rows.length; index++) {
							if (rows[index].CARD_NO == data.cardNo) {
								$.messager.confirm("系统消息", "列表中已存在该登记信息，是否覆盖", function(e) {
									if(e){
										$cardRecoverRegisterEditDataGrid.datagrid("updateRow", {
											index:index,
											row:{
												BOX_NO:$("#info_boxNo").val(),
												NAME:data.name,
												CERT_NO:data.certNo,
												CARD_TYPE:data.cardType,
												CARD_NO:data.cardNo,
												APPLY_WAY:data.applyWay,
												APPLY_TYPE:data.applyType,
												APPLY_DATE:data.applyDate,
												CORP_ID:data.corpId,
												CORP_NAME:data.corpName,
												REGION_NAME:data.regionName,
												TOWN_NAME:data.townName,
												COMMUNITY_NAME:data.communityName,
												CONCAT_ADDRESS:data.concatAddress
											}
										});
									}
								});
								$("#dd").dialog("close");
								return;
							}
						}
						$("#cardRecoverRegisterEditDataGrid").datagrid("appendRow",{
							BOX_NO:$("#info_boxNo").val(),
							NAME:data.name,
							CERT_NO:data.certNo,
							CARD_TYPE:data.cardType,
							CARD_NO:data.cardNo,
							APPLY_WAY:data.applyWay,
							APPLY_TYPE:data.applyType,
							APPLY_DATE:data.applyDate,
							CORP_ID:data.corpId,
							CORP_NAME:data.corpName,
							REGION_NAME:data.regionName,
							TOWN_NAME:data.townName,
							COMMUNITY_NAME:data.communityName,
							CONCAT_ADDRESS:data.concatAddress
						});
						//$.messager.alert("系统消息", "卡片回收登记操作成功！", "info");
						$("#register_cardNo").val("");
					} else {
						var position = $cardRecoverRegisterEditDataGrid.datagrid("getRowIndex",row);
						$cardRecoverRegisterEditDataGrid.datagrid("updateRow", {
							index:position,
							row:{
								BOX_NO:$("#info_boxNo").val()
							}
						});
						//$.messager.alert("系统消息", "修改登记盒号信息操作成功！", "info");
					}
					$("#dd").dialog("close");
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					$("#dd").dialog("close");
				}
			}]
		});
		$("#dd").dialog("open");
		$("#info_name").val(data != null ? data.name :row.NAME);
		$("#info_certNo").val(data != null ? data.certNo :row.CERT_NO);
		$("#info_cardType").val(data != null ? data.cardType :row.CARD_TYPE);
		$("#info_cardNo").val(data != null ? data.cardNo :row.CARD_NO);
		$("#info_applyWay").val(data != null ? data.applyWay :row.APPLY_WAY);
		$("#info_applyType").val(data != null ? data.applyType :row.APPLY_TYPE);
		$("#info_applyDate").val(data != null ? data.applyDate :row.APPLY_DATE);
		$("#info_corpId").val(data != null ? data.corpId :row.CORP_ID);
		$("#info_corpName").val(data != null ? data.corpName :row.CORP_NAME);
		$("#info_regionName").val(data != null ? data.regionName :row.REGION_NAME);
		$("#info_townName").val(data != null ? data.townName :row.TOWN_NAME);
		$("#info_communityName").val(data != null ? data.communityName :row.COMMUNITY_NAME);
		$("#info_concatAddress").val(data != null ? data.concatAddress :row.CONCAT_ADDRESS);
		$("#info_boxNo").val(row != null ? row.BOX_NO :"");
	}
	function modifyBoxNo() {
		var rows = $cardRecoverRegisterEditDataGrid.datagrid("getChecked");
		if (rows.length != 1) {
			$.messager.alert("系统消息", "请选择一条要修改盒号的记录！", "info");
			return;
		}
		confirmRegister(null, rows[0]);
	}
	function cancelRegister() {
		var rows = $cardRecoverRegisterEditDataGrid.datagrid("getChecked");
		if (rows.length == 0) {
			$.messager.alert("系统消息", "请选择要取消登记的记录！", "info");
			return;
		}
		$.messager.confirm("系统消息", "确定要取消登记已勾选的记录？", function(e) {
			if (e) {
				$.messager.progress({text:"正在取消登记已勾选的记录，请稍后......"});
				for (var index = 0; index < rows.length; index++) {
					var position = $cardRecoverRegisterEditDataGrid.datagrid("getRowIndex", rows[index]);
					$cardRecoverRegisterEditDataGrid.datagrid("deleteRow", position);
				}
				$.messager.progress("close");
				$.messager.alert("系统消息", "取消登记操作成功！","info");
			}
		});
	}
	function save() {
		var rows = $("#cardRecoverRegisterEditDataGrid").datagrid("getRows");
		if (rows.length == 0) {
			$.messager.alert("系统消息", "请添加需要登记的卡信息！", "info");
			return;
		}
		$.messager.confirm("系统消息", "确定要对所添加的卡信息进行卡片回收登记？", function(e) {
			if (e) {
				$.messager.progress({text:"正在进行登记，请稍后......"});
				var registerInfo = "{info:[";
				for (var index = 0; index < rows.length; index++) {
					registerInfo += "{boxNo:\"" + rows[index].BOX_NO + "\", cardNo:\"" + rows[index].CARD_NO + "\"}";
					if (index != rows.length - 1) {
						registerInfo += ",";
					}
				}
				registerInfo += "]}";
				$.post("cardRecoverRegister/cardRecoverRegisterAction!saveCardRecoverRegister.action", {
					"registerInfo":registerInfo
				}, function(data, status) {
					if (status == "success") {
						if (dealNull(data.errMsg) != "") {
							$.messager.progress("close");
							$.messager.alert("系统消息", data.errMsg, "error");
						} else {
							$cardRecoverRegisterDataGrid.datagrid("reload");
							var message = "成功登记" + data.success + "条卡信息！";
							if (data.failure != "0") {
								message += "<br/>其中" + data.failure + "条卡信息登记失败！原因：<br/>";
								message += data.note;
							}
							$.messager.progress("close");
							$.messager.alert("系统消息", message, "info", function() {
								$.modalDialog.handler.dialog("destroy");
								$.modalDialog.handler = undefined;
							});
						}
					} else {
						$.messager.progress("close");
						$.messager.alert("系统消息", "卡片回收登记操作发生错误！请重试！", "error");
					}
				}, "json");
			}
		});
	}
</script>
<div class="easyui-layout" data-options="fit: true">
	<div data-options="region: 'center', split: false, border:false" style="height: auto; overflow: hidden; border-left: none; border-bottom: none;">
		<div id="edittb">
			<table class="tablegrid">
				<tr>
					<td class="tableleft" style="width: 8%">卡号：</td>
					<td class="tableright"><input type="text" id="register_cardNo" name="" class="textinput"/></td>
					<td class="tableright">
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-search'" onclick="queryCard();">查询</a>
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-readCard'" onclick="readCard();">读卡</a>
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-edit'" onclick="modifyBoxNo();">修改盒号</a>
						<a href="javascript: void(0);" class="easyui-linkbutton" data-options="plain: false, iconCls: 'icon-undo'" onclick="cancelRegister();">取消登记</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="cardRecoverRegisterEditDataGrid"></table>
	</div>
</div>
<div id="dd" class="easyui-dialog" title="卡片回收登记确认" style="width:900px; height:310px;" data-options="iconCls: 'icon-taskExpBank', resizable:false, modal:true, closed: true">
	<div class="easyui-layout" data-options="fit: true">
		<div data-options="region: 'center', split: false, border: true" class="datagrid-toolbar" style="height: auto; overflow: hidden; border-left: none; border-bottom: none;">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">姓名：</td>
					<td class="tableright"><input type="text" id="info_name" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input type="text" id="info_certNo" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input type="text" id="info_cardNo" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input type="text" id="info_cardType" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">单位编号：</td>
					<td class="tableright"><input type="text" id="info_corpId" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">单位名称：</td>
					<td class="tableright"><input type="text" id="info_corpName" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft">申领方式：</td>
					<td class="tableright"><input type="text" id="info_applyWay" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">申领类型：</td>
					<td class="tableright"><input type="text" id="info_applyType" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">申领时间：</td>
					<td class="tableright"><input type="text" id="info_applyDate" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft">所属区域：</td>
					<td class="tableright"><input type="text" id="info_regionName" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">城镇（街道）：</td>
					<td class="tableright"><input type="text" id="info_townName" class="textinput" readonly="readonly"/></td>
					<td class="tableleft">社区（村）：</td>
					<td class="tableright"><input type="text" id="info_communityName" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft">联系地址：</td>
					<td class="tableright" colspan="3"><input type="text" id="info_concatAddress" class="textinput" style="width:95%;" readonly="readonly"/></td>
					<td class="tableleft">盒号：</td>
					<td class="tableright"><input type="text" id="info_boxNo" class="textinput" maxlength="10"/></td>
				</tr>
			</table>
		</div>
	</div>
</div>