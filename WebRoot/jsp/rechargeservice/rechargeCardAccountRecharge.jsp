<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<html>
<script type="text/javascript">
	function readCard(){
		clearCard();
		$.messager.progress({text:"正在读取卡信息,请稍后..."});
		var cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error",function(){
				clearCard();
			});
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		validateCard();
	}

	function validateCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				$("#certType").val(data.person.certTypeStr);
				$("#certNo").val(data.person.certNo);
				$("#cardType").val(data.card.cardTypeStr);
				$("#busType").val(data.card.busTypeStr);
				$("#fkDate").val(data.card.issueDate);
				$("#cardState").val(data.card.note);
				$("#name").val(data.person.name);
				$("#sex").val(data.person.csex);
				$("#cardAmt").val(Number(data.acc.bal).div100());
				if(dealNull(data.card.cardNo).length == 0){
					$.messager.alert("系统消息","验证卡片信息发生错误：当前卡信息不存在，该卡不能进行充值。","error",function(){
						clearCard();
					});
				}
			}else{
				$.messager.alert("系统消息","验证卡信息时出现错误，请重试...","error",function(){
					clearCard();
				});
			}
		},"json").error(function(){
			$.messager.alert("系统消息","验证卡信息时出现错误，请重试...","error",function(){
				clearCard();
			});
		});
	}

	function clearCard(){
		var ids = ["cardNo", "cardAmt", "name", "sex", "certType", "certNo",
			"cardType", "cardState", "busType", "fkDate"];
		for(var i=0;i<ids.length;i++){
			$("#" + ids[i]).val("");
		}
	}

	function readRechargeCard(){
		clearRechargeCard();
		$.messager.progress({text:"正在读取充值卡信息,请稍后..."});
		var cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error",function(){
				clearRechargeCard();
			});
			return;
		}
		$("#rechargeCardNo").val(cardinfo["card_No"]);
		validateRechargeCard();
	}

	function validateRechargeCard(){
		$.post("recharge/rechargeAction!getRechargeCardInfo.action","cardNo=" + $("#rechargeCardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				$("#rechargeCardType").val(data.cardRecharge.cardType);
				$("#rechargeCardNo").val(data.cardRecharge.cardNo);
				$("#rechargeCardFaceVal").val(Number(data.cardRecharge.faceVal).div100());
				if(dealNull(data.cardRecharge.cardNo).length == 0){
					$.messager.alert("系统消息","验证充值卡信息发生错误：当前充值卡信息不存在，不能进行充值操作。","error",function(){
						clearRechargeCard();
					});
				}else if(dealNull(data.cardRecharge.useState) != "已激活"){
					$.messager.alert("系统消息","验证充值卡信息发生错误：当前充值卡为" + data.cardRecharge.useState + "状态，不能进行充值操作。","error",function(){
						clearRechargeCard();
					});
				}
			}else{
				$.messager.alert("系统消息","验证充值卡信息时出现错误，请重试...","error",function(){
					clearRechargeCard();
				});
			}
		},"json").error(function(){
			$.messager.alert("系统消息","验证充值卡信息时出现错误，请重试...","error",function(){
				clearRechargeCard();
			});
		});
	}

	function clearRechargeCard(){
		var ids = ["rechargeCardType", "rechargeCardNo",
			"rechargeCardFaceVal", "rechargeCardPassword"];
		for(var i=0;i<ids.length;i++){
			$("#" + ids[i]).val("");
		}
	}

	function inputPassword(){
		$.messager.progress({text:"正在获取密码信息，请稍后...."});
		$("#rechargeCardPassword").val(getPlaintextPwd());
		$.messager.progress("close");
	}

	function confirmRecharge(){
		if($("#cardNo").val() == ""){
			$.messager.alert("系统消息","请先进行读卡以获取卡号和当前账户余额信息！","error");
			return;
		}
		if($("#rechargeCardNo").val() == ""){
			$.messager.alert("系统消息","请先进行读卡以获取充值卡号信息！","error");
			return;
		}
		if($("#rechargeCardPassword").val() == ""){
			$.messager.alert("系统消息","请输入充值卡密码！","error");
			return;
		}
		if($("#rechargeCardPassword").val().length != 10){
			$.messager.alert("系统消息","充值卡密码长度为10位！","error");
			return;
		}
		$.messager.confirm("系统消息","您确定要为卡号为【" + $("#cardNo").val() + "】的卡片充值<" + $("#rechargeCardFaceVal").val() + ">元？",function(e){
			if(e){
				$.messager.progress({text : "正在进行充值，请稍后...."});
				$.post("recharge/rechargeAction!saveRechargeCardAccount.action",
					{cardNo:$("#cardNo").val(),rechargeCardNo:$("#rechargeCardNo").val(),rechargeCardPwd:$("#rechargeCardPassword").val()},
					function(data,status){
						if(status == "success"){
							if(data.status != "0"){
								$.messager.progress("close");
								$.messager.alert("系统消息",data.msg,"error");
							}else if(data.status == "0"){
								$.messager.progress("close");
								showReport("充值卡账户充值",data.dealNo,function(){
									clearCard();
									clearRechargeCard();
								});
							}
						}else{
							$.messager.alert("系统消息","充值请求出现错误，请重试！","error");
						}
					},"json").error(function(){
						$.messager.alert("系统消息","充值请求出现错误，请重试！","error");
					});
				$.messager.progress("close");
			}
		});
	}

