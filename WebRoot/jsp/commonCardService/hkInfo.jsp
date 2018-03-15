<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	var finalhkcostfee = "${costFee}";
	var finalcurrenthkcardno = "";
	$(function(){
		createSysCode({
			id:"hkAgtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>",
			width:"160"
		});
		createLocalDataSelect({
			id:"hkInfoIsGoodCard",
			data:[{value:"0",text:"是"},{value:"1",text:"否"}],
			value:"1",
			width:160,
		    onSelect:function(node){
		 		if(node.value == "0"){
		 			$.messager.alert("系统消息","已选择是好卡，请先进行读卡,再进行查询！","warning");
		 		}
		 		$(this).combobox("setValue",node.value);
				$("#hkInfoIsGoodCard").val(node.value);
				$("#hkInfoCardAmt").val("0.00");
				globalisreadcard = "1";
				finalcurrenthkcardno = "";
		 	}
		});
		if("${isGoodCard}" != ""){
			var tempchg = "[" + "${isGoodCard}" + "]";
			tempchg = eval("(" + tempchg +  ")");
			tempchg.unshift({codeName:"请选择", codeValue:""});
			$("#hkInfoChgCardReason").combobox({
				width:160,
				data:tempchg,
				valueField:"codeValue",
				editable:false,
			    textField:"codeName",
			    panelHeight:"auto",
			    onSelect:function(node){
			    	if(node){
			    		if(!node.codeValue){
			    			$("#hkInfoCostFee").val("");
			    		} else if(node.codeValue == "<%=com.erp.util.Constants.CHG_CARD_REASON_ZLWT%>"){
			    			$("#hkInfoCostFee").val("0.00");
			    		} else {
			    			$("#hkInfoCostFee").val(finalhkcostfee);
			    		}
			    	}
			 	},
			 	onLoadSuccess:function(){
			 		if(!$("#hkInfoChgCardReason").combobox("getValue")){
		    			$("#hkInfoCostFee").val("");
		    		} else if($("#hkInfoChgCardReason").combobox("getValue") == "<%=com.erp.util.Constants.CHG_CARD_REASON_ZLWT%>") {
			 			$("#hkInfoCostFee").val("0.00");
			 		}else{
			 			$("#hkInfoCostFee").val(finalhkcostfee);
			 		}
			 	}
			});
		}
	});
	function toSaveHkInfo(){
		var rows = $cardInfoGrid.datagrid("getChecked");
		if(rows && rows.length == 1){
			if($("#hkInfoIsGoodCard").combobox("getValue") == "0" && globalisreadcard != "0"){
				$.messager.alert("系统消息","是否好卡已选择是【好卡】，请先读卡再进行操作！","error");
				return;
			}
			if(($("#hkInfoIsGoodCard").combobox("getValue") == "0" && globalisreadcard == "0") && $("#queryCardNo").val() != finalcurrenthkcardno){
				$.messager.alert("系统消息","卡号发生变化，请重新进行查询！","error");
				return;
			}
			if(!$("#hkInfoChgCardReason").combobox("getValue")){
				$.messager.alert("系统消息","换卡发生错误：请选择换卡原因！","error");
				return;
    		}
			if(rows[0].CHG_FLAG != "0"){
				$.messager.alert("系统消息","换卡发生错误：此卡类型设置参数不允许进行换卡！","error");
				return;
			}
			if(rows[0].CARD_STATE != "<%=com.erp.util.Constants.CARD_STATE_ZC%>"){
				$.messager.alert("系统消息","换卡发生错误：卡状态不正常！当前状态【" + rows[0].CARDSTATE + "】" + '<span style="color:red">&nbsp;&nbsp;提示：换卡老卡必须是正常状态</span>',"error");
				return;
			}
			if(globalisreadcard == "0" && rows[0].CARD_NO != finalcurrenthkcardno){
				$.messager.alert("系统消息","勾选的卡片信息和当前换卡的卡号不一致，请重新进行勾选！","error");
				return;
			}
			var finalconfirmmsg = "";
			finalconfirmmsg = finalconfirmmsg + "您确定要对【" + $("#personalName").val() + "】卡号为【" + rows[0].CARD_NO + "】的卡进行换卡吗？<br/>";
			finalconfirmmsg = finalconfirmmsg + "<div style=\"color:red;margin-left:42px;\">提示：1、换卡时老卡将进行注销<br/>";
			finalconfirmmsg = finalconfirmmsg + "2、换卡工本费：" + $("#hkInfoCostFee").val() + "<br/>";
			finalconfirmmsg = finalconfirmmsg + "3、是否好卡：已选择 " + $("#hkInfoIsGoodCard").combobox("getText") + "<br/>";
			finalconfirmmsg = finalconfirmmsg + "4、卡面余额：" + ($("#hkInfoIsGoodCard").combobox("getValue") == "0" ? $("#hkInfoCardAmt").val() : "已后台为准");
			finalconfirmmsg = finalconfirmmsg + "</div>";
			$.messager.confirm("系统消息",finalconfirmmsg,function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("cardService/cardServiceAction!saveBhk.action",$("#hkInfo").serialize() + "&cardNo=" + rows[0].CARD_NO + "&queryType=1&cardAmt=" + $("#hkInfoCardAmt").val(),function(data,status){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info":"error"),function(){
							if(data.status == "0"){
								showReport("卡片换卡",data.dealNo);
								$cardInfoGrid.datagrid("reload");
								$cardApplyInfoGrid.datagrid("reload");
								$("#hkInfo").form("reset");
							}
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条记录信息进行换卡","error");
		}
	}
	function readCardHkAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#hkAgtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#hkAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#hkAgtName").val(dealNull(queryCertInfo["name"]));
	}
	function readCardHkCard(){
		$.messager.progress({text : '正在验证卡信息,请稍后...'});
		var hkCard = getcardinfo();
		if(dealNull(hkCard["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + hkCard["errMsg"],"error");
			return false;
		}
		$.messager.progress("close");
		finalcurrenthkcardno = hkCard["card_No"];
		$("#hkInfoIsGoodCard").combobox("setValue","0");
		globalisreadcard = 0;
		$("#hkInfoCardAmt").val((parseFloat(isNaN(hkCard["wallet_Amt"]) ? 0 : hkCard["wallet_Amt"])/100).toFixed(2));
	}
	
	function readSMKHkAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#hkAgtCertType").combobox("setValue","1");
		$("#hkAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#hkAgtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<form id="hkInfo">
	<h3 class="subtitle">卡片信息</h3>
	<table class="tablegrid">
	 	<tr>
	 	 	<td class="tableleft" style="width: 10%">是否好卡：</td>
			<td class="tableright" style="width: 25%"><input id="hkInfoIsGoodCard" name="isGoodCard"  value="1" class="textinput" type="text"/></td>
	 	 	<td class="tableleft" style="width: 10%">换卡原因：</td>
			<td class="tableright" style="width: 25%"><input id="hkInfoChgCardReason" type="text"  class="textinput" name="rec.chgCardReason" /> </td>
			<td class="tableleft" style="width: 10%">工本费：</td>
			<td class="tableright" style="width: 20%">
				<input id="hkInfoCostFee" type="text" value="0.00" class="textinput" name="costFee" readonly="readonly" />
	 		</td>
	 	 </tr>
	 	 <tr>	
	 	 	<td class="tableleft" >卡面金额：</td>
			<td class="tableright" ><input id="hkInfoCardAmt" name="hkInfoCardAmt"  value="0.00" class="textinput" type="text" readonly="readonly"/></td>
	 		<td class="tableright" style="padding-left: 5%" colspan="4">
	 			<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardHkCard()">读卡</a>
	 		</td>
	 	</tr>
	</table>
	<h3 class="subtitle">代理人信息</h3>
	<table class="tablegrid">
		<tr>
			<td class="tableleft" style="width: 10%">代理人证件类型：</td>
			<td class="tableright" style="width: 25%"><input id="hkAgtCertType" name="rec.agtCertType" type="text" class="textinput"/></td>
			<td class="tableleft" style="width: 10%">代理人证件号码：</td>
			<td class="tableright" style="width: 25%"><input id="hkAgtCertNo" name="rec.agtCertNo" class="agt-info textinput"  type="text" validtype="idcard" maxlength="18"/></td>
			<td class="tableleft" style="width: 10%">代理人姓名：</td>
			<td class="tableright" style="width: 20%"><input id="hkAgtName" name="rec.agtName" type="text" class="agt-info textinput"/></td>
		</tr>
		<tr>
		 	<td class="tableleft">代理人联系电话：</td>
			<td class="tableright"><input id="hkAgtTelNo" name="rec.agtTelNo" type="text" class="agt-info textinput" maxlength="11"/></td>
			<td class="tableright" colspan="4" style="padding-left: 5%">
				<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardHkAgt()">读身份证</a>
				<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMKHkAgt()">读市民卡</a>
				<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="toSaveHkInfo()">确定</a>
			</td>
		</tr>
	</table>
</form>