<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
    var globalCardInfo;
	$(function(){
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"120,100",
			hasDownArrow:false
		});
		createSysCode({
			id:"certType",
			codeType:"CERT_TYPE",
			hasDownArrow:false
		});
		createSysCode({
			id:"cardState",
			codeType:"CARD_STATE",
			hasDownArrow:false
		});
		$("#form").form({
			url:"cardService/cardServiceAction!printCardAccBalCer.action",
			success:function(data){
				$.messager.progress("close");
				var json = JSON.parse(data);
				if(!json || json.status != 0){
					jAlert(json.errMsg);
					return;
				}
				showReport("账户余额凭证",json.dealNo,function(){
     			});
			},
			onSubmit:function(params){
				if(!$("#readCard").val()){
					jAlert("请先进行读卡操作！", "warning");
					return false;
				}
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
				"ljAccBal":data.ljAccBal,
				"ljAccFrzBal":data.ljAccFrzBal,
				"qbAccBal":data.qbAccBal,
				"qbAccFrzBal":data.qbAccFrzBal
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
</script>
<n:initpage>
	<n:north title="打印卡片余额凭证" />
	<n:center>
		<div id="tb" class="easyui-panel datagrid-toolbar" data-options="border:false" style="height: 100%; ">
			<form id="form" method="post">
				<input id="readCard" type="hidden">
				<table class="tablegrid">
					<tr>
						<td colspan="6">
							<h3 class="subtitle">卡片信息</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">卡号:</td>
						<td class="tableright" style="width: 250px">
							<input id="cardNo" name="cardNo" class="textinput easyui-validatebox" required="required" readonly="readonly">
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
						</td>
						<td class="tableleft" style="font-weight: bold">卡类型:</td>
						<td class="tableright" style="width: 200px">
							<input id="cardType" name="cardType" class="textinput" disabled="disabled">
						</td>
						<td class="tableleft" style="font-weight: bold">卡状态:</td>
						<td class="tableright" style="width: 300px">
							<input id="cardState" name="cardState" class="textinput" disabled="disabled">
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">客户信息</h3>
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
						<td colspan="6">
							<h3 class="subtitle">市民卡账户</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">账户余额（<span style="color:red;">元</span>）：</td>
						<td class="tableright"><input id="ljAccBal" name="ljAccBal" class="textinput" disabled="disabled"></td>
						<td class="tableleft" style="font-weight: bold">冻结金额（<span style="color:red;">元</span>）：</td>
						<td class="tableright" colspan="3"><input id="ljAccFrzBal" name="ljAccFrzBal" class="textinput" disabled="disabled"></td>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">市民卡钱包</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">账户余额（<span style="color:red;">元</span>）：</td>
						<td class="tableright"><input id="qbAccBal" name="qbAccBal" class="textinput" disabled="disabled"></td>
						<td class="tableleft" style="font-weight: bold">冻结金额（<span style="color:red;">元</span>）：</td>
						<td class="tableright" colspan="3"><input id="qbAccFrzBal" name="qbAccFrzBal" class="textinput" disabled="disabled"></td>
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