</script>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-top:2px;margin-right:0px;margin-bottom:2px;">
			<span class="badge">提示</span><span>在此你可以对卡片进行<span class="label-info"><strong>充值卡账户充值</strong></span>操作!</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div class="easyui-panel" style="width:100%;height:auto;overflow:hidden;border-left:none;border-bottom:none;" title="卡信息">
			<table style="width:100%" class="datagrid-toolbar tablegrid">
				<tr>
					<td class="tableleft" width="20%">卡号：</td>
					<td class="tableright" width="30%">
						<input type="text" name="cardNo" id="cardNo" class="textinput" readonly="readonly"/>
					</td>
					<td class="tableleft" width="10%">账户余额：</td>
					<td class="tableright" width="40%">
						<input type="text" name="cardAmt" id="cardAmt" class="textinput" readonly="readonly"/>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false" onclick="readCard();">读卡</a>
					</td>
				</tr>
				<tr>
					<td class="tableleft" width="20%">姓名：</td>
					<td class="tableright" width="30%"><input type="text" name="name" id="name" class="textinput" readonly="readonly"/></td>
					<td class="tableleft" width="10%">性别：</td>
					<td class="tableright" width="40%"><input type="text" name="sex" id="sex" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft" width="20%">证件类型：</td>
					<td class="tableright" width="30%"><input type="text" name="certType" id="certType" class="textinput" readonly="readonly"/></td>
					<td class="tableleft" width="10%">证件号码：</td>
					<td class="tableright" width="40%"><input type="text" name="certNo" id="certNo" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft" width="20%">卡类型：</td>
					<td class="tableright" width="30%"><input type="text" name="cardType" id="cardType" class="textinput" readonly="readonly"/></td>
					<td class="tableleft" width="10%">卡状态：</td>
					<td class="tableright" width="40%"><input type="text" name="cardState" id="cardState" class="textinput" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft" width="20%">公交类型：</td>
					<td class="tableright" width="30%"><input type="text" name="busType" id="busType" class="textinput" readonly="readonly"/></td>
					<td class="tableleft" width="10%">发卡日期：</td>
					<td class="tableright" width="40%"><input type="text" name="fkDate" id="fkDate" class="textinput" readonly="readonly"/></td>
				</tr>
			</table>
		</div>
		<div class="easyui-panel" style="width:100%;height:auto;overflow:hidden;border-left:none;border-bottom:none;" title="充值卡信息">
			<table style="width:100%" class="datagrid-toolbar tablegrid">
				<tr>
					<td class="tableleft" width="20%">充值卡类型：</td>
					<td class="tableright" width="30%"><input type="text" name="rechargeCardType" id="rechargeCardType" class="textinput" readonly="readonly"/></td>
					<td class="tableleft" width="10%">充值卡号码：</td>
					<td class="tableright" width="40%">
						<input type="text" name="rechargeCardNo" id="rechargeCardNo" class="textinput" readonly="readonly"/>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false" onclick="readRechargeCard();">读充值卡</a>
					</td>
				</tr>
				<tr>
					<td class="tableleft" width="20%">充值卡面额：</td>
					<td class="tableright" width="30%"><input type="text" name="rechargeCardFaceVal" id="rechargeCardFaceVal" class="textinput" readonly="readonly"/></td>
					<td class="tableleft" width="10%">充值卡密码：</td>
					<td class="tableright" width="40%">
						<input type="password" name="rechargeCardPassword" id="rechargeCardPassword" class="textinput" maxlength="10"/>
						<!-- <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-pwdbtn" plain="false" onclick="inputPassword();">输入密码</a> -->
					</td>
				</tr>
				<tr>
					<td colspan="4" width="100%" align="center" style="padding:2px">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" plain="false" onclick="confirmRecharge();">确认充值</a>
					</td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>