<%@page import="com.erp.util.Constants"%>
<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
    var globalCardInfo;
	$(function(){
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			optimize:true
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			optimize:true,
			minLength:"1"
		},"certNo");
		
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
			url:"cardService/cardServiceAction!printBankCardUnbindAppCer.action",
			success:function(data){
				$.messager.progress("close");
				var json = JSON.parse(data);
				if(!json || json.status != 0){
					jAlert(json.errMsg);
					return;
				}
				showReport("银行卡解绑申领凭证",json.dealNo,function(){
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
		var certNo = $("#certNo").val();
		var cardNo = $("#cardNo").val();
		if(!name && !certNo && ! cardNo && !corpId){
			jAlert("查询条件不能都为空！", "warning");
			return;
		}
		$.messager.progress({text:"正在加载数据，请稍后...."})
		$.post("cardService/cardBindBankCardAction!getCardBindBankCardInfos.action", {"bindInfo.id.certNo":certNo, "card.cardNo":cardNo, isBankCardUnbindApp:true}, function(data){
			$.messager.progress("close");
			if(!data || data.status != 0){
				jAlert("不存在绑定信息");
				return;
			}
			$("#form").form("load", {
				"cardNo":data.rows[0].CARD_NO,
				"cardType":data.rows[0].CARD_TYPE,
				"cardState":data.rows[0].CARD_STATE,
				"name":data.rows[0].NAME,
				"certType":data.rows[0].CERT_TYPE,
				"certNo":data.rows[0].CERT_NO,
				"bankId":data.rows[0].BANK_ID,
				"bankCardNo":data.rows[0].BANK_CARD_NO,
				"mobileNo":data.rows[0].MOBILE_NO,
				"dealNo":data.dealNo
			});
		}, "json");
	}
	
	function print(){
		var dealNo = $("#dealNo").val();
		if(!dealNo){
			jAlert("凭证流水为空！");
			return;
		}
		$.messager.progress({text:"数据处理中，请稍后...."});
		showReport("银行卡解绑申领凭证",dealNo,function(){
			$.messager.progress("close");
		});
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
	<n:north title="打印银行卡解绑申领凭证" />
	<n:center>
		<div id="tb" class="easyui-panel datagrid-toolbar" data-options="border:false" style="height: 100%; ">
			<form id="form" method="post">
				<input type="hidden" id="dealNo" name="dealNo">
				<table class="tablegrid">
					<tr>
						<td colspan="6">
							<h3 class="subtitle" style="border:none;">绑定信息</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold;">证件号码:</td>
						<td class="tableright"><input id="certNo" name="certNo" class="textinput"></td>
						<td class="tableleft" style="font-weight: bold">姓名:</td>
						<td class="tableright"><input id="name" name="name" class="textinput"></td>
						<td class="tableleft" style="font-weight: bold">卡号:</td>
						<td class="tableright" style="width: 300px">
							<input id="cardNo" name="card.cardNo" class="textinput">
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">证件类型:</td>
						<td class="tableright"><input id="certType" name="certType" class="textinput" disabled="disabled"></td>
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
						<td class="tableleft" style="font-weight: bold">手机号码:</td>
						<td class="tableright">
							<input id="mobileNo" name="mobileNo" class="textinput" disabled="disabled">
						</td>
						<td class="tableleft" style="font-weight: bold">绑定银行:</td>
						<td class="tableright">
							<input id="bankId" name="bankId" class="textinput" disabled="disabled">
						</td>
						<td class="tableleft" style="font-weight: bold">绑定银行卡号:</td>
						<td class="tableright">
							<input id="bankCardNo" name="bankCardNo" class="textinput" disabled="disabled">
						</td>
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