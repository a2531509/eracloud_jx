<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<script type="text/javascript">
	function queryCard() {
		if($("#register_cardNo").val() == "") {
			jAlert("请输入卡号在进行查询！",error,function(){
				$("#register_cardNo").focus();
			});
			return;
		}
		$.messager.progress({text:"正在进行卡信息验证，请稍后......"});
		$.post("cardRecoverRegister/cardRecoverRegisterAction!queryCardApplyInfo.action","cardNo=" + $("#register_cardNo").val(), function(data,status){
			$.messager.progress("close");
			if (status == "success") {
				if (dealNull(data.status) == "0") {
					$("#info_name").val(dealNull(data.name));
					$("#info_certNo").val(dealNull(data.certNo));
					$("#info_cardType").val(dealNull(data.cardType));
					$("#info_cardNo").val(dealNull(data.cardNo));
					$("#info_applyWay").val(dealNull(data.applyWay));
					$("#info_applyType").val(dealNull(data.applyType));
					$("#info_applyDate").val(dealNull(data.applyDate));
					$("#info_corpId").val(dealNull(data.corpId));
					$("#info_corpName").val(dealNull(data.corpName));
					$("#info_regionName").val(dealNull(data.regionName));
					$("#info_townName").val(dealNull(data.townName));
					$("#info_communityName").val(dealNull(data.communityName));
					$("#info_concatAddress").val(dealNull(data.concatAddress));
				} else {
					jAlert(data.errMsg);
				}
			} else {
				jAlert("验证卡信息出现错误，请重试！");
			}
		}, "json");
	}
	function readCard(){
		$.messager.progress({text:"正在获取卡信息，请稍后......"});
		var cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0) {
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"], "error");
			return;
		}
		$.messager.progress("close");
		$("#register_cardNo").val(cardmsg["card_No"]);
		queryCard();
	}
	function saveCardRecovery(){
		if(dealNull($("#info_cardNo").val()) == ""){
			jAlert("请先进行卡信息查询，再进行回收登记！","error",function(){
				$("#info_cardNo").focus();
			});
			return;
		}
		if(dealNull($("#info_boxNo").val()) == ""){
			
		}
		jConfirm("您确定要将【" + $("#info_name").val() + "】的卡片进行回收吗？",function(){
			$.messager.progress({text:"正在进行回收登记，请稍后......"});
			$.post("cardRecoverRegister/cardRecoverRegisterAction!saveCardRecovery.action",{
				cardNo:$("#info_cardNo").val(),
				boxNo:$("#info_boxNo").val()
			}, function(data, status) {
				$.messager.progress("close");
				if(status == "success") {
					if(data.status == "0"){
						jAlert("回收登记成功！","info",function(){
							$cardRecoverRegisterDataGrid.datagrid("reload");
							$.modalDialog.handler.dialog("destroy");
							$.modalDialog.handler = undefined;
						});
					}else{
						jAlert(data.errMsg);
					}
				} else {
					$.messager.progress("close");
					$.messager.alert("系统消息", "卡片回收登记操作发生错误！请重试！", "error");
				}
			}, "json");
		});
	}
</script>
<div class="easyui-layout" data-options="fit:true">
	<div data-options="region:'center',split:false,border:true" class="datagrid-toolbar" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<table class="tablegrid">
			<tr>
			    <td class="tableright" style="text-align:center;" colspan="6">
			    	<table style="margin:0 auto">
			    		<tr>
			    			<td class="tableleft">卡号：</td>
							<td class="tableright"><input type="text" id="register_cardNo" name="" class="textinput" maxlength="20"/></td>
							<td class="tableright">
								<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain: false,iconCls:'icon-search'" onclick="queryCard();">查询</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain: false,iconCls:'icon-readCard'" onclick="readCard();">读卡</a>
							</td>
			    		</tr>
			    	</table>
			    </td>
			</tr>
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