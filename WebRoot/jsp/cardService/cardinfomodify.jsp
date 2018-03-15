<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<style>
	.tableleft{
		font-weight:600;
	}
</style>
<script type="text/javascript">
	var cardinfo;
	$(function(){
		$('#cardNo').validatebox('validate');
		$('#cardAmt').validatebox('validate');
		createSysCode({id:"tarBusType",codeType:"BUS_TYPE"});
		createLocalDataSelect({id:"tarValidDate",
			data:[
			    {value:"10",text:"10年"},
			    {value:"15",text:"15年"},
			    {value:"20",text:"20年"},
			    {value:"25",text:"25年"},
			    {value:"30",text:"30年"},
			]
		});
		//createSysCode({id:"busType",codeType:"BUS_TYPE"});
	});
	function readCard(){
		$.messager.progress({text : '正在验证卡信息,请稍后...'});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress('close');
			$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error',function(){
				window.history.go(0);
			});
			return false;
		}
		$("#tarBusType").combobox("setValue", "");
		$("#cardNo").val(cardinfo["card_No"]);
		$("#cardAmt").val((parseFloat(isNaN(cardinfo["wallet_Amt"]) ? 0 : cardinfo["wallet_Amt"])/100).toFixed(2));
		$("#name").val(cardinfo["name"]);
		if(dealNull(cardinfo["sex"]) == "1"){
			$("#csex").val("男");
		}else if(dealNull(cardinfo["sex"]) == "2"){
			$("#csex").val("女");
		}else{
			$("#csex").val("未知");
		}
		$("#certNo").val(cardinfo["cert_No"]);
		if(cardinfo['cert_Type'] == "01"){
			$('#certType').val("身份证");
		}else if(cardinfo['cert_Type'] == "02"){
			$('#certType').val("户口博");
		}else if(cardinfo['cert_Type'] == "03"){
			$('#certType').val("军官证");
		}else if(cardinfo['cert_Type'] == "04"){
			$('#certType').val("护照");
		}else if(cardinfo['cert_Type'] == "05"){
			$('#certType').val("户籍证明");
		}else{
			$('#certType').val("其他");
		}
		$("#busType").val(cardinfo["busTypeName"]);
		$('#start_Date').val(cardinfo['start_Date'].substring(0,4) + "-" + cardinfo['start_Date'].substring(4,6) + "-" + cardinfo['start_Date'].substring(6,8));
		$('#card_Valid_Date').val(cardinfo['card_Valid_Date'].substring(0,4) + "-" + cardinfo['card_Valid_Date'].substring(4,6) + "-" + cardinfo['card_Valid_Date'].substring(6,8));
		$('#valid_Date').val(cardinfo['valid_Date'].substring(0,4) + "-" + cardinfo['valid_Date'].substring(4,6) + "-" + cardinfo['valid_Date'].substring(6,8));
		validCard();
	}
	function validCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				$("#cardType").val(data.card.cardTypeStr);
				$("#cardState").val(data.card.note);
				$("#fkDate").val(data.card.issueDate);
				$("#cardStateHidden").val(data.card.cardState);
				if(dealNull(data.card.cardNo).length == 0){
					$.messager.alert("系统消息","卡号信息不存在，无法进行信息修改！","error",function(){
						window.history.go(0);
					});
				}
			}else{
				$.messager.alert("系统消息","验证卡片信息发生错误，请重试...","error",function(){
					window.history.go(0);
				});
			}
		},"json").error(function(){
			$.messager.alert("系统消息","验证卡片信息发生错误，请重试...","error",function(){
				window.history.go(0);
			});
		});
	}
	function save(){
		if(cardinfo == null){
			$.messager.alert("系统消息","请先读取卡片信息！","error");
			return;
		}
		if(cardinfo["card_No"] == '' || cardinfo["card_No"] == undefined){
			$.messager.alert("系统消息","读取卡片信息失败，请重新操作！","error");
			return;
	    }
		if($("#tarBusType").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择将要修改的目标公交子类型！","error",function(){
				$("#tarBusType").combobox("showPanel");
			});
			return;
		}
		if($("#busType").val() == $("#tarBusType").combobox("getText")){
			$.messager.alert("系统消息","该公交类型已经是【" + $("#busType").val() + "】类型，无需修改！","error");
			return;
		}
		if(dealNull($("#cardStateHidden").val() != "<%=com.erp.util.Constants.CARD_STATE_ZC%>")){
			$.messager.alert("系统消息","卡状态不正常，无法进行修改！","error");
			return;
		}
		$.messager.confirm("系统消息","您确定将公交子类型修改为【" + $("#tarBusType").combobox("getText") + "】？",function(r) {
			 if(r){
				 to_update();
			 }
		});			
	}
	function to_update(){
		$.messager.progress({text:"正在进行修改卡信息,请稍后..."});
		$.post("cardService/cardServiceAction!saveBusTypeModifyHjl.action",{"cardNo":$("#cardNo").val(),"bus_type":$("#tarBusType").combobox("getValue")},function(data,status){
			if(data["status"] == '0'){
				$("#dealNo").val(data["dealNo"]);
				//alert(data["validDate"]);
				if(CardModifyCardInfo($("#cardNo").val(),$("#tarBusType").combobox("getValue"),data["validDate"])){//
					to_confirm();
				}else{
					to_cancel();
				}
			}else if(data["status"] == "1"){
				$.messager.progress("close");
				$.messager.alert("系统消息",data["msg"],"error");
			}
		},"json").error(function(){
			$.messager.progress("close");
			$.messager.alert("系统消息","修改卡信息失败，请重新进行操作！","error",function(){
				window.history.go(0);
			});
		});
	}
	function to_confirm(){
		$.post("cardService/cardServiceAction!saveBusTypeModifyConfirm.action",{"dealNo":$("#dealNo").val()},function(data){
			$.messager.progress("close");
			if(data['status'] == '0'){
				$.messager.alert("系统消息","写卡成功，将跳转至凭证页面...","info",function(){
					showReport("卡片信息修改",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				});
			}else if(data['status'] == '1'){
				showReport("卡片信息修改",$("#dealNo").val(),function(){
					window.history.go(0);
				});
			}
		},"json");
	}
	function to_cancel(){
		$.post("cardService/cardServiceAction!saveBusTypeModifyCancel.action",{"dealNo":$("#dealNo").val()},function(data){
			$.messager.progress("close");
			if(data["status"] == '0'){
				//$.messager.alert("系统消息","修改卡信息出现错误，请重新进行操作！","error");
			}else if(data["status"] == "1"){
				//$.messager.alert("系统消息","修改卡信息出现错误，请重新进行操作！","error");
			}
		},"json");
	}
</script>
<n:initpage title="卡片信息进行更改操作！<span style='color:red;'>注意：</span>只有卡状态为“正常”的卡才能进行卡片信息修改！">
	<n:center>
		<form id="form" method="post">
			<input type="hidden" value="9" name="cardStateHidden" id="cardStateHidden"/>
			<input type="hidden" value="" name="dealNo" id="dealNo"/>
		</form>
	  	<div id="tb"  style="padding:2px 0;width:100%;" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:false,tools:'#toolspanel'" title="卡片信息修改">
			<table class="tablegrid">
				<tr>
					<td style="width:25%" class="tableleft">卡号：</td>
					<td style="width:20%" class="tableright"><input name="cardNo" data-options="required:true,invalidMessage:'请读卡以获取卡号信息',missingMessage:'请读卡以获取卡号信息'" class="textinput easyui-validatebox" id="cardNo" type="text" readonly="readonly"/></td>
					<td style="width:20%" class="tableleft">卡内余额：</td>
					<td style="width:35%" class="tableright"><input name="cardAmt" data-options="required:true,invalidMessage:'请读卡以获取卡内余额信息',missingMessage:'请读卡以获取卡内余额信息'" class="textinput easyui-validatebox" id="cardAmt" type="text" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft">姓名：</td>
					<td class="tableright"><input id="name" type="text" class="textinput" name="name" disabled="disabled"/></td>
					<td class="tableleft">性别：</td>
					<td class="tableright"><input name="csex" class="textinput" id="csex" type="text" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="tableleft">证件类型：</td>
					<td class="tableright"><input id="certType" type="text" class="textinput" name="certType" disabled="disabled"/></td>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input id="cardType" type="text" class="textinput" name="cardType" readonly="readonly" disabled="disabled"/></td>
					<td class="tableleft">卡状态：</td>
					<td class="tableright"><input id="cardState" type="text" class="textinput" name="cardState"  readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="tableleft">公交类型：</td>
					<td class="tableright"><input id="busType" type="text" class="textinput" name="busType" disabled="disabled"/></td>
					<td class="tableleft">发卡日期：</td>
					<td class="tableright"><input id="start_Date" type="text" class="textinput" name="start_Date"  readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="tableleft">卡片有效期：</td>
					<td class="tableright"><input id="card_Valid_Date" type="text" class="textinput" name="card_Valid_Date" readonly="readonly" disabled="disabled"/></td>
					<td class="tableleft">应用有效期：</td>
					<td class="tableright"><input id="valid_Date" type="text" class="textinput" name="valid_Date" disabled="disabled"/></td>
				</tr>
			</table>
		</div>
		<div id="tb2"  style="padding:2px 0;" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:true,tools:'#toolspanel2'" title="参数信息">
			<table class="tablegrid">
				<tr>
					<td class="tableleft"  style="width:25%">公交类型：</td>
					<td class="tableright" style="width:20%"><input id="tarBusType" type="text" class="textinput" name="tarBusType"/></td>
					<td class="tableright" style="width:55%" colspan="2">
						<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0)" class="easyui-linkbutton" onclick="readCard()">读卡</a>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a  data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0)" class="easyui-linkbutton" onclick="save()">确定修改</a>
					</td>
				</tr>
			</table>
		</div>
	</n:center>
</n:initpage>