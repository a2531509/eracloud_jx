<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	$(function(){
		createSysCode({
			id:"bkAgtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>",
			width:160
		});
		createLocalDataSelect({
			id:"bkInfoCostFee",
			data:${costFeeSelect},
			width:160
		});
	});
	function saveBkInfo(){
		var row = $cardInfoGrid.datagrid("getSelected");
		if(row){
			if(row.REISSUE_FLAG != "0"){
				$.messager.alert("系统消息","补卡发生错误：此卡类型设置参数不允许进行补卡！","error");
				return;
			}
			if(row.CARD_STATE != "<%=com.erp.util.Constants.CARD_STATE_GS%>"){
				$.messager.alert("系统消息","补卡发生错误：此卡不是挂失状态！当前状态【" + row.CARDSTATE + "】" + "<span style='color:red'>&nbsp;&nbsp;提示：补卡老卡必须是书面挂失状态</span>","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要对【" + $("#personalName").val() + "】卡号为【" + row.CARD_NO + "】的卡进行补卡吗？<br/><div style='color:red;margin-left:42px;'>提示：1、补卡时老卡将进行注销<br/>2、补卡工本费：" + $("#bkInfoCostFee").combobox("getValue") + "</div>",function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("cardService/cardServiceAction!saveBhk.action",$("#bkInfo").serialize() + "&cardNo=" + row.CARD_NO + "&queryType=0",function(data,status){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info":"error"),function(){
							if(data.status == "0"){
								showReport("卡片补卡",data.dealNo);
								$cardInfoGrid.datagrid("reload");
								$cardApplyInfoGrid.datagrid("reload");
								$("#bkInfo").form("reset");
							}
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条记录信息进行补卡","error");
		}
	}
	function readCardBkAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#bkAgtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#bkAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#bkAgtName").val(dealNull(queryCertInfo["name"]));
	}
	function readSMKBkAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#bkAgtCertType").combobox("setValue","1");
		$("#bkAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#bkAgtName").val(dealNull(queryCertInfo["name"]));
	}
</script>

<form id="bkInfo">
    <h3 class="subtitle">工本费信息</h3>
	<table class="tablegrid">
	 	 <tr>
	 	   <td class="tableleft" style="width: 15%">工本费：</td>
			<td class="tableright"><input id="bkInfoCostFee" name="costFee" type="text" class="textinput" /> </td>
	 	 </tr>
	 
	</table>
	<h3 class="subtitle">代理人信息</h3>
	<table class="tablegrid">
	 	<tr>
			<td class="tableleft" style="width: 15%">代理人证件类型：</td>
			<td class="tableright"><input id="bkAgtCertType" name="rec.agtCertType" type="text" class="textinput"/> </td>
			<td class="tableleft">代理人证件号码：</td>
			<td class="tableright"><input id="bkAgtCertNo" name="rec.agtCertNo" type="text" class="textinput agt-info" validtype="idcard" maxlength="18"/></td>
			<td class="tableleft">代理人姓名：</td>
			<td class="tableright"><input id="bkAgtName" name="rec.agtName" type="text" class="textinput agt-info" maxlength="50"/></td>
		</tr>
		<tr>
		 	<td class="tableleft">代理人联系电话：</td>
			<td class="tableright"><input id="bkAgtTelNo" name="rec.agtTelNo" type="text" class="textinput agt-info" validtype="mobile" maxlength="11"/></td>
			<td class="tableright" colspan="4" style="padding-left: 5%">
					<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardBkAgt()">读身份证</a>
				<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMKBkAgt()">读市民卡</a>
				<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveBkInfo()">确定</a>
			</td>
		</tr>
	</table>
</form>