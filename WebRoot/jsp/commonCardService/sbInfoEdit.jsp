<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
    var sbInfoEditIsCanRe = "0";
	var sbInfoEditBaseSiinfo;
	var sbInfoEditCardinfo;
	$(function(){
		createCustomSelect({
			id:"sbInfoEditMedWholeNo1",
			value:"city_id",
			text:"city_name",
			table:"base_city",
			isShowDefaultOption:false,
			where:"nvl(city_type,'1') <> '2'",
			hasDownArrow:false,
			defaultValue:" ",
			orderby:"city_id desc",
			from:1,
			to:20,
			width:160
		});
		createCustomSelect({
			id:"sbInfoEditMedWholeNo2",
			value:"city_id",
			text:"city_name",
			table:"base_city",
			isShowDefaultOption:false,
			where:"nvl(city_type,'1') <> '2'",
			hasDownArrow:false,
			defaultValue:" ",
			orderby:"city_id desc",
			from:1,
			to:20,
			width:160
		});
	});
	function readCard(){
		try{
		$.messager.progress({text:"正在验证卡信息,请稍后..."});
		sbInfoEditCardinfo = getTouchCardInfo_9901();
		var cardInfo2 = getTouchCardInfo_9902();
		for(var key in cardInfo2){
			sbInfoEditCardinfo[key] = cardInfo2[key];
		}
		if(dealNull(sbInfoEditCardinfo["sub_Card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + sbInfoEditCardinfo["errMsg"],"error",function(){
				$.messager.progress("close");
				//window.history.go(0);
			});
			return false;
		}
		var subCardId = sbInfoEditCardinfo["card_Flag"];
		var subCardNo = sbInfoEditCardinfo["sub_Card_No"];
		var certNo = sbInfoEditCardinfo["cert_No"];
		$("#sbInfoEditMedWholeNo1").combobox("select",subCardId.substr(0,6));
		$("#sbInfoEditPersonalId1").val(subCardId);
		$("#sbInfoEditSubCardNo").val(subCardNo);
		$("#sbInfoEditCertNo").val(certNo);
		$("#sbInfoEditName").val(sbInfoEditCardinfo["name"]);
		getNewBaseSiinfo(certNo,subCardNo, function(){
			$.messager.progress("close");
		});
		}catch(e){
			defaultCatchErrMsg(e);
		}
	}
	function getNewBaseSiinfo(certNo,subCardNo,callback){
		$.post("baseSiinfo/baseSiinfoAction!getNewBaseSiinfo.action",{"baseSiinfo.certNo":certNo,subCardNo:subCardNo}, function(data){
			callback();
			if(data){
				if(data.status == "1"){
					jAlert(data.errMsg);
				}else{
					sbInfoEditBaseSiinfo = data.baseSiinfo;
					var medWholeNo = data.baseSiinfo.id.medWholeNo;
					if(dealNull(medWholeNo).length == 0){
						jAlert("新参保信息的统筹区域编码为空！");
					}else{
						var oldSubCardId = $("#sbInfoEditPersonalId1").val();
						var newSubCardId = medWholeNo + oldSubCardId.substr(6);
						$("#sbInfoEditMedWholeNo2").combobox("select",medWholeNo);
						$("#sbInfoEditPersonalId2").val(newSubCardId);
					}
				}
			} else {
				jAlert("请求出现异常，请重新进行操作！");
			}
		}, "json");
	}
	function writeCard(){
		if(!sbInfoEditCardinfo || dealNull(sbInfoEditCardinfo["sub_Card_No"]).length == 0){
			jAlert("请先进行读取以获取客户参保区域信息！");
			return;
		}
		if(subCardNo == ""){
			jAlert("请先进行读卡以获取社保卡号！");
			return;
		}
		var subCardNo = $("#sbInfoEditSubCardNo").val();
		var oldMedWholeNo = $("#sbInfoEditMedWholeNo1").combobox("getValue");
		var newMedWholeNo = $("#sbInfoEditMedWholeNo2").combobox("getValue");
		if(dealNull(newMedWholeNo) == ""){
			jAlert("客户新参保区域不能为空！");
			return;
		}
		if(dealNull(oldMedWholeNo) == dealNull(newMedWholeNo) && sbInfoEditIsCanRe != "0"){
			jAlert("客户新老参保区域相同，无需进行变更！");
			return;
		}
		if(newMedWholeNo == ""){
			jAlert("请选择新社保信息统筹区域！","error",function(){
				$("#sbInfoEditMedWholeNo2").combobox("showPanel");
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要变更该客户的参保区域信息吗？",function(e) {
			if(e){
				$.messager.progress({text:"正在进行写卡, 请稍后..."});
				if(modifyTouchRegion(subCardNo,newMedWholeNo)){
					$.post("baseSiinfo/baseSiinfoAction!updateBaseSiinfo.action", 
					{
						"baseSiinfo.id.medWholeNo":newMedWholeNo,
						"baseSiinfo.id.personalId":sbInfoEditBaseSiinfo.id.personalId,
						"baseSiinfo.certNo":$("#sbInfoEditCertNo").val(),
						"subCardNo":$("#sbInfoEditSubCardNo").val(),
						"subCardId":$("#sbInfoEditPersonalId2").val(),
						"oldSubCardId":$("#sbInfoEditPersonalId1").val()
					}, function(data){
						if(data.status == "1"){
							if(modifyTouchRegion(subCardNo,oldMedWholeNo)){
								$.messager.progress("close");
								$.messager.alert("系统消息","统筹区域变更失败， " + data.errMsg,"error",function(){
									$("#sbInfoEditForm").form("reset");
								});
							}else{
								$.messager.progress("close");
								$.messager.alert("系统消息","统筹区域变更失败， 请重新进行写卡！","error");
								sbInfoEditIsCanRe = "0";
							}
						}else{
							$.messager.progress("close");
							$.messager.alert("系统消息","统筹区域变更成功, 请取走卡片！","info",function(){
								$("#sbInfoEditForm").form("reset");
							});
						}
					}, "json");
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","写卡失败, 请重试","error");
				}
			}
		});
	}
</script>
<div>
	<form id="sbInfoEditForm">
		<h3 class="subtitle">旧社保信息</h3>
		<table class="tablegrid" style="width: 100%">
			<tr>
				<td class="tableleft" style="width: 30%">医疗保险统筹区编码：</td>
				<td class="tableright" style="width: 20%"><input id="sbInfoEditMedWholeNo1" class="textinput" type="text" readonly="readonly"/></td>
				<td class="tableleft" style="width: 10%">社保卡编码：</td>
				<td class="tableright" style="width: 40%">
					<input id="sbInfoEditPersonalId1" class="textinput" type="text" readonly="readonly" style="width: 250px"/>
					<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
				</td>
			</tr>
			<tr>
				<td class="tableleft" style="width: 30%">客户姓名：</td>
				<td class="tableright" style="width: 20%"><input id="sbInfoEditName" class="textinput" type="text" readonly="readonly" /></td>
				<td class="tableleft" style="width: 10%">身份证号：</td>
				<td class="tableright" style="width: 40%"><input id="sbInfoEditCertNo" class="textinput" type="text" readonly="readonly" /></td>
			</tr>
			<tr>
				<td class="tableleft" style="width: 30%">社保卡号：</td>
				<td class="tableright" style="width: 20%"><input id="sbInfoEditSubCardNo" class="textinput" type="text" readonly="readonly"/></td>
				<td class="tableleft" style="width: 10%">&nbsp;</td>
				<td class="tableright" style="width: 40%">&nbsp;</td>
			</tr>
		</table>
		<h3 class="subtitle">新社保信息</h3>
		<table class="tablegrid" style="width: 100%">
			<tr>
				<td class="tableleft" style="width: 30%">医疗保险统筹区编码：</td>
				<td class="tableright" style="width: 20%"><input id="sbInfoEditMedWholeNo2" class="textinput" type="text" readonly="readonly"/></td>
				<td class="tableleft" style="width: 10%">社保卡编码：</td>
				<td class="tableright" style="width: 40%">
					<input id="sbInfoEditPersonalId2" class="textinput" type="text" readonly="readonly" style="width: 250px"/>
					<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="writeCard()">写卡</a>
				</td>
			</tr>
		</table>
	</form>
</div>