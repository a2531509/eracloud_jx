<%@page import="com.erp.util.Constants"%>
<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
    var globalCardInfo;
	$(function(){
		createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"Base_Bank",
			where:"bank_state = '0'",
			isShowDefaultOption:true,
			orderby:"bank_id asc",
			hasDownArrow:false,
			from:1,
			to:30
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"120,100",
			editable:false,
			hasDownArrow:false
		});
		createSysCode({
			id:"certType",
			codeType:"CERT_TYPE",
			hasDownArrow:false
		});
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE"
		});
		createSysCode({
			id:"cardState",
			codeType:"CARD_STATE",
			hasDownArrow:false
		});
		$("#form").form({
			url:"cardService/cardServiceAction!printChangeServiceBankCer.action",
			success:function(data){
				$.messager.progress("close");
				var json = JSON.parse(data);
				if(!json || json.status != 0){
					jAlert(json.errMsg);
					return;
				}
				showReport("更换服务银行凭证",json.dealNo,function(){
     			});
			},
			onSubmit:function(params){
				if(!$("#form").form("validate")){
					return false;
				}
				$.messager.progress({text:"数据处理中，请稍候...."})
			}
		});
	})
	function readCard(){
		$("#form").form("reset");
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		globalCardInfo = getcardinfo();
		if(dealNull(globalCardInfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + globalCardInfo["errMsg"],"error");
			return;
		}
		$("#cardNo").val(dealNull(globalCardInfo["card_No"]));
		query();
	}
	function query(){
		$.messager.progress({text:"正在加载数据，请稍后...."})
		$.post("cardService/cardServiceAction!getCardAccBalInfo.action", {"cardNo":$("#cardNo").val()}, function(data){
			$.messager.progress("close");
			if(!data || data.status != 0){
				jAlert(!data.errMsg ? "加载失败，未知原因" : data.errMsg);
				return;
			}
			$("#readCard").val(true)
			$("#form").form("load", {
				"cardNo":data.cardNo,
				"cardType":data.cardType,
				"cardState":data.cardState,
				"name":data.name,
				"certType":data.certType,
				"certNo":data.certNo,
				"bankId":data.bankId,
				"bankCardNo":data.bankCardNo
			});
		}, "json");
	}
	
	function validRmb(obj){
		var v = obj.value;
		var exp = /^\d+(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			obj.value = v.substring(0,v.length - 1);
		}else{
			var zeroexp = /^0{2,}$/g;
			if(zeroexp.test(v)){
				obj.value = 0;
			}
		}
	}
	function print(){
		$("#form").form("submit");
	}
	function readIdCard2(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#agtCertNo").val(certinfo["cert_No"]);
			$("#agtName").val(certinfo["name"]);
		}
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<n:initpage>
	<n:north title="打印更换服务银行凭证" />
	<n:center>
		<div id="tb" class="easyui-panel datagrid-toolbar" data-options="border:false" style="height: 100%; ">
			<form id="form" method="post">
				<input id="readCard" type="hidden">
				<table class="tablegrid">
					<tr>
						<td colspan="6">
							<h3 class="subtitle" style="border:none;">卡片信息</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">卡号:</td>
						<td class="tableright" style="width: 300px">
							<input id="cardNo" name="cardNo" class="textinput easyui-validatebox" required="required">
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
						<td class="tableleft" style="font-weight: bold">卡类型:</td>
						<td class="tableright">
							<input id="cardType" name="cardType" class="textinput" disabled="disabled">
						</td>
						<td class="tableleft" style="font-weight: bold">卡状态:</td>
						<td class="tableright">
							<input id="cardState" name="cardState" class="textinput" disabled="disabled">
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">银行:</td>
						<td class="tableright">
							<input id="bankId" name="bankId" class="textinput" disabled="disabled">
						</td>
						<td class="tableleft" style="font-weight: bold">银行卡号:</td>
						<td class="tableright" colspan="3">
							<input id="bankCardNo" name="bankCardNo" class="textinput" disabled="disabled">
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle" style="border:none;">客户信息</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">姓名:</td>
						<td class="tableright"><input id="name" name="name" class="textinput" disabled="disabled"></td>
						<td class="tableleft" style="font-weight: bold">证件类型:</td>
						<td class="tableright"><input id="certType" name="certType" class="textinput" disabled="disabled"></td>
						<td class="tableleft" style="font-weight: bold;">证件号码:</td>
						<td class="tableright"><input id="certNo" name="certNo" class="textinput" disabled="disabled"></td>
					</tr>
					<tr>
						<td colspan="6" >
							<h3 class="subtitle" style="border:none;">代理人信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright" ><input id="agtName" name="rec.agtName" type="text" class="textinput" maxlength="30"/></td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright" ><input id="agtCertType" name="rec.agtCertType" type="text" class="textinput"/></td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright" colspan="2"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" maxlength="18" validtype="idcard"/></td>
					</tr>
					<tr>
						<th class="tableleft">代理人联系电话：</th>
						<td class="tableright" ><input id="agtTelNo" name="rec.agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
						<td colspan="4" class="tableright" style="padding-left: 20px">
							<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						</td>
					</tr>
					<tr>
						<td colspan="6" align="center" >
							<a data-options="plain:false,iconCls:'icon-print'" href="javascript:void(0);" class="easyui-linkbutton" onclick="print()">打印凭证</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</n:center>
</n:initpage>